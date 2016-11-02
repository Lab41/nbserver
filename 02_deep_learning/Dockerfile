#FROM lab41/base_notebook
FROM l41-base-test

USER root

# Install git, bc and dependencies
RUN apt-get update && apt-get install -yq --no-install-recommends \
    software-properties-common \
    rsync \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER

# Install Tensorflow
ENV TENSORFLOW_VERSION 0.11.0rc2
ENV TF_BINARY_URL=https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-${TENSORFLOW_VERSION}-cp35-cp35m-linux_x86_64.whl
RUN pip --no-cache-dir install \
    $TF_BINARY_URL
