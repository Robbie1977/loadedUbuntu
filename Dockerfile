FROM ubuntu:bionic

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

ENV MA=/opt/MouseAtlas
ENV PATH=/opt/MouseAtlas/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/MouseAtlas/lib:$LD_LIBRARY_PATH
ENV LD_RUN_PATH=/opt/MouseAtlas/lib:$LD_RUN_PATH

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

# Install cJSON library
RUN cd /tmp/ \
    && git clone https://github.com/DaveGamble/cJSON.git \
    && cd cJSON \
    && mkdir build \
    && cd build \
    && cmake .. \
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
&& ./configure --prefix=$MA --enable-optimise --enable-extff --with-jpeg=$MA --with-tiff=$MA --with-nifti=/usr/local/ --with-cjson=/usr/local \
&& make \
&& make install

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
