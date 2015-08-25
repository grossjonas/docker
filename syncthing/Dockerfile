FROM debian:8.1

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update; \
  apt-get install -y apt-utils curl; \
  curl -s https://syncthing.net/release-key.txt | apt-key add - ; \
  echo deb http://apt.syncthing.net/ syncthing release | tee /etc/apt/sources.list.d/syncthing-release.list; \
  apt-get update; \
  apt-get install -y syncthing

RUN useradd -m syncthing; \
  mkdir -p /home/syncthing/Sync; \
  mkdir -p /home/syncthing/.config/syncthing

RUN syncthing --generate=/home/syncthing/.config/syncthing; \
  syncthing --gui-authentication=$username:$password

#EXPOSE 8384
CMD ["/syncthing.sh"]
#CMD ["bash"]
