#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include "AnyROM.h"

#define NumMotors 2
#define Debug 0


#define Ch1_Up_Pin 33
#define Ch1_Down_Pin 32
                                                                                                                                                                                      
#define Ch2_Up_Pin 31
#define Ch2_Down_Pin 30

const int MotorSwitch_Pins[NumMotors] = {53,52};
const int MotorLED[NumMotors] = {43,42};

#define MotorMovingPin 10
#define FiveWaySelPin1 5
#define FiveWaySelPin2 6
#define FiveWaySelPin3 7

#define EasyDriver1ControlPin 8
#define SpeedKnobPin 0

#define EasyDriverStepFactor 8
#define MotorRotationDeg   0.176/EasyDriverStepFactor // each tick is 0.176 deg
#define ScrewRotationToMM 0.5  // full rotation is 500 um

#define DOWN_VOLTAGE HIGH
#define UP_VOLTAGE LOW


const int MotorDirectionPins[2] = {
  47, 45};
const int MotorStepPins[2] = {
  46, 44};
const int MotorRelayPins[2] = {36,37};

#define EasyDriverTTL_Usec 100

float StepToUM = MotorRotationDeg/360 * ScrewRotationToMM * 1000;
LiquidCrystal_I2C lcd(0x3F, 2,1,0,4,5,6,7,3,POSITIVE);

float CoarseFineMultipler = 41;
#define KnobMultiplicationFactor CoarseFineMultipler * EasyDriverStepFactor

long NumMotorSteps[NumMotors];

#define ContinuousMode 5
#define AdjustDepthMode 4
#define StepMode 3
#define StepFineMode 2
#define HomeMode 1

int SpeedValue = 0;
int Ch1_Up_PrevState = 0, Ch1_Up_State=0;
int Ch1_Down_PrevState = 0, Ch1_Down_State=0;
int Ch2_Up_PrevState = 0, Ch2_Up_State=0;
int Ch2_Down_PrevState = 0, Ch2_Down_State=0;

int MotorSwitch_State[NumMotors]; 
int MotorSwitch_PrevState[NumMotors];

int FiveWayPrevState = 0, FiveWayState = 0;

int FiveWaySelPin1State = 0;
int FiveWaySelPin2State = 0;
int FiveWaySelPin3State = 0;
void setup() {
  Serial.begin(9600);
  
  lcd.begin(16,2);
  lcd.backlight();


   int eeprom_pos = 0;
    long l;
  for (int k=0;k<NumMotors;k++) {

   MotorSwitch_State[k] = 0; 
   MotorSwitch_PrevState[k] = 0;

pinMode(MotorLED[k], OUTPUT);
  digitalWrite(MotorLED[k], LOW);
  
  pinMode(MotorRelayPins[k], OUTPUT);
  digitalWrite(MotorRelayPins[k], LOW);
  
  pinMode(MotorSwitch_Pins[k], INPUT); 
  digitalWrite(MotorSwitch_Pins[k], LOW);

   eeprom_pos+=EEPROM_readAnything(eeprom_pos, NumMotorSteps[k]);
   if  (Debug)
     Serial.println(String("Advancer position: ") + String(NumMotorSteps[k]));

    
   float Depth = NumMotorSteps[k] * MotorRotationDeg / 360 * ScrewRotationToMM;
   Serial.println(String("Advancer ") + String(k+1) + String(" ")+ String(Depth));
    
    pinMode(MotorDirectionPins[k], OUTPUT);
    digitalWrite(MotorDirectionPins[k], LOW);
    pinMode(MotorStepPins[k], OUTPUT);
    digitalWrite(MotorStepPins[k], LOW);
  }
   pinMode(MotorMovingPin, OUTPUT); digitalWrite(MotorMovingPin, LOW);
  // put your setup code here, to run once:
  pinMode(Ch1_Up_Pin, INPUT);  
  digitalWrite(Ch1_Up_Pin, LOW);
  pinMode(Ch1_Down_Pin, INPUT);
  digitalWrite(Ch1_Down_Pin, LOW);
  pinMode(Ch2_Up_Pin, INPUT);  
  digitalWrite(Ch2_Up_Pin, LOW);
  pinMode(Ch2_Down_Pin, INPUT);
  digitalWrite(Ch2_Down_Pin, LOW);


  

  
  pinMode(FiveWaySelPin1, INPUT);
  pinMode(FiveWaySelPin2, INPUT);
  pinMode(FiveWaySelPin3, INPUT);  

  FiveWayState = ReadFiveWayPosition();
  if (FiveWayState == StepMode)
    CoarseFineMultipler = 41;
  else
    CoarseFineMultipler = 4.1;

  SpeedValue = max(1,min(100,analogRead(SpeedKnobPin)/10));
  UpdateDisplay(false);

}



