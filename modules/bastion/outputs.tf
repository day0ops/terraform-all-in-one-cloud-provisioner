output "bastion_security_group_id" {
  description = "Security group ID for the bastion host"
  value       = try(aws_security_group.bastion[0].id, null)
}
