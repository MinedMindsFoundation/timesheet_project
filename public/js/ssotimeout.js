
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

    function ssolog_out() {
        // logout();
        // signOut();
        window.location.href = '/';  //Adapt to actual logout script
    }

   function reload() {
          window.location = self.location.href;  //Reloads the current page
   }

    function ssomyFunction() {
       var x = document.getElementById("timeout");
       var y = "you will be logged out for inactivity in 1 minute";
       x.innerHTML = y;
    }

    function ssomessagereset() {
        var x = document.getElementById("timeout");
        x.innerHTML = "";
    }

   function ssoresetTimer() {
        clearTimeout(l,k);
        messagereset();
        a = setTimeout(ssomyFunction, 120000); // this is for the alert
        t = setTimeout(ssolog_out, 180000);  // time is in milliseconds (1000 is 1 second), time out log out
       // t= setTimeout(reload, 60000);  // time is in milliseconds (1000 is 1 second), i dont use this one
    }
}
ssoidleTimer();