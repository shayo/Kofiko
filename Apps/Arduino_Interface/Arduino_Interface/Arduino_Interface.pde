
// defines for setting and clearing register bits
#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

int HardwareTrigger0 = 0, HardwareTrigger1 = 0;

void Trigger0() {
   HardwareTrigger0 = 1;
}

void Trigger1() {
   HardwareTrigger1 = 1;
}

void setup() {
        Serial.begin(115200);     // opens serial port, sets data rate to 9600 bps
        
  // set prescale to 16
  sbi(ADCSRA,ADPS2) ;
  cbi(ADCSRA,ADPS1) ;
  cbi(ADCSRA,ADPS0) ;
  
  // Set Interrupt trigger
  pinMode(2, INPUT);
  digitalWrite(2, LOW); // Pin 
  pinMode(3, INPUT);  
  digitalWrite(3, LOW); // Pin   
  
  attachInterrupt(0, Trigger0, RISING);
  attachInterrupt(1, Trigger1, RISING);  
}

#define MAX_BUF_SIZE 100

long cnt =0 ;
long prev_ts=0,ts=0;
char Command_Serial_Buf[MAX_BUF_SIZE];
int bufindex = 0;

class Pulse {
  public:
    Pulse();
    void SetBit();
    private:
    
    int bit;
};

void fnParseBuffer(String InputStr)
{
  Serial.println(InputStr);
  int CmdStop = 0;
  for (int CmdStop=0;CmdStop<InputStr.length();CmdStop++) {
    if (InputStr[CmdStop] == 32)
      break;
  }
  Serial.println(CmdStop);
  String Cmd = InputStr.substring(CmdStop-1);
  Serial.println(Cmd);

  if (Cmd.equals("SetBit")) {
   Serial.println("Match!"); 
  } else if  (Cmd.equals("Pulse")) {
    // Non Blocking pulse    
    int BitIndex = 0;
    int TimeToPulse = 0;
    int NumPulses = 1;
    int NumInterPulseInterval = 0;
    //FSM[BitIndex].MachineState = 1;
    
  } else if  (Cmd.equals("GetBit")) {
    int BitIndex = 0;
    Serial.println("BitValue XX YY TT");
  }  else if  (Cmd.equals("GetAnalog")) {
     // Single Read
    Serial.println("AnalogValue XX YY TT");
  } else if  (Cmd.equals("StartGetAnalog")) {
     // Single Read
     int Channel = 0;
     int Freq = 0;
     Serial.println("AnalogValue XX YY TT");
  }
  
}

void loop() {

        if (Serial.available() > 0) {
                // read the incoming byte:
                char incomingByte = Serial.read();
                if (incomingByte == 10)  {
                  Command_Serial_Buf[bufindex] = 0;
                  fnParseBuffer(String(Command_Serial_Buf));
                  Serial.println(Command_Serial_Buf);
                  bufindex = 0;
                } else {
                      Command_Serial_Buf[bufindex++] = incomingByte;
                }
                
               
        }  
  
  if (HardwareTrigger0) {
      Serial.println("Trigger 0");
      HardwareTrigger0 = 0;
  }
  if (HardwareTrigger1) {
      Serial.println("Trigger 1");
      HardwareTrigger1 = 0;
  }
  
  // Run Finit State Machine...
  
  cnt++;
ts = micros();
if (ts - prev_ts > 1000000) {
Serial.println(cnt);
cnt =0;
prev_ts=ts;
}

for (int k=0;k<5;k++) {
  int x = analogRead(k);
}
for (int k=0;k<13;k++) {
  int x = digitalRead(k);
}

        // send data only when you receive data:

}
