import http from 'http';

const PORT = 8080;

const server = http.createServer();

server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}/`);
});