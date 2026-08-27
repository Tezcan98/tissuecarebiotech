'use strict';
const http = require('http');
const { spawn } = require('child_process');

const PORT = process.env.PORT || 8091;
// info@tissuecarebiotech.com sunucudaki yerel bir Postfix alias'ı
// (/etc/postfix/virtual) üzerinden farklı bir yerel kutuya düşüyor,
// gerçekte okunan Gmail hesabına ulaşmıyor. O yüzden gerçekten
// okunan adrese gönderiyoruz; From başlığı yine info@ görünür.
const TO = 'tissuecarebiotech@gmail.com';
const FROM = 'info@tissuecarebiotech.com';
const SENDMAIL = '/usr/sbin/sendmail';

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) && !/[\r\n]/.test(email);
}

function sendMail(subject, body, replyTo) {
  return new Promise((resolve, reject) => {
    const encodedSubject = `=?UTF-8?B?${Buffer.from(subject, 'utf8').toString('base64')}?=`;
    const headers =
      `From: Tissuecare Web Sitesi <${FROM}>\r\n` +
      `To: ${TO}\r\n` +
      `Reply-To: ${replyTo}\r\n` +
      `Subject: ${encodedSubject}\r\n` +
      `Content-Type: text/plain; charset=UTF-8\r\n\r\n`;

    const proc = spawn(SENDMAIL, ['-t']);
    let stderr = '';
    proc.stderr.on('data', (chunk) => { stderr += chunk; });
    proc.on('error', reject);
    proc.on('close', (code) => {
      if (code === 0) resolve();
      else reject(new Error(`sendmail exited ${code}: ${stderr}`));
    });
    proc.stdin.write(headers + body);
    proc.stdin.end();
  });
}

function sendJson(res, status, payload) {
  res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(payload));
}

const server = http.createServer((req, res) => {
  if (req.method !== 'POST' || req.url !== '/contact-handler') {
    sendJson(res, 404, { ok: false, error: 'not_found' });
    return;
  }

  let raw = '';
  req.on('data', (chunk) => {
    raw += chunk;
    if (raw.length > 20000) req.destroy();
  });

  req.on('end', async () => {
    let data;
    try {
      data = JSON.parse(raw);
    } catch {
      sendJson(res, 400, { ok: false, error: 'invalid_json' });
      return;
    }

    // Honeypot: botlar bu alanı doldurur, gerçek ziyaretçiler görmez.
    if (typeof data.website === 'string' && data.website.trim() !== '') {
      sendJson(res, 200, { ok: true });
      return;
    }

    const name = String(data.name || '').trim();
    const institution = String(data.institution || '').trim();
    const email = String(data.email || '').trim();
    const subject = String(data.subject || '').trim();
    const message = String(data.message || '').trim();

    if (!name || !isValidEmail(email)) {
      sendJson(res, 422, { ok: false, error: 'invalid_input' });
      return;
    }

    const body =
      `Sitedeki iletişim formundan yeni bir mesaj geldi.\n\n` +
      `Ad Soyad: ${name}\n` +
      `Kurum: ${institution || '-'}\n` +
      `E-posta: ${email}\n` +
      `Konu: ${subject || '-'}\n\n` +
      `Mesaj:\n${message}\n`;

    try {
      await sendMail(`Site: ${subject || 'Yeni mesaj'}`, body, email);
      sendJson(res, 200, { ok: true });
    } catch (err) {
      console.error(err);
      sendJson(res, 502, { ok: false, error: 'send_failed' });
    }
  });
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`contact-handler listening on 127.0.0.1:${PORT}`);
});
