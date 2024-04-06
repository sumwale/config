# syntax=docker/dockerfile:1

# Creates an Arch Linux image with utility software, AUR setup etc that integrates into the
# current desktop to allow running CLI and GUI apps seemlessly from the desktop environment

FROM quay.io/archlinux/archlinux

LABEL maintainer="Sumedh Wale"

ARG user
ARG username

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY prime-run /usr/local/bin/prime-run

RUN set -ex && \
    chmod 0755 /usr/local/bin/prime-run && \
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
    $PAC -S --needed less lesspipe bc base-devel man-db man-pages sudo git pulseaudio-alsa neovim ncdu fd bat libva-utils mesa-utils vulkan-tools ttf-fira-code && \
    $PAC -S --asdeps ed unzip fastjar python-pynvim xsel realtime-privileges intel-media-driver libva-mesa-driver vulkan-intel vulkan-mesa-layers python-pipx && \
    yes | pacman -Scc && $PAC -Syu && \
    sed -i 's/^COMPRESSZST=.*/COMPRESSZST=(zstd -c -T0 -8 -)/' /etc/makepkg.conf && \
    echo -e '\nexport EDITOR=nvim\nexport VISUAL=nvim' >> /etc/bash.bashrc && \
    echo -e 'export PAGER="less -RL"\nexport LESSOPEN="|/usr/bin/lesspipe.sh %s"' >> /etc/bash.bashrc && \
    useradd -m -G wheel,nobody,video,lp,mail,realtime -s /bin/bash -c "${username}" ${user} && usermod --lock ${user} && \
    echo "${user} ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/lbox-${user} && \
    run_dir=/run/user/`id -u ${user}` && mkdir -p $run_dir && \
    chown ${user}:${user} $run_dir && chmod 700 $run_dir

USER ${user}
WORKDIR /home/${user}

RUN git clone https://aur.archlinux.org/paru.git && \
    cd paru && makepkg --noconfirm -si && cd .. && \
    PARU="paru --noconfirm" && $PARU -Rs rust && rm -rf .cargo paru && \
    $PARU -S neovim-symlinks && \
    yes | paru -Scd && \
    mkdir -p .config/pulse

CMD [ "/bin/bash" ]
