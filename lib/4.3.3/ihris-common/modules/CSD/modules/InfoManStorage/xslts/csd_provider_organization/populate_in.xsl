<?xml version="1.0" encoding="UTF-8"?>   
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:csd="urn:ihe:iti:csd:2013"
  exclude-result-prefixes="csd xsl"
  >     
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>     
  <xsl:template match="/">         
    <xsl:for-each select="/csd:CSD/csd:providerDirectory/csd:provider/csd:organizations/csd:organization">        
      <form name='csd_provider_organization' parent_form='csd_provider'>
	<xsl:attribute name="id"><xsl:value-of select="concat(../../@entityID,'/',@entityID)"/></xsl:attribute>
	<xsl:attribute name="parent_id"><xsl:value-of select="../../@entityID"/></xsl:attribute>
	<xsl:attribute name="created"><xsl:value-of select="translate(substring(../../csd:record/@created,1,19),'T',' ')"/></xsl:attribute>
	<xsl:attribute name="modified"><xsl:value-of select="translate(substring(../../csd:record/@updated,1,19),'T',' ')"/></xsl:attribute>
	<field name='csd_organization' type='MAP'>
	  <value form='csd_organization'><xsl:value-of select="@entityID"/></value>
	</field>
      </form>
    </xsl:for-each>
  </xsl:template> 
</xsl:stylesheet>
