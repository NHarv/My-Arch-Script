#!/bin/bash

# Setting Keyboard Layout

loadkeys uk
lsblk
echo
echo

# Partitioning Drive

read -p "What drive do you want to use?: " DRIVEVAR
cfdisk /dev/"${DRIVEVAR}"
clear
lsblk
echo

# Collecting Information

read -p "             EFI Partition No?: " EFIVAR
echo
read -p "          System Partition No?: " SYSVAR
echo
read -p "            Home Partition No?: " HOMEVAR
echo
read -p "                    Host Name?: " HOSTVAR
echo
read -p "                    User Name?: " USERVAR
clear

# Time date setup

timedatectl set-ntp true

# Formatting Partitions

mkfs.fat -F32 /dev/"${DRIVEVAR}""${EFIVAR}"
mkfs.ext4 /dev/"${DRIVEVAR}""${SYSVAR}"
# mkfs.ext4 /dev/"${DRIVEVAR}""${HOMEVAR}"

# Mounting Partitions

mount /dev/"${DRIVEVAR}""${SYSVAR}" /mnt
mkdir -p /mnt/boot/efi
mount /dev/"${DRIVEVAR}""${EFIVAR}" /mnt/boot/efi
mkdir /mnt/home
mount /dev/"${DRIVEVAR}""${HOMEVAR}" /mnt/home

# Installing Base System

pacstrap /mnt base base-devel linux linux-firmware vim nano networkmanager sudo

# Generating Fstab

genfstab -U /mnt >> /mnt/etc/fstab

# time Zone setup

ln -sf /usr/share/zoneinfo/Europe/London /mnt/etc/localtime

# Hardware Clock setup

hwclock --systohc

# Setting Locale

sed -i 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /mnt/etc/locale.gen
locale-gen

# local Host setup

echo "LANG=en_GB.UTF-8" >> /mnt/etc/locale.conf
echo "KEYMAP=uk" > /mnt/etc/vconsole.conf
echo "${HOSTVAR}" > /mnt/etc/hostname
echo "127.0.0.1	localhost" >> /mnt/etc/hosts
echo "::1		localhost" >> /mnt/etc/hosts
echo "127.0.1.1	"${HOSTVAR}".localdomain	"${HOSTVAR}"" >> /mnt/etc/hosts
clear
echo

# Create Root Password

echo "Create Root Password"
arch-chroot /mnt passwd

# Install Grub

arch-chroot /mnt pacman -Syu grub efibootmgr --noconfirm
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Adding User

arch-chroot /mnt useradd -m -G wheel -s /bin/bash "${USERVAR}"
clear
echo

# Create User Password

echo "Create User Password"
arch-chroot /mnt passwd "${USERVAR}"

# setup User Sudo Priverlages

sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /mnt/etc/sudoers

# Enabling Services

arch-chroot /mnt systemctl enable NetworkManager

# Install Xorg

arch-chroot /mnt pacman -S xorg xorg-xinit xterm --noconfirm

#Install General Software and AUR

arch-chroot /mnt pacman -S picom nitrogen yay --noconfirm

exit

