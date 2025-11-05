variable "region" {
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  type        = string
  default     = "presto-poc"
}

variable "allowed_cidr" {
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  type        = string
  default     = "t3.large"
}

variable "ssh_key_name" {
  description = "Opcional: nome do par de chaves para SSH"
  type        = string
  default     = "key-presto-poc"
}
