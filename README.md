# tf-asg-module
Terraform aws-asg (Autoscaling).

How to use it:

```
module "asg" {
  source               = "git::https://github.com/open-servus/tf-asg-module.git?ref=main"
  project_name         = "Openservus"
  environment          = "prod"
  launch_configuration_pfx = "web-0.1"
  web_instance_id      = "i-0be49b0e69a32b6bb"
  availability_zones   = ["us-east-1a"]
  aws_instance_type    = "t4g.large"
  aws_security_group   = "sg-07e9055bc23d4d8f8"
  aws_alb_target_group = "arn:aws:elasticloadbalancing:us-east-1:059551436988:targetgroup/test/9d9d625e4cb48a44"
}
```