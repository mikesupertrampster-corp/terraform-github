generate "backend" {
  path      = "config.tf"
  if_exists = "overwrite_terragrunt"
  contents  = templatefile(".files/template/config.tf", {
    organization = basename(get_parent_terragrunt_dir())
    workspace_name = replace(path_relative_to_include(), "/(\\.|/)/", "-")
  })
}
