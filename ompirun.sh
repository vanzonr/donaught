function ompirun()
{
    usage() { echo -e "ompirun usage:\n ompirun [-n <ntasks>] [-c <nthreads>] command" 1>&2; return 1; }
    local OPTIND opt ntasks nthreads
    ntasks=1
    nthreads=-1
    while getopts ":n:c:h" opt; do
        case "$opt" in
            n) ntasks="$OPTARG" ;;
            c) nthreads="$OPTARG" ;;
            h) usage; return ;;
	    *) echo $opt ;;
        esac
    done
    shift $((OPTIND-1))
    (( nthreads >= 0 )) || let nthreads=$(nproc)/$ntasks
    (( nthreads > 0 ))  || let nthreads=1
    echo "OMP_NUM_THREADS=$nthreads OMP_PLACES=cores mpirun --map-by socket:PE=$nthreads -x OMP_NUM_THREADS -n $ntasks $@"
    OMP_NUM_THREADS=$nthreads OMP_PLACES=cores mpirun --map-by socket:PE=$nthreads -x OMP_NUM_THREADS -n $ntasks "$@" 
}
