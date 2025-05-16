import http from 'http';
import path from 'path';
import fs from 'fs';
import { initSocket } from './sock.js';
import { Server } from 'socket.io';

const PORT = process.env.PORT || 8080;
const __dirname = path.resolve();

const server = http.createServer((req, res) => {
  const { method, url } = req;

  if (method === 'GET' && url === '/log') {
    const stream = fs.createReadStream(path.join(__dirname + '/views/index.html'));
    stream.on('error', function() {
        res.writeHead(404);
        res.end();
    });
    stream.pipe(res);
  } else if (method === 'GET' && url === '/client.js') {
    const stream = fs.createReadStream(path.join(__dirname + '/views/client.js'));
    stream.on('error', function() {
        res.writeHead(404);
        res.end();
    });
    res.setHeader('Content-Type', 'application/javascript');
    stream.pipe(res);
  } else if (method === 'GET' && url === '/socket.io/socket.io.js') {
    // Let socket.io handle this request
    // Do nothing, socket.io will serve its own client
  } else {
    res.writeHead(404);
    res.end('Not Found');
  }
});

const io = new Server(server);
initSocket(io);

server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}/`);
});