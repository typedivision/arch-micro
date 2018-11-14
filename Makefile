DOCKER_ID   = typedivision
DOCKER_REPO = arch-micro
DOCKER_TAG  = $(CI_COMMIT_REF_NAME)

ifeq ($(DOCKER_TAG),)
  DOCKER_TAG := $(shell git rev-parse --short HEAD)
endif
ifeq ($(DOCKER_TAG),master)
  DOCKER_TAG = latest
endif

TMPDIR := $(shell mktemp -d)

docker-rootfs:
	pacman -Sy --noconfirm --needed arch-install-scripts
	env -i pacstrap -C pacman.conf -c -d -G -M $(TMPDIR) $$(cat packages)
	cp -a pacman.conf $(TMPDIR)/etc/pacman.conf
	cp -a rootfs/* $(TMPDIR)/
	arch-chroot $(TMPDIR) locale-gen
	arch-chroot $(TMPDIR) pacman-key --init
	arch-chroot $(TMPDIR) pacman-key --populate archlinux
	tar --numeric-owner --xattrs --acls --exclude-from=exclude -C $(TMPDIR) -cf $(DOCKER_REPO).tar .
	rm -rf $(TMPDIR)

docker-image: docker-rootfs
	pacman -Sy --noconfirm --needed docker
	docker rmi $(DOCKER_ID)/$(DOCKER_REPO):$(DOCKER_TAG) || true
	docker build -t $(DOCKER_ID)/$(DOCKER_REPO):$(DOCKER_TAG) .

docker-push: docker-image
	echo $$DOCKER_PASS | docker login -u $(DOCKER_ID) --password-stdin
	docker push $(DOCKER_ID)/$(DOCKER_REPO):$(DOCKER_TAG)
