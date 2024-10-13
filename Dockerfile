FROM nvidia/cuda:12.4.0-base-ubuntu22.04

# Set up environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV POETRY_VIRTUALENVS_CREATE=false
ENV POETRY_NO_INTERACTION=1

# We love UTF!
ENV LANG C.UTF-8

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Set the nvidia container runtime environment variables
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV CUDA_HOME="/usr/local/cuda"
ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0 7.5 8.0 8.6+PTX 8.9"

# Install some handy tools. Even Guvcview for webcam support!
RUN set -x \
	&& apt-get update \
	&& apt-get install -y apt-transport-https ca-certificates \
	&& apt-get install -y git vim tmux nano htop sudo curl wget gnupg2 \
	&& apt-get install -y bash-completion \
	&& apt-get install -y guvcview \
	&& rm -rf /var/lib/apt/lists/*

RUN set -x \
    && apt-get update && apt-get install ffmpeg libsm6 libxext6 -y

WORKDIR /app

COPY ./image_segmentation /app/image_segmentation
COPY ./util /app/util
COPY pyproject.toml poetry.lock /app/

RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"

RUN poetry install --no-root


