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
      <xsl:text> der Universität Zürich</xsl:text>
    </h6>
  </xsl:template>

  <xsl:template match="h:div[@id='footer']">
    <div id="footer">
      <p>
        © 2012
        <a href="http://www.archiv.uzh.ch/">
          Universitätsarchiv Zürich
        </a>
      </p>
    </div>
  </xsl:template>

</xsl:stylesheet>
