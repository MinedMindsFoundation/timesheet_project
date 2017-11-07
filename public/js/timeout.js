


// social section
function idleTimer() {
    var t;
    var a;
    //window.onload = resetTimer;
    window.onmousemove = resetTimer; // catches mouse movements
    window.onmousedown = resetTimer; // catches mouse movements
    window.onclick = resetTimer;     // catches mouse clicks
    window.onscroll = resetTimer;    // catches scrolling
    window.onkeypress = resetTimer;  //catches keyboard actions

    function log_out() {
        logout();
        signOut();
        window.location.href = '/';  //Adapt to actual logout script
    }

   function reload() {
          window.location = self.location.href;  //Reloads the current page
   }

    function myFunction() {
       var x = document.getElementById("timeout");
       var y = "you will be logged out for inactivity in 1 minute";
       x.innerHTML = y;
    }

    function messagereset() {
        var x = document.getElementById("timeout");
        x.innerHTML = "";
    }

   function resetTimer() {
        clearTimeout(t,a);
        messagereset();
        a = setTimeout(myFunction, 120000); // this is for the alert
        t = setTimeout(log_out, 180000);  // time is in milliseconds (1000 is 1 second), time out log out
       // t= setTimeout(reload, 60000);  // time is in milliseconds (1000 is 1 second), i dont use this one
    }
}
idleTimer();
//--------------------------------------------------------------------------------------------------------------------

// sso section
function ssoidleTimer() {
    var l;
    var k;
    //window.onload = resetTimer;
    window.onmousemove = resetTimer; // catches mouse movements
    window.onmousedown = resetTimer; // catches mouse movements
    window.onclick = resetTimer;     // catches mouse clicks
    window.onscroll = resetTimer;    // catches scrolling
    window.onkeypress = resetTimer;  //catches keyboard actions

    function log_out() {
        // logout();
        // signOut();
        window.location.href = '/';  //Adapt to actual logout script
    }

   function reload() {
          window.location = self.location.href;  //Reloads the current page
   }

    function myFunction() {
       var x = document.getElementById("timeout");
       var y = "you will be logged out for inactivity in 1 minute";
       x.innerHTML = y;
    }

    function messagereset() {
        var x = document.getElementById("timeout");
        x.innerHTML = "";
    }

   function resetTimer() {
        clearTimeout(l,k);
        messagereset();
        a = setTimeout(myFunction, 120000); // this is for the alert
        t = setTimeout(log_out, 180000);  // time is in milliseconds (1000 is 1 second), time out log out
       // t= setTimeout(reload, 60000);  // time is in milliseconds (1000 is 1 second), i dont use this one
    }
}
ssoidleTimer();