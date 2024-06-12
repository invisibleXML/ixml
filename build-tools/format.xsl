<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="https://nwalsh.com/ns/functions"
                exclude-result-prefixes="#all"
                expand-text="yes"
                version="3.0">

<xsl:import href="highlight-ixml.xsl"/>
<xsl:import href="highlight-xml.xsl"/>

<xsl:output method="xhtml" encoding="utf-8" indent="no"
            doctype-public="-//W3C//DTD XHTML+RDFa 1.0//EN"
            doctype-system="http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"
            />
<xsl:preserve-space elements="*"/>

<xsl:param name="ci-sha1" select="''" as="xs:string"/>
<xsl:param name="ci-build-num" select="''" as="xs:string"/>
<xsl:param name="ci-project-username" select="''" as="xs:string"/>
<xsl:param name="ci-project-reponame" select="''" as="xs:string"/>
<xsl:param name="ci-branch" select="''" as="xs:string"/>
<xsl:param name="ci-tag" select="''" as="xs:string"/>
<xsl:param name="ci-pull" select="''" as="xs:string"/>

<xsl:mode on-no-match="shallow-copy"/>

<xsl:template match="text()[preceding-sibling::node()[1]/self::comment()
                            and preceding-sibling::node()[1]/string() = '$date=']">
  <span title="Commit: {substring($ci-sha1, 1, 8)}">
    <xsl:sequence select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  </span>
</xsl:template>

<xsl:template match="comment()[contains(., '$version-uri')]"
              expand-text="yes">
  <!-- Ok, now we have to make some heuristic choices ... -->
  <xsl:variable name="uri" as="xs:string">
    <xsl:choose>
      <xsl:when test="$ci-project-username = 'invisibleXML'
                      and $ci-pull = 'null'">
        <xsl:text>https://invisiblexml.org/current/</xsl:text>
      </xsl:when>
      <xsl:when test="$ci-project-username = 'invisibleXML'">
        <xsl:text>https://invisiblexml.org/pr/{$ci-pull}/</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>https://{$ci-project-username}.github.io/{$ci-project-reponame}/branch/{$ci-branch}/</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <a href="{$uri}">{$uri}</a>
</xsl:template>

<xsl:template match="html:h2[@id='status']">
  <xsl:if test="$ci-sha1 != ''">
    <p>A version with automatically generated change
    markup <a href="autodiff.html">is available</a>. Change markup shows
    the differences between <a href="index.html">this version</a> of the
    specification and the
    <a href="https://invisiblexml.org/current/">current version</a> (at the
    time of publication).</p>
  </xsl:if>
  <xsl:next-match/>
</xsl:template>

