#!/bin/bash

rm -rf .terraform
ENV="$1"
sed -i "s/_env_/$ENV/g" backend.tf
echo "Environment is set to $ENV"

terraform init
terraform validate
terraform plan -var-file=$ENV.tfvars
terraform apply -var-file=$ENV.tfvars -auto-approve

echo "Rolling back the backend.tf"
sed -i '' -e "s/$ENV/_env_/" backend.tf

echo "Terraform ran successfully!"