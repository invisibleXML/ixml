(function() {
  // We put different buttons on the "ixml.xml" page and the "ixml.ixml" page
  let xml = !!document.querySelector(".toggle");

  // We use the same id on both pages
  let copyText = document.querySelector("#ixml").textContent;

  // Patch the toggle buttons
  let toggles = document.querySelector("#toggle-buttons");
  let html = toggles.innerHTML;
  if (xml) {
    toggles.innerHTML = "<div><a class='button' id='allopen' href='#'>All ▾</a>"
      + "<a class='button' id='allclose' href='#'>All ▸</a>"
      + "<a class='button' id='allremove' href='#'>Remove ▾/▸</a></div>";
  } else {
    toggles.innerHTML = "";
  }

  // Navigator.clipboard requires a localhost or https: connection
  if (navigator.clipboard) {
    toggles.innerHTML += "<div>"
      + "<span id='copyok'> </span>"
      + "<a class='button' id='copy' href='#'>Copy</a>"
      + html
      + "</div>";
  } else {
    toggles.innerHTML = html;
  }

  document.querySelector("#copy").addEventListener('click', (event) => {
    event.preventDefault();
    if (navigator.clipboard) {
      navigator.clipboard.writeText(copyText);
      let message = document.querySelector("#copyok");
      message.innerHTML = "✔ ";
      message.className = "visible";
      // Run this in a different thread...
      setTimeout(() => {
        message.className = "invisible";
      }, 500);
    }
  });
})();
