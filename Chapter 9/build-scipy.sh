# TL;DR: increase swap space

# don't use pip for numpy and scipy.
# get the latest version of scipy on the raspberry Pi you need to build from source.

# The reason is that scipy relies on compiled C and fortran libraries,
# that need to be compiled on the same architecture.

# Usually pip install would fetch prebuilt packages for you,
# but Raspberry Pi's ARM architecture is not really supported.

# there is an additional problem with the raspberry pi: the small amount of memory available.

# Requirements
# There are a few requirements for building scipy.
# As far as python packages go, you'll need numpy, cython, setuptools, and
# (if you want to build the documentation) Sphinx.

# You should try and use the version of these packages that comes with Raspbian
# (in packages such as python3-numpy), but they might need to be built separately (OT).
# As far as system requirements go, you'll need a few packages that can be installed with apt-get, namely:
# A BLAS/LAPACK math library with development headers, e.g. C and Fortran compilers,
sudo apt install \
libopenblas-base \
libopenblas-dev \
python-dev \
gcc \
gfortran

# Finally you need the source code, that you can download from here
# (Scipy 1.0.0 is the latest stable version as I am writing).
wget https://github.com/scipy/scipy/releases/download/v1.7.1/scipy-1.7.1.tar.gz
tar -xzvf scipy-v1.0.0.tar.gz

# Compiling the source
# At this point, if you start the build process, it will seem to go fine, but it will hang after a few minutes.
# Adding bigger swap space
# This is due to the compiling script occupying the totality of both RAM and swap memory by spawning multiple processes
# (and replicating memory by consequence).
# The problem is that in the Raspberry Pi the swap space is particularly small (only 100MB I think),
# while the norm would be to have it the same size of your RAM.
# As explained here and here, swap space can be increased typing the following:
# which will give you 1GB of swap space.

sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
sudo /sbin/mkswap /var/swap.1
sudo chmod 600 /var/swap.1
sudo /sbin/swapon /var/swap.1

# Then one can finally build and install with
cd scipy
python3 setup.py build
python3 setup.py install

# Finally, one remove the extra swap and restore the default:
sudo swapoff /var/swap.1
sudo rm /var/swap.1
