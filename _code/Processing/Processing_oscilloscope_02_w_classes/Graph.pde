class Graph
{
  int K; //# of values to store
  int values[];
  int times[];
  
  int currentIndex, lastIndex;
  
  // interface aspect
  float x, y, w, h, stepWidth;
  
  // TIMES
  long lastTime;
  
  int mouseCoordsX, mouseCoordsY;
  boolean bInside;
  
  // CONSTRUCTOR ///////////////////////////////////////////////////////////////////
  Graph(float _x, float _y, float _w, float _h, int _K)
  {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    K = _K;
    stepWidth = w / K;
   
    values = new int[K];
    times = new int[K];
    for(int j=0; j<K; j++)
    {
      values[j] = 0;
      times[j] = 0;
    }
    
    currentIndex =  0;
    lastIndex = 0;  
    lastTime = millis();
    
    bInside = false;
  }
  
  // DISPLAY ///////////////////////////////////////////////////////////////////////
  void display()
  {
    
    pushMatrix();
    translate( x, y );
    
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
      // NOTE: inside currentIndex now we have an index that is grater of 1 unit 
      // that the one where we placed the last reading from the sensor. 
      // This is why we are not usign the following formula 
      // int valuesIndex = (K-1) - ((K - 1 - currentIndex ) + i) % K; 
      int valuesIndex;
      if( bScreenShotMode )
        valuesIndex = (K-1) - ((K - lastIndex ) + i) % K; 
      else
        valuesIndex = (K-1) - ((K - currentIndex ) + i) % K; 
      int v = values[ valuesIndex ];
      v = (int) map(v, 0, 1023, 0, h);

      // draw time lines ****************************************************
      if( times[valuesIndex] == 1 )
      {
        pushStyle();
        stroke(255, 0, 0);
        strokeWeight(1);
        line(graphIndex*stepWidth, h, graphIndex*stepWidth, 0);
        popStyle();
      }
      
      // draw grap line *****************************************************
      vertex(graphIndex*stepWidth, h-v);
    }
    endShape();
       
    // display graph outline
    noFill();
    strokeWeight(1);
    stroke(0, 255, 0);
    rect(0, 0, w, h);
    
    popMatrix();
    
    // display mouse cursor
    if( bInside )
    { 
      stroke(255, 255, 0);
      strokeWeight(1);
      line( mouseCoordsX, y, mouseCoordsX, y+h); // vertical line  
            
      // we want to obtain the stored value inside the values 
      // array according to the mouse position on the graph.
      int mappedMouseX = (int) map( constrain(mouseCoordsX-x, 0, w) , 0, w, K, 0);
      
      int valuesIndex;
      if( bScreenShotMode )
        valuesIndex = (K-1) - ((K - lastIndex ) + mappedMouseX) % K; 
      else
        valuesIndex = (K-1) - ((K - currentIndex ) + mappedMouseX) % K; 
      int v = values[ valuesIndex ];
      
      float vMapped = map(v, 0, 1024, h, 0);
      line( x, y+vMapped, x+w, y+vMapped);  // horizontal line
      
      // text
      textAlign(LEFT);
      fill(255);
      textFont(f);
      text(v +";", x-40, y+vMapped);
    }
   
  }
  
  // INSERT NEW READING ////////////////////////////////////////////////////////////
  void insertNewReading( int value )
  {
    values[ currentIndex ] = value;
      
    // TIME
    if(millis() - lastTime >= 1000)
    {
      times[ currentIndex ] = 1;
      lastTime = millis();
    }
    else
    {
      times[ currentIndex ] = 0;
    }
      
    // we update the index so to be ready to 
    // store the next incoming value from teh sensor
    currentIndex = ( ++currentIndex ) % K;
    
  }
  
  
  // SCREENSHOT MODE ///////////////////////////////////////////////////////////////
  void screenshotMode()
  {
    lastIndex = currentIndex;
  }
  
  // MOUSE /////////////////////////////////////////////////////////////////////////
  void mouseInteraction( int _mouseX, int _mouseY )
  {
    mouseCoordsX = _mouseX;
    mouseCoordsY = _mouseY;
    // mouse inside graph area
    if( mouseCoordsX > x && mouseCoordsX < x + w && mouseCoordsY > y && mouseCoordsY < y + h )
      bInside = true;
    else
      bInside = false;    
  }
  
  
} // Graph class