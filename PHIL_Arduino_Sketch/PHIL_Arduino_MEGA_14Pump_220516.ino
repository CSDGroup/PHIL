
#include <AccelStepper.h>
#include <MultiStepper.h>

int myMICROS = 1;
char Sttngs[][3] = {
  {LOW,  LOW, LOW}, // Full step
  {HIGH,  LOW, LOW}, // Half step
  {LOW, HIGH,  LOW}, // 1/4 step
  {HIGH,  HIGH,  LOW}, // 1/8 step
  {LOW, LOW, HIGH}, // 1/16 step
  {HIGH,  HIGH,  HIGH}
};

int MICROoptions[] = {1, 2, 4, 8, 16, 32};

//Stepper  L R Z1 Z2 V P1 P2 P3 P4 P5  P6  P7  P8  P9
int enaPINS[] = {69,  64,  61,  58,  44,  41,  38,  35,  32,  29,  26,  11,  8, 5};
int dirPINS[] = {67,  66,  63,  60,  46,  43,  40,  37,  34,  31,  28,  25,  10,  7};
int stpPINS[] = {68,  65,  62,  59,  45,  42,  39,  36,  33,  30,  27,  12,  9, 6};
int M1[] = {51,  51,  55,  55,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24};
int M2[] = {52,  52,  56,  56,  23,  23,  23,  23,  23,  23,  23,  23,  23,  23};
int M3[] = {53,  53,  57,  57,  22,  22,  22,  22,  22,  22,  22,  22,  22,  22};
int limPins[] = {50,  49,  48,  47};

AccelStepper stepperL(1, stpPINS[0], dirPINS[0]);
AccelStepper stepperR(1, stpPINS[1], dirPINS[1]);
AccelStepper stepperZ1(1, stpPINS[2], dirPINS[2]);
AccelStepper stepperZ2(1, stpPINS[3], dirPINS[3]);
AccelStepper stepperV(1, stpPINS[4], dirPINS[4]);
AccelStepper stepper1(1, stpPINS[5], dirPINS[5]);
AccelStepper stepper2(1, stpPINS[6], dirPINS[6]);
AccelStepper stepper3(1, stpPINS[7], dirPINS[7]);
AccelStepper stepper4(1, stpPINS[8], dirPINS[8]);
AccelStepper stepper5(1, stpPINS[9], dirPINS[9]);
AccelStepper stepper6(1, stpPINS[10], dirPINS[10]);
AccelStepper stepper7(1, stpPINS[11], dirPINS[11]);
AccelStepper stepper8(1, stpPINS[12], dirPINS[12]);
AccelStepper stepper9(1, stpPINS[13], dirPINS[13]);

int limitSwitchL = limPins[0]; // Target Limit Switch L
int limitSwitchR = limPins[1]; // Target Limit Switch R
int limitSwitchZ1 = limPins[2]; // Target Limit Switch Z
int limitSwitchZ2 = limPins[3]; // Target Limit Switch Z

String readString; //main captured String
String Comm;
String Lstr;
String Rstr;
String Z1str;
String Z2str;
String Vstr;
String str1;
String str2;
String str3;
String str4;
String str5;
String str6;
String str7;
String str8;
String str9;

long Lint;
long Rint;
long Z1int;
long Z2int;
long Vint;
long int1;
long int2;
long int3;
long int4;
long int5;
long int6;
long int7;
long int8;
long int9;

int ind0;
int indL;
int indR;
int indZ1;
int indZ2;
int indV;
int ind1;
int ind2;
int ind3;
int ind4;
int ind5;
int ind6;
int ind7;
int ind8;
int ind9;

int MAXspd = 6400;
int MAXaccl = 6400;

