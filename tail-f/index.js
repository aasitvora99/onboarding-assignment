import http from 'http';
import fs from 'fs';
import path from 'path';

const PORT = 8080;
const __dirname = path.resolve();
const htmlFilePath = path.join(__dirname, 'index.html');

const server = http.createServer();

server.on('request', (req, res) => {
  const { method, url } = req;

  if (method === 'GET' && url === '/log') {
    res.writeHead(200, { 'Content-Type':  'text/html' });
    res.end(htmlFilePath);
  } else {
    res.end('Not Found');
  }
});

server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}/`);
});