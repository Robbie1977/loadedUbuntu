#!/bin/bash
cd /opt/VFB_neo4j/
git pull
export PYTHONPATH=/opt/VFB_neo4j/src
python3 -m uk.ac.ebi.vfb.neo4j.flybase2neo.expression_runner $PDBSERVER $PDBuser $PDBpassword /import/
