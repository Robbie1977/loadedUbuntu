#!/bin/bash

/root/anaconda3/bin/jupyter notebook --ip='*' --NotebookApp.password="${JUPYPASS}" --no-browser --port 9999 --allow-root
