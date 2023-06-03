variable "repo_name" {
  type        = string
  default     = "ecr-repo-name"
  description = "Name of ecr repoistory"
}

variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE"
  description = "If mutable or immutable"
}

variable "scan_on_push" {
  type        = bool
  default     = true
  description = "If youwant to scan image after uploading"
}