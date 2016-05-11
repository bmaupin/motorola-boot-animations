#!/bin/bash

prefix=bootanimation-nonstock-

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
    # First, create a new bootanimation.zip that will be compatible
    mkdir tmp
    cd tmp
    unzip ../boot-animations/$animation/bootanimation.zip
    ffprobe 02_globe.mp4 2>&1 | grep fps | grep -q 720x1280
    mkdir part0 part1
    # Use a lower quality for the stitch animation. Since it has a textured 
    # background it's much larger at higher qualities
    if [ "$animation" == "stitch" ]; then
        quality=5
    else
        quality=2
    fi
    fps=`ffprobe 01*.mp4 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p"`
    resolution1=`ffprobe 01*.mp4 2>&1 | grep fps | grep -oP "\d{3,}x\d{3,}" | sed 's/x/ /'`
    ffmpeg -i 01*.mp4 -r $fps -qscale:v $quality part0/%5d.jpg
    fps=`ffprobe 02*.mp4 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p"`
    resolution2=`ffprobe 01*.mp4 2>&1 | grep fps | grep -oP "\d{3,}x\d{3,}" | sed 's/x/ /'`
    if [ "$resolution1" != "$resolution2" ]; then
        echo "Error: video resolutions don't match for $animation animation"
        cd ..
        rm -rf tmp
        continue
    fi
    ffmpeg -i 02*.mp4 -r $fps -qscale:v $quality part1/%5d.jpg
    rm *.*
    echo "$resolution1 $fps
c 1 0 part0
c 0 0 part1
" > desc.txt
    # The files must not be compressed
    zip -0r bootanimation.zip desc.txt part0 part1

    # Put it all together
    zip ../$prefix$animation.zip bootanimation.zip
    cd ..
    rm -rf tmp
    cd boot-animations/$animation
    zip -r ../../$prefix$animation.zip logo *.png
    cd ../..
    zip -r $prefix$animation.zip META-INF
done
