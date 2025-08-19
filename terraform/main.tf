# VPC principal: bloque IP y soporte DNS habilitado
resource "aws_vpc" "lab_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Subred pública AZ1: asigna IP pública automáticamente
resource "aws_subnet" "lab_public_subnet1" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.public_subnet1_cidr
  availability_zone       = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-subnet-public1-${var.az1}"
  }
}

# Subred privada AZ1: sin IP pública
resource "aws_subnet" "lab_private_subnet1" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.private_subnet1_cidr
  availability_zone       = var.az1

  tags = {
    Name = "${var.project_name}-subnet-private1-${var.az1}"
  }
}

// Internet Gateway: conecta la VPC a Internet
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "lab-igw"
  }
}

// Elastic IP: dirección estática para NAT Gateway
resource "aws_eip" "lab_nat_eip" {
  domain   = "vpc"

  tags = {
    Name = "lab-nat-eip"
  }
}

// NAT Gateway AZ1: permite que subredes privadas accedan a Internet
resource "aws_nat_gateway" "lab_nat_gw" {
  allocation_id = aws_eip.lab_nat_eip.id
  subnet_id     = aws_subnet.lab_public_subnet1.id

  tags = {
    Name = "${var.project_name}-nat-${var.az1}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.lab_igw]
}

// Tabla de rutas pública: 0.0.0.0/0 -> IGW
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }
  tags = {
    Name = "lab-rtb-public"
  }
}

// Tabla de rutas privada: 0.0.0.0/0 -> NAT Gateway
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.lab_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.lab_nat_gw.id
  }
  tags = {
    Name = "${var.project_name}-rtb-private1-${var.az1}"
  }
}

# Asociación de rutas: enlaza subred privada AZ1 a su tabla
resource "aws_route_table_association" "lab_rt_assoc_private" {
  subnet_id      = aws_subnet.lab_private_subnet1.id
  route_table_id = aws_route_table.private_route_table.id
}

# Asociación de rutas: enlaza subred pública AZ1 a su tabla
resource "aws_route_table_association" "lab_rt_assoc_public" {
  subnet_id      = aws_subnet.lab_public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Subred pública AZ2
resource "aws_subnet" "lab_public_subnet2" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.public_subnet2_cidr
  availability_zone       = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-subnet-public2-${var.az2}"
  }
}

# Subred privada AZ2
resource "aws_subnet" "lab_private_subnet2" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.private_subnet2_cidr
  availability_zone       = var.az2

  tags = {
    Name = "${var.project_name}-subnet-private2-${var.az2}"
  }
}

# Asociación de rutas: enlaza subred privada AZ2
resource "aws_route_table_association" "lab_rt_assoc_private2" {
  subnet_id      = aws_subnet.lab_private_subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Asociación de rutas: enlaza subred pública AZ2
resource "aws_route_table_association" "lab_rt_assoc_public2" {
  subnet_id      = aws_subnet.lab_public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Group HTTP: permite tráfico entrante por puerto 80
resource "aws_security_group" "allow_http" {
  name        = "Web Security Group"
  description = "Enable HTTP access"
  vpc_id      = aws_vpc.lab_vpc.id

  tags = {
    Name = "Web Security Group"
  }
}

# Egress Rule: todo el tráfico de salida está permitido
resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Ingress Rule: HTTP desde cualquier IPv4 (80/tcp)
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# EC2 Instance: servidor web con Apache, PHP y contenido demo
resource "aws_instance" "web_server1" {
  ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id     = aws_subnet.lab_private_subnet1.id
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  associate_public_ip_address = true
  user_data     = <<EOF
#!/bin/bash
# Install Apache Web Server and PHP
dnf install -y httpd wget php mariadb105-server
# Download Lab files
wget https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-100-ACCLFO-2/2-lab2-vpc/s3/lab-app.zip
unzip lab-app.zip -d /var/www/html/
# Turn on web server
chkconfig httpd on
service httpd start
EOF

  tags = {
    Name = "${var.project_name}-web-server1"
  }
}

resource "aws_lb_target_group" "instance_group" {
  name     = "webserver-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = aws_vpc.lab_vpc.id

  health_check {
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200-399"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  deregistration_delay = 10

}

resource "aws_lb_target_group_attachment" "my_target_group_attachment" {
  target_group_arn = aws_lb_target_group.instance_group.arn
  target_id        = aws_instance.web_server1.id
  port             = 80
}

resource "aws_lb" "alb_lab" {
  name               = "lab-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = [aws_subnet.lab_public_subnet1.id , aws_subnet.lab_public_subnet2.id]

  enable_deletion_protection = true

}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb_lab.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance_group.arn
  }
}