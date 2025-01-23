###############################################################################
# CODEBUILD TARGETS
###############################################################################

NAME    := dummy-codebuild-project
VERSION := $(shell cat VERSION)

.PHONY: codebuild
codebuild:
	docker build -t $(NAME) .
	docker run --rm $(NAME) "/wrk/codebuild.sh"
# docker tag $(NAME):$(VERSION) $(ECR_REPOSITORY_URI):$(VERSION)
# docker push $(ECR_REPOSITORY_URI):$(VERSION)
# docker image rm $(NAME)

.PHONY: test
test:
	poetry run pytest --black
	poetry run flake8
