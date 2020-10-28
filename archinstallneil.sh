#!/bin/bash

loadkeys uk
lsblk
echo
echo
read -p "What drive do you want to use?: " DRIVEVAR
cfdisk /dev/"${DRIVEVAR}"
clear
lsblk
echo
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
timedatectl set-ntp true
mkfs.fat -F32 /dev/"${DRIVEVAR}""${EFIVAR}"
mkfs.ext4 /dev/"${DRIVEVAR}""${SYSVAR}"
# mkfs.ext4 /dev/"${DRIVEVAR}""${HOMEVAR}"
mount /dev/"${DRIVEVAR}""${SYSVAR}" /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount /dev/"${DRIVEVAR}""${EFIVAR}" /mnt/boot/efi
mkdir /mnt/home
mount /dev/"${DRIVEVAR}""${HOMEVAR}" /mnt/home
pacstrap /mnt base base-devel linux linux-firmware vim networkmanager sudo
genfstab -U /mnt >> /mnt/etc/fstab
ln -sf /usr/share/zoneinfo/Europe/London /mnt/etc/localtime
hwclock --systohc
sed -i 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /mnt/etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" >> /mnt/etc/locale.conf
echo "KEYMAP=uk" > /mnt/etc/vconsole.conf
echo "${HOSTVAR}" > /mnt/etc/hostname
echo "127.0.0.1	localhost" >> /mnt/etc/hosts
echo "::1		localhost" >> /mnt/etc/hosts
echo "127.0.1.1	"${HOSTVAR}".localdomain	"${HOSTVAR}"" >> /mnt/etc/hosts
clear
echo
echo "Create Root Password"
arch-chroot /mnt passwd
arch-chroot /mnt pacman -Syu grub efibootmgr --noconfirm
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot /mnt useradd -m -G wheel -s /bin/bash "${USERVAR}"
clear
echo
echo "Create User Password"
arch-chroot /mnt passwd "${USERVAR}"
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /mnt/etc/sudoers
arch-chroot /mnt systemctl enable NetworkManager
exit

