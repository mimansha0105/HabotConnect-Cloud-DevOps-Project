# HabotConnect Cloud DevOps Automation Project

**Candidate:** Mimansha Singh  
**Contact:** [Add your email address]  
**GitHub Repository:** [Add repository URL]

---

## 1. Project Overview

This project demonstrates an automated Cloud and DevOps workflow for deploying the HabotConnect Django application to Amazon Web Services.

The solution integrates application validation, Infrastructure as Code validation, security scanning, Docker containerization, GitHub Actions Continuous Integration and Continuous Deployment, GitHub OpenID Connect authentication, and deployment to Amazon Elastic Compute Cloud using AWS Systems Manager.

The pipeline follows a **Fail-Closed** approach: if a required validation or security gate fails, the workflow stops and deployment does not continue.

---

## 2. Technology Stack

- Python 3.12
- Django
- Terraform
- Git
- GitHub
- GitHub Actions
- Docker
- Docker Hub
- Amazon Web Services
- Amazon Elastic Compute Cloud
- AWS Identity and Access Management
- AWS Systems Manager
- OpenID Connect
- Checkov
- Gitleaks

---

## 3. Project Structure

```text
HabotConnect-Cloud-DevOps-Project/
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── habot_backend/
│
├── student_onboarding/
│   └── terraform/
│       └── *.tf
│
├── Dockerfile
├── manage.py
├── requirements.txt
└── README.md
```

---

## 4. Continuous Integration Pipeline

The GitHub Actions workflow is triggered when code is pushed to the `main` branch or when a pull request targets `main`.

The Continuous Integration pipeline performs:

1. Repository checkout
2. Python 3.12 setup
3. Python dependency installation
4. Django system check
5. Django automated tests
6. Terraform setup
7. Terraform format validation
8. Terraform initialization
9. Terraform configuration validation
10. Checkov security scan
11. Docker Hub authentication
12. Docker image build
13. Docker image push
14. AWS authentication
15. Deployment using AWS Systems Manager
16. Gitleaks secret scanning

---

## 5. Terraform Validation

Terraform is used as Infrastructure as Code.

The pipeline validates the Terraform configuration using:

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
```

These automated checks help detect formatting and configuration errors before deployment.

---

## 6. Automated Security Gates

### Checkov

Checkov scans Terraform Infrastructure as Code for insecure configurations and policy violations.

The pipeline is configured to fail when required Checkov validation fails.

### Gitleaks

Gitleaks is used to detect accidentally committed secrets, credentials, and sensitive information.

### Fail-Closed Pipeline

The pipeline follows a Fail-Closed approach.

```text
Code Commit
     |
     v
Application Validation
     |
     v
Terraform Validation
     |
     v
Security Scan
     |
     +---- FAIL ----> Pipeline Stopped
     |
    PASS
     |
     v
Docker Build
     |
     v
Deployment
```

Invalid or insecure changes are therefore prevented from progressing through the normal deployment path.

---

## 7. Docker Containerization

The Django application is packaged as a Docker image.

Docker image:

```text
mimansha0501/habotconnect:v1
```

The deployment process pulls the image and runs the application container:

```bash
sudo docker pull mimansha0501/habotconnect:v1
sudo docker stop habotconnect-app || true
sudo docker rm habotconnect-app || true
sudo docker run -d \
  --name habotconnect-app \
  --restart unless-stopped \
  -p 8000:8000 \
  mimansha0501/habotconnect:v1
```

---

## 8. Secure AWS Authentication

GitHub Actions authenticates with Amazon Web Services using **OpenID Connect**.

The workflow assumes a dedicated AWS Identity and Access Management role instead of storing permanent AWS access keys in the repository.

Authentication flow:

```text
GitHub Actions
      |
      v
GitHub OpenID Connect Token
      |
      v
AWS Identity and Access Management Trust Policy
      |
      v
Temporary AWS Role Credentials
```

This reduces the security risks associated with long-lived cloud credentials.

---

## 9. Deployment Using AWS Systems Manager

The application is deployed to Amazon Elastic Compute Cloud using AWS Systems Manager Run Command.

Deployment flow:

```text
GitHub Actions
      |
      v
OpenID Connect Authentication
      |
      v
AWS Identity and Access Management Role
      |
      v
AWS Systems Manager
      |
      v
Amazon Elastic Compute Cloud
      |
      v
Docker Container
      |
      v
HabotConnect Application
```

AWS Systems Manager enables remote deployment without requiring the GitHub Actions runner to connect directly to the instance using Secure Shell.

---

## 10. Engineering Logic

The pipeline is designed around early validation and controlled deployment.

Each stage must complete successfully before the next required stage is allowed to proceed.

This provides:

- Repeatable application validation
- Infrastructure as Code validation
- Automated security scanning
- Reproducible Docker packaging
- Reduced manual deployment steps
- Short-lived AWS authentication
- Controlled Amazon Elastic Compute Cloud deployment
- Auditable GitHub Actions execution history

---

## 11. Troubleshooting and Engineering Challenges

During implementation, several issues were identified and resolved.

### GitHub Actions YAML

Incorrect YAML indentation caused workflow syntax failures.

The workflow structure and indentation were corrected before execution.

### OpenID Connect Authentication

AWS initially rejected the GitHub Actions request to assume the deployment role using `sts:AssumeRoleWithWebIdentity`.

The AWS Identity and Access Management trust relationship and GitHub repository conditions were reviewed and corrected.

### AWS Systems Manager

The Amazon Elastic Compute Cloud instance required the appropriate instance permissions and AWS Systems Manager connectivity before remote commands could execute.

### Deployment Access

The deployment workflow was changed from direct Secure Shell deployment to AWS Systems Manager based deployment.

---

## 12. Security Considerations

The project applies several security practices:

- OpenID Connect authentication instead of permanent AWS access keys
- Dedicated AWS Identity and Access Management role
- Checkov Infrastructure as Code scanning
- Gitleaks secret scanning
- Automated validation gates
- AWS Systems Manager based deployment
- No credentials or private keys should be committed to the repository

---

## 13. Conclusion

This project demonstrates an automated Cloud and DevOps lifecycle covering application validation, Infrastructure as Code validation, security scanning, Docker containerization, secure cloud authentication, and automated deployment.

The implementation demonstrates how GitHub Actions, Terraform, Docker, OpenID Connect, AWS Identity and Access Management, AWS Systems Manager, and Amazon Elastic Compute Cloud can work together to create a controlled and repeatable deployment workflow.

---

**Candidate:** Mimansha Singh  
**Project:** HabotConnect Cloud DevOps Automation Project