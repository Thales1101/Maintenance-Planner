// Maintenance Planner — lets the browser show notifications (needed on Android) and
// brings the app to the front when a notification is tapped. Nothing is cached.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', e => e.waitUntil(self.clients.claim()));
self.addEventListener('notificationclick', e => {
  e.notification.close();
  const go = (e.notification.data && e.notification.data.mpGo) || null;
  e.waitUntil((async () => {
    const list = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    const c = list[0];
    if (c) { await c.focus(); c.postMessage({ mpGo: go }); }
    else await self.clients.openWindow('./');
  })());
});
