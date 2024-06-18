FROM nvcr.io/nvidia/tritonserver:24.05-vllm-python-py3

ENV STI_SCRIPTS_PATH=/usr/libexec/s2i
COPY s2i/bin/ ${STI_SCRIPTS_PATH}
COPY usr/ /usr/

### Setup user for build execution and application runtime
ENV APP_ROOT=/opt/app-root

# This is where we will mount a PV containing the model repository configuration folders
# Note - we use a sub directory /models/model_repository since Triton crashes on lost+found folder on default PV
# https://docs.nvidia.com/deeplearning/triton-inference-server/user-guide/docs/user_guide/model_repository.html
VOLUME [ "/models" ]

RUN chmod -R u+x ${STI_SCRIPTS_PATH} && \
    chgrp -R 0 ${STI_SCRIPTS_PATH} && \
    chmod -R g=u ${STI_SCRIPTS_PATH} && \
    mkdir -p ${APP_ROOT}/{bin,src} && \
    chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT}

ENV PATH=${APP_ROOT}/bin:${PATH} \
    HOME=${APP_ROOT} \
    MODEL_REPOSITORY=/models/model_repository

WORKDIR ${APP_ROOT}/src

USER 1001

ENV HOME=${APP_ROOT}/src

EXPOSE 8000 8001 8002

# ENTRYPOINT /opt/nvidia/nvidia_entrypoint.sh
CMD ${STI_SCRIPTS_PATH}/run
