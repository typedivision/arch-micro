FROM scratch
ADD arch-micro.tar /
ENV LANG=en_US.UTF-8
CMD ["/usr/bin/bash"]
