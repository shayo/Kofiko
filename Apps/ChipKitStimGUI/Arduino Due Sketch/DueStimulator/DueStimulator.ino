#include <Wire.h>

/********************************************************************************

Nano stimulator sketch. Based on Arduino Due.

Programmed by Shay Ohayon
Caltech 


Revisions:
22/2/2014 - fixed an issue with stimulating with 1 Hz pulses and train lengths < 1 sec. 
11/2/2014 - added support for photodiode triggering.
1/1/2014 - added support for gating.
?/?/2013 - added support for trigger inhibition (useful for antidromic evoked artifacts)
********************************************************************************/

#include <LiquidCrystal.h>
#include <Wire.h>         // Para a EEPROM 24LC256, assim chamamos as bibliotecas i2c
#include "AnyRom.h"
#include <stdio.h>

#define DEBUG_LCD 0
#define KEEP_CHANGES_IN_ROM 0
#define DEBUG_SERIAL 0
#define SERIAL_SPEED 115200
#define CLR(x,y) (x&=(~(1<<y)))
#define SET(x,y) (x|=(1<<y))
#define _BV(bit) (1 << (bit))
#define NUM_MAX_PRESETS 4
#define NUM_CHANNELS 2
#define PRESET_SIZE 128
#define MAX_BUFFER 1024
#define PRESET_NAME_LENGTH 17

const int DEFAULT_PRESET = 0;

const byte TCP_MODIFY_PULSE_FREQ = 1;
const byte TCP_MODIFY_PULSE_WIDTH = 2;
const byte TCP_MODIFY_SECOND_PULSE = 3;
const byte TCP_MODIFY_TRAIN_LENGTH = 4;
const byte TCP_MODIFY_TRAIN_FREQ = 5;
const byte TCP_MODIFY_NUM_TRAINS = 6;
const byte TCP_MODIFY_TRIG_DELAY = 7;
const byte TCP_MODIFY_SECOND_PULSE_WIDTH = 8;
const byte TCP_MODIFY_SECOND_PULSE_DELAY = 9;
const byte TCP_MODIFY_AMPLITUDE = 10;
const byte TCP_SOFT_TRIGGER = 11;
const byte TCP_SAVE_PRESET = 12;
const byte TCP_LOAD_PRESET = 13;
const byte TCP_TOGGLE_CHANNEL_ACTIVE = 14;
const byte TCP_GET_CURRENT_SETTINGS = 15;
const byte TCP_GET_PRESET_NAMES = 16;
const byte TCP_MODIFY_PRESET_NAME = 17;
const byte TCP_PING = 18;
const byte TCP_MODIFY_IP = 19;
const byte TCP_MODIFY_PORT = 20;
const byte TCP_GET_TRIGGER_COUNT = 21;
const byte TCP_ABORT_STIMULATION = 22;
const byte TCP_MODIFY_GATE_DELAY = 23;
const byte TCP_MODIFY_GATE_LENGTH = 24;
const byte TCP_MODIFY_PHOTODIODE_TRIGGER = 25;


	const byte NUM_MENU_ITEMS = 26;
	const byte NUM_MENU_ITEMS_PER_CHANNEL = 11;
	const byte MENU_ITEM_IP = 0;
	const byte MENU_ITEM_PORT = 1;
	const byte MENU_ITEM_LOAD_PRESET = 2;
	const byte MENU_ITEM_SAVE_PRESET = 3;
	const byte MENU_ITEM_CH1_PULSE_FREQ = 4;
	const byte MENU_ITEM_CH1_PULSE_WIDTH = 5;
	const byte MENU_ITEM_CH1_TRIG_DELAY = 6;
	const byte MENU_ITEM_CH1_TRAIN_FREQ = 7;
	const byte MENU_ITEM_CH1_TRAIN_DUR = 8;
	const byte MENU_ITEM_CH1_NUM_TRAINS = 9;
	const byte MENU_ITEM_CH1_SECOND_PULSE = 10;
	const byte MENU_ITEM_CH1_Second_PULSE_WIDTH = 11;
	const byte MENU_ITEM_CH1_Second_PULSE_DELAY = 12;
	const byte MENU_ITEM_CH1_AMPLITUDE = 13;
	const byte MENU_ITEM_CH1_SIM_TRIG = 14;
	const byte MENU_ITEM_CH2_PULSE_FREQ = 15;
	const byte MENU_ITEM_CH2_PULSE_WIDTH = 16;
	const byte MENU_ITEM_CH2_TRIG_DELAY = 17;
	const byte MENU_ITEM_CH2_TRAIN_FREQ = 18;
	const byte MENU_ITEM_CH2_TRAIN_DUR = 19;
	const byte MENU_ITEM_CH2_NUM_TRAINS = 20;
	const byte MENU_ITEM_CH2_SECOND_PULSE = 21;
	const byte MENU_ITEM_CH2_Second_PULSE_WIDTH = 22;
	const byte MENU_ITEM_CH2_Second_PULSE_DELAY = 23;
	const byte MENU_ITEM_CH2_AMPLITUDE = 24;
	const byte MENU_ITEM_CH2_SIM_TRIG = 25;



	const  String MENU_ITEMS[NUM_MENU_ITEMS] = {
		"IP Address",
		"Server Port",
		"Load preset",
		"Save preset",
		"Ch1 Pulse Freq",
		"Ch1 Pulse Width",
		"Ch1 Trig Delay",
		"Ch1 Train Freq",
		"Ch1 Train Dur",
		"Ch1 Num Trains",
		"Ch1 Second pulse",
		"Ch1 Amplitude",
		"Ch1 #2 Puls Wid",
		"Ch1 #2 Puls Del",
		"Ch1 Sim Trig",
		"Ch2 Pulse Freq",
		"Ch2 Pulse Width",
		"Ch2 Trig Delay",
		"Ch2 Train Freq",
		"Ch2 Train Dur",
		"Ch2 Num Trains",
		"Ch2 Second pulse",
		"Ch2 #2 Puls Wid",
		"Ch2 #2 Puls Del",
		"Ch2 Amplitude",    
		"Ch2 Sim Trig"};

		long t_noncritical = millis();
		long t_ms;

byte remoteIp[4];        // holds received packet's originating IP
unsigned short remotePort; // holds received packet's originating port

int ClientConnected = false;
LiquidCrystal lcd(8, 9, 4, 5, 6, 7);  // pin 10 is LCD backlight toggle...
char PRESET_NAMES[NUM_MAX_PRESETS][PRESET_NAME_LENGTH];
byte mac[] = { 	0x00, 0x18, 0x3E, 0x01, 0x2C, 0x3D };  
unsigned int localPort;
int prev_key = 0;
byte ip_rom[4];
char tmp_str[17];
int buffer_index = 0;
char packetBuffer[MAX_BUFFER]; //buffer to hold incoming packet,
int menu_item=0;
int current_preset = 0;
long t0;
String current_string;



          int ReadKey() {
           int v = analogRead(0); 
           int b = digitalRead(11);
           if (b)
             return 900; // emulate the select button, which doesn't seem to function
            else
           return v; 
          }


