
public class Client {
  public boolean DEBUG = false;
  public boolean DEBUG_OUT = true;

  public String lighthouse_url = "http://relay.seekwhencer.de";

  public String mode = "device";
  public String name = "orb";
  public String relay_name = "main";

  public boolean connect_on_startup = true;
  public boolean auto_reconnect = true;

  public boolean check_wan_ip_on_startup = false;
  public boolean auto_check_wan_ip = false; // check ip change
  public String wan_url_get = this.lighthouse_url+"/getip/"+this.mode+"="+this.name;
  public String wan_ip = "";



  /*
    Without Lighthouse Ip Check: 
   set check.relay_ip_on_startup = false
   set auto_check_relay_ip = false
   and set the relay_ip to a local one    
   */
  public boolean check_relay_ip_on_startup = false;
  public boolean auto_check_relay_ip = false; // check ip change

  public String relay_url_get = this.lighthouse_url+"/getrelayip/"+this.relay_name;

  public String relay_ip = "192.168.2.104";
  public int relay_port = 666;

  public String resource_descriptor = this.mode+"="+this.name;
  public String relay_url = "ws://"+this.relay_ip+":"+this.relay_port+"/"+this.resource_descriptor;

  public int start_millis;
  public int pong_millis = 0;
  public int pong_drop = 5; // seconds to drop the connection, the cycle tries to reconnect automatically

  public int main_thread_frequency = 1; // Hz, Times per Second

  public WSClient wsc;
  public MainThread tm;


  public Client() {
    this.connect();
    this.startThread();
  }


  public void connect() {
    this.wsc = new WSClient( URI.create( this.relay_url ), new Draft_Device() );
  }

  public void startThread() {
    this.tm = new MainThread();
    this.tm.setClient(this);
    this.tm.setFrequency(this.main_thread_frequency);
    this.tm.start();
  }

  public void reconnect() {
    if (this.DEBUG_OUT)
      System.out.println("WSClient: Reconnect to new Relay." );

    this.relay_url = "ws://"+this.relay_ip+":"+this.relay_port+"/"+this.resource_descriptor;  
    if (this.DEBUG_OUT)
      System.out.println("WSClient: Trying to close the connection." );

    this.tm.is_interrupted = true;
    this.wsc.close();
    delay(10);
    this.connect();
    this.tm.setClient(this);
    this.tm.is_interrupted = false;
  }

  //
  public void checkReconnect() {
    this.wsc.conn = this.wsc.getConnection();
    this.wsc.checkReconnect();
    if (this.wsc.conn!=null && this.pong_millis != 0) {
      if (this.getPongAge()>=this.pong_drop) {
        println("WSClient: PONG DROPPPED! by "+this.getPongAge());
        this.reconnect();
        return;
      }
    }
  }


  // get own wan ip
  public void checkWanIp() {
    try {
      URL url = new URL(this.wan_url_get);
      BufferedReader in = new BufferedReader(new InputStreamReader(url.openStream()));
      String wanip = in.readLine();

      // ip change!
      if (!this.wan_ip.equals(wanip)) {
        if (this.DEBUG_OUT)
          System.out.println("WSClient: WAN IP CHANGE TO: "+wanip+" (before: "+this.wan_ip+")" );

        this.wan_ip = wanip;
        this.getRelayIp();
      }
    }
    catch(MalformedURLException a) {
      if (this.DEBUG_OUT)
        System.out.println("WSClient: IP Change not possible. Malformed URL?" );
    }
    catch(IOException b) {
      if (this.DEBUG_OUT)
        System.out.println("WSClient: IP Change not possible. Maybe not connected with the Web?" );
    }
  }

  // get relay ip
  public void getRelayIp() {
    try {
      URL url = new URL(this.relay_url_get);
      BufferedReader in = new BufferedReader(new InputStreamReader(url.openStream()));
      String relayip = in.readLine();

      // relay ip change!
      if (!this.relay_ip.equals(relayip)) {
        if (this.DEBUG_OUT)
          System.out.println("WSClient: RELAY IP CHANGE TO: "+relayip+" (before: "+this.relay_ip+")" );

        this.relay_ip = relayip;
        this.reconnect();
      }
    }
    catch(MalformedURLException a) {
      if (this.DEBUG_OUT)
        System.out.println("WSClient: failed getting Relay Wan IP. Malformed URL?" );
    }
    catch(IOException b) {
      if (this.DEBUG_OUT)
        System.out.println("WSClient: failed getting Relay Wan IP. Maybe not connected with the Web?" );
    }
  }

  // get duration of connection
  public String getDuration() {
    int mdur = millis() - this.start_millis;
    float seconds = mdur/1000;

    String duration = seconds+" Sec";

    return duration;
  }

  // get duration of connection
  public int getPongAge() {
    int pdur = millis() - this.pong_millis;
    float seconds = pdur/1000;
    return parseInt(seconds);
  }

  //
  public void pingRelay() {

    JSONObject action = new JSONObject();
    action.setString("action", "ping");
    
    JSONObject data = new JSONObject();
    data.setString("mode", this.mode);
    data.setString("name", this.name);
    action.setJSONObject("ping", data); 
    
    /*
    JSONObject fields = new JSONObject();
    
    // Field
    JSONObject field = new JSONObject();
    field.setString("name", "throttle");
    field.setString("name", this.name);
    
    fields.setString("mode", this.mode);
    fields.setString("name", this.name);
    action.setJSONObject("fields", fields); 
    */
    

    
    this.wsc.sendMessage(action.toString());
  }


  // Process Incoming Messages
  public void processMessage(String _message) {
    JSONObject message = JSONObject.parse( _message );
    String action = null;

    if (message.hasKey("action")) {
      action = message.getString("action");
    }

    if (message.hasKey(action)) {
      JSONObject data = message.getJSONObject(action);

      if (action.equals("pong")) {

        if (data.hasKey("mode") && data.hasKey("name")) {
          String mode = data.getString("mode");
          String name = data.getString("name");

          if (mode.equals("relay") && name.equals(this.relay_name)) {
            this.pong_millis = millis();
            System.out.println("WSClient: got Pong back from Relay: "+name);
          }
        }
      }
    }
  }
  
  public void sendWelcome(){
    if (this.DEBUG_OUT)
      System.out.println("WSClient: sending Welcome!" );
    
    JSONObject welcome_action = new JSONObject();
    JSONObject welcome = new JSONObject();
    //welcome.setString("id", cl.id);
    welcome_action.setString("action", "welcome");
    welcome_action.setJSONObject("welcome", welcome); 
    this.wsc.sendMessage(welcome_action.toString());
  }
}

