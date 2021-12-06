locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}

locals {
  aws_creds = jsondecode(data.aws_secretsmanager_secret_version.aws-creds.secret_string)
}