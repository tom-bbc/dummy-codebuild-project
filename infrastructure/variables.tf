variable "project_name" {
  type = string
  default = "dummy-codebuild-project"
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

variable "repository_url" {
  type = string
  default = "https://github.com/tom-bbc/dummy-codebuild-project.git"
}

variable "buildspec_file" {
  type    = string
  default = "../buildspec.yaml"
}
