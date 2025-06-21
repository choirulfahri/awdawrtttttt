/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


<script type="module">
  // Import the functions you need from the SDKs you need
  import { initializeApp } from "https://www.gstatic.com/firebasejs/11.8.1/firebase-app.js";
  import { getAnalytics } from "https://www.gstatic.com/firebasejs/11.8.1/firebase-analytics.js";
  // TODO: Add SDKs for Firebase products that you want to use
  // https://firebase.google.com/docs/web/setup#available-libraries

  // Your web app's Firebase configuration
  // For Firebase JS SDK v7.20.0 and later, measurementId is optional
  const firebaseConfig = {
    apiKey: "AIzaSyDMuJltd444j3foWzfZBVZUKTSXhTIZL30",
    authDomain: "yuna-ec9e8.firebaseapp.com",
    projectId: "yuna-ec9e8",
    storageBucket: "yuna-ec9e8.firebasestorage.app",
    messagingSenderId: "1073558102975",
    appId: "1:1073558102975:web:c1111ba97470c0ee6e370a",
    measurementId: "G-67JRRHCGS3"
  };

  // Initialize Firebase
  const app = initializeApp(firebaseConfig);
  const analytics = getAnalytics(app);
  
  // Register user
    function register() {
      const email = document.getElementById('registerEmail').value;
      const password = document.getElementById('registerPassword').value;
      auth.createUserWithEmailAndPassword(email, password)
        .then((userCredential) => {
          document.getElementById('message').style.color = 'green';
          document.getElementById('message').innerText = 'Registration successful!';
        })
        .catch((error) => {
          document.getElementById('message').style.color = 'red';
          document.getElementById('message').innerText = error.message;
        });
    }

    // Login user
    function login() {
      const email = document.getElementById('loginEmail').value;
      const password = document.getElementById('loginPassword').value;
      auth.signInWithEmailAndPassword(email, password)
        .then((userCredential) => {
          document.getElementById('message').style.color = 'green';
          document.getElementById('message').innerText = 'Login successful!';
        })
        .catch((error) => {
          document.getElementById('message').style.color = 'red';
          document.getElementById('message').innerText = error.message;
        });
    }
</script>