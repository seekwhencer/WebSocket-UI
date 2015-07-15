/*
    Heartbeat Main Thread
 */
public class MainThread extends Thread {
  public boolean DEBUG = false;
  public boolean DEBUG_OUT = true;
  
  public Client client;
  public WSClient wsc;

  public int frequency = 1; // Hz, times per second
  public boolean is_interrupted = false;

  public void setClient(Client _client) {
    this.client = _client;
  }

  public void setFrequency(int _f){
    this.frequency = _f;
  }


  @Override
    public void run() {
      if(this.client.check_wan_ip_on_startup && !this.is_interrupted){
        this.client.checkWanIp();
      }
      
      if(this.client.check_relay_ip_on_startup && !this.is_interrupted){
        this.client.getRelayIp();
      }
      
      if(this.client.connect_on_startup && !this.is_interrupted){
        if(this.DEBUG_OUT){
          System.out.println(""); 
          System.out.println("WSCLient: Connecting the first Time to: "+this.client.relay_ip+", waiting ...");
          System.out.println("");
          this.client.wsc.connect();
          delay(10); 
        }
      }
      while ( !this.is_interrupted ) {
        delay(1000/this.frequency);      
  
        if(this.client.auto_reconnect)
          this.client.checkReconnect();
          
        if(this.client.auto_check_wan_ip)
          this.client.checkWanIp();
          
        if(this.client.auto_check_relay_ip)
          this.client.getRelayIp();
        
        // ping the relay and get the pong :)
        this.client.pingRelay();
          
      }
  }
}

