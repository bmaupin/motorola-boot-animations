## Installation

1. Unlock bootloader (if it hasn't been unlocked yet)  
    Note: this only needs to be done one time for each phone
    1. Enable developer options  
        _Settings_ > _About phone_ > tap _Build number_ 7 times. You should see the message: "You are now a developer!"

    2. Enable OEM unlock
        _Settings_ > _Developer options_ > check _Enable OEM unlock_

    3. Follow instructions here:  
        https://motorola-global-portal.custhelp.com/app/standalone/bootloader/unlock-your-device-a

2. Download the desired boot animation  
    https://github.com/bmaupin/motorola-boot-animations/releases
    - Download one of the stock ROM packages if you're running a stock ROM (if you're not sure, you're probably running a stock ROM)
    - Download one of the custom ROM packages if you're running a custom ROM (CyanogenMod, Omni, etc)

3. Copy the boot animation zip file to the phone (either internal storage or the SD card)

4. Boot to a custom recovery
    - If you already have a custom recovery installed:
        1. Boot to fastboot mode  
            Power off the phone, press and hold volume down button, press power button, hold both for about 5 seconds and then let go

        2. Boot to recovery mode
            Note: recovery mode may be a little slow to load, just wait a minute or two and it should load
            - Moto G 2015
                1. Press volume down until you see _RECOVERY MODE_
                2. Press the power button

            - Moto G 2013/2014
                1. Press volume down and select _Recovery_
                2. Press the volume up button

    - Otherwise:
        1. Install the Android SDK platform tools
            - Ubuntu:

                  sudo apt-get install android-tools-adb
                  sudo apt-get install android-tools-fastboot

            - OS X:

                  brew install android-platform-tools

            - Windows:  
                http://forum.xda-developers.com/showthread.php?p=48915118

            - Others:  
                https://developer.android.com/sdk/index.html#Other

        2. Download a compatible custom recovery for your phone
            - Moto G 2015  
                http://forum.xda-developers.com/2015-moto-g/orig-development/twrp-twrp-moto-g-2015-t3170537

            - Moto G 2014  
                http://forum.xda-developers.com/moto-g-2014/orig-development/recovery-twrp-2-8-2-0-touch-recovery-t2979149

            - Moto G 2014 LTE  
                http://forum.xda-developers.com/moto-g-lte/orig-development/recovery-twrp-2-8-6-0-touch-recovery-t3088800

            - Moto G 2013  
                http://forum.xda-developers.com/moto-g/development/recovery-twrp-2-8-2-0-touch-recovery-t2980621

            - Moto G 2013 LTE  
                http://forum.xda-developers.com/moto-g/4g-development/collection-somcom3xs-experimental-corner-t2996266

        3. Boot the custom recovery
            1. Boot to fastboot mode  
                Power off the phone, press and hold volume down button, press power button, hold both for about 5 seconds and then let go

            2. (Optional) Flash the custom recovery  
                **Warning:** a custom recovery will break OTA updates. You will need to flash the stock recovery first before attempting to install any OTA updates.
            
                   sudo fastboot flash recovery twrp-2.8.7.0.-falcon_STOCK_NOTHEME.img

            3. Boot the custom recovery
            
                   sudo fastboot boot twrp-2.8.7.0.-falcon_STOCK_NOTHEME.img

6. Flash the boot animation
    1. Tap _Install_
    2. At the top tap _Storage_ and change to the storage where you copied the boot animation zip file
    3. Scroll down and tap the boot animation zip file
    4. At the bottom swipe to confirm
    5. The log at the top should show the value of `ro.product.build`. Make note of it in case you have any problems
    5. Check the log at the top for any errors
    6. Tap _Reboot System_

7. If you run into problems *after* flashing the boot animation, report them here: [Reporting issues](reporting-issues.md)


## Manual installation

If for some reason you want to install the logo or boot animation manually (for example, if you only want to install one or the other, or you have a locked bootloader), follow these steps:


#### Install the boot animation (Android 6 and below)
1. Download the desired boot animation  
    https://github.com/bmaupin/motorola-boot-animations/releases

2. Extract bootanimation.zip from the file you downloaded

3. Copy the new bootanimation.zip to the phone

       adb push bootanimation.zip /sdcard/

4. See if /data/local/moodle/bootanimation.zip exists

       adb shell
       su
       ls /data/local/moodle/bootanimation.zip

5. If /data/local/moodle/bootanimation.zip exists:

       adb shell
       su
       cp /sdcard/bootanimation.zip /data/local/moodle

6. If /data/local/moodle/bootanimation.zip doesn't exist:
    1. Remount /system as read-write

           adb shell
           su
           mount -o remount,rw /system

    2. Put the new bootanimation.zip file in place and set the permissions

           cp /sdcard/bootanimation.zip /system/media
           chmod 644 /system/media/bootanimation.zip

    3. Clean up

           rm /sdcard/bootanimation.zip
           mount -o remount,ro /system


#### Install the boot animation (Android 7 and above)
1. Download the desired boot animation  
    https://github.com/bmaupin/motorola-boot-animations/releases

1. Extract bootanimation.zip from the file you downloaded

1. (Optional) Get the size of your phone's OEM partition

    1. Boot your phone into a root shell or TWRP and connect using adb

    1. Run these commands to get the partition size:

        ```
        # ls -l /dev/block/bootdevice/by-name/oem
        lrwxrwxrwx    1 root         root                21 Jan  2  1970 /dev/block/bootdevice/by-name/oem -> /dev/block/mmcblk0p51
        # cat /proc/partitions | grep mmcblk0p51
        259       19     671744 mmcblk0p51
        ```
        In this example, the partition size is 671744.

1. Create a new OEM partition image with the new boot animation

    If desired, change `count=...` to the size of your phone's OEM partition. If not, 16MB (as in the example below) should be plenty.

    ```
    dd if=/dev/zero of=oem.raw.img.new bs=1024 count=16384
    mkfs.ext4 oem.raw.img.new
    sudo mkdir -p /mnt/oem
    sudo mount oem.raw.img.new /mnt/oem
    # oem.prop seems to be necessary because build.prop may refer to it
    sudo touch /mnt/oem/oem.prop
    sudo mkdir /mnt/oem/media
    sudo cp /path/to/bootanimation.zip /mnt/oem/media/
    sudo umount /mnt/oem
    ```

1. Boot your phone into fastboot mode and flash the new OEM partition

    ```
    sudo fastboot flash oem oem.raw.img.new
    ```


#### Install the logo (requires an unlocked bootloader)
1. Download the desired boot animation (the logo is included)  
    https://github.com/bmaupin/motorola-boot-animations/releases

2. Extract the appropriate logo from the file you downloaded  
   e.g. If you have the Moto G 2014 LTE, extract logo/moto-g-2014/logo.bin

3. Boot to fastboot mode (see above)

4. Flash the logo (requires the Android SDK Tools; see above)

       sudo fastboot flash logo logo.bin
