---
title: Building an ESP32 GPS Tracker with SIM800, WiFi, and AT Command Integration
author: Murat Süzen
date: 2025-05-10 02:00:00
categories: [IoT, GPS Tracker]
tags: [esp32, gps tracker, sim800, wifi, at commands, telemetry]
math: false
mermaid: false
---

In this article, we explore a robust ESP32-based GPS tracking system that integrates:  
✅ SIM800 module (GPRS) for cellular internet  
✅ WiFi for wireless local connectivity  
✅ TinyGPS++ library to handle GPS data  
✅ LittleFS for onboard file storage  
✅ AT command interpreter to control behavior over serial or a remote service

---

## System Overview

The ESP32 runs firmware that does the following:

- Continuously reads GPS data (latitude, longitude, speed, time).
- Stores data points in a local log (`/gpslog.txt`).
- Every 10 seconds, sends the collected data to a remote telemetry service over the internet, using either SIM800 (GPRS) or WiFi.
- Listens for remote AT commands (via HTTP GET) or local serial AT commands to dynamically change settings.

---

## Internet Connection Modes

✅ **SIM800 Mode:**

- Initializes GPRS (`AT+SAPBR`) and sends HTTP requests with AT commands.
- Retrieves and runs remote commands via `/api/TelemetryData/NextCommand/{DEVICE_ID}`.
- Sends collected GPS telemetry via HTTP POST.

✅ **WiFi Mode:**

- Connects to a local WiFi network using configured SSID and password.
- Uses `WiFiClient` to connect to the service IP and port.
- Dynamically switches between WiFi or SIM800 via AT commands.

---

## GPS Logging

- Uses TinyGPS++ to read NMEA data from the GPS module.
- Captures: latitude, longitude, speed, and UTC timestamp.
- Logs each data point to LittleFS (`/gpslog.txt`).
- On every post interval (default 10s), reads the log file, builds a JSON array, and transmits it to the telemetry API.

---

## Dynamic Configuration with AT Commands

The system accepts AT commands over:

- **Serial input** (e.g., `AT+SETID=NEWID`).
- **Remote service** (via HTTP GET).

Supported commands:

- `AT+SETID`, `AT+GETID`: manage device ID.
- `AT+SETADDR`, `AT+GETADDR`: set or get the telemetry service IP and port.
- `AT+SETMODE=WIFI` or `AT+SETMODE=SIM800`: switch internet modes.
- `AT+SETWIFI=SSID,PASSWORD`: configure WiFi credentials.
- `AT+STARTGPS`, `AT+STOPGPS`: enable or disable GPS logging.
- `AT+RESTART`: restart the ESP32 device.
- `AT+TESTPOST`: perform a test POST to verify connectivity.

---

## Service Endpoint Example

By default, the firmware targets:

```
http://serviceaddr:port/api/TelemetryData
```

You can change this at runtime by sending:

```
AT+SETADDR=192.168.1.100:8080
```

or programmatically adjusting:

```cpp
SERVICE_IP = "192.168.1.100";
SERVICE_PORT = "8080";
saveServiceAddress();
```

This flexibility allows you to redirect the device to **development**, **test**, or **production** servers without reflashing.

---

## Key Takeaways

- Dual internet mode (SIM800 + WiFi) increases resilience.
- Modular AT command system simplifies live reconfiguration.
- File system (LittleFS) ensures reliable buffering when the network is unavailable.
- TinyGPS++ integration makes GPS handling precise and efficient.

---

## How to Use

- Update the service address, SSID, or APN in your environment.
- Connect your GPS module (e.g., NEO-6M) to the defined pins.
- Deploy the firmware and start capturing real-world telemetry.
