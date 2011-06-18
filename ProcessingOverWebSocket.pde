/*
  Broadcast the visual result of this sketch as a jpg image
  stream to a websocket. This is a rough proof of concept 
  and is not really ready  for easy use - but you can copy
  and paste parts of it. if it does not work or chrashes
  your machine, i am not responsible for that! ;)
  
  Oh! And you must have a browser, that supports WebSockets,
  e.g. Chrome, Chromium or Safari.
  
  It is based on the UDP streaming example from Daniel
  Shifman you can find here:
  
  http://www.shiffman.net/2010/11/13/streaming-video-with-udp-in-processing/
  
  For the WebSocketP5 functionality you need this library:
  http://p5.twelvebytes.net/websocketP5-0.1.2/
  
  ***
  HOW TO SEE SOMETHING:
  
  1) make sure you have the above mentioned library
  2) run this sketch
  3) point your browser to http://localhost:8080
  4) be amazed and pay resepct to the mystic digital things
  5) write interesting things with this!
  
  TATA!
  
  have fun! :)
  
 */
// For the WebSocket
import muthesius.net.*;
import org.webbitserver.*;

// For image compression
import javax.imageio.*;
import java.awt.image.*; 

// For Base64
import org.apache.commons.codec.binary.*;


// Let's roll!
WebSocketP5 ws;
PFont font;

void setup() {
  size(320, 240); // do not use more than this, it'll slow down!
  smooth();
  font = createFont("Monaco", 27);
  textFont(font);

  ws = new WebSocketP5(this, 8080);
}

float anim = 0;
float speed= 0.005;

void draw() {
  anim = (anim+speed)-(int)anim;
  background(127);
  noStroke();
  fill(255);

  text("FPS: "+frameRate, 10, 35);

  rect(anim*width-10, mouseY, 10, height);
  
  // after drawing, broadcast the image:
  broadcastOutput();
}

void broadcastOutput() {
  // We need a buffered image to do the JPG encoding
  int w = width;
  int h = height;
  BufferedImage b = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);

  // Transfer pixels from localFrame to the BufferedImage
  loadPixels();
  b.setRGB( 0, 0, w, h, pixels, 0, w);

  // Need these output streams to get image as bytes for UDP
  ByteArrayOutputStream baStream = new ByteArrayOutputStream();
  BufferedOutputStream bos = new BufferedOutputStream(baStream);

  // JPG compression into BufferedOutputStream
  // Requires try/catch

  try {
    ImageIO.write(b, "jpg", bos);
  } 
  catch (IOException e) {
    println("could not encode image");
    return;
  }

  // Get the byte array, which we will send out via UDP!
  try {
    String out = new String(Base64.encodeBase64(baStream.toByteArray(), false));
    ws.broadcast("data:image/*;base64,"+out);
  } 
  catch(Exception e) {
    e.printStackTrace();
  }
}

