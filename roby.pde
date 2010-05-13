#include <Servo.h> 

#define AVANT 1
#define ARRIERE 0
#define GAUCHE 2
#define DROITE 3

#define SERVOG 1
#define SERVOD 0

#define UPDDG 3
#define UPDDD 4

#define LDRSEUIL 100
#define LDRG 1
#define LDRD 0

#define VMAX 5

Servo servog;
Servo servod;

int vLdr = 5;

int getNeutral(int s)
{
  if(s == SERVOG)
    return 86;
  else
    return 84;
}


void handleS(int s, int speed)
{
  //Vitesse : 
  // 0 -> 0; 1 -> 1; 2 -> 3; 3 -> 8; 4 -> 10; v => 5 -> 30
  int tab[6] = {0,1,3,8,10,30};
  int pos = getNeutral(s);
  
  int acc;
  if (speed < 0)
    acc = - tab[abs(speed)];
  else
    acc = tab[speed];
    
  if(s == SERVOG)
      servog.write(pos += acc);
  else
      servod.write(pos -= acc);
}


void move(int direction)
{
  int m1 = 0, m2 = 0;
  switch(direction)
  {
    case DROITE: m1 = 1; m2 = -1; break;
    case GAUCHE: m1 = -1; m2 = 1; break;
    case AVANT: m1 = 1; m2 = 1; break;
    case ARRIERE: m1 = -1; m2 = -1; break;
  }
  handleS(SERVOG, m1*VMAX);
  handleS(SERVOD, m2*VMAX);  
}  

void handleUPDD(int updd)
{
  if(digitalRead(updd) == HIGH)
  {
    move(ARRIERE);
    delay(500);
    
    if (updd == UPDDG)
    {
      move(DROITE);
    }
    else
    {
      move(GAUCHE);
    }
     delay(800);
  }
}


// Retourne une valeur entre 0 et 5 suivant les différences du luminosité.
int LDRMotor(int g, int d)
{
  
  float min = (float)min(g,d);
  float max = (float)max(g,d);


  float err = ((max-min)/min);
  int output = (int)((10. - err*10.)/2.);
  
  if (output >= 4) return 5;
  else if (output <= 1) return 0;
  else return output;
}
void LDR()
{
  int a = analogRead(LDRG);
  int b = analogRead(LDRD);
  
  //On regarde la différence de luminosité entre les deux cotés du robot.
  int LdrValue = LDRMotor(a,b);
  //On fait la moyenne de la nouvelle différence avec la valeur précédente pour éviter les accoups.
  int nV = (vLdr + LdrValue)/2;
  
  if(a < LDRSEUIL && b < LDRSEUIL)
  {
      move(ARRIERE);
      delay(800);
      if (a>b) 
        move(GAUCHE); 
      else 
        move(DROITE);
        
      delay(400);
  }
  else
  {
    if(a>b) // Si le capteur gauche est plus éclairé que le droit, on tourne à gauche
    {    
      handleS(SERVOG, nV);
      handleS(SERVOD, VMAX);
    }
    else // sinon on tourne a droite
    {
      handleS(SERVOG, VMAX);
      handleS(SERVOD, nV);
    }
  }
  
  // on met la nouvelle différence dans l'ancienne
  vLdr = nV;
}

void setup() 
{
  pinMode(UPDDG, INPUT);   
  pinMode(UPDDD, INPUT); 
  
  Serial.begin(9600);
  servog.attach(10);
  servod.attach(9);
  move(AVANT);
} 

void loop()
{
    int v = analogRead(0);
     Serial.println(v);
     handleUPDD(UPDDG);
     handleUPDD(UPDDD); 
     LDR();
    delay(100);
}
