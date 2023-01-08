<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="https://nwalsh.com/ns/functions"
                exclude-result-prefixes="#all"
                expand-text="yes"
                version="3.0">

<xsl:import href="highlight-ixml.xsl"/>

<xsl:output method="html" html-version="5" encoding="utf-8" indent="no"/>
<xsl:preserve-space elements="*"/>

<xsl:param name="ixml.ixml" as="xs:string"/>

<xsl:mode on-no-match="shallow-copy"/>

<xsl:template name="xsl:initial-template">
  <xsl:variable name="text" select="unparsed-text($ixml.ixml)"/>

  <html>
    <head>
      <title>ixml.ixml</title>
      <link rel="stylesheet" href="css/style.css"/>
      <link rel="stylesheet" href="css/treeview.css"/>
    </head>
    <body>
      <h1>ixml.ixml</h1>
      <p>This is the complete <a href="index.html">Invisible XML</a> grammar in iXML.
      It is also available <a href="ixml.xml.html">in XML</a>.</p>
      <div class="listing">
        <div id="toggle-buttons">
          <a class="button" href="ixml.ixml" download="ixml.ixml">Download</a>
        </div>
        <pre id="ixml">
          <xsl:sequence select="f:highlight-ixml($text)"/>
        </pre>
      </div>
      <script src="js/buttons.js"></script>
    </body>
  </html>
</xsl:template>

</xsl:stylesheet>
