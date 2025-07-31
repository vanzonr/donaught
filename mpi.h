/* fake mpi header */
#ifndef _MPIH_

#define _MPIH_
#define MPI_THREAD_FUNNELED 3
#define MPI_COMM_WORLD 0
#define MPI_STATUS_IGNORE -1
#define MPI_CHAR 1

int MPI_Init_thread(int* argc, char***argv, int requested,int* provided);
int MPI_Comm_size(int comm, int* nproc);
int MPI_Comm_rank(int comm, int* rank);
int MPI_Recv(char* buf, int buflen, int type, int from, int tag, int comm, int status);
int MPI_Send(char* buf, int buflen, int type, int to, int tag, int comm);
int MPI_Finalize();

#endif