String Microns_To_String(long usec) {
	if (usec <= 1000)
		return String(usec)+String(" usec");
	else if (usec > 1000 && usec  <= 1000000)
		return String(double(usec/1000.0))+String(" ms");
	else return String(double(usec/1000000.0))+String(" sec");
}


		class stim_train {
		public:
			stim_train();
                        void setState(int newState);

			// train parameters
			long TriggerDelay_Microns;
			int SecondPulse;
			float Pulse_Freq_Hz;
			long Pulse_Width_Microns;
			long Train_Length_Microns; 
			float Train_Freq_Hz;
			long NumTrains_Per_Trigger;
			long Second_Pulse_Width_Microns;
			long Second_Pulse_Delay_Microns;
			float Amplitude;

                        long GateDelay_Microns;
                        long GateLength_Microns;

			// internally used variables
			byte Software_Trig;
			byte Hardware_Trig;
			int prev_trigger_value;
			long  TurnOff_TS;
			long NumTriggers;
			int State;
			int GateState;
			long SecondPulse_TS;
			long Pulse_Start_TS;
			long Train_Start_TS;
			int Active;

                        long GateStartTS;
                        unsigned long LastTriggerTime;
                        double Minimum_Trigger_Time_Distance_Microns;
                        bool triggerDetectedByInterrupt;
                        bool photodiodeDetectedByInterrupt;
                        bool ignoreTriggersDuringTrain;

			long NumTrains;
			byte OutputPin;
			byte TriggerPin;
                        byte GatePin;
			int ID;  
                        int PhotodiodePin;
                        bool UsePhotodiodeSecondTrigger;
                        bool Armed;

			int curr_trig_value, prev_trig_value;
			void  non_block_loop();

                        unsigned long ExternallyTriggeredCount;
		};

		stim_train FSM[2];  

		stim_train::stim_train() {
			SecondPulse = 1;
			Pulse_Freq_Hz = 300;
			Pulse_Width_Microns = 250;
			Train_Length_Microns = 1000000;
			Train_Freq_Hz = 1;
			NumTrains_Per_Trigger = 1;
			Second_Pulse_Width_Microns = 250;
			Second_Pulse_Delay_Microns = 150;
			TriggerDelay_Microns = 0;
			Amplitude = 1;
			Active = 1;
			Hardware_Trig = 0;
			Software_Trig= 0;
			prev_trigger_value = 0;
			TurnOff_TS = 0;
			NumTriggers =0;
			State = 0;
			Pulse_Start_TS =0;
			Train_Start_TS =0;
			SecondPulse_TS = 0;
			NumTrains = 0;
			curr_trig_value = 0;
			prev_trig_value = 0;
                        GateDelay_Microns = 0;
                        GateLength_Microns = 0;
                        GateState = 0;
                        triggerDetectedByInterrupt = false;
                        photodiodeDetectedByInterrupt = false;
                        UsePhotodiodeSecondTrigger = false;
                        Armed = false;
                        ignoreTriggersDuringTrain = true;
                        triggerDetectedByInterrupt = false;
                        Minimum_Trigger_Time_Distance_Microns = 10000; // do not allow external triggers if they are separated by less than 10 ms. 
                                                                       // this will prevent stimulation loops for antidromic spikes..
                                                                       
                        LastTriggerTime = micros();                                                                       
                        ExternallyTriggeredCount = 0;

		}

                
                void stim_train::setState(int newState) {
                        //if (DEBUG_SERIAL)
                        //   Serial.println("State "+String(State) +" => " + String(newState));
                        
                        State = newState;

                }

		void stim_train::non_block_loop() {
			long t;
			byte Continuous;
                      t=micros();



                         if (triggerDetectedByInterrupt) {
                                triggerDetectedByInterrupt = false;
                                   
                                if (t - LastTriggerTime > Minimum_Trigger_Time_Distance_Microns) 
                                {
                                  if (ignoreTriggersDuringTrain && State != 0)
                                  {
                                    // do nothing. We ignore triggers while 
                                  } else 
                                  {
                                    if (!UsePhotodiodeSecondTrigger)
                                    {
      				      Hardware_Trig = 1;
                                    } else
                                    {
                                      Armed = true;                       
                                    }
    
                                   
                                    ExternallyTriggeredCount++;
                                  }

                                }
			}
    
                        
                        if (Armed && UsePhotodiodeSecondTrigger  && photodiodeDetectedByInterrupt)
                        {
                            photodiodeDetectedByInterrupt = false;
                            Armed = false;
                             Hardware_Trig = 1;
                                             
                        }

			if ( (State == 0) && (Software_Trig || Hardware_Trig)) {  
				Software_Trig = 0;
				Hardware_Trig = 0;

				if (State == 0) {
					 //State = 1;
                                         setState(1);
  
                                        if (GateLength_Microns > 0)
                                        {
                                          GateState = 1;
                                          GateStartTS = micros();
                                        }
					//Serial.println(String("Trigged ")+String(ID));                    
				}  
			}

                        if (GateState == 1)
                        {
                          if (micros() - GateStartTS >= GateDelay_Microns)
                          {
                            digitalWrite(GatePin,HIGH);
                            GateState = 2;
                          }
                        }
                        
                        if (GateState == 2)
                        {
                          if (micros() - GateStartTS >= GateDelay_Microns + GateLength_Microns)
                          {
                            digitalWrite(GatePin,LOW);
                            GateState = 0;
                          }
                        }
  

			if (State == 1) {
                                 LastTriggerTime = t;   
				NumTriggers++;
				NumTrains = NumTrains_Per_Trigger;
				Train_Start_TS = micros();
				if (TriggerDelay_Microns == 0)
                                {
                                           setState(4); 
                                           //State = 4;
                              }
				else
                                  {
					//State = 2;
                                        setState(2);

                                   }
			}

			if (State == 2) {
				if (t-Train_Start_TS > TriggerDelay_Microns) {
					Train_Start_TS = micros();        
					//State = 4;
                                        setState(4);
				}
			}

			if (State == 4) { // Start pulse
        			if (NumTrains_Per_Trigger == 0) {
					if (digitalRead(TriggerPin)) {

						digitalWrite(OutputPin, HIGH);
						Pulse_Start_TS = micros();
						//State = 5;
                                                setState(5);
					} else {
						State = 0;
                                                setState(0);
					}
				} else  if (( (t-Train_Start_TS) < Train_Length_Microns)) {
					digitalWrite(OutputPin, HIGH);
					Pulse_Start_TS = micros();
                                        setState(5);
					//State = 5;
				} else {
					// wait inter-train interval
					if (NumTrains > 1)
                                        {
						//State = 8;
                                                setState(8);
                                        }
					else
                                        {
						//State = 0;
                                                setState(0);
                                        }
				}

			}

			if (State == 5) { // wait for pulse to finish
				if (t-Pulse_Start_TS > Pulse_Width_Microns) {
					digitalWrite(OutputPin, LOW);
					//State = 6;
                                        setState(6);
				}
			}

			if (State == 6) {
				// do we have bi-polar pulses?
				if (SecondPulse > 0) {
					SecondPulse_TS=micros();
					//State = 9;
                                        setState(9);

				} else {
					//State = 7;
                                        setState(7);

				}
			}       

			if (State == 7) {
				// wait inter-pulse interval - trigger gate delay time.
				if ( (t-Pulse_Start_TS > 1.0/Pulse_Freq_Hz*1000000-GateDelay_Microns) || (1.0/Pulse_Freq_Hz*1000000 > 1.0/Train_Freq_Hz*1000000-GateDelay_Microns) || (t-Train_Start_TS) > Train_Length_Microns-GateDelay_Microns) {
                                     // go and wait the remaining time ( GateDelay_Microns)
                                      setState(71);
                                      // activate gate again...
                                      if ((t-Pulse_Start_TS > 1.0/Pulse_Freq_Hz*1000000-GateDelay_Microns))
                                      {
                                       GateState = 1;
                                       GateStartTS = micros()-GateDelay_Microns;
                                      }
    				        
				} 
      		        }   
   
			if (State == 71) {
                              // wait the remaining (GateDelay_Microns)
  				if ( (t-Pulse_Start_TS > 1.0/Pulse_Freq_Hz*1000000) || (1.0/Pulse_Freq_Hz*1000000 > 1.0/Train_Freq_Hz*1000000) || (t-Train_Start_TS) > Train_Length_Microns) {
					//State = 4; 
                                        setState(4);
				} 
                        }
      

			if (State == 8) {        // wait inter-train interval
				if (t-Train_Start_TS > 1.0/Train_Freq_Hz*1000000-GateDelay_Microns) {
					if (NumTrains == -1) {
                                           GateState = 1;
                                           GateStartTS = micros()-GateDelay_Microns;
                                          setState(81);
						
					} else if (NumTrains == 1) {
						//State = 0;
                                                setState(0);  

					} else {
                                               GateState = 1;
                                               GateStartTS = micros()-GateDelay_Microns;
  
                                                setState(81);
						NumTrains--;
					}
				}
			}
                        if (State == 81) {        // 
                                if (t-Train_Start_TS > 1.0/Train_Freq_Hz*1000000) {
                                  setState(4);
  				  Train_Start_TS = micros();
                                }
  
                        }
		
			if (State == 9) { 
				if (t-SecondPulse_TS > Second_Pulse_Delay_Microns) {
					digitalWrite(OutputPin, HIGH);          
					SecondPulse_TS = micros();
                                         setState(10);

//					State = 10;
				}
			}

			if (State == 10) { // wait until second pulse is done.
				if (t-SecondPulse_TS > Second_Pulse_Width_Microns) {
					digitalWrite(OutputPin, LOW);          
                                                setState(7);

//					State = 7;
				}

			}


		}


		void print_menu_item() {
			int k;
			current_string = String("");
			switch (menu_item) {
			case MENU_ITEM_IP:
				current_string = String(int(ip_rom[0]))+'.'+String(int(ip_rom[1]))+'.'+String(int(ip_rom[2]))+'.'+String(int(ip_rom[3]));
				break;
			case MENU_ITEM_PORT:
				current_string = String(localPort);
				break;
			case MENU_ITEM_LOAD_PRESET:
				current_string = String(int(current_preset));
				break;
			case MENU_ITEM_SAVE_PRESET:
				current_string = String(int(current_preset));
				break;
			case MENU_ITEM_CH1_PULSE_FREQ:
				current_string = String(FSM[0].Pulse_Freq_Hz)+String(" Hz");
				break;
			case MENU_ITEM_CH1_PULSE_WIDTH:
				current_string = Microns_To_String(FSM[0].Pulse_Width_Microns);
				break;
			case MENU_ITEM_CH1_TRIG_DELAY:
				current_string = Microns_To_String(FSM[0].TriggerDelay_Microns);
				break;
			case MENU_ITEM_CH1_TRAIN_FREQ:
				current_string = String(FSM[0].Train_Freq_Hz)+String(" Hz");
				break;
			case MENU_ITEM_CH1_TRAIN_DUR:
				if (FSM[0].Train_Length_Microns <= 1000)
					current_string = String(FSM[0].Train_Length_Microns)+String("usec");
				else if (FSM[0].Train_Length_Microns > 1000 && FSM[0].Train_Length_Microns <= 1000000)
					current_string = String(FSM[0].Train_Length_Microns/1000)+String(" ms");
				else current_string = String(FSM[0].Train_Length_Microns/1000000.0)+String(" sec");
				break;
			case MENU_ITEM_CH1_NUM_TRAINS:
				current_string = String(FSM[0].NumTrains_Per_Trigger);
				break;
			case MENU_ITEM_CH1_SECOND_PULSE:
				current_string = String(FSM[0].SecondPulse);
				break;
			case MENU_ITEM_CH1_Second_PULSE_WIDTH:
				current_string = Microns_To_String(FSM[0].Second_Pulse_Width_Microns);
				break;
			case MENU_ITEM_CH1_Second_PULSE_DELAY:
				current_string = Microns_To_String(FSM[0].Second_Pulse_Delay_Microns);
				break;
			case MENU_ITEM_CH1_AMPLITUDE:
				current_string = String(FSM[0].Amplitude);    
				break;
			case MENU_ITEM_CH2_PULSE_FREQ:
				current_string = String(FSM[1].Pulse_Freq_Hz)+String(" Hz");
				break;
			case MENU_ITEM_CH2_PULSE_WIDTH:
				current_string = Microns_To_String(FSM[1].Pulse_Width_Microns);
				break;
			case MENU_ITEM_CH2_TRIG_DELAY:
				current_string = Microns_To_String(FSM[1].TriggerDelay_Microns);
				break;
			case MENU_ITEM_CH2_TRAIN_FREQ:
				current_string = String(FSM[1].Train_Freq_Hz)+String(" Hz");
				break;
			case MENU_ITEM_CH2_TRAIN_DUR:
				if (FSM[1].Train_Length_Microns <= 1000)
					current_string = String(FSM[1].Train_Length_Microns)+String("usec");
				else if (FSM[1].Train_Length_Microns > 1000 && FSM[1].Train_Length_Microns <= 1000000)
					current_string = String(FSM[1].Train_Length_Microns/1000)+String("ms");
				else current_string = String(FSM[1].Train_Length_Microns/1000000.0)+String(" sec");
				break;
			case MENU_ITEM_CH2_NUM_TRAINS:
			current_string = String(FSM[1].NumTrains_Per_Trigger);
				break;
			case MENU_ITEM_CH2_SECOND_PULSE:
				current_string = String(FSM[1].SecondPulse);
				break;
			case MENU_ITEM_CH2_Second_PULSE_WIDTH:
				current_string = Microns_To_String(FSM[1].Second_Pulse_Width_Microns);
				break;
			case MENU_ITEM_CH2_Second_PULSE_DELAY:
				current_string = Microns_To_String(FSM[1].Second_Pulse_Delay_Microns);
				break;    
			case MENU_ITEM_CH2_AMPLITUDE:
				current_string = String(FSM[1].Amplitude);    
				break;    
			}
			lcd.setCursor(0, 1);
			//Serial.println(String("Menu Item:")+current_string);
			lcd.print(current_string); 
		}

		void turn_off() {
			// just to be on the safe side, turn off all stimulations....
			digitalWrite(FSM[0].OutputPin, LOW);   
			digitalWrite(FSM[1].OutputPin, LOW);     
		}

		void wait_key_up() {
                  int prev = 5000;
                  if (DEBUG_SERIAL)
                      Serial.println("Waiting for key release...");
                    bool looping = true;
			while (looping) {
				int value= ReadKey();
				int key = getKey(value);
				if (key == 0) {
                                  if (DEBUG_SERIAL)
                                    Serial.println("Key up detected. Breaking!");  
                                    looping = false;
                                  break;   
                                  }
                                if (DEBUG_SERIAL) {
                                  if (prev != value) {
                                    Serial.println(value);
                                    prev = value;
                                  }
                                }
                  
			}
    if (DEBUG_SERIAL)
    Serial.println("key release detected...");

		}


		char GetNextPrevChar(char ch, int dir) {
			const int NUM_CHARS = 17;
			char Chars[NUM_CHARS+1]="0123456789. usecm";
			int nextchar;
			for (int k=0;k<NUM_CHARS;k++) {
				if (ch == Chars[k]) {
					nextchar = k + dir;
					if (nextchar >= NUM_CHARS) nextchar = 0;
					if (nextchar < 0) nextchar = NUM_CHARS-1;
					return Chars[nextchar];
				}
			}
			return '0';
		}


		int parse_ip_from_string(String s, byte *ip) {
			int k;
			int numdots=0;
			int dotpos[3];
			String substr;
			for (k=0;k<s.length();k++) {
				if (s[k] == '.') dotpos[numdots++] = k;
				if (numdots > 3)
					return -1;
			}

		      int i;
			for (int k=0;k<4;k++) {
				// start-end
				if (k==0) {
					substr = s.substring(0,dotpos[0]);
					//      Serial.println("Sub0:");
					//      Serial.println(substr);
					for (i=0;i<17;i++) tmp_str[i] = (i< substr.length()) ?  substr[i] : 0;
					sscanf(tmp_str,"%d",&i);
					ip[0]=i;
				} else if (k==1 || k==2) {
					substr = s.substring(dotpos[k-1]+1,dotpos[k]);
					for (i=0;i<17;i++) tmp_str[i] = (i< substr.length()) ?  substr[i] : 0;
					sscanf(tmp_str,"%d",&i);
					ip[k]=i;
				} else if (k== 3) {
					substr = s.substring(dotpos[2]+1,s.length());
					for (i=0;i<17;i++) tmp_str[i] = (i< substr.length()) ?  substr[i] : 0;
					sscanf(tmp_str,"%d",&i);      
					ip[k]=i;
				}
			}    
			
			return 1;    
		}


		void edit_menu_item() {
			// wait until user releases the select key
			int key;
			turn_off();
			while (1) {
				if (getKey(ReadKey()) == 0) 
					break;
			}
			lcd.setCursor(0, 1);
			lcd.blink();
			prev_key = 0;
			byte inloop= 1;
			int cursor_pos = 0;
			byte ch;
			while (inloop) {
				key = getKey(ReadKey());
				switch (key) {
				case 1: //select
					inloop = 0;
					break;
				case 5: //right
					cursor_pos++; if (cursor_pos >= 16) cursor_pos = 0;
					lcd.setCursor(cursor_pos, 1);
					break;
				case 2: //left
					cursor_pos--; if (cursor_pos < 0) cursor_pos = 15;
					lcd.setCursor(cursor_pos, 1); 
					break;      
				case 3: //up
					if (cursor_pos >= current_string.length())
						current_string=current_string+' ';

					ch=GetNextPrevChar(current_string[cursor_pos],1);

					current_string[cursor_pos] = ch;
					lcd.setCursor(0, 1);   
					lcd.print(current_string);
					lcd.setCursor(cursor_pos, 1);   
					break;
				case 4: // down
					if (cursor_pos >= current_string.length())
						current_string=current_string+' ';

					ch=GetNextPrevChar(current_string[cursor_pos],1);

					ch=GetNextPrevChar(current_string[cursor_pos],-1);
					current_string[cursor_pos] = ch;
					lcd.setCursor(0, 1);   
					lcd.print(current_string);
					lcd.setCursor(cursor_pos, 1);   
					break;
				}

				wait_key_up();
			}
			lcd.noBlink();
			while (1) {
				if (getKey(ReadKey()) == 0) 
					break;
			}
			update_config_from_menu_item();
			print_menu();
		}

		void print_menu() {
			lcd.clear();
			lcd.setCursor(0, 0);

			if (menu_item >= 0 &&  menu_item < NUM_MENU_ITEMS) {
				lcd.print(MENU_ITEMS[menu_item]);
				print_menu_item();
			}
			else
				lcd.print(menu_item);
		}


		void write_preset_to_rom(int preset) {
			int offset = 12; // for keeping IP & port
			int base = offset+(preset)*PRESET_SIZE;
			int loc=0;
			//  Serial.print("Saving into preset ");  Serial.println(preset);
			//  Serial.print("Base: ");  Serial.println(base);

			for (int k=0;k<NUM_CHANNELS;k++) {
				//  Serial.println(String("Channel ")+String(int(k)));
				loc+=EEPROM_writeAnything(base+loc, FSM[k].TriggerDelay_Microns);
				loc+=EEPROM_writeAnything(base+loc, FSM[k].SecondPulse);
				loc+=EEPROM_writeAnything(base+loc, FSM[k].Pulse_Freq_Hz);
				loc+=EEPROM_writeAnything(base+loc, FSM[k].Pulse_Width_Microns);
				loc+=EEPROM_writeAnything(base+loc, FSM[k].Train_Length_Microns);
				loc+=EEPROM_writeAnything(base+loc, FSM[k].Train_Freq_Hz);
				loc+=EEPROM_writeAnything(base+loc, FSM[k].NumTrains_Per_Trigger);
				loc+=EEPROM_writeAnything(base+loc, FSM[k].Second_Pulse_Width_Microns);
				loc+=EEPROM_writeAnything(base+loc, FSM[k].Second_Pulse_Delay_Microns);    
				loc+=EEPROM_writeAnything(base+loc, FSM[k].Amplitude);            
				loc+=EEPROM_writeAnything(base+loc, FSM[k].Active);                
                                loc+=EEPROM_writeAnything(base+loc, FSM[k].GateDelay_Microns);
                                loc+=EEPROM_writeAnything(base+loc, FSM[k].GateLength_Microns);
                                loc+=EEPROM_writeAnything(base+loc, FSM[k].UsePhotodiodeSecondTrigger);
                                

				
				//Serial.println(String("TriggerDelay_Microns:")+String(FSM[k].TriggerDelay_Microns));
//				Serial.println(String("SecondPulse:")+String(FSM[k].SecondPulse));
//				Serial.println(String("Pulse_Freq_Hz:")+String(FSM[k].Pulse_Freq_Hz));
//				Serial.println(String("Pulse_Width_Microns:")+String(FSM[k].Pulse_Width_Microns));
//				Serial.println(String("Train_Length_Microns:")+String(FSM[k].Train_Length_Microns));
//				Serial.println(String("Train_Freq_Hz:")+String(FSM[k].Train_Freq_Hz));
//				Serial.println(String("NumTrains_Per_Trigger:")+String(FSM[k].NumTrains_Per_Trigger));
//				Serial.println(String("Second_Pulse_Width_Microns:")+String(FSM[k].Second_Pulse_Width_Microns));
//				Serial.println(String("Second_Pulse_Delay_Microns:")+String(FSM[k].Second_Pulse_Delay_Microns));    
//				Serial.println(String("Amplitude:")+String(FSM[k].Amplitude));        
				
			}

			for (int k=0;k<PRESET_NAME_LENGTH;k++) {
				loc+=EEPROM_writeAnything(base+loc, PRESET_NAMES[preset][k]);
			}

			if (DEBUG_SERIAL) {
				Serial.print(loc);Serial.println("  bytes written to ROM");  
			}
		}

		void  read_preset_from_rom(int preset){
  
			int offset = 12; // for keeping IP & port
			int base = offset+(preset)*PRESET_SIZE;
			int loc=0;
			for (int k=0;k<NUM_CHANNELS;k++) {
				//    Serial.println(String("Channel ")+String(int(k)));
				loc+=EEPROM_readAnything(base+loc, FSM[k].TriggerDelay_Microns);
				loc+=EEPROM_readAnything(base+loc, FSM[k].SecondPulse);
				loc+=EEPROM_readAnything(base+loc, FSM[k].Pulse_Freq_Hz);
				loc+=EEPROM_readAnything(base+loc, FSM[k].Pulse_Width_Microns);
				loc+=EEPROM_readAnything(base+loc, FSM[k].Train_Length_Microns);
				loc+=EEPROM_readAnything(base+loc, FSM[k].Train_Freq_Hz);
				loc+=EEPROM_readAnything(base+loc, FSM[k].NumTrains_Per_Trigger);
				loc+=EEPROM_readAnything(base+loc, FSM[k].Second_Pulse_Width_Microns);
				loc+=EEPROM_readAnything(base+loc, FSM[k].Second_Pulse_Delay_Microns);    
				loc+=EEPROM_readAnything(base+loc, FSM[k].Amplitude);        
				loc+=EEPROM_readAnything(base+loc, FSM[k].Active);

				loc+=EEPROM_readAnything(base+loc, FSM[k].GateDelay_Microns);
				loc+=EEPROM_readAnything(base+loc, FSM[k].GateLength_Microns);

                                loc+=EEPROM_readAnything(base+loc, FSM[k].UsePhotodiodeSecondTrigger);
				//Serial.println(String("TriggerDelay_Microns:")+String(FSM[k].TriggerDelay_Microns));
//				Serial.println(String("SecondPulse:")+String(FSM[k].SecondPulse));
//				Serial.println(String("Pulse_Freq_Hz:")+String(FSM[k].Pulse_Freq_Hz));
//				Serial.println(String("Pulse_Width_Microns:")+String(FSM[k].Pulse_Width_Microns));
//				Serial.println(String("Train_Length_Microns:")+String(FSM[k].Train_Length_Microns));
//				Serial.println(String("Train_Freq_Hz:")+String(FSM[k].Train_Freq_Hz));
//				Serial.println(String("NumTrains_Per_Trigger:")+String(FSM[k].NumTrains_Per_Trigger));
//				Serial.println(String("Second_Pulse_Width_Microns:")+String(FSM[k].Second_Pulse_Width_Microns));
//				Serial.println(String("Second_Pulse_Delay_Microns:")+String(FSM[k].Second_Pulse_Delay_Microns));    
//				Serial.println(String("Amplitude:")+String(FSM[k].Amplitude));        
				
			}
			//  Serial.print("Preset Name:");
			for (int k=0;k<PRESET_NAME_LENGTH;k++) {
				loc+=EEPROM_readAnything(base+loc, PRESET_NAMES[preset][k]);
				//     Serial.print(PRESET_NAMES[preset][k]);
			}
			//  Serial.println("");
			if (DEBUG_SERIAL) {
				Serial.print(loc);Serial.println("  bytes read from ROM");  
			}

		}

		int fnHasDot(String s) {
			for (int k=0;k<s.length();k++) {
				if (s[k] == '.')
					return 1;
			}
			return 0;    
		}

		long fnGetUnitMultiplier(String s) {
			s.toLowerCase();
			for (int k=0;k<s.length();k++) {
				if (s.substring(k) == String("usec"))
					return 1;
				if (s.substring(k) == String("ms"))
					return 1000;
				if (s.substring(k) == String("sec"))
					return 1000000;
			}
			return 1;    
		}

		String fnRemoveUnit( String S) {
			String s = S,a;
			s.toLowerCase();
			for (int k=0;k<s.length();k++) {
				if ( (s.substring(k) == String("usec")) ||  (s.substring(k) == String("ms")) || (s.substring(k) == String("sec")) || (s.substring(k) == String("hz"))) {
					a= S.substring(0, k);
					return a;
				}
			}

			return S;    
		}

		void ToChar(String s, char *ps) {
			for (int i=0;i<s.length();i++) ps[i] = s[i];
		}

		float ParseNumber(String s, int bUseUnits) {
			char tmp_str2[17];
			for (int i=0;i<17;i++)    
				tmp_str2[i]=0;    
			long f1,f2;
			float f_v;

			String strNoUnit = fnRemoveUnit(s);

			long Multiplier = bUseUnits ? fnGetUnitMultiplier(s) : 1;
			ToChar(strNoUnit, tmp_str2);
			f_v=atof(tmp_str2)* float(Multiplier);
			return f_v;
		}


		void update_config_from_menu_item() {
			int i1,success;

			int Unit;
			byte ip[4];
			int f1,f2;
			float f_v; 

			for (int i=0;i<17;i++) {
				tmp_str[i] = (i< current_string.length()) ?  current_string[i] : 0;

			}


			switch (menu_item) {
			case MENU_ITEM_LOAD_PRESET:
				// load preset
				if (DEBUG_SERIAL) {
					Serial.print("Loading preset ");Serial.println(current_preset);
				}
				sscanf(tmp_str,"%d", &current_preset);
				read_preset_from_rom(current_preset);
				break;  
			case MENU_ITEM_SAVE_PRESET:
				if (DEBUG_SERIAL) {
					Serial.print("Saving preset ");Serial.println(current_preset);
				}
				sscanf(tmp_str,"%d", &i1);
				if (i1 >= 0 && i1 < NUM_MAX_PRESETS) {
					current_preset = i1;
					write_preset_to_rom(current_preset);
				}
				break;  
			case MENU_ITEM_CH1_PULSE_FREQ:
				FSM[0].Pulse_Freq_Hz = ParseNumber(current_string, false);
				break;
			case MENU_ITEM_CH1_PULSE_WIDTH:
				FSM[0].Pulse_Width_Microns = ParseNumber(current_string, true);
				break;

			case MENU_ITEM_CH1_TRIG_DELAY:
				FSM[0].TriggerDelay_Microns = ParseNumber(current_string, true);
				break;
			case MENU_ITEM_CH1_TRAIN_FREQ:
				FSM[0].Train_Freq_Hz = ParseNumber(current_string, false);
				break;
			case MENU_ITEM_CH1_TRAIN_DUR:
				FSM[0].Train_Length_Microns = ParseNumber(current_string, true);
				break;
			case MENU_ITEM_CH1_NUM_TRAINS:
				FSM[0].NumTrains_Per_Trigger = ParseNumber(current_string, false);
				break;
			case MENU_ITEM_CH1_SECOND_PULSE:
				FSM[0].SecondPulse = ParseNumber(current_string, false);    
				break;
			case MENU_ITEM_CH1_Second_PULSE_WIDTH:
				FSM[0].Second_Pulse_Width_Microns = ParseNumber(current_string, true);
				break;
			case MENU_ITEM_CH1_Second_PULSE_DELAY:
				FSM[0].Second_Pulse_Delay_Microns = ParseNumber(current_string, true);
				break;
			case MENU_ITEM_CH1_AMPLITUDE:
				FSM[0].Amplitude = ParseNumber(current_string, false);
				break;
			case MENU_ITEM_CH1_SIM_TRIG:
				FSM[0].Software_Trig = 1;
				break;
			case MENU_ITEM_CH2_PULSE_FREQ:
				FSM[1].Pulse_Freq_Hz = ParseNumber(current_string, false);
				break;
			case MENU_ITEM_CH2_PULSE_WIDTH:
				FSM[1].Pulse_Width_Microns = ParseNumber(current_string, true);
				break;
			case MENU_ITEM_CH2_TRIG_DELAY:
				FSM[1].TriggerDelay_Microns = ParseNumber(current_string, true);
				break;
			case MENU_ITEM_CH2_TRAIN_FREQ:
				FSM[1].Train_Freq_Hz = ParseNumber(current_string, false);
				break;
			case MENU_ITEM_CH2_TRAIN_DUR:
				FSM[1].Train_Length_Microns = ParseNumber(current_string, true);
				break;
			case MENU_ITEM_CH2_NUM_TRAINS:
				FSM[1].NumTrains_Per_Trigger = ParseNumber(current_string, false);
				break;
			case MENU_ITEM_CH2_SECOND_PULSE:
				FSM[1].SecondPulse = ParseNumber(current_string, false);    
				break;
			case MENU_ITEM_CH2_Second_PULSE_WIDTH:
				FSM[1].Second_Pulse_Width_Microns = ParseNumber(current_string, true);
				break;
			case MENU_ITEM_CH2_Second_PULSE_DELAY:
				FSM[1].Second_Pulse_Delay_Microns = ParseNumber(current_string, true);
				break;
			case MENU_ITEM_CH2_AMPLITUDE:
				FSM[1].Amplitude = ParseNumber(current_string, false);
				break;
			case MENU_ITEM_CH2_SIM_TRIG:
				FSM[1].Software_Trig = 1;
				break;          
			}  
                        if (KEEP_CHANGES_IN_ROM) {
                             write_preset_to_rom(DEFAULT_PRESET);
                        }
                          


		}

		void TriggerFS0() {
			FSM[0].Hardware_Trig = 1;
		}

		void TriggerFS1() {
			FSM[1].Hardware_Trig = 1;
		}

		long numcalls =0;



		void SendStringToUser(String s) {
  					Serial.println(s);   
		}

		void SendCurrentSettingsOverTCP() {

			for (int ch=0;ch<NUM_CHANNELS;ch++) {
				SendStringToUser(String(FSM[ch].Pulse_Freq_Hz));
				SendStringToUser(String(FSM[ch].Pulse_Width_Microns));
				SendStringToUser(String(FSM[ch].Train_Length_Microns));
				SendStringToUser(String(FSM[ch].Train_Freq_Hz));
				SendStringToUser(String(FSM[ch].NumTrains_Per_Trigger));
				SendStringToUser(String(FSM[ch].SecondPulse));
				SendStringToUser(String(FSM[ch].Second_Pulse_Delay_Microns));
				SendStringToUser(String(FSM[ch].Second_Pulse_Width_Microns));
				SendStringToUser(String(FSM[ch].TriggerDelay_Microns));
				SendStringToUser(String(FSM[ch].Amplitude));
				SendStringToUser(String(FSM[ch].Active));
                                SendStringToUser(String(FSM[ch].GateDelay_Microns));
                                SendStringToUser(String(FSM[ch].GateLength_Microns));                                
                                SendStringToUser(String(FSM[ch].UsePhotodiodeSecondTrigger));                                

			}
		}



		byte apply_command() {

			int channel=-1;
			long f1,f2,f3,f4,k;
			long value;
			float frequency;
			float trainlengthMS;

			int command = (packetBuffer[0]-'0') * 10 + packetBuffer[1]-'0';
			char str[PRESET_NAME_LENGTH];
			byte successful = false;
			if (DEBUG_SERIAL) {
				Serial.print("Command:");
				Serial.println(command);
			}
			switch (command) {
			case TCP_MODIFY_PULSE_FREQ: // Moify pulse frequency
				sscanf (packetBuffer,"%d %d",&command, &channel);
				frequency = atof(packetBuffer+4);
				if (channel >= 0 && channel < NUM_CHANNELS) {
					FSM[channel].Pulse_Freq_Hz = frequency;
                                        if (KEEP_CHANGES_IN_ROM) {
                                             write_preset_to_rom(DEFAULT_PRESET);
                                        }

					successful = true;
					if (DEBUG_SERIAL) {
						Serial.print("Set pulse frequency: ");
						Serial.print("Channel :");
						Serial.println(channel);
						Serial.print("Freq (Hz):");
						Serial.println(frequency);
					}
					if (DEBUG_LCD) {
						menu_item = MENU_ITEM_CH1_PULSE_FREQ + channel*NUM_MENU_ITEMS_PER_CHANNEL;
						print_menu();
						print_menu_item();
					}
				}
				break; 
			case TCP_MODIFY_PULSE_WIDTH:  // Modify pulse width
				sscanf (packetBuffer,"%d %d %ld",&command, &channel, &value);
				if (channel >= 0 && channel < NUM_CHANNELS && value > 0) {
					FSM[channel].Pulse_Width_Microns = value;
                                        if (KEEP_CHANGES_IN_ROM) {
                                             write_preset_to_rom(DEFAULT_PRESET);
                                        }

					successful = true;      
					if (DEBUG_SERIAL) {      
						Serial.print("Set pulse width: ");
						Serial.print("Channel :");
						Serial.println(channel);
						Serial.print("Width (ms) :");
						Serial.println(float(value)/1000.0);
					}
					if (DEBUG_LCD) {
						menu_item = MENU_ITEM_CH1_PULSE_WIDTH  + channel*NUM_MENU_ITEMS_PER_CHANNEL;
						print_menu();
						print_menu_item();
					}

				}
				break; 

			case TCP_MODIFY_SECOND_PULSE:  // Modify second pulse mode
				sscanf (packetBuffer,"%d %d %ld",&command, &channel, &f1);
				if (channel >= 0 && channel < NUM_CHANNELS ) {
					FSM[channel].SecondPulse = f1;
                                        if (KEEP_CHANGES_IN_ROM) {
                                             write_preset_to_rom(DEFAULT_PRESET);
                                        }

					successful = true;     
					if (DEBUG_SERIAL) { 
						Serial.print("Set second pulse pulse : ");
						Serial.print("Channel :");
						Serial.println(channel);
						Serial.print("Bipolar (bool) :");
						Serial.println(f1);
					}
					if (DEBUG_LCD) {
						menu_item = MENU_ITEM_CH1_SECOND_PULSE  + channel*NUM_MENU_ITEMS_PER_CHANNEL;
						print_menu();
						print_menu_item();
					}
				}

				break;     

			case TCP_MODIFY_TRAIN_LENGTH: // Modify train length
				sscanf (packetBuffer,"%d %d %ld",&command, &channel, &value);
				if (channel >= 0 && channel < NUM_CHANNELS) {
					FSM[channel].Train_Length_Microns = value;
                                        if (KEEP_CHANGES_IN_ROM) {
                                             write_preset_to_rom(DEFAULT_PRESET);
                                        }

					successful = true;    
					if (DEBUG_SERIAL) {
						Serial.print("Set train length: ");
						Serial.print("Channel :");
						Serial.println(channel);
						Serial.print("Length (microns):");
						Serial.println(value);
					}
					if (DEBUG_LCD) {
						menu_item = MENU_ITEM_CH1_TRAIN_DUR  + channel*NUM_MENU_ITEMS_PER_CHANNEL;
						print_menu();
						print_menu_item();
					}

				}
				break; 
			case TCP_MODIFY_TRAIN_FREQ: // Modify train frequency
				sscanf (packetBuffer,"%d %d",&command, &channel);
				frequency = atof(packetBuffer+4);
				if (channel >= 0 && channel < NUM_CHANNELS) {
					FSM[channel].Train_Freq_Hz = frequency;
                                        if (KEEP_CHANGES_IN_ROM) {
                                             write_preset_to_rom(DEFAULT_PRESET);
                                        }

					successful = true;   
					if (DEBUG_SERIAL) {
						Serial.print("Set train frequency: ");
						Serial.print("Channel :");
						Serial.println(channel);
						Serial.print("Freq (Hz):");
						Serial.println(frequency);
					}
					if (DEBUG_LCD) {
						menu_item = MENU_ITEM_CH1_TRAIN_FREQ  + channel*NUM_MENU_ITEMS_PER_CHANNEL;
						print_menu();
						print_menu_item();
					}

				}
				break; 
			case TCP_MODIFY_NUM_TRAINS:  // Modify number of trains per trigger
				sscanf (packetBuffer,"%d %d %ld",&command, &channel, &value);
				if (channel >= 0 && channel < NUM_CHANNELS) {
					FSM[channel].NumTrains_Per_Trigger = value;
                                        if (KEEP_CHANGES_IN_ROM) {
                                             write_preset_to_rom(DEFAULT_PRESET);
                                        }

					successful = true;   
					if (DEBUG_SERIAL) {
						Serial.print("Set number of trains: ");
						Serial.print("Channel :");
						Serial.println(channel);
						Serial.print("Number of trains  :");
						Serial.println(value);
					}
					if (DEBUG_LCD) {
						menu_item = MENU_ITEM_CH1_NUM_TRAINS  + channel*NUM_MENU_ITEMS_PER_CHANNEL;
						print_menu();
						print_menu_item();
					}

				}
				break; 
			case TCP_MODIFY_TRIG_DELAY: // modify trigger delay
				sscanf (packetBuffer,"%d %d %ld",&command, &channel, &value);
				if (channel >= 0 && channel < NUM_CHANNELS) {
					FSM[channel].TriggerDelay_Microns = value;   
                                        if (KEEP_CHANGES_IN_ROM) {
                                             write_preset_to_rom(DEFAULT_PRESET);
                                        }

					successful = true;    
					if (DEBUG_SERIAL) {
						Serial.print("Set trigger delay: ");
						Serial.print("Channel :");
						Serial.println(channel);
						Serial.print("Delay (usec)  :");
						Serial.println(value);
					}
					if (DEBUG_LCD) {
						menu_item = MENU_ITEM_CH1_TRIG_DELAY  + channel*NUM_MENU_ITEMS_PER_CHANNEL;
						print_menu();
						print_menu_item();
					}

				}
				break; 
                        case TCP_MODIFY_GATE_DELAY:
	                        sscanf (packetBuffer,"%d %d %ld",&command, &channel, &value);
				if (channel >= 0 && channel < NUM_CHANNELS) {
					FSM[channel].GateDelay_Microns = value;   
                                        if (KEEP_CHANGES_IN_ROM) {
                                             write_preset_to_rom(DEFAULT_PRESET);
                                        }

					successful = true;    
					if (DEBUG_SERIAL) {
						Serial.print("Set gate trigger delay: ");
						Serial.print("Channel :");
						Serial.println(channel);
						Serial.print("Delay (usec)  :");
						Serial.println(value);
					}
                                  }
	                          break;
                               case TCP_MODIFY_GATE_LENGTH:
	                        sscanf (packetBuffer,"%d %d %ld",&command, &channel, &value);
				if (channel >= 0 && channel < NUM_CHANNELS) {
					FSM[channel].GateLength_Microns = value;   
                                        if (KEEP_CHANGES_IN_ROM) {
                                             write_preset_to_rom(DEFAULT_PRESET);
                                        }

					successful = true;    
					if (DEBUG_SERIAL) {
						Serial.print("Set gate trigger delay: ");
						Serial.print("Channel :");
						Serial.println(channel);
						Serial.print("Delay (usec)  :");
						Serial.println(value);
					}
                                  }
	                          break;

case TCP_MODIFY_PHOTODIODE_TRIGGER:
	                        sscanf (packetBuffer,"%d %d %ld",&command, &channel, &value);
				if (channel >= 0 && channel < NUM_CHANNELS) {
					FSM[channel].UsePhotodiodeSecondTrigger = value;   


    	                      lcd.setCursor(0, 1);
                              if (FSM[channel].UsePhotodiodeSecondTrigger)
                                lcd.print("Photodiode Active");  
                                else
                                lcd.print("Photodiode Inactive");  

                                        if (KEEP_CHANGES_IN_ROM) {
                                             write_preset_to_rom(DEFAULT_PRESET);
                                        }

					successful = true;    
					if (DEBUG_SERIAL) {
						Serial.print("Set photodiode trigger: ");
						Serial.print("Channel :");
						Serial.println(channel);
						Serial.print("Delay (usec)  :");
						Serial.println(value);
					}
                                  }
	                          break;







			case TCP_MODIFY_SECOND_PULSE_WIDTH: // modify second pulse width
				sscanf (packetBuffer,"%d %d %ld",&command, &channel, &value);
				if (channel >= 0 && channel < NUM_CHANNELS) {
					FSM[channel].Second_Pulse_Width_Microns = value;   
                                        if (KEEP_CHANGES_IN_ROM) {
                                             write_preset_to_rom(DEFAULT_PRESET);
                                        }

					successful = true;    
					if (DEBUG_SERIAL) {
						Serial.print("Set second pulse width: ");
						Serial.print("Channel :");
						Serial.println(channel);
						Serial.print("Second pulse width (usec)  :");
						Serial.println(value);
					} 
					if (DEBUG_LCD) {
						menu_item = MENU_ITEM_CH1_Second_PULSE_WIDTH  + channel*NUM_MENU_ITEMS_PER_CHANNEL;
						print_menu();
						print_menu_item();
					}
				}
				break;  
			case TCP_MODIFY_SECOND_PULSE_DELAY: // modify second pulse delay (usec)
				sscanf (packetBuffer,"%d %d %ld",&command, &channel, &value);
				if (channel >= 0 && channel < NUM_CHANNELS) {
					FSM[channel].Second_Pulse_Delay_Microns = value;   
                                        if (KEEP_CHANGES_IN_ROM) {
                                             write_preset_to_rom(DEFAULT_PRESET);
                                        }

					successful = true;    
					if (DEBUG_SERIAL) {      
						Serial.print("Set second pulse delay: ");
						Serial.print("Channel :");
						Serial.println(channel);
						Serial.print("Second pulse delay (usec)  :");
						Serial.println(value);
					}
					if (DEBUG_LCD) {
						menu_item = MENU_ITEM_CH1_Second_PULSE_DELAY  + channel*NUM_MENU_ITEMS_PER_CHANNEL;
						print_menu();
						print_menu_item();
					}

				}
				break;      

			case TCP_MODIFY_AMPLITUDE: // modify second pulse delay (usec)
				sscanf (packetBuffer,"%d %d",&command, &channel);
				frequency = atof(packetBuffer+4);
				if (channel >= 0 && channel < NUM_CHANNELS) {
                                  if (channel == 0)
                                      analogWrite(DAC0,frequency);     
                                    else
                                      analogWrite(DAC1,frequency);                    
  
					FSM[channel].Amplitude = frequency;   
                                        if (KEEP_CHANGES_IN_ROM) {
                                             write_preset_to_rom(DEFAULT_PRESET);
                                        }

					successful = true;    
					if (DEBUG_SERIAL) {
						Serial.print("Set Amplitude: ");
						Serial.print("Channel :");
						Serial.println(channel);
						Serial.print("Second pulse delay (usec)  :");
						Serial.println(frequency);
					}
					if (DEBUG_LCD) {
						menu_item = MENU_ITEM_CH1_AMPLITUDE  + channel*NUM_MENU_ITEMS_PER_CHANNEL;
						print_menu();
						print_menu_item();
					}

				}
				break;          
			case TCP_SOFT_TRIGGER: // simulate soft trigger
				sscanf (packetBuffer,"%d %d",&command, &channel);
				if (channel >= 0 && channel < NUM_CHANNELS) {
					FSM[channel].Software_Trig = true;   
            
					successful = true;    
					if (DEBUG_SERIAL) {
						Serial.print("Soft rigger: ");
						Serial.print("Channel :");
						Serial.println(channel);
					}
				}
				break;      

			case TCP_SAVE_PRESET: // save settings as a preset
				sscanf (packetBuffer,"%d %ld",&command, &f1);
				if (f1 >= 0 && f1 < NUM_MAX_PRESETS) {
					successful = true;    
					if (DEBUG_SERIAL) {
						Serial.print(String("Saving current settings in preset: ")+String(f1));
					}

					write_preset_to_rom(f1);
					read_preset_from_rom(f1);
				}
				break;      
			case TCP_LOAD_PRESET: // load saved preset
				sscanf (packetBuffer,"%d %ld",&command, &f1);
				if (f1 >= 0 && f1 < NUM_MAX_PRESETS) {
					successful = true;    
					read_preset_from_rom(f1);
					if (DEBUG_SERIAL) {
						Serial.print("Loading settings from preset: ");
						Serial.println(f1);
					}
					for (channel =0;channel < NUM_CHANNELS;channel++) {
						digitalWrite(FSM[channel].OutputPin, LOW);                  
						FSM[channel].State= 0;
					}
				}
                            break;
			case TCP_TOGGLE_CHANNEL_ACTIVE: // disable/enable channel

				sscanf (packetBuffer,"%d %d %ld",&command, &channel, &f1);
				if (channel >= 0 && channel < NUM_CHANNELS) {
					successful = true;    
					FSM[channel].Active = f1;      
                            if (KEEP_CHANGES_IN_ROM) {
                                             write_preset_to_rom(DEFAULT_PRESET);
                                        }


					if (DEBUG_SERIAL) {        
						if (f1 == 0)
							Serial.print("Disabling trigger on channel: ");
						else
							Serial.print("Enabling trigger on channel: ");
						Serial.println(channel);
					}
				}
				break;      
                        case TCP_GET_TRIGGER_COUNT:
                              Serial.println(String("TriggerCount ")+String(FSM[0].ExternallyTriggeredCount) + String(" ") + String(FSM[1].ExternallyTriggeredCount));
                              successful=true;      
                                break;
                        case TCP_ABORT_STIMULATION:
                              digitalWrite(FSM[0].OutputPin, LOW);
                              digitalWrite(FSM[1].OutputPin, LOW);
                              FSM[0].State = 0;                              
                              FSM[1].State = 0;                              
                              successful=true;      
                                break;
                                
			case TCP_GET_CURRENT_SETTINGS:
				SendCurrentSettingsOverTCP();    
				successful=true;      
				break;

			case TCP_GET_PRESET_NAMES:
				for (f1=0;f1<NUM_MAX_PRESETS;f1++) {
					SendStringToUser(String(PRESET_NAMES[f1]));
				}
				successful=true;      
				break;

			case TCP_MODIFY_PRESET_NAME:
				sscanf (packetBuffer,"%d %ld %s",&command, &f1, str);
				for (k=0;k<PRESET_NAME_LENGTH;k++) PRESET_NAMES[f1][k] = 0;

				for (k=0;k<PRESET_NAME_LENGTH;k++) {
					PRESET_NAMES[f1][k] = str[k];           
					if (str[k]==0) break;
				}

				//      Serial.println(PRESET_NAMES[f1]);
				successful=true;      
				break;
			case TCP_PING:
				//        Serial.println("PONG");
				successful=true;
				break;


			}

			if (channel >= 0 && channel < NUM_CHANNELS) {
				// just to be safe, turn off and restart machine
				digitalWrite(FSM[channel].OutputPin    , LOW);
				FSM[channel].State= 0;
			}

			return successful;
		}


		int getKey(int value) {
			
			//static int UPKEY_ARV = 144; //that's read "analogue read value"
//			static int DOWNKEY_ARV = 329;
//			static int LEFTKEY_ARV = 505;
//			static int RIGHTKEY_ARV = 0;
//			static int SELKEY_ARV = 742;
//			static int NOKEY_ARV = 1023;
			
			int constants[6] = {
                          ///   nokey, select, left, up, down, right
				1023, 900,     748,  485, 215, 0  };
				int min = 1023;
				int key;
				for (int k=0;k<6;k++) {
					int diff = abs(constants[k]-value);
					if (diff <= min){
						min = diff;
						key = k;
					}
				}  
				if (min <= 30)
					return key;
				else
					return 0; // no key
		}


		void check_key_press() {
			int value= ReadKey();

			int key = getKey(value);
			if (DEBUG_SERIAL && key != 0) {
				Serial.print("Analog ");Serial.print(value);Serial.print(" Key : ");Serial.println(key);
			}
			if (key != 0) {
				switch (key) {
				case 5: //right
					menu_item++;
					if (menu_item >= NUM_MENU_ITEMS)
						menu_item = 0;
					print_menu();      
					break;
				case 2: //left
					menu_item--;
					if (menu_item < 0)
						menu_item =  NUM_MENU_ITEMS-1;
                                        print_menu();      
					break;
				case 1:
					edit_menu_item();      
					break;      
				}
				wait_key_up();    


			}
		}



		void fnHandleSerialCommunication() {
			if (Serial.available() > 0) {
				// get incoming byte:
				char inByte = Serial.read();
				if (inByte == 10) {  // new line
					packetBuffer[buffer_index] = 0;
					//Serial.println(String("Command Recved ") + String(packetBuffer));
					buffer_index = 0;

					byte successful = apply_command();
					// send a reply, to the IP address and port that sent us the packet we received
					if (successful)
						Serial.println(String("OK! ")+String(packetBuffer));   
					else
						Serial.println(String("NOK ")+String(packetBuffer));   


				} else {
					packetBuffer[buffer_index++] = inByte;
					if (buffer_index >= MAX_BUFFER-1) {
						buffer_index = MAX_BUFFER-1;
					}

				}

			}
		}

                void TrigFSM0()
                {
                  FSM[0].triggerDetectedByInterrupt = true;
                }
               void TrigFSM1()
                {
                  FSM[1].triggerDetectedByInterrupt = true;                  
                }                
                
                void TrigPhotodiode()
                {
                  if (FSM[0].Armed)
                    FSM[0].photodiodeDetectedByInterrupt = true;
                    
                  if (FSM[1].Armed)                    
                    FSM[1].photodiodeDetectedByInterrupt = true;
                    

                }
                
		void setupPins() {
			// All on PORTB!
			FSM[0].TriggerPin = 2;
			FSM[0].OutputPin = 22;  
			FSM[0].ID = 0;
                        FSM[0].GatePin = 26;
                        FSM[0].PhotodiodePin = 32;
                        
                        
                        
			FSM[1].TriggerPin = 3; 
			FSM[1].OutputPin = 24;  
			FSM[1].ID = 1;   
                        FSM[1].GatePin = 28;
                        FSM[1].PhotodiodePin = 32;                        
                        
                              
                      pinMode(11,INPUT);
                      
			for (int k=0;k<NUM_CHANNELS;k++) {
				pinMode(FSM[k].OutputPin, OUTPUT);
				pinMode(FSM[k].GatePin, OUTPUT);
				digitalWrite(FSM[k].OutputPin,LOW);
				pinMode(FSM[k].TriggerPin, INPUT);
                                pinMode(FSM[k].PhotodiodePin, INPUT);
				digitalWrite(FSM[k].TriggerPin, LOW); // Pin 
			}

                     attachInterrupt(FSM[0].TriggerPin, TrigFSM0,RISING);
                        attachInterrupt(FSM[1].TriggerPin, TrigFSM1,RISING);
                        
                        attachInterrupt(FSM[0].PhotodiodePin, TrigPhotodiode,CHANGE); // both share this line...
                        //attachInterrupt(FSM[1].PhotodiodePin, TrigPhotodiode1,CHANGE);
     
		}

