module "networking" {
  source                   = "./modules/networking"
  number_of_public_subnets = var.number_of_public_subnets
  default_tags             = var.default_tags
}

module "compute_cluster" {
  source                = "./modules/compute_cluster"
  aws_vpc               = module.networking.aws_vpc
  aws_pub_subnet        = module.networking.aws_pub_subnet
  rds_postgres_endpoint = module.database.rds_postgres_endpoint
  database_name         = var.database_name
  database_username     = var.database_username
  database_password     = var.database_password
  public_ssh            = var.public_ssh
  rails_master_key      = var.rails_master_key
  rails_log_to_stdout   = var.rails_log_to_stdout
  default_tags          = var.default_tags
}

module "database" {
  source             = "./modules/database"
  aws_vpc            = module.networking.aws_vpc
  aws_pub_subnet     = module.networking.aws_pub_subnet
  ecs_security_group = module.compute_cluster.ecs_security_group
  database_name      = var.database_name
  database_username  = var.database_username
  database_password  = var.database_password
  default_tags       = var.default_tags
}
