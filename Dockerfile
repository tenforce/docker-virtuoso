FROM ubuntu:14.04

# Install Virtuoso prerequisites
RUN apt-get update \
        && apt-get install -y build-essential debhelper autotools-dev autoconf automake unzip wget net-tools git libtool flex bison gperf gawk m4 libssl-dev libreadline-dev libreadline-dev openssl

# Set Virtuoso commit SHA to Virtuoso 7.2 release (14/02/2015)
ENV VIRTUOSO_COMMIT a5e1f5bb055761c389ea50f8f8849b73e5241018 

# Get Virtuoso source code from GitHub and checkout specific commit
# Make and install Virtuoso (by default in /usr/local/virtuoso-opensource)
RUN git clone https://github.com/openlink/virtuoso-opensource.git \
        && cd virtuoso-opensource \
        && git checkout ${VIRTUOSO_COMMIT} \
        && ./autogen.sh \
        && CFLAGS="-O2 -m64" && export CFLAGS && ./configure --disable-bpel-vad --enable-conductor-vad --disable-dbpedia-vad --disable-demo-vad --disable-isparql-vad --disable-ods-vad --disable-sparqldemo-vad --disable-syncml-vad --disable-tutorial-vad --with-readline --program-transform-name="s/isql/isql-v/" \
        && make && make install \
        && ln -s /usr/local/virtuoso-opensource/var/lib/virtuoso/ /var/lib/virtuoso \
        && cd .. \
        && rm -r /virtuoso-opensource

# Add Virtuoso bin to the PATH
ENV PATH /usr/local/virtuoso-opensource/bin/:$PATH

# Add Virtuoso config
ADD virtuoso.ini /virtuoso.ini

# Add dump_nquads_procedure
ADD dump_nquads_procedure.sql /dump_nquads_procedure.sql

# Add Virtuoso log cleaning script
ADD clean-logs.sh /clean-logs.sh

# Add startup script
ADD startup.sh /startup.sh

WORKDIR /var/lib/virtuoso/db
EXPOSE 8890
EXPOSE 1111

CMD ["/bin/bash", "/startup.sh"]
