DOCKER_ID   = typedivision
DOCKER_REPO = arch-micro

TMPDIR := $(shell mktemp -d)

docker-rootfs:
	pacman -Sy --noconfirm --needed arch-install-scripts
	env -i pacstrap -C pacman.conf -c -d -G -M $(TMPDIR) $$(cat packages)
	cp --recursive --preserve=timestamps --backup --suffix=.pacnew rootfs/* $(TMPDIR)/
	arch-chroot $(TMPDIR) locale-gen
	arch-chroot $(TMPDIR) pacman-key --init
	arch-chroot $(TMPDIR) pacman-key --populate archlinux
	tar --numeric-owner --xattrs --acls --exclude-from=exclude -C $(TMPDIR) -cf $(DOCKER_REPO).tar .
	rm -rf $(TMPDIR)

docker-image: docker-rootfs
	pacman -Sy --noconfirm --needed docker
	docker rmi $(DOCKER_ID)/$(DOCKER_REPO) || true
	docker build -t $(DOCKER_ID)/$(DOCKER_REPO) .

docker-push: docker-image
	echo "$$DOCKER_PASS" | docker login -u $(DOCKER_ID) --password-stdin
	docker push $(DOCKER_ID)/$(DOCKER_REPO)
