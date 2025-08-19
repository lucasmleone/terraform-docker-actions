variable "aws_region" {
  description = "Región AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefijo para nombres de recursos"
  type        = string
  default     = "lab"
}

variable "vpc_cidr" {
  description = "CIDR principal de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az1" {
  description = "Availability Zone primaria"
  type        = string
  default     = "us-east-1a"
}

variable "az2" {
  description = "Availability Zone secundaria"
  type        = string
  default     = "us-east-1b"
}

variable "public_subnet1_cidr" {
  type        = string
  default     = "10.0.0.0/24"
  description = "CIDR subnet pública 1"
}

variable "private_subnet1_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR subnet privada 1"
}

variable "public_subnet2_cidr" {
  type        = string
  default     = "10.0.2.0/24"
  description = "CIDR subnet pública 2"
}

variable "private_subnet2_cidr" {
  type        = string
  default     = "10.0.3.0/24"
  description = "CIDR subnet privada 2"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nombre del key pair para la instancia"
  type        = string
  default     = "vockey"
}
