window.fbAsyncInit = function() {
    FB.init({
        appId: '918081261676108', // Set YOUR APP ID
        channelUrl: '', // Channel File
        status: true, // check login status
        cookie: true, // enable cookies to allow the server to access the session
        xfbml: true // parse XFBML
    });
    FB.Event.subscribe('auth.authResponseChange', function(response) {
        if (response.status === 'connected') {
            // document.getElementById("message").innerHTML +=  "<br>Connected to Facebook";
            // console.log("Connected to Facebook");
                           getUserInfo();

            // SUCCESS
        } else if (response.status === 'not_authorized') {
            // document.getElementById("message").innerHTML += "<br>Failed to Connect";
            // FAILED
        } else {
            // document.getElementById("message").innerHTML += "<br>Logged Out";
            // // UNKNOWN ERROR
        }
    });
    
};
function work() {
    alert("fired");

}

function fbLogin() {
    FB.login(function(response) {
        if (response.authResponse) {
            FB.api('/me?fields=first_name,last_name,email,id, picture', function(response) {
                console.log(response.first_name);
                console.log(response.last_name);
                console.log(response.email);
                console.log(response.id);
                console.log(response.picture);
                var first_name = response.first_name;
                var last_name = response.last_name;
                var email = response.email;
                var avatarUrl = response.picture.data.url;
                var avatar = avatarUrl.replace("&", "****");
                var fb_id = response.id;
                document.getElementById('first_name').value = first_name;
                document.getElementById('last_name').value = last_name;
                document.getElementById('email').value = email;
                document.getElementById('fb_id').value = fb_id;
                document.getElementById("myform").submit(); // added to submit the page
                
                
                window.location = "/to_landing";
            });
            
            
        } else {
            console.log('User cancelled login or did not fully authorize.');
        }
    }, { scope: 'public_profile, email' });
    getUserInfo();
    
};

// function FBLogin2() {
//     FB.login(function(response) {
//         if (response.authResponse) {
//             FB.api('/me?fields=first_name,last_name,email,id', function(response) {
//                 console.log(response.first_name);
//                 console.log(response.last_name);
//                 console.log(response.email);
//                 console.log(response.id);
//                 var first_name = response.first_name;
//                 var last_name = response.last_name;
//                 var email = response.email;
//                 email = response.email;
//                                    var fb_id = response.id;
//                                    document.getElementById('first_name').value = first_name;
//                                    document.getElementById('last_name').value = last_name;
//                                    document.getElementById('email').value = email;
//                                    document.getElementById('fb_id').value = fb_id;
//                 window.location = "/login";

//             });


//         } else {
//             console.log('User cancelled login or did not fully authorize.');
//         }
//     }, { scope: 'public_profile, email' });
   
// }

   function getUserInfo() {
       FB.api('/me?fields=id, first_name, last_name, email', function(response){
        //    alert(response.first_name + " " + response.last_name + " " + response.email + " " + response.id);
           var first_name = response.first_name,
                   last_name = response.last_name,
                   email = response.email;

           document.getElementById('email').value = email;
           document.getElementById('first_name').value = first_name;
           document.getElementById('last_name').value = last_name;
           document.getElementById("myform").submit(); // added to submit the page
       });
   }
   function getPhoto()
   {
       FB.api('/me/picture?type=normal', function(response) {
           var str="<br/><b>Pic</b> : <img src='"+response.data.url+"'/>";
           document.getElementById("status").innerHTML+=str;
       });
   };


function logout(){
    FB.getLoginStatus(function(response) {
        if (response.status === 'connected') {
          // the user is logged in and has authenticated your
          // app, and response.authResponse supplies
          // the user's ID, a valid access token, a signed
          // request, and the time the access token 
          // and signed request each expire
          var uid = response.authResponse.userID;
          var accessToken = response.authResponse.accessToken;
            FB.logout(function(response) {
                // Person is now logged out
            });
            console.log('User signed out facebook.');
        } else if (response.status === 'not_authorized') {
          // the user is logged in to Facebook, 
          // but has not authenticated your app
        } else {
          // the user isn't logged in to Facebook.
        }
    });
}
// Load the SDK asynchronously
(function(d) {
    var js, id = 'facebook-jssdk',
        ref = d.getElementsByTagName('script')[0];
    if (d.getElementById(id)) { return; }
    js = d.createElement('script');
    js.id = id;
    js.async = true;
    js.src = "https://connect.facebook.net/en_US/all.js";
    ref.parentNode.insertBefore(js, ref);
}(document));


