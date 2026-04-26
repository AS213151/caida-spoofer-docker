FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Added 'jq' to the list of packages
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    whois \
    jq \
    msmtp \
    msmtp-mta \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Add the official CAIDA Spoofer PPA and install the client
RUN add-apt-repository ppa:spoofer-dev/spoofer -y \
    && apt-get update \
    && apt-get install -y spoofer \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["spoofer-prober", "-s1", "-r1"]

