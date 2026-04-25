# This section will create the subnet group for the RDS instance using the private subnets
resource "aws_db_subnet_group" "bassiy-rds" {
  name       = "acs-rds"
  subnet_ids = aws_subnet.private[*].id

  tags = merge(
    var.tags,
    {
      Name = "bassiy-rds"
    },
  )
}

# create the RDS instance with the subnet group
resource "aws_db_instance" "bassiy-rds" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0.45"
  instance_class         = "db.t3.micro"
  db_name                = "bassiydb"
  username               = var.master_username
  password               = var.master_password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.bassiy-rds.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.datalayer_sg.id]
  multi_az               = false
}