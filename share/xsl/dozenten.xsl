<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://histvv.uni-leipzig.de/ns/2007"
                xmlns:str="http://exslt.org/strings"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="v str"
                extension-element-prefixes="str">

  <xsl:import href="common.xsl"/>
  <xsl:import href="histvv2html.xsl"/>

  <xsl:variable name="anfangsbuchstaben"
    select="str:tokenize('A B C D E F G H I J K L M N O P Q R S T U V W X Y Z')"/>

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
        <xsl:when test="/v:dozentenliste and $histvv-url = '/dozenten/galerie.html'">
          <xsl:text>dozentengalerie</xsl:text>
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
        <xsl:apply-templates select="/report/v:dozent/v:name" mode="kurz"/>
        <xsl:if test="/report/v:dozent/v:geboren/v:jahr or /report/v:dozent/v:gestorben/v:jahr">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="/report/v:dozent/v:geboren/v:jahr"/>
          <xsl:text>-</xsl:text>
          <xsl:value-of select="/report/v:dozent/v:gestorben/v:jahr"/>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:when test="/report/name">
        <xsl:text>Name: </xsl:text>
        <xsl:value-of select="/report/name"/>
      </xsl:when>
      <xsl:when test="/v:dozentenliste and $histvv-url='/dozenten/namen.html'">
        <xsl:text>Dozentennamen</xsl:text>
      </xsl:when>
      <xsl:when test="/v:dozentenliste and $histvv-url='/dozenten/galerie.html'">
        <xsl:text>Dozentengalerie</xsl:text>
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
        <xsl:call-template name="namensliste">
          <xsl:with-param name="dozenten" select="v:dozent"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$histvv-url = '/dozenten/galerie.html'">
        <h1>Dozentengalerie</h1>
        <xsl:call-template name="dozentengalerie">
          <xsl:with-param name="dozenten" select="v:dozent[v:bild]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <h1>Dozenten</h1>
        <xsl:call-template name="dozentenliste">
          <xsl:with-param name="dozenten" select="v:dozent[@xml:id]"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="dozentenliste">
    <xsl:param name="dozenten"/>
    <ul class="nav">
      <xsl:for-each select="$anfangsbuchstaben">
        <xsl:variable name="a" select="."/>
        <xsl:if test="$dozenten[starts-with(v:name/v:nachname, $a)]">
          <li>
            <a>
              <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="."/>
              </xsl:attribute>
              <xsl:value-of select="."/>
            </a>
          </li>
        </xsl:if>
      </xsl:for-each>
    </ul>
    <div class="toc">
    <xsl:for-each select="$anfangsbuchstaben">
      <xsl:variable name="a" select="."/>
      <xsl:variable name="d" select="$dozenten[starts-with(v:name/v:nachname, $a)]"/>
      <xsl:if test="$d">
        <div>
          <h3 id="{$a}"><xsl:value-of select="$a"/></h3>
          <ul>
            <xsl:for-each select="$d">
              <li>
                <a href="{@xml:id}.html">
                  <xsl:apply-templates select="v:name" mode="kurz"/>
                </a>
                <xsl:if test="v:geboren/v:jahr or v:gestorben/v:jahr">
                  <xsl:text> (</xsl:text>
                  <xsl:value-of select="v:geboren/v:jahr"/>
                  <xsl:text>-</xsl:text>
                  <xsl:value-of select="v:gestorben/v:jahr"/>
                  <xsl:text>) </xsl:text>
                </xsl:if>
                <xsl:variable name="id" select="@xml:id"/>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </xsl:if>
    </xsl:for-each>
    </div>

    <xsl:if test="$dozenten[v:bild]">
      <p class="galerielink">
        Ein Übersicht über alle Dozenten, die in der Datenbank mit
        Porträtbild erfasst sind, findet sich in der
        <a href="/dozenten/galerie.html">Dozentengalerie</a>.
      </p>
    </xsl:if>

  </xsl:template>

  <xsl:template name="dozentengalerie">
    <xsl:param name="dozenten"/>
    <ul class="nav">
      <xsl:for-each select="$anfangsbuchstaben">
        <xsl:variable name="a" select="."/>
        <xsl:if test="$dozenten[starts-with(v:name/v:nachname, $a)]">
          <li>
            <a>
              <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="."/>
              </xsl:attribute>
              <xsl:value-of select="."/>
            </a>
          </li>
        </xsl:if>
      </xsl:for-each>
    </ul>

    <p>Diese Galerie zeigt alle Dozenten, die in der Datenbank mit
    Porträtbild erfasst sind. Eine Liste aller Dozenten gibt es
    <a href="/dozenten/">auf dieser Seite</a>.</p>

    <div class="galerie">
    <xsl:for-each select="$anfangsbuchstaben">
      <xsl:variable name="a" select="."/>
      <xsl:variable name="d" select="$dozenten[starts-with(v:name/v:nachname, $a)]"/>
      <xsl:if test="$d">
        <h3 id="{$a}"><xsl:value-of select="$a"/></h3>
        <ul>
          <xsl:for-each select="$d">
            <li>
              <a href="{@xml:id}.html">
                <img alt="">
                  <xsl:attribute name="src">
                    <xsl:text>/dozenten/</xsl:text>
                    <xsl:value-of select="v:bild/@name"/>
                  </xsl:attribute>
                </img>
                <xsl:apply-templates select="v:name" mode="kurz"/>
              </a>
              <xsl:if test="v:geboren/v:jahr or v:gestorben/v:jahr">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="v:geboren/v:jahr"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="v:gestorben/v:jahr"/>
                <xsl:text>) </xsl:text>
              </xsl:if>
              <xsl:variable name="id" select="@xml:id"/>
            </li>
          </xsl:for-each>
        </ul>
      </xsl:if>
    </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template name="namensliste">
    <xsl:param name="dozenten"/>
    <ol class="toc">
      <xsl:for-each select="$dozenten">
        <li>
          <xsl:choose>
            <xsl:when test="@xml:id">
              <a href="{@xml:id}.html">
                <xsl:apply-templates select="v:name" mode="kurz"/>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="v:name"/>
              <xsl:text> </xsl:text>
              <a>
                <xsl:attribute name="href">                  
                  <xsl:text>lookup?name=</xsl:text>
                  <xsl:value-of select="str:encode-uri(v:name/v:nachname, true())"/>
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
    <xsl:if test="stellen/stelle">
      <h3 id="veranstaltungen">Veranstaltungen</h3>
      <xsl:apply-templates select="stellen"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/report[name]">
    <h1>Name „<xsl:value-of select="name"/>“</h1>
    <h3>Veranstaltungen</h3>
    <xsl:apply-templates select="stellen"/>
  </xsl:template>

  <xsl:template match="report/v:dozent">
    <xsl:if test="v:bild">
      <div class="portrait">
        <img alt="">
          <xsl:attribute name="src">
            <xsl:text>/dozenten/</xsl:text>
            <xsl:value-of select="v:bild/@name"/>
          </xsl:attribute>
        </img>
        <xsl:if test="v:bild/v:quelle">
          <p>
            <xsl:text>Bildquelle: </xsl:text>
            <xsl:apply-templates select="v:bild/v:quelle"/>
          </p>
        </xsl:if>
      </div>
    </xsl:if>
    <h1>
      <xsl:apply-templates select="v:name" mode="lang"/>
    </h1>
    <xsl:if test="v:geboren or v:gestorben">
      <ul class="lebensdaten">
        <xsl:if test="v:geboren">
          <li title="geboren">
            <xsl:text>* </xsl:text>
            <xsl:apply-templates select="v:geboren"/>
          </li>
        </xsl:if>
        <xsl:if test="v:gestorben">
          <li title="gestorben">
            <xsl:text>† </xsl:text>
            <xsl:apply-templates select="v:gestorben"/>
          </li>
        </xsl:if>
      </ul>
    </xsl:if>
    <xsl:apply-templates select="v:beruf"/>
    <xsl:apply-templates select="v:absatz"/>
    <xsl:apply-templates select="v:pnd"/>
    <xsl:if test="v:url or v:adb[v:url] or v:ndb[v:url]">
      <h3>Links</h3>
      <ul>
        <xsl:for-each select="v:adb[v:url] | v:ndb[v:url]">
          <li><xsl:apply-templates select="." mode="linkliste"/></li>
        </xsl:for-each>
        <xsl:for-each select="v:url">
          <xsl:sort data-type="number" order="descending"
             select="(9 * number(starts-with(., 'http://de.wikipedia.org')))
                   + (8 * number(starts-with(., 'http://en.wikipedia.org')))
                   + (7 * number(starts-with(., 'http://www.uni-leipzig.de/unigeschichte/professorenkatalog/')))
                   + (6 * number(starts-with(., 'http://catalogus-professorum-halensis.de/')))
                   + (5 * number(starts-with(., 'http://cpr.uni-rostock.de/')))
                   + (4 * number(starts-with(., 'http://www.zeno.org/Pagel-1901/')))
                   + (3 * number(starts-with(., 'http://www.bautz.de/bbkl/')))
                   + (2 * number(starts-with(., 'http://saebi.isgv.de/')))
                   + (1 * number(starts-with(., 'http://personen-wiki.slub-dresden.de/')))" />
          <li><xsl:apply-templates select="." mode="linkliste"/></li>
        </xsl:for-each>
      </ul>
    </xsl:if>
    <xsl:if test="v:quelle or v:adb[not(v:url)] or v:ndb[not(v:url)]">
      <h3>Quellen</h3>
      <ul>
        <xsl:for-each select="v:quelle | v:adb[not(v:url)] | v:ndb[not(v:url)]">
          <li><xsl:apply-templates select="."/></li>
        </xsl:for-each>
      </ul>
    </xsl:if>
    <xsl:if test="v:anmerkungen">
      <h3>Anmerkungen</h3>
      <xsl:apply-templates select="v:anmerkungen/v:absatz"/>
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
    <xsl:apply-templates select="v:ort"/>
  </xsl:template>

  <xsl:template match="v:geboren/v:ort | v:gestorben/v:ort">
    <xsl:text> in </xsl:text>
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="v:gestorben/v:ort[../../v:geboren/v:ort = .]">
    <xsl:text> ebenda</xsl:text>
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

  <xsl:template match="v:dozent/v:beruf">
    <p class="beruf">
      <xsl:value-of select="."/>
    </p>
  </xsl:template>

  <xsl:template match="v:dozent/v:name">
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

  <xsl:template match="v:dozent/v:name" mode="kurz">
    <xsl:value-of select="v:nachname"/>
    <xsl:if test="v:vorname">
      <xsl:text>, </xsl:text>
      <xsl:choose>
        <xsl:when test="v:vorname/v:rufname">
          <xsl:for-each select="v:vorname/v:rufname">
            <xsl:value-of select="."/>
            <xsl:if test="not(position() = last())">
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="v:vorname"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="v:nachnamenpräfix">
        <xsl:text> </xsl:text>
        <xsl:value-of select="v:nachnamenpräfix"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="v:dozent/v:name" mode="lang">
    <xsl:apply-templates select="v:nachname"/>
    <xsl:if test="v:vorname">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="v:vorname"/>
      <xsl:if test="v:nachnamenpräfix">
        <xsl:text> </xsl:text>
        <xsl:value-of select="v:nachnamenpräfix"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="v:dozent/v:bild/v:quelle">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="v:dozent/v:bild/v:quelle[@url]">
    <a href="{@url}">
      <xsl:value-of select="."/>
    </a>
  </xsl:template>

  <xsl:template match="/report/stellen">
    <table class="veranstaltungsliste">
      <thead>
        <tr>
          <th class="nr">#</th>
          <th>Semester</th>
          <th>Veranstaltung</th>
          <th class="grad" title="in Veranstaltungsankündigung angegebener akademischer Grad">
            Grad
          </th>
          <th class="fn" title="in Veranstaltungsankündigung angegebene akademische Funktion">
            Funktion
          </th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates select="stelle"/>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match="/report/stellen/stelle">
    <xsl:variable name="id" select="/report/v:dozent/@xml:id"/>
    <tr>
      <xsl:if test="position() mod 2">
        <xsl:attribute name="class">odd</xsl:attribute>
      </xsl:if>
      <td class="nr">
        <xsl:value-of select="position()"/>.
      </td>
      <td class="semester">
        <a>
          <xsl:attribute name="href">
            <xsl:text>/vv/</xsl:text>
            <xsl:value-of select="@semester"/>
            <xsl:text>.html#</xsl:text>
            <xsl:value-of select="v:veranstaltung/@xml:id"/>
          </xsl:attribute>
          <xsl:variable name="jahr" select="substring(@semester, 1, 4)"/>
          <xsl:choose>
            <xsl:when test="contains(@semester,'s')">
              <xsl:text>SS </xsl:text>
              <xsl:value-of select="$jahr"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>WS </xsl:text>
              <xsl:value-of select="$jahr"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="@seite">
            <xsl:text>, S. </xsl:text>
            <xsl:value-of select="@seite"/>
          </xsl:if>
        </a>
      </td>
      <td>
        <xsl:value-of select="v:veranstaltung/@x-thema"/>
      </td>
      <td class="grad">
        <xsl:for-each select=".//v:dozent[@ref=$id]/v:grad">
          <xsl:apply-templates select="." mode="text-without-page-number"/>
          <xsl:if test="not(position() = last())">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </td>
      <td class="fn">
        <xsl:for-each select=".//v:dozent[@ref=$id]/v:funktion">
          <xsl:apply-templates select="." mode="text-without-page-number"/>
          <xsl:if test="not(position() = last())">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="v:url" mode="linkliste">
    <a>
      <xsl:attribute name="href">
        <xsl:value-of select="."/>
      </xsl:attribute>
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
        <xsl:when test="starts-with(., 'http://histvv.uni-leipzig.de/')">
          <xsl:text>Lehrveranstaltungen an der Universität Leipzig</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(., 'http://www.catalogus-professorum-halensis.de/')">
          <xsl:text>Hallenser Professorenkatalog</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(., 'http://cpr.uni-rostock.de/')">
          <xsl:text>Rostocker Professorenkatalog</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(., 'http://www.bautz.de/bbkl/')">
          <xsl:text>Biographisch-Bibliographisches Kirchenlexikon</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(., 'http://www.zeno.org/Pagel-1901/')">
          <xsl:text>Biographisches Lexikon hervorragender Ärzte des neunzehnten Jahrhunderts (1901)</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(., 'http://personen-wiki.slub-dresden.de/')">
          <xsl:text>Personen-Wiki der </xsl:text>
          <abbr title="Sächsische Landesbibliothek - Staats- und Universitätsbibliothek">SLUB</abbr>
          <xsl:text> Dresden</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(., 'http://saebi.isgv.de/biografie/')">
          <xsl:text>Sächsische Biografie</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

  <xsl:template match="v:dozent/v:adb[v:url] | v:dozent/v:ndb[v:url]" mode="linkliste">
    <a>
      <xsl:attribute name="href">
        <xsl:value-of select="v:url"/>
      </xsl:attribute>
      <xsl:apply-templates select="."/>
    </a>
  </xsl:template>

  <xsl:template match="v:dozent/v:adb | v:dozent/v:ndb">
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
  </xsl:template>

  <xsl:template match="*" mode="text-without-page-number">
    <xsl:choose>
      <xsl:when test="self::text()">
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:when test="local-name() = 'seite'">
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="./node()">
          <xsl:apply-templates select="." mode="text-without-page-number"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
