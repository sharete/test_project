version: 0.2

env:
  variables:
    TF_VERSION: 0.15.3
    TF_LOG: 'ERROR' # TRACE, DEBUG, INFO, WARN or ERROR

phases:
  install:
    runtime-versions:
      python: 3.7
    commands:
      - tf_version=$${TF_VERSION}
      - wget "https://releases.hashicorp.com/terraform/$${TF_VERSION}/terraform_$${TF_VERSION}_linux_amd64.zip"
      - unzip "terraform_$${TF_VERSION}_linux_amd64.zip"
      - mv terraform /usr/local/bin/
  build:
    commands:
      - cd aws_tf_project/
      - terraform --version
      - terraform init -input=false
      - terraform apply -input=false -auto-approve "$${CODEBUILD_SRC_DIR_TerraformPlanArtifact}/aws_tf_project/tfplan.plan"
