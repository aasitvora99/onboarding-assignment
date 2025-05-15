import http from 'http';
import path from 'path';
import fs from 'fs';

const PORT = 8080;
const __dirname = path.resolve();

const server = http.createServer();

server.on('request', (req, res) => {
  const { method, url } = req;

  if (method === 'GET' && url === '/log') {
    const stream = fs.createReadStream(path.join(__dirname, 'index.html'));
    stream.on('error', function() {
        res.writeHead(404);
        res.end();
    });
    stream.pipe(res);
  } else {
    res.end('Not Found');
  }
});

server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}/`);
});