importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

// Initialize the Firebase app in the service worker by passing in the
// messagingSenderId.
firebase.initializeApp({
    apiKey: "AIzaSyAPTKN4wl3Tx30a7fuLcD0tnD8o0idLgsQ",
    authDomain: "copy-app-69a54.firebaseapp.com",
    projectId: "copy-app-69a54",
    storageBucket: "copy-app-69a54.appspot.com",
    messagingSenderId: "1056429481431",
    appId: "1:1056429481431:web:4bbd25bc81f7240aad3f92",
});

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
    console.log(
        "[firebase-messaging-sw.js] Received background message ",
        payload
    );
    // Customize notification here
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: "/icons/Icon-192.png",
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});
