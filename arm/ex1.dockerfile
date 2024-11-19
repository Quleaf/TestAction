# Use the official Alpine Linux as the base image
#FROM alpine:latest
FROM ubuntu:20.04

LABEL org.opencontainers.image.arch=arm
LABEL org.opencontainers.image.compilation=auto
LABEL org.opencontainers.image.devmode=false
LABEL org.opencontainers.image.noscan=true
LABEL org.opencontainers.image.minversion="0.0.5"

ENV MYVALUE="VALUE2"
# Install curl package
#RUN apk add --no-cache curl

# Install curl package
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Define the command that will run when the container starts
CMD ["echo", ${MYVALUE}]
