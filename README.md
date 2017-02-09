# Processing Oscilloscope

We have created this sketch because we don't have a real oscilloscope and we've tried to find a confortable way to plot signals we read from different kind of analog sensors usign our Arduino board.

This can be a solution when you are sending data coming from multiple sensors and you can't use the _Arduino Serial plotter_ tool.

Please feel free to contact us at _info[at]limulo.net_ or visit our [website](http://www.limulo.net/website) if you need more information about it.

---

Here's a screenshot of the _virtual oscilloscope_ plotting signals from two potentiometers.

![plotter in action screenshot ](http://www.limulo.net/website/assets/images/processing-oscilloscope/screenshot.png)

As you can see, graphs from different sensors are drawn one below the other. The oscilloscope shows also a series of red vertical lines in order to mark the time (one line for each second passed). You can also enter the _screenshot mode_ to freeze the image. You can use the mouse and place the cursor over the curves to examine values in more detail.

## Installation

In order to use this _virtual oscilloscope_ you simply need to have [Processing](https://processing.org/) and [Arduino](https://www.arduino.cc/) up and running.

## How to use it

### Theory

We know that Arduino quantizes the analog input values usign **10bit** (analog readings can take values from 0 to 1023). In order to maintain the higher fidelity with the original 10bit sampled signal and not to loose any information in sending these information via serial, we need almost 2 byte.

Taking inspiration from the MIDI protocol, we decided to split these 10bit numbers into two part:

* the most significant bits are contained inside a first byte that is always sent as the first of a sequence of two; we call it the **status byte**;
* a second byte, we call it the **data byte**, is sent immediately after the _status_ one and contains the remainig bits (the least significants).

On the receiver side, we needed a way for Processing to differentiate between _status_ and _data_ bytes, so we dedicated the most significant bit of these two type of byte for the purpose:

* when we read a byte whose most significan bit is 1, we know it is a _status byte_;
* when this bit is 0, we know we are reading a _data byte_ instead;

We use the remaining 4 bit of the status byte to send information about the _sensor number_: this is a useful information we can use if there are more than one analog signal we want to plot!

![byte structure](http://www.limulo.net/website/assets/images/processing-oscilloscope/messages-protocol.png)

### Sender side: Arduino

Once you have created your circuit and your Arduino program and you want to plot some data from it, you have to add some line of code to your Arduino sketch in order to correctly format the data and send them via serial to the _virtual oscilloscope_.

Take a look at the Arduino ```to_serial_oscilloscope_02``` sketch inside the ```code/Arduino_test``` folder  as an example. 

### Receiver side: Processing

By default the _virtual oscilloscope_ expects receiving 2 analog sensor readings and it plots them as line graphs of **512 points** in resolution.

If you want you can always change these values acting respectively on the variable ```int N = 2;``` and ```int K = 512;``` in the Processing code. Obviously you have also to update your Arduino code accordingly.

---

Once the _virtual oscilloscope_ has been lauched, you can enable the serial communication with the Arduino board (provided by the _Processing Serial_ library) by pressing the **o** or **O** keys. This way the Arduino board will start to send bytes over the USB connection to the Processing sketch.

If you want to close the serial communication press **c** or **C**: this will interrupt the byte flow.

### Screenshot Mode

Every time you want to pause the continuous plotting and examine a fixed portion of the graphs simply press the **spacebar**. This will make the plotter enter its _screenshot mode_.

When in _screenshot mode_ the plotter will continue receiving serial data from the Arduino board but it will discard them while continuously drawing a fixed image showing the last portion of the graphs.

### Mouse interaction

Every time you move the mouse on a graph, both in _screenshot mode_ than not, a vertical and an horizontal line will appear.

These lines respectively represent the mouse horizontal position - among the 512 stored values - and the corresponding graph value. You will also see a numeric value on the left indicating the 10bit value as originally read by the Arduino board.
