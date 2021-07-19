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

variable "ecs_security_group" {
  description = "ECS Cluster Security Group"
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
