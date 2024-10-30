FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
VOLUME input
VOLUME output
VOLUME template

# Install base dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
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
    python3-pip \
    wget \
    curl \
    libdirectfb-dev \
    libjpeg-dev \
    zlib1g-dev \
    libsdl-gfx1.2-dev \
    libsdl1.2-dev \
    libasound2-dev \
    pkg-config \
    libpci-dev \
    dh-autoreconf \
    csh \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && update-alternatives --set python3 /usr/bin/python3.10

# Install pip for Python 3.10
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

# Python image support
RUN python3.10 -m pip install pynrrd h5py

# Environment variables
ENV MA=/opt/MouseAtlas
ENV PATH=/opt/MouseAtlas/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/MouseAtlas/lib:$LD_LIBRARY_PATH
ENV LD_RUN_PATH=/opt/MouseAtlas/lib:$LD_RUN_PATH

# Woolz installation
RUN cd /tmp/ \
    && git clone https://github.com/ma-tech/External.git

RUN cd /tmp/External/ \
    && cd Fcgi/ \
    && tar -zxf fcgi-2.4.0.tar.gz \
    && patch -p0 < fcgi-2.4.0-patch-01 \
    && cd fcgi-2.4.0 \
    && ./configure --prefix=$MA --enable-static --disable-shared \
    && make \
    && make install

RUN cd /tmp/External/ \
    && cd Log4Cpp \
    && rm -rf log4cpp-1.0 \
    && tar -zxf log4cpp-1.0.tar.gz \
    && patch -p0 < log4cpp-1.0.patch \
    && cd log4cpp-1.0 \
    && ./configure --prefix $MA --disable-shared --enable-static --with-pic \
    && make \
    && make install

RUN cd /tmp/External/ \
    && cd PNG \
    && rm -rf libpng-1.6.29 \
    && tar -zxf libpng-1.6.29.tar.gz \
    && cd libpng-1.6.29 \
    && ./configure --prefix $MA --disable-shared --enable-static --with-pic \
    && make \
    && make install

RUN cd /tmp/External/ \
    && cd Jpeg \
    && rm -rf libjpeg-turbo-1.5.1 \
    && tar -zxf libjpeg-turbo-1.5.1.tar.gz \
    && cd libjpeg-turbo-1.5.1 \
    && autoreconf -fi \
    && ./configure --prefix $MA --disable-shared --enable-static --with-jpeg7 --with-pic \
    && make \
    && make install

RUN cd /tmp/External/ \
    && cd Tiff \
    && rm -rf tiff-4.0.8 \
    && tar -zxf tiff-4.0.8.tar.gz \
    && cd tiff-4.0.8 \
    && ./configure --prefix=$MA --disable-shared --enable-static --with-pic --with-jpeg-include-dir=$MA/include --with-jpeg-lib-dir==$MA/lib \
    && make \
    && make install

RUN cd /tmp/External/ \
    && cd NIfTI \
    && tar -zxf nifticlib-2.0.0.tar.gz \
    && cmake nifticlib-2.0.0 \
    && make \
    && make install

RUN cd /tmp/ \
    && git clone https://github.com/ma-tech/Woolz.git \
    && cd Woolz \
    && cp -v Readme.md README \
    && mkdir -p m4 \
    && libtoolize \
    && aclocal \
    && automake --add-missing \
    && autoreconf -i --force \
    && ./build.sh \
    && ./configure --prefix=$MA --enable-optimise --enable-extff --with-jpeg=$MA --with-tiff=$MA --with-nifti=/usr/local/ \
    && make \
    && make install

# Clone VFB repositories
RUN cd /opt/ \
    && git clone https://github.com/VirtualFlyBrain/VFB_neo4j.git \
    && git clone https://github.com/VirtualFlyBrain/curation.git

# Set environment variables
ENV TZAREA=Europe
ENV TZCITY=London
ENV ANACONDAINS=Anaconda3-2023.09-0-Linux-x86_64.sh
ENV JUPYPASS="sha1:7f8e745dd219:b14fb15e0b4bc290a5d109ae97cba5c361b5d139"

# Install Anaconda
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

# Install requirements from VFB repositories
RUN sed 's/^psycopg2$/psycopg2-binary/g' /opt/VFB_neo4j/requirements.txt >> /opt/requirements.txt \
    && sed 's/^psycopg2$/psycopg2-binary/g' /opt/curation/requirements.txt >> /opt/requirements.txt \
    && python3.10 -m pip install -r /opt/requirements.txt

# Copy and prepare scripts
COPY /scripts/* /scripts/
RUN chmod +x /scripts/*.sh

ENTRYPOINT /scripts/startup.sh
EXPOSE 80
