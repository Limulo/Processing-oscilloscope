const int N = 1; // # sensor to read from

boolean bSendToPlotter;
byte addr;

// SETUP //////////////////////////////////
void setup() {
  Serial.begin( 9600 );
  bSendToPlotter = false;
}

// DRAW ///////////////////////////////////
void loop() {

  if( bSendToPlotter )
  {

    int i;
    for( i=0; i<N; i++ )
    {
      int value = analogRead( i );
  
      byte lower = value & 0x7F;
      addr = i & 0x0F; // 0000 1111
      byte upper = (value >> 7) | (addr << 3) | 0x80;
  
      Serial.write( upper );
      Serial.write( lower ); 
    }
  }
  
  delay( 5 );  
}

// SERIAL EVENT ///////////////////////////
void serialEvent()
{
  byte b = Serial.read();
  if (b == 'o' || b == 'O')
    bSendToPlotter = true;
  else if (b == 'c' || b == 'C')
    bSendToPlotter = false;
  //else if (b == 'r')
    // do something like a reset
}
