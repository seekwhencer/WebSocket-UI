/////////////////////////////////////////////////////////////////////////////////////////////////////
// Server Clients
/////////////////////////////////////////////////////////////////////////////////////////////////////
public class ServerClients {
  public boolean DEBUG = false;
  public boolean DEBUG_OUT = true;

  public ArrayList<ServerClient> list = new ArrayList<ServerClient>();

  public ServerClients() {

  }

  // Add Client
  public void addClient(WebSocket connection, ClientHandshake handshake) {
    
    int ls = 0;
    if(list!=null)
      ls = list.size();
    
    ServerClient Client = new ServerClient(); 

    Client.id = rs.getClientId(connection);
    Client.ip = connection.getRemoteSocketAddress().getAddress().getHostAddress();
    Client.port = connection.getLocalSocketAddress().getPort();
    Client.resource_descriptor = handshake.getResourceDescriptor();
    
    String[] split = Client.resource_descriptor.split("=");
     
    Client.mode = split[0].replace("/","");
    Client.name = split[1];
    Client.start_millis = millis();
    Client.ping_on = false;
    Client.ping_millis = 0;
    
    if (this.DEBUG_OUT)
      System.out.println( "WSServer: adding Client "+Client.ip+" ID: "+Client.id+" "+Client.port+" "+Client.resource_descriptor );
        
    list.add( ls, Client );
    Client.sendWelcome(connection);
    
    if(Client.mode.equals("device"))
      rs.removeUniqueConnections(Client.mode, Client.name, Client.id);
    
  }

  // Remove Client
  public void removeClient(String id) {
    if (this.list.size()>0)
      for (int i=0; i<this.list.size (); i++) {
        if (this.list.get(i).id.equals(id)) {
          this.list.remove(i);
        }
      }
  }
  
  // Get Client by ID
  public ServerClient getClient(String id) {
    if (this.list.size()>0)
      for (int i=0; i<this.list.size (); i++) {
        if (this.list.get(i).id.equals(id)) {
          return this.list.get(i);
        }
      }
    
    return null;
  }
  

  
}



/////////////////////////////////////////////////////////////////////////////////////////////////////
// Server Client
/////////////////////////////////////////////////////////////////////////////////////////////////////
public class ServerClient {
  public String id = "";
  public String ip = "";
  public int port = 0;
  public String resource_descriptor = "";
  public String mode = "";
  public String name = "";
  public int start_millis = 0;
  public int ping_millis = millis();
  public boolean ping_on = false;
  
  public void ServerClient() {
  }
  
  public void ServerClient(String _id) {
    id = _id;
  }

  public void ServerClient(String _id, String _ip, int _port, String _resource_descriptor) {
    id = _id;
    ip = _ip;
    port = _port;
    resource_descriptor = _resource_descriptor;
  }
  
  public String getDuration(){
    int mdur = millis() - this.start_millis;
    float seconds = mdur/1000;
    String duration = seconds+" Sec";
    return duration;
  }
  
  // get time between last ping
  public int getPingAge() {
    int pdur = millis() - this.ping_millis;
    float seconds = pdur/1000;
    return parseInt(seconds);
  }
  
  // Send the Relay Connection ID back to the Client
  public void sendWelcome(WebSocket connection){  
    ServerClient cl = rs.clients.getClient(rs.getClientId(connection));
    JSONObject welcome_action = new JSONObject();
    JSONObject welcome = new JSONObject();
    welcome.setString("id", cl.id);
    welcome_action.setString("action", "welcome");
    welcome_action.setJSONObject("welcome", welcome); 
    rs.wss.sendMessage(connection, welcome_action.toString());
  }
  
  //
  public void warnRelayBeforeDrop(WebSocket connection){
    ServerClient cl = rs.clients.getClient(rs.getClientId(connection));
    JSONObject action = new JSONObject();
    JSONObject action_data = new JSONObject();
    action_data.setString("id", cl.id);

    action.setString("action", "warning-drop");
    action.setJSONObject("warning-drop", action_data);
    rs.sendToMode("webui", action.toString());
  }
  
}

