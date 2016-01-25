FROM jenkins:1.625.3
MAINTAINER Larry Murdock "larry@svds.com"
USER root
RUN apt-get update  && apt-get install -y \
    npm \
    nodejs-legacy \
    unzip \
    curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
 &&  unzip awscli-bundle.zip \
 && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

USER jenkins
ENV THUNDERBIRDS GO
