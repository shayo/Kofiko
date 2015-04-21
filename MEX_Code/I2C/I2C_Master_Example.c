//------------------------------------------------------------------------------
// Keil Software, Inc.
// 
// Project: 	EXAMPLE I2C PROGRAM for Philips 87LPC764
//
// Filename: 	I2C_Master_Example.c
// Version: 	1.0.0
// Description:	This file contains all the necessary routines to communicate
//				to I2C slave devices on the I2C bus.  These routines use the
//				built in I2C hardware of the Philips MCUs.  See application
//				note for futher discussion on I2C.
//				
//				This is example will communicate to a I2C devices.
//				Device 1 will be a serial ADC / DAC from Philips (PCF8591)
//				The example will gather the data and print it out the serial
//				port (9600, 8, N, 1).
//
//				CPU Frequency: 11.0592 MHz
//
// Copyright 2000 - Keil Software, Inc.
// All rights reserved.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Header files
//------------------------------------------------------------------------------
#include "REG764.H"							// Header file for LPC764 MCU
#include <STDIO.H>							// Standard I/O header file

sbit  P1_2 	= 0x92;							// Define the individual bit
sbit  P1_3 	= 0x93;							// Define the individual bit
sbit  P1_4 	= 0x94;							// Define the individual bit

//------------------------------------------------------------------------------
// Macros
//------------------------------------------------------------------------------
											// Get high byte macro
#define high_byte(x)		((x & 0xFF00) >> 8)

//------------------------------------------------------------------------------
// Value Definitions
//------------------------------------------------------------------------------
#define 	TRUE			0x01			// Value representing TRUE
#define		FALSE			0x00			// Value representing FALSE
#define 	ON				0x01			// Value representing ON
#define		OFF				0x00			// Value representing OFF
#define 	HIGH			0x01			// Value representing ON
#define		LOW				0x00			// Value representing OFF

#define  	DELAY_WRITE		1000			// Value for delay write time
#define  	DELAY_BLINK		25000			// Value for delay time - blink

//------------------------------------------------------------------------------
// I/O Port Defines
//------------------------------------------------------------------------------
#define  	LED				P1_4			// LED Output

//------------------------------------------------------------------------------
// I2C Peripheral Function Prototypes
//------------------------------------------------------------------------------
											// Writes a byte to the EEPROM
void write_byte (unsigned char data_out, unsigned int address);
											// Reads a bytee from the EEPROM
unsigned char read_byte (unsigned int address);

//------------------------------------------------------------------------------
// I2C Function Prototypes
//------------------------------------------------------------------------------
bit write_byte_I2C (unsigned char data_out);// Write single byte over I2C
bit	read_byte_I2C (unsigned char *data_in);	// Read single byte from I2C
											// Send the I2C address and start signal
bit send_slave_address_I2C (unsigned char slave_address);
void stop_I2C (void);						// Stops a I2C data transfer
											// Resends the I2C start signal
bit restart_I2C (unsigned char slave_address);	

//------------------------------------------------------------------------------
// Support Function Prototypes
//------------------------------------------------------------------------------
void initialize_system (void);				// Initializes MCU, except I2C
void delay_time (unsigned int time_end);    // To pause execution for pre-determined time

//------------------------------------------------------------------------------
// MAIN FUNCTION 
//------------------------------------------------------------------------------
void main (void)
{
	unsigned int eeprom_address;

	initialize_system();					// Initialize RS-232 and rest of system

	printf("\n\rKeil Software, Inc.\n\r");	// Display starup message
	printf("LPC764 MCU I2C Example Test Program\n\r");
	printf("Version 1.0.0\n\r");
	printf("Copyright 2000 - Keil Software, Inc.\n\r");
	printf("All rights reserved.\n\n\r");

	P1M1  = 0x0C;							// Set Port 1 Open Drain
	P1M2  = 0x0C;

	I2CFG = 0x22;							// Config byte: 0 MAS CLRT1 T1, 00 CC  (page 16)
											// In our case the config byte is:
										 	// Slave bit 	(7): 0 (we are not a slave)
										 	// Master bit 	(6): 0 (we are a master)
										 	// Clear T1 	(5): 1 (Clear TI) 
										 	// TI Run 		(4): 0 (set TI to run)
										 	// Not used		(3): 0 		
											// Not used		(2): 0 
										 	// CT 1			(1): 1 (Set for highest CPU clock rate)
											// CT 0			(0): 0 



	printf("Writing data to EEPROM....");
	for (eeprom_address = 0; eeprom_address < 75; eeprom_address++)
		write_byte((unsigned char)eeprom_address + 0x30, eeprom_address);

	printf("Done!\n\r");
	printf("Reading from EEPROM...ASCII table!\n\r");


	while (TRUE)							// Infinite loop, never exits
	{
		for (eeprom_address = 0; eeprom_address < 75; eeprom_address++)
		{
			delay_time(DELAY_BLINK);		// Blink LED with delay
			LED = ON;
			delay_time(DELAY_BLINK);
			LED = OFF;

			printf("Address: %3u	Character: %c\n\r", eeprom_address, read_byte(eeprom_address));
		}
	}
}

