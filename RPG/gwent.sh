#!/bin/bash 

#Developed by Marins,Matheus

#Introducing you to the game; Function comes first
gwent(){
while true; do

#First of everything, let's garanty the paste Logs exists
if [ ! -d "./Logs" ]; then 
    mkdir ./Logs
fi

echo "Welcome to the witcher game!!
Please select your class: 
1 - Witcher 
2 - Sorceress
3 - Wizard 
4 - Seller
5 - I give up, I want to go to sleep" 

read class 
echo "$class --> being saved" >> ./Logs/logclass.txt
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
sleep 2

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
# For now Seller just have this options, in a futures we'll include more. 
fi
#First Battle 

echo "$type, you are entering in the jungle with many beasts, be careful!" 
sleep 2

#the  number of beast 
beast=$(( $RANDOM % 2 ))

#Saving the player number
echo "Ok, the beast comes, now pick a number between 0-1 to defeat this beast!!! (0/1)"
read player

#Trying to ensure that the number entered is between 0-1
if [[ $player != 1 && $player != 0 ]]; then 
    echo "Come on $USER! I said 0-1"
    exit 1
fi

#Conditional 
if [[ $beast == $player || $player -gt $beast ]]; then 
    echo "Congrats my $type, beast is VANQUISHED!!"
else 
    echo "The beast was  stronger  than you!"
    exit 1
fi 
sleep 3

echo "Perfect, now you are free to explore the jungle, feel free! But look ahead, the dark side it's close!"
sleep 4

#It's getting hard, let's get this to another level
echo "Vampire: What are you doing here? GET OUT NOW!" 
sleep 1

# Vampire get close to intimidate
echo "$type, it's on you, in or out? (I/O)"
read  choice 

choice=$( echo "$choice" | tr a-z A-Z )

# Leaving or not
if [[ $choice == "I" ]]; then
    echo "$type chose to face the Vampire" >> ./Logs/logbrave.txt
else 
    echo "Vampire: Hahahahah I knew it, you are a loser!"
    echo "$type chose not to face the Vampire" >> ./Logs/logbrave.txt
    exit 1
fi

echo "That's awesome! You choose right the people in the village will appreciate!"
sleep 2 
echo "Vampire: Well well if isn't the $type most brave I've ever seen, let's check how powerfull you are"
sleep 2

# Pick up the vampire attack
vampire=$(awk -F'=' '/attack/ {print $2}' vampire.txt)

#Compairs the both attack if diferents ( for now will be always )
if [[ $vampire -lt $attack ]]; then
    echo "Vampire: NOOOOOO, you should be dead now!! I'll return"
    sleep 2 
    echo "Congrats $type, it was a hard battle but this vampire will let our kids in peace for now!"
    sleep 2
    echo " " 
    echo "$type used $attack" >> ./Logs/logattack.txt 
    sleep 2
else 
    echo "Vampire: Hahahahah I knew it, you couldn't do it"
fi 

# #Define the beast again
# beast=$(( $RANDOM % 10 )) # random count start with 0

# #Trying to ensure that the number entered is between 0-9
# if [[ $player -gt 9 && $player == "hack" ]]; then 
#     echo "Come on guy! I said 0-1"
#     exit 1
# fi
# # Battle
# if [[ $beast == $player || $player == "hack" ]]; then 
#     echo "Congrats my $type, you defeat a Higher Vampire!! Congrats"
#     sleep 3
# else 
#     echo "You died!"
#     exit 1
# fi 
 done
}

#Asking if wants to play the game
echo "Do you want to play a game ? (S/N)"
read choice

#Ensuring that the uppercase is maintained
choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]') #Also we can do | tr a-z A-Z 

if [[ $choice == "S" ]]; then
    gwent
elif [[ $choice == "N" ]]; then 
    echo "Ok, see you soon!"
    exit 1
fi
