#! /bin/bash
bench list-apps | grep -q latte
LATTE_EXISTS=$?
if [ $LATTE_EXISTS -eq 0 ]
then
    #Latte exists.
    echo "Starting kafka worker"
    bench kafka-worker
else
    #Latte not installed
    echo "Latte is not installed. Ignoring Kafka Worker Start Command."
    exit 44
fi
