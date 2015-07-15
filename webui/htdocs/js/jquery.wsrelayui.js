/**
 *  Websocket Relay UI
 *  Matthias Kallenbach | Berlin
 *  seekwhencer.de
 */

(function($) {

    var _ns = 'wsrelayui';

    var defaults = {

    };

    // build
    $.fn[_ns] = function(args) {

        var target = this;
        var $target = $(this);
        var options = {};
        var connections = {};
        var connection_id = false;

        if ($.type(options) !== 'object') {
            var options = {};
        }

        $.extend(true, options, defaults, args);

        //
        // Connection Stuff
        //
        var Conn = {

            is_in : function(id) {
                var ids = $.map(connections, function(element, index) {
                    return index;
                });
                for (var i = 0; i < ids.length; i++)
                    if (ids[i] == id)
                        return true;

                return false;
            }
        };

        //
        // Draw Stuff
        //
        var Draw = {

            welcome : function() {
               
            },

            warning : function(data) {
                var client_elm = $target.find("div[data-client-id='" + data.id + "']");
                var source_color = client_elm.css('color');
                client_elm.addClass('blink');
                this.playSFX('device_warning');
            },

            clients : function() {
                
                //this.playSFX('heartbeat');
                $('i.fa-heartbeat').removeClass('blink');
                
                // Add Monitor Block
                var wsrui_monitor = $target.find('.wsrui-monitor');
                if (wsrui_monitor.length == 0) {
                    $target.html('<div class="wsrui-monitor"></div>');
                    wsrui_monitor = $target.find('.wsrui-monitor');
                }

                // Process Client Rows
                for (var id in connections) {
                    var client_elm = $target.find("div[data-client-id='" + id + "']");
                    var html = '';
                    // Add Client Row
                    if (client_elm.length == 0) {

                        var style = connections[id].mode;
                        var options = '';

                        if (connection_id == id)
                            style += ' me';

                        if ((connections[id].mode == 'device' || connections[id].mode == 'webui') && connections[id].name != 'relaymonitor')
                            options += ' <button class="btn"><i class="fa fa-bars"></i></button> ';

                        html += '<div class="row-fluid client-row ' + style + '" data-client-id="' + id + '">';
                        html += '  <div class="col-xs-1 tac"><i class="fa fa-wifi"></i></div>';
                        html += '  <div class="col-xs-5 col-md-3">' + connections[id].name + '</div>';
                        html += '  <div class="col-xs-6 col-md-3 tar">' + connections[id].ip + '</div>';
                        html += '  <div class="col-xs-2 hidden-xs hidden-sm">' + connections[id].mode + '</div>';
                        html += '  <div class="col-xs-1 hidden-xs hidden-sm">' + connections[id].id + '</div>';
                        html += '  <div class="col-xs-2 options hidden-xs hidden-sm">' + options + '</div>';
                        html += '</div>';

                        $(wsrui_monitor).prepend(html);

                        //
                        if (connections[id].mode == 'device')
                            Draw.playSFX('device_new');
                            
                        if (connections[id].mode == 'webui')
                            Draw.playSFX('webui_new');
                        

                    } else {

                    }
                }

                // Process dropped Clients
                var rows = $target.find('.client-row');
                var ids = $.map(connections, function(element, index) {
                    return index;
                });
                
                for (var i = 0; i < rows.length; i++) {
                    var id = $(rows[i]).data('client-id');
                    if (!Conn.is_in(id) && id!=''){
                        Draw.removeClientRow(id);
                    }
                }

            },

            removeClientRow : function(id) {
                this.playSFX('device_lost');
                $target.find("div[data-client-id='" + id + "']").fadeOut(1000, function() {
                    $(this).remove();
                });
            },
            
            connection_warning : function(){
                $('i.fa-heartbeat').addClass('blink');
                Draw.playSFX('device_warning');  
            },
            
            reconnecting : function(){
                $target.html('<h1>disconnected...</h1><h1 class="blink">trying to reconnect!</h1>');
                $('i.fa-heartbeat').removeClass('blink');
                Draw.playSFX('reconnect'); 
            },
            
            

            playSFX : function(sfx) {

                var files = {
                    heartbeat : 'heartbeat.mp3',
                    device_new : 'device_new.mp3',
                    device_warning : 'device_warning.mp3',
                    device_lost : 'device_lost.mp3',
                    reconnect : 'reconnect.mp3',
                    webui_new : 'webui_new.mp3'
                };
                
                var audio_elm = $('#'+sfx);
                
                if(audio_elm.length==0){
                    $('body').prepend('<audio id="' + sfx + '"></audio>');
                    audio = $('#' + sfx)[0];
                    audio.src = 'sound/' + files[sfx];
                    audio.addEventListener('ended', function() {
                        $(this).remove();
                    });
                    audio.play();
                }
                
                

            }
        };

        // init
        function run(args) {
            var that = $(this);           
        }

        /*
        * Functions
        *
        *
        *
        */

        //
        function connected(e) {
            console.log('UI connected to: ' + e.target.url);
        }

        //
        function disconnected() {
            console.log('UI disconnect');
        }

        //
        function incoming(data) {
            //console.log('UI incoming message: '+data);
            var message = $.parseJSON(data);
            var action = message.action;

            if (action == 'welcome') {
                connection_id = message[action].id;
                Draw.welcome();
            }

            if (action == 'clients') {
                connections = message[action];
                Draw.clients();
            }

            if (action == 'warning-drop') {
                var data = message[action];
                Draw.warning(data);
            }

        }

        //
        function lighthouse_error() {
            console.log('UI Lighthouse not reachable.');
        }
        
        //
        function reconnecting(){
            Draw.reconnecting();
        }
        
        function reconnect_trigger(){
            Draw.playSFX('device_lost');
        }
        
        //
        function connection_warning(){
            Draw.connection_warning();
        }

        // Merge Settings
        function assumeSettings() {
            $.extend(true, options, args);
        }

        /*
         * The End ...
         */
        run(options);

        return {

            // some mapped functions to call from outside
            init : run,
            connected : connected,
            disconnected : disconnected,
            incoming : incoming,
            lighthouse_error : lighthouse_error,
            playSFX : Draw.playSFX,
            connection_warning : connection_warning,
            reconnecting : reconnecting,
            reconnect_trigger : reconnect_trigger
        };

    };

})(jQuery);

