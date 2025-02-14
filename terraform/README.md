# Terraform Deployment

We use terraform to create the spaces and services needed by the application and
to deploy the application itself.

We use terraform workspaces to keep the terraform state seperate for each
environment.

We store our state in an s3 bucket on the PaaS in the terraform space.

Deploys will happen automatically from Github Actions

## Manual Deployment

We avoid manual deployments on production and staging, but require them on our
training environment (pentest).

### Setup

- install [tfenv](https://github.com/tfutils/tfenv)
- install Terraform version `0.12.x` using `tfenv`, use `tfenv list-remote` to
  see available versions. Our Terrafiles are not backwards-compatible with
  Terraform `0.11.x`
- install the latest [cloundfoundry
  provider](https://github.com/cloudfoundry-community/terraform-provider-cf/wiki#installations)

### Deployment

- checkout the correct branch
  - `develop` for staging or other testing environments
  - `master` for production
- `cd` to the application's `terraform` directory
- set environment variables for your AWS and CF credentials by creating a file
  named `deploy-credentials.sh` containing the following:

  ```
  export AWS_ACCESS_KEY='...'
  export AWS_SECRET_ACCESS_KEY='...'
  export CF_USER='...'
  export CF_PASSWORD='...'
  ```

  **Make sure you do not commit this file to git, as it contains security
  credentials.** You can find the AWS credentials in the RODA 1Password vault,
  in the item "terraform state S3 bucket credentials". The CF credentials should
  be your username and password for GPaaS. Once set, load these variables into
  your shell by running `source deploy-credentials.sh`
- download a copy of the Terraform variables from the RODA 1Password vault;
  they're in the item "pentest.tfvars" -- save them to a file named
  `pentest.tfvars` in the current directory
- find the Docker image ID for the image you want to deploy, for example to find
  the image currently on production, run:

  ```
  cf login -a api.london.cloud.service.gov.uk
  cf app beis-roda-prod
  ```

  This will contain a line like:

  ```
  docker image: thedxw/beis-report-official-development-assistance:<IMAGE ID>
  ```

  Copy the image ID and set it as the value for the `docker_image` variable in
  `pentest.tfvars`.

- `terraform init`
- switch workspace to the right environment `terraform workspace select
  $TF_VAR_environment` You can view available workspaces with `terraform
  workspace list`
- `terraform plan -var-file pentest.tfvars` to check what the deployment will
  change
- `terraform apply -var-file pentest.tfvars` to deploy
- If changes are not applied you can run `cf restage <app>`
- delete the `deploy-credentials.sh` file so that you don't leave plaintext
  credentials on disk
