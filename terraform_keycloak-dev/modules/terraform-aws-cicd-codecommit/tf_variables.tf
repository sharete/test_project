variable "repository_name" {
  type        = string
  description = "CodeBuild git repository name"
}

variable "repository_description" {
  type        = string
  description = "CodeBuild git repository description"
}

variable "tags" {
  description = "Tags that should be applied to all Resources"
}
