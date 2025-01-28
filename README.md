# mesh2mqtt
meshtastic to mqtt via http

Ziel des Projekt ist es die Nachrichten die auf einem meshtastic Node eingehen über die http Api auf einen eigenen Mqtt-Server zu publizieren um den in meshtastic integrierten Mqttkanal für das meshtastic mqtt frei zu halten.

Benötigt wird:
- Linux Server
  - mit installierter meshtastic instanz (pip3 install meshtastic)
  - mit installiertem mqtt-client (apt install mosquitto-clients)
- eigener Mqtt-Server
- meshtastic node mit IP im eigenen Netzwerk (via http erreichbar)

# Installation/Anpassungen
1. Die start.sh herunterladen
2. In der start.sh müssen die IP des meshtastic Node und des Mqtt-Servers angepasst werden.
3. die start.sh ausführbar machen "chmod +x start.sh"
4. die start.sh ausführen ./start.sh

# Weiterverarbeitung mit Node-Red
**1.Node mqtt-in:**  
- Topic: meshtastic/node1  

**2.Node Funktion (String to msg-Objekt):**  
// Überprüfen, ob msg.payload als String vorliegt  
let payloadString = typeof msg.payload === "string" ? msg.payload : JSON.stringify(msg.payload);  
  
let data;  
try {  
    // Escape alle Backslashes und parse das JSON  
    data = JSON.parse(payloadString.replace(/\\/g, '\\\\'));  
} catch (error) {  
    node.error("Invalid JSON format in payload: " + error.message, msg);  
    return null;  
}  
  
// Extrahiere die Felder aus dem JSON  
msg.from = data.from;  
msg.to = data.to;  
msg.payload = data.payload;  
  
// Gebe das modifizierte msg-Objekt zurück  
return msg;  
  
  
**3.Node Funktion (entferne Doppler):**  
// Erstelle einen globalen Speicher für die zuletzt gesendete Payload  
const lastPayload = flow.get("lastPayload") || "";  
  
if (msg.payload === lastPayload) {  
    // Wenn die aktuelle Payload gleich der letzten ist, breche ab  
    return null;  
}  
  
// Aktualisiere die gespeicherte Payload  
flow.set("lastPayload", msg.payload);  
  
// Gib die Nachricht weiter  
return msg;  


