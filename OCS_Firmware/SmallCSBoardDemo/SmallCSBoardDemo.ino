
#include <ble_mini.h>

//power
#define BATTERY A11 //battery voltage = A11/1024*5.0V
#define KILL 7 //lower this line to turn board off
#define BLE_RESET A2 //lower this line to reset BLE Mini

//indicators
#define BLUE_IND A3 //Blue LED on board, active low
#define RED_IND A4 //Red LED on board, active low
#define GREEN_IND A5 //Green LED on board, active low

//LED drivers
#define LED1_EN A1 //Buck/boost driver 1 enable
#define LED1_PWM 11 //Buck/boost current (0-20 ~ 0-500mA)
#define LED2_EN A0 //Buck/boost driver 2 enable
#define LED2_PWM 13 //Buck/boost current (0-20 ~ 0-500mA)

//peripheral ports
#define P1_PIN2 5 //DIO/PWM
#define P2_PIN2 8 //DIO/PWM/A7
#define P1P2_PIN3 9 //PWM/A10
#define P1P2_PIN4 10 //PWM/A11
#define P3_PIN3 2 //DIO/SDA
#define P3_PIN4 3 //DIO/PWM/SCL
#define PERIPHERAL_5V_EN 4  //switches 5V power on/off to peripherals

//settings
#define BATTERY_GREEN_TO_RED_THRESHOLD 3.3
#define BATTERY_RED_TO_GREEN_THRESHOLD 3.5
#define IDLE_POWEROFF 300000 //5 minutes before auto shutDown
#define BTLE_KEEPALIVE_TIMEOUT 5000 //5 seconds before bluetooth LED turns off due to lack of communication from phone
#define LOW_PRIORITY_COMMAND_INTERVAL 100 //"low priority" commands get executed every 1s


unsigned long lastBTLETimestamp;
unsigned long lastKeepaliveTimestamp;
unsigned long lastLowPriorityIterationTimestamp;
boolean bleConnected = false;

void setBatteryIndicator(boolean batteryOK);
void setPeripheralPower(boolean enabled);
void setLights(byte led1, byte led2);

void setup()
{ 
  pinMode(KILL, OUTPUT);
  pinMode(BLUE_IND, OUTPUT);
  pinMode(GREEN_IND, OUTPUT);
  pinMode(RED_IND, OUTPUT);
  pinMode(LED1_EN, OUTPUT);
  pinMode(LED1_PWM, OUTPUT);
  pinMode(LED2_EN, OUTPUT);
  pinMode(LED2_PWM, OUTPUT);
  pinMode(BLE_RESET, OUTPUT); 
  pinMode(BATTERY, INPUT);
  pinMode(PERIPHERAL_5V_EN, OUTPUT);

  BLEMini_begin(57600);

  //initial state of outputs
  digitalWrite(KILL, LOW);
  digitalWrite(BLE_RESET, LOW);
  digitalWrite(BLUE_IND, HIGH);
  digitalWrite(GREEN_IND, LOW);
  digitalWrite(RED_IND, HIGH);
  digitalWrite(PERIPHERAL_5V_EN, LOW);
  digitalWrite(LED1_EN, LOW);
  digitalWrite(LED2_EN, LOW);  
  analogWrite(LED1_PWM, 0);
  analogWrite(LED2_PWM, 0);

  lastBTLETimestamp = millis();
  lastKeepaliveTimestamp = millis();
  lastLowPriorityIterationTimestamp = millis();
  
  selfTest();
}

/*
 * Tests basic board functionality
 */
void selfTest()
{
    //TEST LED DRIVERS   
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
    
    //TEST PERIPHERAL POWER
    setPeripheralPower(true);
    delay(1000);
    setPeripheralPower(false);
    
    //TEST INDICATORS
    setBatteryIndicator(false);
    delay(1000);
    setBatteryIndicator(true);
    delay(1000);
    digitalWrite(BLUE_IND,LOW);
    delay(1000);
    digitalWrite(BLUE_IND,HIGH);
}

/*
 * This turns the blue indicator LED on if there is a BTLE connection, off if not.
 * It assumes that a command is received from the iPhone periodically. If a command
 * isn't recieved after BTLE_KEEPALIVE_TIMEOUT, the connection is assumed lost.
 * On the iPhone side, command 0xFE (check battery voltage) is sent periodically on a timer.
 */