void setup() {
  // put your setup code here, to run once:
  pinMode(limitSwitchL, INPUT_PULLUP);
  //digitalWrite(limitSwitchL, HIGH);
  pinMode(limitSwitchR, INPUT_PULLUP);
  //digitalWrite(limitSwitchR, HIGH);
  pinMode(limitSwitchZ1, INPUT_PULLUP);
  //digitalWrite(limitSwitchZ1, HIGH);
  pinMode(limitSwitchZ2, INPUT_PULLUP);
  //digitalWrite(limitSwitchZ2, HIGH);

  stepperL.setMaxSpeed(MAXspd * myMICROS);
  stepperR.setMaxSpeed(MAXspd * myMICROS);
  stepperZ1.setMaxSpeed(MAXspd * myMICROS);
  stepperZ2.setMaxSpeed(MAXspd * myMICROS);
  stepperV.setMaxSpeed(MAXspd * myMICROS);
  stepper1.setMaxSpeed(MAXspd * myMICROS);
  stepper2.setMaxSpeed(MAXspd * myMICROS);
  stepper3.setMaxSpeed(MAXspd * myMICROS);
  stepper4.setMaxSpeed(MAXspd * myMICROS);
  stepper5.setMaxSpeed(MAXspd * myMICROS);
  stepper6.setMaxSpeed(MAXspd * myMICROS);
  stepper7.setMaxSpeed(MAXspd * myMICROS);
  stepper8.setMaxSpeed(MAXspd * myMICROS);
  stepper9.setMaxSpeed(MAXspd * myMICROS);
  stepperL.setAcceleration(MAXaccl * myMICROS);
  stepperR.setAcceleration(MAXaccl * myMICROS);
  stepperZ1.setAcceleration(MAXaccl * myMICROS);
  stepperZ2.setAcceleration(MAXaccl * myMICROS);
  stepperV.setAcceleration(MAXaccl * myMICROS);
  stepper1.setAcceleration(MAXaccl * myMICROS);
  stepper2.setAcceleration(MAXaccl * myMICROS);
  stepper3.setAcceleration(MAXaccl * myMICROS);
  stepper4.setAcceleration(MAXaccl * myMICROS);
  stepper5.setAcceleration(MAXaccl * myMICROS);
  stepper6.setAcceleration(MAXaccl * myMICROS);
  stepper7.setAcceleration(MAXaccl * myMICROS);
  stepper8.setAcceleration(MAXaccl * myMICROS);
  stepper9.setAcceleration(MAXaccl * myMICROS);

  for (int i = 0; i <= 13; i++) {
    pinMode(enaPINS[i], OUTPUT);
    digitalWrite(enaPINS[i], HIGH);
    pinMode(dirPINS[i], OUTPUT);
    pinMode(stpPINS[i], OUTPUT);
    pinMode(M1[i], OUTPUT);
    digitalWrite(M1[i], HIGH);
    pinMode(M2[i], OUTPUT);
    digitalWrite(M2[i], HIGH);
    pinMode(M3[i], OUTPUT);
    digitalWrite(M3[i], HIGH);
  }
  Serial.begin(9600);
  Serial.println("E+0+0+0+0+0+0+0+0+0+0+0+0+0+0*"); // so I can keep track of what is loaded
}

