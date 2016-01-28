FROM jenkins:1.625.3
MAINTAINER Larry Murdock "larry@svds.com"
USER root


# install packages for javascript features run from shell scripts during deploys.
RUN apt-get update  && apt-get install -y \
    npm \
    nodejs-legacy \
    unzip \
    curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


# Install Amazon tools to push things to S3 and such.
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
 &&  unzip awscli-bundle.zip \
 && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# Install ChefDK to build chef solo bundles for deployment to our nodes.
RUN curl https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.10.0-1_amd64.deb -o chefdk_0.10.0-1_amd64.deb \
 && dpkg -i chefdk_0.10.0-1_amd64.deb

# https://issues.jenkins-ci.org/browse/JENKINS-31089 workaround
# changed disabledAlgoriths.  This work around was identified Oct 26, 2015
# Would like to get rid of this hack when we can.
COPY java.security /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security

USER jenkins
ENV THUNDERBIRDS GO
