FROM ubuntu:bionic
VOLUME input
VOLUME output
VOLUME template

# Install base dependencies
RUN apt-get -qq -y update \
    && apt-get -qq -y install software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get -qq -y update \
    && apt-get -qq -y install \
    locales \
    cmtk \
    build-essential \
    git \
    nano \
    autoconf \
    nasm \
    zip \
    automake \
    m4 \
    libtool \
    bison \
    cmake \
    flex \
    xvfb \
    imagej \
    bc \
    sec \
    libpq-dev \
    python3.10 \
    python3.10-dev \
    python3.10-distutils \
    python3-pip

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && update-alternatives --set python3 /usr/bin/python3.10

# Install pip for Python 3.10
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

# Python image support
RUN python3.10 -m pip install pynrrd h5py

# Rest of the original dependencies remain same
RUN apt-get -y install build-essential gcc make wget libdirectfb-dev libjpeg-dev zlib1g-dev libsdl-gfx1.2-dev gcc libsdl1.2-dev libasound2-dev pkg-config libpci-dev dh-autoreconf csh python-cjson

# Environment variables
ENV MA=/opt/MouseAtlas
ENV PATH=/opt/MouseAtlas/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/MouseAtlas/lib:$LD_LIBRARY_PATH
ENV LD_RUN_PATH=/opt/MouseAtlas/lib:$LD_RUN_PATH

# Woolz and dependencies installation (same as original)
RUN cd /tmp/ \
    && git clone https://github.com/ma-tech/External.git

# [Previous Woolz-related RUN commands remain the same]

# Install Anaconda and set up Jupyter
ENV TZAREA=Europe
ENV TZCITY=London
ENV ANACONDAINS=Anaconda3-2023.09-0-Linux-x86_64.sh
ENV JUPYPASS="sha1:7f8e745dd219:b14fb15e0b4bc290a5d109ae97cba5c361b5d139"

RUN cd /tmp/ \
    && wget https://repo.anaconda.com/archive/${ANACONDAINS} \
    && bash ${ANACONDAINS} -b

# Install Python packages
RUN python3.10 -m pip install \
    requests \
    psycopg2-binary \
    neo4j \
    jupyter \
    ipykernel

# Set up Python 3.10 kernel for Jupyter
RUN python3.10 -m ipykernel install --name 'python3.10' --display-name 'Python 3.10'

# Clone repositories
RUN cd /opt \
    && git clone https://github.com/VirtualFlyBrain/VFB_neo4j.git \
    && git clone https://github.com/VirtualFlyBrain/curation.git

# Install requirements
RUN sed 's/^psycopg2$/psycopg2-binary/g' /opt/VFB_neo4j/requirements.txt >> /opt/requirements.txt \
    && sed 's/^psycopg2$/psycopg2-binary/g' /opt/curation/requirements.txt >> /opt/requirements.txt \
    && python3.10 -m pip install -r /opt/requirements.txt

COPY /scripts/* /scripts/
RUN chmod +x /scripts/*.sh

ENTRYPOINT /scripts/startup.sh
EXPOSE 80
