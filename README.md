# NARPS_CPPL
Code for the CPPL participation to NARPS

## Using docker
Once you have docker installed you can either:

-   build the docker image using neurodocker by running:

```
docker run --rm kaczmarj/neurodocker:0.4.1 generate docker \
--base=debian:stretch \
--pkg-manager=apt   \
--spm12 version=r7219 method=binaries \
| docker build --tag narps:0.0.1 -
```

This should download the image for `neurodocker` and create a debian based image with the matlab compiler runtime and SPM12.

-   download the official docker SPM container from [there](https://hub.docker.com/r/spmcentral/spm/) by typing:

 -   `docker pull spmcentral/spm:latest` for matlab/spm12
 -   `docker pull spmcentral/spm:octave-latest` for octave/spm12


-   create your own docker image by using a recipe file (`spm_docker_file` is taken from the spm github repo and creates the official SPM docker images):

```
docker build --tag narps:0.0.1 - < spm_docker_file
```
