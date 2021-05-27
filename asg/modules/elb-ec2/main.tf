resource "aws_elb" "this" {
    name            = "${var.app}-lb"
    cross_zone_load_balancing = true
    subnets         = var.subnets
    security_groups = var.security_groups

    listener {
        instance_port     = 80
        instance_protocol = "http"
        lb_port           = 80
        lb_protocol       = "http"
    }
}

# ami : ami-012c7314a6f9b09d6 - nginx certified by bitnami
resource "aws_launch_template" "this" {
  name_prefix   = "${var.app}-lt"
  image_id      = var.web_image_id 
  instance_type = var.web_instance_type
}

resource "aws_autoscaling_group" "this" {
  availability_zones  = null
  vpc_zone_identifier = var.subnets
  desired_capacity   = var.web_desired_capacity
  max_size           = var.web_max_size
  min_size           = var.web_min_size

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  tag {
    key   = "Terraform"
    value = "true"
    propagate_at_launch = true
  }
}

# Create a new load balancer attachment
resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  elb                    = aws_elb.this.id
}