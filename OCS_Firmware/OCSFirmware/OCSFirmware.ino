

#include <ble_mini.h>

#define FIRMWARE_VERSION "1.2"

//comment this out to use discrete LEDs (internal fixation)
#define USE_OLED_DISPLAY

//OLED definitions
#define OLED_TX 10
#define OLED_RX 9
#define OLED_SPOT_COLOR GREEN
#define OLED_SPOT_RADIUS 4
#define OLED_SPOT_CENTER 64,64
#define OLED_SPOT_UP 0+OLED_SPOT_RADIUS,0+OLED_SPOT_RADIUS
#define OLED_SPOT_DOWN 128-OLED_SPOT_RADIUS,128-OLED_SPOT_RADIUS
#define OLED_SPOT_LEFT 0+OLED_SPOT_RADIUS,128-OLED_SPOT_RADIUS
#define OLED_SPOT_RIGHT 128-OLED_SPOT_RADIUS,0+OLED_SPOT_RADIUS
#define OLED_LEFT_DETECT 8
#define OLED_RIGHT_DETECT 5
#define OLED_POWER_EN 4 

#define FIXATION_LIGHT_CENTER 5
#define FIXATION_LIGHT_LEFT 6 
#define FIXATION_LIGHT_RIGHT 9 
#define FIXATION_LIGHT_UP 10
#define FIXATION_LIGHT_DOWN 3

#define KILL 7
#define TRIGGER 8
#define BLE_RESET A2
#define BLUE_LED A3
#define RED_LED A4
#define GREEN_LED A5
#define RED_LIGHT_ENABLE A1
#define RED_LIGHT_PWM 11
#define WHITE_LIGHT_ENABLE A0
#define WHITE_LIGHT_PWM 13
#define BATTERY A11

#define BATTERY_GREEN_TO_RED_THRESHOLD 3.3
#define BATTERY_RED_TO_GREEN_THRESHOLD 3.5


#define IDLE_POWEROFF 300000 //5 minutes before auto shutDown
#define BTLE_KEEPALIVE_TIMEOUT 5000 //5 seconds before bluetooth LED turns off due to lack of communication from phone
#define LOW_PRIORITY_COMMAND_INTERVAL 100 //"low priority" commands get executed every 1s


#ifdef USE_OLED_DISPLAY
  #include <SoftwareSerial.h>
  SoftwareSerial DisplaySerial(OLED_TX,OLED_RX);
  #include "Goldelox_Serial_4DLib.h"
  #include "Goldelox_Const4D.h"    
  Goldelox_Serial_4DLib Display(&DisplaySerial);  
#endif

unsigned long lastBTLETimestamp;
unsigned long lastKeepaliveTimestamp;
unsigned long lastLowPriorityIterationTimestamp;

boolean bleConnected = false;
byte flashWhiteIntensity = 0;
byte flashRedIntensity = 0;
unsigned int flashDelay = 0;
unsigned int flashDuration = 0;
byte currentWhiteIntensity = 0;
byte currentRedIntensity = 0;
byte currentFixationLight = 0;
byte currentFixationIntensity = 0;
byte displayXCoordinate = 0;
byte displayYCoordinate = 0;

void setLights(byte whiteIntensity, byte redIntensity);
void setFixation(byte fixationLight, byte intensity);
void refreshDisplay();
void setBatteryIndicator(boolean batteryOK);

