

So this first version seems to work flawlessly:

``` dockerfile
FROM codenvy/alpine_jdk8

RUN \
  sudo apk update && \

  sudo apk add git && \
  sudo apk add nodejs-lts && \

  sudo npm install --global npm && \

  sudo npm install --global bower && \
  sudo npm install --global gulp-cli && \
  sudo npm install --global yo && \

  sudo npm install --global generator-jhipster

RUN \
  sudo chmod g+w /projects
```

Now let's take it apart and put it together again.

This dockerfile is based  on [```codenvy/alpine_jdk8```](https://github.com/docker/docker/blob/eb7b2ed6bbe3fbef588116d362ce595d6e35fc43/LICENSE) which is based on [```docker:1.12.0```](https://github.com/docker-library/docker/blob/e65e856a4226445f865ec51ea4b6d3bc8353386b/1.12/Dockerfile). Let's start by combining mine and alpine_jdk8:

``` dockerfile
FROM docker:1.12.0

# Here we use several hacks collected from https://github.com/gliderlabs/docker-alpine/issues/11:
# 1. install GLibc (which is not the cleanest solution at all)
# 2. hotfix /etc/nsswitch.conf, which is apperently required by glibc and is not used in Alpine Linux

ENV JAVA_VERSION_MAJOR=8 \
    JAVA_VERSION_MINOR=92 \
    JAVA_VERSION_BUILD=14 \
    JAVA_PACKAGE=jdk \
    JAVA_JCE=standard \
    JAVA_HOME=/opt/jdk \
    GLIBC_VERSION=2.23-r3 \
    MAVEN_VERSION=3.3.9 \
    LANG=C.UTF-8

# upgrade
RUN \
  apk upgrade --update

# install basic stuff
RUN \
  apk add --update libstdc++ curl ca-certificates bash openssh sudo unzip openssl
# get specific glibc
RUN \
  for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do curl -sSL https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
  apk add --allow-untrusted /tmp/*.apk && \
  rm -v /tmp/*.apk
# prepare system settings
RUN \
  ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) && \
  echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh
# use specific glibc
RUN \
  /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib

RUN \
  # download, install and setup java
  mkdir /opt && \
  curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" -o /tmp/java.tar.gz \
    http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz && \
  gunzip /tmp/java.tar.gz && \
  tar -C /opt -xf /tmp/java.tar && \
  ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk && \
  if [ "${JAVA_JCE}" == "unlimited" ]; then echo "Installing Unlimited JCE policy" >&2 && \
    curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" -o /tmp/jce_policy-${JAVA_VERSION_MAJOR}.zip \
      http://download.oracle.com/otn-pub/java/jce/${JAVA_VERSION_MAJOR}/jce_policy-${JAVA_VERSION_MAJOR}.zip && \
    cd /tmp && unzip /tmp/jce_policy-${JAVA_VERSION_MAJOR}.zip && \
    cp -v /tmp/UnlimitedJCEPolicyJDK8/*.jar /opt/jdk/jre/lib/security; \
  fi && \
  sed -i s/#networkaddress.cache.ttl=-1/networkaddress.cache.ttl=30/ $JAVA_HOME/jre/lib/security/java.security && \
  # cleanup by removing unnecessary stuff
  apk del curl glibc-i18n && \
  rm -rf /opt/jdk/*src.zip \
         /opt/jdk/lib/missioncontrol \
         /opt/jdk/lib/visualvm \
         /opt/jdk/lib/*javafx* \
         /opt/jdk/jre/plugin \
         /opt/jdk/jre/bin/javaws \
         /opt/jdk/jre/bin/jjs \
         /opt/jdk/jre/bin/keytool \
         /opt/jdk/jre/bin/orbd \
         /opt/jdk/jre/bin/pack200 \
         /opt/jdk/jre/bin/policytool \
         /opt/jdk/jre/bin/rmid \
         /opt/jdk/jre/bin/rmiregistry \
         /opt/jdk/jre/bin/servertool \
         /opt/jdk/jre/bin/tnameserv \
         /opt/jdk/jre/bin/unpack200 \
         /opt/jdk/jre/lib/javaws.jar \
         /opt/jdk/jre/lib/deploy* \
         /opt/jdk/jre/lib/desktop \
         /opt/jdk/jre/lib/*javafx* \
         /opt/jdk/jre/lib/*jfx* \
         /opt/jdk/jre/lib/amd64/libdecora_sse.so \
         /opt/jdk/jre/lib/amd64/libprism_*.so \
         /opt/jdk/jre/lib/amd64/libfxplugins.so \
         /opt/jdk/jre/lib/amd64/libglass.so \
         /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
         /opt/jdk/jre/lib/amd64/libjavafx*.so \
         /opt/jdk/jre/lib/amd64/libjfx*.so \
         /opt/jdk/jre/lib/ext/jfxrt.jar \
         /opt/jdk/jre/lib/ext/nashorn.jar \
         /opt/jdk/jre/lib/oblique-fonts \
         /opt/jdk/jre/lib/plugin.jar \
         /tmp/* /var/cache/apk/* && \
    # setup system settings some more
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    #download, install and setup maven
    cd /tmp && \
    wget -q "http://apache.ip-connect.vn.ua/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" && \
    tar -xzf "apache-maven-$MAVEN_VERSION-bin.tar.gz" && \
    mv "/tmp/apache-maven-$MAVEN_VERSION" "/usr/lib" && \
    rm "/tmp/"* && \
    # add admin user
    adduser -S user -h /home/user -s /bin/bash -G root -u 1000 && \
    echo "%root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    PASS=$(openssl rand -base64 32) && \
    echo -e "${PASS}\n${PASS}" | passwd user && \
    chown -R user /home/user/

RUN mkdir /usr/che \
    && wget -qO /usr/che/che https://raw.githubusercontent.com/eclipse/che/master/che.sh \
    && chmod +x /usr/che/che

ENV DOCKER_HOST=tcp://192.168.65.1 \
    M2_HOME=/usr/lib/apache-maven-$MAVEN_VERSION

ENV PATH=${PATH}:${JAVA_HOME}/bin:${M2_HOME}/bin:/usr/che

USER user

WORKDIR /projects

RUN \
  sudo apk update && \

  sudo apk add git && \
  sudo apk add nodejs-lts && \

  sudo npm install --global npm && \

  sudo npm install --global bower && \
  sudo npm install --global gulp-cli && \
  sudo npm install --global yo && \

  sudo npm install --global generator-jhipster

RUN \
  sudo chmod g+w /projects

EXPOSE 22 8000 8080

CMD sudo /usr/bin/ssh-keygen -A && \
    sudo /usr/sbin/sshd -D && \
    sudo su - && \
    tail -f /dev/null
```

So far everything works as expected.

But some things bother me ... for example the glibc. Let's try without it.

And we need it for java ... some java by che.

Maybe we could use openjdk instead ... let's try this tomorrow.
