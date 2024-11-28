#include <WiFi.h>
#include <ESP32Servo.h>
#include <WebServer.h> 

const char* ssid = "TECNO";
const char* password = "12345678";

WebServer server(80); 
Servo servo;
int ledPin1 = 22; 
int ledPin = 23; 
int servoPin = 26; 

int openPosition = 90; 
int closedPosition = 0; 

void setup() {
  Serial.begin(115200);

  servo.attach(servoPin);
  servo.write(closedPosition);

  pinMode(ledPin, OUTPUT);
  pinMode(ledPin1, OUTPUT);
  digitalWrite(ledPin, HIGH); 
  digitalWrite(ledPin1, LOW); 

  WiFi.begin(ssid, password);
  Serial.print("Conectando a WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConectado a WiFi");
  Serial.println("IP: " + WiFi.localIP().toString());

  server.on("/levantarBarra", handleLevantarBarra);
 
  server.begin();
  Serial.println("Servidor iniciado");
}

void loop() {
  server.handleClient(); 
}

void handleLevantarBarra() {
  digitalWrite(ledPin, LOW);
  Serial.println("Solicitud recibida: levantando la barra...");
  
  servo.write(openPosition); 
  digitalWrite(ledPin1, HIGH);
  delay(15000); 

  Serial.println("Preparándose para bajar la barra...");
  
  for (int i = 0; i < 10; i++) {
    digitalWrite(ledPin, HIGH); 
    delay(250); 
    digitalWrite(ledPin, LOW); 
    delay(250); 
  }
  digitalWrite(ledPin1, LOW);
  servo.write(closedPosition); 
  digitalWrite(ledPin, HIGH);  
  Serial.println("Barra bajada");

  server.send(200, "text/plain", "Barra levantada");
}
