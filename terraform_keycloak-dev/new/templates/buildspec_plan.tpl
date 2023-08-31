version: 0.2

env:
  variables:
    TF_VERSION: 0.15.3
    TF_LOG: 'ERROR' # TRACE, DEBUG, INFO, WARN or ERROR
  exported-variables:
    - S3_TF_PLAN_URL

phases:
  install:
    runtime-versions:
      python: 3.7
    commands:
      - tf_version=$$${TF_VERSION}
      - wget "https://releases.hashicorp.com/terraform/$${TF_VERSION}/terraform_$${TF_VERSION}_linux_amd64.zip"
      - unzip "terraform_$${TF_VERSION}_linux_amd64.zip"
      - mv terraform /usr/local/bin/
  build:
    commands:
      - pwd
      - cd aws_tf_project/
      - echo $TF_LOG
      - terraform --version
      - terraform init -input=false
      - terraform validate
      - terraform plan -out=tfplan.plan -input=false
      - terraform show -no-color tfplan.plan > tfplan.txt
      - aws s3 cp tfplan.txt "s3://$${TfPlanBucket}/tfplan-$${ExecutionId}.txt"
      - export S3_TF_PLAN_URL=$(aws s3 presign "s3://$${TfPlanBucket}/tfplan-$${ExecutionId}.txt" --expires-in 3600)
      - echo $S3_TF_PLAN_URL

artifacts:
  files:
    - aws_tf_project/tfplan.plan
  name: TerraformPlanArtifact
