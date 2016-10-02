<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://histvv.uni-leipzig.de/ns/2007"
                xmlns:str="http://exslt.org/strings"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="v str"
                extension-element-prefixes="str">

  <xsl:import href="common.xsl"/>
  <xsl:import href="histvv2html.xsl"/>

  <xsl:template name="content">
    <xsl:apply-templates select="/report"/>
  </xsl:template>

  <xsl:template name="htmltitle">
    <xsl:choose>
      <xsl:when test="/v:dozent">
        <xsl:apply-templates select="/v:dozent/v:name"/>
      </xsl:when>
      <xsl:when test="/report/element">
        <xsl:text>Element: </xsl:text>
        <xsl:value-of select="/report/element"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Elements</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/report">
    <h1>Element „<xsl:value-of select="element"/>“</h1>
    <xsl:if test="wert">
      <h2>Wert: „<xsl:value-of select="wert"/>“</h2>
    </xsl:if>
    <xsl:apply-templates select="werte|stellen"/>
  </xsl:template>

  <xsl:template match="/report/werte">
    <h3>Werte</h3>
    <ol>
      <xsl:apply-templates select="w"/>
    </ol>
  </xsl:template>

  <xsl:template match="/report/werte/w">
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="/report/element"/>
          <xsl:text>?w=</xsl:text>
          <xsl:value-of select="str:encode-uri(., true())"/>
        </xsl:attribute>
        <xsl:value-of select="."/>
      </a>
    </li>
  </xsl:template>

  <xsl:template match="/report/stellen">
    <h3>Stellen</h3>
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
            <xsl:choose>
              <xsl:when test="@semester = 'Sommer'">
                <xsl:text>s</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>w</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text>.html</xsl:text>
            <xsl:if test="@seite &gt; 0">
              <xsl:text>#seite</xsl:text>
              <xsl:value-of select="@seite"/>
            </xsl:if>
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
          <xsl:if test="@seite &gt; 0">
            <xsl:text>, S. </xsl:text>
            <xsl:value-of select="@seite"/>
          </xsl:if>
        </a>
      </td>
      <td>
        <xsl:value-of select="."/>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>
