#include <Arduino.h>

#include <Wire.h>    

#define disk1 0x50    //Address of 24LC256 eeprom chip
 
void setup(void)
{
  Serial.begin(9600);
  Wire.begin();  
 
  writeEEPROM(disk1, 0, 115);
  Serial.println(readEEPROM(disk1, 0), DEC);
  
//  writeEEPROM(disk1, 1, 113);
  Serial.println(readEEPROM(disk1, 1), DEC);

 // writeEEPROM(disk1, 2, 23);
  Serial.println(readEEPROM(disk1, 2), DEC);
  
}
 
void loop(){}
 
void writeEEPROM(int deviceaddress, unsigned int eeaddress, byte data ) 
{
  Wire.beginTransmission(deviceaddress);
  Wire.write((int)(eeaddress >> 8));   // MSB
  Wire.write((int)(eeaddress & 0xFF)); // LSB
  Wire.write(data);
  Wire.endTransmission();
 
  delay(5);
}
 
byte readEEPROM(int deviceaddress, unsigned int eeaddress ) 
{
  byte rdata = 0xFF;
 
  Wire.beginTransmission(deviceaddress);
  Wire.write((int)(eeaddress >> 8));   // MSB
  Wire.write((int)(eeaddress & 0xFF)); // LSB
  Wire.endTransmission();
 
  Wire.requestFrom(deviceaddress,1);
 
  if (Wire.available()) rdata = Wire.read();
 
  return rdata;
}
