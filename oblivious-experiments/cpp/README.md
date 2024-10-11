installing mlpack:

install dependencies
	install boost

	#install armadilloo
```
cd /home/narekg/oblivious/experiments/cpp/armadillo-10.2.2
./configure
make
sudo make install
# symlink /usr/lib/libarmadillo.so.6 to /usr/lib/libarmadilo.so
```
	build mlpack

cmake .. -D BUILD_JULIA_BINDINGS=OFF -D BUILD_GO_BINDINGS=OFF -D BUILD_R_BINDINGS=OFF -D USE_OPENMP=OFF
sudo cp ./build/lib/libmlpack.so.3 /usr/lib/
g++ test.cpp -larmadillo -lmlpack
