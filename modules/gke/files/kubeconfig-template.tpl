apiVersion: v1
kind: Config
clusters:
- name: ${context}
  cluster:
    certificate-authority-data: ${cluster_ca_certificate}
    server: https://${endpoint}
contexts:
- name: ${context}
  context:
    cluster: ${context}
    user: ${context}
current-context: ${context}
users:
- name: ${context}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: /usr/local/share/google-cloud-sdk/bin/gke-gcloud-auth-plugin
      installHint: Install gke-gcloud-auth-plugin for use with kubectl by following
        https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
      provideClusterInfo: true
preferences: {}