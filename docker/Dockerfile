FROM golang:alpine

RUN apk add --no-cache git

RUN mkdir -p /go/src/github.com/norova

WORKDIR /go/src/github.com/norova
RUN git clone https://github.com/norova/coreos-ipxe-server.git

WORKDIR /go/src/github.com/norova/coreos-ipxe-server
RUN go install

RUN mkdir -p /opt/coreos-ipxe-server
ADD configs /opt/coreos-ipxe-server/configs
ADD images /opt/coreos-ipxe-server/images
ADD profiles /opt/coreos-ipxe-server/profiles
ADD sshkeys /opt/coreos-ipxe-server/sshkeys

ENV COREOS_IPXE_SERVER_DATA_DIR /opt/coreos-ipxe-server
ENV COREOS_IPXE_SERVER_BASE_URL pp-rancher01.prp.local:4777
ENV COREOS_IPXE_SERVER_LISTEN_ADDR 0.0.0.0:4777

CMD /go/bin/coreos-ipxe-server