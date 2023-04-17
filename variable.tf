variable "region" {
  description = "AWS region to create VPC"
  default     = "us-east-1"
}
variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}
variable "vpc_name" {
  description = "Name of the VPC"
  default     = "Demo VPC"
}
variable "availability_zone_1" {
  description = "AZ for Web1"
  default = "us-east-1a"
}
variable "availability_zone_2" {
  description = "AZ for Web2"
  default = "us-east-1b"
}
variable "CIDR" {
  type = map
    default = {
      "web1" = "10.0.5.0/24"
      "web2" = "10.0.7.0/24"
      "app1" = "10.0.11.0/24"
      "app2" = "10.0.12.0/24"
      "db1" = "10.0.21.0/24"
      "db2" = "10.0.22.0/24"
    }
  
}
variable "web_ami" {
  description = "AMI of webservers"
  default     = "ami-0d5eff06f840b45e9"
}

variable "web_instance" {
  description = "Instance type of webservers"
  default     = "t2.micro"
}

variable "webserver_name_1" {
  description = "Name of web server1"
  default     = "web1"
}
variable "webserver_name_2" {
  description = "Name of web server2"
  default     = "web2"
}
variable "Web_SG1_name" {
  description = "Name of the Web SG1"
  default     = "Web SG1"
}
variable "Web_SG2_name" {
  description = "Name of the Web SG2"
  default     = "Web SG2"
}
variable "DB_SG_name" {
  description = "Name of the Database SG"
  default     = "Database SG"
}
variable "elb_name" {
  description = "Name of the ELB"
  default     = "External-LB"
}
variable "elb_tg_Name" {
  description = "Name of the ELB TG"
  default     = "ALB-TG"
}
variable "tg_port" {
  description = "Enter the port for the application load balancer target group"
  default     = "80"
}

variable "tg_protocol" {
  description = "Enter the protocol for the application load balancer target group"
  default     = "HTTP"
}

variable "rds_subnet_name" {
  description = "Name of the RDS subnet group"
  default     = "rds_group"
}

variable "rds_storage" {
  description = "RDS storage space"
  default     = "10"
}

variable "rds_engine" {
  description = "RDS engine type"
  default     = "mysql"
}
variable "rds_instance_class" {
  description = "RDS instance class"
  default     = "db.t2.micro"
}

variable "rds_name" {
  description = "Name of the RDS"
  default     = "mysql_rds"
}

variable "rds_username" {
  description = "Username of the RDS"
  default     = "mysql_terraform"
}

variable "rds_password" {
  description = "Password of the RDS"
  default     = "terraformrds"
}
