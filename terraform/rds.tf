resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "postgres-subnet-group"
  subnet_ids = aws_subnet.pub_subnet.*.id

  tags = var.default_tags
}

resource "aws_db_instance" "postgres" {
  name                         = var.database_name
  allocated_storage            = 5 # In gigabytes
  backup_retention_period      = 2
  backup_window                = "01:00-01:30"
  maintenance_window           = "sun:03:00-sun:03:30"
  multi_az                     = true
  engine                       = "postgres"
  engine_version               = "13.3"
  storage_encrypted            = true
  username                     = var.database_username
  password                     = var.database_password
  port                         = 5432
  instance_class               = "db.t3.micro"
  skip_final_snapshot          = true
  performance_insights_enabled = true
  db_subnet_group_name         = aws_db_subnet_group.postgres_subnet_group.name
  vpc_security_group_ids       = [aws_security_group.rds_security_group.id, aws_security_group.ecs_security_group.id]

  tags = var.default_tags
}
