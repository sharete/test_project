terraform {
  # Empty. Initialize with the following command:
  # terraform init -backend-config tf-<stage>-backend.tfvars -reconfigure
  backend "s3" {}
}
