<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://histvv.uni-leipzig.de/ns/2007"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="v">

  <xsl:import href="common.xsl"/>
  <xsl:import href="histvv2html.xsl"/>

  <xsl:template name="content">
    <xsl:attribute name="class">
      <xsl:choose>
        <xsl:when test="/report/v:dozent">
          <xsl:text>dozent</xsl:text>
        </xsl:when>
        <xsl:when test="/report/name">
          <xsl:text>dozent</xsl:text>
          <xsl:value-of select="/report/name"/>
        </xsl:when>
        <xsl:when test="/v:dozentenliste">
          <xsl:text>dozentenliste</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:attribute>

    <xsl:apply-templates select="/report|/v:dozentenliste"/>

  </xsl:template>

  <xsl:template name="htmltitle">
    <xsl:choose>
      <xsl:when test="/v:dozent">
        <xsl:apply-templates select="/v:dozent/v:name"/>
      </xsl:when>
      <xsl:when test="/report/v:dozent">
        <xsl:text>Dozent: </xsl:text>
        <xsl:apply-templates select="/report/v:dozent/v:name"/>
      </xsl:when>
      <xsl:when test="/report/name">
        <xsl:text>Name: </xsl:text>
        <xsl:value-of select="/report/name"/>
      </xsl:when>
      <xsl:when test="/v:dozentenliste and $histvv-url='/dozenten/namen.html'">
        <xsl:text>Dozentennamen</xsl:text>
      </xsl:when>
      <xsl:when test="/v:dozentenliste">
        <xsl:text>Dozentenliste</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Dozenten</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="v:dozentenliste">
    <xsl:choose>
      <xsl:when test="$histvv-url = '/dozenten/namen.html'">
        <h1>Dozentennamen</h1>
      </xsl:when>
      <xsl:otherwise>
        <h1>Dozenten</h1>
        <p>
          <i>Diese Liste enthält die bereits eindeutig identifizierten
          Dozenten. Vgl. auch die <a href="/dozenten/namen.html">Liste aller
          Dozentennamen</a>.</i>
        </p>
      </xsl:otherwise>
    </xsl:choose>
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
              <xsl:text> </xsl:text>
              <a>
                <xsl:attribute name="href">                  
                  <xsl:text>lookup?name=</xsl:text>
                  <!-- FIXME: this needs to be URL encoded -->
                  <xsl:value-of select="v:name/v:nachname"/>
                </xsl:attribute>
                <xsl:text>?</xsl:text>
              </a>
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

  <xsl:template match="/report[name]">
    <h1>Name „<xsl:value-of select="name"/>“</h1>
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
    <xsl:apply-templates select="v:pnd"/>
    <xsl:if test="v:url or v:adb or v:ndb">
      <h3>Links</h3>
      <ul>
        <xsl:for-each select="v:url | v:adb | v:ndb">
          <li><xsl:apply-templates select="." mode="linkliste"/></li>
        </xsl:for-each>
      </ul>
    </xsl:if>
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
      <xsl:text> in </xsl:text>
      <xsl:value-of select="v:ort"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="v:dozent/v:pnd">
    <p class="pnd">
      <abbr title="Personennamendatei">PND</abbr>:
      <a>
        <xsl:attribute name="href">
          <xsl:text>http://d-nb.info/gnd/</xsl:text>
          <xsl:value-of select="."/>
        </xsl:attribute>
        <xsl:value-of select="."/>
      </a>
    </p>
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

  <xsl:template match="/report/stellen">
    <table class="veranstaltungsliste">
      <xsl:apply-templates select="stelle"/>
    </table>
  </xsl:template>

  <xsl:template match="/report/stellen/stelle">
    <tr>
      <td class="nr">
        <xsl:value-of select="position()"/>.
      </td>
      <td class="semester">
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

  <xsl:template match="v:url" mode="linkliste">
    <xsl:variable name="text">
      <xsl:choose>
        <xsl:when test="starts-with(., 'http://de.wikipedia.org')">
          <xsl:text>Wikipedia</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(., 'http://en.wikipedia.org')">
          <xsl:text>Wikipedia (engl.)</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(., 'http://www.uni-leipzig.de/unigeschichte/professorenkatalog')">
          <xsl:text>Professorenkatalog der Universität Leipzig</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(., 'http://www.bautz.de/bbkl/')">
          <xsl:text>Biographisch-Bibliographisches Kirchenlexikon</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a>
      <xsl:attribute name="href">
        <xsl:value-of select="."/>
      </xsl:attribute>
      <xsl:value-of select="$text"/>
    </a>
  </xsl:template>

  <xsl:template match="v:dozent/v:adb | v:dozent/v:ndb" mode="linkliste">
    <a>
      <xsl:attribute name="href">
        <xsl:value-of select="v:url"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="local-name(.) = 'adb'">
          <abbr title="Allgemeine Deutsche Biographie">
            <xsl:text>ADB</xsl:text>
          </abbr>
        </xsl:when>
        <xsl:otherwise>
          <abbr title="Neue Deutsche Biographie">
            <xsl:text>NDB</xsl:text>
          </abbr>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>, Bd. </xsl:text>
      <xsl:value-of select="v:band"/>
      <xsl:text>, S. </xsl:text>
      <xsl:value-of select="v:seite"/>
    </a>
  </xsl:template>

</xsl:stylesheet>