void SetupDefaultValues()
{
 
  for (int i=0;i<NUM_MAX_PRESETS;i++)
  for (int j=0;j<PRESET_NAME_LENGTH;j++)
   PRESET_NAMES[i][j] = 0;

				 FSM[0].TriggerDelay_Microns = 0;
				 FSM[0].SecondPulse = 1 ;
				 FSM[0].Pulse_Freq_Hz = 300;
                                 FSM[0].Pulse_Width_Microns = 150;
				 FSM[0].Train_Length_Microns = 100000;
				 FSM[0].Train_Freq_Hz = 1;
				 FSM[0].NumTrains_Per_Trigger = 1;
				 FSM[0].Second_Pulse_Width_Microns = 150;
				 FSM[0].Second_Pulse_Delay_Microns = 100;
				 FSM[0].Amplitude = 1;
				 FSM[0].Active = 1;
                                 FSM[0].GateDelay_Microns = 0;
                                 FSM[0].GateLength_Microns = 0;                                 
  


				 FSM[1].TriggerDelay_Microns = 0;
				 FSM[1].SecondPulse = 0 ;
				 FSM[1].Pulse_Freq_Hz = 80;
                                 FSM[1].Pulse_Width_Microns = 8000;
				 FSM[1].Train_Length_Microns = 100000;
				 FSM[1].Train_Freq_Hz = 1;
				 FSM[1].NumTrains_Per_Trigger = 1;
				 FSM[1].Second_Pulse_Width_Microns = 0;
				 FSM[1].Second_Pulse_Delay_Microns = 0;
				 FSM[1].Amplitude = 1;
				 FSM[1].Active = 1;
                                 FSM[1].GateDelay_Microns = 0;
                                 FSM[1].GateLength_Microns = 0;                                 
  
   
}
		void setupLCD() {
			lcd.begin(16, 2);
			lcd.clear();
			lcd.setCursor(0, 0);
			lcd.print("Nano Stimulator");

			lcd.setCursor(0, 1);
                        if (!DEBUG_LCD)
                          lcd.print("keys disabled.");  
                        else
  			  lcd.print("v1.0");


			lcd.setCursor(0, 1);
			lcd.noBlink();
			//delay(1500);

		}

	

