FROM centos/s2i-core-centos7

# Cassandra image for CentOS.
#
# Volumes:
#  * /var/opt/rh/sclo-cassandra3/lib/cassandra - Datastore for Cassandra
# Environment:

ENV CASSANDRA_VERSION=3.11 \
    SUMMARY="Cassandra is an OpenSource database for high-scale application" \
    DESCRIPTION="Cassandra is a partitioned row store. Rows are organized \
into tables with a required primary key. Partitioning means that Cassandra can \
distribute your data across multiple machines in an application-transparent \
matter. Cassandra will automatically re-partition as machines are \
added/removed from the cluster. Row store means that like relational \
databases, Cassandra organizes data by rows and columns. The Cassandra Query \
Language (CQL) is a close relative of SQL." \
    # Set paths to avoid hard-coding them in scripts.
    HOME=/var/opt/rh/sclo-cassandra3/lib/cassandra \
    CASSANDRA_CONF_DIR=/etc/opt/rh/sclo-cassandra3/cassandra/ \
    CONTAINER_SCRIPTS_BASE=/usr/share/container-scripts \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/cassandra \
    ENABLED_COLLECTIONS="sclo-cassandra3 rh-java-common rh-maven33" \
    BASH_ENV="\${CONTAINER_SCRIPTS_PATH}/scl_enable" \
    ENV="\${CONTAINER_SCRIPTS_PATH}/scl_enable" \
    PROMPT_COMMAND=". \${CONTAINER_SCRIPTS_PATH}/scl_enable"

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$SUMMARY" \
      io.k8s.display-name="Cassandra $CASSANDRA_VERSION" \
      io.openshift.expose-services="7199:cassandra,9042:cql" \
      io.openshift.tags="database,cassandra,cassandra3" \
      name="centos/cassandra-311-centos7" \
      version="$CASSANDRA_VERSION" \
      com.redhat.component="rh-cassandra3-docker" \
      maintainer="SoftwareCollections.org <sclorg@redhat.com>"

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
EXPOSE 7000 7001 7199 9042

RUN INSTALL_PKGS="sclo-cassandra3 sclo-cassandra3-cassandra jemalloc" && \
    yum install -y centos-release-scl epel-release && \
    yum install --enablerepo=centos-sclo-sclo-testing -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all

ADD root /

COPY ./s2i/bin/ $STI_SCRIPTS_PATH

RUN chown -R cassandra $HOME $CONTAINER_SCRIPTS_BASE && \
    /usr/libexec/fix-permissions $HOME $CONTAINER_SCRIPTS_BASE $CASSANDRA_CONF_DIR /var/opt/rh/sclo-cassandra3/log/cassandra/ && \
    rpm-file-permissions

VOLUME ["$HOME"]

USER 143

ENTRYPOINT ["container-entrypoint"]
CMD ["run-cassandra"]