//------------------------------------------------------------------------------
// I2C Peripheral Function Prototypes
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Procedure:	write_byte
// Inputs:		data out, address
// Outputs:		none
// Description:	Writes a byte to the EEPROM given the address 
//------------------------------------------------------------------------------
void write_byte (unsigned char data_out, unsigned int address)
{
  	send_slave_address_I2C(0xA0); 			// Send I2C Start Transfer
       					         			// Send identifier I2C address
   	write_byte_I2C(high_byte(address)); 	// Send address to EEPROM
   	write_byte_I2C((unsigned char)address); // Send address to EEPROM
   	write_byte_I2C(data_out);          		// Send low byte to EEPROM
   	stop_I2C();                   			// Send I2C Stop Transfer
   	delay_time(DELAY_WRITE);       			// Delay a period of time to write
}

//------------------------------------------------------------------------------
// Procedure:	read_byte
// Inputs:		address
// Outputs:		output byte
// Description:	Reads a byte from the EEPROM given the address 
//------------------------------------------------------------------------------
unsigned char read_byte (unsigned int address)
{
   	unsigned char data_in;

  	send_slave_address_I2C(0xA0); 			// Send I2C Start Transfer
   					              			// Send identifer I2C address
   	write_byte_I2C(high_byte(address));   	// Send address to EEPROM
   	write_byte_I2C((unsigned char)address); // Send address to EEPROM
   	restart_I2C(0xA1);         				// Send identifer I2C address
   	read_byte_I2C(&data_in);     			// Read byte
   	stop_I2C();                   			// Send I2C Stop Transfer

   	return data_in;                 
}


//------------------------------------------------------------------------------
// I2C FUNCTIONS
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Procedure:	write_byte_I2C
// Inputs:		data output byte
// Outputs:		TRUE for Pass, FALSE for Failure
// Description:	Writes one byte over the I2C bus
//------------------------------------------------------------------------------
bit write_byte_I2C (unsigned char data_out)
{
	unsigned char bit_index;

	while (!ATN);						// Wait for I2C ready
	for (bit_index = 0; bit_index < 8; bit_index++)
	{
		I2DAT = data_out;				// Output MSB to the I2C bus
		while (!ATN);					// Wait for the bit to be sent
		if (!DRDY) return FALSE;		// If bus not ready for data then error
		data_out <<= 1;					// Shift data out right by one bit
	}
	
	I2CON = 0xA0;						// Clear the TXD active flag and switch to RXD
	while (!ATN);						// Wait for the ACK from the I2C
	
	if (!RDAT) return TRUE;				// If the bit is high then we were not
										// acknoledged from the slave device
										// return error, else if low then 
										// the data was received OK
	return FALSE;						// If bus no ACK then error
}

//------------------------------------------------------------------------------
// Procedure:	write_byte_I2C
// Inputs:		none
// Outputs:		TRUE for Pass, FALSE for Failure
// Description:	Reads one byte over the I2C bus from the specified address
//------------------------------------------------------------------------------
bit	read_byte_I2C (unsigned char *data_in)
{
	unsigned char bit_index, byte_in;
	bit data_i2c;

	byte_in = 0x00;						// Clear the input buffer
	for (bit_index = 0; bit_index < 8; bit_index++)
	{
		byte_in <<= 1;					// Shift data right by one bit
		data_i2c = I2DAT;
		data_i2c = RDAT;
		while (!ATN);					// Wait for the bit to be read
		if (!DRDY) return FALSE;		// If bus not ready for data then error
		byte_in |= data_i2c;
	}

	// No Ack need with the 24LC65!

	*data_in = byte_in;
	return TRUE;
}

