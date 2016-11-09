FROM lab41/logging-notebook

MAINTAINER Lab41

USER root

# Specify what version to use
ENV JAVA_VERSION=oracle-java8 \
    MESOS_VERSION=0.28.0-2.0.16.ubuntu1404 \
    SPARK_VERSION=2.0.1 \
    HADOOP_VERSION=2.6 \
    CDH_VERSION=5.6.0

# Install essential libraries
RUN apt-get update && apt-get install -yq --no-install-recommends \
    software-properties-common \
    wget \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Requirement 2: Install Mesos to communicate with Mesos Master Leader
# =============================================================================

# Install Mesos
RUN echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" > /etc/apt/sources.list.d/mesosphere.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
    apt-get update && apt-get install -yq --no-install-recommends \
    mesos=${MESOS_VERSION} \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# =============================================================================
# Requirement 3: Install Spark to run Spark Driver or Executor
# =============================================================================

# Install Oracle Java 8 and spark dependencies
# Java version does not have to match Master
RUN echo ${JAVA_VERSION}-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && apt-get install -yq --no-install-recommends \
    ${JAVA_VERSION}-installer \
    libnss3 \
    apt-transport-https \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Spark
ENV SPARK_DOWNLOAD_URL http://d3kbcqa49mib13.cloudfront.net/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
RUN curl ${SPARK_DOWNLOAD_URL} | tar -xzC /opt/

# Create directory for Spark's logs
ENV SPARK_LOG_DIR /var/opt/spark/logs/
ENV SPARK_EVENTLOG_DIR ${SPARK_LOG_DIR}/eventLog
RUN mkdir -p ${SPARK_LOG_DIR} ${SPARK_EVENTLOG_DIR}

ENV SPARK_HOME=/opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
ENV PATH=$PATH:${SPARK_HOME}/bin \
    PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.9-src.zip \
    MESOS_NATIVE_JAVA_LIBRARY=/usr/local/lib/libmesos.so

# =============================================================================4yy
# Requirement 4: Install CDH for Hadoop HDFS
# =============================================================================

# Specify what version of Cloudera Manager to use
ENV CLOUDERA_REPO_URL=https://archive.cloudera.com/cm5/ubuntu/trusty/amd64/cm/cloudera.list \
    CLOUDERA_REPO_KEY=http://archive.cloudera.com/cdh5/ubuntu/trusty/amd64/cdh/archive.key

# Add repository to fetch packages and add key
RUN cd /tmp && \
    wget http://archive.cloudera.com/cdh5/one-click-install/trusty/amd64/cdh5-repository_1.0_all.deb && \
    dpkg -i cdh5-repository_1.0_all.deb && \
    curl ${CLOUDERA_REPO_URL} -o /etc/apt/sources.list.d/cloudera-manager.list && \
    curl ${CLOUDERA_REPO_KEY} | apt-key add -

RUN apt-get update && apt-get install -yq --no-install-recommends \
    hadoop-client \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*
