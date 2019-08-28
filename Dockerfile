FROM rocker/r-ver:3.5.1

COPY setup.R setup.R
RUN Rscript setup.R

COPY src/ src/