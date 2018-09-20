<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://histvv.uni-leipzig.de/ns/2007"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="v">

  <xsl:import href="common.xsl"/>

  <xsl:output method="text" encoding="utf-8" />

  <xsl:param name="histvv-beacon-target"/>
  <xsl:param name="histvv-beacon-feed"/>
  <xsl:param name="histvv-beacon-timestamp"/>

  <xsl:template match="/">
    <xsl:text>#FORMAT: BEACON</xsl:text>
    <xsl:text>&#xA;</xsl:text>
    <xsl:text>#PREFIX: http://d-nb.info/gnd/</xsl:text>
    <xsl:text>&#xA;</xsl:text>
    <xsl:if test="$histvv-beacon-target">
      <xsl:text>#TARGET: </xsl:text>
      <xsl:value-of select="$histvv-beacon-target"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="$histvv-beacon-feed">
      <xsl:text>#FEED: </xsl:text>
      <xsl:value-of select="$histvv-beacon-feed"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
    <xsl:text>#COUNT: </xsl:text>
    <xsl:value-of select="count(/v:dozentenliste/v:dozent[v:pnd])"/>
    <xsl:text>&#xA;</xsl:text>
    <xsl:for-each select="/v:dozentenliste/v:beacon/v:*">
      <xsl:text>#</xsl:text>
      <xsl:value-of select="translate(local-name(),
                                      'abcdefghijklmnopqrstuvwxyz',
                                      'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:for-each>
    <xsl:for-each select="/v:dozentenliste/v:dozent[v:pnd]">
      <xsl:sort select="v:pnd"/>
      <xsl:value-of select="normalize-space(v:pnd)"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
