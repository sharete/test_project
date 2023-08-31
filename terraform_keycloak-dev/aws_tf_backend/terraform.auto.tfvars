# - General Setup - #
region       = "eu-central-1" # Region the resources should be created in
system       = "keycloak-test" # Name for your Project / System
organisation = "ivv" # Shorthand for your Organisation / Company
# - Backend - #
sso_credentials_file        = "~/.aws/config" # Name of your AWS CLI Config File
sso_profile_name            = "ivv.keycloak.test" # Name of your AWS SSO Profile
use_remote_state            = true # Should the TF state of this project also be stored in the remote backend (that this project creates)?
populate_backend_to_folders = ["../aws_tf_project"] # Write tf_backend files also to other folders / projects
use_cicd_pipeline           = false # Do you want a CI/CD Pipeline (AWS CodePipline) for your project?