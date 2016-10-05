[WIP]

-v /sys/fs/cgroup:/sys/fs/cgroup:ro

docker build . -t "salt_opensuse" && docker run -it "salt_opensuse" bash

docker build . -t "salt_opensuse" && docker run -it -v /sys/fs/cgroup:/sys/fs/cgroup:ro "salt_opensuse" bash


https://hub.docker.com/r/saltstack/opensuse-13.2-minimal/

https://github.com/saltstack/docker-containers

---

``` bash
zypper in libgit2-devel
```


https://docs.saltstack.com/en/latest/topics/tutorials/walkthrough.html
