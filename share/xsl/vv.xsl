<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://histvv.uni-leipzig.de/ns/2007"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="v">

  <xsl:import href="common.xsl"/>
  <xsl:import href="histvv2html.xsl"/>

  <xsl:variable name="seitenlinklabel">
    <xsl:choose>
      <xsl:when test="/v:vv/@paginierung = 'spalten'">
        <xsl:text>Spalte</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Seite</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template name="content">
    <xsl:apply-templates select="/index|/v:vv"/>
  </xsl:template>

  <xsl:template name="htmltitle">
    <xsl:choose>
      <xsl:when test="/v:vv">
        <xsl:text>Vorlesungsverzeichnis </xsl:text>
        <xsl:value-of select="/v:vv/v:kopf/v:semester"/>
        <xsl:text>semester </xsl:text>
        <xsl:value-of select="/v:vv/v:kopf/v:beginn/v:jahr"/>
        <xsl:if test="/v:vv/v:kopf/v:semester = 'Winter'">
          <xsl:text>/</xsl:text>
          <xsl:value-of select="/v:vv/v:kopf/v:ende/v:jahr"/>
        </xsl:if>
        <xsl:text> -- Universität </xsl:text>
        <xsl:value-of select="/v:vv/v:kopf/v:universität"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Vorlesungsverzeichnisse</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="scripts">
    <script type="text/javascript" src="http://www.google.com/jsapi"></script>
    <script type="text/javascript" src="/js/jquery.gvChart-1.0.1.min.js"></script>
    <script type="text/javascript" src="/js/vv.js"></script>
  </xsl:template>

  <xsl:template match="/index">
    <h1>Vorlesungsverzeichnisse</h1>
    <ol class="toc">
      <xsl:apply-templates select="vv" mode="list"/>
    </ol>

    <xsl:variable name="x" select="count(vv[komplett])"/>
    <xsl:variable name="n" select="count(vv)"/>
    <xsl:variable name="cnt">
      <xsl:if test="$n > $x">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="$x"/>
        <xsl:text> von </xsl:text>
        <xsl:value-of select="$n"/>
        <xsl:text> Semestern)</xsl:text>
      </xsl:if>
    </xsl:variable>

    <table id="numvv" style="display: none">
      <caption>Veranstaltungen pro Semester <xsl:value-of select="$cnt"/></caption>
      <thead>
        <tr>
          <th></th>
          <xsl:for-each select="vv">
            <th><xsl:value-of select="@name"/></th>
          </xsl:for-each>
        </tr>
      </thead>
      <tbody>
        <tr>
          <th>Gesamt</th>
          <xsl:for-each select="vv">
            <td><xsl:value-of select="vnum"/></td>
          </xsl:for-each>
        </tr>
      </tbody>
    </table>

    <script type="text/javascript">
      gvChartInit();
      jQuery(document).ready(function(){
        jQuery('#numvv').gvChart({
          chartType: 'ColumnChart',
          gvSettings: {
            chartArea: {left: 50, top: 50},
            colors: ['7a6e3a', 'green', 'orange'],
            titleTextStyle: {color: '41524a', fontName: 'Verdana'},
            fontSize: 12,
            legend: {position: 'none'},
            width: 750,
            height: 300
          }
        });
      });
    </script>
  </xsl:template>

  <xsl:template match="/index/vv" mode="list">
    <li><xsl:value-of select="titel"/></li>
  </xsl:template>

  <xsl:template match="/index/vv[komplett]" mode="list">
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
  </xsl:template>

  <xsl:template match="/v:vv">
    <xsl:attribute name="class">vv</xsl:attribute>
    <xsl:if test="//v:seite">
      <xsl:call-template name="seitennavigation"/>
    </xsl:if>
    <xsl:if test="v:kopf/v:quelle">
      <p class="quelle">
        <xsl:text>Quelle: </xsl:text>
        <xsl:value-of select="v:kopf/v:quelle"/>
      </p>
    </xsl:if>
    <xsl:apply-templates select="v:titel | v:absatz | v:übersicht |
                                 v:sachgruppe | v:seite | v:trennlinie"/>
  </xsl:template>

  <xsl:template match="/v:vv/v:titel">
    <h1><xsl:value-of select="."/></h1>
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
    <a title="{$seitenlinklabel} {$nr}: zum Scan">
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
      <xsl:when test="string(number($nr)) = 'NaN'">
        <!-- Buchstabe -->
        <xsl:text>000</xsl:text>
        <xsl:value-of select="$nr"/>
      </xsl:when>
      <xsl:when test="/v:vv/@paginierung = 'spalten'">
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
    <xsl:choose>
      <xsl:when test="/v:vv/v:kopf/v:semester = 'Sommer'">
        <xsl:text>s</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>w</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="seitennavigation">
    <ul id="seitennavigation">
      <xsl:if test="/v:vv/@paginierung = 'spalten'">
        <xsl:attribute name="class">spalten</xsl:attribute>
      </xsl:if>
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
