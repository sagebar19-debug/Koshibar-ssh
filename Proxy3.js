/*
 * KOSHIBAR SSH - Proxy Bridge
 * Based on Proxy Bridge by PANCHO7532 - P7COMUnications LLC (c) 2021
 */

const crypto = require("crypto");
const net = require("net");

const dhost = process.env.DHOST || "127.0.0.1";
const dport = Number(process.env.DPORT || 22);
const mainPort = Number(process.env.PORT || 8080);
const packetsToSkip = Number(process.env.PACKSKIP || 1);

let gcwarn = true;

function gcollector() {
    if (!global.gc && gcwarn) {
        console.log("[WARNING] Garbage Collector isn't enabled.");
        gcwarn = false;
        return;
    }

    if (global.gc) {
        global.gc();
    }
}

setInterval(gcollector, 1000);

const server = net.createServer();

server.on("connection", function(socket) {
    let packetCount = 0;

    console.log(
        "[INFO] Connection received from " +
        socket.remoteAddress +
        ":" +
        socket.remotePort
    );

    socket.write(
        "HTTP/1.1 101 vip7 Protocols\r\n" +
        "Connection: Upgrade\r\n" +
        "Date: " + new Date().toUTCString() + "\r\n" +
        "Sec-WebSocket-Accept: " +
        Buffer.from(crypto.randomBytes(20)).toString("base64") +
        "\r\n" +
        "Upgrade: websocket\r\n" +
        "Server: koshibar-ssh/1.0\r\n" +
        "\r\n"
    );

    const conn = net.createConnection({
        host: dhost,
        port: dport
    });

    socket.on("data", function(data) {
        if (packetCount < packetsToSkip) {
            packetCount++;
            return;
        }

        conn.write(data);
        packetCount = packetsToSkip;
    });

    conn.on("data", function(data) {
        socket.write(data);
    });

    socket.on("error", function(error) {
        console.log("[SOCKET] " + error);
        conn.destroy();
    });

    conn.on("error", function(error) {
        console.log("[REMOTE] " + error);
        socket.destroy();
    });

    socket.on("close", function() {
        console.log(
            "[INFO] Connection terminated for " +
            socket.remoteAddress +
            ":" +
            socket.remotePort
        );

        conn.destroy();
    });

    conn.on("close", function() {
        socket.destroy();
    });
});

server.on("error", function(error) {
    console.error("[SERVER] " + error);
});

server.listen(mainPort, "0.0.0.0", function() {
    console.log("[INFO] KOSHIBAR SSH Proxy started");
    console.log("[INFO] Listening on: " + mainPort);
    console.log("[INFO] Redirecting to: " + dhost + ":" + dport);
});
