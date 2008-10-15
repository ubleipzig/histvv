<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://histvv.uni-leipzig.de/ns/2007"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="v">

  <xsl:import href="common.xsl"/>
  <xsl:import href="histvv2html.xsl"/>

  <xsl:template name="content">
    <xsl:apply-templates select="/index|/v:vv"/>
  </xsl:template>

  <xsl:template name="htmltitle">
    <xsl:choose>
      <xsl:when test="/v:vv">
        <xsl:value-of select="/v:vv/v:kopf/v:semester"/>
        <xsl:text>semester </xsl:text>
        <xsl:value-of select="/v:vv/v:kopf/v:beginn/v:jahr"/>
        <xsl:if test="/v:vv/v:kopf/v:semester = 'Winter'">
          <xsl:text>/</xsl:text>
          <xsl:value-of select="/v:vv/v:kopf/v:ende/v:jahr"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Vorlesungsverzeichnisse</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="scripts">
    <script type="text/javascript" src="/js/vv.js"></script>
  </xsl:template>

  <xsl:template match="/index">
    <h1>Vorlesungsverzeichnisse</h1>
    <ol class="toc">
      <xsl:for-each select="vv[komplett]">
        <li>
          <a href="{@name}.html">
            <xsl:value-of select="titel"/>
          </a>
          <xsl:text> </xsl:text>
          <small>
            <xsl:text>(</xsl:text>
            <xsl:value-of select="vnum"/>
            <xsl:text>)</xsl:text>
          </small>
        </li>
      </xsl:for-each>
    </ol>

    <xsl:variable name="chart-data">
      <xsl:for-each select="/index/vv">
        <xsl:choose>
          <xsl:when test="komplett">
            <xsl:value-of select="number(vnum)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>-1</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not(position() = last())">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="chart-url">
      <xsl:text>http://chart.apis.google.com/chart?cht=bvs</xsl:text>
      <xsl:text>&amp;chbh=2,1,2</xsl:text>
      <xsl:text>&amp;chs=650x200</xsl:text>
      <xsl:text>&amp;chco=8fb635</xsl:text>
      <xsl:text>&amp;chds=0,700</xsl:text>
      <xsl:text>&amp;chxt=x,y</xsl:text>
      <xsl:text>&amp;chxr=0,0,201</xsl:text>
      <xsl:text>&amp;chxp=0,0,12,32,52,72,92,112,132,152,172,192</xsl:text>
      <xsl:text>&amp;chxl=</xsl:text>
      <xsl:text>0:|1814|1820|1830|1840|1850|1860|1870|1880|1890|1900|1910|</xsl:text>
      <xsl:text>1:||100|200|300|400|500|600|700</xsl:text>
      <xsl:text>&amp;chd=t:</xsl:text>
      <xsl:value-of select="$chart-data"/>
    </xsl:variable>

    <img alt="Diagramm" title="Anzahl der Veranstaltungen pro Semester"
         src="{$chart-url}"/>
  </xsl:template>

  <xsl:template match="/v:vv">
    <xsl:attribute name="class">vv</xsl:attribute>
    <xsl:call-template name="seitennavigation"/>
    <h1><xsl:value-of select="v:titel"/></h1>
    <xsl:apply-templates select="v:absatz|v:übersicht|v:sachgruppe|v:seite|v:trennlinie"/>
  </xsl:template>

  <xsl:template match="v:siehe[@ref]">
    <a href="#{@ref}" class="siehe"><xsl:apply-templates/></a>
  </xsl:template>

  <xsl:template match="v:seite[@nr]">
    <span class="seite" id="seite{@nr}">
      <xsl:text>[</xsl:text>
      <xsl:call-template name="seitenlink">
        <xsl:with-param name="nr" select="@nr"/>
      </xsl:call-template>
      <xsl:text>]</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="v:seite">
    <xsl:variable name="nr">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:variable>
    <span class="seite" id="seite{$nr}">
      <xsl:call-template name="seitenlink">
        <xsl:with-param name="nr" select="$nr"/>
      </xsl:call-template>
    </span>
  </xsl:template>

  <xsl:template name="seitenlink">
    <xsl:param name="nr"/>
    <a title="Seite {$nr}: zum Scan">
      <xsl:attribute name="href">
        <xsl:call-template name="seitenzahl2scan-url">
          <xsl:with-param name="nr" select="$nr"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:value-of select="$nr"/>
    </a>
  </xsl:template>

  <xsl:template name="seitenzahl2scan-url">
    <xsl:param name="nr"/>
    <xsl:text>../scans/</xsl:text>
    <xsl:call-template name="semester-id"/>
    <xsl:text>/</xsl:text>
    <xsl:choose>
      <xsl:when test="$nr > 300"> <!-- FIXME -->
        <!-- Spaltenzahl -->
        <xsl:choose>
          <xsl:when test="$nr mod 2 > 0">
            <xsl:number value="$nr" format="0001"/>
            <xsl:text>-</xsl:text>
            <xsl:number value="$nr + 1" format="0001"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:number value="$nr - 1" format="0001"/>
            <xsl:text>-</xsl:text>
            <xsl:number value="$nr" format="0001"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- normale Seitenzahl -->
        <xsl:number value="$nr" format="001"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>.png</xsl:text>
  </xsl:template>

  <xsl:template name="semester-id">
    <xsl:value-of select="/v:vv/v:kopf/v:beginn/v:jahr"/>
    <xsl:text>-</xsl:text>
    <xsl:choose>
      <xsl:when test="/v:vv/v:kopf/v:semester = 'Sommer'">
        <xsl:text>ss</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>ws</xsl:text>
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

</xsl:stylesheet>