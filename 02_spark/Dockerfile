FROM lab41/base_notebook

MAINTAINER Lab41

USER root

# Specify what version to use
ENV JAVA_VERSION oracle-java8
ENV MESOS_VERSION 0.28.0-2.0.16.ubuntu1404
ENV SPARK_VERSION 1.6.1
ENV HADOOP_VERSION 2.6
ENV CDH_VERSION 5.6.0

# Install essential libraries
RUN apt-get -y update && \
    apt-get -y install software-properties-common && \
    apt-get -y install wget curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Requirement 2: Install Mesos to communicate with Mesos Master Leader
# =============================================================================

# Install Mesos
RUN echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" > /etc/apt/sources.list.d/mesosphere.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
    apt-get -y update && \
    apt-get -y install mesos=${MESOS_VERSION} && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Requirement 3: Install Spark to run Spark Driver or Executor
# =============================================================================

# Install Oracle Java 8
# Java version does not have to match Master
RUN echo ${JAVA_VERSION}-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get -y update && \
    apt-get -y install ${JAVA_VERSION}-installer && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Spark's dependencies
RUN apt-get install -y python libnss3

# Install Spark
ENV SPARK_DOWNLOAD_URL http://d3kbcqa49mib13.cloudfront.net/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
RUN curl ${SPARK_DOWNLOAD_URL} | tar -xzC /opt/

# Create directory for Spark's logs
ENV SPARK_LOG_DIR /var/opt/spark/logs/
ENV SPARK_EVENTLOG_DIR ${SPARK_LOG_DIR}/eventLog
RUN mkdir -p ${SPARK_LOG_DIR}
RUN mkdir -p ${SPARK_EVENTLOG_DIR}

ENV SPARK_HOME /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
ENV PATH $PATH:${SPARK_HOME}/bin
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.9-src.zip
ENV MESOS_NATIVE_JAVA_LIBRARY /usr/local/lib/libmesos.so

# Util to help with kernel spec later
RUN apt-get -y update && apt-get -y install jq apt-transport-https && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python 2 kernel spec into the Python 3 conda environment which
# runs the notebook server
RUN bash -c '. activate python2 && \
    python -m ipykernel.kernelspec --prefix=$CONDA_DIR && \
    . deactivate'
# Set PYSPARK_HOME in the python2 spec
RUN jq --arg v "$CONDA_DIR/envs/python2/bin/python" \
    '.["env"]["PYSPARK_PYTHON"]=$v' \
    $CONDA_DIR/share/jupyter/kernels/python2/kernel.json > /tmp/kernel.json && \
    mv /tmp/kernel.json $CONDA_DIR/share/jupyter/kernels/python2/kernel.json

# =============================================================================4yy
# Requirement 4: Install CDH for Hadoop HDFS
# =============================================================================

# Specify what version of Cloudera Manager to use
ENV CLOUDERA_REPO_URL https://archive.cloudera.com/cm5/ubuntu/trusty/amd64/cm/cloudera.list
ENV CLOUDERA_REPO_KEY http://archive.cloudera.com/cdh5/ubuntu/trusty/amd64/cdh/archive.key

# Add repository to fetch packages and add key
RUN cd /tmp && \
    wget http://archive.cloudera.com/cdh5/one-click-install/trusty/amd64/cdh5-repository_1.0_all.deb && \
    dpkg -i cdh5-repository_1.0_all.deb
RUN curl ${CLOUDERA_REPO_URL} -o /etc/apt/sources.list.d/cloudera-manager.list
RUN curl ${CLOUDERA_REPO_KEY} | apt-key add -

# Install Hadoop
#RUN apt-get -y update && apt-get -y install apt-transport-https && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get -y update && \
    apt-get -y install hadoop-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# =============================================================================
# Requirement 8: Install Python dependencies
# =============================================================================

# Place the list of python dependencies and the script to install them in /tmp
ADD dependencies/python/install-python-dependencies.sh /tmp
ADD dependencies/python/python-dependencies.txt /tmp

# Set PYDEP_PATH to be used later in the script
ENV PYDEP_PATH /tmp/python-dependencies.txt

# Run the script
RUN chmod +x /tmp/install-python-dependencies.sh
RUN /tmp/install-python-dependencies.sh

# Clean up
RUN rm /tmp/install-python-dependencies.sh /tmp/python-dependencies.txt

USER $NB_USER
