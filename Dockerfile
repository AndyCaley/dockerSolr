FROM    java:openjdk-8-jre

RUN apt-get update && \
  apt-get -y install lsof && \
  rm -rf /var/lib/apt/lists/*

ENV SOLR_USER solr
ENV SOLR_UID 8983

RUN groupadd -r $SOLR_USER && \
  useradd -r -u $SOLR_UID -g $SOLR_USER $SOLR_USER


ENV SOLR_VERSION 4.8.1

RUN mkdir -p /opt/solr && \
  wget -nv --output-document=/opt/solr.tgz http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz && \
  wget -nv --output-document=/opt/solr.tgz.asc http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz.asc && \
  tar -C /opt/solr --extract --file /opt/solr.tgz --strip-components=1 && \
  rm /opt/solr.tgz* && \
  mkdir -p /opt/solr/server/solr/lib && \
  chown -R $SOLR_USER:$SOLR_USER /opt/solr

# https://issues.apache.org/jira/browse/SOLR-8107
RUN sed --in-place -e 's/^    "$JAVA" "${SOLR_START_OPTS\[@\]}" $SOLR_ADDL_ARGS -jar start.jar "${SOLR_JETTY_CONFIG\[@\]}"/    exec "$JAVA" "${SOLR_START_OPTS[@]}" $SOLR_ADDL_ARGS -jar start.jar "${SOLR_JETTY_CONFIG[@]}"/' /opt/solr/bin/solr

EXPOSE 8983
WORKDIR /opt/solr
USER $SOLR_USER
CMD ["/opt/solr/bin/solr", "-f"]