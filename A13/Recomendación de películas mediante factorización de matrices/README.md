# movielens

## Requirements

- Python 3.7 

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r movielens/requirements.txt
pip install https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-1.9.0-py3-none-any.whl
```


If you use Python 3.7, update right in `pywrap_tensorflow_internal.py` async for async1:

```bash
def TFE_ContextSetAsyncForThread(arg1, async1):
    return _pywrap_tensorflow_internal.TFE_ContextSetAsyncForThread(arg1, async1)

def TFE_ContextOptionsSetAsync(arg1, async1):
    return _pywrap_tensorflow_internal.TFE_ContextOptionsSetAsync(arg1, async1)
```
