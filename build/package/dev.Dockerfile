FROM golang:1.10

# install dep
RUN apt-get update \
 && apt-get install -y \
      ca-certificates \
 && curl https://raw.githubusercontent.com/golang/dep/master/install.sh \
      --output /tmp/install-dep.sh \
      --silent \
 && chmod a+x /tmp/install-dep.sh \
 && /tmp/install-dep.sh \
 && rm /tmp/install-dep.sh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install ruby, bundler, nokogiri(necessary for bundler install)
# zlib (necessary for nokogiri install)
# install wpscan and nmap as decker dependencies at runtime
# dnsutils - nslookup, dig, host
RUN apt-get update \
 && apt-get install -y \
      dnsutils \
      nmap \
      ruby-full \
      zlib1g-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && gem install nokogiri -v '1.8.5' --source 'https://rubygems.org/' \
 && gem install bundler \
 && git clone https://github.com/wpscanteam/wpscan /usr/bin/wpscan \
 && cd /usr/bin/wpscan/ \
 && bundle install \
 && rake install

# whois - whois plugin
# python-pip - sslyze plugin
RUN apt-get update \
 && apt-get install -y \
      python3 \
      python3-pip \
      python-pip \
      whois \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && pip install --upgrade setuptools \
 && pip install --upgrade sslyze \
 && pip3 install --upgrade setuptools

# The harvester download and dependencies
RUN git clone https://github.com/laramies/theHarvester.git /usr/bin/theHarvester \
 && pip3 install -r /usr/bin/theHarvester/requirements.txt

# DNSRecon download and Dependencies
RUN git clone https://github.com/darkoperator/dnsrecon.git /usr/bin/dnsrecon \
 && pip install -r /usr/bin/dnsrecon/requirements.txt

# Sublist3r
RUN git clone https://github.com/aboul3la/Sublist3r.git /usr/bin/Sublist3r \
 && pip3 install -r /usr/bin/Sublist3r/requirements.txt

# wafw00f
RUN git clone https://github.com/EnableSecurity/wafw00f.git /usr/bin/wafw00f \
 && cd /usr/bin/wafw00f \
 && python setup.py install

# WAFNinja
RUN git clone https://github.com/khalilbijjou/WAFNinja /usr/bin/WAFNinja \
 && pip install -r /usr/bin/WAFNinja/requirements.txt

# XssPy (discovered issue with the Pentagon)
RUN git clone https://github.com/faizann24/XssPy.git /usr/bin/XssPy \
 && pip install mechanize

# a2sv - auto scanning to SSL vulnerability
RUN git clone https://github.com/hahwul/a2sv.git /usr/bin/a2sv \
 && pip install -r /usr/bin/a2sv/requirements.txt

# sslscan
RUN apt-get update \
 && apt-get install -y \
      sslscan \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG APP_NAME=decker

WORKDIR /go/src/github.com/stevenaldinger/$APP_NAME

RUN go get -u golang.org/x/lint/golint

# COPY . .
#
# RUN dep ensure -v

CMD ["bash"]