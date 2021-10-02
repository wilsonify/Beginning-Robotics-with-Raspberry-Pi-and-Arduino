# 1. Log on to your Raspberry Pi.
# 2. Open a terminal window on the Pi.
# 3. Download the OpenCV source code and the OpenCV contributed files.
# The contributed files contain a lot of functionality not yet rolled into the main OpenCV distribution:
cd ~
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.4.0.zip
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.4.0.zip
unzip opencv.zip
unzip opencv_contrib.zip
mv opencv-4.4.0 opencv
mv opencv_contrib-4.4.0 opencv_contrib
# 4. Install the Python development libraries and pip:
sudo apt-get install python3-dev
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
# 5. Make sure that NumPy is installed:
pip install numpy

# 6. Increase the memory allocated for swap.
# The compilation of these libraries is very memory intensive.
# The likelihood of your Pi hanging due to memory issues is greatly reduced by doing this.
# Open the file /etc/dphys-swapfile:
# sudo nano /etc/dphys-swapfile
# 7. Use the arrow keys to navigate the text and update the line:
# CONF_SWAPSIZE=100 to CONF_SWAPSIZE=2048
# 8. Save and exit the file by pressing Ctrl-X, followed by Y and then Enter.
sed -i 's/# CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/' /etc/dphys-swapfile

# 9. Restart the swap service:
sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start

# 10. Prepare the source code for compiling:
cd ~/opencv
mkdir build
cd build
cmake \
-D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/
modules \
-D ENABLE_NEON=ON \
-D ENABLE_VFPV3=ON \
-D BUILD_TESTS=OFF \
-D INSTALL_PYTHON_EXAMPLES=OFF \
-D OPENCV_ENABLE_NONFREE=ON \
-D CMAKE_SHARED_LINKER_FLAGS=-latomic \
-D BUILD_EXAMPLES=OFF ..

# 11. Now let’s compile the source code. This part is going to take a while:
make -j4

# 12. If you attempted the –j4 switch and it failed,
# somewhere around hour 4, enter the following lines:
make clean
make

# 13. With the source code compiled, you can now install it:
sudo make install
sudo ldconfig

# 14. Set your swap memory back to its default value:
# sudo nano /etc/dphys-swapfile
# 15. Use the arrow keys to navigate the text and update
# the line: CONF_SWAPSIZE=2048 to CONF_SWAPSIZE=100
# 16. Save and exit the file by pressing Ctrl-X, followed by Y and then Enter.
sed -i 's/# CONF_SWAPSIZE=2048/CONF_SWAPSIZE=100/' /etc/dphys-swapfile

# 17. Test the installation by opening a Python command line
python -c "import cv2"
