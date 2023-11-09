CXX=mpicxx
CXXFLAGS=-fopenmp -std=c++11 -O0 -g

donaught: donaught.cc
	${CXX} ${CXXFLAGS} -o $@ $^

clean:
	\rm donaught

install: donaught
	\cp -f donaught ${HOME}/bin
