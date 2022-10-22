
####create VPC
resource "aws_vpc" "clixx" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "CLIXXVPC"
  }
}

#################################################################################################
#####create 2 public subnets for 450 hosts
resource "aws_subnet" "pub1" {
  vpc_id                    = aws_vpc.clixx.id
  cidr_block                = "10.0.0.0/23"
  availability_zone         = "${data.aws_availability_zones.clixx_az.names[0]}"
  map_public_ip_on_launch   = true

  tags = {
    Name = "PUB-SUB1"
  }
}

resource "aws_subnet" "pub2" {
  vpc_id                    = aws_vpc.clixx.id
  cidr_block                = "10.0.2.0/23"
  availability_zone         = "${data.aws_availability_zones.clixx_az.names[1]}"

  tags = {
    Name = "PUB-SUB2"
  }
}
################################################

##############CREATE AN INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.clixx.id

  tags = {
    Name = "CLIXX-IGW"
  }
}

#####Create a custom route table and associate it to the CLIXXPUBSUBS (public subnets)
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.clixx.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "BASTION-RT"
  }
}

######## ASSOCIATE RT1 WITH THE PUBLIC SUBNETS
resource "aws_route_table_association" "pub1" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "pub2" {
  subnet_id      = aws_subnet.pub2.id
  route_table_id = aws_route_table.rt1.id
}
######################################################################

######## CREATE AMI
# data "aws_ami" "clixx" {
#     owners      = ["amazon"]
#     most_recent = true
#     filter {
#       name      = "virtualization-type"
#       values    = ["hvm"]
#     }
#     filter {
#       name      = "architecture"
#       values    = ["x86_64"]
#     }
#     filter {
#       name      = "name"
#       values    = ["amzn2-ami-hvm-2.0*"]
#     }
# }
# ###### CREATE EBS VOLUME
# resource "aws_ebs_volume" "clixx" {
#   availability_zone = "us-east-1a"
#   size              = 30

#   tags = {
#     Name = "Clixx-ebs"
#   }
# }

# ##### CREATE EBS SNAPSHOT
# resource "aws_ebs_snapshot" "clixx" {
#   volume_id = aws_ebs_volume.clixx.id

#   tags = {
#     Name = "Clixx_snap"
#   }
# }
# resource "aws_ami" "clixx" {
#   name                = "CLIXX-IMG"
#   virtualization_type = "hvm"
#   root_device_name    = "/dev/xvda"

#   ebs_block_device {
#     device_name               = "/dev/xvda"
#     volume_type               = "gp2"
#     volume_size               = 30
#     snapshot_id               = aws_ebs_snapshot.clixx.id
#     delete_on_termination     = true
#   }
# }
########################################################################################
######## CREATE APP LOADBALANCER ON PUBLIC SUBNET AND ASSOCIATE WITH THE WEB APP SERVER ASG
resource "aws_lb" "applb" {
  name                    = "app-lb"
  load_balancer_type      = "application"
  security_groups         = [aws_security_group.applbsg.id]
  ip_address_type         = "ipv4"
  subnets                 = [aws_subnet.pub1.id, aws_subnet.pub2.id]

  tags               = {
    Name              = "APP-LB"
  }
}

resource "aws_lb_target_group" "apptg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.clixx.id
  target_type = "instance"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    path                = "/"
    matcher             = 200
  }

  tags            = {
    Name          = "APP-TG"
  }
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.applb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"  ### route requests to a target group
    target_group_arn = aws_lb_target_group.apptg.arn
  }
}

##########################################################################################################
########### CREATE 6 PRIVATE SUBNETS
#############################################
### 2 private subnets for app server and EFS for 256 hosts
resource "aws_subnet" "webpriv1" {
  vpc_id                  = aws_vpc.clixx.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "${data.aws_availability_zones.clixx_az.names[0]}"

  tags = {
    Name = "APP-SUB1"
  }
}

resource "aws_subnet" "webpriv2" {
  vpc_id                  = aws_vpc.clixx.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "${data.aws_availability_zones.clixx_az.names[1]}"

  tags = {
    Name = "APP-SUB2"
  }
}

##### 2 private subnets for RDS 680 hosts
resource "aws_subnet" "rdspriv1" {
  vpc_id                    = aws_vpc.clixx.id
  cidr_block                = "10.0.12.0/22"
  availability_zone         = "${data.aws_availability_zones.clixx_az.names[0]}"

  tags = {
    Name = "RDS-SUB1"
  }
}

resource "aws_subnet" "rdspriv2" {
  vpc_id                  = aws_vpc.clixx.id
  cidr_block              = "10.0.20.0/22"
  availability_zone       = "${data.aws_availability_zones.clixx_az.names[1]}"

  tags = {
    Name = "RDS-SUB2"
  }
}

###### 2 private subnets for oracle-db 254 host
resource "aws_subnet" "oraclepriv1" {
  vpc_id                    = aws_vpc.clixx.id
  cidr_block                = "10.0.8.0/24"
  availability_zone         = "${data.aws_availability_zones.clixx_az.names[0]}"

  tags = {
    Name = "ORACLE-SUB1"
  }
}

