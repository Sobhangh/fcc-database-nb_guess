#!/bin/bash
SECRET=$(( RANDOM % 1000 ))
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "Enter your username:\n"
read USERNAME
PLAYED=$($PSQL "SELECT * FROM users WHERE name='$USERNAME'")
if [[ -z $PLAYED ]]
then
  $($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  Nb_game=0
  Best_game=10000
else
  IFS="|" read -r Name Nb_game Best_game <<< "$PLAYED"
  echo "Welcome back, $USERNAME! You have played $Nb_game games, and your best game took $Best_game guesses."
fi
NOT_FOUND=TRUE
COUNTER=1
while [ $NOT_FOUND ] do
  echo -e "\nGuess the secret number between 1 and 1000:\n"
  read GUESS
  if [[ $input =~ ^[0-9]+$ ]]
  then
    COUNTER=$((COUNTER + 1))
    if [[ $GUESS -eq $SECRET ]]
    then
      echo -e "\nYou guessed it in $COUNTER tries. The secret number was $SECRET. Nice job!\n"
      min=$(( COUNTER < Best_game ? COUNTER : Best_game ))
      Nb_game=$(( Nb_game + 1 ))
      $($PSQL "UPDATE users SET nb_game=$Nb_game, best_score=$min WHERE name='$USERNAME'")
      exit 0
    elif [[ $GUESS -lt $SECRET ]]
      echo -e "\nIt's higher than that, guess again:\n"
    else
      echo -e "\nIt's lower than that, guess again:\n"
    fi
    COUNTER=$((COUNTER + 1))
  else
    echo -e "\nThat is not an integer, guess again:\n"
  fi
done
