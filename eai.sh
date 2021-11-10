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
    #TODO?
    pacstrap /mnt base base-devel linux linux-firmware dhcpcd vim cryptsetup intel-ucode
}

function base_config() {
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
        #TODO
        arch-chroot /mnt sed -i "s/TODO/HOOKS=\"base udev autodetect keyboard keymap modconf block encrypt filesystems fsck\"/"
        arch-chroot /mnt mkinitcpio -p linux
    fi
}

function create_user() {
    useradd -m -g users -s /bin/bash $USER_NAME
    chpasswd $USER_NAME:$USER_PASSWORD
    arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
    gpasswd -a $USER_NAME wheel
}

function desktop_environment() {
    pacman_install "xorg-server xorg-xinit i3-wm rofi alacritty"
    arch-chroot /mnt cp /etc/X11/xinit/xinitrc /home/$USER/.xinitrc
}

function custom_shell() {
    pacman_install "zsh"
    arch-chroot /mnt chsh -s /usr/bin/zsh $USER
}

function graphics() {
    pacman_install "xf86-video-amdgpu mesa"
}


function main() {

}


systemctl enable --now systemd-timesyncd.service



# tools 
pacman -S git wget
# applications
pacman -S firefox thunderbird gimp 


# fonts
pacman -S noto-fonts (ttf-font-awesome)
# sound 
pacman -S pipewire