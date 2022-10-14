window.onload = function() {
  document.querySelector("html").className = "js";

  // Work out the protocol and hostname of our source...
  let location = window.location.href;
  let webroot = "";
  let pos = location.indexOf("//");
  webroot = location.substring(0, pos+2);
  location = location.substring(pos+2);
  pos = location.indexOf("/");
  if (pos > 0) {
    webroot += location.substring(0, pos);
  } else {
    webroot += location;
  }

  // Caching of resources in the browser is a real pain.
  // Make sure they get reloaded at least once a day.
  // If this is localhost, every time.
  let uid = new Date().toString();
  if (webroot.indexOf("localhost") > 0) {
    uid = new Date().getTime();
  }

  const configJson = `${webroot}/dashboard/dashboard.json?ts=${uid}`;
  SaxonJS.getResource({"location": configJson,
                       "type": "json"})
    .then(config => {
      SaxonJS.transform({
        "stylesheetLocation": `dashboard.sef.json?ts=${uid}`,
        "initialTemplate": "Q{}main",
        "stylesheetParams": {
          "Q{}config": config
        }
      }, "async");
    })
    .catch(err => {
      // There's a fair bit of config here where we could in principle
      // get the information from the GitHub API. Unfortunately, that
      // API is rate limited and for non-logged-in users, it's easy to
      // go over the limit. (Perhaps someday I'll make a version that
      // you can login with for a higher limit. But really, this
      // configuration doesn't change very often.
      console.log(`Failed to load ${configJson}; using defaults`);
      const config = {
        "web-root": webroot,
        "main-branch-name": "master",
        "main-branch-prefix": "/current",
        "branch-prefix": "/branch",
        "branch-suffix": "",
        "pr-path": "/pr",
        "branches": {
          "invisiblexml": {
            "ixml": {
              "master": "#IGNORE",
              "gh-pages": "#IGNORE",
              "proposal-pragmas": "#IGNORE"
            }
          }
        },
        "ignore": {
          "invisiblexml": {
            "ixml": {
              "pulls": [10, 146]
            }
          }
        },
        "documents": {
          "invisiblexml": {
            "ixml": ['current']
          }
        },
        "indexes": {
          "invisiblexml": {
            "ixml": {
              "current": {
                "index.html": "Invisible XML",
                "autodiff.html": "DeltaXML diff"
              }
            }
          }
        }
      };
      SaxonJS.transform({
        "stylesheetLocation": `dashboard.sef.json?ts=${uid}`,
        "initialTemplate": "Q{}main",
        "stylesheetParams": {
          "Q{}config": config
        }
      }, "async");
    });

  const descriptions = {};
  window.renderCommonMark = function(id, md) {
    const reader = new commonmark.Parser();
    const writer = new commonmark.HtmlRenderer();
    const parsed = reader.parse(md);
    const result = writer.render(parsed);
    descriptions[id] = result;
  };

  window.insertMarkdown = function() {
    Object.keys(descriptions).forEach(key => {
      const div = document.querySelector(`#${key}`);
      if (div != null) {
        div.innerHTML = descriptions[key];
      }
    });
  };
};
