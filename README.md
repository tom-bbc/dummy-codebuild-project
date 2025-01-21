# dummy-codebuild-project
Test usage of AWS CodeBuild using Git, Docker, Terraform, and Poetry.

### Setup/run commands

* `terraform init` and `terraform apply` will set up the project infrastructure on AWS.
* CodeBuild will run on `git push` command for any new commits to main.
* View the build/test results on the AWS CodeBuild console.

### Granting CodeBuild access to GitHub

To connect AWS CodeBuild to GitHub you need to specify your source credential. The credential is referenced by the `aws_codebuild_source_credential` terraform resource in `main.tf`.

This can be a **GitHub personal access token** (with [these permissions](https://docs.aws.amazon.com/codebuild/latest/userguide/access-tokens-github.html)) declared in terraform:

```
variable "auth_source_token" {
  description = "The GitHub personal access token"
  type        = string
  default     = "xxxx"
}
```
