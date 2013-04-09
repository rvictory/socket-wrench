// socketwrench.js - client side library for SocketWrench server
"use strict";

var SocketWrench = {
    create : function (host, port, protocol) {
        var ws = new WebSocket("ws://" + host + ":" + port + "/" + protocol),
            obj = {
            commands : {},
            onmessage : function (message) {
                var messageData = JSON.parse(message.data);
                var callbacks = this.commands[messageData.command];
                if (callbacks) {
                    for (var i = 0; i < callbacks.length; i++) {
                        callbacks[i](messageData.data);
                    }
                }
            },
            onclose : null,
            on : function (command, callback) {
                this.commands[command] = this.commands[command] || [];
                this.commands[command].push(callback);
            },
            off : function (command, callback) {
                if (callback) {
                    //Need to search through command array and remove the callback
                } else {
                    this.commands[command] = [];
                }
            },
            send : function (command, data) {
                ws.send(JSON.stringify({command : command, data : data}));
            },
            close : function () {
                ws.close();
            },
            isOpen : function () {

            },
            isClosed : function () {

            }
        }
        ws.onmessage = function (data) {
            obj.onmessage(data);
        }
        ws.onclose = function () {
            if (obj.onclose) {
                obj.onclose();
            }
        }
        return obj;
    }
};
