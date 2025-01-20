# modules/codebuild/variables.tf
variable "project_name" {
  type = string
  default = "dummy-codebuild-project"
}

variable "repository_url" {
  type = string
  default = "https://github.com/tom-bbc/dummy-codebuild-project.git"
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Whether images should be scanned on push"
  type        = bool
  default     = true
}

variable "region" {
  type = string
  default = "eu-west-2"
}

variable "account_id" {
  type = string
  default = "093380438279"
}

variable "ecr_repo_name" {
  type = string
  default = "dummy-codebuild-project"
}

variable "buildspec_file" {
  type    = string
  default = "../buildspec.yaml"
}
