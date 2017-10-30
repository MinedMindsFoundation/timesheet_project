// 233763446619-v5s4s15p0r210m8i60dfo4levl7aaoab.apps.googleusercontent.com

var googleUser = {};

var startApp = function() {
    gapi.load('auth2', function() {
        // Retrieve the singleton for the GoogleAuth library and set up the client.
        auth2 = gapi.auth2.init({
            client_id: '529014474103-64pofb78h79be0rblagq6cil53svu4qb.apps.googleusercontent.com',
            cookiepolicy: 'single_host_origin',
            // Request scopes in addition to 'profile' and 'email'
            //scope: 'additional_scope'
        });
        attachSignin(document.getElementById('google_btn'));
    });
};

function attachSignin(element) {
    // console.log(element.id);
    auth2.attachClickHandler(element, {},
        function(googleUser) {
            first_name = googleUser.getBasicProfile().getGivenName();
            last_name = googleUser.getBasicProfile().getFamilyName();
            email = googleUser.getBasicProfile().getEmail();
            avatarUrl = googleUser.getBasicProfile().getImageUrl();
            avatar = avatarUrl.replace("&", "****");
            console.log(googleUser.getBasicProfile().getGivenName());
            console.log(googleUser.getBasicProfile().getFamilyName());
            console.log(googleUser.getBasicProfile().getEmail());
            console.log(googleUser.getBasicProfile().getImageUrl());

            window.location = "/hidden_page?email=" + email + "&a=" + avatar;

        },
        function(error) {
            // alert(JSON.stringify(error, undefined, 2));
        });

};


startApp();

function signOut() {
    var auth2 = gapi.auth2.getAuthInstance();
    auth2.signOut().then(function() {
        console.log('User signed out.');
    });
}