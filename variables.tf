variable "name" {
}

variable "key_name" {
}

variable "key_path" {
}

variable "ami" {
}

variable "aws_region" {
    default = "eu-west-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_id" {
  default = "vpc-ffd1459a"
}

variable "route_table_id" {
  default = "rtb-90402cf5"
}

variable "public_subnet_cidr" {
  default = "10.2.0.0/24"
}

variable "private_subnet_cidr" {
  default = "10.2.0.0/24"
}

variable "db_username" {
}

variable "db_password" {
}
