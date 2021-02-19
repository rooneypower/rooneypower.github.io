<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:om="http://omeka.org/schemas/omeka-xml/v5"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- clean up formatting -->
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes"/>
    
    <!-- initialize program document -->
    <xsl:template match="/om:item">
        <xsl:result-document href="{concat('item',@itemId,'.xml')}">
            <program xmlns:dc="http://purl.org/dc/elements/1.1/" xml:id="{@itemId}">
                <xsl:apply-templates select="om:elementSetContainer/om:elementSet[@elementSetId='1']"/>
                <xsl:apply-templates select="om:itemType//om:element[@elementId='1']"/>
            </program>
        </xsl:result-document>
    </xsl:template>
    
    <!-- extract select dc metadata -->
    <xsl:template match="om:elementSet[@elementSetId='1']">
        <meta>
            <xsl:apply-templates select="om:elementContainer/om:element[@elementId='50']"/>
            <xsl:apply-templates select="om:elementContainer/om:element[@elementId='39']"/>
        </meta>
    </xsl:template>
    
    <!-- dc title -->
    <xsl:template match="om:element[@elementId='50']">
        <dc:title>
            <xsl:value-of select="om:elementTextContainer/om:elementText/om:text"/>
        </dc:title>
    </xsl:template>
    
    <!-- dc creator -->
    <xsl:template match="om:element[@elementId='39']">
        <dc:creator>
            <xsl:value-of select="om:elementTextContainer/om:elementText/om:text"/>
        </dc:creator>
    </xsl:template>
    
    <!-- text body -->
    <xsl:template match="om:element[@elementId='1']">
        <text>
            <xsl:value-of select="om:elementTextContainer/om:elementText/om:text"/>
        </text>
    </xsl:template>
    
</xsl:stylesheet>