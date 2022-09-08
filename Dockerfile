FROM alpine:3.16

ENV VERSION 0.7.0

RUN apk update && \
  apk add --update \
    bash \
    easy-rsa \
    git \
    openssh-client \
    curl \
    ca-certificates \
    jq \
    python \
    py-yaml \
    py3-pip \
    libstdc++ \
    gpgme \
    libressl-dev \
    openssh \
    openssl \
    openssl-dev \
    make \
    g++ \
    && \
  rm -rf /var/cache/apk/*

RUN curl -L https://github.com/AGWA/git-crypt/archive/$VERSION.tar.gz | tar zxv -C /var/tmp
RUN cd /var/tmp/git-crypt-$VERSION && make && make install PREFIX=/usr/local
RUN apk del libressl-dev make g++

RUN pip install ijson awscli
RUN adduser -h /backup -D backup

ENV KUBECTL_VERSION 1.16.1
ENV KUBECTL_SHA256 69cfb3eeaa0b77cc4923428855acdfc9ca9786544eeaff9c21913be830869d29
ENV KUBECTL_URI https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl

RUN curl -SL ${KUBECTL_URI} -o kubectl && chmod +x kubectl

RUN echo "${KUBECTL_SHA256}  kubectl" | sha256sum -c - || exit 10
ENV PATH="/:${PATH}"

COPY entrypoint.sh /
USER backup
ENTRYPOINT ["/entrypoint.sh"]
