#! /bin/bash
# Expects input as the supervisor group or process name.
# Group name should be in format <groupname>:*.
if [ $# -gt 0 ]
then
    NUM_PROCESSES=`sudo supervisorctl status $1 | grep -c RUNNING`
    # Returns success if at least one process is reported as RUNNING by supervisorctl
    # TODO - Add second parameter to get expected number of processes running.
    if [ $NUM_PROCESSES -gt 0 ]
    then
        STATUS=0
    else
        STATUS=1
    fi
else
    # Fall back on simple generic process check.
    # If at least one bench process is running, we consider the pod to be healthy.
    ps -eaf | grep -F -q '/usr/local/bin/bench'
    STATUS=$?
fi
echo "checkjobhealth $1 - exiting with status $STATUS"
exit $STATUS
# if [ $? -eq 0 ]
# then
#     STATUS=0
# else
#     false
# fi
