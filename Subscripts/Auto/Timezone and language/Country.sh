#!/usr/bin/env bash

function spacer {
echo "-------------------------------------------------------------------"
}
function continent {
    cat Continents.txt
    echo ""
    spacer
    touch selectedcont.txt
    read -p "Enter the number, shown next to your desired continent: " cont 

    case $cont in

        1)
        echo "Europe" > selectedcont.txt
        ;;
        2)
        echo "Asia" > selectedcont.txt
        ;;
        3)
        echo "North America" > selectedcont.txt
        ;;
        4) 
        echo "South America" > selectedcont.txt
        ;;
        5)
        echo "Africa" > selectedcont.txt
        ;;
        6)
        echo "Australia" > selectedcont.txt
        ;;
        *)
        sudo pacman -S sdofhsdofiho #A GENIUS way to make it error out :)
    esac
}

read -p "Do you need help assistance up a timezone? [Y/n] " tmz
if [ $tmz = y ]; then

    continent    

    while [ $? -ne 0 ]; do #If it errors out, try again until it doesn't
    clear
    echo "Error, not recognised! Press ENTER to try again!"
    echo "" 
    continent
    done

    #Actual country (scuffed AF)
    scont=$(cat selectedcont.txt)


    case $scont in

            "Europe")
            ls /usr/share/zoneinfo/Europe
            ;;
            "Asia")
            ls /usr/share/zoneinfo/Asia
            ;;
            "North America")
            ls /usr/share/zoneinfo/America
            ;;
            "South America") 
            ls /usr/share/zoneinfo/America
            ;;
            "Africa")
            ls /usr/share/zoneinfo/Africa
            ;;
            "Australia")
            ls /usr/share/zoneinfo/Africa
            ;;
    esac
    read -p "Select a city in your country, you recognise (1st letter should be capital) " ctr

else
    clear
    read -p "Enter your Continent/City (1st letter NEEDS to be capital): " $taim && echo $taim > /Archie/Temp_Files/timezone.txt
    timedatectl set-timezone 

    while [ $? -ne 0 ]; do
    echo "Error unrecognised, please try again..."
    read -p "Enter your Continent/City (1st letter NEEDS to be capital): " $taim && echo $taim > /Archie/Temp_Files/timezone.txt
    timedatectl set-timezone 
    done