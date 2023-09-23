#!/bin/bash 

#Developed by Marins,Matheus

#Introducing you to the game; Function comes first
gwent(){
while true; do
echo "Welcome to the witcher game!!
Please select your class: 
1 - Witcher 
2 - Sorceress
3 - Wizard 
4 - Seller
5 - I give up, I want to go to sleep" 

read class 
#Let's save the player choose
case $class in 
    1) 
        type="Witcher" 
        hp=250
        attack=80
        skills="Kill monsters" 
        ;;
    2) 
        type="Sorceress" 
        hp=150
        attack=60
        skills="Kill monsters and Provide healing"
        ;;
    3)
        type="Wizard" 
        hp=100
        attack=50
        skills="Healiang and magic"
        ;;
    4)
        type="Seller" 
        hp=50
        attack=10
        skills="What you're buying?"
        ;;
    5)  
        echo "Ok, deal with it"
        exit 1
        ;;
esac 

echo "Perfect! You choose $type, you have attack power = $attack, hp = $hp and your skills is '$skills'"

# Seller has a different options
if [[ $class -eq 4 ]]; then 
    echo "
    1 - Potion 
    2-  Sword
    3 - Armor"
    read option
    case $option in
        1)
            echo "Potion has been add in your backpack"
            ;;
        2)
            echo "Perfect! Now you are ready to the battle! Good Luck" 
            ;;
        3) 
            echo "I'm sure now you'll be protected now! Good Luck in your trip" 
            ;;
    esac
    exit 1
fi
#First Battle 

echo "Now, your first battle approaches! This time it's going to be easy" 

#the  number of beast 
beast=$(( $RANDOM % 2 ))

#Saving the player number
echo "Ok, the beast comes, now pick a number between 0-1. (0/1)"
read player

#Trying to ensure that the number entered is between 0-1
if [[ $player != 1 && $player != 0 ]]; then 
    echo "Come on $USER! I said 0-1"
    exit 1
fi

#Conditional 
if [[ $beast == $player ]]; then 
    echo "Congrats my $type, beast is VANQUISHED!! Congrats"
else 
    echo "You died!"
    exit 1
fi 
sleep 3

#It's getting hard, let's get this to another level
echo "Now, it's time to the Boss Battle. It's a Higher Vampire!!! Pick a number between 0-9. (0-9)"
read player

#Define the beast again
beast=$(( $RANDOM % 10 )) # random count start with 0

#Trying to ensure that the number entered is between 0-9
if [[ $player -gt 9 && $player == "hack" ]]; then 
    echo "Come on guy! I said 0-1"
    exit 1
fi
# Battle
if [[ $beast == $player || $player == "hack" ]]; then 
    echo "Congrats my $type, you defeat a Higher Vampire!! Congrats"
    sleep 3
else 
    echo "You died!"
    exit 1
fi 
done
}

#Asking if wants to play the game
echo "Do you want to play a game ? (S/N)"
read choice

#Ensuring that the uppercase is maintained
choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]')

if [[ $choice == "S" ]]; then
    gwent
elif [[ $choice == "N" ]]; then 
    echo "Ok, see you soon!"
    exit 1
fi
