###############################################################################
# CODEBUILD TARGETS
###############################################################################

NAME    := dummy-codebuild-project
VERSION := $(shell cat VERSION)

AWS_DEFAULT_REGION := eu-west-2
AWS_ACCOUNT_ID     := 093380438279
ECR_REPOSITORY_URI := $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_DEFAULT_REGION).amazonaws.com/$(NAME)

.PHONY: codebuild
codebuild:
	docker build -t $(NAME):$(VERSION) .
	docker run --name $(NAME) --rm $(NAME):$(VERSION) "/wrk/codebuild.sh"
	aws ecr get-login-password --region $(AWS_DEFAULT_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_DEFAULT_REGION).amazonaws.com
	docker tag $(NAME):$(VERSION) $(ECR_REPOSITORY_URI):$(VERSION)
	docker push $(ECR_REPOSITORY_URI):$(VERSION)
	docker image rm $(NAME):$(VERSION)

.PHONY: test
test:
	poetry run pytest --black
	poetry run flake8
