#######################################################################################################
############### CREATE BASTION SERVER (ASG)
###### BASTION LB
resource "aws_lb" "bs" {
  name                    = "bastion-lb"
  load_balancer_type      = "application"
  security_groups         = [aws_security_group.bastsg.id]
  ip_address_type         = "ipv4"
  subnets                 = [aws_subnet.pub1.id, aws_subnet.pub2.id]

  tags               = {
    Name              = "BASTION-LB"
  }
}


resource "aws_lb_target_group" "bstg" {
  name     = "bastion-tg"
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
    Name          = "BASTION-TG"
  }
}

resource "aws_lb_listener" "bs" {
  load_balancer_arn = aws_lb.bs.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"  ### route requests to a target group
    target_group_arn = aws_lb_target_group.bstg.arn
  }
}

resource "aws_launch_template" "bstp" {
   name                   = "bastion-tp"
   image_id               = data.aws_ami.clixx.id
   instance_type          = var.instance_type
   key_name               = aws_key_pair.bast-key.id
   user_data              = "${base64encode(data.template_file.bastbootstrap.rendered)}"
   #vpc_security_group_ids = [aws_security_group.bastsg.id]

  #  block_device_mappings {
  #   device_name = "/dev/sda1"

  #   ebs {
  #     volume_size = 30
  #   }
  #}

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [aws_security_group.bastsg.id]
  }

  iam_instance_profile {
        arn = aws_iam_instance_profile.clixx-profile.arn
       }

  tag_specifications {
      resource_type = "instance"

      tags = {
        Name          = "BASTION-TP"
        Environment   = var.environment
        System        = "CliXX"
        Owner_Email   = var.owner_email
        Backup        = "Yes"
        Support_Email = var.support
      }
    }
}


##### ASG
resource "aws_autoscaling_group" "bs-asg" {
  name                        = "BASTION-ASG"
  vpc_zone_identifier         = [aws_subnet.pub1.id, aws_subnet.pub2.id]
  desired_capacity            = 1
  min_size                    = 1
  max_size                    = 3
  target_group_arns           = [aws_lb_target_group.bstg.arn]
  health_check_grace_period   = 200
  force_delete = true

  launch_template {
    id      = aws_launch_template.bstp.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "BASTION-ASG"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "bs" {
  name                   = "bastion-pol"
  adjustment_type        = "PercentChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.bs-asg.id

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}

##########################################################################################################

############# CREATE APP SERVER ASG ##################################

resource "aws_launch_template" "apptp" {
   name                   = "APPSV-TP"
   image_id               = data.aws_ami.clixx.id
   instance_type          = var.instance_type
   key_name               = aws_key_pair.app-key.id
   user_data              = "${base64encode(data.template_file.bootstrap.rendered)}"
   vpc_security_group_ids = [aws_security_group.webappsg.id]

  iam_instance_profile {
        arn = aws_iam_instance_profile.clixx-profile.arn
       }
  # block_device_mappings {
  #   device_name = "/dev/sda1"

  #   ebs {
  #     volume_size = 30
  #   }
  # }
  tag_specifications {
      resource_type = "instance"

      tags = {
        Name          = "APPSV-TP"
        Environment   = var.environment
        System        = "CliXX"
        Owner_Email   = var.owner_email
        Backup        = "Yes"
        Support_Email = var.support
   }
 }
 depends_on = [
    aws_iam_policy.clixx-pol,
    aws_efs_mount_target.clixx-mt1,
    aws_efs_mount_target.clixx-mt2,
    aws_lb.applb,
    aws_db_instance.clixx-db,
    aws_route53_record.clixx,
  ]
}


##### ASG
resource "aws_autoscaling_group" "app-asg" {
  name                        = "APPSV-ASG"
  vpc_zone_identifier         = [aws_subnet.webpriv1.id, aws_subnet.webpriv2.id]
  desired_capacity            = 1
  min_size                    = 1
  max_size                    = 3
  target_group_arns           = [aws_lb_target_group.apptg.arn]
  health_check_grace_period   = 200
  force_delete = true

  launch_template {
    id      = aws_launch_template.apptp.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "APPSV-ASG"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "appasg-pol" {
  name                   = "appasg-pol"
  adjustment_type        = "PercentChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.app-asg.id

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}

