# donaught

Hybrid MPI/OpenMP C++ code that does nothing but eat ran and cycles and optionally crash .

Compile with

"mpicxx -fopenmp -O0 donaught.cc -o donaught".

Run with

"OMP_NUM_THREADs=[NTHREAD] mpirun -n [NPROC] [OPTIONS] ./donaught [SECONDS] [MBPERPROC] [crash]"

# bindreport

Hybrid MPI/OpenMP C code that reports cpu bindings of processes and threads.

Compile with

"mpicc -fopenmp bindreport.c -o bindreport".

Run with

"OMP_NUM_THREADs=[NTHREAD] mpirun -n [NPROC] [OPTIONS] ./bindreport [GBPERTHREAD]"

or replace mpirun with srun.

