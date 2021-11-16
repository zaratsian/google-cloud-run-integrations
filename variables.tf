####################################################################
#   
#   NOTE: 
#   All of these variables as set as part of the config.default file
#   Do not change these variables here.
#
####################################################################

variable "GCP_PROJECT_ID" {
  description = "The project to deploy to, if not set the default provider project is used."
  default     = ""
}

variable "GCP_REGION" {
  description = "Region for cloud resources"
  default     = ""
}

variable "CLOUDSQL_INSTANCE_NAME" {
  description = "CloudSQL Instance Name"
  default     = ""
}

variable "CLOUDSQL_DB_VERSION" {
  description = "The version of of the database. For example, `MYSQL_5_6` or `POSTGRES_9_6`."
  default     = ""
}

variable "CLOUDSQL_TIER" {
  description = "The machine tier (First Generation) or type (Second Generation). See this page for supported tiers and pricing: https://cloud.google.com/sql/pricing"
  default     = ""
}

variable "CLOUDSQL_DB_NAME" {
  description = "Name of the default database to create"
  default     = ""
}

variable "CLOUDSQL_USERNAME" {
  description = "The name of the default user"
  default     = ""
}

variable "CLOUDSQL_HOST" {
  description = "The host for the default user"
  default     = ""
}

variable "CLOUDSQL_DISK_AUTORESIZE" {
  description = "Second Generation only. Configuration to increase storage size automatically."
  default     = true
}

variable "CLOUDSQL_DISK_SIZE" {
  description = "Second generation only. The size of data disk, in GB. Size of a running instance cannot be reduced but can be increased."
  default     = 10
}

variable "REDIS_INSTANCE_NAME" {
  description = "Redis instance name"
  default     = ""
}
