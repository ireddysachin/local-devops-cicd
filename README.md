# **LOCAL DEVOPS CI/CD PLATFORM WITH FLOCI**

## **PROJECT OVERVIEW**

This project demonstrates a complete local DevOps CI/CD workflow using GitHub Actions, Docker, Terraform, and Floci.

The goal of this project is to simulate an AWS-style DevOps environment locally without using real AWS cloud resources.

The pipeline automatically validates the application, builds a Docker image, pushes the image to the local Floci container registry, and deploys the application to ECS simulated by Floci.

---

## **PROJECT ARCHITECTURE**

```text
Developer
    |
    | git push
    v
GitHub Repository
    |
    v
GitHub Actions
    |
    v
Self-Hosted GitHub Runner
    |
    +----------------------+
    |                      |
    v                      v
Python Validation     Terraform Validation
    |
    v
Docker Build
    |
    v
Docker Image
    |
    v
Floci ECR / Local Registry
    |
    v
Terraform Deploy
    |
    v
Floci ECS Cluster
    |
    v
ECS Service
    |
    v
Flask Application
    |
    v
http://localhost:5001


TECHNOLOGIES USED

- Python
- Flask
- Docker
- Terraform
- Git
- GitHub
- GitHub Actions
- Self-Hosted GitHub Actions Runner
- Floci
- AWS CLI
- Amazon S3 Simulation
- Amazon ECR Simulation
- Amazon ECS Simulation

PROJECT STRUCTURE

local-devops-cicd/
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── app/
│   ├── app.py
│   └── requirements.txt
│
├── docker/
│   └── Dockerfile
│
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── s3.tf
│   ├── ecs.tf
│   ├── ecs-task.tf
│   ├── ecs-service.tf
│   └── outputs.tf
│
├── .gitignore
├── artifact.txt
└── README.md


APPLICATION

The application is a simple Python Flask web application.
The application provides a main endpoint and a health-check endpoint.

MAIN ENDPOINT
http://localhost:5001/

HEALTH CHECK ENDPOINT
http://localhost:5001/health

Example health-check response:
{
  "application": "local-devops-cicd",
  "status": "healthy",
  "version": "2.0"
}

DOCKER
Docker is used to package the Flask application and its dependencies into a container image.
The Dockerfile performs the following operations:
1. Uses a Python base image.
2. Creates the application working directory.
3. Copies the Python requirements file.
4. Installs application dependencies.
5. Copies the Flask application.
6. Exposes port 5000.
7. Starts the Flask application.
Example Docker build command:
docker build -f docker/Dockerfile -t local-devops-cicd:1.0 .

FLOCI
Floci is used to simulate AWS services locally.
This allows the project to practice AWS-style DevOps workflows without deploying infrastructure to a real AWS account.
The project uses Floci to simulate services including:
- S3
- ECR
- ECS
Floci runs locally using Docker.
The AWS-compatible endpoint used by the project is:
http://localhost:4566

TERRAFORM
Terraform is used to define and manage the infrastructure required by the application.
The Terraform configuration includes:
- AWS provider configuration
- Floci service endpoints
- S3 bucket
- ECS cluster
- ECS task definition
- ECS service
- Docker image configuration
Terraform configuration can be validated using:
cd terraform
terraform init
terraform validate

Infrastructure can be deployed using:
terraform apply

S3
An S3 bucket is created using Terraform inside the local Floci environment.
The bucket is used to demonstrate Infrastructure as Code and AWS-compatible resource creation.
Example bucket name:
local-devops-terraform-artifacts

ECR / LOCAL CONTAINER REGISTRY
The Docker image is stored in the local container registry provided by the Floci environment.
The local registry is available through:
localhost:5100

The Docker image is tagged using a registry path similar to:
localhost:5100/000000000000/us-east-1/local-devops-app:<IMAGE_TAG>

The image is pushed using:
docker push localhost:5100/000000000000/us-east-1/local-devops-app:<IMAGE_TAG>

ECS
Floci ECS is used to simulate container deployment.
The Terraform configuration creates:
- ECS Cluster
- ECS Task Definition
- ECS Service
The ECS cluster is:
local-devops-cluster

The ECS service is:
local-devops-service

The service maintains the required number of running application tasks.
GITHUB ACTIONS CI/CD PIPELINE
GitHub Actions is used to automate the CI/CD process.
The workflow is stored in:
.github/workflows/ci.yml

The pipeline runs automatically when code is pushed to the main branch.
The pipeline performs the following flow:
Checkout Code
      |
      v
Install Python Dependencies
      |
      v
Terraform Init
      |
      v
Terraform Validate
      |
      v
Python Syntax Check
      |
      v
Build Docker Image
      |
      v
Tag Docker Image
      |
      v
Push Docker Image
      |
      v
Terraform Deploy
      |
      v
ECS Application Deployment

SELF-HOSTED GITHUB ACTIONS RUNNER
A self-hosted GitHub Actions runner is configured on the local Mac.
The runner allows GitHub Actions to execute commands directly inside the local development environment.
This is important because Floci, Docker, Terraform, and the local container registry are running on the local machine.
The pipeline therefore connects:
GitHub
   |
   v
GitHub Actions
   |
   v
Self-Hosted Runner
   |
   v
Local Docker + Terraform + Floci

CI/CD WORKFLOW
When a developer pushes code to GitHub:
git add .
git commit -m "Update application"
git push origin main

GitHub Actions automatically starts the pipeline.
The pipeline then:
1. Checks out the source code.
2. Installs Python dependencies.
3. Initializes Terraform.
4. Validates Terraform configuration.
5. Checks Python syntax.
6. Builds a Docker image.
7. Tags the Docker image using the Git commit SHA.
8. Pushes the image to the local Floci registry.
9. Runs Terraform deployment.
10. Updates the ECS application.
DOCKER IMAGE VERSIONING
The GitHub commit SHA is used as the Docker image tag.
Example:
local-devops-cicd:<GITHUB_SHA>

This provides a unique Docker image for each code change.
This makes application versions traceable from:
Git Commit
     |
     v
Docker Image
     |
     v
ECS Deployment

APPLICATION HEALTH CHECK
After deployment, the application can be tested using:
curl http://localhost:5001/health

Expected response:
{
  "application": "local-devops-cicd",
  "status": "healthy",
  "version": "2.0"
}

VERIFY ECS SERVICE
The ECS service can be checked using:
aws --endpoint-url http://localhost:4566 ecs describe-services \
  --cluster local-devops-cluster \
  --services local-devops-service \
  --query "services[0].{Desired:desiredCount,Running:runningCount,Pending:pendingCount}"

Expected healthy state:
{
  "Desired": 1,
  "Running": 1,
  "Pending": 0
}

This means the ECS service successfully has one application task running.
GIT WORKFLOW
The project uses Git for source-code version control.
Useful commands include:
git status
git add .
git commit -m "Update project"
git push origin main

GitHub stores the project source code and automatically triggers the GitHub Actions pipeline when changes are pushed.
WHAT I LEARNED FROM THIS PROJECT
Through this project, I practiced:
- Creating a Python Flask application
- Containerizing an application using Docker
- Building Docker images
- Tagging Docker images
- Working with a local container registry
- Using Terraform for Infrastructure as Code
- Creating AWS-style infrastructure locally
- Working with S3
- Working with ECR concepts
- Working with ECS clusters
- Creating ECS task definitions
- Creating ECS services
- Using Git and GitHub
- Creating GitHub Actions workflows
- Configuring a self-hosted GitHub Actions runner
- Automating Docker builds
- Automating Docker image pushes
- Automating infrastructure deployment
- Troubleshooting Docker port conflicts
- Testing application health endpoints
- Verifying ECS service health
- Building an end-to-end CI/CD workflow
PROJECT ACHIEVEMENT
This project implements an end-to-end local DevOps CI/CD platform.
The completed workflow is:
Code Change
    |
    v
Git Push
    |
    v
GitHub
    |
    v
GitHub Actions
    |
    v
Self-Hosted Runner
    |
    v
Terraform Validation
    |
    v
Docker Build
    |
    v
Docker Image Tagging
    |
    v
Local Floci Registry
    |
    v
Terraform Deployment
    |
    v
Floci ECS
    |
    v
Running Flask Application
    |
    v
Health Check

The project demonstrates practical experience with CI/CD, containers, Infrastructure as Code, local cloud simulation, and automated application deployment.
AUTHOR
SACHIN S IREDDY
DevOps / Cloud Engineering Project
GitHub: ireddysachin

After pasting it, press **`Command + S`** to save. Then stop there and send me a screenshot. We will do the