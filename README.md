## Shallwe QA Infra (Terraform)

This repository contains a single-environment (QA) AWS infrastructure for a backend application running on ECS (EC2 launch type) behind an ALB, with RDS PostgreSQL and EFS for shared storage. It sits between a learning project and an MVP-quality portfolio piece: pragmatic, reproducible, and intentionally scoped.

### Highlights
- ECS EC2 with capacity provider and ASG-managed instances
- ALB (HTTP) → ECS service (awsvpc)
- RDS PostgreSQL 16 with backups and deletion safety
- EFS with access points mounted into task volumes
- Explicit routing and IAM roles

### Architecture
- Network: 1 VPC with 3 public subnets (for simplicity). IGW + route table associations are explicit.
- Compute: EC2 launch template → Auto Scaling Group → ECS Capacity Provider → ECS Cluster → ECS Service/Tasks.
- Data: RDS PostgreSQL, EFS (APs + mount targets), security groups scoped to components.
- Observability: CloudWatch Logs via awslogs driver.

### Repository layout (single environment)
- Root-level .tf files grouped by concern (network_*, capacity_*, ecs_*, iam_*, db_*, efs_*). Terraform loads all .tf files in this directory; filenames are for human readability.
- `templates/backend/ec2/user_data.sh` for EC2-based ECS agent configuration and swap setup.
- Optional helper scripts: `env_fetch.sh`, `env_apply.sh` for loading variables (e.g., from Bitwarden) into `.env`.

### Prerequisites
- Terraform >= 1.6 (see `version.tf`) and AWS provider ~> 5.100
- AWS credentials configured locally (or via `.env` → TF_VAR_*)
- S3/DynamoDB backend recommended for state/locking (not enforced in repo)

### Quickstart
1) Initialize and preview
```bash
terraform init
terraform plan
```
2) Apply
```bash
terraform apply
```
3) Access
- After apply, use the ALB DNS name to reach the app (HTTP). If you later add TLS, flip `global_use_secure_protocol` to true and configure ACM/443 listener.

### Teardown (read before destroying)
- RDS is protected: `deletion_protection = true`. To destroy, first set it to false and apply.
- Final snapshot is enforced: `skip_final_snapshot = false` with a stable, unique `final_snapshot_identifier` (generated via `time_static`). On destroy, AWS creates that snapshot.

### Design choices and simplifications (intentional)
- Single environment only (QA): No multi-env wiring or Terragrunt. This keeps focus on core AWS primitives while remaining production-flavored.
- Public subnets for everything: Simpler routing. In production, RDS would live in private subnets (NAT for egress) and tasks would typically sit in private as well.
- HTTP-only ALB by default: Faster demo path. Add ACM and a 443 listener when exposing publicly; then set `global_use_secure_protocol = true`.
- ECS EC2 launch type: Uses ECS-optimized AL2023 AMI and an instance profile. Execution role exists and is aligned to `AmazonECSTaskExecutionRolePolicy` for correctness.
- IAM breadth for CI/admin users: Kept close to exported, working infra. For a real product, prefer least-privilege policies and ephemeral credentials (OIDC) over static access keys.

### Security posture (what’s safe and what’s relaxed)
- Safe
  - ECS-optimized AMI; explicit capacity provider association
  - RDS deletion protection + enforced final snapshot
  - EFS access points with restricted POSIX ownership
- Relaxed (trade-offs for simplicity)
  - ALB and tasks share a security group; tasks are internet-reachable. For a stricter stance, use separate SGs and allow task ingress only from the ALB SG.
  - RDS in public subnets (still SG-restricted). For production, move to private subnets.
  - No TLS at the ALB by default. Add ACM + HTTPS when needed.

### Configuration
- See `variables.tf` for all configurable inputs and descriptions.
- Author workflow: a `.env` file is generated from Bitwarden using `env_fetch.sh`, exporting environment variables (e.g., `TF_VAR_*`).
- You can configure values your own way (e.g., `-var`, `-var-file`, Terraform Cloud/Workspace vars, or another secret manager).

### Common operations
- Scale up/down
```bash
terraform apply -var='backend_desired_count=2'
```
- Rotate images
```bash
terraform apply -var='backend_image=repo/backend:1.2.3' -var='nginx_image=repo/nginx:1.2.3'
```

### Future improvements (if time warrants)
- Split public/private subnets; move RDS/tasks private, add NAT
- Add TLS (ACM + 443 listener), ALB → task SG separation
- Break out small modules (e.g., ecs-service) while keeping single-env simplicity
- Remote state backend (S3 + DynamoDB) with CI plan/apply workflow
- Least-privilege IAM and OIDC-based CI credentials

### FAQ
- Why so many .tf files at root?
  - Terraform loads all .tf in a directory; separate files improve readability. It’s equivalent to one big `main.tf`.
- Why not modules everywhere?
  - Single environment and limited scope. Modules add indirection; they’ll be introduced only where they truly reduce noise.

---
This repo is an approximation of how a system could be deployed for stage (and it actually does run a stage for this demo), but please do not take too seriously. While I wanted to make it as real as possible, I also was first time using Terraform and had some other pressing projects on my mind. It is enough to relatively safe and run the demo infra, without obvious bad practices like hard-coded values and secrets, yet I do realize it's not perfect yet. For me, though, it was a great learning experience - not only for the solutions I implemented here, but also the ones I chose to avoid for now, but got to know a lot of - the knowledge is there in any way.
