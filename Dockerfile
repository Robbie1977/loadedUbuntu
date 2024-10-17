FROM ubuntu:bionic

VOLUME input
VOLUME output
VOLUME template

# Base dependencies
RUN apt-get -qq -y update \ 
&& apt-get -qq -y install locales cmtk python python-pip python-dev ipython build-essential git nano autoconf nasm zip automake autoconf m4 libtool bison cmake flex xvfb imagej bc sec libpq-dev maven python3 python3-pip libjson-c-dev \
&& pip install --upgrade virtualenv \
&& pip install --upgrade pip

# Python image support
RUN pip install pynrrd
RUN pip install h5py

RUN pip3 install pynrrd h5py requests psycopg2 neo4j==1.7.6

# Python neo4j support
RUN pip install requests
RUN pip install psycopg2
RUN pip install neo4j==1.7.6

# Woolz dependencies
RUN apt-get -y install build-essential gcc make wget libdirectfb-dev libjpeg-dev zlib1g-dev libsdl-gfx1.2-dev gcc libsdl1.2-dev libasound2-dev pkg-config libpci-dev dh-autoreconf csh

ENV MA=/opt/MouseAtlas
ENV PATH=/opt/MouseAtlas/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/MouseAtlas/lib:$LD_LIBRARY_PATH
ENV LD_RUN_PATH=/opt/MouseAtlas/lib:$LD_RUN_PATH

# External Dependencies
RUN cd /tmp/ \
&& git clone https://github.com/ma-tech/External.git

# Install Fcgi
RUN cd /tmp/External/ \
&& cd Fcgi/ \
&& tar -zxf fcgi-2.4.0.tar.gz \
&& patch -p0 < fcgi-2.4.0-patch-01 \
&& cd fcgi-2.4.0 \
&& ./configure --prefix=$MA --enable-static --disable-shared \
&& make \
&& make install

# Install Log4Cpp
RUN cd /tmp/External/ \
&& cd Log4Cpp \
&& rm -rf log4cpp-1.0 \
&& tar -zxf log4cpp-1.0.tar.gz \
&& patch -p0 < log4cpp-1.0.patch \
&& cd log4cpp-1.0 \
&& ./configure --prefix $MA --disable-shared --enable-static --with-pic \
&& make \
&& make install

# Install PNG
RUN cd /tmp/External/ \
&& cd PNG \
&& rm -rf libpng-1.6.29 \
&& tar -zxf libpng-1.6.29.tar.gz \
&& cd libpng-1.6.29 \
&& ./configure --prefix $MA --disable-shared --enable-static --with-pic \
&& make \
&& make install

# Install JPEG
RUN cd /tmp/External/ \
&& cd Jpeg \
&& rm -rf libjpeg-turbo-1.5.1 \
&& tar -zxf libjpeg-turbo-1.5.1.tar.gz \
&& cd libjpeg-turbo-1.5.1 \
&& autoreconf -fi \
&& ./configure --prefix $MA --disable-shared --enable-static --with-jpeg7 --with-pic \
&& make \
&& make install

# Install Tiff
RUN cd /tmp/External/ \
&& cd Tiff \
&& rm -rf tiff-4.0.8 \
&& tar -zxf tiff-4.0.8.tar.gz \
&& cd tiff-4.0.8 \
&& ./configure --prefix=$MA --disable-shared --enable-static --with-pic --with-jpeg-include-dir=$MA/include --with-jpeg-lib-dir=$MA/lib \
&& make \
&& make install

# Install NIfTI
RUN cd /tmp/External/ \
&& cd NIfTI \
&& tar -zxf nifticlib-2.0.0.tar.gz \
&& cmake nifticlib-2.0.0 \
&& make \
&& make install

# Install cJSON
RUN cd /tmp/ \
&& git clone https://github.com/DaveGamble/cJSON.git \
&& cd cJSON \
&& mkdir build \
&& cd build \
&& cmake .. \
&& make \
&& make install

# Woolz compilation
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
&& ./configure --prefix=$MA --enable-optimise --enable-extff --with-jpeg=$MA --with-tiff=$MA --with-nifti=/usr/local/ CPPFLAGS="-I/usr/local/include/cjson" LDFLAGS="-L/usr/local/lib" \
&& make \
&& make install

