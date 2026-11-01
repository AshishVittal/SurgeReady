# SurgeReady

**An AWS-based cloud reliability and deployment project built with Terraform, Docker, and Amazon ECS Fargate.**

## Project Overview

SurgeReady is a cloud engineering project that demonstrates how to deploy and monitor a containerized web application on AWS using Infrastructure as Code.

The project focuses on application deployment, infrastructure automation, monitoring, alerting, scalability, and reliability engineering.

## Architecture

The current infrastructure includes:

- Amazon VPC with public and private subnets across two Availability Zones
- Internet Gateway and public routing
- Application Load Balancer (ALB)
- Amazon ECS with AWS Fargate
- Amazon ECR for Docker image storage
- AWS IAM execution role
- Amazon CloudWatch for monitoring and logging
- Amazon SNS for email notifications
- Terraform for infrastructure provisioning

## Technology Stack

| Technology | Purpose |
|---|---|
| AWS | Cloud infrastructure |
| Terraform | Infrastructure as Code |
| Docker | Application containerization |
| Amazon ECS Fargate | Container deployment |
| Amazon ECR | Container image registry |
| Application Load Balancer | Traffic distribution |
| CloudWatch | Monitoring and logging |
| Amazon SNS | Email notifications |
| Python and Flask | Web application |
| Git and GitHub | Version control |

## Application Endpoints

- `/` - Application homepage
- `/health` - Application health-check endpoint

## Monitoring and Alerting

CloudWatch alarms are configured to monitor:

- ECS CPU utilization above 70%
- ECS memory utilization above 70%

Amazon SNS is configured to deliver email notifications when an alarm enters its alarm state.

Direct SNS email delivery has been successfully tested.

## Completed Features

- [x] VPC and subnet infrastructure
- [x] Internet Gateway and routing
- [x] Application and ALB security groups
- [x] ECR repository
- [x] Docker image build and push
- [x] ECS Fargate cluster and service
- [x] Application Load Balancer
- [x] Application health-check endpoint
- [x] CloudWatch logs and alarms
- [x] SNS email notification setup
- [x] Terraform infrastructure configuration
- [x] GitHub repository publication

## Planned Improvements

- [ ] ECS service auto scaling
- [ ] Multi-task deployment and resilience testing
- [ ] GitHub Actions CI/CD using OIDC
- [ ] k6 load testing
- [ ] Controlled failure and recovery testing
- [ ] Architecture diagram and test evidence

## Project Goal

The goal of SurgeReady is to demonstrate practical Cloud Engineering and Site Reliability Engineering concepts through a hands-on AWS deployment.

The project explores infrastructure automation, container deployment, observability, alerting, scalability, and reliability testing.

**Note:** Auto scaling and the planned resilience tests are still under development.

## Author

Ashish Vittal

GitHub: [AshishVittal](https://github.com/AshishVittal)
