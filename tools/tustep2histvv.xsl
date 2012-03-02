<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:v="http://histvv.uni-leipzig.de/ns/2007">

  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>

  <xsl:param name="semester" select="'1833'"/>

  <xsl:variable name="beginn">
    <xsl:choose>
      <xsl:when test="contains($semester, '/')">
        <xsl:value-of select="substring-before($semester, '/')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$semester"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="ende">
    <xsl:choose>
      <xsl:when test="contains($semester, '/')">
        <xsl:value-of select="concat(substring($semester, 1, 2), substring-after($semester, '/'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$semester"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates select="root"/>
  </xsl:template>

  <!-- Veranstaltungen -->

  <xsl:template match="root[semester]">
    <xsl:apply-templates select="semester[@jahr=$semester]"/>
  </xsl:template>

  <xsl:template match="root/semester">
    <vv xml:lang="de" xmlns="http://histvv.uni-leipzig.de/ns/2007"
        xmlns:ns="http://histvv.uni-leipzig.de/ns/2007">
      <kopf>
        <universität>Zürich</universität>
        <semester>
          <xsl:choose>
            <xsl:when test="$beginn = $ende">
              <xsl:text>Sommer</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>Winter</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </semester>
        <beginn>
          <jahr><xsl:value-of select="$beginn"/></jahr>
        </beginn>
        <ende>
          <jahr><xsl:value-of select="$ende"/></jahr>
        </ende>
        <quelle><xsl:value-of select="vorlage"/></quelle>
        <status komplett="ja"></status>
      </kopf>
      <titel>
        <xsl:choose>
          <xsl:when test="contains($semester, '/')">
            <xsl:text>Winter</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Sommer</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>semester </xsl:text>
        <xsl:value-of select="$semester"/>
      </titel>
      <xsl:apply-templates select="fakultät"/>
    </vv>
  </xsl:template>

  <xsl:template match="fakultät">
    <sachgruppe xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:attribute name="fakultät">
        <xsl:choose>
          <xsl:when test="@name = 'Medizinische Fakultät'">
            <xsl:text>Medizin</xsl:text>
          </xsl:when>
          <xsl:when test="@name = 'Philosophische Fakultät'">
            <xsl:text>Philosophie</xsl:text>
          </xsl:when>
          <xsl:when test="@name = 'Staatswissenschaftliche Fakultät'">
            <xsl:text>Staatswissenschaften</xsl:text>
          </xsl:when>
          <xsl:when test="@name = 'Theologische Fakultät'">
            <xsl:text>Theologie</xsl:text>
          </xsl:when>
          <xsl:when test="@name = 'Zahnärztliche Schule'">
            <xsl:text>Zahnmedizin</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <titel><xsl:value-of select="@name"/></titel>
      <xsl:apply-templates select="*"/>
    </sachgruppe>
  </xsl:template>

  <xsl:template match="vorlesungen">
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="abteilung|department">
    <sachgruppe xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <titel><xsl:value-of select="@name"/></titel>
      <xsl:apply-templates select="*"/>
    </sachgruppe>
  </xsl:template>

  <xsl:template match="vorlesung">
    <veranstaltung xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:attribute name="xml:id">
        <xsl:value-of select="concat('v-', absvnr)"/>
      </xsl:attribute>
      <xsl:apply-templates select="*[not(name() = 'absvnr')]"/>
      <xsl:if test="lecttitle/polyt">
        <ort>Polytechnikum</ort>
      </xsl:if>
    </veranstaltung>
  </xsl:template>

  <xsl:template match="lecturer">
    <dozent xmlns="http://histvv.uni-leipzig.de/ns/2007" ref="{@id}">
      <xsl:choose>
        <xsl:when test="contains(name, ', ')">
          <nachname><xsl:value-of select="substring-before(name, ', ')"/></nachname>
          <xsl:text>, </xsl:text>
          <vorname><xsl:value-of select="substring-after(name, ', ')"/></vorname>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="name"/></xsl:otherwise>
      </xsl:choose>
      <xsl:if test="degree">
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="degree"/>
      </xsl:if>
      <xsl:if test="zusamt">
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="zusamt"/>
      </xsl:if>
    </dozent>
  </xsl:template>

  <xsl:template match="lecturer/degree">
    <grad xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:apply-templates/>
    </grad>
  </xsl:template>

  <xsl:template match="lecturer/zusamt">
    <funktion xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:apply-templates/>
    </funktion>
  </xsl:template>

  <xsl:template match="lecttitle">
    <thema xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:apply-templates/>
    </thema>
  </xsl:template>

  <xsl:template match="lecttitle/polyt">
  </xsl:template>

  <xsl:template match="lectnr">
    <nr xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:apply-templates/>
    </nr>
  </xsl:template>

  <xsl:template match="hw">
    <wochenstunden xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:apply-templates/>
    </wochenstunden>
  </xsl:template>

  <xsl:template match="time">
    <zeit xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:apply-templates/>
    </zeit>
  </xsl:template>

  <xsl:template match="bemfak">
    <absatz xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:apply-templates/>
    </absatz>
  </xsl:template>

  <xsl:template match="fn">
    <anmerkung xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:apply-templates/>
    </anmerkung>
  </xsl:template>

