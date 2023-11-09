#!/bin/bash
#SBATCH --nodes 2
#SBATCH --ntasks 2
#SBATCH --cpus-per-task 17
#SBATCH --time 3:00:00

set -eu

env | grep SLURM_
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
echo "OMP_NUM_THREADS=$OMP_NUM_THREADS"

if false; then
# this way of collecting module combinations takes tooo long
stacks=( "NiaEnv/2018a" "NiaEnv/2019b" "NiaEnv/2022a" )
compilers=( "gcc/4.9.4" "gcc/7.3.0" "gcc/8.3.0" "gcc/9.2.0"
    "gcc/9.4.0" "gcc/11.2.0" "gcc/11.3.0" "gcc/12.2.0" "gcc/13.2.0"
    "intel/2017.7" "intel/2018.1" "intel/2018.2" "intel/2018.3"
    "intel/2019u3" "intel/2019u4" "intel/2019u5" "intel/2020u2"
    "intel/2020u4""intel/2021u4" "intel/2022u2" )
mpis=( "openmpi/1.10.7" "openmpi/2.1.3" "openmpi/2.1.4"
    "openmpi/3.0.1" "openmpi/3.0.2" "openmpi/3.1.0rc3"
    "openmpi/3.1.0rc4" "openmpi/3.1.0" "openmpi/3.1.1" "openmpi/3.1.3"
    "openmpi/4.0.1" "openmpi/4.1.1" "openmpi/4.1.4"
    "openmpi/4.1.4+ucx" "openmpi/4.1.2+ucx-1.11.2"
    "openmpi/4.1.4+ucx-1.11.2" "intelmpi/2018.1" "intelmpi/2018.2"
    "intelmpi/2018.3" "intelmpi/2019u3" "intelmpi/2019u4"
    "intelmpi/2019u5" "intelmpi/2021u4+ucx-1.11.2" "intelmpi/2021u4"
    "intelmpi/2022u2+ucx-1.11.2" )
for stack in "${stacks[@]}"; do
    for compiler in "${compilers[@]}"; do
	for mpi in "${mpis[@]}"; do
	    module --force --force purge
	    module load $stack $compiler $mpi 2>/dev/null || continue
	    echo '"'"$stack $compiler $mpi"'"'
	done
    done
done | tee modulesets.txt
stacks=( "CCEnv StdEnv/2016.4" "CCEnv StdEnv/2018.3" "CCEnv StdEnv/2020" "CCEnv StdEnv/2023" )
compilers=( "gcc/4.8.5" "gcc/4.9.4" "gcc/5.4.0" "gcc/6.4.0"
    "gcc/7.3.0" "gcc/8.3.0" "gcc/8.4.0" "gcc/9.1.0" "gcc/9.3.0"
    "gcc/10.2.0" "gcc/10.3.0" "gcc/11.3.0" "gcc/12.3" "intel/2014.6"
    "intel/2016.4" "intel/2017.1" "intel/2017.5" "intel/2018.3"
    "intel/2019.3" "intel/2020.1.217" "intel/2021.2.0"
    "intel/2022.1.0" "intel/2023.2.1" )
mpis=( "openmpi/1.8.8" "openmpi/1.10.7" "openmpi/2.1.1"
    "openmpi/3.1.2" "openmpi/3.1.4" "openmpi/4.0.1" "openmpi/4.0.3"
    "openmpi/4.0.5" "openmpi/4.1.1" "openmpi/4.1.4" "openmpi/4.1.5"
    "intelmpi/2018.3.222" "intelmpi/2019.3.199" "intelmpi/2019.7.217"
    "intelmpi/2021.2.0" "intelmpi/2021.9.0" )
for stack in "${stacks[@]}"; do
    for compiler in "${compilers[@]}"; do
	for mpi in "${mpis[@]}"; do
	    module --force --force purge
	    module load $stack $compiler $mpi 2>/dev/null || continue
	    echo '"'"$stack $compiler $mpi"'"'
	done
    done
