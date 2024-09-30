<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:h="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="3.0">

<xsl:param name="ci-sha1" select="''" as="xs:string"/>
<xsl:param name="ci-build-num" select="''" as="xs:string"/>
<xsl:param name="ci-project-username" select="''" as="xs:string"/>
<xsl:param name="ci-project-reponame" select="''" as="xs:string"/>
<xsl:param name="ci-branch" select="''" as="xs:string"/>
<xsl:param name="ci-tag" select="''" as="xs:string"/>
<xsl:param name="ci-pull" select="''" as="xs:string"/>

<xsl:output method="text" encoding="utf-8" indent="no"/>

<xsl:variable name="spaces" select="'              '"/>

<xsl:template match="h:body">
  <!-- Ok, now we have to make some heuristic choices ... -->
  <xsl:variable name="uri" as="xs:string" expand-text="yes">
    <xsl:choose>
      <xsl:when test="$ci-project-username = 'invisibleXML'
                      and $ci-pull = ''">
        <xsl:text>https://invisiblexml.org/current/</xsl:text>
      </xsl:when>
      <xsl:when test="$ci-project-username = 'invisibleXML'">
        <xsl:text>https://invisiblexml.org/pr/{$ci-pull}/</xsl:text>
      </xsl:when>
      <xsl:when test="$ci-project-username = ''">
        <xsl:sequence select="resolve-uri('../build/current/index.html', static-base-uri())"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>https://{$ci-project-username}.github.io/{$ci-project-reponame}/branch/{$ci-branch}/</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:text>{ Invisible XML specification grammar, </xsl:text>
  <xsl:sequence select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:text> }&#10;</xsl:text>
  <xsl:text>{ Published in </xsl:text>
  <xsl:sequence select="$uri"/>
  <xsl:text> }&#10;</xsl:text>
  <xsl:if test="$ci-sha1 != ''">
    <xsl:text>{ Commit hash </xsl:text>
    <xsl:sequence select="substring($ci-sha1, 1, 12)"/>
    <xsl:text> }&#10;</xsl:text>
  </xsl:if>
  <xsl:text>&#10;</xsl:text>

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
