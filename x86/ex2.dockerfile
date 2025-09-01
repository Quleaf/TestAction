# use node:10
FROM node:10

LABEL org.opencontainers.image.version=0.0.1
LABEL org.opencontainers.image.devmode=true

# install some common tools (these packages have many vulnerabilities in node:10)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        vim \
    && rm -rf /var/lib/apt/lists/*

# default command
CMD ["node", "-v"]