# Variables (and outputs) help parameterize the behabiour of the terrform config
# They help integrate your terraform workflow with other automation tools

variable "instance_name" {
  description = "The Name tag of your unfortunate EC2 instance"
  type        = string
  default     = "Learn terra"
}

variable "instance_type" {
  description = "The type of your tarnished EC2 instance"
  type        = string
  default     = "t2.nano"
}

variable "ssh_key" {
  description = "Key for ssh"
  type        = string
  default     = "vps-ssh"
}

variable "public_key" {
  description = "the public key to SSH to EC2"
  type        = string
  default     = "~/.ssh/vps-ssh.pub"
}

variable "ec2_init_log_file" {
  description = "File holding initialization logs for EC2"
  type        = string
  default     = "init_machine.log"
}
variable "ec2_custom_user" {
  description = "Custom user for the sad EC2"
  type        = string
  default     = "yassine"

}

variable "db_passwd" {
  description = "RDS root password"
  type = string
  sensitive = true # hides the password from output during terraform operation, but it's visible in clear in state file
}

variable "db_name" {
  description = "DB NAME"
  type = string
  sensitive = true
}
variable "db_username" {
  description = "Username of db"
  type = string
  sensitive = true
}
# default value is t2.micro if not set.
# So we can set variables. Here's how:
# terraform apply -var instance_type=t2.small