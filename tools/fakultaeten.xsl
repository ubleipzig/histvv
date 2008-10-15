<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://histvv.uni-leipzig.de/ns/2007">

  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template
      match="v:sachgruppe[starts-with(v:titel, 'A) Vorlesungen über die Theologischen Wissenschaften')]
             | v:sachgruppe[starts-with(v:titel, 'A) Vorlesungen über die theologischen Wissenschaften')]
             | v:sachgruppe[starts-with(v:titel, 'A) Christliche Theologie')]
             | v:sachgruppe[starts-with(v:titel, 'I. Theologische Facultät')]
             | v:sachgruppe[starts-with(v:titel, 'I. Theologische Fakultät')]
             | v:sachgruppe[starts-with(v:titel, 'II. Theologie')]
             | v:sachgruppe[starts-with(v:titel, 'A. Theologie')]">
    <v:sachgruppe fakultät="Theologie">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </v:sachgruppe>
  </xsl:template>

  <xsl:template
      match="v:sachgruppe[starts-with(v:titel, 'B) Vorlesungen über die Rechtswissenschaften')]
             | v:sachgruppe[starts-with(v:titel, 'B) Vorlesungen über die Rechts-Wissenschaften')]
             | v:sachgruppe[starts-with(v:titel, 'B) Vorlesungen über die positive Rechtswissenschaft')]
             | v:sachgruppe[starts-with(v:titel, 'B) Vorlesungen über die juristischen Wissenschaften')]
             | v:sachgruppe[starts-with(v:titel, 'B) Juristische Vorlesungen')]
             | v:sachgruppe[starts-with(v:titel, 'B) Rechtsgelahrtheit')]
             | v:sachgruppe[starts-with(v:titel, 'B. Rechtskunde')]
             | v:sachgruppe[starts-with(v:titel, 'III. Rechtswissenschaft')]
             | v:sachgruppe[starts-with(v:titel, 'II. Juristische Facultät')]
             | v:sachgruppe[starts-with(v:titel, 'II. Juristische Fakultät')]
             | v:sachgruppe[starts-with(v:titel, 'B. Rechtswissenschaft')]">
    <v:sachgruppe fakultät="Jura">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </v:sachgruppe>
  </xsl:template>

  <xsl:template
      match="v:sachgruppe[starts-with(v:titel, 'C) Vorlesungen über die medicinischen Wissenschaften')]
             | v:sachgruppe[starts-with(v:titel, 'C) Vorlesungen über die medizinischen Wissenschaften')]
             | v:sachgruppe[starts-with(v:titel, 'III. Medicinische Facultät')]
             | v:sachgruppe[starts-with(v:titel, 'III. Medizinische Facultät')]
             | v:sachgruppe[starts-with(v:titel, 'III. Medizinische Fakultät')]
             | v:sachgruppe[starts-with(v:titel, 'C. Heilkunde')]
             | v:sachgruppe[starts-with(v:titel, 'C. Heilwissenschaft')]
             | v:sachgruppe[starts-with(v:titel, 'C. Arzneywissenschaft')]
             | v:sachgruppe[starts-with(v:titel, 'C. Arzneiwissenschaft')]
             | v:sachgruppe[starts-with(v:titel, 'IV. Arzneiwissenschaft')]">
    <v:sachgruppe fakultät="Medizin">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </v:sachgruppe>
  </xsl:template>

  <xsl:template
      match="v:sachgruppe[starts-with(v:titel, 'I. Allgemeine Einleitungswissenschaften')]
             | v:sachgruppe[starts-with(v:titel, 'I. Allgemeine und Einleitungs')]
             | v:vv/v:sachgruppe[starts-with(v:titel, 'I. Allgemeine u. Einleitungs')]
             | v:vv/v:sachgruppe[starts-with(v:titel, 'I. Allgemeine Studien')]
             | v:vv/v:sachgruppe[starts-with(v:titel, 'I. Wissenschaften des allgemeinen Studium')]
             | v:vv/v:sachgruppe[starts-with(v:titel, 'I. Wissenschaften des allgem. Studium')]
             | v:vv/v:sachgruppe[starts-with(v:titel, 'I. Wissenschaften der philosophischen Facultät')]
             | v:sachgruppe[starts-with(v:titel, 'IV. Philosophische Facultät')]
             | v:sachgruppe[starts-with(v:titel, 'IV. Philosophische Fakultät')]">
    <v:sachgruppe fakultät="Philosophie">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </v:sachgruppe>
  </xsl:template>

</xsl:stylesheet>
