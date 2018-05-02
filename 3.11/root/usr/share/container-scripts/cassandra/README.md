Cassandra container
===================

This repository contains Dockerfiles for Cassandra images for general usage and OpenShift.
Currently only CentOS based image is available. The CentOS image is then available on
[Docker Hub](https://hub.docker.com/r/centos/cassandra-3-centos7/) as centos/cassandra-3-centos7.

Description
-----------

This container image provides a containerized packaging of the Cassandra daemon
and client application. The cassandra server daemon accepts connections from clients
and provides access to content from Cassandra databases on behalf of the clients.
You can find more information on the Cassandra project from the project Web site
(https://cassandra.apache.org/).

Usage
-----

For this, we will assume that you are using the `centos/cassandra-3-centos7` image.
If you want to set only the mandatory environment variables and store the database
in the `/home/user/database` directory on the host filesystem, execute the following command:

```
$ docker run -d -e CASSANDRA_ADMIN_PASSWORD=<password> -v /home/user/database:/var/opt/rh/sclo-cassandra3/lib/cassandra:Z centos/cassandra-3-centos7
```

Environment variables and Volumes
---------------------------------

The image recognizes the following environment variables that you can set during
initialization by passing `-e VAR=VALUE` to the Docker run command.

|    Variable name          |    Description                |
| :------------------------ | ---------------------------   |
|  CASSANDRA_ADMIN_PASSWORD | Password for the admin user   |


The following environment variables influence the Cassandra configuration file. They are all optional.

|    Variable name                            |    Description                                                       |    Default
| :------------------------------------------ | -------------------------------------------------------------------- | --------------
|  CASSANDRA_CLUSTER_NAME                     | The name of the cluster.                                             | 'Test Cluster'
|  CASSANDRA_DISK_OPTIMIZATION_STRATEGY       | The strategy for optimizing disk reads.                              | ssd
|  CASSANDRA_ENDPOINT_SNITCH                  | Cassandra uses the snitch to locate nodes and route requests.        | SimpleSnitch
|  CASSANDRA_NUM_TOKENS                       | Defines the number of tokens randomly assigned to this node.         | 256
|  CASSANDRA_RPC_ADDRESS                      | The listen address for client connections.                           | ' '
|  CASSANDRA_KEY_CACHE_SIZE_IN_MB             | Maximum size of the key cache in memory.                             | ' '
|  CASSANDRA_CONCURRENT_READS                 | Allows operations to queue low enough in the stack so that the OS and drives can reorder them.  | 32
|  CASSANDRA_CONCURRENT_WRITES                | Writes in Cassandra are rarely I/O bound, so the ideal number of concurrent writes depends on the number of CPU cores on the node. The recommended value is 8 × number_of_cpu_cores. | 32
|  CASSANDRA_MEMTABLE_ALLOCATION_TYPE         | The method Cassandra uses to allocate and manage memtable memory.    | 'heap_buffers'
|  CASSANDRA_MEMTABLE_CLEANUP_THRESHOLD       | Ratio used for automatic memtable flush.                             | 0.5
|  CASSANDRA_MEMTABLE_FLUSH_WRITERS           | The number of memtable flush writer threads.                         | 1
|  CASSANDRA_CONCURRENT_COMPACTORS            | Number of concurrent compaction processes allowed to run simultaneously on a node. | ' '
|  CASSANDRA_COMPACTION_THROUGHPUT_MB_PER_SEC | Throttles compaction to the specified Mb/second across the instance. | 16
|  CASSANDRA_COUNTER_CACHE_SIZE_IN_MB         | Maximum size of the counter cache in memory.                         | ' '
|  CASSANDRA_INTERNODE_COMPRESSION            | Controls whether traffic between nodes is compressed.                | all
|  CASSANDRA_GC_WARN_THRESHOLD_IN_MS          | Any GC pause longer than this interval is logged at the WARN level.  | 1000
|  CASSANDRA_AUTO_BOOTSTRAP                   | It causes new (non-seed) nodes migrate the right data to themselves automatically. | true

More details about each variable can be found at: http://docs.datastax.com/en/cassandra/3.0/cassandra/configuration/configCassandra_yaml.html

You can also set the following mount points by passing the `-v /host:/container` flag to Docker.

|  Volume mount point                        | Description              |
| :----------------------------------------- | ------------------------ |
|  /var/opt/rh/sclo-cassandra3/lib/cassandra | Cassandra data directory |

**Notice: When mouting a directory from the host into the container, ensure that the mounted
directory has the appropriate permissions and that the owner and group of the directory
matches the user UID or name which is running inside the container.**


Ports
-----

By default, Cassandra uses 7000 for cluster communication (7001 if SSL is enabled), 9042 for native protocol clients,
and 7199 for JMX. The internode communication and native protocol ports are configurable in the Cassandra Configuration
File (cassandra.yaml). The JMX port is configurable in cassandra-env.sh (through JVM options). All ports are TCP.


Documentation
-------------

See http://cassandra.apache.org/doc/latest/


Requirements
------------

* Memory: For production 32 GB to 512 GB; the minimum is 8 GB for Cassandra nodes. For development in non-loading
testing environments: no less than 4 GB.
* CPU: For production 16-core CPU processors are the current price-performance sweet spot. For development in
non-loading testing environments: 2-core CPU processors are sufficient.
* Disk space: SSDs are recommended for Cassandra nodes. The size depends on the compaction strategy used. With SSDs,
you can use a maximum of 3 to 5 TB per node of disk space for uncompressed data.
* Network: Recommended bandwidth is 1000 Mb/s (gigabit) or greater.

More on hardware requirements on https://docs.datastax.com/en/landing_page/doc/landing_page/planning/planningHardware.html


Custom configuration file
-------------------------

It is allowed to use custom configuration files for cassandra server.

To use custom configuration file in container it has to be mounted into `/etc/opt/rh/sclo-cassandra3/cassandra/cassandra.yaml`.
For example to use configuration file stored in `/home/user` directory use this option for `docker run` command:
`-v /home/user/cassandra.yaml:/etc/opt/rh/sclo-cassandra3/cassandra/cassandra.yaml:Z`.

To configure multiple JVM options a `jvm.options` file needs to be mounted into the container. For example to use
configuration file stored in `/home/user` directory use this option for
`docker run` command: `-v /home/user/jvm.options:/etc/opt/rh/sclo-cassandra3/cassandra/jvm.options:Z`.


Troubleshooting
---------------

The cassandra daemon in the container logs to the standard output, so the log is available in the container log. The log
can be examined by running:

docker logs <container>


See also
--------

Dockerfile and other sources for this container image are available on https://github.com/sclorg/cassandra-container.
In that repository, Dockerfile for CentOS is called Dockerfile, Dockerfile for RHEL (Work-in-progress) is called Dockerfile.rhel7.
