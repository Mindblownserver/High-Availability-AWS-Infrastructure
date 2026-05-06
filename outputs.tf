# This file's sole purpose is displaying infos after applying terraform's plan
# The output values can be consumed by other automation tools or workflows.
# terraform output -raw default_ssh_ip =(returns)=> ssh -i ....

# output "default_ssh_ip_vps1" {
#   description = "How to ssh to the machine"
#   value       = "ssh -i ~/.ssh/${var.ssh_key} ec2-user@${aws_instance.app_server.public_ip}"
# }

# output "yassine_ssh_ip_vps1" {
#   description = "How to ssh to the machine"
#   value       = "ssh -i ~/.ssh/${var.ssh_key} yassine@${aws_instance.app_server.public_ip}"
# }
output "load_balancer_dns" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.app_lb.dns_name
}

output "frontend_ssh" {
  description = "public IP @ of the failed frontend server"
  value = aws_instance.frontend_server.public_ip
}
output "db_host" {
  description = "DB_HOST"
  value = aws_db_instance.db.address
}