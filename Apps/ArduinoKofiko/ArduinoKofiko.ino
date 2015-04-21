/* Kofiko Arduino Communication Interface */
/* Shay Ohayon, Caltech 2012 */

void setFastAnalog() {
// defines for setting and clearing register bits
#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

/* set prescale to 16
sbi(ADCSRA,ADPS2) ;
cbi(ADCSRA,ADPS1) ;
cbi(ADCSRA,ADPS0) ;
*/
}

int InterruptTrigger0=0, InterruptTrigger1=0;
void Trigger0() {
  InterruptTrigger0 = 1;
}
void Trigger1() {
  InterruptTrigger1 = 1;
}

int PortSetOnOutputMode[13];

class analogsampler {
  public:
    analogsampler() { LastTS = 0;Active = 0;}
    void setChannel(int ch) { Channel = ch;};
    void start(double freq);
    void RunMachine();
    private:
    int Active;
    int Channel;
    double Freq;
    unsigned long LastTS;
};

void analogsampler::start(double freq) {
    if (freq == 0) {
      Active = 0;
    } else {
      Active = 1;
    Freq = freq; 
  LastTS = micros();
    }
 }
    
void analogsampler::RunMachine() {
  
  if (micros() - LastTS > 1.0/Freq && Active) {

   int AnalogValue = analogRead(Channel);
   unsigned long ts1 = millis();      
   unsigned long ts2 = micros();
   Serial.println("AnalogValue "+String(Channel) + " " + String(AnalogValue) + " " + String(ts1) + " " + String(ts2));
   
   LastTS = micros();
  }
}

class pulse { 
  public:
    pulse() {State = 0;};  
    void setChannel(int ch) {Channel = ch;};
    void startPulse(int widthusec);
    
    void RunMachine();
    private:
    long WidthUsec;
    int Channel;
    long ts;
    int State;
};

void pulse::startPulse(int widthusec) {
    WidthUsec = widthusec;
    State=1;
    if (!PortSetOnOutputMode[Channel]) {
      PortSetOnOutputMode[Channel] = 1;
      pinMode(Channel, OUTPUT);
    }
  }

void pulse::RunMachine() {
    if (State == 1) {
      digitalWrite(Channel, HIGH);
      State = 2;
      ts = micros();
    } else if (State == 2) {
      if (micros() - ts > WidthUsec) {
        digitalWrite(Channel, LOW);
        State = 0;
      }
    }
}

  
pulse PulseMachines[13];
analogsampler AnalogSamplingMachines[5];

void setup() {
  setFastAnalog();
  Serial.begin(115200);

  for (int k=0;k<13;k++) 
    PulseMachines[k].setChannel(k);
    
  for (int k=0;k<5;k++)
     AnalogSamplingMachines[k].setChannel(k);

  for (int k=0;k<13;k++) {
    PortSetOnOutputMode[k] = 0;
    pinMode(k, INPUT);
    digitalWrite(k, LOW); 
 }
    
  attachInterrupt(0, Trigger0, RISING );
  attachInterrupt(1, Trigger0, RISING );
}

void fnHandleInterrupts() {
  if (InterruptTrigger0) {
    Serial.println("Trigger 0");
    InterruptTrigger0 = 0; 
  }
  
  if (InterruptTrigger1) {
    Serial.println("Trigger 1");
    InterruptTrigger1 = 0; 
  }

}


void fnGetCommand(String S, String& Cmd, String& Op1, String& Op2) {
  int spacepos = -1;
  for (int k=0;k<S.length();k++) {
    if (S[k] == 32) {
      spacepos = k;
      break;
    }
  }
  String SubS;
  if (spacepos == -1) {
    Cmd = S;
  } else {
    Cmd=S.substring(0,spacepos);
    // Parameters?
   int spacepos1 = -1;
    for (int k=spacepos+1;k<S.length();k++) {
      if (S[k] == 32) {
        spacepos1 = k;
        break;
      }
    }
   if (spacepos1 == -1) 
       Op1 =S.substring(spacepos+1);
     else {
      Op1 =S.substring(spacepos+1,spacepos1);

   int spacepos2 = -1;
    for (int k=spacepos1+1;k<S.length();k++) {
      if (S[k] == 32) {
        spacepos2 = k;
        break;
      }
    }
  if (spacepos2 == -1) 
       Op2 =S.substring(spacepos1+1);
     else {
      Op2 =S.substring(spacepos1+1,spacepos2);
     }    
      
      
     }
      
  }
}

