(function() {
  const spaces = "                                        ";
  let ignoreEvents = false;

  function toggleChildren(event, toggle) {
    const open = toggle.querySelector(".open");
    const close = toggle.querySelector(".close");

    const node = toggle.parentNode;
    const dots = node.querySelector(".dots");
    const children = node.querySelector(".children");

    if (open.style.display === "none") {
      const indent = parseInt(dots.getAttribute("x-indent"), 10) + 4;
      close.style.display = "none";
      open.style.display = "inline-block";
      children.style.display = "none";
      dots.innerHTML = spaces.substring(0, indent) + "⸱⸱⸱" + "\n";
    } else {
      open.style.display = "none";
      close.style.display = "inline-block";
      dots.innerHTML = "";
      children.style.display = "inline";
    }
  }

  document.querySelectorAll(".toggle").forEach(toggle => {
    const open = toggle.querySelector(".open");
    const close = toggle.querySelector(".close");

    open.style.display = "none";
    open.innerHTML = "▸";

    close.style.display = "inline-block";
    close.innerHTML = "▾";

    toggle.addEventListener("click", (event) => {
      event.preventDefault();
      if (!ignoreEvents) {
        toggleChildren(event, toggle);
      }
    });
  });

  document.querySelectorAll(".space").forEach(space => {
    space.style.display = "inline";
    space.innerHTML = " ";
  });

  // These buttons are added by buttons.js
  document.querySelector("#allopen").addEventListener('click', (event) => {
    event.preventDefault();
    document.querySelectorAll(".toggle").forEach(toggle => {
      if (toggle.querySelector(".close").style.display === "none") {
        toggleChildren(event, toggle);
      }
    });
  });

  document.querySelector("#allclose").addEventListener('click', (event) => {
    event.preventDefault();
    document.querySelectorAll(".toggle").forEach(toggle => {
      if (toggle.querySelector(".open").style.display === "none") {
        toggleChildren(event, toggle);
      }
    });
  });

  document.querySelector("#allremove").addEventListener('click', (event) => {
    ignoreEvents = true;
    document.querySelectorAll(".toggle").forEach(toggle => {
      const open = toggle.querySelector(".open");
      const close = toggle.querySelector(".close");
      
      if (toggle.querySelector(".close").style.display === "none") {
        toggleChildren(event, toggle);
      }

      open.style.display = "none";
      close.style.display = "none";
    });

    document.querySelectorAll(".space").forEach(space => {
      space.style.display = "none";
    });

    document.querySelector("#toggle-buttons").style.display = "none";
  });
})();
