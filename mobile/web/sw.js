// Passaí — PWA Service Worker Oficial
// Garante conformidade com critérios de instalabilidade PWA do Chromium (Chrome/Edge/Android)
// e resiliência offline para o shell da aplicação.

const CACHE_NAME = 'passai-pwa-v1';
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
// - Requisições da aplicação usam Network-First para garantir que novas versões e dados do Supabase
//   sejam sempre servidos em tempo real.
// - Em caso de perda de conexão (offline), recorre ao cache local de assets estáticos e da casca da página.
self.addEventListener('fetch', (event) => {
  // Apenas métodos GET são cacheados
  if (event.request.method !== 'GET') return;

  const url = new URL(event.request.url);

  // Não interferir em APIs externas (Supabase, Vercel Insights, Google Fonts CDN)
  if (url.origin !== self.location.origin) {
    return;
  }

  event.respondWith(
    fetch(event.request)
      .then((networkResponse) => {
        // Cacheia dinamicamente apenas recursos estáticos locais (ícones, manifest, imagens)
        if (
          networkResponse &&
          networkResponse.status === 200 &&
          (url.pathname.startsWith('/icons/') ||
           url.pathname.endsWith('.png') ||
           url.pathname.endsWith('.svg') ||
           url.pathname.endsWith('manifest.json'))
        ) {
          const responseToCache = networkResponse.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseToCache);
          });
        }
        return networkResponse;
      })
      .catch(async () => {
        // Fallback offline
        const cachedResponse = await caches.match(event.request);
        if (cachedResponse) {
          return cachedResponse;
        }

        // Se for navegação de rota/página e estiver offline, retorna o index.html em cache
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
