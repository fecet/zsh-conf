FROM ubuntu:latest

# Accept username as build argument
ARG USER=ubuntu

# Switch to root to modify apt sources and install packages
USER root

# Backup original sources.list and configure Azure mirrors for Ubuntu/Debian
RUN if [ -f /etc/apt/sources.list ]; then \
  cp /etc/apt/sources.list /etc/apt/sources.list.backup && \
  sed -i 's|http://archive.ubuntu.com/ubuntu/|http://azure.archive.ubuntu.com/ubuntu/|g' /etc/apt/sources.list && \
  sed -i 's|http://security.ubuntu.com/ubuntu/|http://azure.archive.ubuntu.com/ubuntu/|g' /etc/apt/sources.list && \
  sed -i 's|http://deb.debian.org/debian/|http://debian-archive.trafficmanager.net/debian/|g' /etc/apt/sources.list && \
  sed -i 's|http://security.debian.org/|http://debian-archive.trafficmanager.net/debian-security/|g' /etc/apt/sources.list; \
  fi

# Handle sources.list.d directory if using newer Ubuntu/Debian with split sources
RUN if [ -d /etc/apt/sources.list.d ]; then \
  for file in /etc/apt/sources.list.d/*.sources /etc/apt/sources.list.d/*.list; do \
  if [ -f "$file" ]; then \
  sed -i 's|http://archive.ubuntu.com/ubuntu/|http://azure.archive.ubuntu.com/ubuntu/|g' "$file" && \
  sed -i 's|http://security.ubuntu.com/ubuntu/|http://azure.archive.ubuntu.com/ubuntu/|g' "$file" && \
  sed -i 's|http://deb.debian.org/debian/|http://debian-archive.trafficmanager.net/debian/|g' "$file" && \
  sed -i 's|http://security.debian.org/|http://debian-archive.trafficmanager.net/debian-security/|g' "$file"; \
  fi; \
  done; \
  fi

# Update package lists and install apt-file
RUN apt-get update && \
  apt-get install -y --no-install-recommends apt-file zsh kitty-terminfo 

RUN apt-get install -y --no-install-recommends git ca-certificates curl wget file

# Rename ubuntu user to the specified USER
RUN usermod -l ${USER} ubuntu && \
  groupmod -n ${USER} ubuntu && \
  usermod -d /home/${USER} -m ${USER} && \
  echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# RUN apt-file update
# Switch back to the renamed user
USER ${USER}

# Set working directory
ENV TERM=xterm-256color 
WORKDIR /home/${USER}
ENTRYPOINT [ "bash" ]
