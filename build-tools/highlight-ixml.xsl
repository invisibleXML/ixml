<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="https://nwalsh.com/ns/functions"
                exclude-result-prefixes="#all"
                expand-text="yes"
                version="3.0">

<!-- A cheap and cheerful syntax highligher for ixml. It works for the
     ixml.ixml grammar, it will probably work for other valid grammars,
     but YMMV. Note, in particular, that it assumes that nonterminals
     are composed of ASCII characters. -->

<xsl:function name="f:highlight-ixml" as="node()*">
  <xsl:param name="frag" as="xs:string"/>

  <!--
  <xsl:message select="'Highlight ' || string-length($frag) || ' character iXML string…'"/>
  -->

  <!-- We have to avoid blowing out the stack. We can break the input
       into lines and process each line independently. This wouldn't
       work in general, because comments can contain newlines, but none
       of the grammars in the ixml specification do.
  -->

  <xsl:variable name="lines" select="tokenize($frag, '&#10;')"/>
  <span>
    <xsl:for-each select="$lines">
      <xsl:if test="position() gt 1">
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
      <xsl:variable name="tokens"
                    select="string-to-codepoints(.) ! codepoints-to-string(.)"/>
      <xsl:sequence select="f:parse($tokens, 0)"/>
    </xsl:for-each>
  </span>
</xsl:function>

<xsl:function name="f:parse" as="node()*">
  <xsl:param name="tokens" as="xs:string*"/>
  <xsl:param name="depth" as="xs:integer"/>

  <!--
  <xsl:message>Parsing depth {$depth}</xsl:message>
  <xsl:message select="string-join($tokens[position() lt 64], '') ! replace(., '&#10;', ' ')"/>
  -->

  <xsl:choose>
    <xsl:when test="empty($tokens)"/>
    <xsl:when test="$tokens[1] eq '{'">
      <xsl:variable name="comment" select="f:comment($tokens[position() gt 1])"/>
      <span class="com">
        <span class="comdel">{{</span>
        <xsl:sequence select="string-join($comment, '')"/>
        <span class="comdel">}}</span>
      </span>
      <xsl:sequence select="f:parse($tokens[position() gt count($comment)+2], $depth+1)"/>
    </xsl:when>

    <xsl:when test="$tokens[1] eq '['">
      <xsl:variable name="set" select="f:set($tokens[position() gt 1])"/>
      <span class="set">
        <span class="setdel">[</span>
        <xsl:sequence select="f:parse($set, $depth+1)"/>
        <span class="setdel">]</span>
      </span>
      <xsl:sequence select="f:parse($tokens[position() gt count($set)+2], $depth+1)"/>
    </xsl:when>

    <xsl:when test="$tokens[1] eq '~' and $tokens[2] eq '['">
      <xsl:variable name="set" select="f:set($tokens[position() gt 2])"/>
      <span class="set">
        <span class="setdel">~[</span>
        <xsl:sequence select="f:parse($set, $depth+1)"/>
        <span class="setdel">]</span>
      </span>
      <xsl:sequence select="f:parse($tokens[position() gt count($set)+3], $depth+1)"/>
    </xsl:when>

    <xsl:when test="$tokens[1] eq '''' or $tokens[1] eq '&quot;'">
      <xsl:variable name="str" select="f:string($tokens[1], $tokens[position() gt 1])"/>
      <span class="str">
        <span class="strdel">{$tokens[1]}</span>
        <xsl:sequence select="string-join($str, '')"/>
        <span class="strdel">{$tokens[1]}</span>
      </span>
      <xsl:sequence select="f:parse($tokens[position() gt count($str)+2], $depth+1)"/>
    </xsl:when>

    <xsl:when test="$tokens[1] eq '#'">
      <xsl:variable name="hex" select="f:hex($tokens[position() gt 1])"/>
      <span class="hex">
        <span class="hexdel">#</span>
        <xsl:sequence select="string-join($hex, '')"/>
      </span>
      <xsl:sequence select="f:parse($tokens[position() gt count($hex)+1], $depth+1)"/>
    </xsl:when>

    <xsl:when test="$tokens[1] eq ':'">
      <span class="col">:</span>
      <xsl:sequence select="f:parse($tokens[position() gt 1], $depth+1)"/>
    </xsl:when>

    <xsl:when test="contains('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_', $tokens[1])">
      <xsl:variable name="nt" select="f:nt($tokens)"/>
      <span class="nt">
        <xsl:sequence select="string-join($nt, '')"/>
      </span>
      <xsl:sequence select="f:parse($tokens[position() gt count($nt)], $depth+1)"/>
    </xsl:when>

    <xsl:when test="$tokens[1] eq ';' or $tokens[1] eq '|'">
      <span class="alt">{$tokens[1]}</span>
      <xsl:sequence select="f:parse($tokens[position() gt 1], $depth+1)"/>
    </xsl:when>

    <xsl:when test="$tokens[1] eq '^' or $tokens[1] eq '@' or $tokens[1] eq '-'">
      <span class="mark">{$tokens[1]}</span>
      <xsl:sequence select="f:parse($tokens[position() gt 1], $depth+1)"/>
    </xsl:when>

    <xsl:when test="($tokens[1] eq '+' and $tokens[2] eq '+')
                    or ($tokens[1] eq '*' and $tokens[2] eq '*')">
      <span class="reps">{$tokens[1]}{$tokens[1]}</span>
      <xsl:sequence select="f:parse($tokens[position() gt 2], $depth+1)"/>
    </xsl:when>

    <xsl:when test="$tokens[1] eq '?' or $tokens[1] eq '+' or $tokens[1] eq '*'">
      <span class="rep">{$tokens[1]}</span>
      <xsl:sequence select="f:parse($tokens[position() gt 1], $depth+1)"/>
    </xsl:when>

    <xsl:when test="$tokens[1] eq ' ' or $tokens[1] eq '&#10;'">
      <xsl:variable name="ws" select="f:whitespace($tokens)"/>
      <xsl:value-of select="string-join($ws, '')"/>
      <xsl:sequence select="f:parse($tokens[position() gt count($ws)], $depth+1)"/>
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select="$tokens[1]"/>
      <xsl:sequence select="f:parse($tokens[position() gt 1], $depth+1)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:comment" as="xs:string*">
  <xsl:param name="tokens" as="xs:string*"/>

  <xsl:iterate select="$tokens">
    <xsl:param name="chars" as="xs:string*" select="()"/>
    <xsl:param name="depth" as="xs:integer" select="1"/>

    <xsl:choose>
      <xsl:when test=". eq '}' and $depth = 1">
        <xsl:break select="$chars"/>
      </xsl:when>
      <xsl:when test=". eq '}'">
        <xsl:next-iteration>
          <xsl:with-param name="chars" select="($chars, .)"/>
          <xsl:with-param name="depth" select="$depth - 1"/>
        </xsl:next-iteration>
      </xsl:when>
      <xsl:when test=". eq '{'">
        <xsl:next-iteration>
          <xsl:with-param name="chars" select="($chars, .)"/>
          <xsl:with-param name="depth" select="$depth + 1"/>
        </xsl:next-iteration>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-iteration>
          <xsl:with-param name="chars" select="($chars, .)"/>
          <xsl:with-param name="depth" select="$depth"/>
        </xsl:next-iteration>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:iterate>
