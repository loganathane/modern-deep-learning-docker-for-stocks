FROM ubuntu:16.04
MAINTAINER Loganathane <loganathane.virassamy@gmail.com>

RUN apt-get update

# Supress warnings about missing front-end. As recommended at:
# http://stackoverflow.com/questions/22466255/is-it-possibe-to-answer-dialog-questions-when-installing-under-docker
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y --no-install-recommends apt-utils

# Developer Essentials
RUN apt-get install -y --no-install-recommends git curl vim unzip openssh-client wget

# Build tools
RUN apt-get install -y --no-install-recommends build-essential cmake

# OpenBLAS
RUN apt-get install -y --no-install-recommends libopenblas-dev

#
# Python 3.5
#
# For convenience, alisas (but don't sym-link) python & pip to python3 & pip3 as recommended in:
# http://askubuntu.com/questions/351318/changing-symlink-python-to-python3-causes-problems
RUN apt-get install -y --no-install-recommends python3.5 python3.5-dev python3-pip
RUN pip3 install --no-cache-dir --upgrade pip setuptools
RUN echo "alias python='python3'" >> /root/.bash_aliases
RUN echo "alias pip='pip3'" >> /root/.bash_aliases
# Pillow and it's dependencies
RUN apt-get install -y --no-install-recommends libjpeg-dev zlib1g-dev
RUN pip3 --no-cache-dir install Pillow
# Common libraries
RUN pip3 --no-cache-dir install \
    numpy scipy sklearn scikit-image pandas matplotlib

#
# Jupyter Notebook
#
RUN pip3 --no-cache-dir install jupyter


#
# Tensorflow 1.0 - CPU
#
RUN pip3 install --no-cache-dir --upgrade tensorflow

# Expose port for TensorBoard
EXPOSE 6006

#
# OpenCV 3.2
#
# Dependencies
RUN apt-get install -y --no-install-recommends \
    libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libgtk2.0-dev \
    liblapacke-dev checkinstall
# Get source from github
RUN git clone -b 3.2.0 --depth 1 https://github.com/opencv/opencv.git /usr/local/src/opencv
# Compile
RUN cd /usr/local/src/opencv && mkdir build && cd build && \
    cmake -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          -D PYTHON_DEFAULT_EXECUTABLE=$(which python3) \
          .. && \
    make -j"$(nproc)" && \
    make install

#
# Caffe
#
# Dependencies
RUN apt-get install -y --no-install-recommends \
    cmake libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev \
    libhdf5-serial-dev protobuf-compiler liblmdb-dev libgoogle-glog-dev
RUN apt-get install -y --no-install-recommends libboost-all-dev
# Get source. Use master branch because the latest stable release (rc3) misses critical fixes.
RUN git clone -b master --depth 1 https://github.com/BVLC/caffe.git /usr/local/src/caffe
# Python dependencies
RUN pip3 --no-cache-dir install -r /usr/local/src/caffe/python/requirements.txt
# Compile
RUN cd /usr/local/src/caffe && mkdir build && cd build && \
    cmake -D CPU_ONLY=ON -D python_version=3 -D BLAS=open -D USE_OPENCV=ON .. && \
    make -j"$(nproc)" all && \
    make install
# Enivronment variables
ENV PYTHONPATH=/usr/local/src/caffe/python:$PYTHONPATH \
	PATH=/usr/local/src/caffe/build/tools:$PATH
# Fix: old version of python-dateutil breaks caffe. Update it.
RUN pip3 install --no-cache-dir python-dateutil --upgrade

#
# Java
#
# Install JDK (Java Development Kit), which includes JRE (Java Runtime
# Environment). Or, if you just want to run Java apps, you can install
# JRE only using: apt install default-jre
RUN apt-get install -y --no-install-recommends default-jdk

#
# Keras
#
RUN pip3 install --no-cache-dir h5py keras

# Python packages
#
RUN pip --no-cache-dir install 'scikit-learn'
RUN pip --no-cache-dir install 'seaborn'
RUN pip --no-cache-dir install 'xgboost'
RUN pip --no-cache-dir install backtrader[plotting]
RUN pip --no-cache-dir install 'datetime'
RUN pip --no-cache-dir install 'fake_useragent'
RUN pip --no-cache-dir install 'requests'
RUN pip --no-cache-dir install 'beautifulsoup4'
RUN pip --no-cache-dir install 'argparse'
RUN pip --no-cache-dir install 'quandl'
RUN pip --no-cache-dir install 'pyfolio'
RUN pip --no-cache-dir install 'theano'
RUN pip --no-cache-dir install 'zipline'
RUN pip --no-cache-dir install 'multitasking'
RUN pip --no-cache-dir install 'fix_yahoo_finance'
RUN pip --no-cache-dir install 'cycler'
RUN pip --no-cache-dir install 'pyparsing'
RUN pip --no-cache-dir install 'pytz'
RUN pip --no-cache-dir install 'six'
RUN pip --no-cache-dir install 'tweepy'
RUN pip --no-cache-dir install 'textblob'
RUN pip --no-cache-dir install 'pyyaml'
RUN pip --no-cache-dir install 'yahoo_finance'


# RUN pip --no-cache-dir install 'pyalgotrade' #todo

# Copy the file to start the container
COPY start.sh /start.sh
RUN chmod a+x /start.sh

# Create nbuser user with UID=1000 and in the 'users' group
# RUN useradd -ms /bin/bash newuser
RUN useradd -ms /bin/bash nbuser && \
    echo "nbuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir /home/nbuser/notebooks && \
    mkdir /home/nbuser/.jupyter && \
    mkdir /home/nbuser/.local && \
    mkdir -p /home/nbuser/.ipython/profile_default/startup/ && \
    chown -Rf nbuser:users /home/nbuser

# Allow access from outside the container, and skip trying to open a browser.
# NOTE: disable authentication token for convenience. DON'T DO THIS ON A PUBLIC SERVER.
# RUN mkdir /root/.jupyter
# RUN echo "c.NotebookApp.ip = '*'" \
#          "\nc.NotebookApp.open_browser = False" \
#          "\nc.NotebookApp.token = ''" \
#          > /root/.jupyter/jupyter_notebook_config.py
# Run notebook without token
RUN echo "c.NotebookApp.token = u''" >> /home/nbuser/.jupyter/jupyter_notebook_config.py

EXPOSE 8888

#
# Cleanup
#
RUN apt-get clean && \
    apt-get autoremove

# todo
# RUN mkdir /home/nbuser/notebooks/mounted

# WORKDIR "/root"
WORKDIR /home/nbuser/notebooks

USER nbuser

CMD ["/start.sh", "tensorboard", "--logdir=/home/nbuser/notebooks/mounted"]
# CMD ["/bin/bash"]
