variable "default_tags" {
  type = map(string)
  default = {
    application-name       = "MHCLG Data Collection"
    application-identifier = "CLDC"
    business-unit          = "Digital Delivery"
    budget-holder-email    = "katy.armstrong@communities.gov.uk"
    tech-contact-email     = "mhclg-data-collection@googlegroups.com"
    stage                  = "beta"
  }
}

variable "database_username" {
  type      = string
  sensitive = true
}

variable "database_password" {
  type      = string
  sensitive = true
}

variable "rails_master_key" {
  type      = string
  sensitive = true
}

variable "rails_log_to_stdout" {
  default = true
}

variable "public_ssh" {
  type        = string
  description = "The public SSH key to use for ECS"
  sensitive   = true
}

variable "database_name" {
  default = "DataCollectorPostgres"
}

variable "number_of_public_subnets" {
  default     = 2
  description = "Number of AZs we want to set up a public subnet in. ALB requires at least 2."
}
