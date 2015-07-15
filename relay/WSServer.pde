/*
    WSServer Object
 */
public class WSServer extends WebSocketServer {
  public boolean DEBUG = false;
  public boolean DEBUG_OUT = true;

  public Collection<WebSocket> conn;

  //
  public WSServer( int port ) {
    super( new InetSocketAddress( port ) );
  }

  public WSServer( InetSocketAddress address ) {
    super( address );
  }

  public WSServer( InetSocketAddress address, List<Draft> drafts ) {
    super( address, drafts );
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  // Overrides
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  @Override
    public void onOpen( WebSocket _conn, ClientHandshake handshake ) {
    if (this.DEBUG_OUT)
      System.out.println( "WSServer: "+_conn.getRemoteSocketAddress().getAddress().getHostAddress() + " Descriptor:"+handshake.getResourceDescriptor()+" connected!" );

    rs.clients.addClient(_conn, handshake);  
    this.getConnections();
  }

  @Override
    public void onClose( WebSocket _conn, int _code, String _reason, boolean _remote ) {
    if (this.DEBUG_OUT)
      System.out.println( "WSServer: "+_conn.getRemoteSocketAddress().getAddress().getHostAddress() + " has left" );

    rs.clients.removeClient(rs.getClientId(_conn));
    this.getConnections();
  }

  @Override
    public void onMessage( WebSocket _conn, String _message ) {
    //if (this.DEBUG_OUT)
    //  System.out.println("WSServer got Message from: "+_conn.getRemoteSocketAddress().getAddress().getHostAddress() + ": " + _message );

    rs.processMessage(_conn,_message);
  }
  @Override
    public void onError( WebSocket _conn, Exception ex ) {
    if (this.DEBUG)
      ex.printStackTrace();

    if ( _conn != null ) {
      // some errors like port binding failed may not be assignable to a specific websocket
    }
    this.getConnections();
  }
  
  
  public Socket getSocket( WebSocket _conn ) {
      WebSocketImpl impl = (WebSocketImpl) _conn;
      return ( (SocketChannel) impl.key.channel() ).socket();
  }


  /////////////////////////////////////////////////////////////////////////////////////////////////////
  // Functions
  /////////////////////////////////////////////////////////////////////////////////////////////////////  



  // Get and Set Connections
  public void getConnections() {
    this.conn = connections();
  }

  // Send to all Clients
  public void sendToAll( String text ) {
    Collection<WebSocket> con = connections();
    synchronized ( con ) {
      for ( WebSocket ws : con ) {
        ws.send( text );
      }
    }
  }

  //
  public void sendMessage(WebSocket _conn, String message){
    _conn.send(message);
  }
  
    // Remove Connection
  protected boolean removeConnection( WebSocket ws ) {
    boolean removed;
    synchronized ( this.conn ) {
      removed = this.conn.remove( ws );
      assert ( removed );
    }
    return removed;
  }

}

