#!/bin/bash

stock_prefix=bootanimation-stockrom-
nonstock_prefix=bootanimation-customrom-

# Cleanup
rm -f $stock_prefix*.zip
rm -f $nonstock_prefix*.zip

# Check for logo files > 4 MiB (The logo partition on Moto G devices is exactly 4 MiB)
error=false
for logo in `ls -1 common/boot-animations/*/logo/*/logo.bin`; do
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

# Zip the boot animations for stock ROMs
for animation in `ls -1 common/boot-animations`; do
    cd common
    zip -r ../$stock_prefix$animation.zip META-INF
    cd ../stock
    zip -r ../$stock_prefix$animation.zip META-INF
    cd ../common/boot-animations/$animation
    zip -r ../../../$stock_prefix$animation.zip .
    cd ../../..
done

# Zip the boot animations for custom ROMs
for animation in `ls -1 common/boot-animations`; do
    # First, create a new bootanimation.zip that will be compatible
    mkdir tmp
    cd tmp
    unzip ../common/boot-animations/$animation/bootanimation.zip
    mkdir part0 part1

    # Use a lower quality for the stitch animation. Since it has a textured 
    # background it's much larger at higher qualities
    if [ "$animation" == "stitch" ]; then
        quality=5
    else
        quality=2
    fi
    video1=`ls -1 *.mp4 | head -n 1`
    video2=`ls -1 *.mp4 | head -n 2 | tail -n 1`
    resolution1=`ffprobe $video1 2>&1 | grep fps | grep -oP "\d{3,}x\d{3,}" | sed 's/x/ /'`
    resolution2=`ffprobe $video2 2>&1 | grep fps | grep -oP "\d{3,}x\d{3,}" | sed 's/x/ /'`
    if [ "$resolution1" != "$resolution2" ]; then
        echo "Error: video resolutions don't match for $animation animation"
        cd ..
        rm -rf tmp
        continue
    fi

    # Make sure resolution is no higher than what the device supports
    read width height <<<$resolution1
    if [ "$width" -gt 720 ]; then
        width=720
    fi
    if [ "$height" -gt 1280 ]; then
        height=1280
    fi
    fps=`ffprobe $video1 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p"`
    ffmpeg -i $video1 -r $fps -qscale:v $quality -vf scale=$width:$height part0/%5d.jpg
    fps=`ffprobe $video2 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p"`
    ffmpeg -i $video2 -r $fps -qscale:v $quality -vf scale=$width:$height part1/%5d.jpg
    rm *.*
    echo "$width $height $fps
c 1 0 part0
c 0 0 part1
" > desc.txt
    # The files must not be compressed
    zip -0r bootanimation.zip desc.txt part0 part1

    # Put it all together
    zip ../$nonstock_prefix$animation.zip bootanimation.zip
    cd ..
    rm -rf tmp
    cd common
    zip -r ../$nonstock_prefix$animation.zip META-INF
    cd ../nonstock
    zip -r ../$nonstock_prefix$animation.zip META-INF
    cd ../common/boot-animations/$animation
    zip -r ../../../$nonstock_prefix$animation.zip logo *.png
    cd ../../..
done
