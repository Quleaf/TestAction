# Use the official Alpine Linux as the base image
#FROM alpine:latest
From ubuntu:20.04

# Install curl package
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Define the command that will run when the container starts
CMD ["echo", "Hello, World9.7!"]
