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

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "${var.aws_region}b"
  tags {
    Name = "${var.name} private"
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
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db" {
  name = "${var.name} db"
  description = "${var.name} db security group"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = ["${aws_security_group.web.id}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "default" {
  name = "${var.name}"
  description = "${var.name} db subnets"
  subnet_ids = ["${aws_subnet.public.id}", "${aws_subnet.private.id}"]
}

resource "aws_db_instance" "default" {
  identifier = "${var.name}"
  allocated_storage = 10
  engine = "mysql"
  engine_version = "5.6.23"
  instance_class = "db.t2.micro"
  multi_az = "false"
  name = "wordpress"
  username = "${var.db_username}"
  password = "${var.db_password}"
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  final_snapshot_identifier = "${var.name}-final-snapshot"
  backup_retention_period = 3
}

resource "aws_instance" "web" {
  instance_type = "${var.instance_type}"
  ami = "${var.ami}"
  subnet_id =  "${aws_subnet.public.id}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.web.id}"]

  connection {
    user = "ubuntu"
    key_file = "${var.key_path}"
  }

  tags {
    Name = "${var.name}"
  }
}
