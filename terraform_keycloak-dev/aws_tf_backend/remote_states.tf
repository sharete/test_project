# Create a remote State File in "tf_backend.tf"
resource "local_file" "create_remote_state" {
  count = var.use_remote_state ? 1 : 0

  content = templatefile("${path.module}/templates/remote_state.tpl", {
    region               = var.region
    bucket               = module.backend.tf_state_s3_bucket_name
    key                  = "backend.tfstate"
    dynamodb_table       = module.backend.tf_state_dynamodb_name
    encrypt              = true
    sso_credentials_file = var.sso_credentials_file
    sso_profile_name     = var.sso_profile_name
  })

  filename             = "${path.module}/tf_backend.tf"
  file_permission      = "0755"
  directory_permission = "0755"

  depends_on = [module.backend]
}

# Create a remote State Files for the Project Folders
resource "local_file" "create_remote_state_in_populate_backend_to_folders" {
  for_each = toset(var.populate_backend_to_folders)

  content = templatefile("${path.module}/templates/remote_state.tpl", {
    region               = var.region
    bucket               = module.backend.tf_state_s3_bucket_name
    key                  = "${var.system}.tfstate"
    dynamodb_table       = module.backend.tf_state_dynamodb_name
    encrypt              = true
    sso_credentials_file = var.sso_credentials_file
    sso_profile_name     = var.sso_profile_name
  })

  filename             = "${each.value}/tf_backend.tf"
  file_permission      = "0755"
  directory_permission = "0755"

  depends_on = [module.backend]
}

# Create a remote State Files for the Project Folders
resource "local_file" "create_provider_in_populate_backend_to_folders" {
  for_each = toset(var.populate_backend_to_folders)

  content = templatefile("${path.module}/templates/provider.tpl", {
    sso_credentials_file = var.sso_credentials_file
    sso_profile_name     = var.sso_profile_name
  })

  filename             = "${each.value}/tf_provider.tf"
  file_permission      = "0755"
  directory_permission = "0755"

  depends_on = [module.backend]
}
