/* Specify the provider and access details */
provider "aws" {
  region = "${var.aws_region}"
}

/* Security Group for ELB */
resource "aws_security_group" "elb-sg" {
  name = "sg_elb_${var.environment}"
  vpc_id = "${var.vpc_id}"

  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg-elb-${var.environment}"
  }
}

/* ELB for Web/Application Servers */
resource "aws_elb" "web-elb" {
  name = "elb-web-${var.environment}"
  security_groups = ["${aws_security_group.elb-sg.id}"]

  subnets = ["${split(",", var.subnet_ids)}"]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/index.html"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {

