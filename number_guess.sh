#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
echo $SECRET_NUMBER
GUESSES=0
echo -e "Enter your username:"
read NAME
  USERNAME=$($PSQL "SELECT name FROM users WHERE name='$NAME'")
  if [[ -z $USERNAME ]] 
  then 
    USERNAME=$NAME
    BEST_GAME=1000
    echo $($PSQL "INSERT INTO users(name, nb_game, best_Score) VALUES ('$USERNAME', 1, 1000)")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    GAMES_PLAYED=$($PSQL "SELECT nb_game FROM users WHERE name='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_Score FROM users WHERE name='$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    ((GAMES_PLAYED++))
    echo $($PSQL "UPDATE users SET nb_game=$GAMES_PLAYED WHERE name='$USERNAME'")
  fi
echo -e "Guess the secret number between 1 and 1000:"
while true
do
  read GUESS
  ((GUESSES++))
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "That is not an integer, guess again:"
  else 
    if [[ $GUESS -lt $SECRET_NUMBER ]] 
    then
      echo -e "It's higher than that, guess again:"
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo -e "It's lower than that, guess again:"
    else 
      if [[ $GUESSES -lt $BEST_GAME ]]
      then
        echo $($PSQL "UPDATE users SET best_Score=$GUESSES WHERE name='$USERNAME'")
      fi
      echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      exit 
    fi
  fi
done 