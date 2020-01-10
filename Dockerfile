FROM rocker/r-base:latest

COPY setup.R setup.R
RUN mkdir src/
COPY src/Shared.R src/Shared.R 
COPY src/brmsmodel.R src/brmsmodel.R
COPY src/functions.R src/functions.R
COPY src/cont_scale.R src/cont_scale.R

RUN Rscript setup.R