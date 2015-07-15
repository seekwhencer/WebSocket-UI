/*
    Server Thread for the Web Socket Server
 */
public class ServerThread extends Thread {

  public RelayServer rs;

  public void setServer(RelayServer _rs) {
    this.rs = _rs;
  }

  @Override
    public void run() {
    try {   
      if (this.rs.DEBUG_OUT)
        System.out.println( "WSServer: started on port " + this.rs.wss.getPort() );

      BufferedReader sysin = new BufferedReader( new InputStreamReader( System.in ) );
      while ( true ) {
        String in = sysin.readLine();

        //if (this.rs.DEBUG_OUT)
        //  println("WSServer incomming: "+in);

        //rs.sendToAll( in );
      }
    }
    catch(IOException e) {
      e.printStackTrace();
    }
  }
}

/*
    Heartbeat Main Thread
 */
public class MainThread extends Thread {

  public RelayServer rs;

  public int frequency = 1; // Hz, times per second
  public boolean is_interrupted = false;

  public void setServer(RelayServer _rs) {
    this.rs = _rs;
  }

  public void setFrequency(int _f) {
    this.frequency = _f;
  }


  @Override
    public void run() {  
      
    if (this.rs.check_wan_ip_on_startup && !this.is_interrupted) {
      this.rs.checkWanIp();
    }
    
    this.rs.launch();


    while ( !this.is_interrupted ) {
      delay(1000/this.frequency);      

      //
      if (this.rs.auto_check_clients)
        this.rs.checkClients();
      
      //
      if (this.rs.auto_check_wan_ip)
        this.rs.checkWanIp();
      
      //
      this.rs.checkMonitor();
    }
  }
}

