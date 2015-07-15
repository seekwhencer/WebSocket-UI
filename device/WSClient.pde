/*
    Websocket Client to communicate with remote Websocket Relay
 */
public class WSClient extends WebSocketClient {
  public boolean DEBUG = false;
  public boolean DEBUG_OUT = true;
  public boolean DEBUG_OUT_MESSAGE_IN = false;
  

  private WebSocket conn = null;

  public String connected_host;
  public int connected_port;
  public String connection_id;


  public WSClient( URI serverUri, Draft draft ) {
    super( serverUri, draft );
  }

  public WSClient( URI serverURI ) {
    super( serverURI );
  }

  /*
    Overrides
   */

  @Override
    public void onOpen( ServerHandshake handshakedata ) {
    this.conn = this.getConnection();
    this.getSocketInfo();
    client.start_millis = millis();
    client.pong_millis = millis();
    
    client.sendWelcome();
    
    if (DEBUG_OUT)
      System.out.println( "WSClient: Connection established to "+this.connected_host+":"+this.connected_port );
  }

  @Override
    public void onClose( int code, String reason, boolean remote ) {
    if (DEBUG_OUT)
      System.out.println( "WSClient: Connection closed by " + ( remote ? "remote peer" : "us" ) );

    this.conn = this.getConnection();
    this.getSocketInfo();
  }

  @Override
    public void onMessage( String message ) {
    if (DEBUG_OUT_MESSAGE_IN)
      System.out.println( "WSClient received: " + message );
    
    client.processMessage(message);
  }

  @Override
    public void onError( Exception ex ) {
    if (DEBUG)
      ex.printStackTrace();

    //if (DEBUG_OUT)
    //  System.out.println( "WSClient Connection Error: Relay Host not reachable");

    this.conn = this.getConnection();
    this.getSocketInfo();
  }

  


  //
  public void sendMessage(String message) {
    try{
      this.send(message);
    } catch(NotYetConnectedException e){
      
    }
  }


  //
  public String getId() {
    return this.connection_id;
  }

  // check and reconnect
  public void checkReconnect() {
    this.conn = this.getConnection();
    
    if(this.conn==null){
      this.connect();
      delay(2000);
      return;
    }
    
    if (this.conn.isOpen()) {
      if (this.DEBUG_OUT)
        System.out.println("WSCLient (THIS DEVICE) is connected to: "+this.connected_host+":"+this.connected_port+" | since "+client.getDuration()+" | ID: "+this.connection_id);
    }
    
    if(this.conn.isClosed()) {
      if (this.DEBUG_OUT)
        System.out.println("WSCLient (THIS DEVICE) is not connected, trying to reconnect to "+client.relay_ip+":"+client.relay_port);        

      this.connect();
      delay(2000);
      println("");
    }
  }

  // get and store: host, port and ID of the connection
  public void getSocketInfo() {
    if (this.conn.isOpen()) {
      String address = this.conn.getRemoteSocketAddress().toString();

      String split_a[] = address.split("/");
      String split_b[] = split_a[1].split(":");
      String split_c[] = this.conn.toString().split("@");

      this.connected_host = split_b[0];
      this.connected_port = Integer.parseInt( split_b[1] );
      this.connection_id = split_c[1];
    }
  }
}




/* 
 Connection Draft Extension
 */
public class Draft_Device extends Draft_17 {

  public String socket_version  = "13";
  //public String socket_key = "device";

  @Override
    public ClientHandshakeBuilder postProcessHandshakeRequestAsClient( ClientHandshakeBuilder request ) {
    super.postProcessHandshakeRequestAsClient( request );
    //request.put( "Sec-WebSocket-Version", this.socket_version );
    //request.put( "Sec-WebSocket-Key", this.socket_key ); // this is the important change
    return request;
  }
}

