<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://histvv.uni-leipzig.de/ns/2007"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="v">

  <xsl:output method="xml" encoding="utf-8"
    omit-xml-declaration="yes" indent="yes"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <xsl:param name="url"/>

  <xsl:template match="/">
    <xsl:call-template name="skeleton"/>
  </xsl:template>

  <xsl:template name="skeleton">
    <html lang="de">
      <head>
        <meta http-equiv="content-type" content="application/xhtml+xml; charset=utf-8"/>
        <link rel="icon" href="/css/gfx/favicon.png" type="image/png"/>
        <link rel="stylesheet" href="/css/histvv.css" type="text/css" title="Histvv"/>    
        <script type="text/javascript" src="/js/jquery.js"></script>
        <script type="text/javascript" src="/js/jquery.dimensions.js"></script>
        <script type="text/javascript" src="/js/jquery.tooltip.js"></script>
        <script type="text/javascript" src="/js/form.js"></script>
        <xsl:call-template name="scripts"/>
        <title><xsl:call-template name="htmltitle"/> [Histvv]</title>
      </head>
      <body>
        <div id="header">
          <strong>Histvv</strong>
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
            © 2008
            <a href="http://www.ub.uni-leipzig.de/">
              Universitätsbibliothek Leipzig
            </a>
          </p>
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
        <xsl:if test="$url = '/' or $url = '/index.html'">
          <xsl:attribute name="class">current</xsl:attribute>
        </xsl:if>
        <a href="/">Home</a>
      </li>
      <li>
        <xsl:if test="starts-with($url, '/vv/')">
          <xsl:attribute name="class">current</xsl:attribute>
        </xsl:if>
        <a href="/vv/">Vorlesungsverzeichnisse</a>
      </li>
      <li>
        <xsl:if test="starts-with($url, '/dozenten/')">
          <xsl:attribute name="class">current</xsl:attribute>
        </xsl:if>
        <a href="/dozenten/">Dozenten</a>
      </li>
    </ul>
  </xsl:template>

</xsl:stylesheet>
