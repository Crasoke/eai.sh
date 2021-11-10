#!/usr/bin/env bash

# EasyArchInstall (eai)
# change configs

USER_NAME=""
USER_PASSWORD=""
HOSTNAME=""
TIMEZONE="Europe/Berlin"
LOCALES=("en_US.UTF-8","en_DK.UTF-8")
VM=false #true or false

function partitioning() {
    #TODO
}

function encryption() {
    #TODO
}

function base() {
    pacstrap /mnt base base-devel linux linux-firmware dhcpcd vim cryptsetup 
    if ! $VM ; then
        pacstrap /mnt intel-ucode
    fi
    genfstab -U /mnt > /mnt/etc/fstab
    arch-chroot /mnt echo $HOSTNAME > /etc/hostname
    arch-chroot /mnt echo LANG=en_US.UTF-8 > /etc/locale.conf
    arch-chroot /mnt echo LC_TIME=en_DK.UTF-8 >> /etc/locale.conf
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    arch-chroot /mnt sed -i "s/#en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen
    for LOCALE in "${LOCALES[@]}"; do
        sed -i "s/#$LOCALE/$LOCALE/" /etc/locale.gen
    done
    locale-gen
    if ! $VM ; then
        #TODO complete sed command
        arch-chroot /mnt sed -i "s/TODO/HOOKS=\"base udev autodetect keyboard keymap modconf block encrypt filesystems fsck\"/"
        arch-chroot /mnt mkinitcpio -p linux
    fi

    arch-chroot /mnt systemctl enable --now systemd-timesyncd.service
}

function create_user() {
    useradd -m -g users -s /bin/bash $USER_NAME
    chpasswd $USER_NAME:$USER_PASSWORD
    arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
    gpasswd -a $USER_NAME wheel
}

function tools() {
    #TODO add more stuff
    arch-chroot /mnt pacman -Syu --noconfirm git wget
}

function custom_shell() {
    #TODO https://github.com/romkatv/powerlevel10k
    arch-chroot /mnt pacman -Syu --noconfirm zsh
    arch-chroot /mnt chsh -s /usr/bin/zsh $USER
}

function fonts() {
    arch-chroot /mnt pacman -Syu --noconfirm noto-fonts
    #TODO font priority
}

function sound() {
    arch-chroot /mnt pacman -Syu --noconfirm pipewire
    #TODO stuff with DE
}

function desktop_environment() {
    #TODO add i3 config and polybar stuff
    arch-chroot /mnt pacman -Syu --noconfirm xorg-server xorg-xinit i3-wm rofi alacritty
    arch-chroot /mnt cp /etc/X11/xinit/xinitrc /home/$USER/.xinitrc
}

function graphics() {
    arch-chroot /mnt pacman -Syu --noconfirm xf86-video-amdgpu mesa
}

function applications() {
    #TODO more applications
    arch-chroot /mnt pacman -Syu --noconfirm firefox thunderbird gimp
}

function egpu() {
    #TODO https://github.com/hertg/egpu-switcher
}

function main() {
    #TODO everything
}