FROM alpine:latest

ENV ISTIO_VERSION 1.8.3

RUN apk update && apk add curl bash coreutils jq nginx ca-certificates && rm -rf /var/cache/apk/*

# Get Istio tar
RUN mkdir -p /usr/share/nginx/html/istio/istio/releases/download/${ISTIO_VERSION}
RUN curl -L https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-osx.tar.gz -o /usr/share/nginx/html/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-osx.tar.gz

# Get Istio
RUN curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} sh -
RUN mv istio-${ISTIO_VERSION}/bin/istioctl /usr/bin && chmod +x /usr/bin/istioctl

# Get kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
RUN mv ./kubectl /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# custom ssl
COPY nginx.conf /etc/nginx/nginx.conf
COPY ssl /home/ssl/

RUN mkdir -p /usr/local/share/ca-certificates/ /run/nginx/ && \
    cp -rf /home/ssl/cacerts.pem /usr/local/share/ca-certificates/cacerts.pem && \
    update-ca-certificates
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' >> /etc/nsswitch.conf

# Add scripts for Istio
COPY scripts /usr/local/app/scripts/
RUN chmod +x /usr/local/app/scripts/init_kubeconfig.sh \
    /usr/local/app/scripts/run.sh \
    /usr/local/app/scripts/create_istio_system.sh \
    /usr/local/app/scripts/uninstall_istio_system.sh \
    /usr/local/app/scripts/get_grafana_dashboards.sh

RUN mkdir -p /usr/local/app/dashboards && \
    /usr/local/app/scripts/get_grafana_dashboards.sh

ENTRYPOINT [ "/usr/local/app/scripts/run.sh" ]
