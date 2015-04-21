boolean input_change = false;
void trig()
{
  input_change = true;
}
float MaxNumSecondsValveOpen = 300;

void setup() {
  Serial.begin(9600);
  pinMode(2,INPUT);
  digitalWrite(2,LOW);  
  
  pinMode(10,OUTPUT);
  digitalWrite(10,LOW);

  pinMode(7,OUTPUT);
  digitalWrite(7,LOW);
  
  pinMode(9,INPUT);
  pinMode(8,INPUT);  
  digitalWrite(9,LOW);
  digitalWrite(8,LOW);  
  
  attachInterrupt(0, trig, CHANGE );
  
  
}
int State, PrevState = 0; // 0 means off
boolean juice_onset = false;

boolean juice_flowing = false;
long TimeStamp = 0;
void  JuiceOn() {
  if (juice_flowing == false)
  {
    digitalWrite(10, HIGH);
    digitalWrite(7,HIGH);
    TimeStamp = millis();
    juice_flowing = true;
    Serial.println("Juice ON");
  }
}

void AutoShutoff() {
  float NumSecondsValveOpen = (millis() - TimeStamp)/1000;
  if (juice_flowing && NumSecondsValveOpen > MaxNumSecondsValveOpen) {
    Serial.println("Auto Juice OFF");    
    JuiceOff();
  }
}

void  JuiceOff() {
  juice_flowing = false;
    digitalWrite(10,LOW);    
    digitalWrite(7,LOW);  
    Serial.println("Juice OFF");        
}

void loop() {
  
    int I8 = digitalRead(8);
    int I9 = digitalRead(9);    
    

   if (I8 == 1)
   {
     // Computer Controlled
     State = 1;
   }
   if (I9 == 1)
   {
     // Manual
     State = 2;
   }
   if (I8 == 0 && I9 == 0) 
   {
     State = 0;
   }

  if (State != PrevState) {
   Serial.print("Entring State ");      
   Serial.println(State);
    if (State == 2) {
      JuiceOn();
    }
    if (State == 1 || State == 0) 
    {
      JuiceOff();
    }
  }
  
  if (input_change) {
    input_change = false;
    // Sample input port
    boolean PortInput = digitalRead(2);
    if (PortInput && State != 0) {
    Serial.println("Remote Triggered ON");      
      // turn on juice
      JuiceOn();
    } else
    {
      // turn off juice
    Serial.println("Remote Triggered OFF");      
      JuiceOff();      
    }
  }

  // Auto shutoff valve
  AutoShutoff();
  
  PrevState = State;

}
