
# Resource block defines the component of our infrastructure
resource "aws_instance" "frontend_server" {
  # the within arguments depend on the resource type
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  key_name                    = aws_key_pair.app_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.frontend_sg.id]
  subnet_id                   = aws_subnet.public_subnet_a.id
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/frontend-script-setup.tftpl", {
    backend_lb_url = aws_lb.app_lb.dns_name
  })

  tags = {
    Name = var.instance_name
  }
  depends_on = [aws_security_group.frontend_sg, aws_key_pair.app_key_pair, aws_lb.app_lb]

}


resource "aws_security_group" "frontend_sg" {
  name        = "frontend-server-sg"
  description = "Allow the http"
  vpc_id      = aws_vpc.app_vpc.id

  # Config to allow ssh (22) from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Unsafe, should use host's ip @
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

