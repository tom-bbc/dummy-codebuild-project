FROM ubuntu:latest AS base

WORKDIR /wrk

# Install poetry env for core codebase
RUN mkdir -p /wrk/

COPY . /wrk/

# Install system dependencies
RUN apt-get update

RUN apt-get install -y bash-completion \
                       htop            \
                       python3-dev     \
                       python3-venv    \
                       shellcheck      \
                       sudo            \
                       make

# Install Poetry
RUN python3 -m venv /usr/local/libexec/venv
RUN /usr/local/libexec/venv/bin/pip install poetry

ENV PATH="$PATH:/usr/local/libexec/venv/bin"

# Install project dependencies using Poetry
RUN poetry install
