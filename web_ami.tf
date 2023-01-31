resource "aws_ami_from_instance" "ami-web" {
  name               = "${var.project_name}-${var.environment}-${var.launch_configuration_pfx}"
  source_instance_id = var.web_instance_id
  #snapshot_without_reboot = true

  lifecycle {
    create_before_destroy = true
  }
}