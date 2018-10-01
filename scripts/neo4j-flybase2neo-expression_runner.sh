#!/bin/bash
cd /opt/VFB_neo4j/src/
git pull
python3 -m uk.ac.ebi.vfb.neo4j.flybase2neo.expression_runner.py $PDBSERVER $PDBuser $PDBpassword /import/
