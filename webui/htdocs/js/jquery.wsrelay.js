/**
 *  Websocket Relay Connection
 *  Matthias Kallenbach | Berlin
 *  seekwhencer.de
 */

(function($) {

    var _ns = 'wsrelay';

    var defaults = {
        
        // The WAN or LAN IP, if in LAN, set "check_relay_on_startup=false"
        host : '192.168.2.104',
        
        // Security Issue: on Android Chrome, the Ports must be under 1024!
        port : 666,
        
        // The Mode Selector for the Connection, use "webui" to get every
        // second a heartbeat with the clients list    
        mode : 'webui',                     

        // The, unique or not, name of this connection.
        // webui connections MUST NOT be unique.
        // but, by the way, in mode "device" every name must be unique!   
        name : 'relaymonitor',              
        
        // The name of the Target Relay
        relay_name : 'main',
        
        // Get the Relay IP (host) from the Lighthouse, with a detour
        // over Php to speak with the remote Lighthouse REST API
        check_relay_on_startup : true,
        
        // It's better to set it to true :)
        auto_reconnect : true,

        // The Counter. On its end, the Reconnect Process will start
        reconnect_timeout : 10,
        
        // If the Reconnect Process runs, every seconds by "reconnect_time"
        // the process is trying to reconnect. Important to set it
        // NOT to 1 or 2. Its a Security Issue!
        reconnect_time : 5,
        
        // The Main Heartbeat Thread. thread_time means, that every
        // thread_time second the connection will be checked
        thread_time : 1,                    
        
        // Events
        // Every Event from outside will start, after the internal
        // on event function has been started.
        onOpen : false,
        onClose : false,
        onMessage : false,
        onLighthouseError : false,
        onConnectionLost : false,
        onConnectionWarning : false,
    };

    // build
    $.fn[_ns] = function(args) {

        var target          = this;
        var $target         = $(this);
        var options         = {};
        var connection      = false;
        var connection_id   = false;
        var connection_time = false;
        var thread          = false;


        if ($.type(options) !== 'object') {
            var options = {};
        }

        $.extend(true, options, defaults, args);

        // init
        function run(args) {

            var that = $(this);

            if (options.check_relay_on_startup == true) {
                
                getRelayHost({
                    onSuccess : function(host) {
                        console.log('Success Get Relay IP');
                        if (options.host != host)
                            reconnect(host);
                    }
                });
            } else {
                setTimeout(connect, 1000);
            }
            
            
            if (options.auto_reconnect == true){
                
                // important! set every second the connection_time!
                // the latest received clients-action sets the connecton_time.
                // if you connected not with mode: webui - you will not get the clients-action!
                // if no clients action received, the connection_timeout will try to reconnect
                // in this case you will be connected for the timeout time - dont be silly! :D
                thread = setInterval(
                    function(){

                        var now = parseInt((new Date).getTime()/1000);
                        var diff = now-connection_time;
                                                
                        if(diff<options.reconnect_timeout && diff>1){
                            if ($.type(options.onConnectionWarning) == 'function')
                                options.onConnectionWarning();
                        }
                        
                        if(diff==options.reconnect_timeout){
                            if ($.type(options.onReconnectTrigger) == 'function')
                                options.onReconnectTrigger();
                        }
                        
                        if((diff)>options.reconnect_timeout && diff%options.reconnect_time==1){
                            if ($.type(options.onReconnect) == 'function')
                                options.onReconnect();
                                
                            getRelayHost({
                                onSuccess : function(host) {
                                    console.log('Success Get Relay IP');
                                    reconnect(host);
                                }
                            });                           
                        }
                        
                    },options.thread_time*1000
                );
            }
            

        }

        /*
        * Functions
        *
        *
        *
        */
            
        //
        function getConnectionId(){
            return connection_id;
        }
        
        // Set Host
        function setHost(host) {
            options.host = host;
        }

        //Connect to Relay
        function connect() {
            console.log('Trying to connect: ' + options.host);
            var connection_url = "ws://" + options.host + ":" + options.port + "/" + options.mode + "=" + options.name;
            connection = new WebSocket(connection_url);

            connection.onopen = function(e) {
                
                if ($.type(options.onOpen) == 'function')
                    options.onOpen(e);
            };

            connection.onerror = function(error) {
                //alert(error);
            };

            connection.onclose = function(e) {
                console.log('Connection Closed');

                if ($.type(options.onClose) == 'function')
                    options.onClose(e);
                    
                connection_id = '';
            };

            connection.onmessage = function(e) {
                onMessage(e.data);
                
                if ($.type(options.onMessage) == 'function') {
                    options.onMessage(e.data);
                }
            };
        }

        // Close Connection
        function disconnect() {
            if ($.type(connection.close) == 'function')
                connection.close();
        }

        // Reconnect
        function reconnect(host) {
            disconnect();
            options.host = host;
            connect();
        }

        // Merge Settings
        function assumeSettings() {
            $.extend(true, options, args);
        }

        // internal on message
        // will be called BEFORE options.onMessage() 
        function onMessage(data) {
            var message = $.parseJSON(data);
            var action = message.action;
            
            
            // The Welcome Set.
            // The connection_id is the connection ID from the Relay 
            if (action == 'welcome')
                connection_id = message[action].id;
            
            // !important - that is the heartbeat!
            // every WebUI MUST TO RECEIVE the action: "clients"
            // with the clients list - every second.
            // if not, the reconnecting process will start
            // rs.sendToWebUI() in the relay sends data to all web-interfaces
            // the the mode of the connection to: "webui" - it's important!
            if (action == 'clients')
                connection_time = parseInt((new Date).getTime()/1000);
        }

        // get the relay ip from lighthouse
        // no internal on success or on message functions
        function getRelayHost(args) {
            console.log('Getting Relay IP');
            $.ajax({
                url : HOME_URL + 'monitor/getrelayip/' + options.relay_name,
                async : true,
                dataType : 'text',
                success : function(data) {
                    if ($.type(args.onSuccess) == 'function')
                        args.onSuccess(data);
                },
                error : function() {
                    if ($.type(args.onError) == 'function')
                        options.onLighthouseError();
                }
            });
        }
        
        // BANG!
        function sendAction(action){
            connection.send(JSON.stringify( {"action":action} ));
        }
        
        function sendActionData(action,data){
            var send_data = {};
            send_data['action'] = action;
            send_data[action] = data;
            
            var send_message = JSON.stringify( send_data );
            connection.send(send_message);
        }

        /*
         * The End ...
         */
        run(options);

        return {

            // some mapped functions to call from outside
            init : run,
            setHost : setHost,
            connect : connect,
            disconnect : disconnect,
            reconnect : reconnect,
            sendAction : sendAction,
            sendActionData : sendActionData,
            getConnectionId : getConnectionId
        };

    };

})(jQuery);

