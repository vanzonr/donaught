# Makefile for donaught, bindreport, bindreport-nompi
#
# See README.md for explanation and documentation.
#
CC=gcc
MPICC=mpicc
MPICXX=mpicxx

CFLAGS=-fopenmp -O0 -g
CXXFLAGS=${CFLAGS} -std=c++11

all: donaught bindreport bindreport-nompi

donaught: donaught.cc
	${MPICXX} ${CXXFLAGS} -o $@ $^

bindreport: bindreport.c
	${MPICC} ${CFLAGS} -o $@ $^

bindreport-nompi: bindreport.c mpi.c
	${CC} ${CFLAGS} -I. -o $@ $^

clean:
	${RM} donaught bindreport bindreport-nompi

install: donaught bindreport bindreport-nompi
	\cp -f donaught bindreport bindreport-nompi ${HOME}/bin
