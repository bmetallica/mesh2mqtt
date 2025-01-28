#!/bin/bash

# Konfiguration
MESHTASTIC_HOST="192.168.1.XXX"
MQTT_SERVER="192.168.1.XXX"
MQTT_TOPIC="meshtastic/node1"

# Starte die Meshtastic-Session und leite stderr in die Schleife um
meshtastic --host "$MESHTASTIC_HOST" --listen 2>&1 | while read -r line; do
  # Sammle die relevanten Daten aus dem "decoded" Block
  if [[ $line =~ from:\ ([0-9]+) ]]; then
    FROM=${BASH_REMATCH[1]}
  fi

  if [[ $line =~ to:\ ([0-9]+) ]]; then
    TO=${BASH_REMATCH[1]}
  fi

  if [[ $line =~ payload:\ \"([^\"]+)\" ]]; then
    PAYLOAD=${BASH_REMATCH[1]}

    # Sobald alle Felder vorhanden sind, sende die Nachricht an den MQTT-Server
    if [[ -n $FROM && -n $TO && -n $PAYLOAD ]]; then
      echo "Sende an MQTT: from=$FROM, to=$TO, payload=$PAYLOAD"
      mosquitto_pub -h "$MQTT_SERVER" -t "$MQTT_TOPIC" -m "{\"from\": $FROM, \"to\": $TO, \"payload\": \"$PAYLOAD\"}"

      # Leere die Variablen, um neue Nachrichten zu verarbeiten
      FROM=""
      TO=""
      PAYLOAD=""
    fi
  fi
done