void setup()
{
   
  
  pinMode(KILL, OUTPUT);
  pinMode(BLUE_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  pinMode(RED_LED, OUTPUT);
  pinMode(RED_LIGHT_ENABLE, OUTPUT);
  pinMode(RED_LIGHT_PWM, OUTPUT);
  pinMode(WHITE_LIGHT_ENABLE, OUTPUT);
  pinMode(WHITE_LIGHT_PWM, OUTPUT);
  pinMode(BLE_RESET, OUTPUT); 
  pinMode(BATTERY, INPUT);
  pinMode(TRIGGER, INPUT);
  pinMode(OLED_POWER_EN, OUTPUT);
  
  BLEMini_begin(57600);

  //initial state of outputs
  digitalWrite(KILL, LOW);
  digitalWrite(BLE_RESET, LOW);
  digitalWrite(BLUE_LED, HIGH);
  digitalWrite(GREEN_LED, LOW);
  digitalWrite(RED_LED, HIGH);
  digitalWrite(OLED_POWER_EN, LOW);
  
  #ifdef USE_OLED_DISPLAY
    DisplaySerial.begin(9600); 
    pinMode(OLED_LEFT_DETECT, INPUT_PULLUP);
    pinMode(OLED_RIGHT_DETECT, INPUT_PULLUP);
  #else
    pinMode(FIXATION_LIGHT_UP, OUTPUT);
    pinMode(FIXATION_LIGHT_DOWN, OUTPUT);
    pinMode(FIXATION_LIGHT_LEFT, OUTPUT);
    pinMode(FIXATION_LIGHT_RIGHT, OUTPUT);  
    digitalWrite(FIXATION_LIGHT_UP, LOW);
    digitalWrite(FIXATION_LIGHT_DOWN, LOW);
    digitalWrite(FIXATION_LIGHT_LEFT, LOW);
    digitalWrite(FIXATION_LIGHT_RIGHT, LOW);
    digitalWrite(FIXATION_LIGHT_CENTER, LOW);  
   
  #endif

  digitalWrite(RED_LIGHT_ENABLE, LOW);
  digitalWrite(WHITE_LIGHT_ENABLE, LOW);  
  analogWrite(RED_LIGHT_PWM, 0);
  analogWrite(WHITE_LIGHT_PWM, 0);

  lastBTLETimestamp = millis();
  lastKeepaliveTimestamp = millis();
  lastLowPriorityIterationTimestamp = millis();
}

void splashScreen()
{
  
  #ifdef USE_OLED_DISPLAY
  
    static char state = 0;
    
    if (state==0 && millis()>3000)
    {
      Display.gfx_Cls();
      delay(50);
      Display.txt_Attributes(BOLD) ; 
      delay(50);  
      Display.txt_BGcolour(BLACK) ;   
      delay(50);     
      Display.txt_FGcolour(WHITE) ; 
      delay(50);     
      Display.txt_FontID(SYSTEM) ; 
      delay(50); 
      Display.txt_MoveCursor(3, 0);
      delay(50);    
      Display.putstr("Ocular CellScope"); 
      delay(50); 
      Display.txt_MoveCursor(4, 0);
      delay(50);    
      Display.putstr("UC Berkeley"); 
      delay(50);
      Display.txt_MoveCursor(5, 0); 
      delay(50);       
      Display.putstr("Fletcher Lab");  
      delay(50);    
      Display.txt_MoveCursor(11, 0);  
      delay(50);    
      char fw[20] = "Firmware ";
      strcat(fw,FIRMWARE_VERSION);   
      Display.putstr(fw);  
      delay(50);     
      
      state = 1;
    }
    else if (state==1 && millis()>6000)
    {
      Display.gfx_Cls();
      delay(50);
    }
  
  #endif
}

void selfTest()
{
    //TEST ILLUMINATION   
    for (int i=0;i<20;i++)
    {
        setLights(i,0);
        delay(100);
    }
    setLights(0,0);
    
    for (int i=0;i<20;i++)
    {
        setLights(0,i);
        delay(100);
    }
    setLights(0,0);    
    
    //TEST FIXATION
    setFixation(FIXATION_LIGHT_UP,0x255);
    refreshDisplay();
    delay(1000);
    setFixation(FIXATION_LIGHT_DOWN,0x255);
    refreshDisplay();
    delay(1000);
    setFixation(FIXATION_LIGHT_RIGHT,0x255);
    refreshDisplay();
    delay(1000);
    setFixation(FIXATION_LIGHT_LEFT,0x255);
    refreshDisplay();
    delay(1000);
    setFixation(FIXATION_LIGHT_CENTER,0x255);
    refreshDisplay();
    delay(1000);

    //TEST INDICATORS
    setBatteryIndicator(false);
    delay(1000);
    setBatteryIndicator(true);
    delay(1000);
    digitalWrite(BLUE_LED,LOW);
    delay(1000);
    digitalWrite(BLUE_LED,HIGH);
}

//TODO: currently no way to detect a broken connection...could do keepalive packets
void checkBTLEState() {
  
 //this is a hack, not working well
 if ((millis() - lastKeepaliveTimestamp) > BTLE_KEEPALIVE_TIMEOUT)
   bleConnected = false;
   
 if (bleConnected)
    digitalWrite(BLUE_LED, LOW);
 else
    digitalWrite(BLUE_LED, HIGH); 
}

void setBatteryIndicator(boolean batteryOK) {
  if (batteryOK) {
    digitalWrite(RED_LED, HIGH);  
    digitalWrite(GREEN_LED, LOW);      
  }
  else {
    digitalWrite(RED_LED, LOW);  
    digitalWrite(GREEN_LED, HIGH);  
  }  
}

void setFixation(byte fixationLight, byte intensity) //TODO: refactor the API so cmd is "fixation" param1 is 0(none),1,2,3,4,5, and param2 is intensity
{
  currentFixationLight = fixationLight;
  currentFixationIntensity = intensity;
  
#ifdef USE_OLED_DISPLAY
  switch (fixationLight) {
    case 1:
      setOLEDCoordinates(OLED_SPOT_CENTER);
      break;
    case 2:
      setOLEDCoordinates(OLED_SPOT_UP);
      break;
    case 3:
      setOLEDCoordinates(OLED_SPOT_DOWN);
      break;
    case 4:
      setOLEDCoordinates(OLED_SPOT_LEFT);
      break;
    case 5:
      setOLEDCoordinates(OLED_SPOT_RIGHT);
      break;
  }
#else
  //clear all
  analogWrite(FIXATION_LIGHT_UP,0);
  analogWrite(FIXATION_LIGHT_DOWN,0);
  analogWrite(FIXATION_LIGHT_LEFT,0);
  analogWrite(FIXATION_LIGHT_RIGHT,0);
  analogWrite(FIXATION_LIGHT_CENTER,0);

  switch (fixationLight)
    case 0:
      break;
    case 1:
      analogWrite(FIXATION_LIGHT_CENTER,intensity);
      break;
    case 2:
      analogWrite(FIXATION_LIGHT_UP,intensity);
      break;    
    case 3:
      analogWrite(FIXATION_LIGHT_DOWN,intensity);
      break; 
    case 4:
      analogWrite(FIXATION_LIGHT_LEFT,intensity);
      break; 
    case 5:
      analogWrite(FIXATION_LIGHT_RIGHT,intensity);
      break;    
#endif


}

void setOLEDCoordinates(byte x, byte y)
{
#ifdef USE_OLED_DISPLAY
  displayXCoordinate = x;
  displayYCoordinate = y;
  currentFixationLight = 99;
  //refreshDisplay();
#endif
}

void setLights(byte whiteIntensity, byte redIntensity)
{
  if (whiteIntensity>0)
    digitalWrite(WHITE_LIGHT_ENABLE, HIGH);
  else
    digitalWrite(WHITE_LIGHT_ENABLE, LOW); 
   
  if (redIntensity>0)
    digitalWrite(RED_LIGHT_ENABLE, HIGH);
  else
    digitalWrite(RED_LIGHT_ENABLE, LOW); 
    
  analogWrite(WHITE_LIGHT_PWM, whiteIntensity);
  analogWrite(RED_LIGHT_PWM, redIntensity);
  
  currentWhiteIntensity = whiteIntensity;
  currentRedIntensity = redIntensity;
}

void doFlash()
{
  byte originalWhiteIntensity = currentWhiteIntensity;
  byte originalRedIntensity = currentRedIntensity;
  
  #ifndef USE_OLED_DISPLAY
    setFixation(0,0); //turn off fixation light
  #endif
  
  delay(flashDelay); //wait for app to trigger camera
  setLights(flashWhiteIntensity, flashRedIntensity); //turn on flash
  delay(flashDuration); //flash is on...wait for exposure to finish
  setLights(originalWhiteIntensity, originalRedIntensity); //switch back to focus light
  
  #ifndef USE_OLED_DISPLAY
    setFixation(currentFixationLight,currentFixationIntensity); //turn on fixation light
  #endif
}

void checkBatteryState() {
  static boolean batteryOK = true;  
  float batteryVoltage = analogRead(BATTERY) * 5.0 / 1024;

  //Serial.print("batt = "); Serial.println(batteryVoltage);
  
  if (batteryOK) 
    batteryOK = !(batteryVoltage<BATTERY_GREEN_TO_RED_THRESHOLD);  
  else 
    batteryOK = (batteryVoltage>BATTERY_RED_TO_GREEN_THRESHOLD);
    
  setBatteryIndicator(batteryOK);
}

void checkIfInactive(){ 
  if(millis()-lastBTLETimestamp>IDLE_POWEROFF)
      digitalWrite(KILL, HIGH);
}

void refreshDisplay() {
#ifdef USE_OLED_DISPLAY  

  if (currentFixationLight==0)
    Display.gfx_Cls();  
  else
    Display.gfx_CircleFilled(displayXCoordinate,displayYCoordinate,OLED_SPOT_RADIUS,OLED_SPOT_COLOR);
   
   //delay(50);  
#endif  
}

void flushBLE() {
  while (BLEMini_available())
    BLEMini_read(); //flush...  
}

void checkForNewData() {

  while (BLEMini_available()) {
    
    //handle partial packets
    if ((BLEMini_available()%3)!=0) {
      //this could mean the data is still being transmitted, or it could mean there's been a problem during transmission
      //if data is currently being transmitted, it should be finished after some delay
      delay(5);
    
      if ((BLEMini_available()%3)!=0) { //nope, still an issue with the data in the buffer, so flush
        flushBLE();
        return;
      }
    }
  
    
    // read out command and data
    byte cmd = BLEMini_read();
    byte param1 = BLEMini_read();
    byte param2 = BLEMini_read();    

    //params for battery voltage calculation
    int voltage; byte upperByte; byte lowerByte;
    
    //connection indicator/keepalive
    bleConnected = true;
    lastKeepaliveTimestamp = millis();
    
    //if the command is NOT "check battery" (which gets called periodically), reset the timestamp
    if (cmd!=0xFC)
      lastBTLETimestamp = millis(); 
      
    switch (cmd) {
      case 0x01: //set lights, param1=white, param2=red
        setLights(param1,param2);   
        break;
      case 0x02: //set lights w/ callback...necessary?
                
        break;
      case 0x03: //set flash intensities, param1=white, param2=red
        flashWhiteIntensity = param1;
        flashRedIntensity = param2;      
        break;
      case 0x07: //set flash delay
        flashDelay = ((unsigned int)param1 << 8) | param2;
        break;
      case 0x08: //set flash duration
        flashDuration = ((unsigned int)param1 << 8) | param2;  
        break;    
      case 0x04: //do flash, param1=duration
        doFlash();       
        break;
      case 0x05: //right fixation
        setFixation(param1,param2);      
        break;
      case 0x06: //set arbitrary OLED coordinates
        setOLEDCoordinates(param1,param2);      
        break;
      case 0x0B: //white light with callback (why not roll this in above?)
        if (param1 == 0x01){
          digitalWrite(WHITE_LIGHT_ENABLE, HIGH);
          analogWrite(WHITE_LIGHT_PWM, param2);
          BLEMini_write(0xFF);
          BLEMini_write(0xFF);
          BLEMini_write(0xFF);
        }
        else if(param1 == 0x00){
          digitalWrite(WHITE_LIGHT_ENABLE,LOW);
          analogWrite(WHITE_LIGHT_PWM,0);
        }
        break;
      case 0xFC: //return battery voltage (functions as de-facto keepalive signal for bluetooth LED)
        voltage = analogRead(BATTERY);
        upperByte = (voltage & 0xFF00) >> 8;
        lowerByte = (voltage & 0x00FF);
        BLEMini_write(0xFC);
        BLEMini_write(upperByte);
        BLEMini_write(lowerByte);      
        break;
      case 0xFD: //check display connection
        checkIfDisplayAttached(false);
        break;
      case 0xFE: //reset - when does this get used?
        digitalWrite(KILL, LOW);
        digitalWrite(BLE_RESET, LOW);
        digitalWrite(BLUE_LED, HIGH);
        digitalWrite(GREEN_LED, HIGH);
        digitalWrite(RED_LED, HIGH);
        digitalWrite(RED_LIGHT_ENABLE, LOW);
        digitalWrite(WHITE_LIGHT_ENABLE, LOW);
            
        analogWrite(RED_LIGHT_PWM, 0);
        analogWrite(WHITE_LIGHT_PWM, 0);
        
        #ifdef USE_OLED_DISPLAY
          Display.gfx_Cls();
        #else
          digitalWrite(FIXATION_LIGHT_UP, LOW);
          digitalWrite(FIXATION_LIGHT_DOWN, LOW);
          digitalWrite(FIXATION_LIGHT_LEFT, LOW);
          digitalWrite(FIXATION_LIGHT_RIGHT, LOW);
          digitalWrite(FIXATION_LIGHT_CENTER, LOW); 
        #endif    
        break;
      case 0xFF:
        selfTest();
        break;   
      default: //invalid opcode, possibly a frame shift error, so flush the buffer
        flushBLE();
    }   
    
    delay(50); //before processing next command
  }     
   
}

#define NONE 0
#define LEFT 1
#define RIGHT 2
void checkIfDisplayAttached(boolean sendResultOnlyOnChange)
{
  
  static unsigned char display_attached = -1;
  unsigned char display_attached_new;
  
  if (digitalRead(OLED_LEFT_DETECT)==0)
    display_attached_new = LEFT;
  else if (digitalRead(OLED_RIGHT_DETECT)==0)
    display_attached_new = RIGHT;
  else
    display_attached_new = NONE;
    
   //if there was a change, or if this was a request for state, send the display state
   if ((display_attached_new!=display_attached) || !sendResultOnlyOnChange) {
    BLEMini_write(0xFD);
    BLEMini_write(0xFD);
    BLEMini_write(display_attached_new);
   }
   
  //if they just inserted the display, introduce a 3s delay to allow the display to startup
  if (display_attached_new!=NONE && display_attached==NONE) {
    delay(3000);
  }
  

    
  display_attached = display_attached_new;
}

void loop()
{
  //delay(50); 
  
  //changing the way we update the display
  /*
   #ifdef USE_OLED_DISPLAY
    if (millis()<7000)
      splashScreen();   
    else
      refreshDisplay();
  #endif
  
  */
  
  checkForNewData();   
  
  if ((millis() - lastLowPriorityIterationTimestamp) > LOW_PRIORITY_COMMAND_INTERVAL) {
    checkBTLEState();
    checkBatteryState();
    checkIfInactive();
    checkIfDisplayAttached(true); 
    refreshDisplay(); //it's important to continue refreshing the display because (annoyingly) it will start scrolling if we dont
    
    lastLowPriorityIterationTimestamp = millis();
  }
    
}
