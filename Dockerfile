FROM ubuntu:18.04

RUN apt-get update \ 
	&& apt-get install -y --no-install-recommends \
	    apt-utils \
		ed \
		less \
		locales \
		vim-tiny \
		wget \
		ca-certificates \
		apt-transport-https \
		gsfonts \
		gnupg2 \
	&& rm -rf /var/lib/apt/lists/*

ENV R_BASE_VERSION 3.5.1

COPY setup.R setup.R
RUN Rscript setup.R

COPY src/ src/