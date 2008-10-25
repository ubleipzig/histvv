<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://histvv.uni-leipzig.de/ns/2007"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="v">

  <xsl:template match="v:thema | v:modus | v:zeit | v:siehe | v:seite |
                       v:dozent | v:vorname | v:nachname | v:grad | v:funktion |
                       v:schrift | v:autor | v:schrift/v:titel |
                       v:veranstaltungsgruppe/v:veranstaltung">
    <xsl:variable name="name" select="local-name()"/>
    <span class="{$name}">
      <xsl:call-template name="xml-id-to-html-id"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="v:antiqua | v:gesperrt | v:dozent/v:grad | v:dozent/v:funktion">
    <xsl:variable name="name" select="local-name()"/>
    <em class="{$name}"><xsl:apply-templates/></em>
  </xsl:template>

  <!-- single element templates in alphabetical order -->

  <xsl:template match="v:absatz">
    <p><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="v:dozent[@ref]">
    <xsl:variable name="name" select="local-name()"/>
    <a class="dozent" href="../dozenten/{@ref}.html">
      <xsl:attribute name="title">
        <xsl:text>zur Dozentenseite</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="v:vv//v:ders[@ref]">
    <xsl:variable name="dozent" select="preceding::v:dozent[1]"/>
    <a class="dozent" href="../dozenten/{@ref}.html">
      <xsl:attribute name="title">
        <xsl:value-of select="normalize-space($dozent)"/>
        <xsl:text>; zur Dozentenseite</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates/>
    </a>
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

  <xsl:template name="sachgruppentitel-attr">
    <xsl:attribute name="title">
      <xsl:value-of select="parent::*/@xml:id"/>
    </xsl:attribute>
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

  <xsl:template match="v:trennlinie">
    <hr/>
  </xsl:template>

  <xsl:template match="v:übersicht">
    <div class="uebersicht"><xsl:apply-templates/></div>
  </xsl:template>

  <xsl:template match="v:übersicht/v:titel">
    <h2><xsl:apply-templates/></h2>
  </xsl:template>

  <xsl:template match="v:url">
    <xsl:variable name="url" select="normalize-space(.)"/>
    <xsl:choose>
      <xsl:when test="not(contains($url, ' '))">
        <a href="{$url}"><xsl:value-of select="$url"/></a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="v:veranstaltung|v:veranstaltungsgruppe">
    <xsl:variable name="name" select="local-name()"/>
    <p class="{$name}">
      <xsl:call-template name="xml-id-to-html-id"/>
      <xsl:apply-templates/>
    </p>
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
      <xsl:if test="@ref">
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
      </xsl:if>
      <xsl:apply-templates/>
    </span>
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
