<?xml version="1.0" encoding="utf-8"?>
<!-- $Id$ -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://histvv.uni-leipzig.de/ns/2007"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="h">

  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>

  <xsl:param name="cssurl" select="'../css/vv.css'"/>
  <xsl:param name="js-url" select="'../js/vv.js'"/>

  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>
          <xsl:call-template name="seitentitel"/>
        </title>
        <link rel="stylesheet" href="../css/include/general.css"/>
        <link rel="stylesheet" href="{$cssurl}"/>
        <script type="text/javascript" src="../js/jquery.js"><xsl:text> </xsl:text></script>
        <script type="text/javascript" src="../js/jquery.dimensions.js"><xsl:text> </xsl:text></script>
        <script type="text/javascript" src="../js/jquery.tooltip.js"><xsl:text> </xsl:text></script>
        <script type="text/javascript" src="{$js-url}"><xsl:text> </xsl:text></script>
      </head>
      <body>
        <xsl:apply-templates select="v:vv|/index"/>
      </body>
    </html>
  </xsl:template>


  <xsl:template match="/index">
    <h1>Vorlesungsverzeichnisse</h1>
    <ol class="toc">
      <xsl:for-each select="vv">
        <li>
          <a href="{@name}.html"><xsl:value-of select="."/></a>
        </li>
      </xsl:for-each>
    </ol>
  </xsl:template>

  <xsl:template match="v:vv">
    <xsl:call-template name="seitennavigation"/>
    <a href="index.html">Index</a>
    <h1><xsl:value-of select="v:titel"/></h1>
    <xsl:apply-templates select="v:absatz|v:übersicht|v:sachgruppe|v:seite|v:trennlinie"/>
    <a href="index.html">Index</a>
  </xsl:template>

  <xsl:template match="v:trennlinie">
    <hr/>
  </xsl:template>

  <xsl:template match="v:absatz">
    <p><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="v:sachgruppe">
    <div class="sachgruppe">
      <xsl:if test="@xml:id">
        <xsl:attribute name="id">
          <xsl:value-of select="@xml:id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="v:übersicht">
    <div class="uebersicht"><xsl:apply-templates/></div>
  </xsl:template>

  <xsl:template match="v:übersicht/v:titel">
    <h2><xsl:apply-templates/></h2>
  </xsl:template>

  <xsl:template match="v:sachgruppe/v:titel">
    <h2>
      <xsl:call-template name="sachgruppentitel-attr"/>
      <xsl:apply-templates/>
    </h2>
  </xsl:template>

  <xsl:template match="v:sachgruppe/v:sachgruppe/v:titel">
    <h3>
      <xsl:call-template name="sachgruppentitel-attr"/>
      <xsl:apply-templates/>
    </h3>
  </xsl:template>

  <xsl:template match="v:sachgruppe/v:sachgruppe/v:sachgruppe/v:titel">
    <h4>
      <xsl:call-template name="sachgruppentitel-attr"/>
      <xsl:apply-templates/>
    </h4>
  </xsl:template>

  <xsl:template match="v:veranstaltung|v:veranstaltungsgruppe">
    <xsl:variable name="name" select="local-name()"/>
    <p class="{$name}">
      <xsl:call-template name="xml-id-to-html-id"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="v:thema | v:modus | v:zeit | v:siehe |
                       v:dozent | v:vorname | v:nachname | v:grad | v:funktion |
                       v:schrift | v:autor | v:schrift/v:titel |
                       v:veranstaltungsgruppe/v:veranstaltung">
    <xsl:variable name="name" select="local-name()"/>
    <span class="{$name}">
      <xsl:call-template name="xml-id-to-html-id"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="v:veranstaltungsverweis">
    <xsl:choose>
      <xsl:when test="parent::v:sachgruppe">
        <p><xsl:call-template name="veranstaltungsverweis"/></p>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="veranstaltungsverweis"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="veranstaltungsverweis">
    <span class="veranstaltungsverweis">
      <xsl:call-template name="xml-id-to-html-id"/>
      <xsl:attribute name="id">
        <!--
          we currently (ab)use the id attribute to propagate the ref
          to the jQuery tooltip plugin
        -->
        <xsl:text>_</xsl:text>
        <xsl:value-of select="@ref"/>
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:text>Verweis auf: </xsl:text>
        <xsl:value-of select="@ref"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="v:antiqua | v:gesperrt | v:dozent/v:grad | v:dozent/v:funktion">
    <xsl:variable name="name" select="local-name()"/>
    <em class="{$name}"><xsl:apply-templates/></em>
  </xsl:template>

  <xsl:template match="v:korrektur">
    <xsl:if test="@original">
      <del><xsl:value-of select="@original"/></del>
    </xsl:if>
    <xsl:if test="text()">
      <ins>
        <xsl:attribute name="title">
          <xsl:choose>
            <xsl:when test="@original">
              <xsl:text>im Original: </xsl:text>
              <xsl:value-of select="@original"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>ergänzt</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:apply-templates/>
      </ins>
    </xsl:if>
  </xsl:template>

  <xsl:template match="v:scil">
    <abbr>
      <xsl:attribute name="title">
        <xsl:text>scil.: </xsl:text>
        <xsl:value-of select="@text"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </abbr>
  </xsl:template>

  <xsl:template match="v:seite">
    <xsl:variable name="nr">
      <xsl:choose>
        <xsl:when test="@nr">
          <xsl:value-of select="@nr"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <span class="seite" id="seite{$nr}">
      <xsl:text>[Seite </xsl:text>
          <xsl:value-of select="."/>
      <xsl:text>]</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="v:siehe[@ref]">
    <a href="#{@ref}" class="siehe"><xsl:apply-templates/></a>
  </xsl:template>


  <!-- NAMED TEMPLATES -->

  <xsl:template name="seitentitel">
    <xsl:text>HistVV</xsl:text>
    <xsl:choose>
      <xsl:when test="/v:vv">
        <xsl:text>: </xsl:text>
        <xsl:value-of select="/v:vv/v:kopf/v:semester"/>
        <xsl:text>semester </xsl:text>
        <xsl:value-of select="/v:vv/v:kopf/v:beginn/v:jahr"/>
        <xsl:if test="/v:vv/v:kopf/v:semester = 'Winter'">
          <xsl:text>/</xsl:text>
          <xsl:value-of select="/v:vv/v:kopf/v:ende/v:jahr"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>: Vorlesungsverzeichnisse</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="seitennavigation">
    <ul id="seitennavigation">
      <xsl:for-each select="/v:vv//v:seite">
        <xsl:variable name="nr">
          <xsl:choose>
            <xsl:when test="@nr">
              <xsl:value-of select="@nr"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <li>
          <a href="#seite{$nr}"><xsl:value-of select="$nr"/></a>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template name="sachgruppentitel-attr">
    <xsl:attribute name="title">
      <xsl:value-of select="parent::*/@xml:id"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="xml-id-to-html-id">
    <xsl:if test="@xml:id">
      <xsl:attribute name="id">
        <xsl:value-of select="@xml:id"/>
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:value-of select="@xml:id"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
