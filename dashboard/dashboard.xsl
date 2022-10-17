<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 	        xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:err="http://www.w3.org/2005/xqt-errors"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:js="http://saxonica.com/ns/globalJS"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="https://nwalsh.com/ns/functions"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                expand-text="yes"
                version="3.0">

<xsl:output method="html" html-version="5" encoding="utf-8" indent="no"/>

<xsl:param name="config" as="map(*)"/>

<xsl:variable name="as-json" select="map{'method':'json','indent':true()}"/>
<xsl:variable name="as-xml" select="map{'method':'xml','indent':true()}"/>
<xsl:variable name="IGNORE" select="'#IGNORE'"/>

<xsl:variable name="web-root" select="$config?web-root"/>
<xsl:variable name="main-branch-name" select="($config?main-branch-name, 'main')[1]"/>
<xsl:variable name="branch-prefix" select="f:slashes($config?branch-prefix)"/>
<xsl:variable name="main-branch-prefix"
              select="f:slashes(($config?main-branch-prefix, $branch-prefix)[1])"/>
<xsl:variable name="branch-suffix" select="$config?branch-suffix"/>
<xsl:variable name="pr-path" select="f:slashes($config?pr-path)"/>

<xsl:template name="main">
  <xsl:choose>
    <xsl:when test="empty($web-root)">
      <xsl:apply-templates select="ixsl:page()/html/body" mode="root-error">
        <xsl:with-param
            name="message"
            select="'No configuration for web-root, cannot build dashboard'"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:when test="empty($branch-prefix)">
      <xsl:apply-templates select="ixsl:page()/html/body" mode="root-error">
        <xsl:with-param
            name="message"
            select="'No configuration for branch-prefix, cannot build dashboard'"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:when test="empty($pr-path)">
      <xsl:apply-templates select="ixsl:page()/html/body" mode="root-error">
        <xsl:with-param
            name="message"
            select="'No configuration for pr-path, cannot build dashboard'"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates
          select="ixsl:page()//section[contains-token(@class, 'community') and @x-name]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="section[contains-token(@class, 'community')]">
  <xsl:apply-templates select="section[contains-token(@class, 'repository') and @x-name]
                               /div[contains-token(@class, 'branches')]"
                       mode="collect-branches">
    <xsl:with-param name="community" select="@x-name"/>
  </xsl:apply-templates>
  <xsl:apply-templates select="ixsl:page()
                               //section[contains-token(@class, 'repository') and @x-name]
                               /div[contains-token(@class, 'pull-requests')]"
                       mode="collect-pull-requests">
    <xsl:with-param name="community" select="@x-name"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="div" mode="collect-branches">
  <xsl:param name="community" as="xs:string"/>

  <ixsl:schedule-action
      http-request="map {
                      'method': 'GET',
                      'href': 'https://api.github.com/repos/'
                              || $community || '/' || ../@x-name || '/branches'
                    }">
    <xsl:call-template name="find-all-branches">
      <xsl:with-param name="community" select="$community"/>
      <xsl:with-param name="repository" select="../@x-name"/>
      <xsl:with-param name="context" select="."/>
    </xsl:call-template>
  </ixsl:schedule-action>
</xsl:template>

