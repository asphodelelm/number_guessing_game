#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#random number between 0 and 1000
RANDOM_NUM=$(( RANDOM % 1000 + 1 ))
INSERT_RANDOM_NUM_RESULT=$($PSQL "INSERT INTO games(secret_number) VALUES($RANDOM_NUM')")

#When you run your script, you should prompt the user for a username with "Enter your username:", and take a username as input. 

echo "Enter your username:"
read USERNAME_INPUT



USERNAME=$($PSQL "SELECT username FROM players WHERE username='$USERNAME_INPUT'")

        #If the username has not been used before, you should print "Welcome, <username>! It looks like this is your first time here."
        #if user doesn't exist
        if [[ -z $USERNAME ]]
        then
          #get new username
          echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."

          #insert new user        
          INSERT_USER_RESULT=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME_INPUT')")

        else #if user does exist
        #If that username has been used before, it should print "Welcome back, $USERNAME! You have played <games_played> games, and your best game took <best_game> guesses."

        
          TOTAL_GAMES=$($PSQL "SELECT COUNT(*) FROM players FULL JOIN games USING(user_id) WHERE username='$USERNAME'")
          FEWEST_GUESSES=$($PSQL "SELECT MIN(guesses) FROM players FULL JOIN games USING(user_id) WHERE username='$USERNAME'")
          echo "Welcome back, $USERNAME! You have played $TOTAL_GAMES games, and your best game took $FEWEST_GUESSES guesses."

        fi




USER_ID=$($PSQL "SELECT user_id FROM players WHERE username='$USERNAME_INPUT'")

#The next line printed should be "Guess the secret number between 1 and 1000:" and input from the user should be read
GUESS=0;
  echo "Guess the secret number between 1 and 1000:"

GAME() {



  read GUESSED_NUM

  (( GUESS++ ))

    if [[ $GUESSED_NUM =~ ^[0-9]*$ ]]  #if input is an INT:
    then


        #if input is higher than secret number, print "It's lower than that, guess again:" & ask for new input
        if [[ $GUESSED_NUM -gt $RANDOM_NUM ]] 
        then
          echo "It's lower than that, guess again:"
          GAME
        #if input is lower than secret number, print "It's higher than that, guess again:" & ask for new input
        elif [[ $GUESSED_NUM -lt $RANDOM_NUM ]]
        then 

           echo "It's higher than that, guess again:"
          GAME
        #When the secret number is guessed, your script should print "You guessed it in <number_of_guesses> tries. The secret number was <secret_number>. Nice job!" and finish running
        elif [[ $GUESSED_NUM -eq $RANDOM_NUM ]]
        then  
       
          INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES('$USER_ID', $GUESS)")
          echo "You guessed it in $GUESS tries. The secret number was $RANDOM_NUM. Nice job!"

        fi

        


    else    #if input is not an INT:

      #If anything other than an integer (INT) is input as a guess, it should print "That is not an integer, guess again:
        echo "That is not an integer, guess again:"
        GAME
    fi


}

GAME
