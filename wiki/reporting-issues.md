Reporting issues
---

1. Go here and create a new issue:  
  https://github.com/bmaupin/motorola-boot-animations/issues

2. Include the following information in the issue:
  - What happened
    - e.g. Logo was updated, boot animation wasn't

  - Any error messages in the log when applying the boot animation zip file
    - Flash the boot animation zip file again if you forgot to look at the log

  - `ro.product.build`
    - This will be output by the boot animation zip file log
    - Flash the boot animation zip file again if you forgot to write it down

  - The output of `mount | grep system`
    - This needs to be done while in Android and not in recovery mode
    - It can be done through the shell using ADB (included in the Android SDK Tools) or by using a terminal emulator like this one:  
      https://play.google.com/store/apps/details?id=jackpal.androidterm

  - The following information from _Settings_ → _About phone_:  
    (Alternatively, go to _About phone_, scroll all the way to the bottom, and take a screenshot)
    - Hardware SKU (should start with XT)
    - Android version
    - System version
    - Build number
