#!/bin/bash
#SBATCH --nodes 2
#SBATCH --ntasks-per-node 5
#SBATCH --cpus-per-task 34
#SBATCH --time 3:00:00

function remove_hidden_paths() {
  local input="$1"
  local IFS=':'
  local output=()
  for path in $input; do
    local base
    base="$(basename "$path")"
    if [[ "$base" != .* ]]; then
      output+=("$path")
    fi
  done
  (IFS=:; echo "${output[*]}")
}

set -u

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
let NTASKS=SLURM_NTASKS

echo "OMP_NUM_THREADS=$OMP_NUM_THREADS"
echo "NTASKS=$NTASKS"

modulesets=( 
"StdEnv/2023"
"gentoo/2023 gcc/12.3 openmpi/4.1.5"
"gentoo/2023 gcc/13.3 openmpi/5.0.3"
"gentoo/2023 intel/2023.2.1 openmpi/4.1.5"
"gentoo/2023 intel/2024.2.0 openmpi/5.0.3"
)

outputfile="/tmp/alloutputs-$SLURM_JOBID.txt"
touch "$outputfile"

for modset in "${modulesets[@]}" ; do

    module --force --force purge 
    module load $modset || continue
    loadedmodules=$(remove_hidden_paths "$LOADEDMODULES") 
    
    echo "----- $modset -----" | tee -a "$outputfile"

    mpicxx -std=c++11 -fopenmp -O0 -g donaught.cc -o donaught
    mpicc -O0 -fopenmp -g bindreport.c -o bindreport
    
    echo "MPIRUN WITH $loadedmodules" | tee -a "$outputfile"
    mpirun ./bindreport 0.0036 2>&1 | tee -a "$outputfile"
    mpirun ./donaught 16 128 2>&1 >> "$outputfile"  &    
    pid=$!
    sleep 11
    jobperf $SLURM_JOB_ID
    wait $pid

    echo "MPIRUN -n $NTASKS WITH $loadedmodules" | tee -a "$outputfile"
    mpirun -n $NTASKS ./bindreport 0.0036 2>&1 | tee -a "$outputfile"
    mpirun -n $NTASKS ./donaught 16 128 2>&1 >> "$outputfile"  &
    pid=$!
    sleep 11
    jobperf $SLURM_JOB_ID
    wait $pid

    
    if [[ $loadedmodules =~ openmpi ]]; then
        echo "MPIRUN --BIND-TO NONE WITH $loadedmodules" | tee -a "$outputfile"
        mpirun -bind-to none ./bindreport 0.0036 2>&1 | tee -a "$outputfile"
        mpirun -bind-to none ./donaught 16 128 2>&1 >> "$outputfile"  &
        pid=$!
        sleep 11
        jobperf $SLURM_JOB_ID
        wait $pid
    fi

    echo "SRUN WITH $loadedmodules" | tee -a "$outputfile"
    srun ./bindreport 0.0036 2>&1 | tee -a "$outputfile"
    srun ./donaught 16 128 2>&1 >> "$outputfile" &
    pid=$!
    sleep 11
    jobperf $SLURM_JOB_ID
    wait $pid

    echo "------------------------------------------"  | tee -a "$outputfile"

done

cp "$outputfile" .





