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
    KERAS_VERSION=2ad3544b017fe9c0d7a25ef0640baa52281372b5

RUN pip --no-cache-dir install \
    https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-${TENSORFLOW_VERSION}-cp35-cp35m-linux_x86_64.whl \
    git+git://github.com/fchollet/keras.git@${KERAS_VERSION}

# Install Theano
RUN conda install six \
    && conda clean -tipsy
ENV THEANO_VERSION=rel-0.8.2
RUN pip install --upgrade --no-deps git+git://github.com/Theano/Theano.git@${THEANO_VERSION}
RUN echo "[global]\ndevice=gpu\nfloatX=float32\n[lib]\ncnmem=0.1\n[nvcc]\nfastmath=True" > /root/.theanorc
