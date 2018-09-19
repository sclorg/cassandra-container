Apache Cassandra Database Server Docker Image
=============================================

This repository contains Dockerfiles for Apache Cassandra images for OpenShift and general usage.
Currently only CentOS based image is available. RHEL based image will be available soon.

For more information about using these images with OpenShift, please see the
official [OpenShift Documentation](https://docs.okd.io/latest/using_images/other_images/other_container_images.html).

For more information about contributing, see
[the Contribution Guidelines](https://github.com/sclorg/welcome/blob/master/contribution.md).
For more information about concepts used in these docker images, see the
[Landing page](https://github.com/sclorg/welcome).


Versions
--------
Apache Cassandra currently provided are:
* [Cassandra 3.11](3.11)

CentOS versions currently supported are:
* CentOS7


Installation
----------------------

*  **CentOS7 based image**

    This image is available on DockerHub. To download it run:

    ```
    $ docker pull centos/cassandra-311-centos7
    ```

    To build a CentOS based Cassandra image from scratch, run:

    ```
    $ git clone --recursive https://github.com/sclorg/cassandra-container.git
    $ cd cassandra-container
    $ git submodule update --init
    $ make build TARGET=centos7 VERSIONS=3.11
    ```

**Notice: By omitting the `VERSIONS` parameter, the build/test action will be performed
on all provided versions of Cassandra, which must be specified in  `VERSIONS` variable.
This variable must be set to a list with possible versions (subdirectories).**


Usage
---------------------------------

For information about usage of Dockerfile for Cassandra 3.11,
see [usage documentation](3.11).


Test
---------------------------------

This repository also provides a test framework, which checks basic functionality
of the Cassandra image.

*  **CentOS based image**

    ```
    $ cd cassandra-container
    $ git submodule update --init
    $ make test TARGET=centos7 VERSIONS=3.11
    ```

**Notice: By omitting the `VERSIONS` parameter, the build/test action will be performed
on all provided versions of Cassandra, which must be specified in  `VERSIONS` variable.
This variable must be set to a list with possible versions (subdirectories).**
