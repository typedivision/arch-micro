![arch-micro](arch-micro.png)

is a minimal Arch Linux [docker image](https://hub.docker.com/r/typedivision/arch-micro) based on the [base image](https://github.com/archlinux/archlinux-docker) but a bit smaller in its image size and intended for CI and testing purposes.

There is only pacman installed and no header files, static libraries, locales and so on my making use of the `NoExtract` property in the [pacman.conf](pacman.conf) (thats why you need to re-install the _glibc_ if you are going to compile something).

Beside the Arch Linux setup there is also an [Artix](https://artixlinux.org) image branch.