void MOVE(long Lint, long Rint, long Z1int, long Z2int, long Vint, long int1, long int2, long int3, long int4, long int5, long int6, long int7, long int8, long int9) {
  Serial.println("Here0");
  stepperL.setCurrentPosition(0);
  stepperR.setCurrentPosition(0);
  stepperZ1.setCurrentPosition(0);
  stepperZ2.setCurrentPosition(0);
  stepperV.setCurrentPosition(0);
  stepper1.setCurrentPosition(0);
  stepper2.setCurrentPosition(0);
  stepper3.setCurrentPosition(0);
  stepper4.setCurrentPosition(0);
  stepper5.setCurrentPosition(0);
  stepper6.setCurrentPosition(0);
  stepper7.setCurrentPosition(0);
  stepper8.setCurrentPosition(0);
  stepper9.setCurrentPosition(0);
  MultiStepper steppers;
  int count = 0;
  if (Lint != 0) {
    steppers.addStepper(stepperL);
    count = count + 1;
  }
  if (Rint != 0) {
    steppers.addStepper(stepperR);
    count = count + 1;
  }
  if (Z1int != 0) {
    steppers.addStepper(stepperZ1);
    count = count + 1;
  }
  if (Z2int != 0) {
    steppers.addStepper(stepperZ2);
    count = count + 1;
  }
  if (Vint != 0) {
    steppers.addStepper(stepperV);
    count = count + 1;
  }
  if (int1 != 0) {
    steppers.addStepper(stepper1);
    count = count + 1;
  }
  if (int2 != 0) {
    steppers.addStepper(stepper2);
    count = count + 1;
  }
  if (int3 != 0) {
    steppers.addStepper(stepper3);
    count = count + 1;
  }
  if (int4 != 0) {
    steppers.addStepper(stepper4);
    count = count + 1;
  }
  if (int5 != 0) {
    steppers.addStepper(stepper5);
    count = count + 1;
  }
  if (int6 != 0) {
    steppers.addStepper(stepper6);
    count = count + 1;
  }
  if (int7 != 0) {
    steppers.addStepper(stepper7);
    count = count + 1;
  }
  if (int8 != 0) {
    steppers.addStepper(stepper8);
    count = count + 1;
  }
  if (int9 != 0) {
    steppers.addStepper(stepper9);
    count = count + 1;
  }
  long positions[count]; // Array of desired stepper positions
  count = 0;
  if (Lint != 0) {
    positions[count] = Lint;
    count = count + 1;
  }
  if (Rint != 0) {
    positions[count] = Rint;
    count = count + 1;
  }
  if (Z1int != 0) {
    positions[count] = Z1int;
    count = count + 1;
  }
  if (Z2int != 0) {
    positions[count] = Z2int;
    count = count + 1;
  }
  if (Vint != 0) {
    positions[count] = Vint;
    count = count + 1;
  }
  if (int1 != 0) {
    positions[count] = int1;
    count = count + 1;
  }
  if (int2 != 0) {
    positions[count] = int2;
    count = count + 1;
  }
  if (int3 != 0) {
    positions[count] = int3;
    count = count + 1;
  }
  if (int4 != 0) {
    positions[count] = int4;
    count = count + 1;
  }
  if (int5 != 0) {
    positions[count] = int5;
    count = count + 1;
  }
  if (int6 != 0) {
    positions[count] = int6;
    count = count + 1;
  }
  if (int7 != 0) {
    positions[count] = int7;
    count = count + 1;
  }
  if (int8 != 0) {
    positions[count] = int8;
    count = count + 1;
  }
  if (int9 != 0) {
    positions[count] = int9;
    count = count + 1;
  }
  steppers.moveTo(positions);
  steppers.runSpeedToPosition();
  Serial.println("MDONE");
}

void ENABLE(long Lint, long Rint, long Z1int, long Z2int, long Vint, long int1, long int2, long int3, long int4, long int5, long int6, long int7, long int8, long int9) {
  int nbls[] = {Lint, Rint, Z1int, Z2int, Vint, int1, int2, int3, int4, int5, int6, int7, int8, int9};
  for (int i = 0; i <= 13; i++) {
    if (nbls[i] != 0) {
      digitalWrite(enaPINS[i], LOW);
      Serial.println("LOW");
    }
    else {
      digitalWrite(enaPINS[i], HIGH);
      Serial.println("HIGH");
    }
  }
  Serial.println("EDONE");
}

void SPEED(long Lint, long Rint, long Z1int, long Z2int, long Vint, long int1, long int2, long int3, long int4, long int5, long int6, long int7, long int8, long int9) {
  stepperL.setMaxSpeed(Lint);
  stepperR.setMaxSpeed(Rint);
  stepperZ1.setMaxSpeed(Z1int);
  stepperZ2.setMaxSpeed(Z2int);
  stepperV.setMaxSpeed(Vint);
  stepper1.setMaxSpeed(int1);
  stepper2.setMaxSpeed(int2);
  stepper3.setMaxSpeed(int3);
  stepper4.setMaxSpeed(int4);
  stepper5.setMaxSpeed(int5);
  stepper6.setMaxSpeed(int6);
  stepper7.setMaxSpeed(int7);
  stepper8.setMaxSpeed(int8);
  stepper9.setMaxSpeed(int9);
}

