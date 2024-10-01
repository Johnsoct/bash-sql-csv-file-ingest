#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

INSERT_GAMES () {
  # PARAMETERS:
  # 1: YEAR
  # 2: ROUND
  # 3: WINNER
  # 4: OPPONENT
  # 5: WINNER_GOALS
  # 6: OPPONENT_GOALS

  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$3'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$4'")

  INSERT_GAME_RESULT=$($PSQL "
    INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
    VALUES('$1', '$2', '$WINNER_ID', '$OPPONENT_ID', '$5', '$6')
  ")

  # Output result
  if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
  then

    echo "Insert $1, $2, $3, $4 into the games table"

  else

    echo "Error with $1, $2, $3, $4"

  fi
}

INSERT_TEAMS () {
  # EXPECTS TEAM NAME AS VARIABLE #1

  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$1'")

  # IF TEAM_ID == $1 NOT FOUND in teams table
  if [[ -z $TEAM_ID ]]
  then

    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$1')")

    # Output result
    if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
    then

      echo "Insert $1 into the teams table"

    else

      echo "Error with $1"

    fi

  fi
}

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
  do

    # Skip the first row if the first row value === 'year' (CSV file format...)
    if [[ $YEAR != year ]]
    then

      # Add each unique team to the `teams` table. There should be 24 rows.
      INSERT_TEAMS "$WINNER"
      INSERT_TEAMS "$OPPONENT"
      INSERT_GAMES "$YEAR" "$ROUND" "$WINNER" "$OPPONENT" "$WINNER_GOALS" "$OPPONENT_GOALS"
      
    fi
  done