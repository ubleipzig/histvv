<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="h">

  <xsl:output method="xml" encoding="utf-8"
    omit-xml-declaration="yes" indent="yes"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <xsl:param name="histvv-url"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="h:div[@id='header']/h:h6">
    <h6>
      <xsl:value-of select="."/>
      <xsl:text> der Universität Leipzig</xsl:text>
    </h6>
  </xsl:template>

  <xsl:template match="h:div[@id='footer']">
    <div id="footer">
      <p>
        © 2008-2012
        <a href="http://www.ub.uni-leipzig.de/">
          Universitätsbibliothek Leipzig
        </a>
      </p>
      <p class="dfg">
        <a href="http://www.dfg.de/">
          <img src="/img/dfg.png" alt="DFG"
               title="Gefördert durch die Deutsche Forschungsgemeinschaft"/>
        </a>
      </p>
    </div>
  </xsl:template>

  <xsl:template match="h:div[@id='sidebar']/h:ul">
    <ul>
      <xsl:apply-templates/>
      <li>
        <xsl:if test="starts-with($histvv-url, '/doku/')">
          <xsl:attribute name="class">current</xsl:attribute>
        </xsl:if>
        <a href="/doku/">Dokumentation</a>
      </li>
    </ul>
  </xsl:template>

  <xsl:template match="h:div[@id='content']/h:p[@class='quelle'][1]">
    <p class="quelle">
      <xsl:apply-templates/>
      <xsl:text> (</xsl:text>
      <a href="/doku/vorlagen.html">Übersicht über alle Vorlagen</a>
      <xsl:text>)</xsl:text>
    </p>
  </xsl:template>

  <xsl:template match="h:div[@id='content' and @class='dozentenliste']/h:p[@class='galerielink']">
    <p class="galerielink">
      <xsl:text>Ein Übersicht über alle Leipziger Dozenten der Jahre
      1814/15 bis 1914, die in der Datenbank mit Porträtbild erfasst
      sind, findet sich in der </xsl:text>
      <xsl:apply-templates select="h:a"/>
      <xsl:text>.</xsl:text>
    </p>
  </xsl:template>

  <xsl:template match="h:div[@id='content' and @class='dozentengalerie']/h:p">
    <p>
      Diese Galerie zeigt alle Leipziger Dozenten der Jahre 1814/15
      bis 1914, die in der Datenbank mit Porträtbild erfasst sind. Eine
      Liste aller Dozenten gibt es <a href="/dozenten/">auf dieser
      Seite</a>.
    </p>
  </xsl:template>

</xsl:stylesheet>
