// Passaí — PWA Service Worker Oficial de Alta Performance
// Garante atualização instantânea a cada deploy, conformidade PWA e cache offline resiliente.

const CACHE_NAME = 'passai-pwa-1.0.20260929111022';
const PRECACHE_ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './favicon.png',
  './icons/Icon-logo.webp',
  './icons/Icon-192.png',
  './icons/Icon-512.png',
  './icons/Icon-maskable-192.png',
  './icons/Icon-maskable-512.png'
];

// Instalação do Service Worker e pré-cache de ativos essenciais
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(PRECACHE_ASSETS);
    }).catch((err) => {
      console.warn('[Passaí SW] Falha no pré-cache:', err);
    })
  );
  // Força ativação imediata sem esperar o fechamento de abas
  self.skipWaiting();
});

// Ativação e limpeza completa de todos os caches de builds anteriores
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.filter((key) => key !== CACHE_NAME).map((key) => {
          console.log('[Passaí SW] Purgando cache antigo:', key);
          return caches.delete(key);
        })
      );
    }).then(() => self.clients.claim())
  );
});

// Escuta mensagem do cliente para ativação imediata sob demanda
self.addEventListener('message', (event) => {
  if (event.data && (event.data === 'skipWaiting' || event.data.action === 'skipWaiting')) {
    self.skipWaiting();
  }
});

// Interceptação de requisições:
// 1. Arquivos dinâmicos/críticos (index.html, flutter_bootstrap.js, version.json, rotas) -> Network-First
// 2. Arquivos estáticos imutáveis (canvaskit, fonts, wasm, images, main.dart.js com hash) -> Cache-First
// 3. APIs externas (Supabase, etc) -> Network pura
self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;

  const url = new URL(event.request.url);

  // Não interferir em APIs externas (Supabase, Vercel Insights, Google Fonts CDN)
  if (url.origin !== self.location.origin) {
    return;
  }

  const pathname = url.pathname;

  // Arquivos que NUNCA devem ser Cache-First porque determinam a versão do app
  const isBootstrapOrMetadata =
    pathname.endsWith('flutter_bootstrap.js') ||
    pathname.endsWith('version.json') ||
    pathname.endsWith('index.html') ||
    pathname.endsWith('sw.js') ||
    pathname === '/' ||
    event.request.mode === 'navigate';

  if (isBootstrapOrMetadata) {
    // Estratégia Network-First: sempre busca a versão mais recente na rede
    event.respondWith(
      fetch(event.request)
        .then((networkResponse) => {
          if (networkResponse && networkResponse.status === 200) {
            const responseToCache = networkResponse.clone();
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(event.request, responseToCache);
            });
          }
          return networkResponse;
        })
        .catch(async () => {
          // Fallback offline se a rede falhar
          const cachedResponse = await caches.match(event.request);
          if (cachedResponse) {
            return cachedResponse;
          }
          if (event.request.mode === 'navigate') {
            const indexCached = (await caches.match('./index.html')) || (await caches.match('./'));
            if (indexCached) {
              return indexCached;
            }
          }
          return new Response('Sem conexão com a internet', {
            status: 503,
            statusText: 'Service Unavailable',
            headers: { 'Content-Type': 'text/plain; charset=utf-8' }
          });
        })
    );
    return;
  }

  // Identifica se é um asset estático (imagens, fontes, canvaskit, scripts compilados)
  const isStaticAsset =
    pathname.endsWith('.js') ||
    pathname.endsWith('.wasm') ||
    pathname.endsWith('.ttf') ||
    pathname.endsWith('.otf') ||
    pathname.endsWith('.woff') ||
    pathname.endsWith('.woff2') ||
    pathname.endsWith('.png') ||
    pathname.endsWith('.jpg') ||
    pathname.endsWith('.jpeg') ||
    pathname.endsWith('.svg') ||
    pathname.endsWith('.ico') ||
    pathname.endsWith('.json') ||
    pathname.includes('/canvaskit/') ||
    pathname.includes('/assets/') ||
    pathname.includes('/icons/');

  if (isStaticAsset) {
    event.respondWith(
      caches.match(event.request).then((cachedResponse) => {
        if (cachedResponse) {
          return cachedResponse;
        }

        return fetch(event.request).then((networkResponse) => {
          if (networkResponse && networkResponse.status === 200) {
            const responseToCache = networkResponse.clone();
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(event.request, responseToCache);
            });
          }
          return networkResponse;
        });
      })
    );
  }
});
