<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- remove whitespace for element tags -->
    <xsl:strip-space elements="*"/>
    
    <!-- initialize HTML document and plant table -->
    <xsl:template match="CATALOG">
        <html>
            <head>
                <title>Plant Catalog</title>
                <link rel="stylesheet" type="text/css" href="https://rooneypower.github.io/css/main.css"></link>
            </head>
            <body>
                <h1>Catalog of Plants</h1>
                <p>This is a catalog of plants from 1999. Each listing includes the common and scientific names, 
                    <a href="https://www.fs.fed.us/wildflowers/Native_Plant_Materials/Native_Gardening/hardinesszones.shtml" target="_blank">plant hardiness zone</a>, 
                    light preference, price, and date of availability.</p>
                <p>There are currently <xsl:value-of select="count(PLANT)"/> listings.</p>
                <table>
                    <tr>
                        <th>Common Name</th>
                        <th>Botanical Name</th>
                        <th>Zone</th>
                        <th>Light</th>
                        <th>Price</th>
                        <th>Availability</th>
                    </tr>
                    <xsl:apply-templates/>
                </table>
            </body>
        </html>
    </xsl:template>
    
    <!-- start a new table row for each plant -->
    <xsl:template match="PLANT">
        <tr>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>
    
    <!-- output each child of plant that doesn't need formatting -->
    <xsl:template match="COMMON | ZONE | LIGHT | PRICE">
        <td>
            <xsl:apply-templates/>
        </td>
    </xsl:template>
    
    <!-- italicize botanical name -->
    <xsl:template match="BOTANICAL">
        <td>
            <em><xsl:value-of select="."/></em>
        </td>
    </xsl:template>
    
    <!-- format six-character availability string as MM/DD/YY  -->
    <xsl:template match="AVAILABILITY">
        <td>
            <xsl:value-of select="string-join((substring(.,1,2),substring(.,3,2),substring(.,5,2)),'/')"/>
        </td>
    </xsl:template>

</xsl:stylesheet>