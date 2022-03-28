<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="3.0">

<xsl:output method="xml" encoding="utf-8" indent="yes"
            omit-xml-declaration="yes"/>

<xsl:mode on-no-match="shallow-copy"/>

<xsl:template match="/">
  <dl>
    <xsl:for-each
        select="//h:span[@id and contains-token(@class, 'error') and contains-token(@class, 'static')]">
      <xsl:sort select="@id"/>
      <dt>
        <a href="#{@id}">
          <xsl:sequence select="upper-case(@id)"/>
        </a>
      </dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </xsl:for-each>
  </dl>

  <dl>
    <xsl:for-each
        select="//h:span[@id and contains-token(@class, 'error') and contains-token(@class, 'dynamic')]">
      <xsl:sort select="@id"/>
      <dt>
        <a href="#{@id}">
          <xsl:sequence select="upper-case(@id)"/>
        </a>
      </dt>
      <dd>
        <xsl:apply-templates/>
      </dd>
    </xsl:for-each>
  </dl>
</xsl:template>

<xsl:template match="*">
  <xsl:element namespace="http://www.w3.org/1999/xhtml"
               name="{local-name(.)}">
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
