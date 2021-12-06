data "template_file" "bootstrap" {
  template = file(format("%s/scripts/bootstrap.tpl", path.module))
  vars = {
    FILE_SYSTEM_ID="${aws_efs_file_system.clixx-efs.id}"
    LOADBALANCER="${aws_lb.applb.dns_name}"
    #rds_endpoint="${data.aws_db_instance.wordpress.address}"
    rds_endpoint="${aws_db_instance.clixx-db.address}"
    MOUNT_POINT="/var/www/html/"
    CONFIG_FILE="/var/www/html/wp-config.php"
    DB_NAME="${local.db_creds.database}"
    DB_USER="${local.db_creds.username}"
    DB_PASS="${local.db_creds.password}"
    DOMAIN="${var.domain}"

  }
}

data "template_file" "bastbootstrap" {
  template = file(format("%s/scripts/bastion.tpl", path.module))
}