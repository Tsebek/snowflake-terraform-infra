# Common Variables
variable "project" {
  type        = string
  description = "The name of the project, for naming and tagging purposes"
  default     = ""
}

variable "environment" {
  type        = string
  description = "The name of the environment we are deploying"
}

variable "region" {
  type        = string
  description = "The AWS region for backend and naming purposes"
}

variable "default_tags" {
  description = "Default tags to apply to all Snowflake resources"
  type        = map(string)
  default     = {}
}

# Snowflake Connection Variables
variable "snowflake_role" {
  type        = string
  description = "The role in Snowflake that we will use to deploy"
}

variable "snowflake_account" {
  type        = string
  description = "The name of the Snowflake account that we will be deploying into"
}

variable "snowflake_org" {
  type        = string
  description = "The name of the Snowflake Organization we will be deploying into"
}

variable "snowflake_user" {
  type        = string
  description = "The name of the Snowflake user that we will be utilizing to deploy"
}

# Configuration
variable "config_dir" {
  type        = string
  description = "The path to your configuration `.yml` files"
  default     = "./config"
}

variable "comment" {
  description = "A comment to apply to all resources"
  type        = string
  default     = "Created by terraform"
}

# Warehouse Defaults
variable "default_warehouse_size" {
  type        = string
  description = "The size of the Snowflake warehouse"
  default     = "xsmall"
}

variable "default_warehouse_auto_suspend" {
  type        = number
  description = "The auto_suspend (seconds) of the Snowflake warehouse"
  default     = 60
}

variable "default_warehouse_max_cluster_count" {
  type        = string
  description = "The maximum number of clusters for the Snowflake warehouse"
  default     = 1
}

variable "always_apply" {
  type        = bool
  description = "Toggle to always apply on all objects. Used for when there are changes to the grants that need to be retroactively granted to roles"
  default     = false
}

variable "create_parent_roles" {
  type        = bool
  description = "Whether or not you want to create the parent roles (for production deployment only)"
  default     = false
}