</xsl:function>

<xsl:function name="f:set" as="xs:string*">
  <xsl:param name="tokens" as="xs:string*"/>

  <xsl:variable name="quotes" select="('''', '&quot;')"/>

  <xsl:iterate select="$tokens">
    <xsl:param name="chars" as="xs:string*" select="()"/>
    <xsl:param name="pchar" as="xs:string" select="' '"/>
    <xsl:param name="pos" as="xs:integer" select="1"/>
    <xsl:param name="q" as="xs:string?" select="()"/>
    <xsl:on-completion select="error((), 'Unterminated set')"/>

    <xsl:choose>
      <xsl:when test=". eq ']' and empty($q)">
        <xsl:break select="$chars"/>
      </xsl:when>
      <!-- 'a''b' -->
      <!-- "a""b" -->
      <!--   ^    -->
      <xsl:when test=". = $quotes and exists($q) and $q = . and $tokens[$pos + 1] = .">
        <xsl:next-iteration>
          <xsl:with-param name="chars" select="($chars, .)"/>
          <xsl:with-param name="pchar" select="."/>
          <xsl:with-param name="pos" select="$pos+1"/>
          <xsl:with-param name="q" select="$q"/>
        </xsl:next-iteration>
      </xsl:when>
      <!-- 'a''b' -->
      <!-- "a""b" -->
      <!--    ^   -->
      <xsl:when test=". = $quotes and exists($q) and $q = . and $pchar eq .">
        <xsl:next-iteration>
          <xsl:with-param name="chars" select="($chars, .)"/>
          <xsl:with-param name="pchar" select="' '"/>
          <xsl:with-param name="pos" select="$pos+1"/>
          <xsl:with-param name="q" select="$q"/>
        </xsl:next-iteration>
      </xsl:when>
      <!-- 'a''b' -->
      <!-- "a""b" -->
      <!--      ^ -->
      <xsl:when test=". = $quotes and exists($q) and $q = .">
        <xsl:next-iteration>
          <xsl:with-param name="chars" select="($chars, .)"/>
          <xsl:with-param name="pchar" select="' '"/>
          <xsl:with-param name="pos" select="$pos+1"/>
          <xsl:with-param name="q" select="()"/>
        </xsl:next-iteration>
      </xsl:when>
      <!-- 'a''b' -->
      <!-- "a""b" -->
      <!-- ^      -->
      <xsl:when test=". = $quotes and empty($q)">
        <xsl:next-iteration>
          <xsl:with-param name="chars" select="($chars, .)"/>
          <xsl:with-param name="pchar" select="' '"/>
          <xsl:with-param name="pos" select="$pos+1"/>
          <xsl:with-param name="q" select="."/>
        </xsl:next-iteration>
      </xsl:when>

      <xsl:otherwise>
        <xsl:next-iteration>
          <xsl:with-param name="chars" select="($chars, .)"/>
          <xsl:with-param name="pchar" select="."/>
          <xsl:with-param name="pos" select="$pos+1"/>
          <xsl:with-param name="q" select="$q"/>
        </xsl:next-iteration>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:iterate>
