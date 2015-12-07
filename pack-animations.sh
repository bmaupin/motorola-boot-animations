#!/bin/bash

PREFIX=bootanimation-

# Cleanup
rm $PREFIX*.zip

for ANIMATION in `ls -1 boot-animations`; do cd boot-animations/$ANIMATION; zip -r ../../$PREFIX$ANIMATION.zip .; cd ../..; zip -r $PREFIX$ANIMATION.zip META-INF; done
