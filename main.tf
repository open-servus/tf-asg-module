#===========================================================================================

#Autoscaling

resource "aws_launch_configuration" "as_conf" {
  name = "${var.project_name}-${var.environment}-${var.launch_configuration_pfx}"

  image_id = aws_ami_from_instance.ami-web.id
  security_groups = [
    var.aws_security_group,
  ]
  instance_type = var.aws_instance_type

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "as_group" {
  availability_zones        = var.availability_zones
  name                      = "${var.project_name}-${var.environment}-asg"
  launch_configuration      = aws_launch_configuration.as_conf.name
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 660
  health_check_type         = "ELB"

  # vpc_zone_identifier = [
  #   aws_subnet.private[0].id,
  #   aws_subnet.private[1].id,
  #   aws_subnet.private[2].id,
  # ]

  target_group_arns = [
    var.aws_alb_target_group,
  ]

  termination_policies = ["OldestInstance"]

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-web"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "webscaledown" {
  name                   = "WebScaleDown"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 360
  autoscaling_group_name = aws_autoscaling_group.as_group.name
}

resource "aws_autoscaling_policy" "webscaleup" {
  name                   = "WebScaleUp"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = 3
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 360
  autoscaling_group_name = aws_autoscaling_group.as_group.name
}

resource "aws_cloudwatch_metric_alarm" "webscaleup_policy" {
  alarm_name          = "webscaleup_policy"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "55"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.as_group.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.webscaleup.arn]
}

resource "aws_cloudwatch_metric_alarm" "webscaledown_policy" {
  alarm_name          = "webscaledown_policy"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "960"
  statistic           = "Average"
  threshold           = "25"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.as_group.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.webscaledown.arn]
}