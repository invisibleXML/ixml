<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="https://nwalsh.com/ns/functions"
                xmlns:m="https://nwalsh.com/ns/modes"
                exclude-result-prefixes="#all"
                default-mode="m:highlight-xml"
                expand-text="yes"
                version="3.0">

<!-- A cheap and cheerful syntax highligher for xml. It works
     for very simple XML examples, like the ones in the
     Invisible XML specification; it's not a practical, general
     purpose highlighter. -->

<xsl:function name="f:highlight-xml" as="node()*">
  <xsl:param name="frag"/>
  <xsl:sequence select="f:highlight-xml($frag, false())"/>
</xsl:function>

<xsl:function name="f:highlight-xml" as="node()*">
  <xsl:param name="frag"/>
  <xsl:param name="controls" as="xs:boolean"/>

  <xsl:choose>
    <xsl:when test="$frag instance of document-node()">
      <span>
        <xsl:apply-templates select="$frag/*">
          <xsl:with-param name="controls" as="xs:boolean" tunnel="yes" select="$controls"/>
        </xsl:apply-templates>
      </span>
    </xsl:when>
    <xsl:when test="$frag instance of element()">
      <span>
        <xsl:apply-templates select="$frag">
          <xsl:with-param name="controls" as="xs:boolean" tunnel="yes" select="$controls"/>
        </xsl:apply-templates>
      </span>
    </xsl:when>
    <xsl:when test="$frag instance of xs:string">
      <xsl:try>
        <xsl:variable name="doc" select="parse-xml($frag)"/>
        <span>
          <xsl:apply-templates select="$doc/*">
            <xsl:with-param name="controls" as="xs:boolean" tunnel="yes" select="$controls"/>
          </xsl:apply-templates>
        </span>
        <xsl:catch>
          <xsl:value-of select="$frag"/>
        </xsl:catch>
      </xsl:try>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="error((), 'Invalid argument to f:highlight-xml')"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:variable name="spaces" select="'                                        '"/>

<xsl:template match="*">
  <xsl:param name="controls" as="xs:boolean" tunnel="yes"/>

  <xsl:if test="$controls">
    <xsl:sequence select="substring($spaces, 1, count(ancestor::*)*3)"/>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="text()">
      <xsl:if test="$controls">
        <span class="space"></span>
      </xsl:if>
      <span class="text">
        <span class="stag">&lt;</span>
        <span class="gi">{local-name(.)}</span>
        <xsl:apply-templates select="@*"/>
        <span class="stag">&gt;</span>
        <xsl:apply-templates/>
        <span class="etag">&lt;/</span>
        <span class="gi">{local-name(.)}</span>
        <span class="etag">&gt;</span>
      </span>
      <xsl:if test="$controls">
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
    </xsl:when>
    <xsl:when test="node() and $controls">
      <span class="node">
        <span class="toggle">
          <span class="open"></span>
          <span class="close"></span>
          <span>
            <span class="stag">&lt;</span>
            <span class="gi">{local-name(.)}</span>
            <xsl:apply-templates select="@*"/>
            <span class="stag">&gt;</span>
          </span>
        </span>
        <xsl:text>&#10;</xsl:text>
        <span class="dots" x-indent="{count(ancestor::*)*3}"></span>
        <span class="children">
          <xsl:apply-templates/>
        </span>
        <xsl:sequence select="substring($spaces, 1, count(ancestor::*)*3)"/>
        <span>
          <span class="space"></span>
          <span class="etag">&lt;/</span>
          <span class="gi">{local-name(.)}</span>
          <span class="etag">&gt;</span>
        </span>
      </span>
      <xsl:text>&#10;</xsl:text>
    </xsl:when>
    <xsl:when test="node()">
      <span class="node">
        <span>
          <span class="stag">&lt;</span>
          <span class="gi">{local-name(.)}</span>
          <xsl:apply-templates select="@*"/>
          <span class="stag">&gt;</span>
        </span>
        <span class="children">
          <xsl:apply-templates/>
        </span>
        <span>
          <span class="etag">&lt;/</span>
          <span class="gi">{local-name(.)}</span>
          <span class="etag">&gt;</span>
        </span>
      </span>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="$controls">
        <span class="space"></span>
      </xsl:if>
      <span class="empty">
        <span class="stag">&lt;</span>
        <span class="gi">{local-name(.)}</span>
        <xsl:apply-templates select="@*"/>
        <span class="stag">/&gt;</span>
      </span>
      <xsl:if test="$controls">
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- A hack for the ixml grammar! -->
<xsl:template match="comment()">
  <xsl:text>&#10;   &lt;!-- </xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>--&gt;&#10;</xsl:text>
</xsl:template>

<xsl:template match="@*">
  <xsl:text> </xsl:text>
  <span class="attr">
    <span class="aname">{local-name(.)}</span>
    <span class="eq">=</span>
    <span class="q">'</span>
    <span class="avalue">{replace(., "'", "&amp;apos;")}</span>
    <span class="q">'</span>
  </span>
</xsl:template>

</xsl:stylesheet>
