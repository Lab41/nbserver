FROM lab41/logging-notebook

MAINTAINER Lab41

USER root

# Install git, bc and dependencies
RUN apt-get update && apt-get install -yq --no-install-recommends \
    software-properties-common \
    rsync \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Tensorflow and Keras
ENV TENSORFLOW_VERSION=0.11.0 \
    KERAS_VERSION=1.1.*

RUN pip --no-cache-dir install \
    https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-${TENSORFLOW_VERSION}-cp35-cp35m-linux_x86_64.whl \
    "keras==${KERAS_VERSION}"

# Link the CUDA drivers so TensorFlow can find them
RUN  ln -s /usr/local/cuda/lib64/libcudnn.so.5 /usr/local/cuda/lib64/libcudnn.so
