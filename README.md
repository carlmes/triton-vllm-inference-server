# triton-vllm-inference-server
Container project for NVIDIA Triton using vLLM backend

## Downloading Models

Download the various models to a location on disk. On a local machine, this directory will be attached to the container using podman arguments, the on an OpenShift cluster it will be a Persistent Volume. For example, here's how to download the Llama-2-7b model:
```sh
$ mkdir ~/Downloads/model_registry && cd ~/Downloads/model_registry

$ git clone https://${HUGGING_FACE_HUB_USER}:${HUGGING_FACE_HUB_TOKEN}@huggingface.co/meta-llama/Llama-2-7b-hf 
```

> Note: vLLM requires models in [Hugging Face Transformer Format](https://docs.vllm.ai/en/stable/models/supported_models.html#supported-models), this is why we pick Llama-2-7b-hf over Llama-2-7b, which doesn't have the model in a supported format for serving using vLLM. The Llama models can be downloaded from meta by following these instructions: https://github.com/meta-llama/llama#download, however they will not be in a supported format.

Next, we add some configuration files into the model_repository location on disk to identify our model(s). For reference, see the [example model repository](https://github.com/triton-inference-server/vllm_backend/tree/main/samples/model_repository), instructions on the [vLLM backend](https://github.com/triton-inference-server/vllm_backend/blob/main/README.md#using-the-vllm-backend) repo as well as the [Triton Quickstart Guide](https://github.com/triton-inference-server/tutorials/blob/main/Quick_Deploy/vLLM/README.md#step-1-prepare-your-model-repository).

```
model_repository (provide this dir as source / MODEL_REPOSITORY )
└── vllm_model
    ├── 1
    │   └── model.json
    ├── Llama-2-7b-hf
    │   └── model files...
    └── config.pbtxt
```

Here are example files that work with the Llama-2-7B-hf model:

**model.json**
```json

{
    "model": "/opt/app-root/model_repository/vllm_model/Llama-2-7b-hf",
    "disable_log_requests": "true",
    "gpu_memory_utilization": 1
}
```

**config.pbtxt**
```
backend: "vllm"

instance_group [
  {
    count: 1
    kind: KIND_MODEL
  }
]

model_transaction_policy {
  decoupled: True
}

max_batch_size: 0

# https://github.com/triton-inference-server/server/issues/6578#issuecomment-1813112797
# Note: The vLLM backend uses the following input and output names.
# Any change here needs to also be made in model.py

input [
  {
    name: "text_input"
    data_type: TYPE_STRING
    dims: [ 1 ]
  },
  {
    name: "stream"
    data_type: TYPE_BOOL
    dims: [ 1 ]
  },
  {
    name: "sampling_parameters"
    data_type: TYPE_STRING
    dims: [ 1 ]
    optional: true
  }
]

output [
  {
    name: "text_output"
    data_type: TYPE_STRING
    dims: [ -1 ]
  }
]
```

> Note: Configuration extracted from: https://github.com/triton-inference-server/server/issues/6578

## Building and Running Locally using Podman

```sh
$ podman build -t "triton-vllm-inference-server" . 
```

```sh
$ mkdir $HOME/Downloads/model_repository

$ podman run --rm -p 8000:8000 --name "triton-vllm-inference-server" -v $HOME/Downloads/model_repository:/opt/app-root/model_repository --shm-size=1G --ulimit memlock=-1 --ulimit stack=67108864 --gpus all triton-vllm-inference-server
```


Alternative direct run, from 
```sh
$ podman run --env HUGGING_FACE_HUB_TOKEN=$HUGGING_FACE_HUB_TOKEN -it --net=host --rm -p 8001:8001 --shm-size=1G --ulimit memlock=-1 --ulimit stack=67108864 -v ${PWD}:/work -w /work nvcr.io/nvidia/tritonserver:23.10-vllm-python-py3 tritonserver --model-store ./model_repository
```

## Building on Quay, Running using OpenShift

> Note: Under Construction

See examples at: https://github.com/codekow/s2i-patch/blob/main/s2i-triton/README.md

> TODO: Add instructions for creating a Deployment, defining a PV and binding to the pod, creating a service and route. Also securityContext for read write access on PV

Once the pod is started, copy the contents of the `model_repository` to the PV bound to the running pod:

```sh
$  oc rsync ~/Downloads/model_repository triton-vllm-inference-server-784d54f45f-jwr25:/opt/app-root/ --strategy=tar --progress=true
```

Testing the running instance
```sh
$ curl -X POST https://triton-vllm-inference-server-triton-vllm-inference-server.apps.cluster-4b2f6.sandbox888.opentlc.com/v2/models/vllm_model/generate -d '{"text_input": "What is Triton Inference Server?", "parameters": {"stream": false, "temperature": 0}}'
```

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
