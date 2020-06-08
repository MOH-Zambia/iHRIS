<?xml version="1.0" encoding="UTF-8"?>   
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:csd="urn:ihe:iti:csd:2013"
  exclude-result-prefixes="csd xsl">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>     
  <!-- Based on http://stackoverflow.com/questions/2638367/how-do-i-emit-escaped-xml-representation-of-a-node-in-my-xslts-html-output -->
  <!-- defaults and configurable parameters -->
  <xsl:param name="NL"        select="'&#xA;'" /><!-- newline sequence -->
  <xsl:param name="INDENTSEQ" select="'&#x9;'" /><!-- indent sequence -->

  <xsl:variable name="LT" select="'&lt;'" />
  <xsl:variable name="GT" select="'&gt;'" />

  <xsl:template match="/">
    <form name='csd_provider_search' id='0'>
      <field name='result' type='STRING_MLINE'><xsl:apply-templates select="*" mode="XmlEscape" /></field>
      <field name='matches' type='ASSOC_MAP_RESULTS'>
	<xsl:for-each select="/csd:CSD/csd:providerDirectory/csd:provider">
	  <value keyform='csd_provider' >
	    <xsl:attribute name='keyid'><xsl:value-of select="@entityID"/></xsl:attribute>
	    <xsl:value-of select="csd:demographic/csd:name[1]/csd:forename/text()"/><xsl:text> </xsl:text>
	    <xsl:value-of select="csd:demographic/csd:name[1]/csd:surname/text()"/> 
	<!--    <xsl:value-of select="csd:demographic/csd:name[1]/csd:commonName/text()"/> -->
	  </value>
	</xsl:for-each>
      </field>
    </form>
  </xsl:template>         

  <!-- element nodes will be handled here, incl. proper indenting -->
  <xsl:template match="*" mode="XmlEscape">
    <xsl:param name="indent" select="''" />

    <xsl:value-of select="concat($indent, $LT, name())" />
    <xsl:apply-templates select="@*" mode="XmlEscape" />

    <xsl:variable name="HasChildNode" select="node()[not(self::text())]" />
    <xsl:variable name="HasChildText" select="text()[normalize-space()]" />
    <xsl:choose>
      <xsl:when test="$HasChildNode or $HasChildText">
        <xsl:value-of select="$GT" />
        <xsl:if test="not($HasChildText)">
          <xsl:value-of select="$NL" />
        </xsl:if>
        <!-- render child nodes -->
        <xsl:apply-templates mode="XmlEscape" select="node()">
          <xsl:with-param name="indent" select="concat($INDENTSEQ, $indent)" />
        </xsl:apply-templates>
        <xsl:if test="not($HasChildText)">
          <xsl:value-of select="$indent" />
        </xsl:if>
        <xsl:value-of select="concat($LT, '/', name(), $GT, $NL)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(' /', $GT, $NL)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- comments will be handled here -->
  <xsl:template match="comment()" mode="XmlEscape">
    <xsl:param name="indent" select="''" />
    <xsl:value-of select="concat($indent, $LT, '!--', ., '--', $GT, $NL)" />
  </xsl:template>

  <!-- text nodes will be printed XML-escaped -->
  <xsl:template match="text()" mode="XmlEscape">
    <xsl:if test="not(normalize-space() = '')">
      <xsl:call-template name="XmlEscapeString">
        <xsl:with-param name="s" select="." />
        <xsl:with-param name="IsAttribute" select="false()" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- attributes become a string: '{name()}="{escaped-value()}"' -->
  <xsl:template match="@*" mode="XmlEscape">
    <xsl:value-of select="concat(' ', name(), '=&quot;')" />
    <xsl:call-template name="XmlEscapeString">
      <xsl:with-param name="s" select="." />
      <xsl:with-param name="IsAttribute" select="true()" />
    </xsl:call-template>
    <xsl:value-of select="'&quot;'" />
  </xsl:template>

  <!-- template to XML-escape a string -->
  <xsl:template name="XmlEscapeString">
    <xsl:param name="s" select="''" />
    <xsl:param name="IsAttribute" select="false()" />
    <!-- chars &, < and > are never allowed -->
    <xsl:variable name="step1">
      <xsl:call-template name="StringReplace">
        <xsl:with-param name="s"       select="$s" />
        <xsl:with-param name="search"  select="'&amp;'" />
        <xsl:with-param name="replace" select="'&amp;amp;'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="step2">
      <xsl:call-template name="StringReplace">
        <xsl:with-param name="s"       select="$step1" />
        <xsl:with-param name="search"  select="'&lt;'" />
        <xsl:with-param name="replace" select="'&amp;lt;'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="step3">
      <xsl:call-template name="StringReplace">
        <xsl:with-param name="s"       select="$step2" />
        <xsl:with-param name="search"  select="'&gt;'" />
        <xsl:with-param name="replace" select="'&amp;lt;'" />
      </xsl:call-template>
    </xsl:variable>
    <!-- chars ", TAB, CR and LF are never allowed in attributes -->
    <xsl:choose>
      <xsl:when test="$IsAttribute">
        <xsl:variable name="step4">
          <xsl:call-template name="StringReplace">
            <xsl:with-param name="s"       select="$step3" />
            <xsl:with-param name="search"  select="'&quot;'" />
            <xsl:with-param name="replace" select="'&amp;quot;'" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="step5">
          <xsl:call-template name="StringReplace">
            <xsl:with-param name="s"       select="$step4" />
            <xsl:with-param name="search"  select="'&#x9;'" />
            <xsl:with-param name="replace" select="'&amp;#x9;'" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="step6">
          <xsl:call-template name="StringReplace">
            <xsl:with-param name="s"       select="$step5" />
            <xsl:with-param name="search"  select="'&#xA;'" />
            <xsl:with-param name="replace" select="'&amp;#xD;'" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="step7">
          <xsl:call-template name="StringReplace">
            <xsl:with-param name="s"       select="$step6" />
            <xsl:with-param name="search"  select="'&#xD;'" />
            <xsl:with-param name="replace" select="'&amp;#xD;'" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$step7" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$step3" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- generic string replace template -->
  <xsl:template name="StringReplace">
    <xsl:param name="s"       select="''" />
    <xsl:param name="search"  select="''" />
    <xsl:param name="replace" select="''" />

    <xsl:choose>
      <xsl:when test="contains($s, $search)">
        <xsl:value-of select="substring-before($s, $search)" />
        <xsl:value-of select="$replace" />
        <xsl:variable name="rest" select="substring-after($s, $search)" />
        <xsl:if test="$rest">
          <xsl:call-template name="StringReplace">
            <xsl:with-param name="s"       select="$rest" />
            <xsl:with-param name="search"  select="$search" />
            <xsl:with-param name="replace" select="$replace" />
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$s" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
