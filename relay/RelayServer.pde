

public class RelayServer {
  public boolean DEBUG = false;
  public boolean DEBUG_OUT = true;

  public String lighthouse_url = "http://relay.seekwhencer.de";

  public int server_port = 666;

  public String mode = "relay";
  public String name = "main";

  public boolean check_wan_ip_on_startup = false;
  public boolean auto_check_wan_ip = false;
  public boolean auto_check_clients = true;

  public String wan_url_get = this.lighthouse_url+"/getip/"+this.mode+"="+this.name;
  public String wan_ip = "n/a";

  public int main_thread_frequency = 1; // Hz, Times per Second
  public int ping_drop = 10;

  public WSServer wss;
  public ServerClients clients;
  public MainThread tm;
  public ServerThread ts;


  public RelayServer() {
    this.init();
  }

  public RelayServer(int port) {
    this.server_port = port;
    this.init();
  }

  public RelayServer(int port, String mode, String name) {
    this.server_port = port;
    this.mode = mode;
    this.name = name;
    this.init();
  }

  // Init
  public void init() {
    this.wss = new WSServer( this.server_port );
    this.clients = new ServerClients();
    this.initThreads();
    this.startThreads();
  }

  // Init Threads
  public void initThreads() {

    // Main Thread
    this.tm = new MainThread();
    this.tm.setServer(this);
    this.tm.setFrequency(this.main_thread_frequency);

    // Websocket Server Thread
    this.ts = new ServerThread();
    this.ts.setServer(this);
  }

  // Launch
  public void launch() {
    this.wss.start();
  }

  // Threads Start
  public void startThreads() {
    this.ts.start();
    this.tm.start();
  }


  // Check the Wide Area Ip Address
  public void checkWanIp() {
    try {
      URL url = new URL(this.wan_url_get);
      BufferedReader in = new BufferedReader(new InputStreamReader(url.openStream()));
      String wanip = in.readLine();

      // ip change!
      if (!this.wan_ip.equals(wanip)) {
        if (this.DEBUG_OUT)
          System.out.println("WSServer: WAN IP CHANGE TO: "+wanip+" (before: "+this.wan_ip+")" );

        this.wan_ip = wanip;
      }
    }
    catch(MalformedURLException a) {
      if (this.DEBUG_OUT)
        System.out.println("WSServer: IP Change not possible. Malformed URL?" );
    }
    catch(IOException b) {
      if (this.DEBUG_OUT)
        System.out.println("WSServer: IP Change not possible. Maybe not connected with the Web?" );
    }
  }

  // Check Connections
  public void checkClients() {
    this.wss.getConnections();
    if (this.wss.conn.size()>0) {
      ServerClient cl;
      try {
        for ( WebSocket ws : this.wss.conn ) {
          if (ws.isOpen()) {
            String id =  this.getClientId(ws);
            cl = this.clients.getClient(id);
            if (this.DEBUG_OUT)
              System.out.println("WSServer: Client: "+cl.ip+":"+cl.port+" | since "+cl.getDuration()+" | ID: "+cl.id + " | Name: "+cl.name+" | Mode: "+cl.mode );

            if (cl.getPingAge()==this.ping_drop && cl.ping_on==true ) {
              cl.ping_on=false;
              this.removeConnection(ws);
            }
            //Socket socket = this.wss.getSocket(ws);
            //SocketChannel channel = socket.getChannel();
          }
        }
      } 
      catch(ConcurrentModificationException e) {
      }
    } else {
      if (this.DEBUG_OUT)
        System.out.println("WSServer: no Client connected.");
    }
  }

  // Get Client info from Connection
  public String getClientId(WebSocket conn) {
    String id = null;
    if (conn.isOpen()) {
      String[] split = conn.toString().split("@");
      id = split[1];
    }
    return id;
  }

  // close other connections by mode and name for the latest unique connection
  public void removeUniqueConnections(String mode, String name, String id) {
    this.wss.getConnections();
    if (this.wss.conn.size()>0) {
      for ( WebSocket ws : this.wss.conn ) {
        if (ws.isOpen()) {
          ServerClient cl = this.clients.getClient(this.getClientId(ws));

          if ((cl.mode.equals(mode) && cl.name.equals(name)) && !cl.id.equals(id) ) {
            if (this.DEBUG_OUT)
              System.out.println("WSServer: dropping for unique Client: "+cl.ip+":"+cl.port+" | ID: "+cl.id + " | Name: "+cl.name+" | Mode: "+cl.mode );

            this.wss.removeConnection(ws);
          }

          if (this.DEBUG_OUT)
            System.out.println("WSServer connected: "+cl.ip+":"+cl.port+" | ID: "+cl.id + " | Name: "+cl.name+" | Mode: "+cl.mode );
        }
      }
    } else {
      if (this.DEBUG_OUT)
        System.out.println("WSServer: no Client connected.");
    }
  }

