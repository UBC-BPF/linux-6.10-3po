CC=gcc
CXX=g++
EIGEN_DIR=$(realpath ./eigen/Eigen)
CFLAGS=-O0 -Wall -Wextra -g -march=native -fno-omit-frame-pointer
CPPFLAGS=-O2 -Wall -Wextra -g -march=native -fno-omit-frame-pointer -std=c++17 -I $(EIGEN_DIR)
# used for mmap_random+_rw because optimizations optimize out most memory reads..somehow
CPPFLAGS_O0 =-O0 -Wall -Wextra -g -march=native -std=c++17 -static  -I $(EIGEN_DIR)

# todo:: later remote multi mmult_eigen apps, a hack here since traces are managed by file name
all: mmult_eigen mmult_eigen_vec mmult_eigen_dot sparse_eigen mmap_random_rw sort sort_merge mmult_eigen_par mmult_eigen_vec_par mmult_eigen_dot_par sparse_eigen_par

mmap_random_rw: mmap_random_rw.cpp
	$(CXX) $(CPPFLAGS_O0) $^ -o $@

mmult_eigen: mmult_eigen.cpp
	$(CXX) $(CPPFLAGS) -static $^ -o $@
	$(CXX) $(CPPFLAGS) $^ -o $@_dyn

mmult_eigen_vec: mmult_eigen.cpp
	$(CXX) $(CPPFLAGS) -static $^ -o $@

mmult_eigen_dot: mmult_eigen.cpp
	$(CXX) $(CPPFLAGS) -static $^ -o $@

sparse_eigen: sparse_eigen.cpp
	$(CXX) $(CPPFLAGS) -static $^ -o $@
	$(CXX) $(CPPFLAGS) $^ -o $@_dyn

mmult_eigen_par: mmult_eigen.cpp
	$(CXX) $(CPPFLAGS) $^  -fopenmp  -o $@

mmult_eigen_vec_par: mmult_eigen.cpp
	$(CXX) $(CPPFLAGS) $^  -fopenmp  -o $@

mmult_eigen_dot_par: mmult_eigen.cpp
	$(CXX) $(CPPFLAGS) $^  -fopenmp  -o $@

sparse_eigen_par: sparse_eigen.cpp
	$(CXX) $(CPPFLAGS) $^  -fopenmp  -o $@

sort: sort.cpp
	$(CXX) $(CPPFLAGS) $^ -o $@
	$(CXX) $(CPPFLAGS) -DMADVISE $^ -o $@_madvise

sort_merge: sort.cpp
	$(CXX) $(CPPFLAGS) $^ -o $@

.PHONY: clean
clean:
	rm -rf *.o mmult_eigen mmult_eigen_dyn mmap_random_rw sort sort_madvise

