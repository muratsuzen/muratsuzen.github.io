---
title: Detailed Guide ESP32 GPS Data Collection and Transmission via SIM800
author: Murat Süzen
date: 2025-05-10 02:00:00
categories: [IoT, GPS Tracker]
tags: [esp32, sim800, gps, telemetry, iot, gprs, data transmission]
math: false
mermaid: false
---

This guide dives deeply into how an ESP32-based system collects GPS data using TinyGPS++, stores it locally, and transmits it over a cellular GPRS connection using a SIM800 module. We’ll cover each step with explanations, practical details, and insights.

---

## System Architecture Overview

✅ **Hardware components**:

- ESP32 microcontroller
- SIM800L (or SIM800C) GPRS modem
- NEO-6M or similar GPS module
- Power supply and antennas

✅ **Main functionalities**:

- Read real-time GPS coordinates and speed
- Log data locally using LittleFS
- Batch-send collected data every 10 seconds over HTTP POST
- Handle communication either over WiFi or SIM800, depending on mode

In this article, we focus specifically on **GPS data acquisition** and **SIM800 transmission**.

---

## Step 1: Reading GPS Data with TinyGPS++

The GPS module sends NMEA sentences (standardized ASCII messages) over serial. The TinyGPS++ library parses these into usable data:

```csharp
while (gpsSerial.available()) {
    gps.encode(gpsSerial.read());
}

if (gps.location.isUpdated()) {
    float latitude = gps.location.lat();
    float longitude = gps.location.lng();
    float speedKmph = gps.speed.kmph();
    String timeUTC = getFormattedTime();

    Serial.printf("Lat: %.6f, Lng: %.6f, Speed: %.2f km/h, Time: %s\n",
                  latitude, longitude, speedKmph, timeUTC.c_str());
}
```

✅ **Important notes**:

- Always check `isUpdated()` to avoid stale data.
- Use `.lat()` and `.lng()` for high-precision coordinates.
- Retrieve time only if `gps.time.isValid()`.

---

## Step 2: Storing Data Locally with LittleFS

Collected points are stored in a text file (`/gpslog.txt`) on the ESP32’s flash memory:

```csharp
String record = String(latitude, 6) + "," + String(longitude, 6) + "," +
                String(speedKmph, 2) + "," + timeUTC;

appendToFile("/gpslog.txt", record);
```

✅ **Why store locally?**

- If the connection is down, you avoid data loss.
- You can batch-send multiple points in one POST request, reducing overhead.

---

## Step 3: Preparing JSON for Transmission

Before sending, the code reads the log file and builds a valid JSON array:

```csharp
[
  {
    "deviceId": "SCM-AA0001",
    "latitude": 41.123456,
    "longitude": 29.987654,
    "speed": 12.34,
    "timeStamp": "2025-05-09T12:34:56Z"
  },
  ...
]
```

✅ **Batching advantage**:

- Reduce SIM800 data session usage.
- Ensure multiple data points are preserved.

---

## Step 4: Sending Data over SIM800 GPRS

Using AT commands, the ESP32 communicates with SIM800 via serial (`sim800Serial`):

```csharp
sendATCommand("AT+HTTPINIT", 1000);
sendATCommand("AT+HTTPPARA=\"CID\",1", 1000);
sendATCommand("AT+HTTPPARA=\"URL\",\"http://<IP>:<PORT>/api/TelemetryData\"", 1000);
sendATCommand("AT+HTTPPARA=\"CONTENT\",\"application/json\"", 1000);
sendATCommand("AT+HTTPDATA=" + String(jsonArray.length()) + ",10000", 1000);

sim800Serial.print(jsonArray);
delay(2000);

sendATCommand("AT+HTTPACTION=1", 10000);  // POST
sendATCommand("AT+HTTPREAD", 3000);
sendATCommand("AT+HTTPTERM", 1000);
```

✅ **Key points**:

- Always initialize HTTP (`HTTPINIT`) before sending.
- Use `HTTPPARA` to set headers and target URL.
- Set `CID` to 1, which refers to the active GPRS context (`SAPBR`).
- Use `HTTPDATA` to indicate payload length and prepare the modem.

✅ **GPRS prerequisites**:

- Ensure APN is set (`AT+SAPBR=3,1,"APN","internet"`).
- Ensure GPRS session is activated (`AT+SAPBR=1,1`).

---

## Example AT Command Flow (SIM800)

1️⃣ Check module: `AT` → `OK`  
2️⃣ Open bearer: `AT+SAPBR=1,1`  
3️⃣ Initialize HTTP: `AT+HTTPINIT`  
4️⃣ Set URL: `AT+HTTPPARA="URL",...`  
5️⃣ Load data: `AT+HTTPDATA`  
6️⃣ Execute POST: `AT+HTTPACTION=1`  
7️⃣ Read result: `AT+HTTPREAD`  
8️⃣ Terminate HTTP: `AT+HTTPTERM`

If anything fails, you can reset the connection with:

```csharp
restartSIM800Connection();
```

---

## Debugging Tips

✅ Enable serial prints to monitor AT command responses.  
✅ Check signal strength with `AT+CSQ`.  
✅ Use `AT+CGATT?` to ensure GPRS is attached.  
✅ Retry failed actions or implement a reconnection loop.

---

## Final Thoughts

By combining ESP32, TinyGPS++, and SIM800, you build a resilient, flexible GPS tracker capable of working in both WiFi and mobile network environments. Understanding the AT command flow is crucial for reliable data transmission.
