DOCKER_ID   = typedivision
DOCKER_REPO = arch-micro
DOCKER_TAG  = $(TRAVIS_BRANCH)

ifeq ($(DOCKER_TAG),)
  DOCKER_TAG := $(shell git rev-parse --short HEAD)
endif
ifeq ($(DOCKER_TAG),master)
  DOCKER_TAG = latest
endif

TMPDIR := $(shell mktemp -d)

all: docker-image

/etc/pacman.conf.orig:
	cp /etc/pacman.conf /etc/pacman.conf.orig
	echo -e '[system]\nServer = http://mirror1.artixlinux.org/repos/$$repo/os/$$arch' \
	  >> /etc/pacman.conf
	sed 's/SigLevel *=.*/SigLevel = Never/' -i /etc/pacman.conf

docker-rootfs: /etc/pacman.conf.orig
	pacman -Sy --noconfirm artix-keyring
	pacman-key --init
	pacman-key --populate archlinux artix
	pacman -Sy --noconfirm --needed arch-install-scripts
	cp rootfs/etc/pacman.d/mirrorlist-artix /etc/pacman.d
	env -i pacstrap -C pacman.conf -c -d -G -M $(TMPDIR) $$(cat packages)
	cp pacman.conf $(TMPDIR)/etc/pacman.conf
	sed '\|NoExtract.*/lib|d; \|NoExtract.*/include|d' -i $(TMPDIR)/etc/pacman.conf
	cp -r rootfs/* $(TMPDIR)/
	arch-chroot $(TMPDIR) locale-gen
	arch-chroot $(TMPDIR) pacman-key --init
	arch-chroot $(TMPDIR) pacman-key --populate archlinux artix
	tar --numeric-owner --xattrs --acls --exclude-from=exclude -C $(TMPDIR) -cf $(DOCKER_REPO).tar .
	rm -rf $(TMPDIR)

docker-image: docker-rootfs
	pacman -Sy --noconfirm --needed docker
	docker rmi $(DOCKER_ID)/$(DOCKER_REPO):$(DOCKER_TAG) || true
	docker build -t $(DOCKER_ID)/$(DOCKER_REPO):$(DOCKER_TAG) .
