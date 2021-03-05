<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:om="http://omeka.org/schemas/omeka-xml/v5" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <!-- clean up formatting -->
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes"/>

    <!-- address items (programs) within container -->
    <xsl:template match="om:itemContainer">
        <xsl:apply-templates select="om:item"/>
    </xsl:template>
    
    <!-- setup output file and initialize multiple passes for each item-->
    <xsl:template match="om:item">
        <xsl:result-document href="{concat('../output/item', @itemId, '.xml')}">
            <!-- add stylesheet processing instruction  -->
            <xsl:processing-instruction name="xml-stylesheet">
                <xsl:text>type="text/xsl" href="https://rooneypower.github.io/sbct/xslt/program_style_pi.xsl"</xsl:text>
            </xsl:processing-instruction>
            <xsl:variable name="pass1">
                <xsl:apply-templates mode="pass1" select="."/>
            </xsl:variable>
            <xsl:variable name="pass2">
                <xsl:apply-templates mode="pass2" select="$pass1"/>
            </xsl:variable>
            <xsl:copy-of select="$pass2"/>
        </xsl:result-document>
    </xsl:template>

    <!-- begin pass1 -->
    <!-- initialize program document -->
    <xsl:template mode="pass1" match="om:item">
        <program xmlns:dc="http://purl.org/dc/elements/1.1/" xml:id="{@itemId}">
            <xsl:apply-templates mode="pass1" select="om:elementSetContainer/om:elementSet[@elementSetId = '1']"/>
            <xsl:apply-templates mode="pass1" select="om:itemType//om:element[@elementId = '1']"/>
        </program>
    </xsl:template>

    <!-- extract select dc metadata -->
    <xsl:template mode="pass1" match="om:elementSet[@elementSetId = '1']">
        <metadata>
            <xsl:apply-templates mode="pass1" select="om:elementContainer/om:element[@elementId = '50']"/>
            <xsl:apply-templates mode="pass1" select="om:elementContainer/om:element[@elementId = '39']"/>
        </metadata>
    </xsl:template>

    <!-- dc title -->
    <xsl:template mode="pass1" match="om:element[@elementId = '50']">
        <dc:title>
            <xsl:value-of select="om:elementTextContainer/om:elementText/om:text"/>
        </dc:title>
    </xsl:template>

    <!-- dc creator -->
    <xsl:template mode="pass1" match="om:element[@elementId = '39']">
        <dc:creator>
            <xsl:value-of select="om:elementTextContainer/om:elementText/om:text"/>
        </dc:creator>
    </xsl:template>

    <!-- text body -->
    <xsl:template mode="pass1" match="om:element[@elementId = '1']">
        <text>
            <xsl:call-template name="breakLines">
                <xsl:with-param name="pString"
                    select="om:elementTextContainer/om:elementText/om:text"/>
            </xsl:call-template>
        </text>
    </xsl:template>

    <!-- recursive template to parse linebreaks, adapted from paragrapher by Nick Homenda -->
    <xsl:template name="breakLines">
        <xsl:param name="pString"/>
        <xsl:choose>
            <!-- contains break character, needs to be split -->
            <xsl:when test="contains($pString, '&#13;')">
                <xsl:call-template name="breakLines">
                    <xsl:with-param name="pString" select="substring-before($pString, '&#13;')"/>
                </xsl:call-template>
                <xsl:call-template name="breakLines">
                    <xsl:with-param name="pString" select="substring-after($pString, '&#13;')"/>
                </xsl:call-template>
            </xsl:when>
            <!-- just text, output as line -->
            <xsl:when test="normalize-space($pString)">
                <line>
                    <xsl:value-of select="normalize-space($pString)"/>
                </line>
            </xsl:when>
            <!-- blank line, output as break -->
            <xsl:otherwise>
                <break/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- begin pass2 -->
    <!-- copy elements other than text -->
    <xsl:template mode="pass2" match="node()[name() != 'text'] | @*">
        <xsl:copy>
            <xsl:apply-templates mode="pass2" select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- handle text element with its own mode-->
    <xsl:template mode="pass2" match="text">
        <xsl:copy>
            <xsl:apply-templates mode="text"/>
        </xsl:copy>
    </xsl:template>

    <!-- templates to build text sections -->
    <!-- identify cover -->
    <xsl:template mode="text" match="line[upper-case(.) = 'SOUTH BEND']">
        <cover>
            <xsl:call-template name="getLine">
                <xsl:with-param name="next" select="."/>
            </xsl:call-template>
        </cover>
    </xsl:template>
    
    <!-- identify cast -->
    <xsl:template mode="text" match="line[starts-with(upper-case(.), 'THE CAST') or upper-case(.) = 'THE ACTORS']">
        <cast>
            <header><xsl:value-of select="."/></header>
            <xsl:call-template name="getCredit">
                <xsl:with-param name="next" select="./following-sibling::line[1]"/>
            </xsl:call-template>
        </cast>
    </xsl:template>
    
    <!-- identify crew -->
    <xsl:template mode="text" match="line[starts-with(upper-case(.), 'THE PRODUCTION') or upper-case(.) = 'PRODUCTION TEAM']">
        <crew>
            <header><xsl:value-of select="."/></header>
            <xsl:call-template name="getCredit">
                <xsl:with-param name="next" select="./following-sibling::line[1]"/>
            </xsl:call-template>
        </crew>
    </xsl:template>
    
    <!-- identify biographies -->
    <xsl:template mode="text" match="line[starts-with(upper-case(.), &quot;WHO'S WHO&quot;)]">
        <bios>
            <header><xsl:value-of select="."/></header>
            <xsl:call-template name="groupEntries">
                <xsl:with-param name="start" select="."/>
            </xsl:call-template>
        </bios>
    </xsl:template>
    
    <!-- setting and adjacent info -->
    <xsl:template mode="text" match="line[upper-case(.) = 'SETTING' or upper-case(.) = 'PLACE' or starts-with(upper-case(.), 'TIME:')]">
        <setting>
            <header><xsl:value-of select="."/></header>
            <xsl:call-template name="getLine">
                <xsl:with-param name="next" select="./following-sibling::*[1]"/>
            </xsl:call-template>
        </setting>
    </xsl:template>
    
    <!-- content handled by section, don't automatically output each line--> 
    <xsl:template mode="text" match="line | break"/>

    <!-- named support templates -->
    <!-- add lines/breaks to a section: terminate on double break, next section header, or unexpected element  -->
    <xsl:template name="getLine">
        <xsl:param name="next"/>
        <xsl:choose>
            <!-- element is a line --> 
            <xsl:when test="$next/self::line">
                <xsl:choose>
                    <!-- beginning of next section, terminate -->
                    <xsl:when test="upper-case($next) = 'THE PRODUCTION TEAM' or upper-case($next) = 'THE CAST'"/>                        
                    <!-- else copy and process next element -->
                    <xsl:otherwise>
                        <xsl:copy-of select="$next"/>
                        <xsl:call-template name="getLine">
                            <xsl:with-param name="next" select="$next/following-sibling::*[1]"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- element is a break: terminate on double, or copy single and process next element -->
            <xsl:when test="$next/self::break">
                <xsl:choose>
                    <!-- following element is also a break, terminate -->
                    <xsl:when test="$next/following-sibling::*[1]/self::break"/>
                    <!-- else copy and continue -->
                    <xsl:otherwise>
                        <xsl:copy-of select="$next"/>
                        <xsl:call-template name="getLine">
                            <xsl:with-param name="next" select="$next/following-sibling::*[1]"/>
                        </xsl:call-template>        
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- element is not a line or a break, we are done here -->
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <!-- populate cast/crew elements -->
    <xsl:template name="getCredit">
        <xsl:param name="next"/>
        <xsl:choose>
            <!-- element is a line, add as credit and process next element -->
            <xsl:when test="$next/self::line">
                <xsl:choose>
                    <!-- comma indicates there are multiple people listed for this role:
                         the last two words before the first comma and everything after are names,
                         everything before that is the role -->
                    <xsl:when test="contains($next, ',')">
                        <!-- split into pre- and post-comma strings -->
                        <xsl:variable name="piece1" select="substring-before($next, ',')"/>
                        <xsl:variable name="piece2" select="substring-after($next, ',')"/>
                        <!-- split the first string into a sequence of words -->
                        <xsl:variable name="words" select="tokenize($piece1, ' ')"/>
                        <credit>
                            <role>
                                <!-- include each word except the last two before the comma -->
                                <xsl:for-each select="$words[position() &lt; (last()-1)]">
                                    <xsl:value-of select="concat(., ' ')"/>
                                </xsl:for-each>    
                            </role>
                            <talent>
                                <!-- include the last two words from the first piece and the whole second piece -->
                                <xsl:value-of select="concat($words[position()=(last()-1)], ' ', $words[position()=last()], ',', $piece2)"/>
                            </talent>
                        </credit>
                    </xsl:when>
                    <!-- check for ampersand in names only (at least one occurence but not early in line) -->
                    <xsl:when test="contains($next, '&amp;') and not(contains(substring($next,1,15), '&amp;'))">
                        <!-- split into pre- and post-amp strings -->
                        <xsl:variable name="piece1" select="substring-before($next, ' &amp;')"/>
                        <xsl:variable name="piece2" select="substring-after($next, ' &amp;')"/>
                        <!-- split the first string into a sequence of words -->
                        <xsl:variable name="words" select="tokenize($piece1, ' ')"/>
                        <credit>
                            <role>
                                <!-- include each word except the last two before the amp -->
                                <xsl:for-each select="$words[position() &lt; (last()-1)]">
                                    <xsl:value-of select="concat(., ' ')"/>
                                </xsl:for-each>    
                            </role>
                            <talent>
                                <!-- include the last two words from the first piece and the whole second piece -->
                                <xsl:value-of select="concat($words[position()=(last()-1)], ' ', $words[position()=last()], ' &amp;', $piece2)"/>
                            </talent>
                        </credit>
                    </xsl:when>
                    <!-- simpler case: the last two words are the name and everything before that is the role -->
                    <xsl:otherwise>
                        <!-- split line into a sequence of words -->
                        <xsl:variable name="words" select="tokenize($next, ' ')"/>
                        <credit>
                            <role>
                                <!-- include each word before the penultimate in the role-->
                                <xsl:for-each select="$words[position() &lt; (last()-1)]">
                                    <xsl:value-of select="concat(., ' ')"/>
                                </xsl:for-each>    
                            </role>
                            <talent>
                                <!-- the last two words should be the name -->
                                <xsl:value-of select="concat($words[position()=(last()-1)], ' ', $words[position()=last()])"/>
                            </talent>
                        </credit>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="getCredit">
                    <xsl:with-param name="next" select="$next/following-sibling::*[1]"/>
                </xsl:call-template>
            </xsl:when>
            <!-- element is not a line, we are done here -->
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <!-- populate biography elements -->
    <xsl:template name="groupEntries">
        <xsl:param name="start"/>
        <!-- group consecutive lines, adapted from example at http://www.java2s.com/Code/XML/XSLT-stylesheet/Groupingwithgroupadjacent.htm -->
        <xsl:for-each-group select="$start/following-sibling::*" group-adjacent="boolean(self::line)">
            <xsl:choose>
                <!-- create one entry for each group -->
                <xsl:when test="current-grouping-key()">
                    <entry>
                        <!-- copy each line into group -->
                        <xsl:for-each select="current-group()">
                            <xsl:value-of select="concat(., ' ')"/>
                        </xsl:for-each>
                    </entry>
                </xsl:when>
                <!-- omit breaks or other intervening elements -->
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>

</xsl:stylesheet>
