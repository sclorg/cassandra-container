FROM centos:centos7

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
Language (CQL) is a close relative of SQL."

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$SUMMARY" \
      io.k8s.display-name="Cassandra $CASSANDRA_VERSION" \
      io.openshift.expose-services="7199:cassandra" \
      io.openshift.tags="database,cassandra,cassandra311" \
      name="centos/cassandra-311-centos7" \
      version="$CASSANDRA_VERSION" \
      release="1" \
      com.redhat.component="rh-cassandra311-docker" \
      maintainer="SoftwareCollections.org <sclorg@redhat.com>"

ENV CASSANDRA_VERSION=3.11 \
    # Set paths to avoid hard-coding them in scripts.
    HOME=/var/opt/rh/sclo-cassandra3/lib/cassandra \
    CASSANDRA_CONF_DIR=/etc/opt/rh/sclo-cassandra3/cassandra/ \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/cassandra \
    ENABLED_COLLECTIONS="sclo-cassandra3 rh-java-common rh-maven33" \
    BASH_ENV="\${CONTAINER_SCRIPTS_PATH}/scl_enable" \
    ENV="\${CONTAINER_SCRIPTS_PATH}/scl_enable" \
    PROMPT_COMMAND=". \${CONTAINER_SCRIPTS_PATH}/scl_enable"

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
EXPOSE 7000 7001 7199 9042

ADD root /

RUN INSTALL_PKGS="sclo-cassandra3 sclo-cassandra3-cassandra jemalloc" && \
    yum install -y centos-release-scl && \
    yum install -y epel-release && \
    yum-config-manager --add-repo https://cbs.centos.org/repos/sclo7-sclo-cassandra3-sclo-candidate/x86_64/os/ && \
    echo gpgcheck=0 >> /etc/yum.repos.d/cbs.centos.org_repos_sclo7-sclo-cassandra3-sclo-candidate_x86_64_os_.repo && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all

VOLUME ["/var/opt/rh/sclo-cassandra3/lib/cassandra"]

USER 143

ENTRYPOINT ["container-entrypoint"]
CMD ["run-cassandra"]