void setup() {
			Serial.begin(SERIAL_SPEED);  
			Serial.println("Initializing device...");


  Wire.begin();  
  // Do this only if you changed EEPROM settings
/*
  SetupDefaultValues();
  	for (int pres=NUM_MAX_PRESETS-1;pres>=0;pres--) {
          write_preset_to_rom(pres);		
  }
*/
			setupLCD();
			setupPins();  

	
			// This will read all preset names, and keep preset 0 as the active one...
			for (int pres=NUM_MAX_PRESETS-1;pres>=0;pres--) {
				read_preset_from_rom(pres); 
                        }
			menu_item = 0;
			//print_menu();  

                       digitalWrite(FSM[0].GatePin,LOW);
                       digitalWrite(FSM[1].GatePin,LOW);

                       digitalWrite(FSM[0].OutputPin,LOW);
                       digitalWrite(FSM[1].OutputPin,LOW);

			Serial.println("Initialization Done!");
                    analogWriteResolution( 12);
                       analogWrite(DAC0,0);     
                    analogWrite(DAC1,0);                    
}

 int prev_v=0;
void loop() {
/*
			int value= ReadKey();
if (value != prev_v) {
prev_v = value;
Serial.println(value);
}
return; */
	if (FSM[0].Active > 0) 
		FSM[0].non_block_loop();
	if (FSM[1].Active > 0) 
		FSM[1].non_block_loop();  

  fnHandleSerialCommunication();

              if (DEBUG_LCD) {
			t_ms = millis();
  			if (t_ms-t_noncritical >= 100) {
				check_key_press();
				t_noncritical=t_ms;
				
			}
                  }
}