<xsl:template name="find-all-branches">
  <xsl:context-item as="map(*)" use="required"/>
  <xsl:param name="community" as="xs:string"/>
  <xsl:param name="repository" as="xs:string"/>
  <xsl:param name="context" as="element()"/>

  <xsl:choose>
    <xsl:when test=".?status = 200 and starts-with(.?headers?content-type, 'application/json')">
      <xsl:variable name="current-branches"
                    select="array:flatten(parse-json(.?body)) ! .?name"/>

      <xsl:apply-templates select="$context" mode="list-branches">
        <xsl:with-param name="community" select="$community"/>
        <xsl:with-param name="repository" select="$repository"/>
        <xsl:with-param name="branches" select="$current-branches"/>
      </xsl:apply-templates>

      <xsl:variable name="documents" as="xs:string*">
        <xsl:if test="map:contains($config, 'documents')">
          <xsl:variable name="docs" select="map:get($config, 'documents')"/>
          <xsl:if test="$docs instance of map(*)
                        and map:contains($docs, $community)">
            <xsl:variable name="comm" select="map:get($docs, $community)"/>
            <xsl:if test="$comm instance of map(*)
                          and map:contains($comm, $repository)">
              <xsl:sequence select="map:get($comm, $repository)"/>
            </xsl:if>
          </xsl:if>
        </xsl:if>
      </xsl:variable>

      <!-- Note: we've now *updated* the content of $context! -->
      <xsl:apply-templates select="$context/div[@x-branch]" mode="collect-branch-documents">
        <xsl:with-param name="community" select="$community"/>
        <xsl:with-param name="repository" select="$repository"/>
        <xsl:with-param name="documents" select="$documents"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:when test=".?status = 404">
      <!-- ignore -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:message select="'Error: ', serialize(., $as-json)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="list-branches">
  <xsl:param name="community" as="xs:string"/>
  <xsl:param name="repository" as="xs:string"/>
  <xsl:param name="branches" as="xs:string*"/>

  <xsl:variable name="branch-titles" as="map(*)*">
    <xsl:map>
      <xsl:if test="map:contains($config, 'branches')">
        <xsl:variable name="titles" select="map:get($config, 'branches')"/>
        <xsl:if test="$titles instance of map(*)
                      and map:contains($titles, $community)">
          <xsl:variable name="comm" select="map:get($titles, $community)"/>
          <xsl:if test="$comm instance of map(*)
                        and map:contains($comm, $repository)">
            <xsl:variable name="tmap" select="map:get($comm, $repository)"/>
            <xsl:if test="$tmap instance of map(*)">
              <xsl:for-each select="map:keys($tmap)">
                <xsl:map-entry key="." select="map:get($tmap, .)"/>
              </xsl:for-each>
            </xsl:if>
          </xsl:if>
        </xsl:if>
      </xsl:if>
    </xsl:map>
  </xsl:variable>

  <xsl:variable
      name="useful-branches"
      select="$branches ! (if (map:get($branch-titles, .) = $IGNORE) then () else .)"/>

  <xsl:variable name="this" select="."/>

  <xsl:result-document href="?." method="ixsl:replace-content">
    <xsl:if test="exists($useful-branches)">
      <h3>Branches</h3>

      <xsl:if test="$main-branch-name = $useful-branches">
        <div id="x-{$this/../../@x-name}-{$this/../@x-name}-{$main-branch-name}"
             x-community="{$this/../../@x-name}" x-repository="{$this/../@x-name}"
             x-branch="{$main-branch-name}" class="branch">
          <h4>{$main-branch-name}</h4>
          <p>Loading documents…</p>
        </div>
      </xsl:if>

      <xsl:for-each select="$branches">
        <xsl:sort select="." order="descending"/>
        <xsl:if test=". != $main-branch-name">
          <xsl:choose>
            <xsl:when test=". = $useful-branches">
              <div id="x-{$this/../../@x-name}-{$this/../@x-name}-{.}"
                   x-community="{$this/../../@x-name}" x-repository="{$this/../@x-name}"
                   x-branch="{.}" class="branch">
                <h4>{.}</h4>
                <p>Loading documents…</p>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <xsl:comment> Ignored branch: {.} </xsl:comment>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:result-document>
</xsl:template>

