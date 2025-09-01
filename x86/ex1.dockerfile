# Use the official Alpine Linux as the base image
#FROM alpine:latest
FROM ubuntu:20.04

LABEL org.opencontainers.image.version=0.0.7
LABEL org.opencontainers.image.devmode=true

# # Install curl packageW
#RUN apk add --no-cache curl



# Install curl package
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

#Define the command that will run when the container starts
CMD ["echo", "Hello, World18.4!"]
