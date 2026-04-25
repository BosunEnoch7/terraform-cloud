#### creating sns topic for all the auto scaling groups
resource "aws_sns_topic" "david_sns" {
  name = "Default_CloudWatch_Alarms_Topic"
}

# creating notification for all the auto scaling groups
resource "aws_autoscaling_notification" "david_notifications" {
  group_names = [
    aws_autoscaling_group.bastion_asg.name,
    aws_autoscaling_group.nginx_asg.name,
    aws_autoscaling_group.wordpress_asg.name,
    aws_autoscaling_group.tooling_asg.name,
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.david_sns.arn
}
# launch template for bastion
resource "random_shuffle" "az_list" {
  input = data.aws_availability_zones.available.names
}


resource "aws_launch_template" "bastion_launch_template" {
  image_id      = lookup(var.images, var.region, "ami-0c02fb55956c7d316")
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.keypair

  iam_instance_profile {
    name = aws_iam_instance_profile.ip.name
  }

  placement {
    availability_zone = random_shuffle.az_list.result[0]
  }

  lifecycle {
    create_before_destroy = true
  }

  user_data = filebase64("${path.module}/bastion.sh")

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "bastion-launch-template"
      },
    )
  }
}


# ---- Autoscaling for bastion  hosts


resource "aws_autoscaling_group" "bastion_asg" {
  name                      = "bastion-asg"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1


  vpc_zone_identifier = [
    aws_subnet.public[0].id,
    aws_subnet.public[1].id
  ]


  launch_template {
    id      = aws_launch_template.bastion_launch_template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "bastion-launch-template"
    propagate_at_launch = true
  }


}


# launch template for nginx


resource "aws_launch_template" "nginx_launch_template" {
  image_id               = lookup(var.images, var.region, "ami-0c02fb55956c7d316")
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]


  iam_instance_profile {
    name = aws_iam_instance_profile.ip.id
  }


  key_name = var.keypair


  placement {
    availability_zone = "random_shuffle.az_list.result"
  }


  lifecycle {
    create_before_destroy = true
  }


  tag_specifications {
    resource_type = "instance"


    tags = merge(
      var.tags,
      {
        Name = "nginx-launch-template"
      },
    )
  }


  user_data = filebase64("${path.module}/nginx.sh")
}


# ------ Autoscslaling group for reverse proxy nginx ---------


resource "aws_autoscaling_group" "nginx_asg" {
  name                      = "nginx-asg"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1


  vpc_zone_identifier = [
    aws_subnet.public[0].id,
    aws_subnet.public[1].id
  ]


  launch_template {
    id      = aws_launch_template.nginx_launch_template.id
    version = "$Latest"
  }


  tag {
    key                 = "Name"
    value               = "nginx-launch-template"
    propagate_at_launch = true
  }


}


# attaching autoscaling group of nginx to external load balancer
resource "aws_autoscaling_attachment" "asg_attachment_nginx" {
  autoscaling_group_name = aws_autoscaling_group.nginx_asg.id
  lb_target_group_arn    = aws_lb_target_group.nginx_tgt.arn
}