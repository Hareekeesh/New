terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "${var.region}"
}
# Create a VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "${var.vpc_cidr_block}"
  
  tags = {
    Name = "${var.vpc_name}"
  }
}
# Create Web Public Subnet
resource "aws_subnet" "web-subnet-1" {
  vpc_id                  = "${aws_vpc.my-vpc.id}"
  cidr_block              = var.CIDR["web1"]
  availability_zone       = "${var.availability_zone_1}"
  map_public_ip_on_launch = true

  tags = {
    Name = "Web-1a"
  }
}

resource "aws_subnet" "web-subnet-2" {
  vpc_id                  = "${aws_vpc.my-vpc.id}"
  cidr_block              = var.CIDR["web2"]
  availability_zone       = "${var.availability_zone_2}"
  map_public_ip_on_launch = true

  tags = {
    Name = "Web-2b"
  }
}

# Create Application Private Subnet
resource "aws_subnet" "application-subnet-1" {
  vpc_id                  = "${aws_vpc.my-vpc.id}"
  cidr_block              = var.CIDR["app1"]
  availability_zone       = "${var.availability_zone_1}"
  map_public_ip_on_launch = false

  tags = {
    Name = "Application-1a"
  }
}

resource "aws_subnet" "application-subnet-2" {
  vpc_id                  = "${aws_vpc.my-vpc.id}"
  cidr_block              = var.CIDR["app2"]
  availability_zone       = "${var.availability_zone_2}"
  map_public_ip_on_launch = false

  tags = {
    Name = "Application-2b"
  }
}
# Create Database Private Subnet
resource "aws_subnet" "database-subnet-1" {
  vpc_id            = "${aws_vpc.my-vpc.id}"
  cidr_block        = var.CIDR["db1"]
  availability_zone = "${var.availability_zone_1}"

  tags = {
    Name = "Database-1a"
  }
}

resource "aws_subnet" "database-subnet-2" {
  vpc_id            = "${aws_vpc.my-vpc.id}"
  cidr_block        = var.CIDR["db2"]
  availability_zone = "${var.availability_zone_2}"

  tags = {
    Name = "Database-2b"
  }
}
# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.my-vpc.id}"

  tags = {
    Name = "Demo IGW"
  }
}
# Create Web layber route table
resource "aws_route_table" "web-rt" {
  vpc_id = "${aws_vpc.my-vpc.id}"


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "WebRT"
  }
}
# Create Web Subnet association with Web route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.web-subnet-1.id
  route_table_id = aws_route_table.web-rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.web-subnet-2.id
  route_table_id = aws_route_table.web-rt.id
}

#Create EC2 Instance
resource "aws_instance" "webserver1" {
  ami                    = "${var.web_ami}"
  instance_type          = "${var.web_instance}"
  availability_zone      = "${var.availability_zone_1}"
  vpc_security_group_ids = [aws_security_group.webserver-sg.id]
  subnet_id              = aws_subnet.web-subnet-1.id
  user_data              = file("install_apache.sh")

  tags = {
    Name = "${var.webserver_name_1}"
  }
}
resource "aws_instance" "webserver2" {
  ami                    = "${var.web_ami}"
  instance_type          = "${var.web_instance}"
  availability_zone      = "${var.availability_zone_2}"
  vpc_security_group_ids = [aws_security_group.webserver-sg.id]
  subnet_id              = aws_subnet.web-subnet-2.id
  user_data              = file("install_apache.sh")

  tags = {
    Name = "${var.webserver_name_2}"
  }
}

# Create Web Security Group
resource "aws_security_group" "web-sg" {
  name        = "${var.Web_SG1_name}"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "${aws_vpc.my-vpc.id}"

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.Web_SG1_name}"
  }
}
# Create Web Server Security Group
resource "aws_security_group" "webserver-sg" {
  name        = "${var.Web_SG2_name}"
  description = "Allow inbound traffic from ALB"
  vpc_id      = "${aws_vpc.my-vpc.id}"

  ingress {
    description     = "Allow traffic from web layer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.Web_SG2_name}"
  }
}
# Create Database Security Group
resource "aws_security_group" "database-sg" {
  name        = "${var.DB_SG_name}"
  description = "Allow inbound traffic from application layer"
  vpc_id      = "${aws_vpc.my-vpc.id}"

  ingress {
    description     = "Allow traffic from application layer"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver-sg.id]
  }

  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.DB_SG_name}"
  }
}
resource "aws_lb" "external-elb" {
  name               = "${var.elb_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-sg.id]
  subnets            = [aws_subnet.web-subnet-1.id, aws_subnet.web-subnet-2.id]
}
resource "aws_lb_target_group" "external-elb" {
  name     = "${var.elb_tg_Name}"
  port     = "${var.tg_port}"
  protocol = "${var.tg_protocol}"
  vpc_id   = "${aws_vpc.my-vpc.id}"
}
resource "aws_lb_target_group_attachment" "external-elb1" {
  target_group_arn = aws_lb_target_group.external-elb.arn
  target_id        = aws_instance.webserver1.id
  port             = 80

  depends_on = [
    aws_instance.webserver1,
  ]
}
resource "aws_lb_target_group_attachment" "external-elb2" {
  target_group_arn = aws_lb_target_group.external-elb.arn
  target_id        = aws_instance.webserver2.id
  port             = 80

  depends_on = [
    aws_instance.webserver2,
  ]
}
resource "aws_lb_listener" "external-elb" {
  load_balancer_arn = aws_lb.external-elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-elb.arn
  }
}
resource "aws_db_instance" "mysql_rds" {
  allocated_storage      = "${var.rds_storage}"
  db_subnet_group_name   = aws_db_subnet_group.default.id
  engine                 = "${var.rds_engine}"
  instance_class         = "${var.rds_instance_class}"
  multi_az               = true
  name                   = "${var.rds_name}"
  username               = "${var.rds_username}"
  password               = "${var.rds_password}"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.database-sg.id]
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.database-subnet-1.id, aws_subnet.database-subnet-2.id]

  tags = {
    Name = "My DB subnet group"
  }
}
output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.external-elb.dns_name
}