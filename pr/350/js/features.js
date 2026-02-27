(function() {
  let html = document.querySelector("html");
  let sectbox = document.querySelector("#sectnum");
  sectbox.addEventListener("click", (event) => {
    if (sectbox.checked) {
      html.classList.remove("informal");
      html.classList.add("formal");
    } else {
      html.classList.remove("formal");
      html.classList.add("informal");
    }
  });
})();

