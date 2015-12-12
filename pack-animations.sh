#!/bin/bash

prefix=bootanimation-

# Cleanup
rm -f $prefix*.zip

for animation in `ls -1 boot-animations`; do cd boot-animations/$animation; zip -r ../../$prefix$animation.zip .; cd ../..; zip -r $prefix$animation.zip META-INF; done
