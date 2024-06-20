Taken from: https://github.com/coreweave/kubernetes-cloud/tree/master/online-inference/tensorizer-isvc/benchmark

## Running the benchmark

```sh
$ python benchmark/load_test.py --kserve --url=<ISVC_URL> --requests=<NUMBER_OF_REQUESTS>
```

`load_test.py` defaults to running async requests with `[aiohttp](https://pypi.org/project/aiohttp/)`

`--sync` may be added to the command line to instead send requests sequentially using `[requests](https://pypi.org/project/requests/)`
