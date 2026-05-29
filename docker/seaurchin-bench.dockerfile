# start with a base image (same bytes are mirrored at ghcr; using ghcr so
# CI on github actions can pull without external registry credentials).
FROM ghcr.io/seahorn/seaurchin-llvm/buildpack-deps-seaurchin:latest
# set user to root to install requirements
USER root
WORKDIR /
# install build/runtime utilities
RUN apt-get update && \
  apt-get install -y curl zstd nano emacs texlive-xetex pandoc

# install rust (seaurchin toolchain) from the dev-18-latest rolling release
RUN curl -fsSL -o /seaurchin-dist.tar.zst \
    https://github.com/seahorn/seaurchin/releases/download/dev-18-latest/seaurchin-dist.tar.zst && \
  mkdir seaurchin && \
  tar --zstd -xf /seaurchin-dist.tar.zst -C seaurchin && \
  rm /seaurchin-dist.tar.zst
# setup default user
RUN useradd -ms /bin/bash usea && \
  echo usea:horn | chpasswd && \
  usermod -aG sudo usea && \
  echo "PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\n\[\033[00m\]\\\$ '" >> /home/usea/.bashrc

USER usea  
WORKDIR /home/usea

# install data-science utilities
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install notebook
RUN python3 -m pip install pandas
RUN python3 -m pip install matplotlib
RUN python3 -m pip install --upgrade "jinja2>=3.1.2"

# install reframe hpc test framework v4.8.0 and set path
RUN pip install ReFrame-HPC==4.8.0
ENV PATH="/home/usea/.local/bin:$PATH"

# install rustup
# set up custom rust toolchain "seaurchin" pointing to /seaurchin/install/usr/local
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  . "$HOME/.cargo/env" && \
  rustup component add rustfmt clippy && \
  rustup toolchain link seaurchin /seaurchin/install/usr/local && \
  rustup default seaurchin
ENV PATH="/home/usea/.cargo/bin:$PATH"

# set the working directory
RUN mkdir seaurchin-bench
WORKDIR /home/usea/seaurchin-bench
# copy the repo to the docker image
COPY --chown=usea:usea . /home/usea/seaurchin-bench

# run reframe build tests as a smoke test of the toolchain
# RUN_ID lets callers force a fresh reframe execution (BuildKit caches identical RUNs otherwise).
ARG RUN_ID=0
RUN echo "reframe run id: $RUN_ID" && \
  cd /tmp && \
  ARTIFACTS=micro reframe \
    -C /home/usea/seaurchin-bench/bench/settings.py \
    -c /home/usea/seaurchin-bench/bench/rfm_cargo_build_test.py \
    --exec-policy serial \
    --performance-report \
    -S sourcesdir=/home/usea/seaurchin-bench \
    --system=local \
    --run
