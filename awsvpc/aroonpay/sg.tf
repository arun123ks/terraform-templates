resource "aws_security_group" "publicsg" {
  name        = "SG-NV-AROON-PROD-CSE-PUBLIC"
  description = "Allow HTTPS inbound outbound traffic from anywhere"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "privatesg" {
  name        = "SG-NV-AROON-PROD-CSE-PRIVATE"
  description = "Allow HTTPS inbound outbound traffic from ALB"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = ["${aws_security_group.publicsg.id}"]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