<xsl:template match="html:html">
  <xsl:copy>
    <xsl:sequence select="@* except @class"/>
    <xsl:attribute name="class" select="'informal no-js ' || @class"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:template match="html:head">
  <xsl:copy>
    <xsl:apply-templates select="@*, node()"/>
    <script>(function(H){{H.className=H.className.replace(/\bno-js\b/,'js')}})(document.documentElement)</script>
    <script defer="defer" src="js/features.js"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="html:body">
  <body>
    <xsl:apply-templates select="@*"/>

    <main>
      <xsl:apply-templates select="node()"/>

      <footer class="docid">
        <p>
          <xsl:choose>
            <xsl:when test="$ci-pull != ''">
              <span class="dt">
                <xsl:text>Document build #{$ci-build-num} with PR #{$ci-pull} </xsl:text>
                <xsl:text>for {$ci-project-username}/{$ci-project-reponame} at </xsl:text>
                <time datetime="{format-dateTime(current-dateTime(),
                                '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][z,6-6]')}"
                      title="{format-dateTime(current-dateTime(),
                             '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][z,6-6]')}">
                  <xsl:text>{format-dateTime(current-dateTime(),
                  '[H01]:[m01] on [D01] [MNn] [Y0001]')}</xsl:text>
                </time>
              </span>
              <xsl:text> </xsl:text>
              <span class="bh">
                <xsl:if test="$ci-tag != '' or $ci-branch ne 'master'">
                  <xsl:sequence select="$ci-tag||$ci-branch||'/'"/>
                </xsl:if>
                <span title="{$ci-sha1}">{substring($ci-sha1, 1, 8)}</span>
              </span>
            </xsl:when>
            <xsl:when test="$ci-sha1 = ''">
              <span class="dt">
                <xsl:text>Published at </xsl:text>
                <time datetime="{format-dateTime(current-dateTime(),
                                '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][z,6-6]')}"
                      title="{format-dateTime(current-dateTime(),
                             '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][z,6-6]')}">
                  <xsl:text>{format-dateTime(current-dateTime(),
                  '[H01]:[m01] on [D01] [MNn] [Y0001]')}</xsl:text>
                </time>
              </span>
            </xsl:when>
            <xsl:otherwise>
              <span class="dt">
                <xsl:text>Document build #{$ci-build-num} </xsl:text>
                <xsl:text>for {$ci-project-username}/{$ci-project-reponame} at </xsl:text>
                <time datetime="{format-dateTime(current-dateTime(),
                                '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][z,6-6]')}"
                      title="{format-dateTime(current-dateTime(),
                             '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][z,6-6]')}">
                  <xsl:text>{format-dateTime(current-dateTime(),
                  '[H01]:[m01] on [D01] [MNn] [Y0001]')}</xsl:text>
                </time>
              </span>
              <xsl:text> </xsl:text>
              <span class="bh">
                <xsl:if test="$ci-tag != '' or $ci-branch ne 'master'">
                  <xsl:sequence select="$ci-tag||$ci-branch||'/'"/>
                </xsl:if>
                <span title="{$ci-sha1}">{substring($ci-sha1, 1, 8)}</span>
              </span>
            </xsl:otherwise>
          </xsl:choose>
        </p>
      </footer>
    </main>
  </body>
</xsl:template>

<xsl:template match="html:body/html:header/html:dl">
  <xsl:variable name="items" as="element()*">
    <xsl:apply-templates/>
  </xsl:variable>
  
  <dl>
    <xsl:sequence select="@*"/>

    <xsl:choose>
      <xsl:when test="$ci-project-username = 'invisibleXML'
                      and $ci-pull = 'null'">
        <xsl:sequence select="$items except $items[contains-token(@class, 'h-current')]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$items"/>
      </xsl:otherwise>
    </xsl:choose>
  </dl>
</xsl:template>

<xsl:template match="html:div[@class='toc']">
  <div>
    <xsl:apply-templates select="@*"/>

    <div class="checkboxes">
      <xsl:text>Show section numbers </xsl:text>
      <label class="switch" for="sectnum">
        <input type="checkbox" id="sectnum" />
        <div class="slider round"></div>
      </label>
    </div>

    <ul>
      <xsl:for-each-group select="/html:html/html:body/*" group-starting-with="html:h2">
        <xsl:if test="position() gt 2"> <!-- skip premable and status section -->
          <xsl:variable name="h2" select="current-group()[1]"/>
          <xsl:if test="empty($h2/@id)">
            <xsl:message select="'Warning: No ID on h2 for ' || string($h2)"/>
          </xsl:if>
          <li>
            <xsl:apply-templates select="$h2" mode="section-number"/>
            <a href="#{if ($h2/@id) then $h2/@id/string() else generate-id($h2)}">
              <xsl:sequence select="$h2/node()"/>
            </a>
            <xsl:if test="current-group()[self::html:h3]">
              <ul>
                <xsl:for-each-group select="current-group()" group-starting-with="html:h3">
                  <xsl:if test="position() gt 1"> <!-- skip premable -->
                    <xsl:variable name="h3" select="current-group()[1]"/>
                    <xsl:if test="empty($h3/@id)">
                      <xsl:message select="'Warning: No ID on h3 for ' || string($h3)"/>
                    </xsl:if>
                    <li>
                      <xsl:apply-templates select="$h3" mode="section-number"/>
                      <a href="#{if ($h3/@id) then $h3/@id/string() else generate-id($h3)}">
                        <xsl:sequence select="$h3/node()"/>
                      </a>
                    </li>
                  </xsl:if>
                </xsl:for-each-group>
              </ul>
            </xsl:if>
          </li>
        </xsl:if>
      </xsl:for-each-group>
    </ul>
  </div>
