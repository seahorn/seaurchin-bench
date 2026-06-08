FROM ghcr.io/seahorn/seaurchin-toolchain:dev-18-latest

USER root
WORKDIR /

RUN apt-get update && \
  apt-get install -y nano emacs texlive-xetex pandoc

RUN echo usea:horn | chpasswd && \
  usermod -aG sudo usea && \
  echo "PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\n\[\033[00m\]\\\$ '" >> /home/usea/.bashrc

USER usea
WORKDIR /home/usea

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install notebook
RUN python3 -m pip install pandas
RUN python3 -m pip install matplotlib
RUN python3 -m pip install --upgrade "jinja2>=3.1.2"

RUN pip install ReFrame-HPC==4.8.0
ENV PATH="/home/usea/.local/bin:$PATH"

RUN mkdir seaurchin-bench
WORKDIR /home/usea/seaurchin-bench
COPY --chown=usea:usea . /home/usea/seaurchin-bench

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
