provider "aws" {
    region = "${var.aws_region}"
}

resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.name}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true
  depends_on = ["aws_internet_gateway.default"]
  tags {
    Name = "${var.name} public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_security_group" "web" {
  name = "${var.name} web"
  description = "Security group for web that allows web traffic from internet"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  instance_type = "${var.instance_type}"
  ami = "${var.ami}"
  subnet_id =  "${aws_subnet.public.id}"
  key_name = "${var.name}"
  security_groups = ["${aws_security_group.web.id}"]

  connection {
    user = "ubuntu"
    key_file = "${var.key_path}"
  }

  tags {
    Name = "${var.name}"
  }
}
