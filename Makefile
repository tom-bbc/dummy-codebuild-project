###############################################################################
# CODEBUILD TARGETS
###############################################################################

NAME    := dummy-codebuild-project
VERSION := $(shell cat VERSION)

AWS_DEFAULT_REGION := eu-west-2
AWS_ACCOUNT_ID     := 093380438279
ECR_REPOSITORY_URI := $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_DEFAULT_REGION).amazonaws.com/$(NAME)


.PHONY: test
test:
	poetry run pytest --black
	poetry run flake8


.PHONY: codebuild-setup
codebuild-setup:
	aws ecr get-login-password --region $(AWS_DEFAULT_REGION) | \
		docker login                                            \
			--username AWS                                      \
			--password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_DEFAULT_REGION).amazonaws.com


.PHONY: codebuild-run
codebuild-run:
	docker build -t $(NAME) .
	docker run --rm $(NAME) "/wrk/test-build.sh"


.PHONY: codebuild-push
codebuild-push:
	docker tag $(NAME) $(ECR_REPOSITORY_URI):$(VERSION)
	docker tag $(NAME) $(ECR_REPOSITORY_URI):latest
	docker push $(ECR_REPOSITORY_URI):$(VERSION)
	docker push $(ECR_REPOSITORY_URI):latest
	docker rmi $(NAME) $(ECR_REPOSITORY_URI):$(VERSION) $(ECR_REPOSITORY_URI):latest
