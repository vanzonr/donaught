#include <mpi.h>          
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/utsname.h>
#include <unistd.h>
#include <sys/sysinfo.h>

#define _GNU_SOURCE
#include <sched.h>
#include <pthread.h>

#ifndef CPU_ISSET
#define CPU_ISSET(cpu,cpusetp) __CPU_ISSET_S(cpu,sizeof(cpu_set_t),cpusetp)
#endif

int sched_setaffinity(pid_t pid, size_t cpusetsize, cpu_set_t *mask);
int sched_getaffinity(pid_t pid, size_t cpusetsize, cpu_set_t *mask);
int pthread_setaffinity_np(pthread_t thread, size_t cpusetsize, const cpu_set_t *cpuset);
int pthread_getaffinity_np(pthread_t thread, size_t cpusetsize, cpu_set_t *cpuset);

/*---------------------------------------------------------------------------*/

#define BUFLEN 16384
int intarraysize = 0;
double gigabytes = 0.0;

/*---------------------------------------------------------------------------*/

int get_local_process_count(MPI_Comm comm) {
    MPI_Comm local_comm;
    int local_size;

    // Create a communicator for processes that share the same node
    MPI_Comm_split_type(comm, MPI_COMM_TYPE_SHARED, 0, MPI_INFO_NULL, &local_comm);

    // Get the size of the local communicator = number of local processes
    MPI_Comm_size(local_comm, &local_size);

    // Clean up
    MPI_Comm_free(&local_comm);

    return local_size;
}

/*---------------------------------------------------------------------------*/

long long get_node_memory_bytes() {
    struct sysinfo info;
    if (sysinfo(&info) == 0)
        return (long long)info.totalram * info.mem_unit;
    return 0;
}

/*---------------------------------------------------------------------------*/

void reportprocessbinding(char* buff)
{
    cpu_set_t mask;   
    sched_getaffinity(0, sizeof(mask), &mask);
    char tmp[2*2050] = " bound to cpu ";
    int lastset=0, onebutlastset=0;
    for (int i = 0; i < 512; i++) {
        if (CPU_ISSET(i, &mask)) {
            if (!lastset) {
                sprintf(tmp+strlen(tmp), "%03d", i);
            } else {
                if (!onebutlastset)
                    sprintf(tmp+strlen(tmp), "%c", '-');
            }
            onebutlastset = lastset;
           lastset = 1;
        } else {
            if (lastset) {
                if (onebutlastset) {
                    sprintf(tmp+strlen(tmp), "%03d,", i-1);
                } else {
                    sprintf(tmp+strlen(tmp), "%c", ',');
                }
           }
            onebutlastset = lastset = 0;
        }
    }
    tmp[strlen(tmp)-1]='\0';
    strcat(buff, tmp);
}

/*---------------------------------------------------------------------------*/

void reportthreadbinding(char* buff)
{
    cpu_set_t mask;
    pthread_getaffinity_np(pthread_self(), sizeof(cpu_set_t), &mask);
    char tmp[2*2050] = "->";
    int lastset=0, onebutlastset=0;
    for (int i = 0; i < 512; i++) {
        if (CPU_ISSET(i, &mask)) {
            if (!lastset) {
                sprintf(tmp+strlen(tmp), "%03d", i);
            } else {
                if (!onebutlastset)
                    sprintf(tmp+strlen(tmp), "%c", '-');
            }
            onebutlastset = lastset;
            lastset = 1;
        } else {
            if (lastset) {
                if (onebutlastset) {
                    sprintf(tmp+strlen(tmp), "%03d,", i-1);
                } else {
                    sprintf(tmp+strlen(tmp), "%c", ',');
                }
            }
            onebutlastset = lastset = 0;
        }
    }
    tmp[strlen(tmp)-1]='\t';
    tmp[strlen(tmp)]='\0';
    strcat(buff, tmp);
}

/*---------------------------------------------------------------------------*/

