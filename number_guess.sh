#! /bin/bash
#Number Guessing Game
#YES
echo -e "\n\n~~Welcome to Number Guessing Game~~\n"
#query database
PSQL="psql --username=freecodecamp --dbname=number_guessing_game_db -Atc"
#read username
echo "Enter your username:"
read USERNAME
#Allow usernames only between 3 and 22 characters.(Uppercase or lowercase letters with digits and the symbols: - and _ are allowed as well)
while ! [[ "$USERNAME" =~ ^[[:alpha:][:digit:]_-]{3,22}$ ]]
do
  echo "Sorry, '$USERNAME' name is not allowed, try please another one:"
  read USERNAME
done
#Search current user in database
USER_ID="$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")"
if [[ -z $USER_ID ]]
then
  #insert new user
  INSERT_NEW_USER="$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")"
  #get new user id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  #get data from existing user
  GET_USER_GAMES_DATA="$($PSQL "SELECT COUNT(*), MIN(result) FROM games WHERE user_id = $USER_ID;")"
  echo $GET_USER_GAMES_DATA | while IFS="|" read -a Read
  do
    echo -e "\nWelcome back, $USERNAME! You have played ${Read[0]} games, and your best game took ${Read[1]} guesses.\n"
  done
fi
#start game
# generate a random number between 1 and 1000
SECRET_NUMBER=$(( $RANDOM % 1001 ))
#get user's number
echo -e "\nGuess the secret number between 1 and 1000:"
read USER_GUESS
#initiate number of guesses
NUMBER_OF_GUESSES=1
while [[ $USER_GUESS != $SECRET_NUMBER ]]
do
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read USER_GUESS
  else
    if [[ $USER_GUESS > $SECRET_NUMBER ]]
    then
      NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
      echo "It's lower than that, guess again:"
      read USER_GUESS
    else
      NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
      echo "It's higher than that, guess again:"
      read USER_GUESS
    fi
  fi
done
#insert new game
INSERT_NEW_GAME="$($PSQL "INSERT INTO games(user_id, result) VALUES($USER_ID, '$NUMBER_OF_GUESSES');")"
#congratulation message
echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!\n"
