include {
  path = find_in_parent_folders()
}

inputs = {
  github_owner = basename(get_parent_terragrunt_dir())
}