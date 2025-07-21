#include <mpi.h>          
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/utsname.h>
#include <unistd.h>

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