double StringToDouble(String S) {
  char Tmp[20];
  S.toCharArray(Tmp,20);
  return atof(Tmp);
}

int StringToInt(String S) {
  char Tmp[20];
  S.toCharArray(Tmp,20);
  return atoi(Tmp);
}
long StringToLong(String S) {
  char Tmp[20];
  S.toCharArray(Tmp,20);
  return atol(Tmp);
}

void fnParseCommand(String S) {
// Split the string into the command and potential parameters...
  String Cmd="", Op1="", Op2="";
  fnGetCommand(S, Cmd, Op1, Op2);
  Cmd.toLowerCase();
//  Serial.println(" Cmd = "+Cmd + " Op1 =  " + Op1 + " , Op2 = " + Op2);
  if (Cmd.equals("setbit")) {
    int Channel = StringToInt(Op1);
    int BitValue = StringToInt(Op2);
    if (!PortSetOnOutputMode[Channel]) {
      pinMode(Channel, OUTPUT);
      PortSetOnOutputMode[Channel] = 1;
    }
    if (BitValue == 0) {
      //Serial.println("Setting Bit "+String(Channel)+" To LOW");
        digitalWrite(Channel, LOW);
    } else {
      //      Serial.println("Setting Bit "+String(Channel)+" To HIGH");
      digitalWrite(Channel, HIGH);
    }
  } else if (Cmd.equals("pulse")) {
      int Channel = StringToInt(Op1);
      long PulseWidthUsec = StringToLong(Op2);      
      PulseMachines[Channel].startPulse(PulseWidthUsec);
  } else if (Cmd.equals("getanalog")) {
      int Channel = StringToInt(Op1);
      int AnalogValue = analogRead(Channel);
      unsigned long ts1 = millis();      
      unsigned long ts2 = micros();
      Serial.println("AnalogValue "+String(Channel) + " " + String(AnalogValue) + " " + String(ts1) + " " + String(ts2));
  } else if (Cmd.equals("gettimestamp")) {
      unsigned long ts1 = millis();      
      unsigned long ts2 = micros();
      Serial.println("Timestamp "+String(ts1) + " " + String(ts2));
  } else if (Cmd.equals("sampleanalog")) {
      int Channel = StringToInt(Op1);
      double Freq = StringToDouble(Op2);
      AnalogSamplingMachines[Channel].start(Freq);
  }
}


char SerialBuffer[100];
int SerialBufferIdx = 0;
char IncomingByte;
void  fnHandleIncomingCommands() {
  if (Serial.available() > 0)
  {
    IncomingByte = Serial.read();
    if (IncomingByte == 10) {
        SerialBuffer[SerialBufferIdx] = 0;
        fnParseCommand(String(SerialBuffer));
        SerialBufferIdx = 0;
    } else {
      if (SerialBufferIdx < 100) {
        SerialBuffer[SerialBufferIdx++] = IncomingByte;
      }
    }
  }
}

void fnHandleFiniteStateMachines() {
  for (int k=0;k<13;k++) {
    PulseMachines[k].RunMachine();
  }
  for (int k=0;k<5;k++) {
    AnalogSamplingMachines[k].RunMachine();    
  }
}

long cnt=0;
long ts=0;
void  fnPrintRate() {
  cnt++;
  if (micros() - ts > 1000000) {
    Serial.println(cnt);
    ts = micros();
    cnt = 0;
  }
}

void loop() {
  fnHandleInterrupts();  
  fnHandleIncomingCommands(); 
  fnHandleFiniteStateMachines();
 // fnPrintRate();
}