void ACCELERATION(long Lint, long Rint, long Z1int, long Z2int, long Vint, long int1, long int2, long int3, long int4, long int5, long int6, long int7, long int8, long int9) {
  stepperL.setAcceleration(Lint);
  stepperR.setAcceleration(Rint);
  stepperZ1.setAcceleration(Z1int);
  stepperZ2.setAcceleration(Z2int);
  stepperV.setAcceleration(Vint);
  stepper1.setAcceleration(int1);
  stepper2.setAcceleration(int2);
  stepper3.setAcceleration(int3);
  stepper4.setAcceleration(int4);
  stepper5.setAcceleration(int5);
  stepper6.setAcceleration(int6);
  stepper7.setAcceleration(int7);
  stepper8.setAcceleration(int8);
  stepper9.setAcceleration(int9);
}

void HOME(long Lint, long Rint, long Z1int, long Z2int, long Vint, long int1, long int2, long int3, long int4, long int5, long int6, long int7, long int8, long int9) {
    stepperL.setMaxSpeed(MAXspd * myMICROS);
  stepperR.setMaxSpeed(MAXspd * myMICROS);
  stepperZ1.setMaxSpeed(MAXspd * myMICROS);
  stepperZ2.setMaxSpeed(MAXspd * myMICROS);

  stepperL.setAcceleration(MAXaccl * myMICROS);
  stepperR.setAcceleration(MAXaccl * myMICROS);
  stepperZ1.setAcceleration(MAXaccl * myMICROS);
  stepperZ2.setAcceleration(MAXaccl * myMICROS);
  
  stepperL.setCurrentPosition(0);
  stepperR.setCurrentPosition(0);
  stepperZ1.setCurrentPosition(0);
  stepperZ2.setCurrentPosition(0);
  
  stepperL.moveTo(Lint);
  stepperR.moveTo(Rint);
  stepperZ1.moveTo(Z1int);
  stepperZ2.moveTo(Z2int);
  Serial.println("Here0");

  if (Lint != 0) {
    while (stepperL.distanceToGo() != 0 && digitalRead(limitSwitchL) == HIGH) {
      stepperL.run();
      Serial.println("Here1");
    }
  }

  Serial.println("Here2");

  if (Rint != 0) {
    while (stepperR.distanceToGo() != 0 && digitalRead(limitSwitchR) == HIGH) {
      stepperR.run();
      Serial.println("Here3");
    }
  }

  Serial.println("Here4");

  if (Z1int != 0 && Z2int != 0) {
    while (stepperZ1.distanceToGo() != 0 || stepperZ2.distanceToGo() != 0) {
      if (digitalRead(limitSwitchZ1) == HIGH && stepperZ1.distanceToGo() != 0) {
        stepperZ1.run();
        Serial.println("Here5");
      } else {
        stepperZ1.setCurrentPosition(0);
        stepperZ1.moveTo(0);
      }
      if (digitalRead(limitSwitchZ2) == HIGH && stepperZ2.distanceToGo() != 0) {
        stepperZ2.run();
        Serial.println("Here6");
      } else {
        stepperZ2.setCurrentPosition(0);
        stepperZ2.moveTo(0);
      }
    }
  }

  Serial.println("Here7");
}

