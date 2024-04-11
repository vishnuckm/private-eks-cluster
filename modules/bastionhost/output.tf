output "bastion_host_id" {
  description = "The ID of the Bastion Host"
  value       = aws_instance.bastion_host.id
}

