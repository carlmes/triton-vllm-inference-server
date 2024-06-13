FROM nvcr.io/nvidia/tritonserver:23.10-vllm-python-py3

ENV STI_SCRIPTS_PATH=/usr/libexec/s2i
COPY s2i/bin/ ${STI_SCRIPTS_PATH}
COPY usr/ /usr/

### Setup user for build execution and application runtime
ENV APP_ROOT=/opt/app-root

RUN mkdir -p ${APP_ROOT}/{bin,src,mnt/model_repository} && \
    chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT}

ENV PATH=${APP_ROOT}/bin:${PATH} \
    HOME=${APP_ROOT} \
    MODEL_REPOSITORY=${APP_ROOT}/mnt/model_repository

WORKDIR ${APP_ROOT}/src

# Install git lfs, as required for downloading from Huggingface
# https://huggingface.co/docs/hub/models-downloading#using-git
# https://github.com/git-lfs/git-lfs/wiki/Installation#debian-and-ubuntu 
RUN apt-get update && \
    apt-get install git-lfs && \
    git lfs install

USER 1001

ENV HOME=${APP_ROOT}/src

EXPOSE 8000 8001 8002

# ENTRYPOINT /opt/nvidia/nvidia_entrypoint.sh
CMD ${STI_SCRIPTS_PATH}/run