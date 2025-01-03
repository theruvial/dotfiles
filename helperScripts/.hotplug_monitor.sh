#! /usr/bin/bash

export DISPLAY=:0
export XAUTHORITY=/home/theruvial/.Xauthority

function connect(){
    xrandr --output DP-1-0.5 --auto
    xrandr --output DP-1-0.6 --auto
    xrandr --output DP-1-0.5 --above eDP --preferred --output DP-1-0.6 --right-of DP-1-0.5 --output eDP --preferred --primary 
}

function disconnect(){
      xrandr --output DP-1-0.5 --off
      xrandr --output DP-1-0.6 --off
}

xrandr | grep "DP-1-0.5 connected" &> /dev/null && connect || disconnect
