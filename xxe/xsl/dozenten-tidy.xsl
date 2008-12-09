<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://histvv.uni-leipzig.de/ns/2007">

  <!--
      This stylesheet removes unused/empty elements and comments that
      were inserted by the default template of the 'dozent' element in
      dozenten.xxe.
  -->

  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="no"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="v:url[.=''] | v:ort[.=''] | v:monat[.=''] | v:tag[.=''] |
                       v:adb[v:band='' and v:seite='' and v:url=''] |
                       v:ndb[v:band='' and v:seite='' and v:url='']">
  </xsl:template>

  <xsl:template match="comment()[
                         .='[Berufsbezeichnung, Fachgebiet]' or
                         .='[Links zu Wikipedia, Professorenkatalog, BBKL usw.]'
                         ]">
  </xsl:template>


</xsl:stylesheet>
