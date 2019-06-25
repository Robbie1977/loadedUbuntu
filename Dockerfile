FROM ubuntu

VOLUME input
VOLUME output
VOLUME template

#cmtk
RUN apt-get -qq -y update \ 
&& apt-get -qq -y install locales cmtk python python-pip python-dev ipython build-essential git nano autoconf nasm zip automake autoconf m4 libtool bison cmake flex xvfb imagej bc sec libpq-dev\
&& pip install --upgrade virtualenv \
&& pip install --upgrade pip

#python image support
RUN pip install pynrrd
RUN pip install h5py

#python neo4j support
RUN pip install requests
RUN pip install psycopg2
RUN pip install neo4j

#woolz
RUN apt-get -y install build-essential gcc make wget libdirectfb-dev libjpeg-dev zlib1g-dev libsdl-gfx1.2-dev gcc libsdl1.2-dev libasound2-dev  pkg-config libpci-dev dh-autoreconf csh

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

RUN cd /tmp/ \
&& git clone https://github.com/ma-tech/Woolz.git \
&& cd Woolz \
&& mkdir -p m4 \
&& libtoolize \
&& aclocal \
&& automake --add-missing \
&& autoreconf -i --force \
&& ./build.sh \
&& ./configure --prefix=$MA --enable-optimise --enable-extff --with-jpeg=$MA --with-tiff=$MA --with-nifti=/usr/local/ \
&& make \
&& make install


RUN cd /opt/ \
&& git clone https://github.com/Robbie1977/NRRDtools.git 
RUN cd /opt/ \
&& git clone https://github.com/Robbie1977/SWCtools.git 
RUN cd /opt/ \
&& git clone https://github.com/Robbie1977/Bound.git 
RUN cd /opt/ \
&& git clone https://github.com/Robbie1977/3DwarpScoring.git 
RUN cd /opt/ \
&& git clone https://github.com/Robbie1977/IndexStackConv.git 
RUN cd /opt/ \
&& git clone https://github.com/Robbie1977/3DstackDisplay.git
RUN cd /opt/ \
&& git clone https://github.com/Robbie1977/lsm2nrrd.git
RUN cd /opt/ \
&& git clone https://github.com/Robbie1977/nrrd2raw.git
RUN cd /opt/ \
&& git clone https://github.com/VirtualFlyBrain/VFB_neo4j.git
RUN cd /opt/ \
&& git clone https://github.com/VirtualFlyBrain/StackProcessing.git
RUN cd /opt/ \
&& git clone https://github.com/VirtualFlyBrain/StackLoader.git
RUN cd /opt/ \
&& wget https://downloads.imagej.net/fiji/latest/fiji-linux64.zip \
&& unzip fiji-linux64.zip \
&& rm fiji-linux64.zip

ENV FIJI=/opt/Fiji.app/ImageJ-linux64

RUN mkdir -p /data/ && cd /data/ \
&& git clone https://github.com/VirtualFlyBrain/DrosAdultVNSdomains.git

RUN cd /data/ \
&& git clone https://github.com/VirtualFlyBrain/DrosAdultBRAINdomains.git

RUN cd /data/ \
&& git clone https://github.com/VirtualFlyBrain/DrosAdultHalfBRAINdomains.git



RUN mkdir -p /disk/data/VFB/IMAGE_DATA/
RUN ln -s /opt/StackLoader /disk/data/VFB/IMAGE_DATA/
RUN mkdir -p /partition/bocian/VFBTools
RUN ln -s /opt/* /partition/bocian/VFBTools/
RUN ln -s /VFB /disk/data/VFB/IMAGE_DATA/
RUN mkdir -p /disk/data/VFBTools
RUN ln -s /opt/Fiji.app /disk/data/VFBTools/
RUN mv /disk/data/VFBTools/Fiji.app /disk/data/VFBTools/Fiji
RUN ln -s /opt/* /disk/data/VFBTools/
RUN ln -s /disk/data/VFBTools/MouseAtlas /disk/data/VFBTools/Woolz2013Full
RUN mkdir -p /partition/karenin/VFB/IMAGE_DATA/
RUN ln -s /opt/StackLoader /partition/karenin/VFB/IMAGE_DATA/
RUN ln -s /VFB /partition/karenin/VFB/IMAGE_DATA/
RUN mkdir -p /partition/bocian/VFBTools/python-modules-2.6/bin/
RUN echo "#empty" > /partition/bocian/VFBTools/python-modules-2.6/bin/activate
RUN ln -s /opt/StackProcessing /disk/data/VFB/IMAGE_DATA/

# ENV TZAREA=Europe
# ENV TZCITY=London
# ENV ANACONDAINS=Anaconda3-5.2.0-Linux-x86_64.sh
# ENV JUPYPASS="sha1:7f8e745dd219:b14fb15e0b4bc290a5d109ae97cba5c361b5d139"

# #ipython jupyter notebook
# RUN cd /tmp/ && \
# wget https://repo.anaconda.com/archive/${ANACONDAINS} && \
# bash ${ANACONDAINS} -b 

# #neo4j requirements
# RUN apt-get -y install ipython3 python3-pip python3-setuptools
# RUN pip3 install pynrrd
# RUN pip3 install requests
# RUN pip3 install psycopg2-binary
# RUN pip3 install pandas

# #python3.7 install
# RUN apt-get -y update && apt-get -y install python3.7

COPY /scripts/* /scripts/
RUN chmod +x /scripts/*.sh

ENTRYPOINT /scripts/startup.sh

EXPOSE 80
