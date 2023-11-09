//
// donaught does nothing but eat cpu cycles and memory
//
// Compilation:
//   mpicxx -std=c++11 -fopenmp -O0 -g donaught.cc -o donaught
//
// Usage:
//   OMP_NUM_THREADS=NTHREADS mpiexec -n NPROCS donaught [SECONDS] [MEGABYTES]
//
// NPROCS:  number of processes
// SECONDS: walltime in seconds (approximate)
// MEGABYTES: memory to be allocated per process
//
// Ramses van Zon, April 2019
// (some clean up Oct 2023)
//

#include <mpi.h>
#include <omp.h>
#include <cmath>
#include <iostream>
#include <cstdlib>
#include <string>

// Function to keep the cpu busy
double spin(int iterations, double* allocated) 
{
    double x = allocated[0];
    #pragma omp parallel default(none) shared(iterations) reduction(+:x)
    for (int i = 0; i < iterations; i++) 
	    x += sin(1.0+x);
    return x;
}

int main(int argc, char** argv) 
{
   // Command line arguments specify runtime in seconds and memory in megabytes.

   int  seconds   = (argc>1)?std::atoi(argv[1]):900;
   int  megabytes = (argc>2)?std::atoi(argv[2]):128;

   // Initialize mpi and figure out rank, size, and numthreads.

   char name[MPI_MAX_PROCESSOR_NAME + 1];
   int  trequired = MPI_THREAD_FUNNELED;
   int  err, rank, size, len, tprovided, nthreads;

   MPI_Init_thread(&argc, &argv, trequired, &tprovided);
   MPI_Comm_set_errhandler(MPI_COMM_WORLD, MPI_ERRORS_RETURN);
   err = (tprovided < trequired);
   err |= MPI_Get_processor_name(name, &len);
   err |= MPI_Comm_size(MPI_COMM_WORLD, &size);
   err |= MPI_Comm_rank(MPI_COMM_WORLD, &rank);

   if (rank == 0) 
       std::cout << "--------------------\n"
                 << argv[0] << "\n"
                 << "does nothing but eat cpu cycles and memory\n";
   MPI_Barrier(MPI_COMM_WORLD);

   #pragma omp parallel default(none) shared(nthreads)
   #pragma omp single
   nthreads = omp_get_num_threads();

   // Report from each process.

   std::string report_per_node 
       = std::string("rank=")     + std::to_string(rank)+ " "
       + std::string("size=")     + std::to_string(size)+ " "
       + std::string("nthreads=") + std::to_string(nthreads)+ " "
       + std::string("name=")     + name + "\n";
   std::cout << report_per_node;

   // Allocate requested memory per process.

   int    MEGABYTE  = (1024*1024);
   double*allocated = (double*)calloc(megabytes,MEGABYTE);

   // Estimate how many iterations are needed to keep busy for a second.

   double verystart = MPI_Wtime();
   int    iterations = 1*1000;
   double totelapsed = 0;
   double y;
   {
       double elapsed;
       do {
           iterations *= 10;
	   double start = MPI_Wtime();
	   y = spin(iterations, allocated);
	   double stop = MPI_Wtime();      
	   elapsed = stop - start;
	   totelapsed += elapsed;
       } while (elapsed < 0.1);      
       iterations = int(iterations/elapsed);
   }
   if (rank == 0) 
       std::cout << "ticks are at approximately every one second.\n";

   // Report the time ticks that passed do far during the estimation phase.

   totelapsed = MPI_Wtime() - verystart;
   int tick = int(MPI_Wtime() - verystart+0.5);
   if (rank == 0) 
       for (int t = 1; t <= tick; t++)
	   std::cout << "tick " << t << std::endl;

   // Keep cpu busy until requested walltime has elapsed
   while (totelapsed < seconds) {
       y = spin(iterations, allocated);
       if (rank == 0) 
	   std::cout << "tick " << ++tick << std::endl;
       totelapsed = MPI_Wtime() - verystart;
   }
   
   MPI_Finalize();
   free(allocated);

   return err;
}
