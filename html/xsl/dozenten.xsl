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
      <xsl:when test="/v:dozentenliste">
        <xsl:text>Dozentenliste</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Dozenten</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
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
    <xsl:for-each select="v:url">
      <p><xsl:apply-templates select="."/></p>
    </xsl:for-each>
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
    <p class="pnd">
      PND:
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

</xsl:stylesheet>
