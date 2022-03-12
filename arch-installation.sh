# Configure time
timedatectl set-ntp true

# Setup partitions
lsblk
cfdisk /dev/sda (gpt for > 2TB otherwise dos)
	boot partition (press B) 128M
	root partition (the rest of the space)
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda2

# Mount partitions
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# Install bae system
pacstrap /mnt base base-devel linux linux-firmware vim

# Generate fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Change root to mounted partitions
arch-chroot /mnt

# Set root password
passwd

# Install base packages
pacman -S networkmanager grub os-prober git sudo neofetch zsh go

# Enable network service
systemctl enable NetworkManager

# Install and configure Grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Configure system locale
vim /etc/locale.gen (find and uncomment "en_US.UTF-8 UTF-8")
locale-gen
printf "LANGUAGE=en_US.UTF-8\nLC_ALL=en_US.UTF-8\nLANG=en_US.UTF-8\nLC_CTYPE=en_US.UTF-8" >> /etc/locale.conf

# Configure hostname
echo "arch" >> /ect/hostname

# Configure timezone
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

# Setup new user
useradd -m tengu
echo "tengu:tengu" | chpasswd
usermod --append --groups wheel tengu
visudo (find and uncomment "%wheel ALL=(ALL) ALL" under "User privilege specification" block)

# Install other packages
su - tengu
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Exit & reboot
exit
umount -R /mnt
reboot
