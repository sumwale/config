# syntax=docker/dockerfile:1

# Creates an Arch Linux image with utility software, AUR setup etc that integrates into the
# current desktop to allow running CLI and GUI apps seemlessly from the desktop environment

FROM quay.io/archlinux/archlinux

LABEL maintainer="Sumedh Wale"

ARG user=lbox-user

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY common/prime-run /usr/local/bin/prime-run

# for some reason TERMINFO_DIRS does not work for root user, so explicitly installing terminfo
# packages for other terminal emulators available in arch which occupy only a tiny space
RUN set -ex && \
    chmod 0755 /usr/local/bin/prime-run && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen en_US.UTF-8 && \
    echo -e "LANG=$LANG\nLANGUAGE=$LANGUAGE\nLC_ALL=$LC_ALL" > /etc/locale.conf && \
    source /etc/locale.conf && export LANG LANGUAGE LC_ALL && \
    pacman-key --init && \
    sed -i 's/^#Color.*/Color/;s/^NoProgressBar.*/#NoProgressBar/' /etc/pacman.conf && \
    sed -i 's,^NoExtract[ ]*=[ ]*/\?usr/share/man.*,#\0,' /etc/pacman.conf && \
    echo -e '[multilib]\nInclude = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf && \
    PAC="pacman --noconfirm" && $PAC -Syy && \
    $PAC -S reflector && \
    sed -i 's/^--latest.*/--latest 50\n--number 5\n--threads 5/' /etc/xdg/reflector/reflector.conf && \
    sed -i 's/^--sort.*/--sort rate/' /etc/xdg/reflector/reflector.conf && \
    reflector @/etc/xdg/reflector/reflector.conf 2>/dev/null && \
    $PAC -Syu && \
    $PAC -S --needed lesspipe bash-completion bc base-devel man-db man-pages sudo pulseaudio-alsa neovim eza ncdu fd bat libva-utils mesa-utils vulkan-tools gtk3 cantarell-fonts ttf-fira-code noto-fonts kitty-terminfo rxvt-unicode-terminfo rio-terminfo wezterm-terminfo wget aria2 btop realtime-privileges python-typeguard && \
    $PAC -S --asdeps git ed unzip fastjar python-pynvim xsel intel-media-driver libva-mesa-driver vulkan-intel vulkan-mesa-layers python-pip && \
    yes | pacman -Scc && $PAC -Syu && rm -rf .cache && \
    sed -i 's/^COMPRESSZST=.*/COMPRESSZST=(zstd -c -T0 -8 -)/' /etc/makepkg.conf && \
    echo -e '\nexport EDITOR=nvim\nexport VISUAL=nvim' >> /etc/bash.bashrc && \
    echo -e 'export PAGER="less -RL"\nexport LESSOPEN="|/usr/bin/lesspipe.sh %s"' >> /etc/bash.bashrc && \
    useradd -m -g users -s /bin/bash -c Linuxbox ${user} && \
    echo "${user} ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${user} && \
    chmod 0400 /etc/sudoers.d/${user}

USER ${user}
WORKDIR /home/${user}

RUN git clone https://aur.archlinux.org/paru-bin.git && \
    cd paru-bin && makepkg --noconfirm -si && cd .. && \
    PARU="paru --noconfirm" && $PARU -Rs paru-bin-debug && \
    $PARU -S neovim-symlinks && yes | paru -Scd && $PARU -Syu && \
    rm -rf .cache .cargo .config .local paru-bin && \
    sudo rm -rf /root/.cache

USER root
WORKDIR /root

RUN userdel -r ${user} && rm -f /etc/sudoers.d/${user}

CMD [ "/bin/bash" ]
