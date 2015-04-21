/* 
 *  Example: I2C bus - EEPROM 24LC256
 */

#include <Wire.h> //I2C library



#include "Wire.h"


// BLOCKSIZE must be 16
#define BLOCKSIZE 16

#define I2C_EEPROM_VERSION "0.2"

// interface
class I2C_eeprom 
{
        public:
        // (I2C address)
        I2C_eeprom(uint8_t);
        // (mem_address, value)
        void writeByte(unsigned int, uint8_t );
        // (mem_address, buffer, length)
        void writeBlock(unsigned int, uint8_t*, int ); 
        // (mem_address, value, count)
        void setBlock(unsigned int, uint8_t, int ); 
        // (mem_address)
        uint8_t readByte(unsigned int );
        // (mem_address, buffer, length)
        void readBlock(unsigned int, uint8_t*, int );

        private:
        uint8_t _Device;
        // (address)
        int endOfPage(unsigned int);  
        // (mem_address, buffer, length)
        void _WriteBlock(unsigned int, uint8_t*, uint8_t );
        void _ReadBlock(unsigned int, uint8_t*, uint8_t );
};

////////////////////////////////////////////////////////////////////
//
// PUBLIC
//

I2C_eeprom::I2C_eeprom(uint8_t device)
{
        _Device = device;
        Wire.begin();           // initialise the connection
}

void I2C_eeprom::writeByte(unsigned int address, uint8_t data )
{
        _WriteBlock(address, &data, 1);
}

void I2C_eeprom::writeBlock(unsigned int address, uint8_t* buffer, int length)
{
        // determine length until end of page
        int le = endOfPage(address);
        if (le > 0)
        {
                _WriteBlock(address, buffer, le);
                address += le;
                buffer += le;
                length -= le;
        }

        // write the rest at BLOCKSIZE (16) byte boundaries 
        while (length > 0)
        {
                _WriteBlock(address, buffer, min(length, BLOCKSIZE));
                address += BLOCKSIZE;
                buffer += BLOCKSIZE;
                length -= BLOCKSIZE;
        }
}

void I2C_eeprom::setBlock(unsigned int address, uint8_t data, int length)
{
        uint8_t buffer[BLOCKSIZE];
        for (uint8_t i =0; i< BLOCKSIZE; i++) buffer[i] = data;

        // determine length until end of page
        int le = endOfPage(address);
        if (le > 0)
        {
                _WriteBlock(address, buffer, le);
                address += le;
                length -= le;
        }

        while (length > 0)
        {
                _WriteBlock(address, buffer, min(length, BLOCKSIZE));
                address += BLOCKSIZE;
                length -= BLOCKSIZE;
        }
}


uint8_t I2C_eeprom::readByte(unsigned int address)
{
        uint8_t rdata;
        _ReadBlock(address, &rdata, 1);
        return rdata;
}

// maybe let's not read more than 30 or 32 uint8_ts at a time!
void I2C_eeprom::readBlock(unsigned int address, uint8_t* buffer, int length)
{
        while (length > 0)
        {
                _ReadBlock(address, buffer, min(length, BLOCKSIZE));
                address += BLOCKSIZE;
                buffer += BLOCKSIZE;
                length -= BLOCKSIZE;
        }
}

////////////////////////////////////////////////////////////////////
//
// PRIVATE
//


// detemines length until first multiple of 16 of an address
// so writing allways occurs up to 16 byte boundaries
// this is automatically 64 byte boundaries
int I2C_eeprom::endOfPage(unsigned int address)
{
        const int m = BLOCKSIZE;
        unsigned int eopAddr = ((address + m - 1) / m) * m;  // "end of page" address
        return eopAddr - address;  // length until end of page
}

// pre: length < 32;
void I2C_eeprom::_WriteBlock(unsigned int address, uint8_t* buffer, uint8_t length)
{
        Wire.beginTransmission(_Device);
        Wire.write((int)(address >> 8)); 
        Wire.write((int)(address & 0xFF));  
        for (uint8_t c = 0; c < length; c++)
        Wire.write(buffer[c]);
        Wire.endTransmission();
        delay(5);
}

// pre: buffer is large enough to hold length bytes
void I2C_eeprom::_ReadBlock(unsigned int address, uint8_t* buffer, uint8_t length)
{
        Wire.beginTransmission(_Device);
        Wire.write((int)(address >> 8));
        Wire.write((int)(address & 0xFF));
        Wire.endTransmission();
        Wire.requestFrom(_Device, length);
        for (int c = 0; c < length; c++ )
        if (Wire.available()) buffer[c] = Wire.read();
}
/********************************************/

I2C_eeprom ee(0x50);

void dumpEEPROM(unsigned int addr, unsigned int length)
{
  // block to 10
  addr = addr / 10 * 10;
  length = (length + 9)/10 * 10;

  byte b = ee.readByte(addr); 
  for (int i = 0; i < length; i++) 
  {
    if (addr % 10 == 0)
    {
      Serial.println();
      Serial.print(addr);
      Serial.print(":\t");
    }
    Serial.print(b);
    b = ee.readByte(++addr); 
    Serial.print("  ");
  }
  Serial.println();
}


void setup() 
{
  Serial.begin(115200);
  Serial.print("Demo I2C eeprom library ");
  Serial.print(I2C_EEPROM_VERSION);
  Serial.println("\n");
}


void loop() 
{

  Serial.println("\nTEST: 64 byte page boundary writeBlock");
  ee.setBlock(0,'0',100);
  dumpEEPROM(0, 80);
  char data[] = "11111111111111111111";
  ee.writeBlock(61, (uint8_t*) data, 10);
  dumpEEPROM(0, 80);


  Serial.println("\nTEST: 64 byte page boundary setBlock");
  ee.setBlock(0,'0',100);
  dumpEEPROM(0, 80);
  ee.setBlock(61, '1', 10);
  dumpEEPROM(0, 80);


  Serial.println("\nTEST: 64 byte page boundary readBlock");
  ee.setBlock(0,'0',64);
  ee.setBlock(64, '1', 64);
  dumpEEPROM(0, 128);
  char ar[100];
  memset(ar,0,100);
  ee.readBlock(60, (uint8_t*)ar, 10);
  Serial.println(ar);


  Serial.println("\nTEST: write large string readback in small steps");
  ee.setBlock(0,'X',128);
  char data2[] = "0000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999A"; 
  ee.writeBlock(10, (uint8_t *) &data2, 100);
  dumpEEPROM(0, 256);
  for (int i = 0; i<100; i++)
  {
    if (i%10 == 0 ) Serial.println();
    Serial.print(ee.readByte(10+i));
  }
  Serial.println();
  while(1);

}
