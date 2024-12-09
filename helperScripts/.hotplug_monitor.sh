#! /usr/bin/bash

export DISPLAY=:0
export XAUTHORITY=/home/theruvial/.Xauthority

function connect(){
    xrandr --output HDMI-A-0 --auto
    xrandr --output HDMI-A-0 --above eDP --preferred --output eDP --preferred --primary 
}

function disconnect(){
      xrandr --output HDMI-A-0 --off
}

xrandr | grep "HDMI-A-0 connected" &> /dev/null && connect || disconnect
