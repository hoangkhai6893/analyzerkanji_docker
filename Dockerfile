ARG VERSION_CUDA
ARG VERSION_PYTORCH

# FROM nvidia/cuda:${VERSION_CUDA}-cudann8-devel-ubuntu20.04 AS base
FROM pytorch/pytorch:${VERSION_PYTORCH}-cuda11.3-cudnn8-runtime

ARG USER_ID
ARG GROUP_ID
ARG USER_NAME

SHELL ["/bin/bash","-o" ,"pipefail","-c"]

ENV DEBIAN_FRONTEND=noninteractive
RUN rm -rf /etc/apt/apt.conf.d/docker-clean

WORKDIR /tmp

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone 

RUN apt-get update -y

RUN apt-get clean
RUN apt-get install -y libgl1-mesa-glx wget curl git   htop  unzip


RUN pip install wrapt --upgrade --ignore-installed pyopengl pylint natsort kfp seaborn transformers==4.24.0   numba==0.48  fugashi==1.1.0 ipadic==1.0.0

RUN apt-get update -y
RUN  apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN conda install -c conda-forge jupyterlab
RUN pip install tensorflow==2.4.0 jupyter-tensorboard==0.2.0 tensorflow-estimator==2.4.0 tensorboard==2.4.0

RUN pip3 install --upgrade pip
    

RUN apt-get update -y
RUN apt-get clean

RUN pip install matplotlib

RUN apt-get update && apt-get install -y sudo 

# # Since uid and gid will change at entrypoint, anything can be used
# RUN groupadd -g ${GROUP_ID} ${USER_NAME} \
#     && useradd --gid ${GROUP_ID} -m ${USER_NAME} \
#     && echo "${USER_NAME}:${USER_NAME}" | chpasswd \ 
#     && usermod --shell /bin/bash ${USER_NAME} \
#     && usermod -aG sudo ${USER_NAME} \
#     && usermod --uid ${USER_ID} ${USER_NAME} \
#     # && echo '%{USER_NAME} ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/${USER_NAME} \
#     && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
#     && chmod 0440 /etc/sudoers.d/${USERNAME} \
#     # && echo "root:${USER_NAME}"  | chpasswd \
#     && echo "export LANG=\"en_US.UTF=8\"" >> /etc/profile.d/${USER_NAME}.sh
ARG USER_ID=1000
ARG GROUP_ID=1000
ENV USER_NAME=dkhai
RUN groupadd -g ${GROUP_ID} ${USER_NAME} && \
    useradd -d /home/${USER_NAME} -m -s /bin/bash -u ${USER_ID} -g ${GROUP_ID} ${USER_NAME}  | chpasswd
RUN echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}



COPY --chown=${USER_NAME}:${USER_NAME} --chmod=777 ./entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh
WORKDIR /home/${USER_NAME}/workspace

ENTRYPOINT ["/entrypoint.sh"]
