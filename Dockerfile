FROM ubuntu:latest

ARG ARACHNI_VERSION=arachni-1.5.1-0.5.12

#ADD tzdata.sh /tzdata.sh
#RUN /tzdata.sh

ENV DEBIAN_FRONTEND="noninteractive" TZ="America/Chicago"

#RUN DEBIAN_FRONTEND="noninteractive" apt-get install tzdata
RUN apt-get update && apt-get install -y tzdata \
#    apt-get install -y build-essential \
      bzip2 \
#      ca-certificates \
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
#RUN gem install bundler
#COPY /examples /gauntlt/examples
COPY /attacks /gauntlt/attacks
#COPY bundle_install.sh /tmp
#RUN /bin/bash -c "/tmp/bundle_install.sh"
#ADD Gemfile $APP_HOME/Gemfile
#ADD Gemfile.lock $APP_HOME/Gemfile.lock
#RUN bundler install
#RUN bundler exec rake
COPY bundle_install.sh /opt
WORKDIR /opt

# W3AF

#FROM andresriancho/w3af .
RUN git clone https://github.com/andresriancho/w3af.git
#RUN ln -s /w3af/w3af_console /usr/local/bin/


#RUN git clone https://github.com/Arachni/arachni.git

#RUN git clone https://github.com/sullo/nikto.git

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

#ENTRYPOINT [ "/usr/local/bin/gauntlt" ]
