# -------------------------------------------------------------- #
# BACKEND configuration variables
# -------------------------------------------------------------- #

variable "bucket" {
  description = "Name of the bucket to store .tfstate file remotely."
  type        = string
}

variable "prefix" {
  description = "Prefix for the state file"
  type        = string
}

variable "credentials" {
  description = "GCP credentials file"
  type        = string
}