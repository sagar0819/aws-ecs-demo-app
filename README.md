# aws-ecs-demo-app

## Project Overview

This project demonstrates a full-stack AWS deployment with:
- **React frontend** hosted on S3 and served via CloudFront
- **Python FastAPI backend** containerized, deployed to ECS Fargate, and image stored in ECR
- **Infrastructure as Code** using Terraform (Includes S3, CloudFront, ECR, ECS, etc.)
- **CI/CD** with GitHub Actions for backend, frontend, and infra

---

## Directory Structure

```
aws-ecs-demo-app/
  backend/      # FastAPI app (Dockerized)
  frontend/     # React app (SPA)
  infra/        # Terraform IaC (modularized)
  .github/
    workflows/  # GitHub Actions for CI/CD
  README.md     # This file
```

---

## Prerequisites
- AWS account with admin access
- AWS CLI configured locally
- Terraform installed (v1.3+ recommended)
- Docker installed
- Node.js (v18+ recommended)
- GitHub repository with required secrets for CI/CD

---

## 1. Infrastructure Deployment (Terraform)

1. **Initialize Terraform**
   ```sh
   cd infra
   terraform init
   ```
2. **Review and apply the plan**
   ```sh
   terraform plan
   terraform apply -auto-approve
   ```
3. **Note the outputs**
   - `alb_dns_name`: Backend API load balancer DNS
   - `frontend_s3_bucket`: S3 bucket for frontend
   - `frontend_cloudfront_domain`: CloudFront domain for frontend

---

## 2. Backend: FastAPI (Build & Deploy)

### Local Development
1. Run locally:
   ```sh
   cd backend
   pip install -r requirements.txt
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```
2. Test health endpoint:
   - Visit [http://localhost:8000/health](http://localhost:8000/health)

### Docker Build & Push
1. Build Docker image:
   ```sh
   docker build -t <your_ecr_repo_url>:latest .
   ```
2. Authenticate Docker to ECR:
   ```sh
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <your_ecr_repo_url>
   ```
3. Push image:
   ```sh
   docker push <your_ecr_repo_url>:latest
   ```

### Deploy to ECS
- ECS service will automatically pick up the new image if using GitHub Actions or after a manual update.

---

## 3. Frontend: React (Build & Deploy)

### Local Development
1. Set backend API URL in `.env`:
   ```env
   REACT_APP_BACKEND_URL=http://localhost:8000
   ```
2. Start React app:
   ```sh
   cd frontend
   npm install
   npm start
   ```

### Production Build & Deploy
1. Set backend API URL in `.env.production`:
   ```env
   REACT_APP_BACKEND_URL=https://<alb_dns_name>
   ```
2. Build React app:
   ```sh
   npm run build
   ```
3. Deploy to S3:
   ```sh
   aws s3 sync build/ s3://<frontend_s3_bucket>/ --delete
   ```
4. Invalidate CloudFront cache:
   ```sh
   aws cloudfront create-invalidation --distribution-id <cloudfront_dist_id> --paths "/*"
   ```
5. Access your app at `https://<frontend_cloudfront_domain>`

---

## 4. CI/CD with GitHub Actions

- **.github/workflows/backend.yml**: Builds, pushes Docker image to ECR, updates ECS service
- **.github/workflows/frontend.yml**: Builds React app, deploys to S3, invalidates CloudFront
- **.github/workflows/infra.yml**: Deploys infrastructure with Terraform

### Required GitHub Secrets
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`
- `ECR_REPO`, `ECS_CLUSTER`, `ECS_SERVICE`, `TASK_DEFINITION`
- `S3_BUCKET`, `CLOUDFRONT_DIST_ID`

---

## 5. Useful Tips
- Update security groups, VPC, and subnet settings as needed for your environment
- For custom domains, configure Route53 and SSL certificates in CloudFront
- Monitor ECS, ALB, and CloudFront in AWS Console for troubleshooting

---

## 6. Clean Up
To avoid ongoing AWS charges, destroy all resources:
```sh
cd infra
terraform destroy -auto-approve
```

---

## 7. References
- [AWS ECS Fargate](https://docs.aws.amazon.com/ecs/latest/developerguide/AWS_Fargate.html)
- [AWS S3 Static Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [AWS CloudFront](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [FastAPI](https://fastapi.tiangolo.com/)
- [React](https://react.dev/)