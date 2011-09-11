#!/bin/bash

beanstalk -d && god -c ../config/god.rb && forever start /usr/local/bin/juggernaut