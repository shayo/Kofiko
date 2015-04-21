#define INPUT_PIN 10
#define OUTPUT_PIN 13

boolean LineTrig = false;
void Trigger() {
  LineTrig = true;
}

void setup() {
  // put your setup code here, to run once:
  pinMode(INPUT_PIN, INPUT);
  pinMode(OUTPUT_PIN, OUTPUT);
  digitalWrite(OUTPUT_PIN,LOW);
  digitalWrite(INPUT_PIN,LOW);
  attachInterrupt(INPUT_PIN, Trigger,RISING );
}

//unsigned long LastTriggering = micros();

void loop() {
  if (LineTrig) { // 10 ms
    digitalWrite(OUTPUT_PIN,HIGH);
    digitalWrite(OUTPUT_PIN,LOW);    
    delayMicroseconds(1000 * 10);
    LineTrig = false;
  }
}
