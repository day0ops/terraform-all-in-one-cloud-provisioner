apiVersion: v1
kind: Config
clusters:
- name: ${context}
  cluster:
    certificate-authority-data: ${cluster_ca_certificate}
    server: ${endpoint}
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
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${cluster_name}"
        - "--region"
        - "${region}"
preferences: {}