void checkBTLEState() {
  
 if ((millis() - lastKeepaliveTimestamp) > BTLE_KEEPALIVE_TIMEOUT)
   bleConnected = false;
   
 if (bleConnected)
    digitalWrite(BLUE_IND, LOW);
 else
    digitalWrite(BLUE_IND, HIGH); 
}

/*
 * Turns on or off the 5V outputs on the peripheral ports
 */
void setPeripheralPower(boolean enabled) {
  if (enabled)
      digitalWrite(PERIPHERAL_5V_EN,HIGH);
  else
      digitalWrite(PERIPHERAL_5V_EN,LOW);  
}

/*
 * Sets the battery indicator LED to red or green, depending on battery state
 */
void setBatteryIndicator(boolean batteryOK) {
  if (batteryOK) {
    digitalWrite(RED_IND, HIGH);  
    digitalWrite(GREEN_IND, LOW);      
  }
  else {
    digitalWrite(RED_IND, LOW);  
    digitalWrite(GREEN_IND, HIGH);  
  }  
}

/*
 * Set current of LED drivers (0-20 is approx 0-500mA, although this needs to be verified)
 */
void setLights(byte led1, byte led2)
{
  if (led1>0)
    digitalWrite(LED1_EN, HIGH);
  else
    digitalWrite(LED1_EN, LOW); 
   
  if (led2>0)
    digitalWrite(LED2_EN, HIGH);
  else
    digitalWrite(LED2_EN, LOW); 
    
  analogWrite(LED1_PWM, led1);
  analogWrite(LED2_PWM, led2);
}

/*
 * Check if battery voltage has crossed a specified threshold
 * since the last time this function was run. The green-to-red and red-to-green 
 * thresholds are not the same, which provides a little hysteresis.
 */
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

/*
 * If we haven't receieved a BTLE command after some time, kill the board to save power
 */
void checkIfInactive(){ 
  if(millis()-lastBTLETimestamp>IDLE_POWEROFF)
      digitalWrite(KILL, HIGH);
}

/*
 * Flushes the input buffer. Used in case a packet is corrupted (e.g. not 3 bytes).
 */
void flushBLE() {
  while (BLEMini_available())
    BLEMini_read(); //flush...  
}

/*
 * Interpret each 3-byte BTLE command
 */
void checkForNewData() {
  
  while (BLEMini_available()) {
    
    //handle partial/corrupt packets
    if ((BLEMini_available()%3)!=0) {
      //this could mean the data is still being transmitted, or it could mean there's been a problem during transmission
      //if data is currently being transmitted, it should be finished after some delay
      delay(5);
    
      if ((BLEMini_available()%3)!=0) { //nope, still an issue with the data in the buffer, so flush
        flushBLE();
        return;
      }
    }
    
    // read out command and data (3-byte sequence)
    byte cmd = BLEMini_read();
    byte param1 = BLEMini_read();
    byte param2 = BLEMini_read();    

    //params for battery voltage calculation
    int voltage; byte upperByte; byte lowerByte;
    
    //connection indicator/keepalive
    bleConnected = true;
    lastKeepaliveTimestamp = millis();
    
    //if the command is NOT "check battery" (which gets called periodically as keepalive), reset the timestamp
    if (cmd!=0xFC)
      lastBTLETimestamp = millis(); 
      
    switch (cmd) {
      case 0x01: //set lights, param1=white, param2=red
        setLights(param1,param2);   
        break;
      case 0x02:
        //some other command...
        break;
      case 0x03:
        //some other command...
        break;        
      case 0xFC: //return battery voltage (functions as de-facto keepalive signal for bluetooth LED)
        voltage = analogRead(BATTERY);
        upperByte = (voltage & 0xFF00) >> 8;
        lowerByte = (voltage & 0x00FF);
        BLEMini_write(0xFC);
        BLEMini_write(upperByte);
        BLEMini_write(lowerByte);      
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

void loop()
{
  
  //constantly check for new BTLE commands
  checkForNewData();   
  
  //periodically run other functions on a specified interval
  if ((millis() - lastLowPriorityIterationTimestamp) > LOW_PRIORITY_COMMAND_INTERVAL) {
    checkBTLEState();
    checkBatteryState();
    checkIfInactive();

    lastLowPriorityIterationTimestamp = millis();
  }
    
}
