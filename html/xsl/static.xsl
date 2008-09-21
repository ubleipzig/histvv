<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://histvv.uni-leipzig.de/ns/2007"
                xmlns:h="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="v">

  <xsl:import href="common.xsl"/>

  <xsl:template name="content">
    <xsl:apply-templates select="/h:html/h:body/*"/>
  </xsl:template>

  <xsl:template name="htmltitle">
    <xsl:value-of select="/h:html/h:head/h:title"/>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- filter elements with conflicting IDs -->
  <xsl:template match="*[@id='header' or @id='footer' or @id='sidebar']">
  </xsl:template>

</xsl:stylesheet>
