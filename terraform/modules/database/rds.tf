resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "postgres-subnet-group"
  subnet_ids = var.aws_pub_subnet.*.id

  tags = var.default_tags
}

resource "aws_db_instance" "postgres" {
  name                         = "DataCollectorPostgres"
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
  vpc_security_group_ids       = [aws_security_group.rds_security_group.id, var.ecs_security_group.id]

  tags = var.default_tags
}

#TODO actually create the database required so you can go from Terraform to pipeline
# deploy and running in a single shot. This effectively replaces rake db:create
provider "postgresql" {
  host     = aws_db_instance.postgres.endpoint
  port     = 5432
  username = var.database_username
  password = var.database_password
}

resource "postgresql_role" "application_role" {
  name               = var.database_username
  login              = true
  password           = var.database_password
  encrypted_password = true
}

resource "postgresql_database" "data_collector_db" {
  name              = var.database_name
  owner             = postgresql_role.application_role.name
  template          = "template0"
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
}
