# CliXX Retail — Deployment Pipeline

This pipeline builds and deploys the CliXX Retail application to the EKS cluster provisioned by the base infrastructure pipeline. It must run after the base infra pipeline has completed.

---

## Before You Run This

Make sure the following are in place:

- Base infra pipeline has run and state exists in S3
- Jenkins has these credentials saved:
  - `github-token`
  - `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
  - `SONAR_TOKEN`
  - `DB_USER_NAME`, `DB_PASSWORD`, `DB_NAME`, `RDS_ENDPOINT`
- Jenkins tools installed: `Sonar-inst`, `docker-inst`, `terraform-14`
- SonarQube server registered in Jenkins as `SonarQubeScanner`
- Slack notifications configured in Jenkins

---

## What Happens When You Run It

1. Runs a SonarQube scan on the codebase and waits for the quality gate
2. Builds a Docker image tagged with the build number
3. Starts the container locally on the Jenkins agent so you can test it
4. Asks for manual confirmation before tearing it down
5. Asks for manual confirmation before pushing to ECR
6. Pushes the image to ECR with both a versioned tag and `:latest`
7. Fetches the ALB hostname from the running ingress and updates the WordPress database
8. Asks for manual confirmation before deploying to EKS
9. Injects the ECR image URL into `deployment.yaml` and applies all Kubernetes manifests
10. Waits for the rollout to complete and prints pod and service status

---

## File Structure

```
deployment_infra/
├── Jenkinsfile
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
└── README.md
```

---

## A Note on the Image URL

`deployment.yaml` contains `IMAGE_PLACEHOLDER` as the image value. Jenkins replaces this at runtime with the actual ECR URL and build tag before applying the manifest. The file resets itself after each deployment so the next run starts clean.

---

## Remote State

The pipeline reads the ECR URL, cluster name, and account ID directly from the base infra S3 state. Nothing is hardcoded.

---

## Manual Gates

There are three points in the pipeline where it pauses and waits for your confirmation:

| Gate | What it's waiting for |
|---|---|
| Tear Down Docker Image | You to finish testing the local container |
| Push to ECR | Your go-ahead to push the image |
| Deploy to EKS | Your go-ahead to apply to the cluster |