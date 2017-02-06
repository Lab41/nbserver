#!/usr/bin/env bash

echo "---- environment ----"
env | sort

echo "---- group ----"
echo "Creating group: $L41_USER_GROUP ($L41_USER_GID)."
groupadd -g $L41_USER_GID $L41_USER_GROUP

echo "---- passwd ----"
set -e

if getent passwd $USER_ID > /dev/null ; then
    echo "$USER ($USER_ID) exists"
else
    echo "Creating user $USER ($USER_ID)."
    useradd -u $USER_ID -g $L41_USER_GROUP -s $SHELL -m $USER
    #useradd -u $USER_ID -G $L41_USER_GROUP -s $SHELL $USER
fi
# vv  /

echo "---- sudoers ----"
echo "[TEMP] Adding $USER to sudoers file."
echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} && chmod 0440 /etc/sudoers.d/${USER}

#echo "[TEMP] Changing permissions to /opt directory."
# To allow user to conda install and run pyspark.
#sudo chmod -R a+rwx /opt

echo "---- getting the GPU to work ----"
# If we need the GPU, this is required. It is harmless if we do not.
sudo ldconfig

echo "---- getting pyspark to work ----"
echo "[TEMP] Changing permissions to /var/opt directory."
sudo chmod -R a+rwx /var/opt

echo "[TEMP] Setting PYTHONPATH env var"
export PYTHONPATH="${SPARK_HOME}/python/:${PATH}"
for file in "${SPARK_HOME}/python/lib"/*
do
    export PYTHONPATH="${file}:${PYTHONPATH}"
done
echo $PYTHONPATH

echo "---- notebook args ----"
notebook_arg=""
if [ -n "${NOTEBOOK_DIR:+x}" ]
then
    notebook_arg="--notebook-dir=${NOTEBOOK_DIR}"
fi

echo "---- nopleats ----"

if [ -d /var/log/jupyterLogs ]
then
    for i in `(ls /var/log/jupyterLogs/)`; do rm /var/log/jupyterLogs/$i; done
else
    mkdir -p /var/log/jupyterLogs
fi

if [ -d /var/log/sparkLogs ]
then
    for i in `(ls /var/log/sparkLogs/)`; do rm /var/log/sparkLogs/$i; done
else
    mkdir -p /var/log/sparkLogs
fi

chmod -R 755 /opt/nopleats /var/log/jupyterLogs
sync
sudo -E /opt/nopleats/makeLoggingWork

echo "---- jupyterhub-singleuser ----"
echo "USER: $USER"
sudo -u $USER whoami
PERSISTENT_HOME=${L41_PERSISTENT_BASE:="/home/"}/${USER}
echo "PERSISTENT_HOME: $PERSISTENT_HOME"
sudo -u $USER mkdir -p $PERSISTENT_HOME
cd $PERSISTENT_HOME

echo "---- Theano ----"
THEANORC="${HOME}/.theanorc"
sudo -u $USER echo "[global]\ndevice=gpu0\nfloatX=float32\n[nvcc]\nfastmath=True" > $THEANORC

echo "---- Add front-end nbgallery integrations ----"
jupyter nbextension install --py jupyter_nbgallery
jupyter nbextension enable --py jupyter_nbgallery

sudo -E THEANO_FLAGS='floatX=float32,device=gpu0' \
    -E PATH="/usr/local/cuda/bin:/usr/local/nvidia/bin:${CONDA_DIR}/bin:$PATH" \
    -E PYTHONPATH="${PYTHONPATH}" \
    -E PYSPARK_SUBMIT_ARGS="${PYSPARK_SUBMIT_ARGS} pyspark-shell" \
    -u $USER /opt/conda/bin/jupyterhub-singleuser \
    --port=$NOTEBOOK_PORT \
    --ip=0.0.0.0 \
    --user=$JPY_USER \
    --cookie-name=$JPY_COOKIE_NAME \
    --base-url=$JPY_BASE_URL \
    --hub-prefix=$JPY_HUB_PREFIX \
    --hub-api-url=$JPY_HUB_API_URL \
    --config=/srv/ganymede_nbserver/jupyter_notebook_config.py \
    ${notebook_arg} #\
    #  $@ > /var/log/jupyterLogs/stdOut 2> /var/log/jupyterLogs/stdErr
