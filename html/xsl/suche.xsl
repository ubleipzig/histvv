<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://histvv.uni-leipzig.de/ns/2007"
                xmlns:str="http://exslt.org/strings"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="v str"
                extension-element-prefixes="str">

  <xsl:import href="common.xsl"/>
  <xsl:import href="histvv2html.xsl"/>

  <xsl:variable name="start" select="/report/stellen/@start"/>
  <xsl:variable name="interval" select="/report/stellen/@interval"/>
  <xsl:variable name="total" select="/report/stellen/@total"/>

  <xsl:variable name="query">
    <xsl:text>volltext=</xsl:text>
    <xsl:value-of select="str:encode-uri(/report/suche/text, true())"/>
    <xsl:text>&amp;dozent=</xsl:text>
    <xsl:value-of select="str:encode-uri(/report/suche/dozent, true())"/>
    <xsl:text>&amp;von=</xsl:text>
    <xsl:value-of select="/report/suche/von"/>
    <xsl:text>&amp;bis=</xsl:text>
    <xsl:value-of select="/report/suche/bis"/>
    <xsl:text>&amp;fakultaet=</xsl:text>
    <xsl:value-of select="str:encode-uri(/report/suche/fakultaet, true())"/>
    <xsl:text>&amp;l=</xsl:text>
    <xsl:value-of select="$interval"/>
  </xsl:variable>

  <xsl:template name="content">
    <xsl:attribute name="class">suchergebnis</xsl:attribute>
    <xsl:apply-templates select="/report"/>
  </xsl:template>

  <xsl:template name="htmltitle">
    <xsl:choose>
      <xsl:when test="/report/stellen">
        <xsl:text>Suchergebnis</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Veranstaltungssuche</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/report[suche]">
    <h1>
      <xsl:text>Suchergebnis (</xsl:text>
      <xsl:value-of select="stellen/@total"/>
      <xsl:text> Treffer)</xsl:text>
    </h1>

    <p><xsl:value-of select="/report/suche/text"/></p>

    <form method="get" action="./?" class="treffer-pro-seite">
      <input type="hidden" name="volltext" value="{/report/suche/text}"/>
      <input type="hidden" name="dozent" value="{/report/suche/dozent}"/>
      <input type="hidden" name="von" value="{/report/suche/von}"/>
      <input type="hidden" name="bis" value="{/report/suche/bis}"/>
      <input type="hidden" name="fakultaet" value="{/report/suche/fakultaet}"/>
      <input type="hidden" name="start" value="1"/>
      <label for="f-treffer-pro-seite">Treffer pro Seite:</label>
      <select name="l" id="f-treffer-pro-seite">
        <xsl:for-each select="str:tokenize('10 20 50 100')">
          <option>
            <xsl:if test=". = $interval">
              <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
          </option>
        </xsl:for-each>
      </select>
      <noscript>
        <input type="submit" value="Anzeigen"/>
      </noscript>
    </form>

    <xsl:call-template name="pager"/>

    <xsl:apply-templates select="stellen"/>

    <xsl:call-template name="pager"/>
  </xsl:template>

  <xsl:template match="stellen">
    <table class="suchergebnis">
      <thead>
        <tr>
          <th class="nr">#</th>
          <th>Dozent</th>
          <th>Veranstaltung</th>
          <th>Semester</th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates select="stelle"/>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match="stelle">
    <tr>
      <xsl:if test="position() mod 2">
        <xsl:attribute name="class">odd</xsl:attribute>
      </xsl:if>
      <td class="nr">
        <xsl:value-of select="position() + $start - 1"/>
      </td>
      <td>
        <xsl:for-each select="dozenten/v:dozent">
          <xsl:apply-templates select="."/>
          <xsl:if test="not(position() = last())">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </td>
      <td>
        <xsl:value-of select="thema"/>
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
            <xsl:text>.html#</xsl:text>
            <xsl:value-of select="@id"/>
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
        </a>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="dozenten/v:dozent">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="dozenten/v:dozent[@ref]">
    <a>
      <xsl:attribute name="href">
        <xsl:text>/dozenten/</xsl:text>
        <xsl:value-of select="@ref"/>
        <xsl:text>.html</xsl:text>
      </xsl:attribute>
      <xsl:value-of select="."/>
    </a>
  </xsl:template>

  <xsl:template name="pager">
    <ul class="pager">
      <li class="previous">
        <xsl:choose>
          <xsl:when test="$start &gt; 1">
            <a>
              <xsl:attribute name="href">
                <xsl:text>./?</xsl:text>
                <xsl:value-of select="$query"/>
                <xsl:text>&amp;start=</xsl:text>
                <xsl:choose>
                  <xsl:when test="$start - $interval > 0">
                    <xsl:value-of select="$start - $interval"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>1</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:text>vorherige Seite</xsl:text>
            </a>
          </xsl:when>
          <xsl:otherwise><i>vorherige Seite</i></xsl:otherwise>
        </xsl:choose>
      </li>
      <li class="next">
        <xsl:choose>
          <xsl:when test="$start + $interval &lt;= $total">
            <a>
              <xsl:attribute name="href">
                <xsl:text>./?</xsl:text>
                <xsl:value-of select="$query"/>
                <xsl:text>&amp;start=</xsl:text>
                <xsl:value-of select="$start + $interval"/>
              </xsl:attribute>
              <xsl:text>nächste Seite</xsl:text>
            </a>
          </xsl:when>
          <xsl:otherwise><i>nächste Seite</i></xsl:otherwise>
        </xsl:choose>
      </li>
    </ul>
  </xsl:template>

</xsl:stylesheet>
