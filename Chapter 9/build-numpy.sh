# 3. Download the source code
cd ~
wget https://github.com/numpy/numpy/releases/download/v1.21.2/numpy-1.21.2.tar.gz
tar -xzvf numpy-1.21.2.tar.gz

# 4. Install the Python development libraries and pip:
sudo apt-get install python3-dev

# 6. Increase the memory allocated for swap.
sudo sed -i 's/# CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/' /etc/dphys-swapfile

# 9. Restart the swap service:
sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start

# 10. Prepare the source code for compiling:
cd ~/numpy-1.21.2
python3 setup.py build
python3 setup.py install

# 17. Test the installation by opening a Python command line
python3 -c "import numpy"

# 14. Set your swap memory back to its default value:
sudo sed -i 's/# CONF_SWAPSIZE=2048/CONF_SWAPSIZE=100/' /etc/dphys-swapfile

# 9. Restart the swap service:
sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start
