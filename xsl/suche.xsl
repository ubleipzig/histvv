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
    <xsl:choose>
      <xsl:when test="/report/stellen">
        <xsl:attribute name="class">suchergebnis</xsl:attribute>
        <xsl:apply-templates select="/report"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="/formular"/>
      </xsl:otherwise>
    </xsl:choose>
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

  <xsl:template match="/formular">
    <h1>Veranstaltungssuche</h1>

    <form id="suchformular" class="suche" action="/suchergebnisse/">
      <p class="widget">
        <label for="f-volltext">Volltext <a href="#hilfe-volltext">[i]</a></label>
        <br/>
        <input type="text" id="f-volltext" name="volltext" value=""/>
      </p>

      <p class="widget">
        <label for="f-dozent">Dozent <a href="#hilfe-dozenten">[i]</a></label>
        <br/>
        <input type="text" id="f-dozent" name="dozent" value=""/>
      </p>

      <fieldset>
        <legend>Semester <a href="#hilfe-semester">[i]</a></legend>
        <span class="widget">
          <label for="f-von">von</label>
          <select name="von" id="f-von">
            <xsl:for-each select=".//semester">
              <option value="{name}">
                <xsl:value-of select="titel"/>
              </option>
            </xsl:for-each>
          </select>
        </span>
        <span class="widget">
          <label for="f-bis">bis</label>
          <select name="bis" id="f-bis">
            <xsl:for-each select=".//semester">
              <option value="{name}">
                <xsl:if test="position() = last()">
                  <xsl:attribute name="selected">selected</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="titel"/>
              </option>
            </xsl:for-each>
          </select>
        </span>
      </fieldset>

      <fieldset id="fs-fakultaeten">
        <legend>Fakultäten <a href="#hilfe-fakultaeten">[i]</a></legend>
        <xsl:if test="fakultäten/fakultät[.='Theologie']">
          <label class="widget">
            <input name="fakultaet" type="checkbox" value="Theologie" />
            Theologische Fakultät
          </label>
        </xsl:if>
        <xsl:if test="fakultäten/fakultät[.='Philosophie']">
          <label class="widget">
            <input name="fakultaet" type="checkbox" value="Philosophie" />
            Philosophische Fakultät
          </label>
        </xsl:if>
        <xsl:if test="fakultäten/fakultät[.='Jura']">
          <label class="widget">
            <input name="fakultaet" type="checkbox" value="Jura" />
            Juristische Fakultät
          </label>
        </xsl:if>
        <xsl:if test="fakultäten/fakultät[.='Staatswissenschaften']">
          <label class="widget">
            <input name="fakultaet" type="checkbox" value="Staatswissenschaften" />
            Staatwissenschaftliche Fakultät
          </label>
        </xsl:if>
        <xsl:if test="fakultäten/fakultät[.='Medizin']">
          <label class="widget">
            <input name="fakultaet" type="checkbox" value="Medizin" />
            Medizinische Fakultät
          </label>
        </xsl:if>
        <xsl:if test="fakultäten/fakultät[.='Zahnmedizin']">
          <label class="widget">
            <input name="fakultaet" type="checkbox" value="Zahnmedizin" />
            Zahnärztliche Schule
          </label>
        </xsl:if>
      </fieldset>

      <p class="buttonbar">
        <input type="submit" value="Veranstaltungen suchen"/>
        <br class="clear"/>
      </p>
    </form>

    <div id="hilfe">
      <h2>Hilfe</h2>

      <div id="hilfe-volltext">
        <h3>Volltext</h3>

        <p>
          Die Volltextsuche bezieht sich auf den gesamten Text
          innerhalb von Veranstaltungen. Sie eignet sich sowohl für
          die Suche nach Dozenten als auch Veranstaltungsthemen.
        </p>
      </div>

      <div id="hilfe-semester">
        <h3>Semester</h3>
        <p>
          Mit den Semesterangaben kann der Suchzeitraum eingeschränkt
          werden. Es werden nur Veranstaltungen gefunden, die
          innerhalb der angegebenen Zeitspanne angeboten wurden.
        </p>
      </div>

      <div id="hilfe-dozenten">
        <h3>Dozenten</h3>
        <p>
          Die Dozentensuche berücksichtigt den kompletten Text der
          Dozentenelemente (inklusive Graden und Funktionen).
        </p>
      </div>

      <div id="hilfe-fakultaeten">
        <h3>Fakultäten</h3>
        <p>
          Hiermit kann die Suche auf einzelne oder mehrere Fakultäten
          beschränkt werden.
        </p>
      </div>
    </div>
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
    <table class="veranstaltungsliste">
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
    <xsl:apply-templates select="*|text()" mode="filter-seite"/>
  </xsl:template>

  <xsl:template match="dozenten/v:dozent[@ref]">
    <a>
      <xsl:attribute name="href">
        <xsl:text>/dozenten/</xsl:text>
        <xsl:value-of select="@ref"/>
        <xsl:text>.html</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="*|text()" mode="filter-seite"/>
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
