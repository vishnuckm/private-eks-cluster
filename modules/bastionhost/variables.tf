variable "ami_id" {
  description = "The AMI to be used for the bastion host"
}

variable "instance_type" {
  description = "Instance type for the bastion host"
  default     = "t3.micro"
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance"
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
}

variable "vpc_id" {
  description = "The ID of the VPC"
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks that are allowed to access the bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"] # It's recommended to restrict this to your IP range
}
# variable "user_data" {
# }
