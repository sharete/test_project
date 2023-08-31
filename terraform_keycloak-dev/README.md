# Terraform Project Boilerplate

## Purpose

This Repository includes a Sample Project that can be used to easily use the Project Accounts of the cloudRacer AWS Landingzone.

## Tools needed

- A Linux environment (if you use Windows, try using Windows-Subsystem for Linux (WSL))
- AWS CLI v2 (<https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html>)
- Terraform (via tfswitch <https://tfswitch.warrensbox.com/>)
- Awsume (<https://awsu.me/>)
- Python3 (make sure you have "python3" as CLI command)
- Git CLI (<https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>)
- Git Remote Code Commit (GRC): `pip install git-remote-codecommit` (<https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-git-remote-codecommit.html?icmpid=docs_acc_console_connect>)

## Usage

### Step 1: Setup Credentials

- First we need to configure the AWS CLI to be able to access the AWS Accounts
- Ideally you would create an AWS SSO Profile for each AWS Account that you are working on.
- Ensure that everybody calls the profiles the same. E.g. Client.Account.Stage (tecRacer.cloudRacer.Dev)
- Use `aws configure sso --profile Client.Account.Stage`
  - SSO start URL: `https://<URL>.awsapps.com/start/`
  - SSO Region: `eu-central-1`
  - You can now choose between multiple accounts, choose the one you need
  - A Browser Window will open automatically, enter your Username and Password
  - After Login your see a window "Authorize request", click "Allow"
  - CLI default client Region: `eu-central-1`
  - CLI default output format: json
- Check your configuration:
  - Login with your new profile `aws sso login --profile Client.Account.Stage`
  - Check credentials: `aws sts get-caller-identity --profile Client.Account.Stage`
  - You should receive a JSON file with an Attribute `"Account": "<ACCOUNT-ID"`, make sure the ID is the same as chosen above.

- Do the same for the other accounts you need

### Step 2: Create the Terraform Backend

- Go to the `tf_backend` Folder and change the variables in the `terraform.auto.tfvars` file
  - You'll find all details in the ReadMe.md of the `tf_backend` folder
- Change to `tf_backend` folder on your CLI

### Step 3: Configure your Project

- Go to the `aws_tf_project` folder and edit the `terraform.auto.tfvars` file
  - Add the name of your project to the `system` variable, you may also edit `organisation` and `tags` variables
  - Check if the file `tf_backend.tf` exists and if the content is correct (the file is automatically created from the `aws_tf_backend` project)
  - Your project should be configured, you can proceed with Step 4

### Step 4: Initialize your Project

- Go to the `aws_tf_project` project folder on your CLI
- Make sure you're logged in to your AWS SSO Profile
- Initialize the Terraform environment (`terraform init`)
  - If you receive an error like `Unsupported Terraform Core version`, use tfswitch (`tfswitch` or `tfswitch -l`) to choose the correct Terraform version
  - You should see a message like `Successfully configured the backend "s3"!` and `Terraform has been successfully initialized!`
- Now everything is setup! You can use `terraform apply` to apply a sample S3 Bucket (defined in `s3_sample.tf` or start creating your own resources)
- You are ready to go. Checkout *Step 5: Additional Information / Best Practices* for further information

## Step 5: Additional Information / Best Practices

- You should always add the local variable `local.common_prefix` to your resource names
  - This includes your workspace, your organization and your project name
- Alway add `local.tags` to your resources, if possible

## Use Git

### Clone & Push Code with AWS SSO

- You can easily use AWS CodeCommit for your project
- In the AWS Management Console go to the service CodeCommit and create a new repository (make sure you're in the correct region), let's say it's `<MyRespository>`
- The best way is to use the HTTPS GRC (Git Remote Code Commit) Option to clone your repository
- (Make sure you installed Git Remote Code Commit (GRC))
- Use `aws sso login --profile <MyPROFILE>` to login (you'll logout after a while)
- Use `git clone codecommit::<AWS-REGION>://<MyPROFILE>@<MyRespository>`

## Info

- Everything you see that is in `<>` needs to be replaced! These are just placeholders...
