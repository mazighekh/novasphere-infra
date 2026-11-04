output "web_public_ip" {
  description = "IP publique de l'instance web"
  value       = module.web.public_ip
}

output "web_instance_id" {
  description = "Identifiant de l'instance web (utilise par les scripts stop/start)"
  value       = module.web.instance_id
}

output "monitoring_public_ip" {
  description = "IP publique de l'instance de supervision"
  value       = module.monitoring.public_ip
}

output "ssh_command" {
  description = "Commande de connexion au web"
  value       = "ssh -i ~/.ssh/novasphere admin@${module.web.public_ip}"
}
