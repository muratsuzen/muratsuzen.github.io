---
title: ESP32 GPS Tracker with SIM800 and WiFi Today’s Deep Dive
author: Murat Süzen
date: 2025-05-10 02:00:00
categories: [ESP32, IoT, GPS, SIM800, WiFi]
tags: [esp32, sim800, wifi, gps, telemetry, at commands, iot project]
math: false
mermaid: false
---

Today, we take a detailed look at a powerful ESP32-based GPS tracker that uses both SIM800 (GPRS) and WiFi to send data, ensuring high resilience and flexibility. This article explores **today’s deployment lessons**, **technical deep dive**, and **key implementation tips**.

---

## 🛠 System Highlights

✅ ESP32 MCU with dual connectivity (WiFi + SIM800)  
✅ NEO-6M GPS module to capture real-time positions  
✅ LittleFS file system for local storage  
✅ TinyGPS++ library for parsing NMEA data  
✅ AT command system to control settings live

This setup logs GPS coordinates, stores them, and sends them over HTTP to a server — **either via mobile network or local WiFi**.

---

## 🌐 Dual Connectivity: Why Use Both?

Many IoT systems face environments where WiFi is unavailable or unreliable. By adding SIM800, your tracker can:
- **Fallback to mobile networks** when WiFi fails.
- Cover remote regions without WiFi infrastructure.
- Switch between modes using `AT+SETMODE=WIFI` or `AT+SETMODE=SIM800` without rebooting.

This makes the system **field-deployable and self-recovering**.

---

## 📍 GPS Data Flow

### Step 1: Collect Data

```csharp
while (gpsSerial.available()) {
    gps.encode(gpsSerial.read());
}

if (gps.location.isUpdated()) {
    float lat = gps.location.lat();
    float lng = gps.location.lng();
    float speed = gps.speed.kmph();
    String timestamp = getFormattedTime();
    String record = String(lat, 6) + "," + String(lng, 6) + "," + String(speed, 2) + "," + timestamp;
    appendToFile("/gpslog.txt", record);
}
```

✅ Logs are saved every update, ensuring no data is lost if the network is temporarily down.

---

## 📡 Sending Data via SIM800

### Preparing SIM800

1️⃣ Activate bearer (APN):  
```csharp
sendATCommand("AT+SAPBR=1,1", 2000);
```

2️⃣ Setup HTTP:  
```csharp
sendATCommand("AT+HTTPINIT", 1000);
sendATCommand("AT+HTTPPARA=\"URL\",\"http://server/api\"", 1000);
```

3️⃣ Push data:  
```csharp
sendATCommand("AT+HTTPDATA=length,timeout", 1000);
sim800Serial.print(jsonPayload);
sendATCommand("AT+HTTPACTION=1", 10000);
```

4️⃣ Cleanup:  
```csharp
sendATCommand("AT+HTTPTERM", 1000);
```

✅ **Debug tip**: Use `AT+CSQ` to check signal; aim for strength >10.

---

## 📶 Sending Data via WiFi

```csharp
if (client.connect(SERVICE_IP.c_str(), SERVICE_PORT.toInt())) {
    client.println("POST /api HTTP/1.1");
    client.println("Host: " + SERVICE_IP);
    client.println("Content-Type: application/json");
    client.print("Content-Length: ");
    client.println(json.length());
    client.println();
    client.println(json);
}
```

✅ **Resilience tip**: Use connection retries and check `WiFi.status()` regularly.

---

## 🔧 Dynamic AT Command Control

With the built-in AT command system, you can change settings live:

| Command             | Action                                  |
|---------------------|----------------------------------------|
| `AT+SETID=<ID>`     | Update device ID                       |
| `AT+SETADDR=<IP:PORT>` | Change server address                 |
| `AT+SETMODE=WIFI`   | Switch to WiFi mode                    |
| `AT+SETMODE=SIM800` | Switch to SIM800 mode                  |
| `AT+STARTGPS`       | Enable GPS logging                     |
| `AT+STOPGPS`        | Disable GPS logging                    |

✅ **Field tip**: You can also pull commands from the server dynamically via `/api/TelemetryData/NextCommand/{DEVICE_ID}`.

---

## 🌍 Real-World Use Cases

- Vehicle tracking in mixed rural/urban zones  
- Wildlife monitoring where WiFi is rare  
- Delivery fleet systems that need dual redundancy  
- Remote sensors pushing environmental data

---

## ✅ Summary

Today’s build showcases a **flexible, powerful ESP32 GPS tracker** that seamlessly switches between WiFi and SIM800 connections, ensuring robust field operation. With smart AT command integration and careful data handling, you can confidently deploy this system in real-world scenarios.
