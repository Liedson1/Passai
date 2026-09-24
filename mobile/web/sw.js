// Passaí — PWA Service Worker Oficial de Alta Performance
// Garante conformidade com critérios de instalabilidade PWA do Chromium (Chrome/Edge/Android/iOS)
// e desempenho instantâneo com estratégia Cache-First para assets estáticos locais do Flutter.

const CACHE_NAME = 'passai-pwa-v16';
const PRECACHE_ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './favicon.png',
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
  self.skipWaiting();
});

// Ativação e limpeza de caches obsoletos
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
      );
    }).then(() => self.clients.claim())
  );
});

// Interceptação de requisições:
// 1. Static Assets (Wasm, JS, Fontes TTF/OTF, Imagens, JSON) -> Cache-First:
//    Retorna imediatamente do cache (0ms), eliminando travamentos de rede e gargalos de IPC.
// 2. Navegação / HTML -> Network-First com fallback para cache offline.
// 3. Supabase / APIs Externas -> Não intercepta (Network pura).
self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;

  const url = new URL(event.request.url);

  // Não interferir em APIs externas (Supabase, Vercel Insights, Google Fonts CDN)
  if (url.origin !== self.location.origin) {
    return;
  }

  // Identifica se é um asset estático do Flutter ou da aplicação
  const pathname = url.pathname;
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

  // Estratégia Cache-First para recursos estáticos:
  // Se já estiver em cache, serve instantaneamente sem requisição de rede.
  // Se não estiver, busca na rede, armazena no cache e retorna.
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
    return;
  }

  // Estratégia Network-First para documentos e páginas de navegação:
  // Tenta obter o HTML mais atualizado; em caso de falha ou offline, usa a casca em cache.
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
        const cachedResponse = await caches.match(event.request);
        if (cachedResponse) {
          return cachedResponse;
        }

        if (event.request.mode === 'navigate') {
          const indexCached = await caches.match('./index.html') || await caches.match('./');
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
});