<!--
  <xsl:template match="zusatz[.='gratis' or .='unentgeltlich']">
    <zusatz xmlns="http://histvv.uni-leipzig.de/ns/2007"><gebühr><xsl:value-of select="."/></gebühr></zusatz>
  </xsl:template>
-->
  <xsl:template match="zusatz">
    <zusatz xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:choose>
        <xsl:when test="false()">
          <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:when test=".='gratis' or .='unentgeltlich'">
          <gebühr><xsl:value-of select="."/></gebühr>
        </xsl:when>
        <xsl:when test=".='öffentlich' or .='publice' or .='privatim'
                        or .='privatissime' or .='privatissimum'">
          <modus><xsl:value-of select="."/></modus>
        </xsl:when>
        <!-- "für Zuhörer aller Facultäten, publice" -->
        <xsl:when test="substring-after(., ', ') = 'publice'">
          <xsl:value-of select="substring-before(., ', ')"/>
          <xsl:text>, </xsl:text>
          <modus>
            <xsl:value-of select="substring-after(., ', ')"/>
          </modus>
        </xsl:when>
        <!-- "gratis, für Studierende aller Fakultäten" -->
        <xsl:when test="starts-with(., 'gratis, ')">
          <modus>gratis</modus>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="substring-after(., ', ')"/>
        </xsl:when>
        <xsl:when test=". = 'privatissime et gratis'">
          <modus>privatissime</modus> et <gebühr>gratis</gebühr>
        </xsl:when>
        <xsl:when test=". = 'privatissime und gratis'">
          <modus>privatissime</modus> und <gebühr>gratis</gebühr>
        </xsl:when>
        <xsl:when test=". = 'privatissime u. gratis'">
          <modus>privatissime</modus> u. <gebühr>gratis</gebühr>
        </xsl:when>
        <xsl:when test=". = 'privatissime, gratis'">
          <modus>privatissime</modus>, <gebühr>gratis</gebühr>
        </xsl:when>
        <xsl:when test=". = 'publice et gratis'">
          <modus>publice</modus> et <gebühr>gratis</gebühr>
        </xsl:when>
        <xsl:when test=". = 'publice und gratis'">
          <modus>publice</modus> und <gebühr>gratis</gebühr>
        </xsl:when>
        <xsl:when test=". = 'publice u. gratis'">
          <modus>publice</modus> u. <gebühr>gratis</gebühr>
        </xsl:when>
        <xsl:when test=". = 'publice, gratis'">
          <modus>publice</modus>, <gebühr>gratis</gebühr>
        </xsl:when>
        <xsl:when test="contains(., 'gratis') or contains(.,'unentgeltlich')">
          <gebühr><xsl:value-of select="."/></gebühr>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </zusatz>
  </xsl:template>

  <xsl:template match="sup">
    <xsl:choose>
      <xsl:when test="not(.='') and translate(., '0123456789', '') = ''">
        <xsl:value-of select="translate(., '0123456789', '⁰¹²³⁴⁵⁶⁷⁸⁹')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Dozenten -->

  <xsl:template match="root[dozent]">
    <dozentenliste xml:lang="de" xmlns="http://histvv.uni-leipzig.de/ns/2007"
                   xmlns:ns="http://histvv.uni-leipzig.de/ns/2007">
      <universität>Zürich</universität>
      <xsl:apply-templates select="dozent"/>
    </dozentenliste>
  </xsl:template>

  <xsl:template match="root/dozent">
    <dozent xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:attribute name="xml:id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <name>
        <nachname><xsl:value-of select="nachname"/></nachname>
        <xsl:choose>
          <xsl:when test="substring(vorname, string-length(vorname) - 3) = ' von'">
            <vorname><xsl:value-of select="substring-before(vorname, ' von')"/></vorname>
            <nachnamenpräfix>von</nachnamenpräfix>
          </xsl:when>
          <xsl:otherwise>
            <vorname><xsl:value-of select="vorname"/></vorname>
          </xsl:otherwise>
        </xsl:choose>
      </name>
      <xsl:if test="geb">
        <geboren>
          <jahr><xsl:value-of select="geb"/></jahr>
        </geboren>
      </xsl:if>
      <xsl:if test="gest">
        <gestorben>
          <jahr><xsl:value-of select="gest"/></jahr>
        </gestorben>
      </xsl:if>
      <xsl:apply-templates select="pnd|gagl|fak|dek|rek"/>
    </dozent>
  </xsl:template>

  <xsl:template match="root/dozent[@id='od']">
  </xsl:template>

  <xsl:template match="root/dozent/pnd">
    <pnd xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:value-of select="."/>
    </pnd>
  </xsl:template>

  <xsl:template match="root/dozent/gagl">
    <absatz xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:text>UZV: </xsl:text>
      <xsl:value-of select="."/>
    </absatz>
  </xsl:template>

  <xsl:template match="root/dozent/fak">
    <absatz xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:value-of select="."/>
    </absatz>
  </xsl:template>

  <xsl:template match="root/dozent/dek">
    <absatz xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:text>Dekan: </xsl:text>
      <xsl:value-of select="."/>
    </absatz>
  </xsl:template>

  <xsl:template match="root/dozent/rek">
    <absatz xmlns="http://histvv.uni-leipzig.de/ns/2007">
      <xsl:text>Rektor: </xsl:text>
      <xsl:value-of select="."/>
    </absatz>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
