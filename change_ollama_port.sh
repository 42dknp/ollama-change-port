#!/bin/bash

SERVICE_FILE="/etc/systemd/system/ollama.service"
BACKUP_FILE="$SERVICE_FILE.bak"

# Help function to display usage information
usage() {
  echo "Usage:"
  echo "  sudo ./change_ollama_port.sh <new_port> [--overwrite]   Change the Ollama service port (optional: overwrite)"
  echo "  sudo ./change_ollama_port.sh --restore                  Restore the Ollama service configuration from backup"
  exit 1
}

# Check if enough arguments are provided
if [ -z "$1" ]; then
  usage
fi

# Function to edit the systemd service file
edit_service_file() {
  local new_port=$1
  local overwrite=$2

  # Backup the service file if it exists
  if [ -f "$SERVICE_FILE" ]; then
    echo "Backing up existing service file to $BACKUP_FILE..."
    cp "$SERVICE_FILE" "$BACKUP_FILE"
  fi

  # If the file already contains an OLLAMA_HOST entry, update it
  if grep -q 'Environment="OLLAMA_HOST=' "$SERVICE_FILE"; then
    if [ "$overwrite" == "true" ]; then
      echo "Overwriting the existing OLLAMA_HOST entry with port $new_port..."
      sed -i "s|Environment=\"OLLAMA_HOST=.*\"|Environment=\"OLLAMA_HOST=0.0.0.0:$new_port\"|g" "$SERVICE_FILE"
    else
      echo "OLLAMA_HOST is already present. Use --overwrite to force the change."
      exit 0
    fi
  else
    # If no OLLAMA_HOST entry exists, add it under the [Service] section
    echo "Adding OLLAMA_HOST entry to the service file with port $new_port..."
    sed -i "/\[Service\]/a Environment=\"OLLAMA_HOST=0.0.0.0:$new_port\"" "$SERVICE_FILE"
  fi
}

# Function to restore the backup service file
restore_service_file() {
  if [ -f "$BACKUP_FILE" ]; then
    echo "Restoring the service file from $BACKUP_FILE..."
    cp "$BACKUP_FILE" "$SERVICE_FILE"
    echo "Service file restored."

    # Option to remove or rename the backup after restore
    echo "Removing the backup file..."
    rm -f "$BACKUP_FILE"
    echo "Backup file removed."
  else
    echo "No backup file found. Unable to restore."
    exit 1
  fi
}

# Main script logic
if [ "$1" == "--restore" ]; then
  restore_service_file
elif [[ "$1" =~ ^[0-9]+$ ]]; then
  NEW_PORT=$1
  OVERWRITE="false"

  if [ "$2" == "--overwrite" ]; then
    OVERWRITE="true"
  fi

  echo "Editing the systemd service file to change Ollama port to $NEW_PORT..."
  edit_service_file "$NEW_PORT" "$OVERWRITE"

  echo "Reloading systemd daemon..."
  systemctl daemon-reload

  echo "Restarting Ollama service..."
  systemctl restart "ollama.service"

  echo "Ollama service port updated or confirmed, and service restarted successfully."
else
  usage
fi
