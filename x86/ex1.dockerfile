# Use the official Alpine Linux as the base image
#FROM alpine:latest
FROM ubuntu:20.04
LABEL org.opencontainers.image.arch=x86
LABEL org.opencontainers.image.compilation=auto

# # Install curl package
#RUN apk add --no-cache curl



# Install curl package
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

#Define the command that will run when the container starts
CMD ["echo", "Hello, World18.2!"]
