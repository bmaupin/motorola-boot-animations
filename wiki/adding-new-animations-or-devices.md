## Add a new boot animation

1. Add the boot animation
    1. Get bootanimation.zip
    1. At a minimum, these files are required inside bootanimation.zip:
        - 01_....mp4
        - 02_....mp4
        - videodesc.txt
    1. Remove any carrier folders (att, vzw)
    2. There should only be one video file per number. If there are multiple videos with the same number, delete one.
        - For example, the stitch animation contains these files: 01_intro.mp4, 02_fade.mp4, 02_loop.mp4  
          Remove 02_fade.mp4 so 02_loop.mp4 plays instead.
2. Create the logo
    1. Download the mlogo tool from here:  
    http://forum.xda-developers.com/moto-x/themes-apps/app-moto-x-g-boot-logo-command-line-tool-t2819494
    2. Get the sol.png file that should be included with the boot animation and rename it to logo_preview.png (so it's clear it doesn't serve any purpose other than a preview of the logo)
    3. Copy the logo file from one of the other animations (the logos are from the latest stock ROM for each device)

           cd motorola-boot-animations/newlogo
           cp -r ../aprilfool/logo .

    4. Update logo.bin with the new logo

           cd motorola-boot-animations/newlogo
           read width height <<<$(file logo_preview.png | grep -oP "\d{3,} x \d{3,}" | sed 's/x//g')
           if [ "$width" -gt 720 ] || [ "$height" -gt 1280 ]; then
               mv logo_preview.png logo_preview.png.bak
               convert logo_preview.png.bak -resize 720x1280 logo_preview.png
           fi
           for folder in `ls -1 logo`; do mlogo logo/$folder/logo.bin replace logo_boot logo_preview.png; done
           for folder in `ls -1 logo`; do mlogo logo/$folder/logo.bin replace logo_unlocked logo_preview.png; done
           mv logo_preview.png.bak logo_preview.png

    5. Make sure the new logo.bin files are all 4 MiB or less (pack-animations.sh will verify this)


## Add a new device

1. Get the /dev mount location for the system partition
    1. If you have access to the device:

           adb shell
           mount | grep system

    2. Otherwise:
        1. Download the stock ROM for the device, extract boot.img from the file
        2. Extract the contents of boot.img  
           http://unix.stackexchange.com/a/65316/14436
        3. Look in the fstab.qcom file to get the mount location
2. Get the /dev mount location for the system partition
    1. Take the mount location for the system partition and replace the word `system` with `logo`
3. Get `ro.product.device`
    1. If you have access to the device, it's located in /system/build.prop
    2. Otherwise, you can get it from build.prop in the system partition from a stock ROM
    3. **Important:** TWRP may overwrite `ro.product.device` by putting a different value in /default.prop. To check this:
        1. Download the TWRP image for the device
        2. Extract the image  
           http://unix.stackexchange.com/a/65316/14436
            1. If you get this error: `gzip: twrp-osprey-2.8.7-r4.img-ramdisk.gz: not in gzip format`:

                   mv twrp-osprey-2.8.7-r4.img-ramdisk.gz twrp-osprey-2.8.7-r4.img-ramdisk.lzma
                   xz -d twrp-osprey-2.8.7-r4.img-ramdisk.lzma
                   cpio -idv < twrp-osprey-2.8.7-r4.img-ramdisk

4. Get logo.bin for the device from the device's stock firmware

5. Copy the new device's stock logo.bin

    ```
    device=moto-e4
    for folder in common/boot-animations/*; do
        mkdir -p $folder/logo/$device
        cp /path/to/logo.bin $folder/logo/$device
        mlogo $folder/logo/$device/logo.bin replace logo_boot $folder/logo_preview.png
        mlogo $folder/logo/$device/logo.bin replace logo_unlocked $folder/logo_preview.png
    done
    ```

6. Update nonstock/META-INF/com/google/android/updater-script and stock/META-INF/com/google/android/updater-script with the `ro.product.device` of the new device

7. If your device shows a "bad key" message, additionally append an "orange" image in the logo.bin file

    ```
    device=moto-e4
    for folder in common/boot-animations/*; do
        mkdir -p $folder/logo/$device
        cp /path/to/logo.bin $folder/logo/$device
        mlogo $folder/logo/$device/logo.bin append orange $folder/logo_preview.png
    done
    ```


## Troubleshooting

#### Boot animation doesn't change after adding new device

1. Get the bootanimation binary for the device from the stock ROM or from /system/bin/bootanimation

2. See what the supported locations for bootanimation.zip are and adjust the stock updater-script as necessary

    ```
    strings bootanimation | grep bootanimation.zip
    /customize/bootanimation.zip
    /oem/media/bootanimation.zip
    /system/media/bootanimation.zip
    ```

    **Note**: if you don't get any results in /system/bin/bootanimation, see if there's a bootanimation library (e.g. /system/lib64/libbootanimation.so) and try that instead

    - `/customize` is part of the root filesystem and can't be modified except by modifying boot.img
    - Writing to `/system/` is no longer supported as of Android 7/N
        - Even for earlier versions it's not recommended as it will likely cause OTA updates to fail
