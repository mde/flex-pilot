#!/bin/sh

./build.py -t all
cp org/flex_pilot/FlexPilot.swf tests
(cd tests && ./build.py -t all)
