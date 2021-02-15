<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- clean up formatting -->
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes"/>
    
    <!-- initialize document -->
    <xsl:template match="html">
        <xsl:result-document href="journal_data.xml">
            <journalData>
                <xsl:apply-templates/>
            </journalData>
        </xsl:result-document>        
    </xsl:template>
    
    <!-- exclude unwanted HTML elements -->
    <xsl:template match="head|header|script|input"/>
    
    <!-- exclude divs with unwanted content based on attributes (no need to identify divs without content)-->
    <xsl:template match="div[@class='container breadcrumbs-wrapper' or @class='block' or @class='interior-rail' or @style='display:none']"/>
    
    <!-- identify document title, simplified from body/form/div/main//h1 -->
    <xsl:template match="main//h1">
        <title>
            <xsl:apply-templates/>
        </title>
    </xsl:template>
    
    <!-- create table of journals sorted by institution -->
    <xsl:template match="main//ul">
        <journalTable>
            <xsl:apply-templates>
                <xsl:sort select="p[1]/span" lang="en" order="ascending"/>
            </xsl:apply-templates>
        </journalTable>
    </xsl:template>
    
    <!-- treat each list item as a journal record/row -->
    <xsl:template match="main//ul/li">
        <journalRecord row="{position()}">
            <xsl:apply-templates/>
        </journalRecord>
    </xsl:template>
    
    <!-- identify name and URL-->
    <xsl:template match="main//ul/li/p[1]/a">
        <journalURL>
            <xsl:value-of select="@href"/>
        </journalURL>
        <journalName>
            <xsl:value-of select="normalize-space()"/>
        </journalName>
    </xsl:template>
    
    <!-- identify institution -->
    <xsl:template match="main//ul/li/p[1]/span">
        <journalInstitution>
            <xsl:choose>
                <!-- separator present, extract institution -->
                <xsl:when test="contains(., ' - ')">
                    <xsl:value-of select="normalize-space(substring-after(., ' - '))"/>        
                </xsl:when>
                <!-- else treat as no institution -->
                <xsl:otherwise>
                    <xsl:text>[no institution listed]</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </journalInstitution>
    </xsl:template>
   
    <!-- exclude description -->   
    <xsl:template match="main//ul/li/p[2]"/>
    
</xsl:stylesheet>