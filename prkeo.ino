#include <WiFi.h>
#include <ESP32Servo.h>
#include <WebServer.h> 


const char* ssid = "MARI LUZ";
const char* password = "75010698";
WebServer server(80);
Servo servo;
int servoPin = 18; 
int openPosition = 90; 
int closedPosition = 0; 

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  Serial.print("Conectando a WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConectado a WiFi");
  Serial.println("IP: " + WiFi.localIP().toString());
  servo.attach(servoPin);
  servo.write(closedPosition);
  

  /*// Configurar ruta para manejar solicitudes POST
  server.on("/control-bar", HTTP_POST, []() {
    if (server.hasArg("lift")) {
      String lift = server.arg("lift");
      if (lift == "true") {
        levantarBarra();
        server.send(200, "text/plain", "Barra levantada");
      } else {
        server.send(200, "text/plain", "No se levanta la barra");
      }
    } else {
      server.send(400, "text/plain", "Falta el argumento 'lift'");
    }
  });

  server.begin();
}

void loop() {
  server.handleClient(); */
}
void loop() {
  if (WiFi.status() == WL_CONNECTED) { // Verificar si hay conexión
    levantarBarra(); 
  } else {
    Serial.println("WiFi no conectado");
  }

  delay(10000); // Esperar 10 segundos antes de la siguiente solicitud
}

void levantarBarra() {
  Serial.println("Levantando la barra...");
  servo.write(openPosition); 
  delay(40000); 
  servo.write(closedPosition); 
  Serial.println("Bajando la barra...");
}
