# Explicitly defining vpc requires you to explicitly define subnet.
# Because if you don't, terraform (and AWS) will use default subnet != vpc.
# Get error because can't have subnet not in the same vpc as security group
resource "aws_vpc" "app_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "learn terra"
  }
}

## AZ-a
data "aws_availability_zone" "az-a" {
  state = "available"
  name  = "us-east-1a"
}


resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zone.az-a.name

  tags = {
    Name = "AZ-A"
  }
  depends_on = [aws_vpc.app_vpc]
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zone.az-a.name

  tags = {
    Name = "AZ-A"
  }
  depends_on = [aws_vpc.app_vpc]
}
## AZ-b
data "aws_availability_zone" "az-b" {
  state = "available"
  name  = "us-east-1b"
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zone.az-b.name

  tags = {
    Name = "AZ-B"
  }
  depends_on = [aws_vpc.app_vpc]
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zone.az-b.name

  tags = {
    Name = "AZ-B"
  }
  depends_on = [aws_vpc.app_vpc]
}


# Public subnet routing setup
## Linking public subnet and "public" routing table
resource "aws_route_table_association" "public_subnet_a_rt_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_subnet_rt.id
}

resource "aws_route_table_association" "public_subnet_b_rt_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_subnet_rt.id
}

## Defining routing table which routes 0.0.0.0/0 to internet gateway
resource "aws_route_table" "public_subnet_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_vpc_ig.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  tags = {
    Name = "learn terra"
  }
}

resource "aws_internet_gateway" "app_vpc_ig" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "learn terra"
  }
}

resource "aws_eip" "eip_a" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.app_vpc_ig]
}

resource "aws_eip" "eip_b" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.app_vpc_ig]
}
resource "aws_nat_gateway" "nat_a" {
  subnet_id     = aws_subnet.public_subnet_a.id
  allocation_id = aws_eip.eip_a.id
}

resource "aws_nat_gateway" "nat_b" {
  subnet_id     = aws_subnet.public_subnet_b.id
  allocation_id = aws_eip.eip_b.id
}

resource "aws_route_table" "private_subnet_a_rt" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_a.id
  }
}

resource "aws_route_table" "private_subnet_b_rt" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_b.id
  }
}

resource "aws_route_table_association" "private_subnet_a_rt_association" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_subnet_a_rt.id
}

resource "aws_route_table_association" "private_subnet_b_rt_association" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_subnet_b_rt.id
}
