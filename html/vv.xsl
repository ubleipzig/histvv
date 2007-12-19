<?xml version="1.0" encoding="utf-8"?>
<!-- $Id$ -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://hashtable.de/ns/histvv" 
                xmlns:h="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="h">

  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>

  <xsl:param name="cssurl" select="'html.css'"/>

  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>
          <xsl:call-template name="seitentitel"/>
        </title>
        <link rel="stylesheet" href="{$cssurl}"/>
      </head>
      <body>
        <xsl:apply-templates select="v:vv|/index"/>
      </body>
    </html>
  </xsl:template>


  <xsl:template match="/index">
    <h1>Vorlesungsverzeichnisse</h1>
    <ol>
      <xsl:for-each select="vv">
        <li>
          <a href="{.}.html"><xsl:value-of select="."/></a>
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

  <xsl:template match="v:vv/v:sachgruppe/v:titel | v:vv/v:übersicht/v:titel">
    <h2><xsl:apply-templates/></h2>
  </xsl:template>

  <xsl:template match="v:sachgruppe/v:titel">
    <h4><xsl:apply-templates/></h4>
  </xsl:template>

  <xsl:template match="v:veranstaltung|v:veranstaltungsgruppe">
    <xsl:variable name="name" select="local-name()"/>
    <p class="{$name}"><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="v:thema | v:modus | v:zeit |
                       v:dozent| v:vorname |v:nachname |v:grad | v:funktion |
                       v:schrift | v:autor | v:schrift/v:titel |
                       v:veranstaltungsgruppe/v:veranstaltung">
    <xsl:variable name="name" select="local-name()"/>
    <span class="{$name}"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="v:antiqua | v:gesperrt | v:dozent/v:grad | v:dozent/v:funktion">
    <xsl:variable name="name" select="local-name()"/>
    <em class="{$name}"><xsl:apply-templates/></em>
  </xsl:template>

  <xsl:template match="v:korrektur">
    <xsl:if test="@original">
      <del><xsl:value-of select="@original"/></del>
    </xsl:if>
    <ins>
      <xsl:if test="@original">
        <xsl:attribute name="title">
          <xsl:text>im Original: </xsl:text>
          <xsl:value-of select="@original"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </ins>
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


  <!-- NAMED TEMPLATES -->


  <xsl:template name="seitentitel">
    <xsl:text>HistVV</xsl:text>
    <xsl:if test="/v:vv">
      <xsl:text>: </xsl:text>
      <xsl:value-of select="/v:vv/v:kopf/v:semester"/>
      <xsl:text>semester </xsl:text>
      <xsl:value-of select="/v:vv/v:kopf/v:beginn/v:jahr"/>
      <xsl:if test="/v:vv/v:kopf/v:semester = 'Winter'">
        <xsl:text>/</xsl:text>
        <xsl:value-of select="/v:vv/v:kopf/v:ende/v:jahr"/>
      </xsl:if>
    </xsl:if>
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

</xsl:stylesheet>
