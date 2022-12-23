FROM ubuntu:22.04
LABEL user="boy_clever"

EXPOSE 3000

ENV DEBIAN_FRONTEND=noninteractive \
    USER=ubuntu \
    PASS=ubuntu

# no Upstart or DBus
# https://github.com/dotcloud/docker/issues/1724#issuecomment-26294856
RUN apt-get update && apt-mark hold initscripts udev plymouth mountall && \
    dpkg-divert --local --rename --add /sbin/initctl && ln -fs /bin/true /sbin/initctl && \
    apt-get install -yqq --no-install-recommends \
      openssh-server \
      pwgen \
      sudo \
      vim-tiny \
      ca-certificates \
      curl

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install nodejs

COPY ./package* /src/

WORKDIR /src

# Install build-time requirements, where compilation is needed
RUN apt-get install -yqq \
      build-essential \
      python \
    && \
    npm i && \
    # Perform extensive cleanup
    apt-get remove -y \
      build-essential \
      python \
    && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/{cache,log}/ && \
    rm -rf /var/lib/apt/lists/*.lz4 && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /usr/share/doc/ && \
    rm -rf /usr/share/man/

COPY ./src/* /src/

CMD ["/src/startup.sh"]
