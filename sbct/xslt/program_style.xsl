<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-result-prefixes="xs dc"
    version="2.0">
    
    <!-- formatting -->
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="html" version="5.0" encoding="UTF-8"/>
    
    <!-- initialize HTML document -->
    <xsl:template match="/program">
        <xsl:result-document href="{concat('../programs/item', @xml:id, '.html')}">
            <html>
                <xsl:apply-templates/>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <!-- link CSS and put metadata in head -->
    <xsl:template match="metadata">
        <head prefix="dc: http://purl.org/dc/elements/1.1/">
            <title><xsl:value-of select="dc:title"/></title>
            <link rel="stylesheet" type="text/css" href="../css/sbct.css"/>
            <xsl:apply-templates/>
        </head>
    </xsl:template>
    
    <xsl:template match="metadata/*">
        <meta name="{name()}" content="{.}"/>
    </xsl:template>
    
    <!-- add nav bar and create page body from program text -->
    <xsl:template match="text">
        <body>
            <!-- navigation bar -->
            <nav>
                <ul>
                    <li><a href="../index.html">Home</a></li>
                    <li><a href="../technical.html">Technical</a></li>
                    <li><a href="https://sbct.omeka.net/">Omeka Collection</a></li>
                </ul>
            </nav>
            <!-- title and Omeka link -->
            <div class="center">
                <h1><xsl:value-of select="/program/metadata/dc:title"/></h1>
                <a href="{concat('https://sbct.omeka.net/items/show/', /program/@xml:id)}" target="_blank">See item in Omeka</a>    
            </div>
            <!-- add sections in specific order -->
            <xsl:apply-templates select="cover"/>
            <div class="wrapper">
                <xsl:apply-templates select="cast"/>
                <xsl:apply-templates select="crew"/>
                <br class="stop"/>
            </div>
            <xsl:apply-templates select="setting"/>
            <xsl:apply-templates select="bios"/>
        </body>
    </xsl:template>
    
    <xsl:template match="cover">
        <div class="center">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- create table for cast -->
    <xsl:template match="cast">
        <div class="float">
            <xsl:apply-templates select="header"/>
            <table>
                <tr><th>Role</th><th>Actor</th></tr>
                <xsl:apply-templates select="credit"/>
            </table>
        </div>
    </xsl:template>
    
    <!-- create table for crew -->
    <xsl:template match="crew">
        <div class="float">
            <xsl:apply-templates select="header"/>
            <table>
                <tr><th>Position</th><th>Member</th></tr>
                <xsl:apply-templates select="credit"/>
            </table>
        </div>
    </xsl:template>
    
    <xsl:template match="setting">
        <div class="center">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="bios">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="line">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="break">
        <br/>
    </xsl:template>
    
    <xsl:template match="header">
        <h2>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>
    
    <!-- each credit is a table row with two columns -->
    <xsl:template match="credit">
        <tr>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>
    
    <xsl:template match="role | talent">
        <td>
            <xsl:apply-templates/>
        </td>
    </xsl:template>
    
    <!-- emphasize name (before role in parentheses) for bio entries -->
    <xsl:template match="entry">
        <p>
            <xsl:choose>
                <xsl:when test="contains(., '(')">
                    <span class="bioname"><xsl:value-of select="substring-before(., '(')"/></span>
                    <xsl:value-of select="concat('(', substring-after(., '('))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </p>
    </xsl:template>
    
</xsl:stylesheet>