# Additional tools installation
RUN cd /opt/ \
&& git clone https://github.com/Robbie1977/NRRDtools.git \
&& git clone https://github.com/Robbie1977/SWCtools.git \
&& git clone https://github.com/Robbie1977/Bound.git \
&& git clone https://github.com/Robbie1977/3DwarpScoring.git \
&& git clone https://github.com/Robbie1977/IndexStackConv.git \
&& git clone https://github.com/Robbie1977/3DstackDisplay.git \
&& git clone https://github.com/Robbie1977/lsm2nrrd.git \
&& git clone https://github.com/Robbie1977/nrrd2raw.git \
&& git clone https://github.com/VirtualFlyBrain/VFB_neo4j.git \
&& git clone https://github.com/VirtualFlyBrain/StackProcessing.git \
&& git clone https://github.com/VirtualFlyBrain/StackLoader.git \
&& wget https://downloads.imagej.net/fiji/latest/fiji-linux64.zip \
&& unzip fiji-linux64.zip \
&& rm fiji-linux64.zip

ENV FIJI=/opt/Fiji.app/ImageJ-linux64

RUN mkdir -p /data/ && cd /data/ \
&& git clone https://github.com/VirtualFlyBrain/DrosAdultVNSdomains.git \
&& git clone https://github.com/VirtualFlyBrain/DrosAdultBRAINdomains.git \
&& git clone https://github.com/VirtualFlyBrain/DrosAdultHalfBRAINdomains.git

# Various symlinks
RUN mkdir -p /disk/data/VFB/IMAGE_DATA/ \
&& ln -s /opt/StackLoader /disk/data/VFB/IMAGE_DATA/ \
&& mkdir -p /partition/bocian/VFBTools \
&& ln -s /opt/* /partition/bocian/VFBTools/ \
&& ln -s /VFB /disk/data/VFB/IMAGE_DATA/ \
&& mkdir -p /disk/data/VFBTools \
&& ln -s /opt/Fiji.app /disk/data/VFBTools/ \
&& mv /disk/data/VFBTools/Fiji.app /disk/data/VFBTools/Fiji \
&& ln -s /opt/* /disk/data/VFBTools/ \
&& ln -s /disk/data/VFBTools/MouseAtlas /disk/data/VFBTools/Woolz2013Full \
&& mkdir -p /partition/karenin/VFB/IMAGE_DATA/ \
&& ln -s /opt/StackLoader /partition/karenin/VFB/IMAGE_DATA/ \
&& ln -s /VFB /partition/karenin/VFB/IMAGE_DATA/ \
&& mkdir -p /partition/bocian/VFBTools/python-modules-2.6/bin/ \
&& echo "#empty" > /partition/bocian/VFBTools/python-modules-2.6/bin/activate \
&& ln -s /opt/StackProcessing /disk/data/VFB/IMAGE_DATA/

# Install JGO and other tools
RUN cd /opt/ && \
git clone https://github.com/scijava/jgo && \
cd /bin && \
ln -s /opt/jgo/jgo.sh jgo 
RUN cd /opt/ && \
git clone https://github.com/saalfeldlab/template-building.git && \
cd template-building && \
git checkout v0.1.0 && \
mvn -Dimagej.app.directory=$FIJI clean compile install

# Copy scripts and set permissions
COPY /scripts/* /scripts/
RUN chmod +x /scripts/*.sh

# Environment variables for scripts
ENV woolzDir=/usr/lib/cmtk/bin/
ENV dirName=/opt/StackLoader/PutAlignedFilesInHere/
ENV fijiBin=/opt/Fiji.app/ImageJ-linux64
ENV sriptDir=/opt/StackProcessing/scripts/
ENV imageDir=/IMAGE_DATA/VFB/i/

# Install ImageMagick
RUN cd /opt/ && \
wget https://www.imagemagick.org/archive/ImageMagick.tar.gz && \
tar xvzf ImageMagick.tar.gz && \
cd ImageMagick-* && \
./configure && \
make && \
make install && \ 
ldconfig /usr/local/lib && \
magick -version

# Set the entry point
ENTRYPOINT /scripts/startup.sh

# Expose port 80
EXPOSE 80
