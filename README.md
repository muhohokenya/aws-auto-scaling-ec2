# Tech Space AWS Infrastructure

This repository contains Terraform scripts to set up a scalable and secure web infrastructure on AWS.

## Infrastructure Overview

The infrastructure includes the following resources:

- A VPC (`tech_space_vpc`) with CIDR block `10.0.0.0/16`.
- Two public subnets (`public_subnet`, `public_subnet_2`) in different availability zones.
- An internet gateway (`igw`) attached to the VPC.
- A route table (`public_route_table`) associated with the public subnets.
- Two security groups (`allow_ssh`, `security_group_for_ec2`) to allow SSH and HTTP traffic.
- An application load balancer (`tech_space_elb`) associated with the public subnets and a security group.
- A target group (`tech_space_target_group`) associated with the load balancer.
- An auto-scaling group (`tech_space_autoscaling_group`) that uses a launch template (`tech_space_launch_template`).

## Usage

1. Install Terraform.
2. Clone this repository.
3. Run `terraform init` to initialize your Terraform workspace.
4. Run `terraform apply` to create the AWS resources.

Please replace the placeholders in the scripts with your actual AWS resource IDs and other values as needed.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