<xsl:template match="div" mode="collect-branch-documents">
  <xsl:param name="community" as="xs:string"/>
  <xsl:param name="repository" as="xs:string"/>
  <xsl:param name="documents" as="xs:string*"/>

  <xsl:variable name="branch-titles" as="map(*)*">
    <xsl:map>
      <xsl:if test="map:contains($config, 'branches')">
        <xsl:variable name="titles" select="map:get($config, 'branches')"/>
        <xsl:if test="$titles instance of map(*)
                      and map:contains($titles, $community)">
          <xsl:variable name="comm" select="map:get($titles, $community)"/>
          <xsl:if test="$comm instance of map(*)
                        and map:contains($comm, $repository)">
            <xsl:variable name="tmap" select="map:get($comm, $repository)"/>
            <xsl:if test="$tmap instance of map(*)">
              <xsl:for-each select="map:keys($tmap)">
                <xsl:map-entry key="." select="map:get($tmap, .)"/>
              </xsl:for-each>
            </xsl:if>
          </xsl:if>
        </xsl:if>
      </xsl:if>
    </xsl:map>
  </xsl:variable>

  <xsl:variable name="branch-name" select="@x-branch/string()"/>
  <xsl:variable name="branch-title"
                select="if (map:contains($branch-titles, $branch-name))
                        then map:get($branch-titles, $branch-name)
                        else $branch-name"/>

  <xsl:variable name="path" select="if ($branch-name = $main-branch-name
                                        and $main-branch-prefix != $branch-prefix)
                                    then $main-branch-prefix
                                    else $branch-prefix || $branch-name"/>

  <xsl:variable name="branch" select="@x-branch/string()"/>
  <xsl:call-template name="f-find-documents">
    <xsl:with-param name="community" select="$community"/>
    <xsl:with-param name="repository" select="$repository"/>
    <xsl:with-param name="context" select="."/>
    <xsl:with-param name="title" as="element()"><h4>{$branch-title}</h4></xsl:with-param>
    <xsl:with-param name="base-uri" select="$web-root || $path || $branch-suffix"/>
    <xsl:with-param name="dirs" select="$documents"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="f-find-documents">
  <xsl:param name="community" as="xs:string+"/>
  <xsl:param name="repository" as="xs:string+"/>
  <xsl:param name="context" as="element()"/>
  <xsl:param name="title" as="element()"/>
  <xsl:param name="base-uri" as="xs:string"/>
  <xsl:param name="dirs" as="xs:string+"/>

  <xsl:variable name="indexes" as="map(*)?">
    <xsl:if test="map:contains($config, 'indexes')">
      <xsl:variable name="indexes" select="map:get($config, 'indexes')"/>
      <xsl:if test="$indexes instance of map(*) and map:contains($indexes, $community)">
        <xsl:variable name="comm" select="map:get($indexes, $community)"/>
        <xsl:if test="$comm instance of map(*) and map:contains($comm, $repository)">
          <xsl:variable name="repo" select="map:get($comm, $repository)"/>
          <xsl:if test="$repo instance of map(*)">
            <xsl:sequence select="$repo"/>
          </xsl:if>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="indexes" as="map(*)"
                select="if (exists($indexes)) then $indexes else map{}"/>

  <xsl:variable name="documents" as="map(*)*">
    <xsl:for-each select="$dirs">
      <xsl:variable name="dir" select="."/>
      <xsl:variable name="idx" as="map(*)"
                    select="if (map:contains($indexes, $dir))
                            then map:get($indexes, $dir)
                            else map:entry('index.html', $dir)"/>
      <xsl:for-each select="map:keys($idx)">
        <xsl:map>
          <xsl:map-entry key="'dir'" select="$dir"/>
          <xsl:map-entry key="'title'" select="map:get($idx, .)"/>
          <xsl:map-entry key="'uri'"
                         select="$base-uri
                                 || (if (ends-with($base-uri, '/')) then '' else '/')
                                 || (if ($dir eq '') then '' else $dir || '/')
                                 || ."/>
        </xsl:map>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:variable>

  <xsl:if test="exists($documents)">
    <ixsl:schedule-action
        http-request="map {
                        'method': 'GET',
                        'href': $documents[1]?uri,
                        'status-only': true()
                      }">
      <xsl:call-template name="xfind-documents">
        <xsl:with-param name="context" select="$context"/>
        <xsl:with-param name="title" select="$title"/>
        <xsl:with-param name="document" select="$documents[1]"/>
        <xsl:with-param name="documents" select="$documents[position() gt 1]"/>
      </xsl:call-template>
    </ixsl:schedule-action>
  </xsl:if>