resource "aws_subnet" "oraclepriv2" {
  vpc_id                  = aws_vpc.clixx.id
  cidr_block              = "10.0.18.0/24"
  availability_zone       = "${data.aws_availability_zones.clixx_az.names[1]}"

  tags = {
    Name = "ORACLE-SUB2"
  }
}

#########################################################################################
########################################################################
############ CREATE AN EIP FOR THE NAT GATEWAY
resource "aws_eip" "nat" {
  vpc      = true

  tags = {
    Name = "NAT-EIP"
  }
}
################### CREATE A NAT GATEWAY ON ONE OF THE PUBLIC SUBNETS
resource "aws_nat_gateway" "clixxnat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.pub1.id

  tags = {
    Name = "CLIXX-NATGW"
  }
}

####### CREATE ROUTE TABLE FOR WEB APP SERVER PRIVATE SUBNETS AND
### ASSOCIATE NAT GW WITH THE WEB APP SERVER ROUTE TABLE###########
resource "aws_route_table" "rt2" {
  vpc_id            = aws_vpc.clixx.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id    = aws_nat_gateway.clixxnat.id
  }

  tags = {
    Name = "APPSERVER-RT"
  }
}

######## ASSOCIATE RT1 WITH THE PUBLIC SUBNETS
resource "aws_route_table_association" "webpriv1" {
  subnet_id      = aws_subnet.webpriv1.id
  route_table_id = aws_route_table.rt2.id
}

resource "aws_route_table_association" "webpriv2" {
  subnet_id      = aws_subnet.webpriv2.id
  route_table_id = aws_route_table.rt2.id
}
##########################################################################################


########### RESTORE SHARED RDS SNAPSHOT #################################
####### CREATE RDS SUBNET GROUP USING THE RDS PRIVATE SUBNETS
resource "aws_db_subnet_group" "rds" {
  name       = "rdssub-grp"
  subnet_ids = [aws_subnet.rdspriv1.id, aws_subnet.rdspriv2.id]

  tags = {
    Name = "RDSSUB-GRP"
  }
}
resource "aws_db_instance" "clixx-db" {
  instance_class             = "db.m6g.large"
  identifier                 = "clixx-apps-db"
  engine                     = "mysql"
  name                       = local.db_creds.database
  username                   = local.db_creds.username
  password                   = local.db_creds.password
  publicly_accessible        = false
  snapshot_identifier        = data.aws_db_snapshot.clixx_db_snapshot.id
  vpc_security_group_ids     = [aws_security_group.rdssg.id]
  skip_final_snapshot        = true
  db_subnet_group_name       = aws_db_subnet_group.rds.id
  multi_az                   = true
  storage_type               = "gp2"
  auto_minor_version_upgrade = "false"

}

####################################################################################

################# create EFS
resource "aws_efs_file_system" "clixx-efs" {
  encrypted           = true
  tags = {
    Name              = "clixx-efs"
  }
}

#### mount EFS
resource "aws_efs_mount_target" "clixx-mt1" {
  file_system_id        = "${aws_efs_file_system.clixx-efs.id}"
  subnet_id             = aws_subnet.webpriv1.id
  security_groups       = [aws_security_group.efssg.id]
}

resource "aws_efs_mount_target" "clixx-mt2" {
  file_system_id        = "${aws_efs_file_system.clixx-efs.id}"
  subnet_id             = aws_subnet.webpriv2.id
  security_groups       = [aws_security_group.efssg.id]
}

######################### BASTION KEYPAIR ############################
resource "aws_key_pair" "bast-key" {
  key_name   = "MyEC2keypair"
  public_key = local.db_creds.MyEC2KeyPair
  # public_key = file(var.PATH_TO_BAST_PUBLIC_KEY)
}

##################### APP SERVER KEYPAIR ###########################
resource "aws_key_pair" "app-key" {
  key_name   = "MyEC2keypair_Priv"
  public_key = local.db_creds.MyEC2KeyPair_Priv
  # public_key = file(var.PATH_TO_APP_PUBLIC_KEY)
}
####################################################################

####################################################################


######## ROUTE 53 #####

resource "aws_route53_record" "clixx" {
  zone_id = data.aws_route53_zone.clixx.zone_id
  name    = var.domain
  type    = "A"
  set_identifier         = each.key
  for_each    = toset(var.r53_region)

  alias {
    name                   = aws_lb.applb.dns_name  ##### LB DNS
    zone_id                = aws_lb.applb.zone_id
    evaluate_target_health = true
  }

  latency_routing_policy {
    region      = each.key

  }
}


# resource "aws_autoscaling_notification" "sns" {
#   group_names = [
#     aws_autoscaling_group.clixx-asg.name
#   ]

#   notifications = [
#     "autoscaling:EC2_INSTANCE_LAUNCH",
#     "autoscaling:EC2_INSTANCE_TERMINATE",
#     "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
#     "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
#   ]

#   topic_arn = aws_sns_topic.clixx.arn
# }

# resource "aws_sns_topic" "clixx" {
#   name = "clixx-sns"

# }

