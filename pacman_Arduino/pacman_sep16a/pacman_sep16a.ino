const int ghostUpButtonPin = 3;
const int ghostDownButtonPin = 2;
const int ghostLeftButtonPin = 4;
const int ghostRightButtonPin = 5;

const int pacmanUpButtonPin = 10;
const int pacmanDownButtonPin = 11;
const int pacmanLeftButtonPin = 12;
const int pacmanRightButtonPin = 13;

const int insertCoinButtonPin = 8;

void setup() {
  
  pinMode(ghostUpButtonPin, INPUT);
  pinMode(ghostDownButtonPin, INPUT);
  pinMode(ghostLeftButtonPin, INPUT);
  pinMode(ghostRightButtonPin, INPUT);
  
  pinMode(pacmanUpButtonPin, INPUT);
  pinMode(pacmanDownButtonPin, INPUT);
  pinMode(pacmanLeftButtonPin, INPUT);
  pinMode(pacmanRightButtonPin, INPUT);
  
  pinMode(insertCoinButtonPin, INPUT);
  
  Serial.begin(9600);
}


void loop() {
  
  int ghostUpButtonValue = digitalRead(ghostUpButtonPin);
  int ghostDownButtonValue = digitalRead(ghostDownButtonPin);
  int ghostLeftButtonValue = digitalRead(ghostLeftButtonPin);
  int ghostRightButtonValue = digitalRead(ghostRightButtonPin);
  
  int pacmanUpButtonValue = digitalRead(pacmanUpButtonPin);
  int pacmanDownButtonValue = digitalRead(pacmanDownButtonPin);
  int pacmanLeftButtonValue = digitalRead(pacmanLeftButtonPin);
  int pacmanRightButtonValue = digitalRead(pacmanRightButtonPin);
  
  int insertCoinButtonValue = digitalRead(insertCoinButtonPin);

  Serial.print(ghostUpButtonValue);
  Serial.print(",");
  Serial.print(ghostDownButtonValue);
  Serial.print(",");
  Serial.print(ghostLeftButtonValue);
  Serial.print(",");
  Serial.print(ghostRightButtonValue);
  Serial.print(",");
  Serial.print(pacmanUpButtonValue);
  Serial.print(",");
  Serial.print(pacmanDownButtonValue);
  Serial.print(",");
  Serial.print(pacmanLeftButtonValue);
  Serial.print(",");
  Serial.print(pacmanRightButtonValue);
  Serial.print(",");
  Serial.println(insertCoinButtonValue);

  delay(10);

}


