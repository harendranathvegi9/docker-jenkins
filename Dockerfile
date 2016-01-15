FROM jenkins:1.625.3
MAINTAINER Larry Murdock "larry@svds.com"

USER root
RUN apt-get update \
      && apt-get install -y npm && apt-get install -y node

USER jenkins
ENV THUNDERBIRDS GO

