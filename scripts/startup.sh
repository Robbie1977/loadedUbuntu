#!/bin/bash

find / | grep '/\.git$' | rev | cut -c 6- | rev | xargs -t -n 1 git pull || :

/root/anaconda3/bin/jupyter lab --ip='*' --NotebookApp.password="${JUPYPASS}" --no-browser --port 80 --allow-root
