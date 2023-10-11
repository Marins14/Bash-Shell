#!/bin/bash 

#################################################
#               The Witcher Game!               #
#################################################
# Developed by: Matheus Marins                  #
# V1.0                                          #
# Date: 2023/10/10                              #
# Att: --/--/--                                 #
#################################################

#The combat against Vampire
combatAgainstVampire() {
    playerHp=$hp
    vampireHp=$(awk -F'=' '/attack/ {print $2}' vampire.txt)

    # Vampire get close to intimidate
    for (( round=1; round <= 3; round++ )); do
        echo "Roud: $round"
        performPlayerAttack
        performVampireAttack
    done
}

#The Player Attack
performPlayerAttack(){
    echo "It's your turn, $type! Choose your action:"
    echo "
        1 - Normal Attack 
        2 - Special Attack"
    read playerAction

    case $playerAction in
        1)
            playerDamage=$(( RANDOM % 30 + 20 )) # Normal Attack
            ;;
        2)
            playerDamage=$(( RANDOM % 50 + 30 )) # Special Attack
            ;;
        *)
            echo "Invalid choice. Assuming normal attack"
            playerDamage=$(( RANDOM % 30 + 20 ))
            ;;
        esac

        echo "You dealt $playerDamage damage to the Vampire!"
        vampireHp=$(( $vampireHp - $playerDamage ))
}

#The vampire attack 
performVampireAttack(){
    vampireDamage=$(( RANDOM % 20 + 10 ))
    echo "The Vampire dealt $vampireDamage damage to you!"
    playerHp=$(( $playerHp - $vampireDamage ))

    if [[ $playerHp -le 0  ]]; then
        echo "You have been defeated by Vampire. Game over!"
        exit 1
    else
        echo "You have $playerHp HP remaining."
    fi 

}

firstBattle(){
#Combat
player_victory_condition(){
    beastHp=$(( RANDOM % 50 ))

    # Player attacks the beast
    playerDamage=$attack

    echo "You attack the $beast_description with your sword and deal $playerDamage damage."

    beastHp=$(( $beastHp - $playerDamage ))

    if [[ $beastHp -le 0 ]]; then
        return 0  # Player wins
    else
        return 1  # Player doesn't win yet
    fi
}

#The First Battle
echo "$type, you are entering the jungle with many beasts. Be careful!"
sleep 2

# Beast Description
beast_description="a fearsome black wolf with glowing eyes"
echo "A $beast_description approaching you!"

# Take a Decision
echo "What will you do?"
echo "1 - Attack"
echo "2 - Get Out Now!"
read player_decision
echo "$player_decision --> being saved" >> ./Logs/logdecision.txt

# Case of your decision
case $player_decision in
    1)
        echo "You attack the beast"
        player_victory_condition
        ;;
    2)
        echo "You are weak! The beast will attack the village!"
        exit 1
        ;;
    *)
        echo "Invalid choice. The $beast_description attacks you!"
        ;;
esac


#Combat Result
if [[ $? -eq 0 ]]; then
    echo "Congratulations, you defeated $beast_description!"
else
    echo "The $beast_description was too strong. You are defeated."
    echo "Sorry, you are dead. Game over!"
    exit 1
fi
}

#The evoluate Performance
evaluatePerformance(){
    echo "Let's see your performance...."

    if [[ $playerHp > 70 ]]; then 
        echo "Congratulations! You emerged victorious with great strength!"
        echo "You have achieved the Best Ending."
    elif [[ $playerHp > 30 ]]; then
        echo "You survived, but it was a tough battle."
        echo "You have achieved a Good Ending."
    else
        echo "Unfortunately, you were defeated. Better luck next time!"
        echo "You have achieved a Bad Ending." 
    fi
}

# The game starts here!
#Introducing you to the game; Function comes first
gwent(){
while true; do

# Providing player options
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

#The types has a differents attributes
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
    *)
        echo "Invalid choid. Assuming Witcher"
        type="Witcher" 
        hp=250
        attack=80
        skills="Kill monsters" 
        ;;
esac 

#That's it, let's play
echo "Perfect! You choose $type, you have attack power = $attack, hp = $hp and your skills is '$skills'"
sleep 2

#In case the seller has been choosen
coin=200
# Seller has a different options
if [[ $class -eq 4 ]]; then 
    echo "
    1 - Potion (50 coins)
    2-  Sword (100 coins)
    3 - Armor (150 coins)
    PS: You have $coin coins"
    read option
    case $option in
        1)
            echo "Perfect! You purchased a healing potion"
            echo "Your wallet now has: $(( $coin - 50 )) coins"
            playerHp=$(( $playerHp + 30 ))
            ;;
        2)
            echo "You purchased a powerful sword for 100 coins."
            echo "Your wallet now has: $(( $coin - 150 )) coins"
            attack=$(( $attack + 20 ))
            ;;
        3) 
            echo "I'm sure now you'll be protected now! Good Luck in your trip" 
            echo "Your wallet now has: $(( $coin - 200 )) coins"
            hp=$(( $hp + 40 ))
            ;;
    esac
    exit 1
# For now Seller just have this options, in a futures we'll include more. 
fi
#First Battle
firstBattle

#Travelling to another map
echo "Perfect, now you are free to explore the jungle, feel free! But look ahead, the dark side it's close!"
sleep 4

#It's getting hard, let's get this to another level
echo "Vampire: What are you doing here? GET OUT NOW!" 
sleep 1

# Vampire get close to intimidate
combatAgainstVampire

#Showing the performance  
evaluatePerformance

done
}

#Asking if wants to play the game
echo "Do you want to play a game ? (S/N)"
read choice


#Ensuring that the uppercase is maintained
choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]') #Also we can do | tr a-z A-Z 

if [[ $choice == "S" ]]; then
    #First of everything, let's garanty the paste Logs exists
    if [ ! -d "./Logs" ]; then 
        mkdir ./Logs
    fi

    #Let's create the vampire file
    if [ ! -f "./vampire.txt" ]; then 
        echo "type="Vampire" 
        hp=125
        attack=70
        skills="Sucking the blood"" > vampire.txt
    fi
    #Calling the function of game
    gwent

elif [[ $choice == "N" ]]; then 
    echo "Ok, see you soon!"
    exit 1
fi


