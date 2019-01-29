# NARPS_CPPL
Code for the CPPL participation to NARPS

## Using docker

### 'Creating' a docker image

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


### Using docker

The general use of the docker works as follow:

```
docker run -it --rm \
-v fullpath-to-data:/data:ro \
-v fullpath-to-code:/code \
-v fullpath-to-output_dir/:/output \
spmcentral/spm:octave-latest script '/code/script-to-execute.m'
```

- The `-it` flag tells docker that it should open an interactive container instance.
- The `--rm` flag tells docker that the container should automatically be removed after we close docker.
- The `-v` flag tells docker which folders should be mounted to make them accessible inside the container. The folders `\data`, `\code` and `\output` will be 'created' automatically in the container.
- `/data:ro` means that the content of the `\data` will be in read-only mode.


For example to run the subject level analysis on my computer I type:
```
docker run -it --rm \
-v /c/Users/Remi/Documents/NARPS/:/data:ro \
-v /c/Users/Remi/Documents/NARPS/code/:/code/ \
-v /c/Users/Remi/Documents/NARPS/derivatives/:/output \
spmcentral/spm:octave-latest script '/code/step_2_run_first_level.m'
```

if you want to use a different docker image, simply replace `spmcentral/spm:latest` by the name of the docker image you want to use (e.g `spmcentral/spm:octave-latest`).

If you want to "log into" the docker and use its command line, you need to specify `the entrypoint`. For example:
```
docker run -it --rm \
--entrypoint /bin/sh \
-v /c/Users/Remi/Documents/NARPS/:/data:ro \
-v /c/Users/Remi/Documents/NARPS/code/:/code/ \
-v /c/Users/Remi/Documents/NARPS/derivatives/:/output \
spmcentral/spm:octave-latest
```
