<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                expand-text="yes"
                exclude-result-prefixes="#all"
                version="3.0">

<xsl:output method="html" html-version="5" encoding="utf-8" indent="no"/>

<xsl:param name="spec" required="yes"/>

<xsl:mode on-no-match="shallow-copy"/>

<xsl:template match="html:body/html:h1[empty(preceding::html:h1)]">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()"/>
  </xsl:copy>

  <div class="diffinfo">
    <p>The presentation of this document has been augmented by
    <a href="https://www.deltaxml.com/">DeltaXML</a> to identify changes
    from the {$spec} version. You can view the old version, the new version,
    or both versions with styled <span class="show-old">old text</span>
    and <span class="show-new">new text</span>.</p>
  </div>
</xsl:template>

<xsl:template match="@xml:space"/>

</xsl:stylesheet>
