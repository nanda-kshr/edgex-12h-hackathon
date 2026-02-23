/*
 * ESP32 WiFi Connect To an Existing Network
 */

#include <WiFi.h>
#include <HTTPClient.h>

// WiFi credentials
const char* ssid = "Evil Phone";
const char* password = "0987654321";

// -------- Voltage Sensor --------
#include <ZMPT101B.h>
#define SENSITIVITY 500.0f
#define CALIBRATION_FACTOR 1.49
ZMPT101B voltageSensor(27, 50.0);

// -------- Current Sensor --------
#define currentpin 4
float R1 = 6800.0;
float R2 = 12000.0;

// Server endpoint
const char* serverName = "http://172.20.176.17:8000/ingest";

void setup() {
    Serial.begin(115200);

    voltageSensor.setSensitivity(SENSITIVITY);
    pinMode(currentpin, INPUT);

    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid, password);

    Serial.println("\nConnecting to WiFi Network ..");
    while (WiFi.status() != WL_CONNECTED) {
        Serial.print(".");
        delay(100);
    }

    Serial.println("\nConnected!");
    Serial.print("ESP32 IP: ");
    Serial.println(WiFi.localIP());
}

float getVoltage() {
    float voltage = voltageSensor.getRmsVoltage() * CALIBRATION_FACTOR;
    Serial.print("Voltage: ");
    Serial.println(voltage);
    return voltage;
}

float getCurrent() {
    int adc = analogRead(currentpin);
    float adc_voltage = adc * (3.3 / 4096.0);
    float current_voltage = (adc_voltage * (R1 + R2) / R2);
    float current = (current_voltage - 2.5) / 0.100;

    Serial.print("Current: ");
    Serial.println(current);
    return current;
}

void sendData(float power) {
    if (WiFi.status() == WL_CONNECTED) {
        HTTPClient http;

        http.begin(serverName);
        http.addHeader("Content-Type", "application/json");

        String jsonData =
            "{\"appliance_id\":\"Laptop\",\"power\":" +
            String(power, 2) + "}";

        int httpResponseCode = http.POST(jsonData);

        Serial.print("HTTP Response code: ");
        Serial.println(httpResponseCode);

        http.end();
    }
}

void loop() {
    float voltage = getVoltage();
    float current = getCurrent();

    float power = voltage * current;
    Serial.print("Power: ");
    Serial.println(power);

    sendData(power);

    delay(2000);
}
