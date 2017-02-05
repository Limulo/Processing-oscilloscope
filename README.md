# Processing Oscilloscope

We have created this sketch because we don't have a real oscilloscope and we've tried to find a confortable way to plot signals we read from different kind of analog sensors usign our Arduino board.

## Installation

In order to use this _virtual oscilloscope_ you simply need to have [Processing]() and [Arduino]() up and running. 

## How to use it

Once you have created your circuit you have to add some line of code to your Arduino sketch in order to enable it to format and send serial data to the _virtual oscilloscope_.


### Theory 

We know that Arduino quantizes the analog input values usign 10bit (these analog readings can take values from 0 to 1023). In order to maintain the higher fidelity with the original 10bit sampled signal and not to loose any information in sending it via serial, we need almost 2 byte.

Taking inspiration from the MIDI protocol, we decided to split these 10bit numbers into two part:
* the most significant bits are contained inside a first byte that is always sent as the first of a sequence of two; we call it the **status byte**;
* a second byte, we call it the **data byte**, is sent immediately after the _status_ one and contains the remainig bits (the least significants).

We needed a way for Processing to differentiate between _status_ and _data_ bytes, so we dedicated the most significant bit of these two type of byte for the purpose:
* when we read a byte whose most significan bit is 1, we know it is a _status byte_;
* when this bit is 0, we know we are reading a _data byte_ instead;

We use the remaining 4 bit of the status byte to send information about the _sensor number_: this is a useful information we can use if there are more than one analog signal we want to plot!

![]()

--

By default the _virtual oscilloscope_ (also named plotter) expects receiving 2 analog sensor readings and it plots them as lines graph of 512 point in resolution. If you want you can always change these values acting respectively on the variable ```int N = 2;``` and ```int K = 512;``` in the Processing code. 

Obviously you have also to update your Arduino code accordingly.

---

Once the plotter has been lauched, you can enable the serial communication with the Arduino board (provided by the _Processing Serial_ library) by pressing the **o** or **O** keys. This way the Arduino board will start to send bytes over the USB connection to the Processing sketch.

If you want to close the serial communication press **c** or **C**: this will interrupt the byte flow.

### Screenshot Mode

Every time you want to pause the continuos plotting and examine a fixed portion of the graphs simply press the **spacebar**. This will make the plotter enter its _screenshot mode_. 

When in _screenshot mode_ the plotter will continue receiving serial data from the Arduino board but it will discard them while continuosly drawing a fixed image showing the last portion of the graphs.

### Mouse interaction

Every time you move the mouse on a graph, both in _screenshot mode_ than not, a vertical and an horizontal line will appear respectively representing the mouse horizontal position and the corresponding graph value. You will also see a numeric value on the left indicating the 10bit as read by the Arduino board.
