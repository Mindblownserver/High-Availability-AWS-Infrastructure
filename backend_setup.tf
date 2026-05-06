data "aws_ami" "amazon_linux" {
  # within arguments depend on the data type(?) "aws_ami"
  most_recent = true # most recent of the results

  filter {
    name   = "name" # filter the field name. AMI name doesn't work!!!
    values = ["al2023-ami-2023.11*"]
  }
  owners = ["137112412989"] # Amazon owner code

} # This returns the identifier of the selected AMI
# Every data block has an id, this one's id is data.aws_ami.amazon_linux. Now it's accessible anywhere (within our main.tf of course :D)
/* ============================= */
resource "aws_key_pair" "app_key_pair" {
  key_name   = "app_keypair"
  public_key = file(var.public_key)

  tags = {
    Name = "learn terra"
  }
}

## The destination of the requests that reach lb.
## Maps to port 80 and protocol HTTP
resource "aws_lb_target_group" "lb_target_group" {
  name     = "lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id

  # Add health checks
  health_check {
    enabled = true
    # healthy-threshold = 3 # by default
    # interval=30 # by default (in seconds)
    # timeout =30 # by default (in seconds)
    # port = "traffic-port" # by default. same port as group
    # unhealthy-threshold= 3 # by default
    path = "/" # / by default.
    #matcher = "200" # "200" by default. the status code to know if app is healthy
  }
}

## Security group. Who can talk to lb
resource "aws_security_group" "lb" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # to DoS it and see scaling
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.app_vpc.id

}

## Lo and Behold. The lb itself
resource "aws_lb" "app_lb" {
  name               = "backend"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  #depends_on = [aws_autoscaling_group.auto_sc_group]
}

## OnRequestReceived. on port X through protocol Y, which action should it take?
resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

resource "aws_autoscaling_group" "auto_sc_group" {
  max_size         = 4
  min_size         = 2
  desired_capacity = 2
  launch_template {
    id      = aws_launch_template.launch_templ.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  target_group_arns    = [aws_lb_target_group.lb_target_group.arn] # to link target group with auto scaling group


  lifecycle {
    ignore_changes = [desired_capacity, target_group_arns] #  stops scaling your instances when previous params change
  }

  tag {
    key                 = "Name"
    value               = "ASG instance"
    propagate_at_launch = true
  }
}

## What's autoscaling group without policy?
## Autoscaling policy
resource "aws_autoscaling_policy" "cpu_usage" {
  name                   = "cpu-usage"
  autoscaling_group_name = aws_autoscaling_group.auto_sc_group.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

resource "aws_autoscaling_attachment" "asg_lb_link" {
  autoscaling_group_name = aws_autoscaling_group.auto_sc_group.id
  lb_target_group_arn    = aws_lb_target_group.lb_target_group.arn
}

resource "aws_launch_template" "launch_templ" {
  name          = "launch-template"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.app_key_pair.key_name

  user_data = base64encode(templatefile("${path.module}/backend-script-setup.tftpl", {
    DB_HOST= aws_db_instance.db.endpoint
    DB_USER=var.db_username
    DB_PASSWORD= var.db_passwd
    DB_NAME= var.db_name
  }))
  tag_specifications {
    resource_type = "instance"
    tags = {
      key   = "Name"
      value = "Auto Scaling Instance"
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.backend_sg.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}
## For future uses, consider aws_vpc_security_group_ingress_rule onstead of ingress bloc. The same applies for egress
## Because egress and ingress blocs struggle to manage multiple CIDR blocks
resource "aws_security_group" "backend_sg" {
  name        = "backend-server-sg"
  description = "Allow the http"
  vpc_id      = aws_vpc.app_vpc.id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [ aws_security_group.lb.id ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # This means to allow ANY protocol to access the internet/outside
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "learn terra"
  }

  depends_on = [aws_vpc.app_vpc]
}