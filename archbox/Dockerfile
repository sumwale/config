# syntax=docker/dockerfile:1

# Creates an Arch Linux image with utility software, AUR setup etc that integrates into the
# current desktop to allow running CLI and GUI apps seemlessly from the desktop environment

FROM archlinux

LABEL maintainer="Sumedh Wale"

ARG user
ARG username

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN set -ex && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen en_US.UTF-8 && \
    echo -e "LANG=$LANG\nLANGUAGE=$LANGUAGE\nLC_ALL=$LC_ALL" > /etc/locale.conf && \
    source /etc/locale.conf && export LANG LANGUAGE LC_ALL && \
    pacman-key --init && \
    sed -i 's/^#Color.*/Color/;s/^NoProgressBar.*/#NoProgressBar/' /etc/pacman.conf && \
    sed -i 's,^NoExtract[ ]*=[ ]*/\?usr/share/man.*,#\0,' /etc/pacman.conf && \
    PAC="pacman --noconfirm" && $PAC -Syy && \
    $PAC -S reflector && \
    sed -i 's/^--latest.*/--latest 50\n--number 5\n--threads 5/' /etc/xdg/reflector/reflector.conf && \
    sed -i 's/^--sort.*/--sort rate/' /etc/xdg/reflector/reflector.conf && \
    reflector @/etc/xdg/reflector/reflector.conf 2>/dev/null && \
    $PAC -Syu && \
    $PAC -S --needed less lesspipe bc base-devel man-db man-pages sudo git neovim ncdu fd bat libva-utils mesa-utils vulkan-tools && \
    $PAC -S --asdeps ed unzip fastjar python-pynvim xsel intel-media-driver libva-mesa-driver vulkan-intel vulkan-mesa-layers python-pipx && \
    yes | pacman -Scc && \
    sed -i 's/^COMPRESSZST=.*/COMPRESSZST=(zstd -c -T0 -8 -)/' /etc/makepkg.conf && \
    echo -e '\nexport EDITOR=nvim\nexport VISUAL=nvim' >> /etc/bash.bashrc && \
    echo -e 'export PAGER="less -RL"\nexport LESSOPEN="|/usr/bin/lesspipe.sh %s"' >> /etc/bash.bashrc && \
    useradd -m -G wheel -s /bin/bash -c "${username}" ${user} && usermod --lock ${user} && \
    echo "${user} ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/lbox-${user}

USER ${user}
WORKDIR /home/${user}

RUN sudo pacman -Syu && \
    git clone https://aur.archlinux.org/paru.git && \
    cd paru && makepkg --noconfirm -si && cd .. && \
    PARU="paru --noconfirm" && $PARU -Rs rust && rm -rf .cargo paru && \
    $PARU -S neovim-symlinks && \
    yes | paru -Sccd && $PARU -Syu && \
    mkdir -p .config/pulse

CMD [ "/usr/bin/tail", "-s10", "-f", "/dev/null" ]
