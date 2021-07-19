variable "database_name" {
  type      = string
  sensitive = true
}

variable "database_username" {
  type      = string
  sensitive = true
}

variable "database_password" {
  type      = string
  sensitive = true
}

variable "rds_postgres_endpoint" {
  description = "Endpoint for the Postgres RDS instance"
}
