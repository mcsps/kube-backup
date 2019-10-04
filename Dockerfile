FROM alpine:3.10

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
    py2-pip \
    libstdc++ \
    gpgme \
    libressl-dev \
    make \
    g++ \
    && \
  git clone https://github.com/AGWA/git-crypt.git && \
  make --directory git-crypt && \
  make --directory git-crypt install && \
  rm -rf git-crypt && \
  apk del libressl-dev make g++ && \
  rm -rf /var/cache/apk/*

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
