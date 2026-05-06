resource "aws_db_subnet_group" "db" {
  name = "db-subnet-grp"
  subnet_ids = [ aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id ]

  tags = {
    Name= "learn terra"
  }
}