# 📡 mesh2mqtt

**Meshtastic ➜ MQTT via HTTP**

Dieses Tool liest Nachrichten von einem Meshtastic-Node über die HTTP-API aus und veröffentlicht sie auf einem eigenen MQTT-Server.  
Ziel ist es, den integrierten Meshtastic-MQTT-Kanal für Meshtastic-interne Kommunikation freizuhalten.

---

## 🔧 Voraussetzungen

- Ein Linux-Server mit:
  - installierter Meshtastic-Python-Bibliothek (`pip3 install meshtastic`)
  - installiertem MQTT-Client (`apt install mosquitto-clients`)
- Ein eigener MQTT-Broker
- Ein Meshtastic-Node mit erreichbarer IP im lokalen Netzwerk (HTTP-API muss verfügbar sein)

---

## 🚀 Installation & Einrichtung

1. Repository nach `/opt/mesh2mqtt/` klonen oder Datei `start.sh` dorthin kopieren  
2. In der `start.sh`:
   - IP-Adresse des Meshtastic-Nodes anpassen
   - IP-Adresse (und ggf. Port) des MQTT-Servers anpassen
3. Ausführbar machen:

```bash
chmod +x start.sh
```

4. Starten:

```bash
./start.sh
```

---

## ⚙️ Autostart per systemd-Dienst

1. Service-Datei verschieben:

```bash
mv mesh2mqtt.service /etc/systemd/system/
```

2. systemd neu laden:

```bash
systemctl daemon-reload
```

3. Dienst aktivieren:

```bash
systemctl enable mesh2mqtt.service
```

4. Dienst starten:

```bash
systemctl start mesh2mqtt.service
```

---

## 🔄 Weiterverarbeitung mit Node-RED

### 1. 🟢 MQTT-In Node

- **Topic**: `meshtastic/node1`

---

### 2. 🧠 Funktion (String to msg-Objekt)

```javascript
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

return msg;
```

---

### 3. 🚫 Funktion (Entferne Doppler)

```javascript
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
```


---

**Autor:** [bmetallica](https://github.com/bmetallica)
