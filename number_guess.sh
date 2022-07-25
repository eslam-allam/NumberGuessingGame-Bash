#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Login screen
LOGIN_SCREEN () {
  # If function called with argument
  if [[ $1 ]]
  then

    # Print argument
    echo -e "\n$1"
  fi

  # Ask for username
  echo -e "Enter your username:"
  read USERNAME

  # If username less than 22 characters
  if [[ ${#USERNAME} -lt 22 ]]
  then 

    # Return to login with error message
    LOGIN_SCREEN "\nUsername has to be at least 22 characters"
    return
  fi

  # Get user_id from database
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")

  # If doesn't exist
  if [[ -z $USER_ID ]]
  then

    # Welcome user
    echo -e "\nWelcome, $(echo $USERNAME | sed -E 's/^ *| *$//g')! It looks like this is your first time here."

    # Add to database
    ADD_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
    
    # Go to game
    GAME "$USER_ID" "$USERNAME" 


  fi
  # Fetch games_played and best number of guesses from database
  USER_INFORMATION=$($PSQL "SELECT COUNT(game_id), MIN(number_guesses) FROM users INNER JOIN games USING(user_id) WHERE user_id = 2")
  
  IFS="|" read -r GAMES_PLAYED BEST_NUMBER_GUESSES <<< $USER_INFORMATION

  # Display user information
  echo -e "\nWelcome back, $(echo $USERNAME | sed -E 's/^ *| *$//g')! You have played $(echo $GAMES_PLAYED | sed -E 's/^ *| *$//g') games, and your best game took $(echo $BEST_NUMBER_GUESSES | sed -E 's/^ *| *$//g') guesses."

  # Go to game
  GAME "$USER_ID" "$USERNAME"
}

GAME () {
  USER_ID=$1
  USERNAME=$2
  GUESSES=0


  # Generate random number between 1 and 1000 
  NUMBER_TO_GUESS=$(( $RANDOM % 1000 + 1 ))

  # Display game message
  echo -e "\nGuess the secret number between 1 and 1000:"

  # Input while loop
  while true
  do
    # Increment number of guesses
    let "GUESSES++"

    # Ask for user input
    read NUMBER

    # If input isn't an integer 
    if [[ ! $NUMBER =~ ^[0-9]+$ ]]
    then 

      # Print error message
      That is not an integer, guess again:

      # Ask for input again
      continue
    fi

    # If input is higher than number
    if [[ $NUMBER -gt $NUMBER_TO_GUESS ]]
    then

      # Display appropriate message
      echo -e "\nIt's lower than that, guess again:"

      # Ask for input again
      continue
    fi

    # Else if input is lower than number
    if [[ $NUMBER -lt $NUMBER_TO_GUESS ]]
    then

      # Display appropriate message
      echo -e "\nIt's higher than that, guess again:"

      # Ask for input again
      continue
    fi

    # Display congrats message and exit the loop
    echo -e "\nYou guessed it in $(echo $GUESSES | sed -E 's/^ *| *$//g') tries. The secret number was $(echo $NUMBER_TO_GUESS | sed -E 's/^ *| *$//g'). Nice job!"

    break
  done

}

LOGIN_SCREEN "~~~~ Welcome to the number guessing game ~~~~"