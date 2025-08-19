# AWS Web Server with Terraform

## Overview
This project provisions a complete AWS web server environment using Terraform. It automates the setup of a secure, highly available, and scalable infrastructure, including networking components, security groups, and an EC2 instance running a sample web application.

## Problem Statement
Provision an AWS environment that includes a VPC with both public and private subnets, internet and NAT gateways, appropriate routing, and a web server accessible via HTTP. The infrastructure should follow best practices for security and availability, and be fully reproducible using Infrastructure as Code.

## Architecture
```text
         Internet
            |
           IGW
            |
       ┌────────────┐
       │ Public RT  │
       └────────────┘
         /        \
Pub Subnet1      Pub Subnet2 ─── EC2 Web (HTTP)
 (AZ1)              (AZ2)
    |                 |
    |                 +---- user_data → Apache+PHP
    |
   NAT GW
    |
┌────────────┐
│ Private RT │
└────────────┘
   /      \
Priv1     Priv2
(AZ1)     (AZ2)
```

## Key Features
- Automated provisioning of a custom VPC with public and private subnets across multiple availability zones.
- Internet Gateway and NAT Gateway setup for controlled internet access.
- Custom route tables for public and private networking.
- Security Group allowing HTTP (port 80) traffic to the web server.
- EC2 instance (Amazon Linux 2023, t2.micro) deployed in a public subnet with user data to install Apache, PHP, and a demo web application.
- Infrastructure as Code managed with Terraform for repeatability and version control.

## Requirements
- Terraform installed.
- AWS credentials configured (via `~/.aws/credentials` or environment variables `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`).
- EC2 key pair named **vockey** in the us-east-1 region (referenced in `main.tf`).

## Deployment
Initialize Terraform and deploy the infrastructure:
```bash
terraform init
terraform plan       # Review the execution plan and resource names
terraform apply      # Provision all resources as defined in main.tf
```

## Teardown
To destroy all provisioned resources:
```bash
terraform destroy
```

## Project Structure
- `main.tf`: Main Terraform configuration file defining all AWS resources.
- `variables.tf`: Input variables for parameterizing the deployment.
- `outputs.tf`: Output values such as public IPs and URLs.
- `img/`: Directory containing deployment evidence and screenshots.

## Evidence
The following images demonstrate the deployed resources and web server verification:

**Terraform Apply Output**
![](./img/terraform-apply.png)

**Deployed AWS Resources**
![](./img/resultado-lab.png)

**Web Server Running**
![](./img/web-working.png)

## Skills & Technologies Used
- AWS VPC, Subnets, Route Tables, Internet Gateway, NAT Gateway, Elastic IP
- EC2 Instances, Security Groups, Key Pairs
- Terraform (Infrastructure as Code)
- Amazon Linux, Apache, PHP
- Linux shell scripting (user data)