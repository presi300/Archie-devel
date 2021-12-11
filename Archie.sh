#!/usr/bin/env bash
pwd | grep -x "/root"
if [ $? -eq 0 ]; then
    clear
else
    echo "The script is required to be in the /root directory to work!"
    echo "Exitting..."

clear
echo "Welcome to Archie! A simple terminal based installer for Arch linux"
echo "-------------------------------------------------------------------"
echo "Make sure you have a network connection before proceeding with the install"
echo "Press enter to begin"
read pressenter
clear
echo "Chose instalation type:"
echo "-------------------------------------------------------------------"
echo "1 - Full Auto"
echo "2 - Guided"
echo "3 - Manual"
read mode
if [ $mode -eq 1 ]; then
    bash Subscripts/Auto/Auto.sh
elif [ $mode -eq 2 ]; then
    bash Subscripts/Guided/Guided.sh
elif [ $mode -eq 3 ]; then
    bash Subscripts/Manual/Manual.sh
fi
