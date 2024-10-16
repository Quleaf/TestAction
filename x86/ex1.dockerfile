# Use the official Alpine Linux as the base image
FROM alpine:latest

# Install curl package
RUN apk add --no-cache curl

# Define the command that will run when the container starts
CMD ["echo", "Hello, World9!"]
