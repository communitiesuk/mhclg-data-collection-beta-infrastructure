variable "default_tags" {
  type        = map(string)
  description = "Tags to use for each resource"
}

variable "aws_vpc" {
  description = "The main VPC"
}

variable "aws_pub_subnet" {
  description = "Public Subnets"
}

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

variable "public_ssh" {
  type        = string
  description = "The public SSH key to use for ECS"
  sensitive   = true
}

variable "rds_postgres_endpoint" {
  description = "Endpoint for the Postgres RDS instance"
}

variable "rails_master_key" {
  type      = string
  sensitive = true
}

variable "rails_log_to_stdout" {
  description = "Whether Rails should log to STDOUT or not"
}
