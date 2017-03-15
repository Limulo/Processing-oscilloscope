/*
* This sketch is a sort of an oscilloscope
* and  can be very useful if you need to plot 
* grafically values read from analog sensors 
* by an Arduino board
*/

import processing.serial.*;
Serial s_port;
boolean bSerialListen;

// incoming serial data
int sensorAddr, upper, lower;

int N = 2;   // number of sensor to be plotted
int K = 512; // number of values to be stored
Graph graphs[];

// plotter and graph interface aspect elements
int topMargin    = 50;
int bottomMargin = 50;
int leftMargin   = 50;
int rightMargin  = 50;
float plotterWidth, plotterHeight;
float graphHeight;
int intergraphMargin = 10;

boolean bScreenShotMode;

PFont f;

// SETUP ////////////////////////////////////////
void setup()
{
  size( 700, 512 );
  frameRate(30);
  smooth();
  
  f = createFont("Courier", 14);
 
  //println(Serial.list());
  s_port = new Serial(this, Serial.list()[0], 9600);
  bSerialListen = false;
     
  plotterWidth  = width - leftMargin - rightMargin;
  plotterHeight = height- topMargin - bottomMargin;
  graphHeight = plotterHeight / N - intergraphMargin;
    
  graphs = new Graph[ N ];
  for( int i=0; i<N; i++ )
  {
    float x = leftMargin;
    float y = topMargin + (graphHeight + intergraphMargin)*i;
    graphs[i] = new Graph( x, y, plotterWidth, graphHeight, K);
  }
  
  sensorAddr = 0;
  upper = 0;
  lower = 0;
  bScreenShotMode = false;
  
}

// DRAW /////////////////////////////////////////
void draw()
{
  background(0);
  
  // display plotter area
  noStroke();
  fill(0, 0, 255);
  rect( leftMargin, topMargin, plotterWidth, plotterHeight ); 
  
  // display graps
  if( bSerialListen ) {
    for(int i=0; i<N; i++)
      graphs[i].display();
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
    if( sensorAddr < N )
    {
      // a "data" byte
      lower = b & 0x7F; // 0111 1111
      int value = (upper << 7) | lower ;
      //println("[" + lower + "] = " + value);
      
      if( !bScreenShotMode ) {
        // now that we have read the complete 10bit value
        // from the serial port we can write it inside the 
        // corresponding array.
        graphs[ sensorAddr ].insertNewReading( value );
      }                                    
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
  else if (key == ' ')
  {
    // screenshot mode: we have to stop the
    // screen to be refreshed with new values and
    // maintain the last visualization
    bScreenShotMode = !bScreenShotMode;
    if( bScreenShotMode )
    {
    for(int i=0; i<N; i++)
      graphs[i].screenshotMode();
      //lastCurrent[ i ] = current[ i ];
    }
  }
  else if (key == 's')
  {
    saveFrame("###-frame.png");
  }
}

// MOUSE ////////////////////////////////////////
void mouseMoved()
{
  for(int i=0; i<N; i++)
  {
    graphs[i].mouseInteraction( mouseX, mouseY );
  }
}