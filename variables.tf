####################################################################
#   
#   NOTE: 
#   All of these variables as set as part of the config.default file
#   Do not change these variables here.
#
####################################################################

variable "GCP_PROJECT_ID" {
  description = "Google Cloud Project ID"
  default     = ""
}

variable "GCP_PROJECT_NUMBER" {
  description = "Google Cloud Project Number"
  default     = ""
}

variable "GCP_REGION" {
  description = "Region for cloud resources"
  default     = ""
}
