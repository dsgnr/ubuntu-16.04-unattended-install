# Ubuntu 16.04 Unattended-Install for UEFI using preseed
Create a Legacy and UEFI automated Ubuntu ISO installer. Using preseed.cfg and post-install scripts, this can completely automate installing Ubuntu 16.04. This may work with other distros, but I have yet to test this. Your personal variables such as default packages, SSH keys and username/password will obviously need to be edited before use.

Follow the steps below to create your own image.

    cd /root
    wget http://releases.ubuntu.com/16.04.2/ubuntu-16.04.2-server-amd64.iso

### Extract ISO
    xorriso -osirrox on -indev ubuntu-16.04.2-server-amd64.iso -extract / custom-iso

### Edit /boot/grub/grub.cfg
This is for UEFI booting. This specifies the timeout on the grub menu to 1 second, tells grub what network adapter to use and grabs the preseed file.

    cd /root/custom-iso
    nano boot/grub/grub.cfg

Replace the contents with grub.cfg with the following. __Make sure you alter the HTTP location of your preseed file!__

    if loadfont /boot/grub/font.pf2 ; then
            set gfxmode=auto
            insmod efi_gop
            insmod efi_uga
            insmod gfxterm
            terminal_output gfxterm
    fi
    set default=0
    set timeout=1
    set menu_color_normal=white/black
    set menu_color_highlight=black/light-gray

    menuentry "Install Ubuntu Server" {
            set gfxpayload=keep
            linux /install/vmlinuz gfxpayload=800x600x16,800x600 hostname=ubuntu16-04 --- auto=true url=http://preseed.handsoff.local/ubuntu-16-04/preseed.cfg quiet
            initrd  /install/initrd.gz
    }

### Edit /isolinux/txt.cfg
If you do not want to enable preseeding on a legacy device, this step isn't necessary.

    nano isolinux/txt.cfg

Replace the contents with the following. __Make sure you alter the HTTP location of your preseed file!__

    GRUB_DEFAULT=0
    GRUB_HIDDEN_TIMEOUT=0
    GRUB_HIDDEN_TIMEOUT_QUIET=true
    GRUB_TIMEOUT=1

    default install
    label install
    menu label ^Install Ubuntu Server
    kernel /install/vmlinuz
    append preseed/url=http://preseed.handsoff.local/ubuntu-16-04/preseed.cfg bga=788 netcfg/choose_interface=auto initrd=/install/initrd.gz priority=critical --

## Obtain isohdpfx.bin for hybrid ISO

    cd ../
    sudo dd if=ubuntu-16.04.2-server-amd64.iso bs=512 count=1 of=custom-iso/isolinux/isohdpfx.bin

## Create new ISO

    cd custom-iso
    sudo xorriso -as mkisofs -isohybrid-mbr isolinux/isohdpfx.bin -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -o ../custom-ubuntu-http.iso .

## Confirm partitions
As we have created a hybrid ISO, meaning it can be used in both UEFI and Legacy modes, it's good to make sure EFI is showing in the partition table. You can check this by using the following command:

    fdisk -l custom-ubuntu-http.iso

If the partitions have been created correctly, you should see something similar to the following:

    Disk custom-ubuntu-http.iso: 841 MiB, 881852416 bytes, 1722368 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x19a15b31

    Device                  Boot Start     End Sectors  Size Id Type
    custom-ubuntu-http.iso1 *        0 1722367 1722368  841M  0 Empty
    custom-ubuntu-http.iso2       4036    8899    4864  2.4M ef EFI (FAT-12/16/32)
    
## Preseed file
Upload preseed .cfg file to location specified in grub.cfg/txt.cfg. As we have specified networking within the Grub menu, we are now able to pull the preseed file over network using DHCP.

## User passwords
You can either encrypt your password, or pass it over plain text. If you want to use plain text, then comment the line `d-i passwd/user-password-crypted` and uncomment the two lines above containing `passwd/user-password` and `passwd/user-password-again`. __Don't forget to update your password__. If you would like to hash the password, enter the following line. This will prompt for a password and return a hash for you to use. You must then add your hash to the preseed.cfg file. 
    
    mkpasswd -m sha-512

## Post install script

* Explain this!

