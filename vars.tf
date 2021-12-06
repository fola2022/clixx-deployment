variable "AWS_ACCESS_KEY" {}

variable "AWS_SECRET_KEY" {}


variable "AWS_REGION" {
  default = "us-east-1"
}

##########################################################
# variable "db_user" {}

# variable "db_password" {}

# variable "db_name" {}

variable "environment" {
  default = "dev"
}

variable "owner_email" {
  default = "atandafatimat01@gmail.com"
}

variable "support" {
  default = "support@stackitsolutions.com"
}


variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}


variable "PATH_TO_BAST_PRIVATE_KEY" {
  default = "MyEC2KeyPair.ppk"
}

variable "PATH_TO_BAST_PUBLIC_KEY" {
  default = "MyEC2KeyPair.pub"
}

variable "PATH_TO_APP_PRIVATE_KEY" {
  default = "MyEC2KeyPair_Priv.ppk"
}

variable "PATH_TO_APP_PUBLIC_KEY" {
  default = "MyEC2KeyPair_Priv.pub"
}

variable "AMIS" {
  type = map(string)
  default = {
   # us-east-1 = "ami-13be557e"
    us-east-1 = "ami-08f3d892de259504d"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-844e0bf7"
  }
}

variable "ami" {
  default = ""
}

variable "azs" {
  type = list(string)
  default =[
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
    "us-east-1d",
    "us-east-1e",
    "us-east-1f",
  ]
}


variable "rds_db" {
  default = "clixxwordpressdb"
}

variable "domain" {
  default = "clixx-fatimat.com"
}

variable "r53_region" {
  type    = list(string)
  default = [
    "us-east-1",
    "us-west-1",
    "af-south-1",
    "ap-east-1",
    "cn-north-1",
    "eu-west-2",
    "me-south-1",
    "sa-east-1",
  ]
}