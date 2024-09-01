#!/bin/bash
PSQL="psql --csv --username=freecodecamp --dbname=number_guess --tuples-only -c"

SECRET=$(( RANDOM % 1000 + 1 ))

echo -e "\nEnter your username:"
read USERNAME

# Get user information from the database
USER=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME';")

# Check if user information was retrieved
if [[ -z $USER ]]
then
  # If user doesn't exist, insert new user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users (username, games_played, best_game) VALUES('$USERNAME', 0, 0);")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  # If user exists, extract the details
  IFS=',' read -r USERNAME GAMES_PLAYED BEST_GAME <<< "$USER"
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read PREDICT

NUMBER_OF_GUESSES=1

# Loop until the guess is correct
while [[ $PREDICT -ne $SECRET ]]
do
  # Check if the guess is a number
  if ! [[ $PREDICT =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  # Check if the guess is higher
  elif [[ $PREDICT -gt $SECRET ]]
  then
    echo "It's lower than that, guess again:"
  # Check if the guess is lower
  elif [[ $PREDICT -lt $SECRET ]]
  then
    echo "It's higher than that, guess again:"
  fi

  read PREDICT
  NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
done

# Update game statistics in the database
if [[ -z $USER ]]
then
  # If new user, update their statistics
  UPDATE=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")
else
  # If existing user, update their statistics
  if [[ $BEST_GAME -eq 0 || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
  then
    UPDATE=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES, games_played = games_played + 1 WHERE username = '$USERNAME'")
  else
    UPDATE=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")
  fi
fi

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET. Nice job!"
