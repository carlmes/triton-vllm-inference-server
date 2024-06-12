# triton-vllm-inference-server
Container project for NVIDIA Triton using vLLM backend

## Building and Running Locally using Podman

```sh
$ podman build -t "triton-vllm-inference-server" . 
```

```sh
$ mkdir $HOME/Downloads/model_repository

$ podman run --rm -p 8000:8000 --name "triton-vllm-inference-server" -v $HOME/Downloads/model_repository:/opt/app-root/models --env HUGGING_FACE_HUB_TOKEN=$HUGGING_FACE_HUB_TOKEN --shm-size=1G --ulimit memlock=-1 --ulimit stack=67108864 --gpus all triton-vllm-inference-server
```

HuggingFace Tokens: https://huggingface.co/settings/tokens

Alternative direct run, from https://github.com/triton-inference-server/server/issues/6578
```sh
$ podman run --env HUGGING_FACE_HUB_TOKEN=$HUGGING_FACE_HUB_TOKEN -it --net=host --rm -p 8001:8001 --shm-size=1G --ulimit memlock=-1 --ulimit stack=67108864 -v ${PWD}:/work -w /work nvcr.io/nvidia/tritonserver:23.10-vllm-python-py3 tritonserver --model-store ./model_repository
```

## Building on Quay, Running using OpenShift

> Note: Under Construction

See examples at: https://github.com/codekow/s2i-patch/blob/main/s2i-triton/README.md

## Running using Run:AI

> Note: Under Construction

## References

* Triton Inference Server: [vLLM Backend](https://github.com/triton-inference-server/vllm_backend)
* NVIDIA NGC Catalog: [Triton Inference Server](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/tritonserver) (search tags for "vllm")
* NVIDIA Docs: [Triton Inference Server Quickstart](https://docs.nvidia.com/deeplearning/triton-inference-server/user-guide/docs/getting_started/quickstart.html)
* Github: [NVIDIA Triton Inference Server Organization](https://github.com/triton-inference-server/)
  + [Deploying a vLLM model in Triton](https://github.com/triton-inference-server/tutorials/blob/main/Quick_Deploy/vLLM/README.md#deploying-a-vllm-model-in-triton)
* Run:AI: Sample [Triton Inference Server](https://github.com/run-ai/runai-samples/tree/main/Dockerfiles/Triton%20Inference%20Server)
* Run:AI: [Quickstart: Launch an Inference Workload](https://docs.run.ai/v2.17/Researcher/Walkthroughs/quickstart-inference/)

## Additional Links
  
- https://github.com/codekow/s2i-patch/tree/main/s2i-triton
- https://docs.vllm.ai/en/latest/index.html
- https://github.com/triton-inference-server/vllm_backend
- https://catalog.ngc.nvidia.com/orgs/nvidia/containers/tritonserver/tags
- https://github.com/microsoft/DeepSpeed
- https://gitlab.consulting.redhat.com/ai-practice/awesome-ai-discovery/-/blob/master/LLMs/vLLM%20Reference%20Implementation.adoc?ref_type=heads
- https://github.com/rh-aiservices-bu/llm-on-openshift/blob/main/llm-servers/vllm/README.md
- https://github.com/redhat-na-ssa/demo-ocp-gpu/blob/main/containers/udi-cuda/ubi8/Dockerfile
- https://catalog.ngc.nvidia.com/orgs/nvidia/containers/tritonserver/tags
- https://github.com/triton-inference-server/vllm_backend
- https://github.com/run-ai/runai-samples/blob/main/Dockerfiles/Triton%20Inference%20Server/Dockerfile
- https://github.com/triton-inference-server/server
- Downloading a model from HugguingFace: https://github.com/cfchase/basic-kserve-vllm/blob/main/1_download_save.ipynb
