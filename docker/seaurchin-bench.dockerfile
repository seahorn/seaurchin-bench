# start with a base image
FROM git.uwaterloo.ca:5050/seaurchin/seaurchin-llvm
# set user to root to install requirements
USER root
WORKDIR /
# install rust
RUN apt-get update && \
  apt-get install -y curl unzip jq zstd nano texlive-xetex pandoc  && \
  PROJECT_PATH="seaurchin%2Fseaurchin" && \
  PIPELINE_ID=$(curl --silent "https://git.uwaterloo.ca/api/v4/projects/$PROJECT_PATH/pipelines?ref=dev-18&status=success&per_page=1" | jq -r '.[0].id') && \
  if [ -z "$PIPELINE_ID" ]; then echo "❌ No successful pipeline found" && exit 1; fi && \
  JOB_ID=$(curl --silent "https://git.uwaterloo.ca/api/v4/projects/$PROJECT_PATH/pipelines/$PIPELINE_ID/jobs" | jq -r '.[] | select(.name == "build-rust-dist") | .id' | head -n 1) && \
  if [ -z "$JOB_ID" ]; then echo "❌ No matching job found in pipeline $PIPELINE_ID" && exit 1; fi && \
  echo "✅ Using job ID: $JOB_ID" && \
  curl "https://git.uwaterloo.ca/api/v4/projects/$PROJECT_PATH/jobs/$JOB_ID/artifacts" --output artifacts.zip && \
  unzip artifacts.zip && \
  rm artifacts.zip
# unzip seaurchin-dist.tar.zst in seaurchin directory
RUN mkdir seaurchin && \
  tar --zstd -xf seaurchin-dist.tar.zst -C seaurchin 
# delete the tar file
RUN rm seaurchin-dist.tar.zst
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

# set the working directory
RUN mkdir seaurchin-bench
WORKDIR /home/usea/seaurchin-bench
# copy the repo to the docker image
COPY --chown=usea:usea . /home/usea/seaurchin-bench
