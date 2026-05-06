resource "aws_db_subnet_group" "db" {
  name = "db-subnet-grp"
  subnet_ids = [ aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id ]

  tags = {
    Name= "learn terra"
  }
}

resource "aws_security_group" "db" {
  name = "db-security-group"
  vpc_id = aws_vpc.app_vpc.id
  ingress{
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }
  egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_db_instance" "db" {
  identifier = "db"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "8.0"
  username               = var.db_username
  password               = var.db_passwd
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

}