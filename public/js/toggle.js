function admin_toggle(admin) {
    var x = Document.getElementById("admin_div");
    if (admin === "Y" || admin === "y") {
        x.style.display = "none";
    } else {
        x.style.display = "block";
    }
}