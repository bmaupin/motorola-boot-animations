#!/bin/bash

prefix=bootanimation-

# Cleanup
rm -f $prefix*.zip

# Check for logo files > 4 MiB (The logo partition on Moto G devices is exactly 4 MiB)
error=false
for logo in `ls -1 boot-animations/*/logo/*/logo.bin`; do
    if [ `stat --printf="%s" $logo` -gt 4194304 ]; then
        echo "ERROR: logo file is greater than 4 MiB: $logo"
        error=true
    fi
done

# Abort on error
if [ "$error" = true ]; then
    echo "Please reduce the size of logo files and try again"
    exit 1
fi

# Zip the boot animations
for animation in `ls -1 boot-animations`; do
    cd boot-animations/$animation
    zip -r ../../$prefix$animation.zip .
    cd ../..
    zip -r $prefix$animation.zip META-INF
done
