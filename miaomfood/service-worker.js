const cacheAll = async (resources) => {
  const cache = await caches.open("v1");
  await cache.addAll(resources);
};

const cacheIn = async (request, response) => {
  const cache = await caches.open('v1');
  await cache.put(request, response);
};

const tryCache = async ({ request, preloadResponsePromise }) => {
  const responseFromCache = await caches.match(request);
  if (responseFromCache) {
    return responseFromCache;
  }

  const preloadResponse = await preloadResponsePromise;
  if (preloadResponse) {
    console.info('using preload response', preloadResponse);
    cacheIn(request, preloadResponse.clone());
    return preloadResponse;
  }

  try {
    const responseFromNetwork = await fetch(request);
    cacheIn(request, responseFromNetwork.clone());
    return responseFromNetwork;
  } catch (error) {
    return new Response('Network error happened', {
      status: 408,
      headers: { 'Content-Type': 'text/plain' },
    });
  }
};

const enableNavigationPreload = async () => {
  if (self.registration.navigationPreload) {
    await self.registration.navigationPreload.enable();
  }
};

self.addEventListener('install', (event) => {
  event.waitUntil(
    cacheAll([
    '/',
    '/campaign',
    '/page.css',
    '/app.js',
    ])
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(enableNavigationPreload());
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    tryCache({
      request: event.request,
      preloadResponsePromise: event.preloadResponse,
    })
  );
});