# locals {
#   db_user  = yamldecode(data.aws_kms_secrets.creds.plaintext["username"])
#   db_pass  = yamldecode(data.aws_kms_secrets.creds.plaintext["password"])
#   database = yamldecode(data.aws_kms_secrets.creds.plaintext["database"])
# }

# locals {
#   db_creds = yamldecode(sops_decrypt_file(("db-creds.yml")))
# }