//------------------------------------------------------------------------------
// Procedure:	send_slave_address_I2C
// Inputs:		slave_address
// Outputs:		TRUE for Pass, FALSE for Failure
// Description:	Sends slave address for data transfer on the bus
//------------------------------------------------------------------------------
bit send_slave_address_I2C (unsigned char slave_address)
{
	unsigned char bit_index;

	I2CFG = 0x52;							// Config byte: 0 MAS CLRT1 T1, 00 CC  (page 16)

	while (!ATN);							// Loop until we receive an attention flag

	if (MASTER)
	{										// Send all eight bits over the I2C bus
		I2DAT = slave_address;				// Output MSB to the I2C bus
		I2CON = 0x1C;						// Clear the CARL, START, and STOP flags
		slave_address <<= 1;				// Shift address right by one bit
	
		while (!ATN);						// Wait for the MSB to be sent
		for (bit_index = 0; bit_index < 7; bit_index++)
		{
			I2DAT = slave_address;			// Output MSB to the I2C bus
			while (!ATN);					// Wait for the bit to be sent
			if (!DRDY) return FALSE;		// If bus not ready for data then error
			slave_address <<= 1;			// Shift address right by one bit
		}

		I2CON = 0xA0;						// Clear the TXD active flag and switch to RXD
		while (!ATN);						// Wait for the ACK from the I2C

		if (!RDAT) return TRUE;				// If the bit is high then we were not
											// acknoledged from the slave device
											// return error, else if low then 
											// the address was sent OK
	}
	return FALSE;							// If we do not return true, then error
											// Cause of error might be due to an 
											// invalid bus if RDAT is not LOW
}

//------------------------------------------------------------------------------
// Procedure:	stop_I2C
// Inputs:		none
// Outputs:		none
// Description:	Stops the data transfer on the bus
//------------------------------------------------------------------------------
void stop_I2C (void)
{
	MASTRQ = 0;								// Clear the Master Request	bit
	I2CON = 0x31;							// Clear the data ready flag, generate a I2C Bus Stop
	while (!ATN);							// Loop until we receive an attention flag
	I2CON = 0x20;							// Clear the data ready flag
	while (!ATN);							// Loop until we receive an attention flag
	I2CON = 0x94;							// Clear the bus arb bit, I2C stop, and deactive the Xmit
	I2CFG = 0x22;							// Config byte: 0 MAS CLRT1 T1, 00 CC  (page 16)
}

//------------------------------------------------------------------------------
// Procedure:	restart_I2C
// Inputs:		slave_address
// Outputs:		TRUE for Pass, FALSE for Failure
// Description:	Restarts I2C with slave address (ie. control byte)
//------------------------------------------------------------------------------
bit restart_I2C (unsigned char slave_address)
{
	unsigned char bit_index;

	I2CON = 0x22;							// Send repeated start
	while (!ATN);							// Wait for the ACK
	I2CON = 0x20;							// Clear data ready
	while (!ATN);							// Wait for the ACK

											// Send all eight bits over the I2C bus
	I2DAT = slave_address;					// Output MSB to the I2C bus
	I2CON = 0x1C;							// Clear the CARL, START, and STOP flags
	slave_address <<= 1;					// Shift address right by one bit
	
	while (!ATN);							// Wait for the MSB to be sent
	for (bit_index = 0; bit_index < 7; bit_index++)
	{
		I2DAT = slave_address;				// Output MSB to the I2C bus
		while (!ATN);						// Wait for the bit to be sent
		if (!DRDY) return FALSE;			// If bus not ready for data then error
		slave_address <<= 1;				// Shift address right by one bit
	}
	I2CON = 0xA0;							// Clear the TXD active flag and switch to RXD
	while (!ATN);							// Wait for the ACK from the I2C
	if (!RDAT) return TRUE;					// If the bit is high then we were not
											// acknoledged from the slave device
											// return error, else if low then 
											// the address was sent OK
	return FALSE;
}

//------------------------------------------------------------------------------
// SUPPORT FUNCTIONS
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Procedure:	initialize_system
// Inputs:		none
// Outputs:		none
// Description:	Initializes embedded system MCU LPC764
//------------------------------------------------------------------------------
void initialize_system (void)
{
	// Initialize the serial port (1200, 8, N, 1) [see page 32 of data sheet]
	PCON &= 0x7F;							// Clear bit 7 of the PCON register (SMOD1 = 0)  
	SCON = 0x50;							// 0101,0000 (Mode 1 and RxD enable)			
	TMOD = 0x20;							// Timer #1 in autoreload 8 bit mode
	TCON = 0x40;							// Set Timer #1 to run mode
	TH1 = 0xCC;								// Baud rate is determined by
											// Timer #1 overflow rate
											// Baud Rate = (Fcpu / 192) / (256 - TH1)
											// Fcpu = 12.00 MHz (XTAL)
	TR1 = 1;								// Turn on Timer 1
	TI = 1;									// Set UART to send first char
}

////////////////////////////////////////////////////////////////////////////////
// 	Routine:	delay_time
//	Inputs:		counter value to stop delaying
//	Outputs:	none
//	Purpose:	To pause execution for pre-determined time
////////////////////////////////////////////////////////////////////////////////
void delay_time (unsigned int time_end)
{
	unsigned int index;
	for (index = 0; index < time_end; index++);
}

