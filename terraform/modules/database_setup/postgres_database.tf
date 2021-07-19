# Actually create the database instance within Postgres RDS so you can go from Terraform to pipeline
# deploy and running in a single shot. This effectively replaces rake db:create
provider "postgresql" {
  host     = replace(var.rds_postgres_endpoint, ":5432", "")
  port     = 5432
  username = var.database_username
  password = var.database_password
}

resource "postgresql_database" "data_collector_db" {
  name              = var.database_name
  template          = "template0"
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
}
