#!/bin/bash

/root/anaconda3/bin/jupyter lab --ip='*' --NotebookApp.password="${JUPYPASS}" --no-browser --port 80 --allow-root
