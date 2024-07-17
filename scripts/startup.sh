#!/bin/bash

TIMEOUT_DURATION=30
DELAY_DURATION=50

# Function to perform git pulls with timeout and delay
perform_git_pulls() {
    for folder in $(find / -type d -name ".git"); do
        # Perform the git pull with a timeout
        timeout $TIMEOUT_DURATION git --git-dir="$folder" pull || :
        # Wait for the specified delay duration
        sleep $DELAY_DURATION
    done
}

# Run the perform_git_pulls function as a subprocess
(perform_git_pulls &)

/root/anaconda3/bin/jupyter lab --ip='*' --NotebookApp.password="${JUPYPASS}" --no-browser --port 80 --allow-root
