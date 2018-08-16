#!/bin/bash

jupyter notebook --ip='*' --NotebookApp.password="${JUPYPASS}" --no-browser --port 9999 --allow-root
