#!/bin/bash

# Conectar ao banco de dados
PSQL="psql --username=postgres --dbname=salon -t --no-align -c"

# Função para exibir os serviços
display_services() {
  echo "Here are the services we offer:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Função para agendar um compromisso
schedule_appointment() {
  echo "Please select a service:"
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  # Verificar se o serviço é válido
  if [[ -z $SERVICE_NAME ]]; then
    echo "That service does not exist. Please choose again."
    display_services
    schedule_appointment
  else
    # Solicitar o telefone do cliente
    echo "Please enter your phone number:"
    read CUSTOMER_PHONE
    
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
    # Se o cliente não existir, solicitar o nome
    if [[ -z $CUSTOMER_NAME ]]; then
      echo "You are not registered. Please enter your name:"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    
    # Solicitar a hora do serviço
    echo "What time would you like your appointment?"
    read SERVICE_TIME

    # Obter o ID do cliente
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # Inserir o compromisso
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    # Exibir a mensagem de confirmação
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

# Exibir os serviços e agendar um compromisso
display_services
schedule_appointment