int ReadFiveWayPosition() {
  int switchpos;

  FiveWaySelPin1State = digitalRead(FiveWaySelPin1);
  FiveWaySelPin2State = digitalRead(FiveWaySelPin2);
  FiveWaySelPin3State = digitalRead(FiveWaySelPin3);

  if(FiveWaySelPin1State == HIGH)
  {
    if(FiveWaySelPin2State == HIGH) 
      switchpos = 2;
    else 
      switchpos = 1;
  }
  else 
    if(FiveWaySelPin2State == HIGH)
  {

    if(FiveWaySelPin1State == HIGH){
      switchpos = 2;
    }
    else if(FiveWaySelPin3State == HIGH){
      switchpos = 4;
    }
    else {
      switchpos = 3;
    }
  }

  else if(FiveWaySelPin3State ==HIGH){

    if(FiveWaySelPin2State == HIGH){
      switchpos = 4;
    }
    else {
      switchpos = 5;
    }
  }


  return switchpos;
}

void UpdateDisplay(boolean OnlyDepth) {


  if (!OnlyDepth) {
    lcd.setCursor(0,0);    

    if (FiveWayState == StepFineMode) {
        lcd.print(String("FineStep ") + String(StepToUM*SpeedValue * KnobMultiplicationFactor,0) + String(" um            "));

    }

    if (FiveWayState == StepMode) {
      lcd.print(String("Step ") + String(StepToUM*SpeedValue * KnobMultiplicationFactor,0) + String(" um            "));
    }

    if (FiveWayState ==  AdjustDepthMode) {
      lcd.print(String("Init ") + String(StepToUM*SpeedValue * KnobMultiplicationFactor,0) + String(" um             "));
    }


    if (FiveWayState == ContinuousMode) {
      lcd.print(String("Cont ") + String(StepToUM*SpeedValue * KnobMultiplicationFactor,0) + String(" um/sec          "));
    }

    if (FiveWayState == HomeMode) {
      lcd.print(String("Move to initial "));
    }  
  }

  float Depth1 = NumMotorSteps[0] * MotorRotationDeg / 360 * ScrewRotationToMM;
  float Depth2 = NumMotorSteps[1] * MotorRotationDeg / 360 * ScrewRotationToMM;
  
   int eeprom_pos = EEPROM_writeAnything(0, NumMotorSteps[0]);
   EEPROM_writeAnything(eeprom_pos, NumMotorSteps[1]);   

  Serial.println(String("Advancer 1 ") + String(Depth1,4));
  Serial.println(String("Advancer 2 ") + String(Depth2,4));  
  lcd.setCursor(0,1);
  lcd.print(String(Depth1,2) + String("     "));
  lcd.setCursor(15-5,1);
  lcd.print(String(Depth2,2) + String("     "));


}  

void StepMotor(int MotorIndex, boolean Down, boolean ActuallyMove) 
{
  float MicronsToMove = StepToUM*SpeedValue * KnobMultiplicationFactor;
  int NumStepsToTake = MicronsToMove/StepToUM;
   if  (Debug)
    Serial.println(String("Motor ") + String(MotorIndex) + String(" ") + String(ActuallyMove));
  int Increment;
  if (Down)
    Increment = 1;
  else
    Increment = -1;



  
  // Actually move motor (if we are in the right mode....)
  if (ActuallyMove) {
    digitalWrite(MotorRelayPins[MotorIndex], HIGH);
    
    digitalWrite(MotorLED[MotorIndex], HIGH);
    digitalWrite(MotorMovingPin, HIGH);
    
    if (Down) 
      digitalWrite(MotorDirectionPins[MotorIndex], DOWN_VOLTAGE);
    else
      digitalWrite(MotorDirectionPins[MotorIndex], UP_VOLTAGE);


    for (int k=0;k<NumStepsToTake;k++) {
      MotorSwitch_State[MotorIndex] = digitalRead(MotorSwitch_Pins[MotorIndex]);
      if (!MotorSwitch_State[MotorIndex])
      break;
      
      NumMotorSteps[MotorIndex]+= Increment;

      digitalWrite(MotorStepPins[MotorIndex], HIGH);  
      delayMicroseconds(EasyDriverTTL_Usec);
      digitalWrite(MotorStepPins[MotorIndex], LOW);          
      delayMicroseconds(EasyDriverTTL_Usec);        


      if ( k % 100 == 0) 
        UpdateDisplay(true);  
    }
    digitalWrite(MotorLED[MotorIndex], LOW);
    digitalWrite(MotorMovingPin, LOW); // TTL
    digitalWrite(MotorRelayPins[MotorIndex], LOW);
    
  } 
  else 
  {
    NumMotorSteps[MotorIndex]+= NumStepsToTake * Increment;
  }

  UpdateDisplay(true);  
}


