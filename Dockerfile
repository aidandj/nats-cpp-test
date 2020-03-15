FROM ubuntu:latest

ENV cmake_version 3.12
ENV cmake_build 3

# These commands copy your files into the specified directory in the image
# and set that as the working location
WORKDIR /usr/src/nats

RUN apt update
RUN apt install -y build-essential wget python3-pip git
RUN pip3 install conan

# debugging
RUN apt install -y gdb

# install cmake
RUN mkdir /temp
WORKDIR /temp
RUN wget https://cmake.org/files/v${cmake_version}/cmake-${cmake_version}.${cmake_build}.tar.gz
RUN tar -xzvf cmake-${cmake_version}.${cmake_build}.tar.gz
WORKDIR /temp/cmake-${cmake_version}.${cmake_build}/

RUN ./bootstrap
RUN make -j
RUN make install

# Install nats asio requirements. And build?
COPY . /usr/src/nats
WORKDIR /usr/src/nats/nats_asio
RUN pwd
RUN ls
RUN ./config_conan.sh
RUN mkdir build
WORKDIR /usr/src/nats/nats_asio/build
RUN conan install --build=missing ..
RUN cmake .. -DCMAKE_PREFIX_PATH=${PREFIX}  -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Debug ${CMAKE_ARGS}
RUN cmake --build .

# # This command compiles your app using GCC, adjust for your source code
# RUN g++ -o test test.cpp

# LABEL Name=cpp-test cmake_version=0.0.1
