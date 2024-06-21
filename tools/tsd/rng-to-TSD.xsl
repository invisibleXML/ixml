<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"                
                xmlns:rng="http://relaxng.org/ns/structure/1.0"                         
                xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:xh="http://www.w3.org/1999/xhtml"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                
                version="3.0"
                >
  <!--* rng-to-TSD.xsl:  read a RelaxNG schema and write out a skeleton
      * document for tag-set documentation in the selected vocabulary.
      *-->

  <!--* To do:
      * - find a way to record declarations in Docbook.
      * - render declarations somehow in XHTML (English paraphrase using
      *   list structure? RNC?)
      *-->
  <!--* Revisions:
      * 2024-05-01 : CMSMcQ : made file, with rudimentary translation
      *-->
  <xsl:output indent="yes"/>

  <!--* Parameters *-->
  <!--* vocabulary: output a skeleton in which XML vocabulary? *-->
  <xsl:param name="vocabulary" as="xs:string"
             select="('docbook', 'xhtml', 'tei')[1]"/>
  
  <!--* schema: name to use for the schema being documented? *-->
  <xsl:param name="schema" as="xs:string"
             select="'an unnamed schema'"/>
  
  <!--* grouping: list elements and patterns together or separately? *-->
  <xsl:param name="grouping" as="xs:string"
             select=" ('together', 'separate')[2]"/>

  <!--* namespace names, to use in specifying output *-->
  <xsl:variable name="nss" as="map(*)"
                select="map {
                        'db' : 'http://docbook.org/ns/docbook',
                        'tei' : 'http://www.tei-c.org/ns/1.0',
                        'xh' : 'http://www.w3.org/1999/xhtml'
                        }"/>


  <!--****************************************************************
      * 1 Top-level document organization
      ****************************************************************
      *-->
  <xsl:template match="/">
    <xsl:choose>

      <!--****************************************************************
          * 1a Docbook
          *-->
      <xsl:when test="$vocabulary eq 'docbook'">
        <xsl:element name="book" namespace="{$nss?db}">
          <xsl:element name="title" namespace="{$nss?db}">
            <xsl:text>Tag set documentation for </xsl:text>
            <xsl:value-of select="$schema"/>
          </xsl:element>
          <xsl:element name="info" namespace="{$nss?db}">
            <xsl:element name="date" namespace="{$nss?db}">
              <xsl:value-of select="adjust-date-to-timezone(current-date(), ())"/>
            </xsl:element>
            <xsl:element name="revhistory" namespace="{$nss?db}">
              <xsl:element name="revision" namespace="{$nss?db}">
                <xsl:element name="date" namespace="{$nss?db}">
                  <xsl:value-of select="adjust-date-to-timezone(current-date(), ())"/>
                </xsl:element>
                <xsl:element name="revremark" namespace="{$nss?db}">
                  <xsl:text>auto-generated from schema by rng-to-TSD.xsl</xsl:text>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:element>
          
          <xsl:element name="chapter" namespace="{$nss?db}">
            <xsl:attribute name="xml:id" select="'introduction'"/>
            <xsl:element name="title" namespace="{$nss?db}">
              <xsl:text>Introduction</xsl:text>
            </xsl:element><!-- title -->
            <xsl:element name="para" namespace="{$nss?db}">
              <xsl:text>This is a skeletal framework for documentation of </xsl:text>
              <xsl:value-of select="$schema"/>
              <xsl:text>.</xsl:text>
              <xsl:text>&#xA;It was generated automatically from the </xsl:text>
              <xsl:text>schema by rng-to-TSD.xsl, </xsl:text>
              <xsl:text>&#xA; on </xsl:text>
              <xsl:value-of select="adjust-date-to-timezone(current-date(), ())"/>
              <xsl:text> at </xsl:text>
              <xsl:value-of select="current-time()"/>
              <xsl:text>.</xsl:text>
            </xsl:element><!-- para -->
          </xsl:element><!-- chapter -->

          <xsl:choose>
            <xsl:when test="$grouping eq 'together'">
              <xsl:element name="reference" namespace="{$nss?db}">
                <xsl:attribute name="xml:id" select="'reference'"/>
                <xsl:element name="title" namespace="{$nss?db}">
                  <xsl:text>Alphabetical list of elements and patterns</xsl:text>
                </xsl:element><!-- title -->
                
                <xsl:apply-templates select="descendant::rng:define | descendant::rng:element">
                  <xsl:sort select="@name"/>
                </xsl:apply-templates>
                
              </xsl:element><!-- reference -->
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="reference" namespace="{$nss?db}">
                <xsl:attribute name="xml:id" select="'elements'"/>
                <xsl:element name="title" namespace="{$nss?db}">
                  <xsl:text>Alphabetical list of elements</xsl:text>
                </xsl:element><!-- title -->
                
                <xsl:apply-templates select="descendant::rng:element">
                  <xsl:sort select="@name"/>
                </xsl:apply-templates>
                
              </xsl:element><!-- reference -->
              
              <xsl:element name="reference" namespace="{$nss?db}">
                <xsl:attribute name="xml:id" select="'patterns'"/>
                <xsl:element name="title" namespace="{$nss?db}">
                  <xsl:text>Alphabetical list of patterns</xsl:text>
                </xsl:element><!-- title -->
                
                <xsl:apply-templates select="descendant::rng:define">
                  <xsl:sort select="@name"/>
                </xsl:apply-templates>
                
              </xsl:element><!-- reference -->
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element><!-- book -->
      </xsl:when>
      
      <!--****************************************************************
          * 1b TEI
          *-->
      <xsl:when test="$vocabulary eq 'tei'">
        <xsl:element name="TEI" namespace="{$nss?tei}">
          <xsl:element name="teiHeader" namespace="{$nss?tei}">
            <xsl:element name="fileDesc" namespace="{$nss?tei}">
              <xsl:element name="titleStmt" namespace="{$nss?tei}">
                <xsl:element name="title" namespace="{$nss?tei}">
                  <xsl:text>Tag set documentation for </xsl:text>
                  <xsl:value-of select="$schema"/>
                </xsl:element><!-- title -->
              </xsl:element>
              <xsl:element name="publicationStmt" namespace="{$nss?tei}">
                <xsl:element name="distributor" namespace="{$nss?tei}">
                  <xsl:text>[None. This tag set documentation </xsl:text>
                  <xsl:text>will not be distributed in this form.]</xsl:text>
                </xsl:element><!-- distributor -->
                <xsl:element name="date" namespace="{$nss?tei}">
                  <xsl:value-of select="substring(
                                        string(
                                        adjust-date-to-timezone(current-date(), ())
                                        ),
                                        1, 4)"/>
                </xsl:element><!-- date -->
              </xsl:element><!-- publicationStmt -->
              <xsl:element name="sourceDesc" namespace="{$nss?tei}">
                <xsl:element name="p" namespace="{$nss?tei}">
                  <xsl:text>Generated automatically from </xsl:text>
                  <xsl:value-of select="$schema"/>
                </xsl:element><!-- p -->
              </xsl:element><!-- sourceDesc -->
            </xsl:element><!-- fileDesc -->
            
            <xsl:element name="revisionDesc" namespace="{$nss?tei}">
              <xsl:element name="change" namespace="{$nss?tei}">
                <xsl:attribute name="when"
                               select="adjust-date-to-timezone(current-date(), ())"/>
                <xsl:text>Document auto-generated from schema by rng-to-TSD.xsl</xsl:text>
              </xsl:element>
            </xsl:element><!-- revisionDesc -->
          </xsl:element><!-- teiHeader -->
          
          <xsl:element name="text" namespace="{$nss?tei}">
            <xsl:element name="front" namespace="{$nss?tei}">
              <xsl:element name="titlePage" namespace="{$nss?tei}">
                <xsl:element name="docTitle" namespace="{$nss?tei}">
                  <xsl:element name="titlePart" namespace="{$nss?tei}">
                    <xsl:text>Reference documentation (skeleton)</xsl:text>
                  </xsl:element>
                  <xsl:element name="titlePart" namespace="{$nss?tei}">
                    <xsl:text>for </xsl:text>
                    <xsl:value-of select="$schema"/>
                  </xsl:element>
                </xsl:element><!-- docTitle -->

                <xsl:element name="docDate" namespace="{$nss?tei}">
                  <xsl:value-of select="adjust-date-to-timezone(current-date(), ())"/>
                </xsl:element>
              </xsl:element><!-- titlePage -->
            </xsl:element><!-- front -->
            <xsl:element name="body" namespace="{$nss?tei}">
              <xsl:element name="div" namespace="{$nss?tei}">
                <xsl:attribute name="xml:id" select="'introduction'"/>
                <xsl:element name="head" namespace="{$nss?tei}">
                  <xsl:text>Introduction</xsl:text>
                </xsl:element><!-- head -->
                <xsl:element name="p" namespace="{$nss?tei}">
                  <xsl:text>This is a skeletal framework for documentation of </xsl:text>
                  <xsl:value-of select="$schema"/>
                  <xsl:text>.</xsl:text>
                  <xsl:text>&#xA;It was generated automatically from the </xsl:text>
                  <xsl:text>schema by rng-to-TSD.xsl, </xsl:text>
                  <xsl:text>&#xA; on </xsl:text>
                  <xsl:value-of select="adjust-date-to-timezone(current-date(), ())"/>
                  <xsl:text> at </xsl:text>
                  <xsl:value-of select="current-time()"/>
                  <xsl:text>.</xsl:text>
                </xsl:element><!-- p -->
              </xsl:element><!-- div (intro) -->

              <xsl:choose>
                <xsl:when test="$grouping eq 'together'">
                  <xsl:element name="div" namespace="{$nss?tei}">
                    <xsl:attribute name="xml:id" select="'reference'"/>
                    <xsl:element name="head" namespace="{$nss?tei}">
                      <xsl:text>Alphabetical list of elements and patterns</xsl:text>
                    </xsl:element><!-- title -->
                    
                    <xsl:apply-templates select="descendant::rng:define | descendant::rng:element">
                      <xsl:sort select="@name"/>
                    </xsl:apply-templates>
                    
                  </xsl:element><!-- reference -->
                </xsl:when>
                <xsl:otherwise>
                  <xsl:element name="div" namespace="{$nss?tei}">
                    <xsl:attribute name="xml:id" select="'elements'"/>
                    <xsl:element name="head" namespace="{$nss?tei}">
                      <xsl:text>Alphabetical list of elements</xsl:text>
                    </xsl:element><!-- title -->
                    
                    <xsl:apply-templates select="descendant::rng:element">
                      <xsl:sort select="@name"/>
                    </xsl:apply-templates>
                    
                  </xsl:element><!-- div -->                  
                  <xsl:element name="div" namespace="{$nss?tei}">
                    <xsl:attribute name="xml:id" select="'patterns'"/>
                    <xsl:element name="head" namespace="{$nss?tei}">
                      <xsl:text>Alphabetical list of patterns</xsl:text>
                    </xsl:element><!-- head -->
                    
                    <xsl:apply-templates select="descendant::rng:define">
                      <xsl:sort select="@name"/>
                    </xsl:apply-templates>
                    
                  </xsl:element><!-- div -->
                </xsl:otherwise>
              </xsl:choose>
            </xsl:element><!-- body -->
          </xsl:element><!-- text -->
        </xsl:element><!-- TEI -->
      </xsl:when>
      
      <!--****************************************************************
          * 1c XHTML
          *-->
      <xsl:when test="$vocabulary eq 'xhtml'">
        <xsl:element name="html" namespace="{$nss?xh}">
          <xsl:element name="head" namespace="{$nss?xh}">
            <xsl:element name="title" namespace="{$nss?xh}">
              <xsl:text>Tag set documentation for </xsl:text>
              <xsl:value-of select="$schema"/>
            </xsl:element><!-- title -->
            <xsl:element name="meta" namespace="{$nss?xh}">
              <xsl:attribute name="name" select=" 'distributor' "/>
              <xsl:attribute name="content" select=" 'None' "/>
            </xsl:element>
            <xsl:element name="meta" namespace="{$nss?xh}">
              <xsl:attribute name="name" select=" 'date' "/>
              <xsl:attribute name="content" select="substring(string(
                                                    adjust-date-to-timezone(current-date(), ())
                                                    ),
                                                    1, 4)"/>
            </xsl:element>
            <xsl:element name="meta" namespace="{$nss?xh}">
              <xsl:attribute name="name" select=" 'source' "/>
              <xsl:attribute name="content"
                             select=" concat('generated ',
                                     'automatically by ',
                                     'rng-to-TSD.xsl') "/>
            </xsl:element>
          </xsl:element><!-- head -->
          
          <xsl:element name="body" namespace="{$nss?xh}">
            <xsl:element name="div" namespace="{$nss?xh}">
              <xsl:attribute name="class" select="'titlepage'"/>
              <xsl:element name="h1" namespace="{$nss?xh}">
                <xsl:text>Reference documentation (skeleton)</xsl:text>
                <xsl:text> for </xsl:text>
                <xsl:value-of select="$schema"/>
              </xsl:element><!-- h1 -->
              <xsl:element name="h3" namespace="{$nss?xh}">
                <xsl:value-of select="adjust-date-to-timezone(current-date(), ())"/>
              </xsl:element><!-- h3 -->
            </xsl:element><!-- div titlepage -->
            
            <xsl:element name="div" namespace="{$nss?xh}">
              <xsl:attribute name="id" select="'introduction'"/>
              <xsl:element name="h2" namespace="{$nss?xh}">
                <xsl:text>Introduction</xsl:text>
              </xsl:element><!-- head -->
              <xsl:element name="p" namespace="{$nss?xh}">
                <xsl:text>This is a skeletal framework for documentation of </xsl:text>
                <xsl:value-of select="$schema"/>
                <xsl:text>.</xsl:text>
                <xsl:text>&#xA;It was generated automatically from the </xsl:text>
                <xsl:text>schema by rng-to-TSD.xsl, </xsl:text>
                <xsl:text>&#xA; on </xsl:text>
                <xsl:value-of select="adjust-date-to-timezone(current-date(), ())"/>
                <xsl:text> at </xsl:text>
                <xsl:value-of select="current-time()"/>
                <xsl:text>.</xsl:text>
              </xsl:element><!-- p -->
            </xsl:element><!-- div (intro) -->

            <xsl:choose>
              <xsl:when test="$grouping eq 'together'">
                <xsl:element name="div" namespace="{$nss?xh}">
                  <xsl:attribute name="id" select="'reference'"/>
                  <xsl:element name="h2" namespace="{$nss?xh}">
                    <xsl:text>Alphabetical list of elements and patterns</xsl:text>
                  </xsl:element><!-- h2 -->
                  
                  <xsl:apply-templates select="descendant::rng:define | descendant::rng:element">
                    <xsl:sort select="@name"/>
                  </xsl:apply-templates>
                  
                </xsl:element><!-- div -->
              </xsl:when>
              <xsl:otherwise>
                <xsl:element name="div" namespace="{$nss?xh}">
                  <xsl:attribute name="id" select="'elements'"/>
                  <xsl:element name="h2" namespace="{$nss?xh}">
                    <xsl:text>Alphabetical list of elements</xsl:text>
                  </xsl:element><!-- h2 -->
                  
                  <xsl:apply-templates select="descendant::rng:element">
                    <xsl:sort select="@name"/>
                  </xsl:apply-templates>
                  
                </xsl:element><!-- div -->                  
                <xsl:element name="div" namespace="{$nss?xh}">
                  <xsl:attribute name="id" select="'patterns'"/>
                  <xsl:element name="h2" namespace="{$nss?xh}">
                    <xsl:text>Alphabetical list of patterns</xsl:text>
                  </xsl:element><!-- h2 -->
                  
                  <xsl:apply-templates select="descendant::rng:define">
                    <xsl:sort select="@name"/>
                  </xsl:apply-templates>
                  
                </xsl:element><!-- div -->
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element><!-- body -->
        </xsl:element><!-- html -->
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <!--****************************************************************
      * 2 Elements (and their attributes)
      ****************************************************************
      *-->
  <xsl:template match="rng:element">
    <xsl:choose>

      <!--****************************************************************
          * 2a Docbook
          *-->
      <xsl:when test="$vocabulary eq 'docbook'">
        <xsl:element name="refentry" namespace="{$nss?db}">
          <xsl:attribute name="xml:id" select="concat('element.', @name)"/>
          
          <xsl:element name="refnamediv" namespace="{$nss?db}">
            <xsl:element name="refdescriptor" namespace="{$nss?db}">
              <xsl:text>(element)</xsl:text>
            </xsl:element>
            <xsl:element name="refname" namespace="{$nss?db}">
              <xsl:value-of select="@name"/>
            </xsl:element>
            <xsl:element name="refpurpose" namespace="{$nss?db}">
              <xsl:choose>
                <xsl:when test="parent::rng:define
                                and
                                preceding-sibling::*[1]/self::a:documentation">
                  <xsl:apply-templates select="parent::*/a:documentation"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>[Description to be supplied.]</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:element>
          </xsl:element><!-- refnamediv -->

          <xsl:element name="refsynopsisdiv" namespace="{$nss?db}">
            <xsl:element name="synopsis" namespace="{$nss?db}">
              <xsl:copy-of select="."/>
            </xsl:element>
          </xsl:element>

          <xsl:element name="refsection" namespace="{$nss?db}">
            <xsl:element name="title" namespace="{$nss?db}">
              <xsl:text>Remarks</xsl:text>
            </xsl:element>
            <xsl:element name="para" namespace="{$nss?db}">
              <xsl:text>...</xsl:text>
            </xsl:element>
          </xsl:element>
          
        </xsl:element><!-- refentry -->
      </xsl:when>
      
      <!--****************************************************************
          * 2b TEI
          *-->
      <xsl:when test="$vocabulary eq 'tei'">
        <xsl:element name="macroSpec" namespace="{$nss?tei}">
          <xsl:attribute name="xml:id" select="concat('element.', @name)"/>
          <xsl:attribute name="ident" select="@name"/>
          <xsl:element name="desc" namespace="{$nss?tei}">
              <xsl:choose>
                <xsl:when test="parent::rng:define
                                and
                                preceding-sibling::*[1]/self::a:documentation">
                  <xsl:apply-templates select="parent::*/a:documentation"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>[Description to be supplied.]</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
          </xsl:element>
          <xsl:element name="content" namespace="{$nss?tei}">
            <xsl:copy-of select="."/>
          </xsl:element>
          <xsl:element name="remarks" namespace="{$nss?tei}">
            <xsl:element name="p" namespace="{$nss?tei}">
              <xsl:text>...</xsl:text>
            </xsl:element>
          </xsl:element>          
        </xsl:element><!-- macroSpec -->
      </xsl:when>
      
      <!--****************************************************************
          * 2c XHTML
          *-->
      <xsl:when test="$vocabulary eq 'xhtml'">
        <xsl:element name="div" namespace="{$nss?xh}">
          <xsl:attribute name="id" select="concat('element.', @name)"/>
          <xsl:attribute name="class" select=" 'element reference'"/>
          
          <xsl:element name="div" namespace="{$nss?xh}">
            <xsl:attribute name="class" select=" 'naming'"/>
            <xsl:element name="h3" namespace="{$nss?xh}">
              <xsl:element name="span" namespace="{$nss?xh}">
                <xsl:attribute name="class" select=" 'element-name'"/>
                <xsl:value-of select="@name"/>
              </xsl:element>
              <xsl:text> </xsl:text>              
              <xsl:element name="span" namespace="{$nss?xh}">
                <xsl:attribute name="class" select=" 'type-qualifier'"/>
                <xsl:text>(element)</xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="div" namespace="{$nss?xh}">
              <xsl:attribute name="class" select=" 'desc' "/>
              <xsl:choose>
                <xsl:when test="parent::rng:define
                                and
                                preceding-sibling::*[1]/self::a:documentation">
                  <xsl:apply-templates select="parent::*/a:documentation"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>[Description to be supplied.]</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:element>
          </xsl:element><!-- div naming  -->

          <xsl:element name="div" namespace="{$nss?xh}">
            <xsl:attribute name="class" select=" 'synopsis' "/>
            <xsl:element name="p" namespace="{$nss?xh}">
              <xsl:text>watch this space</xsl:text>
            </xsl:element>
            <!-- <xsl:copy-of select="."/> -->
          </xsl:element>

          <xsl:element name="div" namespace="{$nss?xh}">
            <xsl:attribute name="class" select=" 'remarks' "/>
            <xsl:element name="h4" namespace="{$nss?xh}">
              <xsl:text>Remarks</xsl:text>
            </xsl:element>
            <xsl:element name="p" namespace="{$nss?xh}">
              <xsl:text>...</xsl:text>
            </xsl:element>
          </xsl:element><!-- div remarks -->
          
        </xsl:element>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <!--****************************************************************
      * 3 Patterns
      ****************************************************************
      *-->
  <xsl:template match="rng:define">
    <xsl:choose>

      <!--****************************************************************
          * 2a Docbook
          *-->
      <xsl:when test="$vocabulary eq 'docbook'">
        <xsl:element name="refentry" namespace="{$nss?db}">
          <xsl:attribute name="xml:id" select="concat('pattern.', @name)"/>
          
          <xsl:element name="refnamediv" namespace="{$nss?db}">
            <xsl:element name="refdescriptor" namespace="{$nss?db}">
              <xsl:text>(pattern)</xsl:text>
            </xsl:element>
            <xsl:element name="refname" namespace="{$nss?db}">
              <xsl:value-of select="@name"/>
            </xsl:element>
            <xsl:element name="refpurpose" namespace="{$nss?db}">
              <xsl:apply-templates select="a:documentation"/>
            </xsl:element>
          </xsl:element><!-- refnamediv -->

          <xsl:element name="refsynopsisdiv" namespace="{$nss?db}">
            <xsl:element name="synopsis" namespace="{$nss?db}">
              <xsl:copy-of select="."/>
            </xsl:element>
          </xsl:element>

          <xsl:element name="refsection" namespace="{$nss?db}">
            <xsl:element name="title" namespace="{$nss?db}">
              <xsl:text>Remarks</xsl:text>
            </xsl:element>
            <xsl:element name="para" namespace="{$nss?db}">
              <xsl:text>...</xsl:text>
            </xsl:element>
          </xsl:element>
          
        </xsl:element><!-- refentry -->
      </xsl:when>
      
      <!--****************************************************************
          * 2b TEI
          *-->
      <xsl:when test="$vocabulary eq 'tei'">
        <xsl:element name="macroSpec" namespace="{$nss?tei}">
          <xsl:attribute name="xml:id" select="concat('pattern.', @name)"/>
          <xsl:attribute name="ident" select="@name"/>
          <xsl:element name="desc" namespace="{$nss?tei}">
            <xsl:apply-templates select="a:documentation"/>
          </xsl:element>
          <xsl:element name="content" namespace="{$nss?tei}">
            <xsl:copy-of select="."/>
          </xsl:element>
          <xsl:element name="remarks" namespace="{$nss?tei}">
            <xsl:element name="p" namespace="{$nss?tei}">
              <xsl:text>...</xsl:text>
            </xsl:element>
          </xsl:element>          
        </xsl:element><!-- macroSpec -->
      </xsl:when>
      
      <!--****************************************************************
          * 2c XHTML
          *-->
      <xsl:when test="$vocabulary eq 'xhtml'">
        <xsl:element name="div" namespace="{$nss?xh}">
          <xsl:attribute name="id" select="concat('pattern.', @name)"/>
          <xsl:attribute name="class" select=" 'pattern reference'"/>
          
          <xsl:element name="div" namespace="{$nss?xh}">
            <xsl:attribute name="class" select=" 'naming'"/>
            <xsl:element name="h3" namespace="{$nss?xh}">
              <xsl:element name="span" namespace="{$nss?xh}">
                <xsl:attribute name="class" select=" 'pattern-name'"/>
                <xsl:value-of select="@name"/>
              </xsl:element>
              <xsl:text> </xsl:text>
              <xsl:element name="span" namespace="{$nss?xh}">
                <xsl:attribute name="class" select=" 'type-qualifier'"/>
                <xsl:text>(pattern)</xsl:text>
              </xsl:element>
            </xsl:element>
            <xsl:element name="div" namespace="{$nss?xh}">
              <xsl:attribute name="class" select=" 'desc' "/>
              <xsl:apply-templates select="a:documentation"/>
            </xsl:element>
          </xsl:element><!-- div naming  -->

          <xsl:element name="div" namespace="{$nss?xh}">
            <xsl:attribute name="class" select=" 'synopsis' "/>
            <xsl:element name="p" namespace="{$nss?xh}">
              <xsl:text>watch this space</xsl:text>
            </xsl:element>
            <!-- <xsl:copy-of select="."/> -->
          </xsl:element>

          <xsl:element name="div" namespace="{$nss?xh}">
            <xsl:attribute name="class" select=" 'remarks' "/>
            <xsl:element name="h4" namespace="{$nss?xh}">
              <xsl:text>Remarks</xsl:text>
            </xsl:element>
            <xsl:element name="p" namespace="{$nss?xh}">
              <xsl:text>...</xsl:text>
            </xsl:element>
          </xsl:element><!-- div remarks -->
          
        </xsl:element>
      </xsl:when>
    </xsl:choose>
  </xsl:template>  
  
</xsl:stylesheet>
