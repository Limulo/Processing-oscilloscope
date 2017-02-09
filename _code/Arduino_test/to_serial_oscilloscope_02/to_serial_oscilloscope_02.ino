boolean bSendToPlotter;

// SETUP //////////////////////////////////
void setup() {
  Serial.begin( 9600 );
  bSendToPlotter = false;
}

// DRAW ///////////////////////////////////
void loop() {

  if( bSendToPlotter )
  {
    analogPlot( 0, 0 );
    analogPlot( 3, 1 );
  }
}

// ANALOG PLOT ////////////////////////////
void analogPlot( int _analogPinNumber, int _addr )
{
  int value = analogRead( _analogPinNumber );
  
  byte lower = value & 0x7F;
  byte addr = _addr & 0x0F; // 0000 1111
  byte upper = (value >> 7) | (addr << 3) | 0x80;
  
  Serial.write( upper );
  Serial.write( lower ); 
  delay( 1 ); 
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