void MoveMotor(int MotorIndex, boolean Down, int PinToDepress) {

  float MicronsToMove = StepToUM*SpeedValue * KnobMultiplicationFactor;
  int NumStepsToTakePerSecond = MicronsToMove/StepToUM;
  int Increment;

  int PinState;
 
  if (Down)
    Increment = 1;
  else
    Increment = -1;

    digitalWrite(MotorRelayPins[MotorIndex], HIGH);

      digitalWrite(MotorLED[MotorIndex], HIGH);
    digitalWrite(MotorMovingPin, HIGH);      
  if (Down) 
    digitalWrite(MotorDirectionPins[MotorIndex], DOWN_VOLTAGE);
  else
    digitalWrite(MotorDirectionPins[MotorIndex], UP_VOLTAGE);

  long Pos = NumMotorSteps[MotorIndex];
  while (true) {
    PinState = digitalRead(PinToDepress);
    if (!PinState)
      break;

     MotorSwitch_State[MotorIndex] = digitalRead(MotorSwitch_Pins[MotorIndex]);
      if (!MotorSwitch_State[MotorIndex])
        break;
 
    for (int k=0;k<NumStepsToTakePerSecond;k++) {
      PinState = digitalRead(PinToDepress);
      if (!PinState)
        break;
        
      MotorSwitch_State[MotorIndex] = digitalRead(MotorSwitch_Pins[MotorIndex]);
      if (!MotorSwitch_State[MotorIndex])
      break;
 
        

      NumMotorSteps[MotorIndex]+=Increment;
      digitalWrite(MotorStepPins[MotorIndex], HIGH);  
      delayMicroseconds(EasyDriverTTL_Usec);
      digitalWrite(MotorStepPins[MotorIndex], LOW);          
      delayMicroseconds(EasyDriverTTL_Usec);        
      if (abs(NumMotorSteps[MotorIndex]-Pos) > StepToUM*1000*5) {
        Pos = NumMotorSteps[MotorIndex];
        UpdateDisplay(false); 
      }

    }



  } 

  UpdateDisplay(false); 
  digitalWrite(MotorLED[MotorIndex], LOW);
    digitalWrite(MotorMovingPin, LOW);      
    digitalWrite(MotorRelayPins[MotorIndex], LOW);
    
}

void MoveHome() {
    digitalWrite(MotorRelayPins[0], HIGH);
    digitalWrite(MotorRelayPins[1], HIGH);    
  
  digitalWrite(MotorLED[0], HIGH);
  digitalWrite(MotorLED[1], HIGH);  
    digitalWrite(MotorMovingPin, HIGH);      


  digitalWrite(MotorDirectionPins[0], UP_VOLTAGE);
  digitalWrite(MotorDirectionPins[1], UP_VOLTAGE); 


  int k = 0;
  boolean bMoving = true;
  while (bMoving) {
    for (int MotorIter=0;MotorIter < NumMotors; MotorIter++) {
      if ( NumMotorSteps[MotorIter] > 0) 
        NumMotorSteps[MotorIter]--;
      digitalWrite(MotorStepPins[MotorIter], HIGH);  
      delayMicroseconds(EasyDriverTTL_Usec);
      digitalWrite(MotorStepPins[MotorIter], LOW);          
      delayMicroseconds(EasyDriverTTL_Usec);              
    }
    if (k++ > 100) {
      UpdateDisplay(false);
      k= 0;
      
      
    }
    if (NumMotorSteps[0] == 0 && NumMotorSteps[1] == 0)
      break;
      
     for (int MotorIter=0;MotorIter < NumMotors; MotorIter++) {
      MotorSwitch_State[MotorIter] = digitalRead(MotorSwitch_Pins[MotorIter]);
      if (!MotorSwitch_State[MotorIter])
      {
        bMoving= false;
        break;
      }
     }
      
     }

  digitalWrite(MotorLED[0], LOW);
  digitalWrite(MotorLED[1], LOW);  
    digitalWrite(MotorMovingPin, LOW);  
    
    digitalWrite(MotorRelayPins[0], LOW);
    digitalWrite(MotorRelayPins[1], LOW);    
    
  UpdateDisplay(false);
  }


