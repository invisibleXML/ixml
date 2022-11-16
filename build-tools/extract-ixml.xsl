<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:h="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="3.0">

<xsl:output method="text" encoding="utf-8" indent="no"/>

<xsl:variable name="spaces" select="'              '"/>

<xsl:template match="h:body">
  <xsl:apply-templates select="h:p[starts-with(., 'Version:')]"/>

  <xsl:variable name="chunks" as="document-node()+">
    <xsl:for-each select="h:pre[contains-token(@class, 'frag')]">
      <xsl:document>
        <xsl:apply-templates select="."/>
      </xsl:document>
    </xsl:for-each>
  </xsl:variable>

  <!-- I don't know why these are reordered... -->
  <xsl:for-each select="$chunks">
    <xsl:choose>
      <xsl:when test="position() = 6"/>
      <xsl:when test="position() = 15">
        <xsl:sequence select="."/>
        <xsl:sequence select="$chunks[6]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<xsl:template match="h:p[starts-with(., 'Version:')]">
  <xsl:text>{version </xsl:text>
  <xsl:sequence select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:text>}&#10;</xsl:text>
</xsl:template>

<xsl:template match="h:pre[contains-token(@class, 'frag')]">
  <xsl:variable name="lines" select="tokenize(., '&#10;')"/>
  <xsl:variable name="pos"
                select="13 - string-length(substring-before($lines[1], ':'))"/>
  <xsl:variable name="indent"
                select="if ($pos gt 0)
                        then substring($spaces, 1, $pos)
                        else ''"/>

  <xsl:for-each select="$lines">
    <xsl:choose>
      <xsl:when test="normalize-space(.) = ''">
        <xsl:value-of select="'&#10;'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$indent || . || '&#10;'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<xsl:template match="*">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="attribute()|text()|comment()|processing-instruction()"/>

</xsl:stylesheet>
