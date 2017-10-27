FROM jfloff/alpine-python:2.7
RUN pip install yq && \
  echo 'http://ghostbar.github.io/alpine-pkg-bats/v3.2/pkgs' >> /etc/apk/repositories && \
  apk --update --allow-untrusted add bats && \
  apk add --no-cache jq && \
  apk add --no-cache curl curl-dev && \
  apk add --no-cache openssh
ENTRYPOINT ["bats"]
CMD ["-v"]
