# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# VPC section
# Create a VPC
resource "aws_vpc" "detola_first_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "detola_first_vpc"
  }
}

# Creating Public subnets:
# 1
resource "aws_subnet" "detola_public_subnet1" {
  vpc_id     = aws_vpc.detola_first_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "detola_public_subnet1"
  }
}

# 2
resource "aws_subnet" "detola_public_subnet2" {
  vpc_id     = aws_vpc.detola_first_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = {
    Name = "detola_public_subnet2"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "detola_internet_gateway" {
  vpc_id = aws_vpc.detola_first_vpc.id

  tags = {
    Name = "detola_internet_gateway"
  }
}

# Creating Public Route Table:

resource "aws_route_table" "detola_route_table" {
  vpc_id = aws_vpc.detola_first_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.detola_internet_gateway.id
  }

  tags = {
    Name = "detola_route_table"
  }
}

# Attaching Routing table to Subnets
#attaching route table to subnets created in order to provide access to internet.
# Creating Public Route Table Association:

# 1
resource "aws_route_table_association" "detola_public_subnet1_association" {
  subnet_id      = aws_subnet.detola_public_subnet1.id
  route_table_id = aws_route_table.detola_route_table.id
}

# 2
resource "aws_route_table_association" "detola_public_subnet2_association" {
  subnet_id      = aws_subnet.detola_public_subnet2.id
  route_table_id = aws_route_table.detola_route_table.id
}

# creating a Network ACL
# A network access control list (ACL) allows or denies specific inbound or outbound traffic at the subnet level.

resource "aws_network_acl" "detola_network_acl" {
  vpc_id = aws_vpc.detola_first_vpc.id
  subnet_ids = [aws_subnet.detola_public_subnet1.id, aws_subnet.detola_public_subnet2.id]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "detola_network_acl"
  }
}

#Done with VPC creation
# Creation of Security Group for load balancer

resource "aws_security_group" "detola_lb_sg" {
  name        = "detola_lb_sg"
  description = "security group for load balancer"
  vpc_id      = aws_vpc.detola_first_vpc.id

 # Inbound Rules
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "detola_lb_sg"
  }
}

#create Ec2 instance security group to SSH into the instances
resource "aws_security_group" "detola_sg_rule" {
  name        = "sg_rule_ssh_http_https"
  description = "Allow SSH, HTTP and HTTPS inbound traffic"
  vpc_id      = aws_vpc.detola_first_vpc.id

  # Inbound Rules
  # HTTP access from anywhere
 ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.detola_lb_sg.id]
  }
  # HTTPS access from anywhere
 ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.detola_lb_sg.id]
  }

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }
  # Outbound Rules
  # Internet access to anywhere

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   
  }
  tags = {
    Name = "detola_sg_rule"
  }
}

# create 3 EC2 instances
resource "aws_instance" "server1" {
  ami             = "ami-00874d747dde814fa"
  instance_type   = "t2.micro"
  key_name        = "detolakey_pair"
  security_groups = [aws_security_group.detola_sg_rule.id]
  subnet_id       = aws_subnet.detola_public_subnet1.id
  availability_zone = "us-east-1a"
  tags = {
    Name   = "server1"
    source = "terraform"
  }
}
# creating instance 2
 resource "aws_instance" "server2" {
  ami             = "ami-00874d747dde814fa"
  instance_type   = "t2.micro"
  key_name        = "detolakey_pair"
  security_groups = [aws_security_group.detola_sg_rule.id]
  subnet_id       = aws_subnet.detola_public_subnet1.id
  availability_zone = "us-east-1a"
  tags = {
    Name   = "server2"
    source = "terraform"
  }
}
# creating instance 3
resource "aws_instance" "server3" {
  ami             = "ami-00874d747dde814fa"
  instance_type   = "t2.micro"
  key_name        = "detolakey_pair"
  security_groups = [aws_security_group.detola_sg_rule.id]
  subnet_id       = aws_subnet.detola_public_subnet2.id
  availability_zone = "us-east-1b"
  tags = {
    Name   = "server3"
    source = "terraform"
  }
}
# Creating file to store IP addresses of the 3 instances
resource "local_file" "inventory_IP_address" {
  filename = "/vagrant/terraform/host-inventory"
  content  = <<EOT
${aws_instance.server1.public_ip}
${aws_instance.server2.public_ip}
${aws_instance.server3.public_ip}
  EOT
}

# Create an Application Load Balancer
resource "aws_lb" "detola-lb"{
  name = "detola-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.detola_lb_sg.id]
  subnets            = [aws_subnet.detola_public_subnet1.id, aws_subnet.detola_public_subnet2.id]

  enable_deletion_protection = false
  depends_on = [
    aws_instance.server1, aws_instance.server2, aws_instance.server3
  ]
 
}

#Creating Target Groups
resource "aws_lb_target_group" "detola-target-gp" {
  name        = "detola-target-gp"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.detola_first_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 5
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Listener

resource "aws_lb_listener" "detola_listener" {
  load_balancer_arn = aws_lb.detola-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.detola-target-gp.arn
  }
}
  
# Listener Rule
resource "aws_lb_listener_rule" "detola_listener_rule" {
  listener_arn = aws_lb_listener.detola_listener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.detola-target-gp.arn

  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}
# Attach the target group to the load balancer
resource "aws_lb_target_group_attachment" "tg_attachment1" {
  target_group_arn = aws_lb_target_group.detola-target-gp.arn
  target_id        = aws_instance.server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_attachment2" {
  target_group_arn = aws_lb_target_group.detola-target-gp.arn
  target_id        = aws_instance.server2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_attachment3" {
  target_group_arn = aws_lb_target_group.detola-target-gp.arn
  target_id        = aws_instance.server3.id
  port             = 80
}







