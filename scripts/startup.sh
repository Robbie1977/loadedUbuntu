#!/bin/bash

for folder in $(find / | grep '/\.git$') ; do git --git-dir=$folder pull || : ; done;

# /root/anaconda3/bin/jupyter lab --ip='*' --NotebookApp.password="${JUPYPASS}" --no-browser --port 80 --allow-root

while true 
do 
  sleep 999m
done
  
