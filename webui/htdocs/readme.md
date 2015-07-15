    Relay UI
    
    Two jQuery Plugins:
    
    1. jquery.wsrelay.js
    2. jquery.wsrelayui.js
    
    
    1. Is the Websocket Connection to the Relay.
    
    var wsrelay;
    
    wsrelay = $('#targetelement').wsrelay({
    
        host : '192.168.2.101',         // Relay IP
        port : 6666,                    // Relay Port
        mode : 'webui',                 // Resource Descriptor Mode of the Connection
        name : 'relaymonitor',          // Resource Descriptor Name of the Connection
    
        auto_reconnect : true,          // Try to reconnect
        check_relay_on_startup:true,    // Check the Relay IP from Lighthouse
        
        onOpen : function(e) {          // When the Connection is open
            ui.connected(e);
        },
    
        onClose : function(e) {         // When the Connection is closed
            ui.disconnected(e);
        },
    
        onMessage : function(message) { // When Message is incoming
            ui.incoming(message);
        },
        
        onLighthouseError : function(){ // When Lighthouse is not Reachable @TODO
            ui.lighthouse_error();
        }
        
    });
    
    
    Methods outside of wsrelay:
 
    wsrelay.setHost()               Set options.host in wsrelay.
    wsrelay.connect()               Connect to the Relay Server.
    wsrelay.disconnect()            As Name.
    wsrelay.reconnect(host)         Disconnect and connect to the given Host.
    wsrelay.sendAction(message)     Send a Message to the Relay.
    
    
    
    
    
    2. The Websockt UI Plugin
    
    var wsrelayui;
    
    ui = $('#targetelement').wsrelayui({
    
    });
    
    
    Methods outside of wsrelayui:
    
    ui.connected() 
    ui.disconnected()
    ui.incoming(message)
    ui.lighthouse_error()
