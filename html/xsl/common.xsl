<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://histvv.uni-leipzig.de/ns/2007"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="v">

  <xsl:output method="xml" encoding="utf-8"
    omit-xml-declaration="yes" indent="yes"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <xsl:param name="histvv-url"/>
  <xsl:param name="histvv-debug" select="false()"/>

  <xsl:template match="/">
    <xsl:call-template name="skeleton"/>
  </xsl:template>

  <xsl:template name="skeleton">
    <html lang="de">
      <head>
        <meta http-equiv="content-type" content="application/xhtml+xml; charset=utf-8"/>
        <link rel="icon" href="/css/gfx/favicon.png" type="image/png"/>
        <link rel="stylesheet" href="/css/histvv.css" type="text/css" title="Histvv"/>    
        <link rel="alternative stylesheet" href="/css/experimental.css" type="text/css" title="Experimental"/>    
        <link rel="alternative stylesheet" href="/css/structure.css" type="text/css" title="Structure"/>    
        <script type="text/javascript" src="/js/jquery.js"></script>
        <script type="text/javascript" src="/js/jquery.dimensions.js"></script>
        <script type="text/javascript" src="/js/jquery.tooltip.js"></script>
        <script type="text/javascript" src="/js/form.js"></script>
        <xsl:call-template name="scripts"/>
        <title><xsl:call-template name="htmltitle"/> [HistVV]</title>
      </head>
      <body>
        <div>
          <div id="header">
            <a href="/" title="Historische Vorlesungsverzeichnisse">
              <strong>HistVV</strong>
            </a>
            <h6>Historische Vorlesungsverzeichnisse der Universität Leipzig</h6>
          </div>

          <div id="content">
            <xsl:call-template name="content"/>
          </div>

          <hr/>

          <div id="sidebar">
            <xsl:call-template name="navigation"/>
          </div>

          <hr/>

          <div id="footer">
            <p>
              © 2008-2009
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
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="htmltitle">
  </xsl:template>

  <xsl:template name="scripts">
  </xsl:template>

  <xsl:template name="content">
  </xsl:template>

  <xsl:template name="navigation">
    <ul>
      <li>
        <xsl:if test="$histvv-url = '/' or $histvv-url = '/index.html'">
          <xsl:attribute name="class">current</xsl:attribute>
        </xsl:if>
        <a href="/">Home</a>
      </li>
      <li>
        <xsl:if test="starts-with($histvv-url, '/vv/')">
          <xsl:attribute name="class">current</xsl:attribute>
        </xsl:if>
        <a href="/vv/">Vorlesungsverzeichnisse</a>
      </li>
      <li>
        <xsl:if test="starts-with($histvv-url, '/dozenten/')">
          <xsl:attribute name="class">current</xsl:attribute>
        </xsl:if>
        <a href="/dozenten/">Dozenten</a>
      </li>
      <li>
        <xsl:if test="$histvv-url = '/suche.html' or starts-with($histvv-url, '/suche/')">
          <xsl:attribute name="class">current</xsl:attribute>
        </xsl:if>
        <a href="/suche.html">Suche</a>
      </li>
    </ul>
  </xsl:template>

  <!-- mode to filter element 'seite' -->
  <xsl:template match="*" mode="filter-seite">
    <xsl:apply-templates select="*|text()" mode="filter-seite"/>
  </xsl:template>

  <xsl:template match="text()" mode="filter-seite">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="v:seite" mode="filter-seite">
    <xsl:if test="$histvv-debug">
      <xsl:comment>
        <xsl:value-of select="."/>
      </xsl:comment>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
