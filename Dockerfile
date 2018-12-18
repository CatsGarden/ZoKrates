FROM ubuntu:18.04

MAINTAINER JacobEberhardt <jacob.eberhardt@tu-berlin.de>, Dennis Kuhnert <mail@kyroy.com>, Thibaut Schaeffer <thibaut@schaeff.fr>

#RUN useradd -u 1000 -m zokrates

ARG RUST_TOOLCHAIN=nightly-2018-06-04
ARG LIBSNARK_COMMIT=f7c87b88744ecfd008126d415494d9b34c4c1b20
ENV LIBSNARK_SOURCE_PATH=/root/libsnark-$LIBSNARK_COMMIT
ENV WITH_LIBSNARK=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    cmake \
    curl \
    libboost-dev \
    libboost-program-options-dev \
    libgmp3-dev \
    libprocps-dev \
    libssl-dev \
    pkg-config \
    python-markdown \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && git clone https://github.com/scipr-lab/libsnark.git $LIBSNARK_SOURCE_PATH \
    && git -C $LIBSNARK_SOURCE_PATH checkout $LIBSNARK_COMMIT \
    && git -C $LIBSNARK_SOURCE_PATH submodule update --init --recursive 
    #&& chown -R zokrates:zokrates $LIBSNARK_SOURCE_PATH

#USER zokrates
#USER root

#WORKDIR /home/zokrates
WORKDIR /root/

#COPY --chown=zokrates:zokrates . src
COPY . src

RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain $RUST_TOOLCHAIN -y \
    #&& export PATH=/home/zokrates/.cargo/bin:$PATH \
    && export PATH=/root/.cargo/bin:$PATH \
    && (cd src;./build_release.sh) \
    && mv ./src/target/release/zokrates . \
    && mv ./src/zokrates_cli/examples . \
    && rustup self uninstall -y \
    && mkdir usless_tmp
    #&& rm -rf $LIBSNARK_SOURCE_PATH src

#-------Extra Added----------------    

RUN apt-get update && apt-get install -y vim \
    && apt-get install -y tree
    
COPY vimrc /root/.vimrc

#-------Install MerkleTree Evaluation Proj-----
RUN mkdir -p /root/mkt \
 && cd /root/mkt \
 && git clone https://github.com/gnosis/MultiSigWallet.git
 && git clone https://github.com/cbergoon/merkletree.git

#------ install Golang 1.8.x ----------
RUN mkdir -p /root/go-setup \
    && cd /root/go-setup/ 
    # && wget https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz \
ADD https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz /root/go-setup/
RUN cd /root/go-setup \
    && tar -xvf go1.8.3.linux-amd64.tar.gz \
    && mv go /usr/local \
    && mkdir /go

#set golang environment variables
ENV GOROOT /usr/local/go  
ENV GOPATH /go
#ENV PATH $GOPATH/bin:$GOROOT/bin:$PATH
ENV PATH $GOPATH/bin:$GOROOT/bin:/root/src/target/release:$PATH

# set go vim syntax highlightning  
# RUN wget https://storage.googleapis.com/golang/go1.3.3.src.tar.gz \
ADD https://storage.googleapis.com/golang/go1.3.3.src.tar.gz /root/go-setup/ 
RUN cd /root/go-setup \
    && tar -zxvf go1.3.3.src.tar.gz \
    && cp -r go/misc/vim/syntax/ go/misc/vim/ftplugin/ go/misc/vim/indent/ go/misc/vim/compiler/ go/misc/vim/ftdetect/ /usr/share/vim/vim74/ 

WORKDIR /root/
