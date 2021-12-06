data "aws_db_snapshot" "clixx_db_snapshot" {
  db_snapshot_identifier = var.rds_db
  most_recent = true
  #snapshot_type  = "shared"
  #include_shared = true
}

data "aws_route53_zone" "clixx" {
  name = var.domain
}

data "aws_availability_zones" "clixx_az" {
    state = "available"
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "db-creds"
}

# locals {
#   db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
# }
###########################################################


# data "aws_vpc" "vpc" {
#   id = var.vpc_id
# }

# data "aws_subnet_ids" "clixx" {
#   #id = "${var.subnet_id}"
#   vpc_id = var.vpc_id
# }

# data "aws_subnet" "subnet" {
#   id   = var.subnet
# }


# ##### pulling existing security group ###
# data "aws_security_group" "clixx-sg" {
#    id = var.security_group_id
# }


# data "aws_ami" "clixx-ami" {
#   most_recent     = true
#   owners          = ["self"]
#   name_regex="^"
#   filter {
#     name          = "name"
#     values        = ["TESTIMG"]
#   }
# }