  // close other connections by mode and name for the latest unique connection
  public void removeConnection(WebSocket _conn) {
    if (_conn.isOpen()) {
      String id = this.getClientId(_conn);
      ServerClient cl = this.clients.getClient(id);

      if (this.DEBUG_OUT)
        System.out.println("WSServer: dropping for idle Client: "+cl.ip+":"+cl.port+" | ID: "+cl.id + " | Name: "+cl.name+" | Mode: "+cl.mode );

      this.wss.removeConnection(_conn);
    }
  }

  //
  //public void pongClient(WebSocket _conn) {
  //  this.wss.sendMessage(_conn, "{\"ping\":\""+this.mode+"="+this.name+"\"}");
  //}

  // Process Incoming Messages
  public void processMessage(WebSocket _conn, String _message) {
    JSONObject message = JSONObject.parse( _message );
    String action = null;

    String id =  this.getClientId(_conn);
    ServerClient cl = this.clients.getClient(id);

    if (message.hasKey("action"))
      action = message.getString("action");

    if (message.hasKey(action)) {
      JSONObject data = message.getJSONObject(action);

      // ping action from device
      if (action.equals("ping")) {
        if (cl.mode.equals("device")) {
          
          // one row, sorry...
          String pong_message = "{\"action\":\"pong\", \"pong\":{\"mode\":\""+this.mode+"\",\"name\":\""+this.name+"\"}}";
          this.wss.sendMessage(_conn, pong_message);

          cl.ping_millis = millis();
          cl.ping_on = true;
        }
      }

      // welcome data
      if (action.equals("welcome")) {
        if (cl.mode.equals("device")) {
          // say what?
        }
      }

      // Route when action = values is
      // IMPORTANT: the structure is:
      /*
        {
       "action" : "values",
       "values" : {
       "steering" : "0",
       "throttle" : "0",
       "light_top": "0",
       "light_bottom" : "0"
       
       and so on.
       
       }
       }
       
       and beware: the mover (sender) webui gets also the values from the device!
       stop getting values and modifying the knobs in the UI, when the knob is in use
       */
      if (action.equals("values")) {

        // Send from Device to WebUI
        if (cl.mode.equals("device")) {
          rs.sendToMode("webui", _message); // <-- magic!
        }

        // Send from WebUI to Device
        if (cl.mode.equals("webui")) {
          rs.sendToMode("device", _message); // <-- magic!
          rs.sendToModeExceptID("webui", _message, cl.id); // <-- magic!
        }
      }
      
      // the same for a little chat
      if (action.equals("chat")) {
        // Send from WebUI to WebUI and Device
        if (cl.mode.equals("webui")) {
          rs.sendToMode("webui", _message);
          rs.sendToMode("device", _message);
        }
      }
    }
  }

  // Send Status to connected Relay Monitor Web Clients
  public void checkMonitor() {
    this.wss.getConnections();
    //try{
    if (this.wss.conn.size()>0) {

      // Build the Status Message
      ServerClient cl;
      JSONObject status_monitor = new JSONObject();
      JSONObject sm_clients = new JSONObject();
      for ( WebSocket ws : this.wss.conn ) {
        cl = this.clients.getClient(this.getClientId(ws));
        JSONObject client_connection = new JSONObject();
        client_connection.setString("name", cl.name);
        client_connection.setString("mode", cl.mode);
        client_connection.setString("ip", cl.ip);
        client_connection.setString("id", cl.id);

        sm_clients.setJSONObject(cl.id, client_connection);

        // Send Warning to relay if Client seems to be lost
        if (cl.getPingAge()>1 && cl.getPingAge() < this.ping_drop && cl.ping_on==true && cl.mode.equals("device")) {
          cl.warnRelayBeforeDrop(ws);
        }
      }

      status_monitor.setString("action", "clients");
      status_monitor.setJSONObject("clients", sm_clients);

      // Send the Status Message to all Connections width name=relaymonitor
      this.sendToMode( "webui", status_monitor.toString() );
    }
    //}
    //catch(NullPointerException e){}
  }

  // Send message by mode  
  public void sendToMode(String _mode, String _message) {
    //println("WSServer: sending to >"+_mode+"< Connections: "+_message);
    for ( WebSocket _conn : this.wss.conn ) {
      if (_conn.isOpen()) {
        ServerClient cl = this.clients.getClient(this.getClientId(_conn));
        if ( cl.mode.equals(_mode) ) {
          this.wss.sendMessage(_conn, _message);
        }
      }
    }
  }
  
  // Send message by mode  
  public void sendToModeExceptID(String _mode, String _message, String _id) {
    for ( WebSocket _conn : this.wss.conn ) {
      if (_conn.isOpen()) {
        ServerClient cl = this.clients.getClient(this.getClientId(_conn));
        if ( cl.mode.equals(_mode) && !cl.id.equals(_id)) {
          this.wss.sendMessage(_conn, _message);
        }
      }
    }
  }
}

