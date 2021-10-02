.PHONY: after before

~/opencv.zip:
	wget -O ~/opencv.zip https://github.com/opencv/opencv/archive/4.4.0.zip

~/opencv_contrib.zip:
	wget -O ~/opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.4.0.zip

~/numpy-1.21.2.tar.gz:
	wget https://github.com/numpy/numpy/releases/download/v1.21.2/numpy-1.21.2.tar.gz

~/numpy-1.21.2: ~/numpy-1.21.2.tar.gz
	cd ~ && tar -xzvf numpy-1.21.2.tar.gz

~/scipy-1.7.1.tar.gz:
	wget https://github.com/scipy/scipy/releases/download/v1.7.1/scipy-1.7.1.tar.gz

~/scipy-1.7.1: scipy-1.7.1.tar.gz
	tar -xzvf scipy-v1.0.0.tar.gz

~/opencv: ~/opencv.zip
	cd ~ && unzip opencv.zip

~/opencv_contrib: ~/opencv_contrib.zip
	cd ~ && unzip opencv_contrib.zip

~/opencv/build: ~/opencv
	mkdir -p ~/opencv/build

before:
	echo "increase swap 100 to 2048"
	sudo sed -i 's/# CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/' /etc/dphys-swapfile
	echo "Restart the swap service"
	sudo /etc/init.d/dphys-swapfile stop
	sudo /etc/init.d/dphys-swapfile start

opencv: ~/opencv/build before
	cd ~/opencv/build && cmake \
	-D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib /
	modules \
	-D ENABLE_NEON=ON \
	-D ENABLE_VFPV3=ON \
	-D BUILD_TESTS=OFF \
	-D INSTALL_PYTHON_EXAMPLES=OFF \
	-D OPENCV_ENABLE_NONFREE=ON \
	-D CMAKE_SHARED_LINKER_FLAGS=-latomic \
	-D BUILD_EXAMPLES=OFF .. &&
	make -j2

numpy: ~/numpy-1.21.2 before
	cd ~/numpy && python3 setup.py build

scipy: ~/scipy-1.7.1 before
	python3 setup.py build

after: opencv numpy scipy
	echo "reset swap 2048 to 100"
	sudo sed -i 's/# CONF_SWAPSIZE=2048/CONF_SWAPSIZE=100/' /etc/dphys-swapfile
	echo "Restart the swap service"
	sudo /etc/init.d/dphys-swapfile stop
	sudo /etc/init.d/dphys-swapfile start

install: opencv
	cd ~/opencv/build && sudo make install && sudo ldconfig
