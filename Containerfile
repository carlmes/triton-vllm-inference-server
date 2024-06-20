FROM nvcr.io/nvidia/tritonserver:24.05-vllm-python-py3

ENV STI_SCRIPTS_PATH=/usr/libexec/s2i
COPY s2i/bin/ ${STI_SCRIPTS_PATH}
COPY usr/ /usr/

### Setup user for build execution and application runtime
ENV APP_ROOT=/opt/app-root

RUN chmod -R u+x ${STI_SCRIPTS_PATH} && \
    chgrp -R 0 ${STI_SCRIPTS_PATH} && \
    chmod -R g=u ${STI_SCRIPTS_PATH} && \
    mkdir -p ${APP_ROOT}/{bin,src} && \
    chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT}

# These volumes contain the model(s) that Triton will host:
# - /models contains the actual models, as downloaded from model registry
# - /model_repository contains the Triton model repository configuration
# Note - we use a sub directory in /model_repository since Triton crashes on lost+found folder on default PV
# https://docs.nvidia.com/deeplearning/triton-inference-server/user-guide/docs/user_guide/model_repository.html
VOLUME [ "/opt/app-root/models", "/opt/app-root/model_repository" ]

USER 1001

# We will use the model_repository PV as our user home directory, allowing
# Triton to persist model caches for subsequent fast startup.
WORKDIR ${APP_ROOT}/model_repository

ENV PATH=${APP_ROOT}/bin:${PATH} \
    HOME=${APP_ROOT}/model_repository \
    MODEL_REPOSITORY=${APP_ROOT}/model_repository \
    MODEL_SOURCE=${APP_ROOT}/models

# 8000: REST Interface
# 8001: gRPC Interface
# 8002: Model performance monitoring
EXPOSE 8000 8001 8002

# ENTRYPOINT /opt/nvidia/nvidia_entrypoint.sh
CMD ${STI_SCRIPTS_PATH}/run
