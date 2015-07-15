/*

 ORB Websocket Device
 Matthias Kallenbach
 July, 2015
 Berlin
 
 seekwhencer.de
 
 */
import java.net.*;
import java.io.*;

// Websocket Server
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.InetSocketAddress;
import java.net.UnknownHostException;
import java.util.Collection;
import org.java_websocket.WebSocket;
import org.java_websocket.WebSocketImpl;
import org.java_websocket.framing.Framedata;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;

// Websocket Client
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.lang.reflect.Method;

import org.java_websocket.client.WebSocketClient;
import org.java_websocket.drafts.Draft;
import org.java_websocket.drafts.Draft_10;
import org.java_websocket.drafts.Draft_17;
import org.java_websocket.framing.Framedata;
import org.java_websocket.handshake.ServerHandshake;

import org.java_websocket.exceptions.InvalidHandshakeException;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.handshake.ClientHandshakeBuilder;
import java.nio.channels.NotYetConnectedException;

// Init
Client client;

// Setup
void setup() {
  size(10, 10);
  frameRate(1);
    
  WebSocketImpl.DEBUG = false;

  client = new Client();
  
}

//
void draw(){

}

void stop() {
  super.stop();
  client.wsc.close();
}

