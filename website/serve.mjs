/**
 * Poswal Orbit · Local Preview Server
 * Zero dependencies. Serves website/dist under /poswal-orbit/
 */

import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PORT = parseInt(process.env.PORT || '8080', 10);
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

server.listen(PORT, () => {
  console.log(`Poswal Orbit preview server running at http://localhost:${PORT}${BASE_PATH}`);
});
