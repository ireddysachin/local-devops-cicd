# 🚀 Local DevOps CI/CD Platform with Floci

A complete local DevOps CI/CD project demonstrating GitHub Actions, Docker, Terraform, ECS, ECR, S3 remote state, automated testing, and a self-hosted GitHub Actions runner using Floci as a local AWS-compatible environment.

---

## 📌 Project Overview

The goal of this project was to build an end-to-end DevOps CI/CD pipeline without depending on paid AWS infrastructure.

A code push to GitHub triggers GitHub Actions on a self-hosted Mac runner.

The pipeline performs:

1. Checkout source code
2. Install Python dependencies
3. Terraform initialization
4. Terraform validation
5. Python syntax validation
6. Automated testing using Pytest
7. Docker image build
8. Docker image tagging
9. Push image to Floci ECR/local registry
10. Terraform ECS deployment
11. Application health verification

---

# 🏗️ Project Architecture

```text
                    ┌───────────────────┐
                    │      GitHub       │
                    │   Source Code     │
                    └─────────┬─────────┘
                              │
                           git push
                              │
                              ▼
                    ┌───────────────────┐
                    │  GitHub Actions   │
                    │      CI/CD        │
                    └─────────┬─────────┘
                              │
                              ▼
                 ┌─────────────────────────┐
                 │ Self-hosted Mac Runner  │
                 │  local-devops-runner    │
                 └────────────┬────────────┘
                              │
             ┌────────────────┼────────────────┐
             │                │                │
             ▼                ▼                ▼
        Python Tests     Terraform         Docker
          / Pytest        Validate          Build
             │                │                │
             │                │                ▼
             │                │         ┌──────────────┐
             │                │         │   Floci ECR  │
             │                │         │ Docker Image │
             │                │         └──────┬───────┘
             │                │                │
             │                ▼                │
             │         ┌──────────────┐        │
             │         │   Floci S3   │        │
             │         │ Remote State │        │
             │         └──────────────┘        │
             │                                │
             │                                ▼
             │                       ┌────────────────┐
             │                       │    Floci ECS   │
             │                       │   ECS Service  │
             │                       └───────┬────────┘
             │                               │
             │                               ▼
             │                       ┌────────────────┐
             │                       │ Flask Container│
             │                       │ Container:5000 │
             │                       │ Host:5001      │
             │                       └───────┬────────┘
             │                               │
             └───────────────────────────────┤
                                             ▼
                                http://localhost:5001
                                             │
                                             ▼
                                          /health


🛠️ Technologies Used
Technology	Purpose
Python	Application development
Flask	Web application/API
Pytest	Automated testing
Docker	Containerization
Floci	Local AWS-compatible environment
ECR	Docker image registry
ECS	Container deployment
S3	Terraform remote state
Terraform	Infrastructure as Code
GitHub	Source code management
GitHub Actions	CI/CD automation
Self-hosted Runner	Local CI/CD execution


📁 Project Structure
local-devops-cicd/
│
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── test_app.py
│
├── docker/
│   └── Dockerfile
│
├── terraform/
│   ├── backend.tf
│   ├── provider.tf
│   ├── s3.tf
│   ├── ecs.tf
│   ├── ecs-task.tf
│   ├── ecs-service.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── .terraform.lock.hcl
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── .gitignore
├── artifact.txt
└── README.md

Terraform state files are not stored in Git. Terraform state is maintained in the Floci S3 remote backend.

1️⃣ Flask Application
The project uses a simple Flask application.
Endpoints
GET /
GET /health

Health Response
{
  "application": "local-devops-cicd",
  "status": "healthy",
  "version": "2.0"
}

The /health endpoint is used to verify that the application is running successfully after deployment.
2️⃣ Automated Testing
Pytest was added to automatically test the Flask application.
Tests verify:
- / returns HTTP 200
- /health returns HTTP 200
- Health response contains the expected status
Run tests
pytest app/test_app.py

Final result:
2 passed

3️⃣ Docker
The Flask application is packaged into a Docker image.
Dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

EXPOSE 5000

CMD ["python", "app.py"]

Build Docker image
docker build -f docker/Dockerfile -t local-devops-cicd:1.0 .

Run locally
docker run -d \
  --name local-devops-app \
  -p 5000:5000 \
  local-devops-cicd:1.0

4️⃣ Floci
Floci was used as a local AWS-compatible environment.
Main endpoint:
http://localhost:4566

Services used:
- S3
- ECR
- ECS
This allowed the project to practice AWS and DevOps concepts locally without deploying the infrastructure to real AWS.
5️⃣ ECR / Docker Registry
Docker images were pushed to the Floci-backed local registry.
Registry:
localhost:5100

Image format:
localhost:5100/000000000000/us-east-1/local-devops-app:<TAG>

The CI pipeline uses the GitHub commit SHA as the Docker image tag:
${{ github.sha }}

This provides a unique image version for every commit.
6️⃣ Terraform Infrastructure
Terraform was used to manage infrastructure as Code.
Resources managed
aws_s3_bucket.artifacts

aws_ecs_cluster.app_cluster

aws_ecs_task_definition.app_task

aws_ecs_service.app_service

Terraform commands
Initialize:
terraform init

Validate:
terraform validate

Plan:
terraform plan -var="image_tag=test"

Apply:
terraform apply -auto-approve -var="image_tag=test"

Check state:
terraform state list

7️⃣ ECS Deployment
The Flask application runs inside an ECS container.
The application listens on:
Container Port: 5000

The host exposes:
Host Port: 5001

Therefore:
localhost:5001
       ↓
Container:5000
       ↓
Flask Application

Final ECS verification:
Desired: 1
Running: 1
Pending: 0

8️⃣ Terraform Remote State
The Problem
Initially, Terraform state was stored locally on the Mac.
When the Terraform state file was removed from Git, GitHub Actions did not have the same state.
Therefore Terraform attempted to create resources that already existed.
This produced errors such as:
BucketAlreadyExists

and:
Creation of service was not idempotent

The Solution
Terraform state was migrated to an S3-compatible backend provided by Floci.
Bucket
local-devops-terraform-artifacts

State file
terraform-state.tfstate

Backend
terraform {
  backend "s3" {
    bucket = "local-devops-terraform-artifacts"
    key    = "terraform-state.tfstate"
    region = "us-east-1"

    access_key = "test"
    secret_key = "test"

    endpoints = {
      s3 = "http://localhost:4566"
    }

    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true

    use_path_style = true
  }
}

State migration
terraform init -migrate-state

The remote state was verified inside the Floci S3 bucket.
Why remote state is important
Before:
Local Mac
   ↓
terraform.tfstate

GitHub Actions
   ↓
No matching state

After:
              Floci S3
                  │
       terraform-state.tfstate
             ▲          ▲
             │          │
          Local      GitHub
        Terraform    Actions

Both environments can now use the same Terraform state.
9️⃣ GitHub Actions CI/CD Pipeline
The CI/CD pipeline runs on the self-hosted Mac runner.
Pipeline Flow
Checkout Code
      ↓
Install Dependencies
      ↓
Terraform Init
      ↓
Terraform Validate
      ↓
Python Syntax Check
      ↓
Pytest
      ↓
Docker Build
      ↓
Docker Tag
      ↓
Push Docker Image
      ↓
Terraform Deploy
      ↓
Application Running

Runner
runs-on: [self-hosted, macOS, x64]

Docker Image Tag
${{ github.sha }}

Using the commit SHA gives every Docker image a unique version.
🔟 Self-Hosted GitHub Runner
Runner name:
local-devops-runner

Labels:
self-hosted
macOS
x64

The self-hosted runner was used because the CI/CD pipeline needs access to local services:
localhost:4566
localhost:5100

The runner executes Docker, Terraform and Floci-related commands directly on the Mac.
🐛 Troubleshooting
Issue 1 — ECS Port Conflict
Error
Bind for 0.0.0.0:5000 failed:
port is already allocated

Cause
A standalone Docker container was already using host port 5000.
Solution
Changed the ECS host port:
Container: 5000
Host:      5001

Issue 2 — Floci ECR Push 503
Problem
The initial ECR push through the Floci control-plane endpoint returned:
503 Service Unavailable

Solution
Used the Floci backing registry:
localhost:5100

The Docker image was successfully pushed through this registry.
Issue 3 — Terraform State Problem
Problem
GitHub Actions did not have the same Terraform state as the local Mac.
Symptoms
BucketAlreadyExists

and ECS service creation/idempotency errors.
Solution
Migrated Terraform state to:
Floci S3
     ↓
terraform-state.tfstate

Issue 4 — backend.tf Location
The backend configuration was initially found inside Terraform's internal .terraform directory.
It was corrected so that:
terraform/
└── backend.tf

contains the actual backend configuration.
✅ Final Verification
The final GitHub Actions pipeline successfully passed:
✅ Checkout
✅ Install dependencies
✅ Terraform Init
✅ Terraform Validate
✅ Python syntax
✅ Pytest
✅ Docker Build
✅ Docker Tag
✅ Docker Push
✅ Terraform Deploy
✅ Complete Job

ECS:
Desired: 1
Running: 1
Pending: 0

🏥 Application Health Check
Command:
curl http://localhost:5001/health

Response:
{
  "application": "local-devops-cicd",
  "status": "healthy",
  "version": "2.0"
}

This confirms that the application was successfully deployed and is running.
🔧 Useful Commands
Testing
pytest app/test_app.py

Docker
docker build -f docker/Dockerfile -t local-devops-cicd:1.0 .

Terraform
terraform init

terraform validate

terraform plan -var="image_tag=test"

terraform apply -auto-approve -var="image_tag=test"

terraform state list

Remote State
terraform init -migrate-state

aws --endpoint-url http://localhost:4566 \
s3api list-objects-v2 \
--bucket local-devops-terraform-artifacts

ECS
aws --endpoint-url http://localhost:4566 \
ecs describe-services \
--cluster local-devops-cluster \
--services local-devops-service

Application Health
curl http://localhost:5001/health

Git
git status

git add .

git commit -m "Update project documentation"

git push origin main

🎯 Interview Explanation
60-Second Project Explanation
I built a local end-to-end DevOps CI/CD platform using Floci as an AWS-compatible environment. The application is a Flask service packaged with Docker. I created ECS, ECR and S3 infrastructure using Terraform. GitHub Actions runs on a self-hosted macOS runner and performs dependency installation, Terraform validation, Python syntax checks, automated tests, Docker build and image push, followed by Terraform-based ECS deployment.
During the project, I faced a Terraform state problem because CI did not have the same local state, which caused duplicate-resource errors. I solved this by migrating the Terraform state to an S3-compatible remote backend in Floci. Finally, I verified the deployed application using the /health endpoint.

💼 Interview Questions to Prepare
Terraform
1. What is Terraform state?
2. Why should terraform.tfstate not be committed to Git?
3. What is a remote backend?
4. Why did you use S3 for Terraform state?
5. What happens when Terraform does not have the correct state?
6. What is the difference between terraform plan and terraform apply?
7. What is Infrastructure as Code?
Docker
1. What is the difference between a Docker image and a container?
2. What is a Dockerfile?
3. Why use python:3.12-slim?
4. What is port mapping?
5. Why did you use host port 5001 and container port 5000?
CI/CD
1. Explain your GitHub Actions pipeline.
2. Why did you use a self-hosted runner?
3. Why run tests before deployment?
4. How are Docker images versioned?
5. What happens when you push a new commit?
ECS / ECR
1. What is ECS?
2. What is ECR?
3. What is an ECS task definition?
4. What is an ECS service?
5. What is the difference between desired count and running count?
Troubleshooting
1. How did you troubleshoot the ECS port conflict?
2. Why did GitHub Actions initially fail with BucketAlreadyExists?
3. How did you solve the Terraform state problem?
4. Why did you use the Floci backing registry?
5. How did you verify the final deployment?
🏆 Final Project Summary
This project demonstrates a complete DevOps lifecycle:
Code
 ↓
Git
 ↓
GitHub
 ↓
CI/CD
 ↓
Automated Testing
 ↓
Docker Build
 ↓
Container Registry
 ↓
Terraform
 ↓
ECS Deployment
 ↓
Remote Terraform State
 ↓
Application Health Check

📌 Portfolio Statement
Designed and implemented a local end-to-end DevOps CI/CD platform using GitHub Actions, Docker, Terraform, Floci ECS/ECR/S3 and a self-hosted runner, including automated testing, container image delivery, infrastructure deployment and remote Terraform state management.

✅ Project Status
Project 5 — Local DevOps CI/CD Platform with Floci: COMPLETE 🎉
Technologies:
GitHub GitHub Actions Docker Terraform ECS ECR S3 Floci Python Flask Pytest
