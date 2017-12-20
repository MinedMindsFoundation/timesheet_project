function gitSignOn(git_id){ 
    console.log("signing in with github")
    window.location = 'https://github.com/login/oauth/authorize?scopes=user&client_id='+ git_id;
};
// Get the authorization code from the url that was returned by GitHub

var authCode = getAuthCode(window.location.href);

// Extract the auth code from the original URL

function getAuthCode(url){
    var error = url.match(/[&\?]error=([^&]+)/);
    if (error) {
        throw 'Error getting authorization code: ' + error[1];
    }
    return url.match(/[&\?]code=([\w\/\-]+)/)[1];
}
