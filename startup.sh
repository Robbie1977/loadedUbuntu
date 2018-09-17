#!/bin/bash

/root/anaconda3/bin/jupyter notebook --ip='*' --NotebookApp.password="${JUPYPASS}" --no-browser --port 80 --allow-root