</xsl:template>

<xsl:template name="xfind-documents">
  <xsl:context-item as="map(*)" use="required"/>
  <xsl:param name="context" as="element()"/>
  <xsl:param name="title" as="element()"/>
  <xsl:param name="document" as="map(*)"/>
  <xsl:param name="documents" as="map(*)*"/>
  <xsl:param name="found" as="map(*)*" select="()"/>

  <xsl:variable name="current"
                select="if (.?status = 200)
                        then ($found, $document)
                        else $found"/>

  <xsl:choose>
    <xsl:when test="exists($documents)">
      <ixsl:schedule-action
          http-request="map {
                          'method': 'GET',
                          'href': $documents[1]?uri,
                          'status-only': true()
                        }">
        <xsl:call-template name="xfind-documents">
          <xsl:with-param name="context" select="$context"/>
          <xsl:with-param name="title" select="$title"/>
          <xsl:with-param name="document" select="$documents[1]"/>
          <xsl:with-param name="documents" select="$documents[position() gt 1]"/>
          <xsl:with-param name="found" select="$current"/>
        </xsl:call-template>
      </ixsl:schedule-action>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="$context" mode="show-map-results">
        <xsl:with-param name="title" select="$title"/>
        <xsl:with-param name="documents" select="$current"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="show-map-results">
  <xsl:param name="title" as="element()"/>
  <xsl:param name="documents" as="map(*)*"/>

  <xsl:variable name="non-auto-documents" as="map(*)*">
    <xsl:for-each select="$documents">
      <xsl:if test="not(contains(.?uri, 'autodiff'))">
        <xsl:sequence select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <!-- THERE IS A TOTAL HACK HERE TO SUPPORT THE DeltaXML DIFFS -->
  <xsl:result-document href="?." method="ixsl:replace-content">
    <xsl:if test="exists(@x-branch) or count($non-auto-documents) gt 1">
      <xsl:sequence select="$title"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="exists($documents)">
        <ul>
          <xsl:for-each select="$documents">
            <xsl:choose>
              <xsl:when test="contains(.?uri, 'autodiff')">
                <!-- nop, not this one -->
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="dxml" as="map(*)?">
                  <xsl:choose>
                    <xsl:when test="ends-with(.?uri, 'xquery-40.html')">
                      <xsl:sequence
                          select="f:find-dxml($documents, .?dir, '/xquery-40-autodiff.html')"/>
                    </xsl:when>
                    <xsl:when test="ends-with(.?uri, 'xpath-40.html')">
                      <xsl:sequence
                          select="f:find-dxml($documents, .?dir, '/xpath-40-autodiff.html')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:sequence
                          select="f:find-dxml($documents, .?dir, '/autodiff.html')"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <li>
                  <a href="{.?uri}">
                    <xsl:sequence select="?title"/>
                  </a>
                  <xsl:if test="exists($dxml)">
                    <span class="diffs">
                      <xsl:text> (</xsl:text>
                      <a href="{$dxml?uri}">
                        <xsl:sequence select="$dxml?title"/>
                      </a>
                      <xsl:text>)</xsl:text>
                    </span>
                  </xsl:if>
                </li>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </ul>
      </xsl:when>
      <xsl:otherwise>
        <p>No formatted documents found.</p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:result-document>
</xsl:template>

