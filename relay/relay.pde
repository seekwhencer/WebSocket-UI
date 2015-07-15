/*

 ORB Websocket Relay
 Matthias Kallenbach
 July, 2015
 Berlin
 
 seekwhencer.de
 
 */

// Websocket Server
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.InetSocketAddress;
import java.net.UnknownHostException;
import java.util.Collection;
import java.util.List;

import java.net.*;
import java.io.*;

import org.java_websocket.WebSocket;
import org.java_websocket.WebSocketImpl;
import org.java_websocket.framing.Framedata;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;

import org.java_websocket.drafts.Draft;
import org.java_websocket.drafts.Draft_10;
import org.java_websocket.drafts.Draft_17;
import org.java_websocket.handshake.ClientHandshakeBuilder;
import org.java_websocket.handshake.HandshakeBuilder;
import org.java_websocket.handshake.ServerHandshakeBuilder;
import org.java_websocket.exceptions.InvalidHandshakeException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import org.java_websocket.util.Base64;

import java.net.Socket;
import java.nio.channels.SocketChannel;
import java.net.SocketException;

import java.util.ConcurrentModificationException;

//import org.json.*;

// Init
RelayServer rs;

// Setup
void setup() {
  size(10, 10);
  frameRate( 1 );
  
  rs = new RelayServer();
  
}

void draw(){

}

void stop() {
  super.stop();
}

