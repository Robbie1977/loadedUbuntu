#!/bin/bash

/root/anaconda3/bin/jupyter lab --ip='*' --NotebookApp.password="${JUPYPASS}" --no-browser --port 80 --allow-root &

for folder in $(find /opt/ | grep '/\.git$') ; do echo $folder; cd $folder/../;  git pull || : ; cd ..; sleep 10m; done; 

while true 
do 
  sleep 999m
done
