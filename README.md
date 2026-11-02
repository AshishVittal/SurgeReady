# SurgeReady

**An AWS-based cloud reliability and auto-scaling project built with Terraform, Docker, and Amazon ECS Fargate.**

## Project Overview

SurgeReady is a cloud engineering project demonstrating how to deploy, monitor, and automatically scale a containerized web application on AWS.

The project focuses on Infrastructure as Code, container deployment, load balancing, observability, automated scaling, performance testing, and reliability engineering.

## Architecture

The infrastructure includes:

- Amazon VPC with public and private subnets across two Availability Zones
- Internet Gateway and public routing
- Application Load Balancer (ALB)
- Amazon ECS with AWS Fargate
- Amazon ECR for Docker image storage
- AWS IAM execution role
- Amazon CloudWatch for monitoring, logging, and alarms
- Amazon SNS for email notifications
- Terraform for infrastructure provisioning

## Technology Stack

| Technology | Purpose |
|---|---|
| AWS | Cloud infrastructure |
| Terraform | Infrastructure as Code |
| Docker | Application containerization |
| Amazon ECS Fargate | Container deployment and scaling |
| Amazon ECR | Container image registry |
| Application Load Balancer | Traffic distribution |
| CloudWatch | Monitoring, logs and alarms |
| Amazon SNS | Email notifications |
| k6 | Load and performance testing |
| Python and Flask | Web application |
| Git and GitHub | Version control |

## Application Endpoints

- `/` - Application homepage
- `/health` - Application health-check endpoint
- `/work` - CPU-intensive endpoint for load testing

## Auto Scaling and Load Testing

ECS Service Auto Scaling is configured using CPU-based target tracking.

- Minimum tasks: 2
- Maximum tasks: 4
- Target CPU utilization: 60%
- Scaling metric: ECSServiceAverageCPUUtilization

### Load Test Results

A five-minute k6 load test was conducted using 25 virtual users.

| Metric | Result |
|---|---:|
| Test duration | 5 minutes |
| Virtual users | 25 |
| Total requests | 1,217 |
| Failed HTTP requests | 0% |
| Average response time | 5.26 seconds |
| 95th percentile response time | 10.43 seconds |

### Autoscaling Validation

The test demonstrated the following behaviour:

1. ECS initially operated with 2 running tasks.
2. k6 generated simulated application traffic.
3. CloudWatch CPU alarm entered ALARM state.
4. ECS Auto Scaling increased the desired task count to 4.
5. All 4 tasks reached RUNNING state.
6. After traffic subsided, the service scaled back to 2 running tasks.

Both scale-out and scale-in were successfully validated.

## Monitoring and Alerting

CloudWatch alarms monitor:

- ECS CPU utilization above 70%
- ECS memory utilization above 70%

Amazon SNS delivers email notifications when an alarm enters its alarm state.

Direct SNS email delivery was successfully tested.

## Completed Features

- [x] VPC and multi-AZ subnet infrastructure
- [x] Internet Gateway and routing
- [x] ALB and application security groups
- [x] ECR repository
- [x] Docker image build and push
- [x] ECS Fargate cluster and service
- [x] Application Load Balancer
- [x] Application health-check endpoint
- [x] CloudWatch logs and alarms
- [x] SNS email notification setup
- [x] Terraform infrastructure configuration
- [x] ECS target-tracking auto scaling
- [x] k6 load testing
- [x] Autoscaling scale-out and scale-in validation
- [x] GitHub repository publication

## Planned Improvements

- [ ] Grafana dashboards for application and infrastructure observability
- [ ] GitHub Actions CI/CD using OIDC
- [ ] Controlled failure and recovery testing
- [ ] Architecture diagram and test evidence

## Project Goal

The goal of SurgeReady is to demonstrate practical Cloud Engineering and Site Reliability Engineering concepts through a hands-on AWS deployment.

The project explores infrastructure automation, container deployment, observability, performance testing, automated scaling, and reliability validation.

## Author

Ashish Vittal

GitHub: [AshishVittal](https://github.com/AshishVittal)