<xsl:function name="f:find-dxml" as="map(*)?">
  <xsl:param name="documents" as="map(*)*"/>
  <xsl:param name="dir" as="xs:string"/>
  <xsl:param name="suffix" as="xs:string"/>

  <!-- we should never match more than one, but just in case... -->
  <xsl:variable name="candidates" as="map(*)*">
    <xsl:for-each select="$documents">
      <xsl:if test=".?dir = $dir and ends-with(.?uri, $suffix)">
        <xsl:sequence select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:if test="count($candidates) gt 1">
    <xsl:message select="'Warning: multiple find-dxml candidates!?'"/>
  </xsl:if>

  <xsl:sequence select="$candidates[1]"/>
</xsl:function>

<!-- ============================================================ -->

<xsl:template match="div" mode="collect-pull-requests">
  <xsl:param name="community" as="xs:string"/>

  <ixsl:schedule-action
      http-request="map {
                      'method': 'GET',
                      'href': 'https://api.github.com/repos/'
                              || $community || '/' || ../@x-name || '/pulls?state=open'
                    }">
    <xsl:call-template name="find-all-pull-requests">
      <xsl:with-param name="community" select="$community"/>
      <xsl:with-param name="repository" select="../@x-name"/>
      <xsl:with-param name="context" select="."/>
    </xsl:call-template>
  </ixsl:schedule-action>
</xsl:template>

<xsl:template name="find-all-pull-requests">
  <xsl:context-item as="map(*)" use="required"/>
  <xsl:param name="community" as="xs:string"/>
  <xsl:param name="repository" as="xs:string"/>
  <xsl:param name="context" as="element()"/>

  <xsl:choose>
    <xsl:when test=".?status = 200 and starts-with(.?headers?content-type, 'application/json')">
      <xsl:variable name="current-pulls"
                    select="array:flatten(parse-json(.?body))"/>

      <xsl:apply-templates select="$context" mode="list-pulls">
        <xsl:with-param name="community" select="$community"/>
        <xsl:with-param name="repository" select="$repository"/>
        <xsl:with-param name="pulls" select="$current-pulls"/>
      </xsl:apply-templates>

      <!-- Note: we've now *updated* the content of $context! -->
      <xsl:apply-templates
          select="$context/div[@x-pull]/div[contains-token(@class, 'changed-files')]"
          mode="collect-changed-files">
        <xsl:with-param name="community" select="$community"/>
        <xsl:with-param name="repository" select="$repository"/>
      </xsl:apply-templates>

      <xsl:variable name="documents" as="xs:string*">
        <xsl:if test="map:contains($config, 'documents')">
          <xsl:variable name="docs" select="map:get($config, 'documents')"/>
          <xsl:if test="$docs instance of map(*)
                        and map:contains($docs, $community)">
            <xsl:variable name="comm" select="map:get($docs, $community)"/>
            <xsl:if test="$comm instance of map(*)
                          and map:contains($comm, $repository)">
              <xsl:sequence select="map:get($comm, $repository)"/>
            </xsl:if>
          </xsl:if>
        </xsl:if>
      </xsl:variable>

      <xsl:apply-templates
          select="$context/div[@x-pull]/div[contains-token(@class, 'document-list')]"
          mode="collect-pull-documents">
        <xsl:with-param name="community" select="$community"/>
        <xsl:with-param name="repository" select="$repository"/>
        <xsl:with-param name="documents" select="$documents"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message select="'Error: ', serialize(., $as-json)"/>
    </xsl:otherwise>
  </xsl:choose>

  <ixsl:schedule-action wait="1000">
    <xsl:call-template name="insert-markdown"/>
  </ixsl:schedule-action>
</xsl:template>

<xsl:template name="insert-markdown">
  <xsl:sequence select="js:insertMarkdown()"/>
</xsl:template>

