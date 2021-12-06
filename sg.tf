########### CREATE SG FOR THE BASTION SERVER(ON PUBLIC SUBNET)
resource "aws_security_group" "bastsg" {
  name        = "BS-SG"
  description = "Bastion server Security Group"
  vpc_id      = aws_vpc.clixx.id

  ingress {
      from_port        = 443  #### HTTPS
      to_port          = 443
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  ingress {
     from_port        = 22 ### SSH
     to_port          = 22
     protocol         = "TCP"
     cidr_blocks      = ["0.0.0.0/0"]
    }

  ingress {
     from_port        = 80 ### HTTP
     to_port          = 80
     protocol         = "TCP"
     cidr_blocks      = ["0.0.0.0/0"]
    }

  ingress {
     from_port        = 3306 ### MYSQL/Aurora
     to_port          = 3306
     protocol         = "TCP"
     security_groups  = [aws_security_group.rdssg.id]
    }

  egress {
   from_port        = 0
   to_port          = 0
   protocol         = "-1"  ###(all traffic)
   cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "BS-SG"
  }
}


######## CREATE WEB APP LB SECURITY GROUP  #############################
resource "aws_security_group" "applbsg" {
  name        = "APPLB-SG"
  description = "App server loadbalancer Security Group"
  vpc_id      = aws_vpc.clixx.id

  ingress {
      from_port        = 443  #### HTTPS
      to_port          = 443
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  ingress {
     from_port        = 80 ### HTTP
     to_port          = 80
     protocol         = "TCP"
     cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
   from_port        = 0
   to_port          = 0
   protocol         = "-1"  ###(all traffic)
   cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "APPLB-SG"
  }
}
###########################################################

######### CREATE RDS(MYSQL/AURORA) SG ########################
resource "aws_security_group" "rdssg" {
  name        = "RDS-SG"
  description = "RDS Security Group"
  vpc_id      = aws_vpc.clixx.id

  tags = {
    Name = "RDS-SG"
  }
}
resource "aws_security_group_rule" "rds-web" {
  security_group_id             = aws_security_group.rdssg.id
  type                          = "ingress"
  protocol                      = "tcp"
  from_port                     = 3306
  to_port                       = 3306
  source_security_group_id      = aws_security_group.webappsg.id
}
resource "aws_security_group_rule" "rds-bastion" {
  security_group_id             = aws_security_group.rdssg.id
  type                          = "ingress"
  protocol                      = "tcp"
  from_port                     = 3306
  to_port                       = 3306
  source_security_group_id      = aws_security_group.bastsg.id
}
resource "aws_security_group_rule" "out_rds" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.rdssg.id
  cidr_blocks              = ["0.0.0.0/0"]
}
############################################################################

########### CREATE ORACLE-DB SG ################################
resource "aws_security_group" "oraclesg" {
  name        = "ORACLE-SG"
  description = "ORACLE Security Group"
  vpc_id      = aws_vpc.clixx.id

  ingress {
      from_port        = 1521  #### (oracle)
      to_port          = 1521
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
   from_port        = 0
   to_port          = 0
   protocol         = "-1"  ###(all traffic)
   cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "ORACLE-SG"
  }
}

############# CREATE EFS SG ##########################################
resource "aws_security_group" "efssg" {
  name        = "EFS-SG"
  description = "EFS Security Group"
  vpc_id      = aws_vpc.clixx.id

  tags = {
    Name = "EFS-SG"
  }
}
resource "aws_security_group_rule" "efs-web" {
  security_group_id             = aws_security_group.efssg.id
  type                          = "ingress"
  protocol                      = "tcp"
  from_port                     = 2049
  to_port                       = 2049
  source_security_group_id      = aws_security_group.webappsg.id
}
resource "aws_security_group_rule" "out_efs" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.efssg.id
  cidr_blocks              = ["0.0.0.0/0"]
}

############ CREATE WEB APP SERVER SG ############################################
resource "aws_security_group" "webappsg" {
  name        = "APP-SG"
  description = "Bastion server Security Group"
  vpc_id      = aws_vpc.clixx.id

  ingress {
      from_port        = 443  #### HTTPS
      to_port          = 443
      protocol         = "TCP"
      security_groups  = [aws_security_group.applbsg.id]
    }

  ingress {
     from_port        = 80 ### HTTP
     to_port          = 80
     protocol         = "TCP"
     security_groups  = [aws_security_group.applbsg.id]
    }

  ingress {
     from_port        = 22 ### SSH
     to_port          = 22
     protocol         = "TCP"
     security_groups  = [aws_security_group.bastsg.id]
    }

  ingress {
     from_port        = 3306 ### MYSQL/Aurora
     to_port          = 3306
     protocol         = "TCP"
     security_groups  = [aws_security_group.rdssg.id]
    }

  ingress {
     from_port        = 2049 ### NFS/EFS
     to_port          = 2049
     protocol         = "TCP"
     security_groups  = [aws_security_group.efssg.id]
    }

  ingress {
     from_port        = 1521 ### oracle-db
     to_port          = 1521
     protocol         = "TCP"
     security_groups  = [aws_security_group.oraclesg.id]
    }

  egress {
   from_port        = 0
   to_port          = 0
   protocol         = "-1"  ###(all traffic)
   cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "APP-SG"
  }
}

