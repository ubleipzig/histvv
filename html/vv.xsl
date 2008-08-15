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
        <link rel="stylesheet" href="{$cssurl}"/>
        <script type="text/javascript" src="../js/jquery.js"><xsl:text> </xsl:text></script>
        <script type="text/javascript" src="../js/jquery.dimensions.js"><xsl:text> </xsl:text></script>
        <script type="text/javascript" src="../js/jquery.tooltip.js"><xsl:text> </xsl:text></script>
        <script type="text/javascript" src="{$js-url}"><xsl:text> </xsl:text></script>
      </head>
      <body>
        <xsl:apply-templates select="v:vv|/index|/report|v:dozentenliste|/v:dozent"/>
      </body>
    </html>
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

  <xsl:template match="v:vv">
    <xsl:call-template name="seitennavigation"/>
    <a href="index.html">Index</a>
    <h1><xsl:value-of select="v:titel"/></h1>
    <xsl:apply-templates select="v:absatz|v:übersicht|v:sachgruppe|v:seite|v:trennlinie"/>
    <a href="index.html">Index</a>
  </xsl:template>

  <xsl:template match="v:dozentenliste">
    <h1>Dozenten</h1>
    <ol class="toc">
      <xsl:for-each select="v:dozent">
        <li>
          <xsl:choose>
            <xsl:when test="@xml:id">
              <a href="{@xml:id}.html">
                <xsl:apply-templates select="v:name"/>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="v:name"/>
            </xsl:otherwise>
          </xsl:choose>
        </li>
      </xsl:for-each>
    </ol>
  </xsl:template>

  <xsl:template match="/report[v:dozent]">
    <xsl:apply-templates select="v:dozent"/>
    <h3>Veranstaltungen</h3>
    <xsl:apply-templates select="stellen"/>
  </xsl:template>

  <xsl:template match="report/v:dozent">
    <h1>
      <xsl:apply-templates select="v:name"/>
    </h1>
    <xsl:if test="v:geboren or v:gestorben">
      <p>
        <xsl:if test="v:geboren">
          <span>
            <xsl:text>* </xsl:text>
            <xsl:apply-templates select="v:geboren"/>
          </span>
        </xsl:if>
        <br/>
        <xsl:text> </xsl:text>
        <xsl:if test="v:gestorben">
          <span>
            <xsl:text>† </xsl:text>
            <xsl:apply-templates select="v:gestorben"/>
          </span>
        </xsl:if>
      </p>
    </xsl:if>
    <xsl:apply-templates select="v:absatz"/>
    <xsl:apply-templates select="v:url"/>
    <xsl:apply-templates select="v:pnd"/>
  </xsl:template>

  <xsl:template match="v:dozent/v:geboren | v:dozent/v:gestorben">
    <xsl:if test="v:tag">
      <xsl:value-of select="v:tag"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="v:monat"/>
      <xsl:text>.</xsl:text>
    </xsl:if>
    <xsl:value-of select="v:jahr"/>
    <xsl:if test="v:ort">
      <xsl:text>, in </xsl:text>
      <xsl:value-of select="v:ort"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="v:dozent/v:pnd">
    <p class="pnd">PND: <xsl:value-of select="."/></p>
  </xsl:template>

  <xsl:template match="v:dozentenliste/v:dozent/v:name | /report/v:dozent/v:name">
    <xsl:value-of select="v:nachname"/>
    <xsl:if test="v:vorname">
      <xsl:text>, </xsl:text>
      <xsl:value-of select="v:vorname"/>
      <xsl:if test="v:nachnamenpräfix">
        <xsl:text> </xsl:text>
        <xsl:value-of select="v:nachnamenpräfix"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/report[v:dozent]/stellen">
    <table class="veranstaltungsliste">
      <xsl:apply-templates select="stelle"/>
    </table>
  </xsl:template>

  <xsl:template match="/report/stellen/stelle">
    <tr>
      <td class="nr">
        <xsl:value-of select="position()"/>.
      </td>
      <td class="semester" style="white-space: nowrap;">
        <a>
          <xsl:attribute name="href">
            <xsl:text>/vv/</xsl:text>
            <xsl:value-of select="@jahr"/>
            <xsl:text>-</xsl:text>
            <xsl:choose>
              <xsl:when test="@semester = 'Sommer'">
                <xsl:text>ss</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>ws</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text>.html#seite</xsl:text>
            <xsl:value-of select="@seite"/>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="@semester = 'Sommer'">
              <xsl:text>SS</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>WS</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text> </xsl:text>
          <xsl:value-of select="@jahr"/>
          <xsl:text>, S. </xsl:text>
          <xsl:value-of select="@seite"/>
        </a>
      </td>
      <td>
        <xsl:value-of select="."/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="v:trennlinie">
    <hr/>
  </xsl:template>

  <xsl:template match="v:absatz">
    <p><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="v:url">
    <xsl:variable name="url" select="normalize-space(.)"/>
    <p>
      <xsl:choose>
        <xsl:when test="not(contains($url, ' '))">
          <a href="{$url}"><xsl:value-of select="$url"/></a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </p>
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

  <xsl:template match="v:dozent[@ref]">
    <xsl:variable name="name" select="local-name()"/>
    <a class="dozent" href="../dozenten/{@ref}.html">
      <xsl:attribute name="title">
        <xsl:text>zur Dozentenseite</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates/>
    </a>
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
      <xsl:when test="/v:dozentenliste">
        <xsl:text>: Dozenten</xsl:text>
      </xsl:when>
      <xsl:when test="/v:dozent">
        <xsl:text>: </xsl:text>
        <xsl:apply-templates select="/v:dozent/v:name"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>: Vorlesungsverzeichnisse</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
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

</xsl:stylesheet>
