provider "aws" {
region = var.AWS_REGION
access_key = var.AWS_ACCESS_KEY
secret_key = var.AWS_SECRET_KEY
}


############ PROVIDER FOR SOPS DB SECRETS ENCRYPTION ############
# terraform {
#   required_providers {
#     sops = {
#       source = "carlpett/sops"
#       version = "~> 0.5"
#     }
#   }
# }