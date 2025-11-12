importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyBW5fiV4iELyylY2map9cUg4fBBguOkodQ",
  authDomain: "demonpay.firebaseapp.com",
  projectId: "demonpay",
  storageBucket: "demonpay.firebasestorage.app",
  messagingSenderId: "877170767007",
  appId: "1:877170767007:web:f6449f73ef6843fecf1eaa"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(multicastMessage) {
  console.log("Received background message", multicastMessage);

  const notificationTitle = multicastMessage.notification.title;
  const notificationOptions = {
    body: multicastMessage.notification.body,
    icon: "icon.png"
  };

  self.registration.showNotification(notificationTitle, notificationOptions);

});

// Handle notification click
self.addEventListener("notificationclick", function(event) {
  console.log("Notification click:", event.notification.data);
  event.notification.close();

  event.waitUntil( 
    clients.matchAll({typeof: "window", includeUncontrolled: true}).then(function(clientList) {
      for (client of clientList) {
        if ("focus" in client) {
          client.postMessage(event.notification.data);
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow("/");
      }
    })
  )
})