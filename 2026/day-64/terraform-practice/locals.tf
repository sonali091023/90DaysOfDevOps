locals {
  name_prefix = "${var.project_name}_${var.env}"

  common_tags = {
    Project     = var.project_name
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}
