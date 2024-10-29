# EKS Cluster Deployment using Terraform

This repository contains Terraform scripts to automate the provisioning of an Amazon Elastic Kubernetes Service (EKS) cluster on AWS. It includes the setup for a Virtual Private Cloud (VPC), public subnets across multiple availability zones, and the necessary IAM roles, policies, security groups, and networking resources. The configuration is tailored for an autoscaling EKS worker node group using launch templates, allowing for efficient and scalable cluster deployment.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Usage](#usage)
- [Outputs](#outputs)
- [Cleanup](#cleanup)

---

## Overview

This project automates the setup of an EKS cluster using Terraform and AWS resources. Key components include:

- **VPC and Networking**: Custom VPC with public subnets across multiple availability zones.
- **Security Groups**: Firewall rules to control network traffic to and from the cluster.
- **IAM Roles and Policies**: Dedicated roles and policies for EKS and its worker nodes.
- **EKS Cluster and Worker Nodes**: EKS cluster configured with autoscaling worker nodes using launch templates.

## Architecture

The architecture consists of the following resources:

- **VPC** with three public subnets across availability zones `ap-south-1a`, `ap-south-1b`, and `ap-south-1c`.
- **Internet Gateway** and **Route Table** associations to enable internet access for the EKS cluster.
- **Security Group** to manage inbound and outbound traffic for the EKS cluster.
- **IAM Roles** and **Policies** for EKS cluster management and worker nodes.
- **EKS Cluster** with autoscaling worker nodes using EC2 Launch Templates for AMIs and SSH key pairs.

## Prerequisites

- **Terraform** installed (version `1.0+` recommended).
- **AWS CLI** configured with appropriate permissions.
- An **AWS IAM User** with the necessary permissions for EKS and VPC management.
- **AWS Key Pair** for SSH access to the worker nodes.

## Getting Started

1. **Clone the repository**:

```bash
   git clone https://github.com/Vikas-Prince/Terraform-EKS-Cluster.git
   cd Terraform-EKS-Cluster.git/
```

2. **Configure AWS Provider**: Ensure you have the AWS provider defined with the correct region and profile in `provider.tf`.

```bash
   provider "aws" {
     region  = "ap-south-1"
     profile = "default"
   }
```

3. **Edit `terraform.tfvars`**: Customize variables in `terraform.tfvars` to suit your setup (e.g., `vpc_cidr`, `subnet CIDRs`, `instance_type`, `key_name`).

## Configuration

### Variables

The following variables are defined in `variables.tf` and should be customized in `terraform.tfvars`:

| Variable        | Description                             | Example Value     |
| --------------- | --------------------------------------- | ----------------- |
| `vpc_cidr`      | The CIDR block for the VPC              | `"10.0.0.0/16"`   |
| `subnet1_cidr`  | CIDR block for the first public subnet  | `"10.0.1.0/24"`   |
| `subnet2_cidr`  | CIDR block for the second public subnet | `"10.0.2.0/24"`   |
| `subnet3_cidr`  | CIDR block for the third public subnet  | `"10.0.3.0/24"`   |
| `instance_type` | EC2 instance type for worker nodes      | `"t2.medium"`     |
| `key_name`      | Key pair for SSH access to worker nodes | `"your-key-name"` |

### IAM Policies

IAM policies are set up in `datasource.tf`:

- **EKS Cluster Policy** (`AmazonEKSClusterPolicy`)
- **Worker Node Policy** (`AmazonEKSWorkerNodePolicy`)

### Resources

Key resources in `resources.tf` include:

- **VPC, Subnets, and Internet Gateway**: Networking resources for the cluster.
- **Security Group**: Controls network access to the EKS cluster.
- **EKS Cluster**: Primary EKS cluster resource.
- **Node Group**: Autoscaling worker nodes using a launch template.

## Usage

1. **Initialize Terraform**:

```bash
   terraform init
```

2. **Validate Terraform Scripts**

```bash
    terraform validate
```

3. **Plan the Deployment:**

```bash
    terraform plan
```

4. **Apply the Configuration:**

```bash
    terraform apply
```

This step provisions all AWS resources, including VPC, EKS cluster, IAM roles, and worker nodes.

## Outputs

Upon successful creation, the following outputs will be available:

- **EKS Cluster Endpoint** (`cluster_endpoint`): URL to access the EKS cluster API.
- **EKS Cluster Name** (`cluster_name`): Name of the created EKS cluster.

To view outputs, use:

```bash
    terraform output
```

## Cleanup

To remove all created resources and avoid ongoing charges:

```bash
    terraform destroy
```

## Additional Notes

- **Data Sources**: Data sources like `aws_ami` (for the latest AMI) and `aws_key_pair` (for SSH access) are used to ensure resources are up-to-date.
- **Terraform State**: Store your Terraform state file (`terraform.tfstate`) securely, especially if managing resources in production.
- **Auto-scaling**: The worker node group is configured to autoscale, with parameters for desired, minimum, and maximum node counts.

For any further customization, edit the Terraform files as per your requirements.
