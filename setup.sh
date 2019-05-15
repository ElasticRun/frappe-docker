#! /bin/bash
CONFIG_DIRS="fluentd ."

function setup_k8s(){
    type=$1
    declare -A FILES_TO_PROCESS
    for directory in $CONFIG_DIRS
    do
        if [ -d ./$directory/k8s ]
        then
            for file in `ls ./$directory/k8s/*.yaml`
            do
                key=`basename $file`
                FILES_TO_PROCESS[$key]=$file
            done
        fi
        if [ -d ./$directory/k8s/$type ]
        then
            for file in `ls ./$directory/k8s/$type/*.yaml`
            do
                key=`basename $file`
                FILES_TO_PROCESS[$key]=$file
            done
        fi
    done
    #echo "Files to process - ${!FILES_TO_PROCESS[@]}"
    SORTED_FILES_TO_PROCESS=($(echo ${!FILES_TO_PROCESS[@]} | tr ' ' '\n' | sort | tr '\n' ' '))
    #IFS=$'\n' SORTED_FILES_TO_PROCESS=($(sort <<<"${!FILES_TO_PROCESS[@]}"))
    #IFS=' '; SORTED_FILES_TO_PROCESS=($(echo "${!FILES_TO_PROCESS[@]}" | sort -h))
    unset IFS
    #echo "Sorted Files - ${SORTED_FILES_TO_PROCESS[@]}"
    for key in ${SORTED_FILES_TO_PROCESS[@]}
    do
        filename=${FILES_TO_PROCESS[$key]}
        if [ $filename == *"-sc-"* -o $filename == *"-pv"* ]
        then
            echo "Deleting existing resource using file $filename"
            kubectl delete -f $filename
        fi
        echo "Processing file $filename..."
        kubectl apply -f $filename
    done
}
function usage(){
    echo "USAGE: $1 -t aks|local"
}

if [ $# -ne 2 ]
then
    usage $0
else
    if [ $1 == "-t" ]
    then
        type=$2
        echo "Running setup of type $type"
        setup_k8s $type
    else
        usage $0
    fi
fi
