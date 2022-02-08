FROM ubuntu:focal AS stage1

COPY 0001-disable-root-check.patch /root/

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install -y git chrpath diffstat gawk python3-distutils locales wget build-essential cpio
RUN locale-gen en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8 

SHELL ["/bin/bash", "-c"]

RUN git clone https://github.com/openbmc/openbmc.git && \
	cd openbmc && \
	git checkout 2.9.0 && \
	git apply /root/0001-disable-root-check.patch && \
	source setup g220a && \
	echo "BB_GENERATE_MIRROR_TARBALLS = \"1\"" >> conf/local.conf && \
	bitbake --runall=fetch obmc-phosphor-image && \
	ln -sf $PWD/downloads /openbmc-downloads

FROM nginx:1.21

COPY --from=stage1 /openbmc-downloads /
COPY nginx.conf /etc/nginx/nginx.conf
