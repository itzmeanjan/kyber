CXX = g++
CXXFLAGS = -std=c++20 -Wall -Wextra -pedantic
OPTFLAGS = -O3 -march=native -mtune=native
IFLAGS = -I ./include
DEP_IFLAGS = -I ./sha3/include

all: testing test_kat

wrapper/libkyber_kem.so: wrapper/kyber_kem.cpp include/*.hpp sha3/include/*.hpp
	$(CXX) $(CXXFLAGS) $(OPTFLAGS) $(IFLAGS) $(DEP_IFLAGS) -fPIC --shared $< -o $@

lib: wrapper/libkyber_kem.so

test/a.out: test/main.cpp include/*.hpp sha3/include/*.hpp
	$(CXX) $(CXXFLAGS) $(OPTFLAGS) $(IFLAGS) $(DEP_IFLAGS) $< -o $@

testing: test/a.out
	./$<

test_kat:
	bash test_kat.sh

clean:
	find . -name '*.out' -o -name '*.o' -o -name '*.so' -o -name '*.gch' | xargs rm -rf

format:
	find . -path ./sha3 -prune -name '*.hpp' -o -name '*.cpp' -o -name '*.hpp' | xargs clang-format -i --style=Mozilla && python3 -m black wrapper/python/*.py

bench/a.out: bench/main.cpp include/*.hpp sha3/include/*.hpp
	# make sure you've google-benchmark globally installed;
	# see https://github.com/google/benchmark/tree/60b16f1#installation
	$(CXX) $(CXXFLAGS) $(OPTFLAGS) $(IFLAGS) $(DEP_IFLAGS) $< -lbenchmark -o $@

benchmark: bench/a.out
	./$< --benchmark_time_unit=us --benchmark_counters_tabular=true
