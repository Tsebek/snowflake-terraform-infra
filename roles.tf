locals {
  functional_roles = {
    for role, roles in local.roles_yml.functional_roles : role => roles
  }

  account_roles = {
    for role, roles in local.roles_yml.account_roles : role => roles
  }

  account_roles_wo_sysadmin = {
    for role, roles in local.account_roles : role => roles if !contains([role], "sysadmin")
  }

  object_roles = flatten([
    for database, specs in local.databases : [
      for role in specs.roles : join("_", [database, role])
    ]
  ])
}

resource "snowflake_account_role" "object_role" {
  for_each = toset(local.object_roles)

  provider = snowflake.securityadmin

  name    = upper(join("_", [local.object_prefix, each.key]))
  comment = var.comment
}

resource "snowflake_account_role" "functional_role" {
  for_each = local.functional_roles

  provider = snowflake.securityadmin

  name    = upper(join("_", [local.object_prefix, each.key]))
  comment = var.comment
}

resource "snowflake_account_role" "account_role" {
  for_each = local.account_roles_wo_sysadmin
  provider = snowflake.securityadmin

  name    = upper(each.key)
  comment = var.comment
}
