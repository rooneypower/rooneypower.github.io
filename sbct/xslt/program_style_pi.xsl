<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-result-prefixes="xs dc"
    version="2.0">
    
    <!-- formatting -->
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="html" version="5.0" encoding="UTF-8"/>
    
    <!-- for use with xml-stylesheet processing instruction -->
    <!-- initialize HTML with no result document -->
    <xsl:template match="/program">
        <html>
            <xsl:apply-templates/>
        </html>
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
    
    <!-- create page body from program text -->
    <!-- includes nav bar and footer -->
    <xsl:template match="text">
        <body>
            <!-- navigation bar -->
            <nav>
                <ul>
                    <li><a href="../index.html">Home</a></li>
                    <li><a href="../technical.html">Technical</a></li>
                    <li><a href="https://sbct.omeka.net/" target="_blank">Omeka Collection</a></li>
                </ul>
            </nav>
            <!-- title and Omeka item link -->
            <div class="center" id="top">
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
            <!-- footer: return home or jump to top of program -->
            <footer>
                <ul>
                    <li><a href="../index.html">Home</a></li>
                    <li><a href="#top">Top</a></li>
                </ul>
            </footer>
        </body>
    </xsl:template>
    
    <!-- 
    Main Division Templates
    -->
    <xsl:template match="cover">
        <div class="center">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- create table for cast -->
    <xsl:template match="cast">
        <div class="float half">
            <xsl:apply-templates select="header"/>
            <table>
                <tr><th>Role</th><th>Actor</th></tr>
                <xsl:apply-templates select="credit"/>
            </table>
        </div>
    </xsl:template>
    
    <!-- create table for crew -->
    <xsl:template match="crew">
        <div class="float half">
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
    
    <!-- 
    Content Element Templates
    -->
    <xsl:template match="line">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="line[@type='playTitle']">
        <p class="title">
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
                <!-- check for left parenthesis in first 30 characters -->
                <xsl:when test="contains(substring(.,1,30), '(')">
                    <span class="name"><xsl:value-of select="substring-before(., '(')"/></span>
                    <xsl:value-of select="concat('(', substring-after(., '('))"/>
                </xsl:when>
                <!-- there may be no name or no role in parentheses, output normally -->
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </p>
    </xsl:template>
    
</xsl:stylesheet>