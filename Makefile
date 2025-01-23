###############################################################################
# CODEBUILD TARGETS
###############################################################################

NAME    := dummy-codebuild-project
VERSION := $(shell cat VERSION)

AWS_DEFAULT_REGION := eu-west-2
AWS_ACCOUNT_ID := 093380438279
ECR_REPOSITORY_URI := 093380438279.dkr.ecr.eu-west-2.amazonaws.com/dummy-codebuild-project

.PHONY: codebuild
codebuild:
    aws ecr get-login-password --region $(AWS_DEFAULT_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_DEFAULT_REGION).amazonaws.com
	docker build -t $(NAME) .
	docker run --rm $(NAME) "/wrk/codebuild.sh"
	docker tag $(NAME) $(ECR_REPOSITORY_URI):$(VERSION)
	docker push $(ECR_REPOSITORY_URI):$(VERSION)
	docker image rm $(NAME)

.PHONY: test
test:
	poetry run pytest --black
	poetry run flake8
