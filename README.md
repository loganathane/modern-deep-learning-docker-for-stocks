# Modern Deep Learning Docker Image

This is a modern environment for building deep learning applications. It has the latest *stable* versions of the most common tools and frameworks that you're likely to need.

Keep in mind that this image is big (3GB+). I considered dropping a few tools or creating different images with different toolsets, but I think that'll waste everyone's time. If you're doing deep learning then you probably have a lot of disk space anyway, and you're likely to prefer saving time over disk space.


## Included Libraries
- Ubuntu 16.04 LTS
- Python 3.5.2
- Tensorflow 1.0
- OpenCV 3.2
- Jupyter Notebook
- Numpy, Scipy, Scikit Learn, Scikit Image, Pandas, Matplotlib, Pillow and more.
- Caffe
- Keras 2.0.3
- Java JDK

TODO:
- Torch
- GPU/CUDA


## Runing the Docker Image

If you haven't yet, start by installing [Docker](https://www.docker.com/). It should take a few minutes. Then run this command at your terminal:

```
docker run -it -p 8888:8888 -p 6006:6006 -v ~/:/host loganathane/su-ml
```

Note the *-v* option. It maps your user directory (~/) to /host in the container. Change it if needed. The two *-p* options expose the ports used by Jupyter Notebook and Tensorboard respectively.
