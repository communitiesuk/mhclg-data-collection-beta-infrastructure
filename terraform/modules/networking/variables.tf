variable "default_tags" {
  type        = map(string)
  description = "Tags to use for each resource"
}

variable "number_of_public_subnets" {
  default = 2
  description = "Number of AZs we want to set up a public subnet in. ALB requires at least 2."
}