<xsl:template match="*" mode="list-pulls">
  <xsl:param name="community" as="xs:string"/>
  <xsl:param name="repository" as="xs:string"/>
  <xsl:param name="pulls" as="map(*)*"/>

  <xsl:variable name="ignore" as="xs:integer*">
    <xsl:if test="map:contains($config, 'ignore')">
      <xsl:variable name="ignore" select="map:get($config, 'ignore')"/>
      <xsl:if test="$ignore instance of map(*)
                    and map:contains($ignore, $community)">
        <xsl:variable name="comm" select="map:get($ignore, $community)"/>
        <xsl:if test="$comm instance of map(*)
                      and map:contains($comm, $repository)">
          <xsl:sequence select="array:flatten(map:get($comm, $repository)?pulls) ! xs:integer(.)"/>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="useful-pulls"
                select="$pulls ! (if (.?number = $ignore) then () else .?number)"/>

  <xsl:if test="empty($useful-pulls)">
    <xsl:message select="'No useful pulls in ' || $community || '/' || $repository"/>
  </xsl:if>

  <xsl:variable name="this" select="."/>

  <xsl:result-document href="?." method="ixsl:replace-content">
    <xsl:if test="exists($useful-pulls)">
      <h3>
        <xsl:text>Pull requests in </xsl:text>
        <a href="#" id="prdesc">ascending</a>
        <a href="#" id="prasc">descending</a>
        <xsl:text> order</xsl:text>
      </h3>
      <xsl:for-each select="$pulls">
        <xsl:sort select=".?number" order="descending"/>
        <xsl:choose>
          <xsl:when test=".?number = $useful-pulls">
            <div class="pull-request" x-pull="{.?number}" id="pr-{.?number}"
                 x-base="{.?base?sha}" x-head="{.?head?sha}">
              <h4>PR #{.?number}: {.?title}</h4>
              <details>
                <summary>
                  <xsl:text>Pull request </xsl:text>
                  <a href="{.?html_url}">#{.?number}</a>
                  <xsl:text> by </xsl:text>
                  <a href="{.?user?html_url}">{.?user?login}</a>
                  <xsl:text>.</xsl:text>
                </summary>
                <xsl:variable name="id" select="'pr' || .?number || '-desc'"/>
                <div class="prdesc" id="{$id}">
                  <xsl:choose>
                    <xsl:when test="empty(.?body) or .?body = ''">
                      <pre>No description provided.</pre>
                    </xsl:when>
                    <xsl:otherwise>
                      <pre>{.?body}</pre>
                      <!-- injecting the result has to be deferred because we're
                           still constructing the page... -->
                      <xsl:sequence select="js:renderCommonMark($id, .?body)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </div>
              </details>
              <div class="changed-files">Loading changed files…</div>
              <div class="document-list">Loading documents…</div>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <xsl:comment> Ignored pull: {.?number} </xsl:comment>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
  </xsl:result-document>
</xsl:template>

<xsl:template match="a[@id='prasc']" mode="ixsl:onclick">
  <xsl:sequence select="ixsl:call(ixsl:event(), 'preventDefault', [])"/>
  <xsl:apply-templates select="../.." mode="flip-divs"/>
  <!-- Why doesn't this apply to the context item if @object is omitted? -->
  <ixsl:set-style name="display" select="'none'" object="ixsl:page()//a[@id='prasc']"/>
  <ixsl:set-style name="display" select="'inline'" object="ixsl:page()//a[@id='prdesc']"/>
</xsl:template>

<xsl:template match="a[@id='prdesc']" mode="ixsl:onclick">
  <xsl:sequence select="ixsl:call(ixsl:event(), 'preventDefault', [])"/>
  <xsl:apply-templates select="../.." mode="flip-divs"/>
  <!-- Why doesn't this apply to the context item if @object is omitted? -->
  <ixsl:set-style name="display" select="'none'" object="ixsl:page()//a[@id='prdesc']"/>
  <ixsl:set-style name="display" select="'inline'" object="ixsl:page()//a[@id='prasc']"/>
</xsl:template>

<xsl:template match="*" mode="flip-divs">
  <xsl:variable name="divs" select="div"/>
  <xsl:result-document href="?." method="ixsl:replace-content">
    <xsl:for-each select="node()">
      <xsl:choose>
        <xsl:when test="self::div[empty(preceding-sibling::div)]">
          <xsl:sequence select="reverse($divs)"/>
        </xsl:when>
        <xsl:when test="self::div"/>
        <xsl:otherwise>
          <xsl:sequence select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:result-document>
