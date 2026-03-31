# Environment Configurations

These directories are **standalone Terraform roots** for specific cloud combinations. Use the one that matches your target providers so you only configure credentials for the clouds you use.

## Available environments

| Environment     | Providers   | Use when you need...        |
|----------------|-------------|-----------------------------|
| `aks`          | Azure only  | AKS clusters only           |
| `eks`          | AWS only    | EKS clusters only           |
| `gke`          | GCP only    | GKE clusters only           |
| `aks-eks`       | Azure + AWS | AKS and EKS                 |
| `aks-gke`      | Azure + GCP | AKS and GKE                 |
| `eks-gke`      | AWS + GCP   | EKS and GKE                 |
| `multicluster` | All three   | AKS, EKS, and GKE together  |
| `eks-ipv6`     | AWS only    | EKS IPv6 dual-stack clusters with Transit Gateway mesh and optional bastion |

## How to use

1. **Pick an environment** (e.g. `gke` if you only use GCP).

2. **Run Terraform from that directory:**
   ```bash
   cd environments/gke
   terraform init
   terraform plan -var-file=my.tfvars
   terraform apply -var-file=my.tfvars
   ```
   Or from the repo root:
   ```bash
   terraform -chdir=environments/gke init
   terraform -chdir=environments/gke plan -var-file=environments/gke/my.tfvars
   terraform -chdir=environments/gke apply -var-file=environments/gke/my.tfvars
   ```

3. **Configure only the providers that environment uses:**
   - **aks**: `az login` (or Azure env vars / service principal).
   - **eks** / **eks-ipv6**: AWS credentials (profile, env vars, or IAM role).
   - **gke**: GCP credentials (`gcloud auth application-default login` or service account).

Each environment’s `providers.tf` declares only the provider(s) it needs. Provider version constraints come from the shared modules under `modules/`, so you are not forced to set up unused cloud credentials.

**Default Kubernetes version (single place):** The default version for all clusters (AKS, EKS, GKE) is defined once in **`modules/defaults/variables.tf`** (variable `kubernetes_version`, default `1.34`). Every environment uses this via the `defaults` module; you only change it there to update the default everywhere. To override per run: `-var kubernetes_version=1.35` or set `kubernetes_version` in your tfvars.