void MICROSTEP(long Lint, long Rint, long Z1int, long Z2int, long Vint, long int1, long int2, long int3, long int4, long int5, long int6, long int7, long int8, long int9) {
  //  char Sttngs[][3] = {
  //    {LOW,  LOW, LOW}, // Full step
  //    {HIGH,  LOW, LOW}, // Half step
  //    {LOW, HIGH,  LOW}, // 1/4 step
  //    {HIGH,  HIGH,  LOW}, // 1/8 step
  //    {LOW, LOW, HIGH}, // 1/16 step
  //    {HIGH,  HIGH,  HIGH} }; // 1/32 step
  //int M1[] = {51,  51,  55,  55,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24};
  //int M2[] = {52,  52,  56,  56,  23,  23,  23,  23,  23,  23,  23,  23,  23,  23};
  //int M3[] = {53,  53,  57,  57,  22,  22,  22,  22,  22,  22,  22,  22,  22,  22};


  //  myMICROS = MICROoptions[Lint];
  Serial.println("MHERE1");
  digitalWrite(M1[0], Sttngs[Lint][0]);
  digitalWrite(M2[0], Sttngs[Lint][1]);
  digitalWrite(M3[0], Sttngs[Lint][2]);

  digitalWrite(M1[1], Sttngs[Rint][0]);
  digitalWrite(M2[1], Sttngs[Rint][1]);
  digitalWrite(M3[1], Sttngs[Rint][2]);

  digitalWrite(M1[2], Sttngs[Z1int][0]);
  digitalWrite(M2[2], Sttngs[Z1int][1]);
  digitalWrite(M3[2], Sttngs[Z1int][2]);

  digitalWrite(M1[3], Sttngs[Z2int][0]);
  digitalWrite(M2[3], Sttngs[Z2int][1]);
  digitalWrite(M3[3], Sttngs[Z2int][2]);

  digitalWrite(M1[4], Sttngs[Vint][0]);
  digitalWrite(M2[4], Sttngs[Vint][1]);
  digitalWrite(M3[4], Sttngs[Vint][2]);

  digitalWrite(M1[5], Sttngs[int1][0]);
  digitalWrite(M2[5], Sttngs[int1][1]);
  digitalWrite(M3[5], Sttngs[int1][2]);

  digitalWrite(M1[6], Sttngs[int2][0]);
  digitalWrite(M2[6], Sttngs[int2][1]);
  digitalWrite(M3[6], Sttngs[int2][2]);

  digitalWrite(M1[7], Sttngs[int3][0]);
  digitalWrite(M2[7], Sttngs[int3][1]);
  digitalWrite(M3[7], Sttngs[int3][2]);

  digitalWrite(M1[8], Sttngs[int4][0]);
  digitalWrite(M2[8], Sttngs[int4][1]);
  digitalWrite(M3[8], Sttngs[int4][2]);

  digitalWrite(M1[9], Sttngs[int5][0]);
  digitalWrite(M2[9], Sttngs[int5][1]);
  digitalWrite(M3[9], Sttngs[int5][2]);

  digitalWrite(M1[10], Sttngs[int6][0]);
  digitalWrite(M2[10], Sttngs[int6][1]);
  digitalWrite(M3[10], Sttngs[int6][2]);

  digitalWrite(M1[11], Sttngs[int7][0]);
  digitalWrite(M2[11], Sttngs[int7][1]);
  digitalWrite(M3[11], Sttngs[int7][2]);

  digitalWrite(M1[12], Sttngs[int8][0]);
  digitalWrite(M2[12], Sttngs[int8][1]);
  digitalWrite(M3[12], Sttngs[int8][2]);

  digitalWrite(M1[13], Sttngs[int9][0]);
  digitalWrite(M2[13], Sttngs[int9][1]);
  digitalWrite(M3[13], Sttngs[int9][2]);
  Serial.println("MHERE2");
}

