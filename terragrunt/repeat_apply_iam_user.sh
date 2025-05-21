#!/bin/bash

repo_dir="/Users/bing-wei/Documents/swissknife/SA/aws_infra_terraform/projects/fit-bear/iam-user"

username=(
  charlies_lin
)

# cd repo_dir
cd $repo_dir

# 檢查 username's dir是否存在
for name in ${username[@]}; do
  if [ ! -d "$name" ]; then
    echo "Directory $name does not exist. Creating it now."
    mkdir $name
  else
    echo "Directory $name already exists."
  fi
done

# 在每個 username's dir 中建立 terragrunt.hcl
for name in ${username[@]}; do
  cd $name
  if [ ! -f "terragrunt.hcl" ]; then
    echo "Creating terragrunt.hcl in $name"
    touch terragrunt.hcl
  else
    echo "terragrunt.hcl already exists in $name"
  fi
  cd ..
done

# 依照 username 創建 terragrunt.hcl 內容
for name in ${username[@]}; do
  cat > $repo_dir/$name/terragrunt.hcl <<EOF
terraform {
  source = "\${get_path_to_repo_root()}/modules/iam-user"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name = "$name"
  policy_arns = [
    "arn:aws:iam::590183828335:policy/AllowChangePassword"
  ]
}
EOF
echo "Editing terragrunt.hcl in $name"
done

# terragrunt apply & output
for name in ${username[@]}; do
  cd $repo_dir/$name
  terragrunt apply -auto-approve
  password=$(terragrunt output -raw iam_user_login_profile_password)
  cat > $repo_dir/$name/iam_user_login_profile_password.txt <<EOF
aws account: fit-bear
username: $name
password: $password
EOF
  cd ..
done

