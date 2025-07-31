/* fake mpi implementation */
#include "mpi.h"

int MPI_Init_thread(int* argc, char***argv, int requested,int* provided)
{
    *provided = requested;
    return 0;
}

int MPI_Comm_size(int comm, int* nproc)
{
    *nproc = 1;
    return 0;
}

int MPI_Comm_rank(int comm, int* rank)
{
    *rank = 0;
    return 0;
}

int MPI_Recv(char* buf, int buflen, int type, int from, int tag, int comm, int status)
{
    return 0;
}

int MPI_Send(char* buf, int buflen, int type, int to, int tag, int comm)
{
    return 0;
}
    
int MPI_Finalize()
{
    return 0;
}
