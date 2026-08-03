variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
  default     = "habotconnect-devops-2026"
}

variable "region" {
  description = "Google Cloud region"
  type        = string
  default     = "asia-south1"
}

variable "iam_user_email" {
  description = "Email address used for IAM access"
  type        = string
}