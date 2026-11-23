/**
 * Poswal Orbit · Local Preview Server
 * Zero dependencies. Serves website/dist under /poswal-orbit/
 */

import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Command line argument parser
const args = process.argv.slice(2);
let HOST = '127.0.0.1';
let PORT = parseInt(process.env.PORT || '8080', 10);

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--host' && args[i + 1]) {
    HOST = args[i + 1];
    i++;
  } else if (args[i] === '--port' && args[i + 1]) {
    PORT = parseInt(args[i + 1], 10);
    i++;
  }
}

if (process.env.HOST) {
  HOST = process.env.HOST;
}

const DIST_DIR = path.join(__dirname, 'dist');
const BASE_PATH = '/poswal-orbit/';

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.woff2': 'font/woff2',
  '.txt': 'text/plain; charset=utf-8',
  '.xml': 'application/xml; charset=utf-8',
  '.webmanifest': 'application/manifest+json; charset=utf-8'
};

function getLocalIp() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }
  return '127.0.0.1';
}

const server = http.createServer((req, res) => {
  let reqUrl = req.url || '/';
  // Strip query strings
  reqUrl = reqUrl.split('?')[0];

  if (!reqUrl.startsWith(BASE_PATH)) {
    if (reqUrl === '/' || reqUrl === '') {
      res.writeHead(302, { Location: BASE_PATH });
      return res.end();
    }
    res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
    return res.end('Not Found. Poswal Orbit is served under /poswal-orbit/');
  }

  let subPath = reqUrl.slice(BASE_PATH.length);
  if (subPath.endsWith('/')) {
    subPath += 'index.html';
  } else if (!path.extname(subPath)) {
    // Check if directory exists
    const potentialDir = path.join(DIST_DIR, subPath);
    if (fs.existsSync(potentialDir) && fs.statSync(potentialDir).isDirectory()) {
      res.writeHead(302, { Location: reqUrl + '/' });
      return res.end();
    }
    subPath += '.html';
  }

  const filePath = path.join(DIST_DIR, subPath);

  if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
    const errorPage = path.join(DIST_DIR, '404.html');
    if (fs.existsSync(errorPage)) {
      res.writeHead(404, { 'Content-Type': 'text/html; charset=utf-8' });
      return res.end(fs.readFileSync(errorPage));
    }
    res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
    return res.end('404 Not Found');
  }

  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';

  res.writeHead(200, {
    'Content-Type': contentType,
    'Cache-Control': 'no-cache',
    'X-Content-Type-Options': 'nosniff'
  });

  const stream = fs.createReadStream(filePath);
  stream.pipe(res);
});

server.listen(PORT, HOST, () => {
  if (HOST === '0.0.0.0') {
    const lanIp = getLocalIp();
    console.log(`\n⚠️  WARNING: Server is bound to 0.0.0.0, exposing it to your local Wi-Fi network.`);
    console.log(`Local URL:   http://localhost:${PORT}${BASE_PATH}`);
    console.log(`Network URL: http://${lanIp}:${PORT}${BASE_PATH}\n`);
  } else {
    console.log(`\nPoswal Orbit preview server running at http://${HOST}:${PORT}${BASE_PATH}`);
    console.log(`(Bound to localhost only. To preview on phone over Wi-Fi, run: node website/serve.mjs --host 0.0.0.0)\n`);
  }
});
