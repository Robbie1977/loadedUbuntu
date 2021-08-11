FROM ubuntu

VOLUME input
VOLUME output
VOLUME template

#cmtk
RUN apt-get -qq -y update \ 
&& apt-get -qq -y install locales cmtk python python-pip python-dev ipython build-essential git nano autoconf nasm zip automake autoconf m4 libtool bison cmake flex xvfb imagej bc sec libpq-dev python3.7 \
&& pip install --upgrade virtualenv \
&& pip install --upgrade pip

#python image support
RUN pip install pynrrd
RUN pip install h5py


#woolz
RUN apt-get -y install build-essential gcc make wget libdirectfb-dev libjpeg-dev zlib1g-dev libsdl-gfx1.2-dev gcc libsdl1.2-dev libasound2-dev  pkg-config libpci-dev dh-autoreconf csh python-cjson


RUN cd /opt/ \
&& git clone https://github.com/VirtualFlyBrain/VFB_neo4j.git


ENV TZAREA=Europe
ENV TZCITY=London
ENV ANACONDAINS=Anaconda3-5.2.0-Linux-x86_64.sh
ENV JUPYPASS="sha1:7f8e745dd219:b14fb15e0b4bc290a5d109ae97cba5c361b5d139"

#ipython jupyter notebook
RUN cd /tmp/ && \
wget https://repo.anaconda.com/archive/${ANACONDAINS} && \
bash ${ANACONDAINS} -b 

#neo4j requirements
RUN apt-get -y install ipython3 python3-pip python3-setuptools

#python image support
RUN pip3 install pynrrd
RUN pip3 install h5py

#python neo4j support
RUN pip3 install requests
RUN pip3 install psycopg2
RUN pip3 install neo4j

RUN cd /opt && git clone https://github.com/VirtualFlyBrain/curation.git

RUN sed 's/^psycopg2$/psycopg2-binary/g' /opt/VFB_neo4j/requirements.txt >> /opt/requirements.txt
RUN sed 's/^psycopg2$/psycopg2-binary/g' /opt/curation/requirements.txt >> /opt/requirements.txt

RUN pip install -r /opt/requirements.txt
RUN pip3 install -r /opt/requirements.txt

RUN python3.7 -m pip install --force-reinstall pip 

RUN python3.7 -m pip install -r /opt/requirements.txt 

RUN python3.7 -m pip install ipykernel

RUN python3.7 -m ipykernel install --prefix=/root/anaconda3/envs/ --name 'python3.7'

COPY /scripts/* /scripts/
RUN chmod +x /scripts/*.sh

ENTRYPOINT /scripts/startup.sh

EXPOSE 80
