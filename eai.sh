#!/usr/bin/env bash

# EasyArchInstall (eai)
# change vars

USER_NAME=                              #example: USER_NAME="expert"
USER_PASSWORD=                          #example: USER_PASSWORD="123456"
HOSTNAME=                               #example: HOSTNAME="blackrock"
TIMEZONE=                               #example: TIMEZONE="Europe/Berlin" 
LOCALES=                                #example: LOCALES=("en_US.UTF-8","en_DK.UTF-8")
VM=                                     #example: VM=false
DEVICE=                                 #example: DEVICE=mmblk0

function check() {
    echo "Username: $USER_NAME"
    echo "User-Password: $USER_PASSWORD"
    echo "Hostname: $HOSTNAME"
    echo "Timezone: $TIMEZONE"
    echo "Locales: $LOCALES"
    echo "VM: $VM"
    read "everyting correct? [y/N]" CHECK
    if [ "$CHECK" !== "y" ]; then
        exit 0
    fi
    echo "see ya on the other side...."
}

function partitioning() {
    sgdisk --zap-all /dev/$DEVICE
    sgdisk -o /dev/$DEVICE
    sgdisk -n 1:0:512M /dev/$DEVICE
    sgdisk -t 1:ef00 /dev/$DEVICE
    sgdisk -n 2:0:0 /dev/$DEVICE
    sgdisk -t 2:8300 /dev/$DEVICE
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

function bootloader() {
    arch-chroot /mnt blkid -s UUID -o value /dev/nvme0n1p2 > /boot/loader/entries/arch-uefi.conf
    echo "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /intel-ucode.img\ninitrd /initramfs-linux.img\noptions cryptdevice=UUID=6b220a55-ebe1-4c95-8804-4227f4e13c8a:cryptroot root=/dev/mapper/cryptroot rw" > /boot/loader/entries/arch-uefi.conf
    echo "title Arch Linux (fallback initramfs)\nlinux /vmlinuz-linux\ninitrd /intel-ucode.img\ninitrd /initramfs-linux-fallback.img\noptions cryptdevice=UUID=6b220a55-ebe1-4c95-8804-4227f4e13c8a:cryptroot root=/dev/mapper/cryptroot rw" > /boot/loader/entries/arch-uefi-fallback.conf
    #TODO check command
    echo "default arch-uefi.conf\ntimeout 3" > /boot/loader/loader.conf
    arch-chroot /mnt bootctl update
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
    check()
    partitioning()
    if [ ! $VM ]; then
        encryption()
    fi
    base()


}