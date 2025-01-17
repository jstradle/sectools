FROM ubuntu:latest

ARG ARACHNI_VERSION=arachni-1.5.1-0.5.12

ENV DEBIAN_FRONTEND="noninteractive" TZ="America/Chicago"

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y

RUN apt-get install -y tzdata && \
    apt-get install -y build-essential \
      bzip2 \
      curl \
      gcc \
      git \
      libcurl4 \
      libcurl4-openssl-dev \
      wget \
      nano \
      sudo \
      zlib1g-dev \
      libfontconfig \
      libxml2-dev \
      libxslt1-dev \
      make \
      python3 \
      python3-dev \
      python3-pip \ 
      ruby \
      ruby-dev \
      ruby-bundler
     

# Install Security Testing Tools

# Gauntlt

RUN git clone https://github.com/gauntlt/gauntlt.git
RUN cp /gauntlt/bin/gauntlt /usr/local/bin/

WORKDIR /gauntlt/bin
RUN bundle install
RUN ./gauntlt -v
COPY /attacks /gauntlt/attacks

WORKDIR /opt

# W3AF

#FROM andresriancho/w3af .
RUN git clone https://github.com/andresriancho/w3af.git
RUN ln -s /w3af/w3af_console /usr/local/bin/

# arachni
RUN wget https://github.com/Arachni/arachni/releases/download/v1.5.1/${ARACHNI_VERSION}-linux-x86_64.tar.gz && \
    tar xzvf ${ARACHNI_VERSION}-linux-x86_64.tar.gz > /dev/null && \
    mv ${ARACHNI_VERSION} /usr/local && \
    ln -s /usr/local/${ARACHNI_VERSION}/bin/* /usr/local/bin/

# Nikto
RUN apt-get update && \
    apt-get install -y libtimedate-perl \
      libnet-ssleay-perl && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 https://github.com/sullo/nikto.git && \
    cd nikto/program && \
    echo "EXECDIR=/opt/nikto/program" >> nikto.conf && \
    ln -s /opt/nikto/program/nikto.conf /etc/nikto.conf && \
    chmod +x nikto.pl && \
    ln -s /opt/nikto/program/nikto.pl /usr/local/bin/nikto

# sqlmap
WORKDIR /opt
ENV SQLMAP_PATH /opt/sqlmap/sqlmap.py
RUN git clone --depth=1 https://github.com/sqlmapproject/sqlmap.git

# dirb
COPY vendor/dirb222.tar.gz dirb222.tar.gz

RUN tar xvfz dirb222.tar.gz > /dev/null && \
    cd dirb222 && \
    chmod 755 ./configure && \
    ./configure && \
    make && \
    ln -s /opt/dirb222/dirb /usr/local/bin/dirb

ENV DIRB_WORDLISTS /opt/dirb222/wordlists

# nmap
RUN apt-get update && \
    apt-get install -y nmap && \
    rm -rf /var/lib/apt/lists/*

# sslyze
#RUN pip install sslyze
#ENV SSLYZE_PATH /usr/local/bin/sslyze

WORKDIR /gauntlt/bin
#ENTRYPOINT [ "/usr/local/bin/gauntlt" ]
