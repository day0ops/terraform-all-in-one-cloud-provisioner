# All-In-One Terraform Provisioner

This includes terraform modules for provisioning Kubernetes clusters in AWS, Google and Azure.

## Prerequisites

In order to run these terraform modules you will need to authenticate with each of the cloud providers.
* For EKS - Using `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to map the credentials.
* For AKS - Supported via CLI login, `az login`.
  Create a service principal following [docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)
* For GKE - Using `gcloud beta auth application-default login` to save the credentials to `json` file. Set env `GOOGLE_APPLICATION_CREDENTIALS` to this file.

## Instructions

1. Few examples given in `examples`.

    or define custom `terraform.tfvars`. 

    For e.g.
    ```
    owner                   = "kasunt"

    enable_gke              = false
    gke_project             = "field-engineering-apac"
    gke_cluster_count       = 3
    gke_region              = "australia-southeast1"
    gke_cluster_name        = "test"
    gke_node_pool_size      = 3
    gke_node_type           = "e2-standard-4"

    enable_eks              = true
    aws_profile             = "default"
    eks_region              = "ap-southeast-1"
    eks_cluster_name        = "gloo-platform"
    eks_cluster_count       = 3
    eks_node_type           = "t3.medium"
    eks_nodes               = 3
    ```
2. `terraform init` to initialize.
3. `terraform apply` to apply the plan. Alternatively use `terraform apply -var-file examples/<example file>.tfvars -auto-approve`
4. To retrieve the kube configuration,
  ```
  export CLUSTER1_CONTEXT=`terraform output -json | jq -r '.eks_kubeconfig_context.value[0]'`
  export CLUSTER2_CONTEXT=`terraform output -json | jq -r '.gke_kubeconfig_context.value[0]'`
  export CLUSTER3_CONTEXT=`terraform output -json | jq -r '.aks_kubeconfig_context.value[0]'`

  export CLUSTER1_CLUSTER=`terraform output -json | jq -r '.eks_cluster_name.value[0]'`
  export CLUSTER2_CLUSTER=`terraform output -json | jq -r '.gke_cluster_name.value[0]'`
  export CLUSTER3_CLUSTER=`terraform output -json | jq -r '.aks_cluster_name.value[0]'`

  export KUBECONFIG=$KUBECONFIG:`terraform output -json | jq -r '.eks_kubeconfig.value'`:`terraform output -json | jq -r '.gke_kubeconfig.value'`:`terraform output -json | jq -r '.aks_kubeconfig.value'`
  ```