</xsl:template>

<xsl:template match="div" mode="collect-changed-files">
  <xsl:param name="community" as="xs:string"/>
  <xsl:param name="repository" as="xs:string"/>

  <xsl:variable name="compare"
                select="'https://api.github.com/repos/'
                        || $community || '/' || $repository || '/compare/'
                        || ../@x-base || '...' || ../@x-head"/>

  <ixsl:schedule-action
      http-request="map {
                      'method': 'GET',
                      'href': $compare
                    }">
    <xsl:call-template name="f-show-changed-files">
      <xsl:with-param name="context" select="."/>
    </xsl:call-template>
  </ixsl:schedule-action>
</xsl:template>

<xsl:template name="f-show-changed-files">
  <xsl:context-item as="map(*)" use="required"/>
  <xsl:param name="context" as="element()"/>
  <xsl:apply-templates select="$context" mode="f-show-changed-files">
    <xsl:with-param name="context" select="."/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="*" mode="f-show-changed-files">
  <xsl:param name="context" as="map(*)"/>

  <xsl:result-document href="?." method="ixsl:replace-content">
    <xsl:choose>
      <xsl:when test="$context?status = 200
                      and starts-with($context?headers?content-type, 'application/json')">
        <xsl:variable name="body" select="parse-json($context?body)"/>
        <xsl:variable name="files" select="array:flatten($body?files) ! .?filename"/>
        <xsl:if test="exists($files)">
          <details>
            <summary>
              <span class="fake-h5">Changed files</span>
            </summary>
            <!-- It would be nice to link to the diffs for each file, but CORS
                 prevents us from reading the GitHub page and I have no idea
                 how to predict the fragment identifiers for each file. -->
            <ul class="changed-files">
              <xsl:for-each select="$files">
                <li>{.}</li>
              </xsl:for-each>
            </ul>
          </details>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="'Error: ', serialize(., $as-json)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:result-document>
</xsl:template>

<xsl:template match="div" mode="collect-pull-documents">
  <xsl:param name="community" as="xs:string"/>
  <xsl:param name="repository" as="xs:string"/>
  <xsl:param name="documents" as="xs:string+"/>

  <xsl:variable name="pull" select="../@x-pull/string()"/>
  <xsl:variable name="path" select="$pr-path || $pull"/>

  <xsl:call-template name="f-find-documents">
    <xsl:with-param name="community" select="$community"/>
    <xsl:with-param name="repository" select="$repository"/>
    <xsl:with-param name="context" select="."/>
    <xsl:with-param name="title" as="element()"><h5>Documents</h5></xsl:with-param>
    <xsl:with-param name="base-uri" select="$web-root || $path"/>
    <xsl:with-param name="dirs" select="$documents"/>
  </xsl:call-template>
</xsl:template>

<!-- ============================================================ -->

<xsl:function name="f:slashes" as="xs:string?">
  <xsl:param name="path" as="xs:string?"/>

  <xsl:variable name="leading"
                select="if (exists($path) and starts-with($path, '/'))
                        then '' else '/'"/>
  <xsl:variable name="trailing"
                select="if (exists($path) and ends-with($path, '/'))
                        then '' else '/'"/>

  <xsl:choose>
    <xsl:when test="empty($path) or $path = ''">
      <xsl:sequence select="$path"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$leading || $path || $trailing"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<xsl:template match="body" mode="root-error">
  <xsl:param name="message" as="xs:string"/>
  <xsl:result-document href="?." method="ixsl:replace-content">
    <div class="error">{$message}</div>
    <xsl:sequence select="node()"/>
  </xsl:result-document>
</xsl:template>

<!-- ============================================================ -->

</xsl:stylesheet>
