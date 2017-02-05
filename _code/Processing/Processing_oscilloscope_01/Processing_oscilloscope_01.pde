/*
* This sketch is a sort of an oscilloscope
* and  can be very useful if you need to plot 
* grafically values read from analog sensors 
* by an Arduino board
*/

import processing.serial.*;
Serial s_port;
boolean bSerialListen = false;

int N = 2;   // number of sensor to be plotted
int K = 512; // numbere of values to be stored
int values[][];
int times[][];

// TIMES
long lastTime;

// here we store the current position inside the 'values'
// array where to memorize the next value from the sensor
int current[];
int lastCurrent[];

int sensorAddr, upper, lower;

// graph margins
int topMargin    = 50;
int bottomMargin = 50;
int leftMargin   = 50;
int rightMargin  = 50;
float plotWidth, plotHeight, plotInterval;

boolean bScreenShotMode;


// SETUP ////////////////////////////////////////
void setup()
{
  size( 700, 512 );
  frameRate(30);
  smooth();
 
  //println(Serial.list());
  s_port = new Serial(this, Serial.list()[0], 9600);
  //s_port.buffer( 2 ); //wait till we have 2 byte inside the serial buffer to be read
  
  values = new int[N][K];
  times = new int[N][K];
  for(int i=0; i<N; i++)
  {
    for(int j=0; j<K; j++)
    {
      values[i][j] = 0;
      times[i][j] = 0;
    }
  }
  
  current = new int[N];
  for(int i=0; i<N; i++)
    current[i] = 0;
    
  lastCurrent = new int[N];
  for(int i=0; i<N; i++)
    lastCurrent[i] = 0;
    
  
  plotWidth  = width - leftMargin - rightMargin;
  plotHeight = height- topMargin - bottomMargin;
  plotInterval = plotWidth / K;
  sensorAddr = 0;
  upper = 0;
  lower = 0;
  
  
  bScreenShotMode = false;
  
  lastTime = millis();
}


// DRAW /////////////////////////////////////////
void draw()
{
  
  // background
  background(0);
  noStroke();
  fill(0, 0, 255);
  rect( leftMargin, topMargin, plotWidth, plotHeight ); 
  
  if( bSerialListen ) {
    
    pushMatrix();
    translate( leftMargin, topMargin );
    
    /* SHAPE */
    noFill();
    stroke(255);
    strokeWeight(3);
    beginShape();
    for(int i=0; i<K; i++)
    {
      // we draw the graph from right to left
      int graphIndex = K - i;
      
      // we read the 'values' array from right to left
      // beginning with the last value we have stored.
      // this way we have the most recent value we have read to the right.
      // NOTE: inside current[] now we have an index that is grater of 1 unit 
      // that the one where we placed the last reading from the sensor. 
      // This is why we are not usign the following formula 
      // int valuesIndex = (K-1) - ((K - 1 - current[sensorAddr] ) + i) % K; 
      int valuesIndex;
      if( bScreenShotMode )
      {
        valuesIndex = (K-1) - ((K - lastCurrent[sensorAddr] ) + i) % K; 
      }
      else
      {
        valuesIndex = (K-1) - ((K - current[sensorAddr] ) + i) % K; 
      }
      int h = values[sensorAddr][ valuesIndex ];
      h = (int) map(h, 0, 1023, 0, plotHeight);
      
      
      // draw time lines 
      for(int j=0; j<N; j++)
      {
        if( times[j][valuesIndex] == 1 )
        {
          pushStyle();
          stroke(255, 0, 0);
          strokeWeight(1);
          line(graphIndex*plotInterval, plotHeight, graphIndex*plotInterval, 0);
          popStyle();
        }
      }
      
      
      vertex(graphIndex*plotInterval, plotHeight-h);
    }
    endShape();
    
    popMatrix();
  }
  
}

// SERIAL EVENT /////////////////////////////////
void serialEvent(Serial s)
{
  int b = s.read();
  if (b >= 128 )
  {
    // a "status" byte
    sensorAddr = (b & 0x78) >> 3;  // 0111 1000
    upper = b & 0x07;    // 0000 0111  
    //print( sensorAddr + ": [" + upper + "]+");
  }
  else
  {
    // a "data" byte
    lower = b & 0x7F; // 0111 1111
    int value = (upper << 7) | lower ;
    //println("[" + lower + "] = " + value);
    
    if( !bScreenShotMode ) {
      // now that we have read the complete 10bit value
      // from the serial port we can write it inside the 
      // corresponding array.
      int index = current[sensorAddr];
      values[sensorAddr][ index ] = value;
      
      // TIME
      if(millis() - lastTime >= 1000)
      {
        for(int i=0; i<N; i++)
          times[i][index] = 1;
        lastTime = millis();
      }
      else
      {
        for(int i=0; i<N; i++)
          times[i][index] = 0;
      }
      
      // we update the index so to be ready to 
      // store the next incoming value from teh sensor
      current[sensorAddr] = ( ++index ) % K;
    }
  }
  
}


// KEYBOARD /////////////////////////////////////
void keyPressed()
{
  if (key == 'o' || key == 'O')
  {
    println("open");
    s_port.write('o');
    bSerialListen = true;
  }
  else if( key == 'c' || key == 'C')
  {
    println("close");
    s_port.write('c');
    bSerialListen = false;
  }
  else if (key == 'r' || key == 'R')
  {
    s_port.write('r');
    //bestDelta0 = 0;
    //bestDelta1 = 0;
  } 
  else if (key == ' ')
  {
    // screenshot mode: we have to stop the
    // screen to be refreshed with new values and
    // maintain the last visualization
    bScreenShotMode = !bScreenShotMode;
    if( bScreenShotMode )
    {
    for(int i=0; i<N; i++)
      lastCurrent[ i ] = current[ i ];
    }
  }
}

// MOUSE ////////////////////////////////////////

// OTHER ////////////////////////////////////////