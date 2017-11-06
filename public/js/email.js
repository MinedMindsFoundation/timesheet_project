// function sendMail() {
//     var link = "mailto:billyjacktattoos@gmail.com" +
//         "?cc=fakeemail@junkmail.com" +
//         "&subject=" + escape("subject") +
//         "&body=" + escape(document.getElementById('myText').value);

//     window.location.href = link;
// }


function sendemail() {
    var email = document.getElementById("emailID").value;
    var subject = ('PTO Request');
    var body = ('My permanent body contents');
    document.write('<a href="mailto:billyjacktattoos@gmail.com' + email + '?subject=' + subject + '&body=' + body + '">' + 'Click here to send email as well' + '<' + '/a>');
};

