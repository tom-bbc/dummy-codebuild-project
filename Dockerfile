# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY pyproject.toml ./
COPY . .

# Install Poetry
RUN pip install poetry

# Install project dependencies using Poetry
RUN poetry install

# Run main when the container launches
CMD [ "poetry", "run", "python", "package" ]
