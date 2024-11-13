#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c "
SHOW_SERVICES(){
  #echo "$($PSQL "SELECT * FROM services")"
  echo "$($PSQL "SELECT * FROM services")" | while IFS="|" read SERVICE_ID NAME
  #echo -e "\n $SERVICE_ID $NAME"
  do 
    if [[ $SERVICE_ID != "service_id" && $SERVICE_ID =~ ^[0-9]+$ ]]
    then
      echo -e "\n$SERVICE_ID) $(echo $NAME | sed 's/| //')"
    fi
    
  done
  PICK_SERVICE
}

PICK_SERVICE(){
  echo -e "\nChoose one of the services using their number"
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SHOW_SERVICES
    return
  else
    EXISTING=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    #echo $EXISTING
    if [[ -z $EXISTING ]]
    then 
      SHOW_SERVICES
      return
    fi  
  fi
  echo -e "\nPlease entre your phone number"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nPlease provide your name"
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')" &> /dev/null
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  echo -e "\nPlease provide the time of the appointment"
  read SERVICE_TIME
  $PSQL "INSERT INTO appointments(customer_id, service_id,time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME')" &> /dev/null
  if [[ $? == 0 ]]
  then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

SHOW_SERVICES