void reportonempiproc(int rank, int size, char* buff)
{
    char tmp[3*140];
    struct utsname name;
    uname(&name);
    snprintf(tmp, 3*140, 
             "On host %s, process %03d/%d (%.3lfGB/th)", 
             name.nodename, 
             rank,size,
	     gigabytes);
    strcat(buff,tmp);
    reportprocessbinding(buff);
}

/*---------------------------------------------------------------------------*/

void reportoneompthread(char* buff)
{  
   char tmp1[3*140+3*2050];
   sprintf(tmp1, "%03d", omp_get_thread_num());
   reportthreadbinding(tmp1);   
   #pragma omp critical
   strcat(buff, tmp1);
}

/*---------------------------------------------------------------------------*/

void reportallompthreads(char* buff)
{
    sprintf(buff+strlen(buff), "%s", ". Thread binding:\n");
    int  n;
    #pragma omp parallel default(none) shared(n)
    #pragma omp single
    n = omp_get_num_threads();
    int* go = calloc(n+1, sizeof(int));
    go[0] = 1;
    #pragma omp parallel default(none) shared(buff, go, intarraysize) 
    {
       int* a = malloc(intarraysize*sizeof(int));
       int* b = malloc(intarraysize*sizeof(int));
       for (size_t i=0; i<intarraysize; i++)
         a[i] = i;
       for (size_t i=0; i<intarraysize; i++)
         b[intarraysize-1-i] = a[i];
       // mechanism to make the threads report in order
       int th = omp_get_thread_num();
       while (!go[th]) {
       #pragma omp flush
       }
       reportoneompthread(buff);
       go[th+1] = 1;
       free(a); free(b);
    }
    sleep(1);
}

/*---------------------------------------------------------------------------*/

int main(int argc, char *argv[])
{
    int  nproc;
    int  rank;
    int  i;
    int  root = 0;
    char buf[BUFLEN] = "";
    int  requested=MPI_THREAD_FUNNELED;
    int  provided;
    
    MPI_Init_thread(&argc, &argv, requested,&provided);
    if (provided < requested)
        fprintf(stderr, "MPI threading support level too low!");
    MPI_Comm_size(MPI_COMM_WORLD, &nproc);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    gigabytes = (argc>1)?atof(argv[1]):0;
    intarraysize = (gigabytes*1024*1024*1024)/(2*sizeof(int));
    int numprocspernode=get_local_process_count(MPI_COMM_WORLD);
    size_t memorypernode=get_node_memory_bytes();
    int nthread;
    #pragma omp parallel default(none) shared(nthread)
    #pragma omp single
    nthread = omp_get_num_threads();
    double maxgigabytes = memorypernode/(double)(numprocspernode*nthread)/1073741824;
    if (rank==0) {
        printf("Number of processes: %d\n", nproc);
        printf("Processes per node:  %d\n", numprocspernode);
        printf("Threads per process: %d\n", nthread);
        printf("Memory per node:    %.3lf GB\n",memorypernode/(double)1073741824);
        printf("Max. GB per thread: %.3lf GB\n",maxgigabytes);
    }
    
    if (gigabytes > maxgigabytes) {
        if (rank==0)
            fprintf(stderr,"ERROR (bindreport): Asking too much memory per thread!\n");
        MPI_Barrier(MPI_COMM_WORLD);
        MPI_Abort(MPI_COMM_WORLD,2);
    }
    if (rank==root) {
        
        reportonempiproc(rank, nproc, buf);
        reportallompthreads(buf);
        printf("%s\n", buf);  
        for (i=1; i<nproc; i++) {
            MPI_Recv(buf, BUFLEN, MPI_CHAR, i, 7, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            printf("%s\n", buf);
        }
        
    } else {
        
        reportonempiproc(rank, nproc, buf);
        reportallompthreads(buf);
        MPI_Send(buf, strlen(buf)+1, MPI_CHAR, root, 7, MPI_COMM_WORLD);
        
    }

    MPI_Finalize();     
    return 0;
}

/*---------------------------------------------------------------------------*/
