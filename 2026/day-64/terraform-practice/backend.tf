terraform {
  backend "s3" {
    bucket         = "terraweek-state-sonali-dev-tf-state"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile = true
    encrypt        = true
  }
}
