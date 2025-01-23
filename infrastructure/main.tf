################################################################################
# Set up of AWS CodeBuild project and linking to GitHub PRs
################################################################################

data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "main" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Role for project to access codebuild
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

# Policy allowing project role to access codebuild and resources
resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/codebuild/${var.project_name}",
          "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/codebuild/${var.project_name}:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ],
        Resource = ["arn:aws:codebuild:${var.region}:${var.account_id}:report-group/${var.project_name}-*"]
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ],
        Resource = "arn:aws:ecr:${var.region}:${var.account_id}:repository/${var.ecr_repo_name}"
      }
    ]
  })
}

# Setting up codebuild project
resource "aws_codebuild_project" "project" {
  name          = var.project_name
  description   = "Builds a Python app with Poetry managed dependencies and pushes to ECR"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.account_id
    }
    environment_variable {
      name  = "REPOSITORY_URI"
      value = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo_name}"
    }
  }

  # Connection to GitHub
  source {
    type            = "GITHUB"
    location        = var.repository_url
    git_clone_depth = 1
  }

  cache {
    type = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }
}

# Authenticating connection to GitHub
data "aws_secretsmanager_secret" "personal_access_token" {
  name = "dummy-codebuild-project-github-token"
  arn = "arn:aws:secretsmanager:eu-west-2:093380438279:secret:bbc-language-modelling-codebuild-xBUcef"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.personal_access_token.id
}

resource "aws_codebuild_source_credential" "source_credential" {
  depends_on = [aws_codebuild_project.project]
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["github-personal-access-token"]
}

# Activating CodeBuild on GitHub push events
resource "aws_codebuild_webhook" "example" {
  depends_on = [aws_codebuild_source_credential.source_credential]
  project_name = var.project_name
  build_type   = "BUILD"

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_CREATED"
    }

    filter {
      type    = "BASE_REF"
      pattern = "main"
    }
  }

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_UPDATED"
    }

    filter {
      type    = "BASE_REF"
      pattern = "main"
    }
  }

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_REOPENED"
    }

    filter {
      type    = "BASE_REF"
      pattern = "main"
    }
  }
}
