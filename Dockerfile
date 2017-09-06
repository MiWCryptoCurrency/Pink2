FROM ubuntu:xenial
RUN echo APT::Install-Recommends "0"; >> /etc/apt/apt.conf && \
                  echo APT::Install-Suggests "0"; >> /etc/apt/apt.conf && \
                  apt-get update && apt-get install \
                  --no-install-recommends \
                  -y \
                  qt5-default qt5-qmake qtbase5-dev-tools \
                  qttools5-dev-tools build-essential libboost-dev \
                  libboost-system-dev \
                  libboost-filesystem-dev \
                  libboost-program-options-dev \
                  libboost-thread-dev libssl-dev \
                  libdb++-dev \
                  libminiupnpc-dev \
                  libqrencode-dev \
                  wget \
                  ca-certificates \
		  git
WORKDIR /
RUN git clone https://github.com/MiWCryptoCurrency/Pink2
WORKDIR /Pink2/src		
RUN wget https://fukuchi.org/works/qrencode/qrencode-3.4.4.tar.gz
RUN tar xzvf qrencode-3.4.4.tar.gz
RUN mkdir -p /Pink2/src/qrencode
WORKDIR /Pink2/src/qrencode-3.4.4
RUN ./configure --disable-shared --enable-static --without-tools --prefix=/Pink2/src/qrencode
RUN make install
WORKDIR /Pink2/src
RUN mkdir -p /Pink2/src/db4
RUN wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
RUN echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef db-4.8.30.NC.tar.gz' | sha256sum -c
RUN tar -xzvf db-4.8.30.NC.tar.gz
WORKDIR /Pink2/src/db-4.8.30.NC/build_unix/
RUN	../dist/configure --enable-cxx \
	--disable-shared --with-pic --prefix=/Pink2/src/db4
RUN make install
WORKDIR /Pink2/src
RUN mkdir -p /Pink2/src/openssl
RUN wget 'https://www.openssl.org/source/openssl-1.0.2l.tar.gz'
RUN echo 'ce07195b659e75f4e1db43552860070061f156a98bb37b672b101ba6e3ddf30c openssl-1.0.2l.tar.gz' | sha256sum -c
RUN tar -xzvf openssl-1.0.2l.tar.gz
WORKDIR /Pink2/src/openssl-1.0.2l
RUN ./Configure  linux-x86_64 no-ssl2 no-ssl3 no-comp --prefix=/Pink2/src/openssl no-shared
RUN make depend
RUN make install
WORKDIR /Pink2
RUN qmake \
	USE_UPNP=1 \
	USE_DBUS=1 \
	CONFIG+=c++11 \
	USE_QRCODE=1 \
	STATIC=all \
	RELEASE=1 \
	BDB_LIB_PATH=/Pink2/src/db4/lib \
	BDB_INCLUDE_PATH=/Pink2/src/db4/include \
	OPENSSL_INCLUDE_PATH=/Pink2/src/openssl/include \
	OPENSSL_LIB_PATH=/Pink2/src/openssl/lib \
        QRENCODE_INCLUDE_PATH=/Pink2/src/qrencode/include \
        QRENCODE_LIB_PATH=/Pink2/src/qrencode/lib
RUN make
RUN strip Pinkcoin-Qt