</xsl:function>

<xsl:function name="f:string" as="xs:string*">
  <xsl:param name="q" as="xs:string"/>
  <xsl:param name="tokens" as="xs:string*"/>

  <xsl:iterate select="$tokens">
    <xsl:param name="chars" as="xs:string*" select="()"/>
    <xsl:param name="pchar" as="xs:string" select="' '"/>
    <xsl:param name="pos" as="xs:integer" select="1"/>
    <xsl:on-completion select="error((), 'Unterminated string')"/>

    <xsl:choose>
      <xsl:when test=". eq $q
                      and ($pos eq count($tokens) or $tokens[$pos+1] ne $q)
                      and $pchar ne $q">
        <xsl:break select="$chars"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-iteration>
          <xsl:with-param name="chars" select="($chars, .)"/>
          <xsl:with-param name="pchar" select="."/>
          <xsl:with-param name="pos" select="$pos + 1"/>
        </xsl:next-iteration>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:iterate>
</xsl:function>

<xsl:function name="f:hex" as="xs:string*">
  <xsl:param name="tokens" as="xs:string*"/>

  <xsl:iterate select="$tokens">
    <xsl:param name="chars" as="xs:string*" select="()"/>
    <xsl:on-completion select="$chars"/>

    <xsl:choose>
      <xsl:when test="contains('ABCDEFabcdef0123456789', .)">
        <xsl:next-iteration>
          <xsl:with-param name="chars" select="($chars, .)"/>
        </xsl:next-iteration>
      </xsl:when>
      <xsl:otherwise>
        <xsl:break select="$chars"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:iterate>
</xsl:function>

<xsl:function name="f:nt" as="xs:string*">
  <xsl:param name="tokens" as="xs:string*"/>

  <xsl:iterate select="$tokens">
    <xsl:param name="chars" as="xs:string*" select="()"/>
    <xsl:on-completion select="$chars"/>

    <xsl:choose>
      <xsl:when test="contains('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789', .)">
        <xsl:next-iteration>
          <xsl:with-param name="chars" select="($chars, .)"/>
        </xsl:next-iteration>
      </xsl:when>
      <xsl:otherwise>
        <xsl:break select="$chars"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:iterate>
</xsl:function>

<xsl:function name="f:whitespace" as="xs:string*">
  <xsl:param name="tokens" as="xs:string*"/>

  <xsl:iterate select="$tokens">
    <xsl:param name="chars" as="xs:string*" select="()"/>
    <xsl:on-completion select="$chars"/>

    <xsl:choose>
      <xsl:when test=". eq ' ' or . eq '&#10;'">
        <xsl:next-iteration>
          <xsl:with-param name="chars" select="($chars, .)"/>
        </xsl:next-iteration>
      </xsl:when>
      <xsl:otherwise>
        <xsl:break select="$chars"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:iterate>
</xsl:function>

</xsl:stylesheet>