</xsl:template>

<xsl:template match="html:h2|html:h3">
  <xsl:copy>
    <xsl:sequence select="@*"/>
    <xsl:if test="not(@id)">
      <xsl:attribute name="id" select="generate-id(.)"/>
    </xsl:if>
    <xsl:apply-templates select="." mode="section-number"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:template match="html:h4">
  <xsl:message>Warning: h4 and below are not numbered</xsl:message>
  <xsl:next-match/>
</xsl:template>

<xsl:template match="html:h2" mode="section-number">
  <!-- Don't number the status section -->
  <xsl:if test="preceding::html:h2">
    <span class="sectnum">
      <xsl:sequence select="count(preceding::html:h2)"/>
      <xsl:text>. </xsl:text>
    </span>
  </xsl:if>
</xsl:template>

<xsl:template match="html:h3" mode="section-number">
  <span class="sectnum">
    <xsl:sequence select="count(preceding::html:h2)-1"/>
    <xsl:text>.</xsl:text>
    <xsl:number from="html:h2"/>
    <xsl:text>. </xsl:text>
  </span>
</xsl:template>

<xsl:template match="html:pre[contains-token(@class, 'ixml')
                             or contains-token(@class, 'frag')]">
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:sequence select="f:highlight-ixml(string(.))"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="html:pre[contains-token(@class, 'xml')]">
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:sequence select="f:highlight-xml(string(.))"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="html:pre[@class = 'complete']">
  <xsl:variable name="lines"
                select="unparsed-text('../build/current/ixml.ixml')
                        =&gt; tokenize('&#10;')"/>
  <!-- skip the version comment -->
  <pre>
    <xsl:sequence select="f:highlight-ixml(string-join($lines[position() gt 1], '&#10;'))"/>
  </pre>
</xsl:template>

<xsl:template match="html:pre[@class = 'completexml']">
  <xsl:variable name="grammar"
                select="doc('../build/current/ixml.xml')"/>

  <xsl:variable name="transformed">
    <xsl:apply-templates select="$grammar" mode="trim"/>
  </xsl:variable>

  <xsl:variable name="serialized" as="xs:string">
    <xsl:sequence select="serialize($transformed, map{'method':'xml','indent':true()})"/>
  </xsl:variable>

  <pre>
    <xsl:sequence select="f:highlight-xml($transformed)"/>
  </pre>
</xsl:template>

<xsl:template match="@xml:space"/>

<xsl:mode name="trim" on-no-match="shallow-copy"/>

<xsl:template match="*" mode="trim">
  <xsl:copy>
    <xsl:apply-templates select="@*, node()" mode="trim"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="ixml/*[position() = 15]" mode="trim">
  <xsl:copy>
    <xsl:apply-templates select="@*, node()" mode="trim"/>
  </xsl:copy>
  <xsl:comment> Many more rules here… </xsl:comment>
</xsl:template>

<xsl:template match="ixml/*[position() gt 15]" mode="trim"/>

<xsl:template match="comment[starts-with(., 'version ')]"
              mode="trim" priority="10"/>

<xsl:template match="text()[preceding-sibling::node()[1]
                            /self::comment[starts-with(., 'version ')]]"
              mode="trim">
</xsl:template>

<xsl:template match="ixml/text()[position() gt 15]"
              mode="trim">
</xsl:template>

</xsl:stylesheet>
