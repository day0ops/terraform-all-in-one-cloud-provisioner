# Terraform Cloud Provisioner

Terraform modules for provisioning Kubernetes clusters in AWS (EKS), Google (GKE), and Azure (AKS).

All runnable configs live under **`environments/`**. Each environment is a separate root that uses only the providers you need, so you don't have to configure unused cloud credentials.

## Layout

- **`environments/`** – Terraform roots by provider combination (see [environments/README.md](environments/README.md)):
  - Single: `aks`, `eks`, `gke`
  - Pairs: `aks-eks`, `aks-gke`, `eks-gke`
  - All three: `multicluster`
- **`modules/`** – Shared cluster modules: `aks`, `eks`, `gke`. Provider version constraints are defined in each module’s `versions.tf`.
- **`examples/`** – Sample tfvars (e.g. for EKS); adapt variable names to the environment you use (see each environment’s `variables.tf`).

## Quick start

1. Choose an environment, e.g. **EKS only** → `environments/eks`.
2. Authenticate for that cloud (e.g. AWS profile or env vars for EKS).
3. Run Terraform from that directory:

   ```bash
   cd environments/eks
   terraform init
   terraform plan -var="owner=yourname" -var="eks_cluster_name=my-cluster" -var-file=my.tfvars
   terraform apply -var="owner=yourname" -var="eks_cluster_name=my-cluster" -var-file=my.tfvars
   ```

Variables and outputs are per environment; see `environments/<name>/variables.tf` and `environments/<name>/outputs.tf`.

## Prerequisites

- **EKS** – AWS credentials (e.g. `aws_profile`, or `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`).
- **GKE** – `gcloud auth application-default login` (or `GOOGLE_APPLICATION_CREDENTIALS`).
- **AKS** – `az login` and a service principal; see [Azurerm docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret).

Full list of environments and usage: **[environments/README.md](environments/README.md)**.
