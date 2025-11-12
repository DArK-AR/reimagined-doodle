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