done | tee ccmodulesets.txt
fi

modulesets=( 
"NiaEnv/2018a gcc/7.3.0 openmpi/1.10.7"
"NiaEnv/2018a gcc/7.3.0 openmpi/2.1.3"
"NiaEnv/2018a gcc/7.3.0 openmpi/2.1.4"
"NiaEnv/2018a gcc/7.3.0 openmpi/3.0.1"
"NiaEnv/2018a gcc/7.3.0 openmpi/3.1.0rc3"
"NiaEnv/2018a gcc/7.3.0 openmpi/3.1.0rc4"
"NiaEnv/2018a gcc/7.3.0 openmpi/3.1.0"
"NiaEnv/2018a gcc/7.3.0 openmpi/3.1.1"
"NiaEnv/2018a gcc/7.3.0 intelmpi/2018.2"
"NiaEnv/2018a intel/2018.1 openmpi/3.1.1"
"NiaEnv/2018a intel/2018.1 intelmpi/2018.1"
"NiaEnv/2018a intel/2018.2 openmpi/2.1.3"
"NiaEnv/2018a intel/2018.2 openmpi/3.0.1"
"NiaEnv/2018a intel/2018.2 openmpi/3.1.0rc3"
"NiaEnv/2018a intel/2018.2 openmpi/3.1.0rc4"
"NiaEnv/2018a intel/2018.2 openmpi/3.1.0"
"NiaEnv/2018a intel/2018.2 intelmpi/2018.2"
"NiaEnv/2018a intel/2018.3 openmpi/3.0.2"
"NiaEnv/2018a intel/2018.3 openmpi/3.1.1"
"NiaEnv/2018a intel/2018.3 intelmpi/2018.3"
"NiaEnv/2019b gcc/8.3.0 openmpi/3.1.3"
"NiaEnv/2019b gcc/8.3.0 openmpi/4.0.1"
"NiaEnv/2019b gcc/8.3.0 openmpi/4.1.4"
"NiaEnv/2019b gcc/8.3.0 openmpi/4.1.4+ucx"
"NiaEnv/2019b gcc/8.3.0 openmpi/4.1.4+ucx-1.11.2"
"NiaEnv/2019b gcc/8.3.0 intelmpi/2019u3"
"NiaEnv/2019b gcc/8.3.0 intelmpi/2019u4"
"NiaEnv/2019b gcc/8.3.0 intelmpi/2019u5"
"NiaEnv/2019b gcc/9.2.0 openmpi/4.0.1"
"NiaEnv/2019b gcc/9.2.0 openmpi/4.1.1"
"NiaEnv/2019b gcc/9.2.0 intelmpi/2019u4"
"NiaEnv/2019b gcc/9.2.0 intelmpi/2019u5"
"NiaEnv/2019b gcc/9.4.0 openmpi/4.1.1"
"NiaEnv/2019b intel/2019u3 openmpi/3.1.3"
"NiaEnv/2019b intel/2019u3 openmpi/4.0.1"
"NiaEnv/2019b intel/2019u3 intelmpi/2019u3"
"NiaEnv/2019b intel/2019u4 openmpi/4.0.1"
"NiaEnv/2019b intel/2019u4 intelmpi/2019u4"
"NiaEnv/2019b intel/2019u5 intelmpi/2019u5"
"NiaEnv/2022a gcc/11.2.0 openmpi/4.1.2+ucx-1.11.2"
"NiaEnv/2022a gcc/11.3.0 openmpi/4.1.4"
"NiaEnv/2022a gcc/11.3.0 openmpi/4.1.4+ucx"
"NiaEnv/2022a gcc/11.3.0 openmpi/4.1.4+ucx-1.11.2"
"NiaEnv/2022a intel/2022u2 openmpi/4.1.4"
"NiaEnv/2022a intel/2022u2 openmpi/4.1.4+ucx"
"NiaEnv/2022a intel/2022u2 openmpi/4.1.4+ucx-1.11.2"
"NiaEnv/2022a intel/2022u2 intelmpi/2022u2+ucx-1.11.2"
"CCEnv StdEnv/2016.4 gcc/4.8.5 openmpi/1.8.8"
"CCEnv StdEnv/2016.4 gcc/4.8.5 openmpi/2.1.1"
"CCEnv StdEnv/2016.4 gcc/4.8.5 openmpi/3.1.2"
"CCEnv StdEnv/2016.4 gcc/4.9.4 openmpi/2.1.1"
"CCEnv StdEnv/2016.4 gcc/5.4.0 openmpi/2.1.1"
"CCEnv StdEnv/2016.4 gcc/6.4.0 openmpi/2.1.1"
"CCEnv StdEnv/2016.4 gcc/7.3.0 openmpi/2.1.1"
"CCEnv StdEnv/2016.4 gcc/7.3.0 openmpi/3.1.2"
"CCEnv StdEnv/2016.4 gcc/7.3.0 openmpi/3.1.4"
"CCEnv StdEnv/2016.4 gcc/7.3.0 intelmpi/2018.3.222"
"CCEnv StdEnv/2016.4 gcc/8.3.0 openmpi/4.0.1"
"CCEnv StdEnv/2016.4 gcc/9.1.0 openmpi/4.0.1"
"CCEnv StdEnv/2016.4 intel/2014.6 openmpi/2.1.1"
"CCEnv StdEnv/2016.4 intel/2016.4 openmpi/1.10.7"
"CCEnv StdEnv/2016.4 intel/2016.4 openmpi/2.1.1"
"CCEnv StdEnv/2016.4 intel/2016.4 openmpi/3.1.2"
"CCEnv StdEnv/2016.4 intel/2017.1 openmpi/2.1.1"
"CCEnv StdEnv/2016.4 intel/2017.5 openmpi/2.1.1"
"CCEnv StdEnv/2016.4 intel/2018.3 openmpi/2.1.1"
"CCEnv StdEnv/2016.4 intel/2018.3 openmpi/3.1.2"
"CCEnv StdEnv/2016.4 intel/2018.3 openmpi/3.1.4"
"CCEnv StdEnv/2016.4 intel/2018.3 intelmpi/2018.3.222"
"CCEnv StdEnv/2016.4 intel/2019.3 openmpi/2.1.1"
"CCEnv StdEnv/2016.4 intel/2019.3 openmpi/4.0.1"
"CCEnv StdEnv/2016.4 intel/2019.3 intelmpi/2019.3.199"
"CCEnv StdEnv/2018.3 gcc/4.8.5 openmpi/1.8.8"
"CCEnv StdEnv/2018.3 gcc/4.8.5 openmpi/2.1.1"
"CCEnv StdEnv/2018.3 gcc/4.8.5 openmpi/3.1.2"
"CCEnv StdEnv/2018.3 gcc/4.9.4 openmpi/3.1.2"
"CCEnv StdEnv/2018.3 gcc/5.4.0 openmpi/3.1.2"
"CCEnv StdEnv/2018.3 gcc/6.4.0 openmpi/2.1.1"
"CCEnv StdEnv/2018.3 gcc/7.3.0 openmpi/2.1.1"
"CCEnv StdEnv/2018.3 gcc/7.3.0 openmpi/3.1.2"
"CCEnv StdEnv/2018.3 gcc/7.3.0 openmpi/3.1.4"
"CCEnv StdEnv/2018.3 gcc/7.3.0 intelmpi/2018.3.222"
"CCEnv StdEnv/2018.3 gcc/8.3.0 openmpi/4.0.1"
"CCEnv StdEnv/2018.3 gcc/9.1.0 openmpi/4.0.1"
"CCEnv StdEnv/2018.3 intel/2014.6 openmpi/3.1.2"
"CCEnv StdEnv/2018.3 intel/2016.4 openmpi/1.10.7"
"CCEnv StdEnv/2018.3 intel/2016.4 openmpi/2.1.1"
"CCEnv StdEnv/2018.3 intel/2016.4 openmpi/3.1.2"
"CCEnv StdEnv/2018.3 intel/2017.1 openmpi/3.1.2"
"CCEnv StdEnv/2018.3 intel/2017.5 openmpi/2.1.1"
"CCEnv StdEnv/2018.3 intel/2017.5 openmpi/3.1.2"
"CCEnv StdEnv/2018.3 intel/2018.3 openmpi/3.1.2"
"CCEnv StdEnv/2018.3 intel/2018.3 openmpi/3.1.4"
"CCEnv StdEnv/2018.3 intel/2018.3 intelmpi/2018.3.222"
"CCEnv StdEnv/2018.3 intel/2019.3 openmpi/3.1.2"
"CCEnv StdEnv/2018.3 intel/2019.3 openmpi/4.0.1"
"CCEnv StdEnv/2018.3 intel/2019.3 intelmpi/2019.3.199"
"CCEnv StdEnv/2020 gcc/9.3.0 openmpi/4.0.3"
"CCEnv StdEnv/2020 gcc/10.2.0 openmpi/4.0.5"
"CCEnv StdEnv/2020 gcc/10.2.0 openmpi/4.1.1"
"CCEnv StdEnv/2020 gcc/10.3.0 openmpi/4.0.5"
"CCEnv StdEnv/2020 gcc/10.3.0 openmpi/4.1.1"
"CCEnv StdEnv/2020 gcc/11.3.0 openmpi/4.1.4"
"CCEnv StdEnv/2020 intel/2020.1.217 openmpi/4.0.3"
"CCEnv StdEnv/2020 intel/2020.1.217 intelmpi/2019.7.217"
"CCEnv StdEnv/2020 intel/2021.2.0 openmpi/4.1.1"
"CCEnv StdEnv/2020 intel/2021.2.0 intelmpi/2021.2.0"
"CCEnv StdEnv/2020 intel/2022.1.0 openmpi/4.1.4"
"CCEnv StdEnv/2023 gcc/12.3 openmpi/4.1.5"
"CCEnv StdEnv/2023 intel/2023.2.1 openmpi/4.1.5"
"CCEnv StdEnv/2023 intel/2023.2.1 intelmpi/2021.9.0"
#"CCEnv StdEnv/2020 openmpi/4.0.3" 
#"CCEnv StdEnv/2020 intel/2022.1.0 openmpi/4.1.4"
#"CCEnv StdEnv/2023 openmpi/4.1.5"
#"CCEnv StdEnv/2020 intel/2020.1.217 openmpi/4.0.3"
#"CCEnv StdEnv/2020 gcc/10.2.0 openmpi/4.0.5"
#"CCEnv StdEnv/2020 gcc/10.3.0 openmpi/4.0.5"
#"CCEnv StdEnv/2020 gcc/10.2.0 openmpi/4.1.1"
#"CCEnv StdEnv/2020 gcc/10.3.0 openmpi/4.1.1"
#"CCEnv StdEnv/2020 intel/2021.2.0 openmpi/4.1.1"
#"CCEnv StdEnv/2020 intel/2020.1.217 intelmpi/2019.7.217"
#"CCEnv StdEnv/2020 intel/2021.2.0 intelmpi/2021.2.0"
)


for modset in "${modulesets[@]}"
do
   module --force --force purge 
   module load $modset || continue

   echo "----- $modset -----"

   touch ./donaught
   make clean
   make

   echo MPIRUN WITH $LOADEDMODULES
   mpirun ./donaught 13 >&/dev/null &
   sleep 9
   jobperf $SLURM_JOB_ID
   wait

   echo SRUN WITH $LOADEDMODULES
   srun ./donaught 13  >&/dev/null &
   sleep 9
   jobperf $SLURM_JOB_ID
   wait

   echo "------------------------------------------"

done






