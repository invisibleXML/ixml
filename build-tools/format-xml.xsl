<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="https://nwalsh.com/ns/functions"
                exclude-result-prefixes="#all"
                expand-text="yes"
                version="3.0">

<xsl:import href="highlight-xml.xsl"/>

<xsl:output method="html" html-version="5" encoding="utf-8" indent="no"/>
<xsl:strip-space elements="*"/>

<xsl:mode on-no-match="shallow-copy"/>

<xsl:template match="/">
  <html>
    <head>
      <title>ixml.xml</title>
      <link rel="stylesheet" href="css/style.css"/>
      <link rel="stylesheet" href="css/treeview.css"/>
    </head>
    <body>
      <h1>ixml.xml</h1>
      <p>This is the complete <a href="index.html">Invisible XML</a> grammar in XML.
      It is also available <a href="ixml.ixml.html">in iXML</a>.</p>
      <div class="listing">
        <div id="toggle-buttons">
          <a class="button" href="ixml.xml" download="ixml.xml">Download</a>
        </div>
        <pre id="ixml">
          <xsl:sequence select="f:highlight-xml(*, true())"/>
        </pre>
      </div>
      <script src="js/buttons.js"></script>
      <script src="js/treeview.js"></script>
    </body>
  </html>
</xsl:template>

</xsl:stylesheet>
