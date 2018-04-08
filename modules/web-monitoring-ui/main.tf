/* Security group for the web monitoring ui */
resource "aws_security_group" "webmonitoring_ui_server_sg" {
  name        = "${var.environment}-webmonitoring_ui-server-sg"
  description = "Security group for webmonitoring_ui that allows webmonitoring_ui traffic from internet"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.environment}-webmonitoring_ui-server-sg"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "webmonitoring_ui_inbound_sg" {
  name        = "${var.environment}-webmonitoring_ui-inbound-sg"
  description = "Allow HTTP from Anywhere"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.environment}-webmonitoring_ui-inbound-sg"
  }
}

/* Webmonitoring-ui servers */
resource "aws_instance" "webmonitoring_ui" {
  count             = "${var.webmonitoring_ui_instance_count}"
  ami               = "${lookup(var.amis, var.region)}"
  instance_type     = "${var.instance_type}"
  subnet_id         = "${var.private_subnet_id}"
  vpc_security_group_ids = [
    "${aws_security_group.webmonitoring_ui_server_sg.id}"
  ]
  key_name          = "${var.key_name}"
  user_data         = "${file("${path.module}/files/user_data.sh")}"
  tags = {
    Name        = "${var.environment}-webmonitoring_ui-${count.index+1}"
    Environment = "${var.environment}"
  }
}

/* Load Balancer */
resource "aws_elb" "webmonitoring_ui" {
  name            = "${var.environment}-webmonitoring_ui-lb"
  subnets         = ["${var.public_subnet_id}"]
  security_groups = ["${aws_security_group.webmonitoring_ui_inbound_sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
  healthy_threshold = 2
  unhealthy_threshold = 10
  timeout = 3
  target = "HTTP:80/"
  interval = 180
  }

  instances = ["${aws_instance.webmonitoring_ui.*.id}"]
  connection_draining = true
  idle_timeout = 400
  connection_draining_timeout = 400

  tags {
    Environment = "${var.environment}"
  }
}