void loop() {
  if (Serial.available())  {
    char c = Serial.read();  //gets one byte from serial buffer
    delay(1);
    if (c == '*') {
      Serial.println();
      Serial.print("Captured String is : ");
      Serial.println(readString); //prints string to serial port out
      ind0 = readString.indexOf('+');  //finds location of first ,
      Comm = readString.substring(ind0-1, ind0);   //captures first data String
      Serial.print("Command Type : ");
      Serial.println(Comm); //prints string to serial port out
      indL = readString.indexOf('+', ind0 + 1 ); //finds location of second ,
      Lstr = readString.substring(ind0 + 1, indL); //captures second data String
      Serial.print("X : ");
      Serial.println(Lstr); //prints string to serial port out
      indR = readString.indexOf('+', indL + 1 );
      Rstr = readString.substring(indL + 1, indR);
      Serial.print("Y : ");
      Serial.println(Rstr); //prints string to serial port out
      indZ1 = readString.indexOf('+', indR + 1 );
      Z1str = readString.substring(indR + 1, indZ1);
      Serial.print("Z1 : ");
      Serial.println(Z1str); //prints string to serial port out
      indZ2 = readString.indexOf('+', indZ1 + 1 );
      Z2str = readString.substring(indZ1 + 1, indZ2);
      Serial.print("Z2 : ");
      Serial.println(Z2str); //prints string to serial port out
      indV = readString.indexOf('+', indZ2 + 1 );
      Vstr = readString.substring(indZ2 + 1, indV);
      Serial.print("V : ");
      Serial.println(Vstr); //prints string to serial port out
      ind1 = readString.indexOf('+', indV + 1 );
      str1 = readString.substring(indV + 1, ind1);
      Serial.print("1 : ");
      Serial.println(str1); //prints string to serial port out
      ind2 = readString.indexOf('+', ind1 + 1 );
      str2 = readString.substring(ind1 + 1, ind2);
      Serial.print("2 : ");
      Serial.println(str2); //prints string to serial port out
      ind3 = readString.indexOf('+', ind2 + 1 );
      str3 = readString.substring(ind2 + 1, ind3);
      Serial.print("3 : ");
      Serial.println(str3); //prints string to serial port out
      ind4 = readString.indexOf('+', ind3 + 1 );
      str4 = readString.substring(ind3 + 1, ind4);
      Serial.print("4 : ");
      Serial.println(str4); //prints string to serial port out
      ind5 = readString.indexOf('+', ind4 + 1 );
      str5 = readString.substring(ind4 + 1, ind5);
      Serial.print("5 : ");
      Serial.println(str5); //prints string to serial port out
      ind6 = readString.indexOf('+', ind5 + 1 );
      str6 = readString.substring(ind5 + 1, ind6);
      Serial.print("6 : ");
      Serial.println(str6); //prints string to serial port out
      ind7 = readString.indexOf('+', ind6 + 1 );
      str7 = readString.substring(ind6 + 1, ind7);
      Serial.print("7 : ");
      Serial.println(str7); //prints string to serial port out
      ind8 = readString.indexOf('+', ind7 + 1 );
      str8 = readString.substring(ind7 + 1, ind8);
      Serial.print("8 : ");
      Serial.println(str8); //prints string to serial port out
      ind9 = readString.indexOf('+', ind8 + 1 );
      str9 = readString.substring(ind8 + 1, ind9);
      Serial.print("9 : ");
      Serial.println(str9); //prints string to serial port out

      Lint = Lstr.toInt();
      Rint = Rstr.toInt();
      Z1int = Z1str.toInt();
      Z2int = Z2str.toInt();
      Vint = Vstr.toInt();
      int1 = str1.toInt();
      int2 = str2.toInt();
      int3 = str3.toInt();
      int4 = str4.toInt();
      int5 = str5.toInt();
      int6 = str6.toInt();
      int7 = str7.toInt();
      int8 = str8.toInt();
      int9 = str9.toInt();

      Serial.print("Comm is:");
      Serial.print(Comm);
      if (Comm[0] == 'G') {
        Serial.println("Move");
        MOVE(Lint, Rint, Z1int, Z2int, Vint, int1, int2, int3, int4, int5, int6, int7, int8, int9);
      };
      if (Comm[0] == 'E') {
        Serial.println("Enable");
        ENABLE(Lint, Rint, Z1int, Z2int, Vint, int1, int2, int3, int4, int5, int6, int7, int8, int9);
      };
      Serial.println("HereS");
      if (Comm[0] == 'S') {
        Serial.println("Speed");
        SPEED(Lint, Rint, Z1int, Z2int, Vint, int1, int2, int3, int4, int5, int6, int7, int8, int9);
      };
      if (Comm[0] == 'A') {
        Serial.println("Acceleration");
        ACCELERATION(Lint, Rint, Z1int, Z2int, Vint, int1, int2, int3, int4, int5, int6, int7, int8, int9);
      };
      if (Comm[0] == 'H') {
        Serial.println("Home");
        HOME(Lint, Rint, Z1int, Z2int, Vint, int1, int2, int3, int4, int5, int6, int7, int8, int9);
      };
      if (Comm[0] == 'M') {
        Serial.println("Microstep");
        MICROSTEP(Lint, Rint, Z1int, Z2int, Vint, int1, int2, int3, int4, int5, int6, int7, int8, int9);
      };
      readString = "";
      Serial.println("*");

    }
    else {
      readString += c; //makes the string readString
    }
  }
}