int PrevSpeedValue = 0;
void loop() {
  SpeedValue = analogRead(SpeedKnobPin) / 1023.0 * 100;
  if  (abs(PrevSpeedValue - SpeedValue) > 2) {
   if  (Debug)
      Serial.println(String("Speed = ") + String(SpeedValue));
    PrevSpeedValue = SpeedValue;
    UpdateDisplay(false); 
  }

  FiveWayState = ReadFiveWayPosition();
 if (FiveWayState == StepMode)
    CoarseFineMultipler = 41;
  else
    CoarseFineMultipler = 4.1;
  

  Ch1_Up_State=digitalRead(Ch1_Up_Pin);
  Ch1_Down_State=digitalRead(Ch1_Down_Pin);
  Ch2_Up_State=digitalRead(Ch2_Up_Pin);
  Ch2_Down_State=digitalRead(Ch2_Down_Pin);
  
  for (int k=0;k<NumMotors;k++)
    MotorSwitch_State[k]=digitalRead(MotorSwitch_Pins[k]);

  if (Ch1_Up_PrevState != Ch1_Up_State)
    if (Ch1_Up_State) {
       if  (Debug)
        Serial.println("Ch1 Up pressed");
      if ((FiveWayState == StepMode || FiveWayState == StepFineMode) && MotorSwitch_State[0])
        StepMotor(0, false, true); 
      else if (FiveWayState == AdjustDepthMode)
        StepMotor(0, false, false); 
      else if (FiveWayState == ContinuousMode && MotorSwitch_State[0])
        MoveMotor(0, false,Ch1_Up_Pin);
    }
    else  {
    if (Debug)      
      Serial.println("Ch1 Up depressed");
    }

  if (Ch1_Down_PrevState != Ch1_Down_State)
    if (Ch1_Down_State) {
    if (Debug)            
      Serial.println("Ch1 Down pressed");
      if ((FiveWayState == StepMode || FiveWayState == StepFineMode)   && MotorSwitch_State[0])
        StepMotor(0, true,true); 
      else if (FiveWayState == AdjustDepthMode)
        StepMotor(0, true, false); 
      else if (FiveWayState == ContinuousMode && MotorSwitch_State[0])
        MoveMotor(0, true,Ch1_Down_Pin);

    }
    else
    if (Debug)          
      Serial.println("Ch1 Down depressed");

  if (FiveWayState == HomeMode && Ch1_Up_State && Ch1_Down_State && Ch2_Up_State && Ch2_Down_State && MotorSwitch_State[0] && MotorSwitch_State[1]) 
    MoveHome();

  if (Ch2_Up_PrevState != Ch2_Up_State)
    if (Ch2_Up_State) {
          if (Debug)      
      Serial.println("Ch2 Up pressed");  
      if ((FiveWayState == StepMode || FiveWayState == StepFineMode)   && MotorSwitch_State[1])
        StepMotor(1, false,true); 
      else if (FiveWayState == AdjustDepthMode)
        StepMotor(1, false, false); 
      else if (FiveWayState == ContinuousMode && MotorSwitch_State[1])
        MoveMotor(1, false,Ch2_Up_Pin);

    }
    else
        if (Debug)      
      Serial.println("Ch2 Up depressed");  

  if (Ch2_Down_PrevState != Ch2_Down_State)
    if (Ch2_Down_State) {
          if (Debug)      
      Serial.println("Ch2 Down pressed");
      if ((FiveWayState == StepMode || FiveWayState == StepFineMode)  && MotorSwitch_State[1])
        StepMotor(1, true,true); 
      else if (FiveWayState == AdjustDepthMode)
        StepMotor(1, true, false); 
      else if (FiveWayState == ContinuousMode && MotorSwitch_State[1])
        MoveMotor(1, true,Ch2_Down_Pin);

    }
    else
        if (Debug)      
      Serial.println("Ch2 Down depressed");


  for (int k=0;k<NumMotors;k++) {
    
  if (MotorSwitch_PrevState[k] != MotorSwitch_State[k])
    if (MotorSwitch_State[k]) {
          if (Debug)      
      Serial.println(String("Motor ") + String(k+1) + String(" On"));

      for (int k=0;k<5;k++) {
          digitalWrite(MotorLED[k], HIGH);
        delay(50);
          digitalWrite(MotorLED[k], LOW);
        delay(50);
      }


    }
    else {
          if (Debug)      
            Serial.println(String("Motor ") + String(k+1) + String(" Off"));
    }
  }
  
  if  (FiveWayPrevState != FiveWayState) {
        if (Debug)      
    Serial.println(String("Five Way now: ") + String(FiveWayState));
    UpdateDisplay(false);
  }

  Ch1_Up_PrevState = Ch1_Up_State;
  Ch1_Down_PrevState = Ch1_Down_State;
  Ch2_Up_PrevState = Ch2_Up_State;
  Ch2_Down_PrevState = Ch2_Down_State;
  
  for (int k=0;k<NumMotors;k++) {
    MotorSwitch_PrevState[k] = MotorSwitch_State[k];
  }
  
  FiveWayPrevState = FiveWayState;
}


