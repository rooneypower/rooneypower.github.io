<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:om="http://omeka.org/schemas/omeka-xml/v5" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs om" version="2.0">

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
            <!-- first pass to get metadata and parse text by line -->
            <xsl:variable name="pass1">
                <xsl:apply-templates mode="pass1" select="."/>
            </xsl:variable>
            <!-- second pass to apply meaningful structure to text --> 
            <xsl:variable name="pass2">
                <xsl:apply-templates mode="pass2" select="$pass1"/>
            </xsl:variable>
            <!-- output results of second pass to file -->
            <xsl:copy-of select="$pass2"/>
        </xsl:result-document>
    </xsl:template>

    <!-- 
    Begin pass1 
    -->
    <!-- initialize program document -->
    <xsl:template mode="pass1" match="om:item">
        <program xml:id="{@itemId}">
            <!-- enter container for DC metadata -->
            <xsl:apply-templates mode="pass1" select="om:elementSetContainer/om:elementSet[@elementSetId = '1']"/>
            <!-- enter element containing item text within Omeka metadata -->
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

    <!--
    Begin pass2 
    -->
    <!-- copy elements other than text -->
    <xsl:template mode="pass2" match="node()[name() != 'text'] | @*">
        <xsl:copy>
            <xsl:apply-templates mode="pass2" select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- handle text element with its own submode to avoid copying children -->
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
    <xsl:template mode="text" match="line[upper-case(.) = 'SETTING' or upper-case(.) = 'SYNOPSIS OF SCENES' 
        or upper-case(.) = 'SETTING:' or starts-with(upper-case(.), 'TIME:') 
        or (upper-case(.) = 'PLACE' and preceding-sibling::*[1]/self::break)]">
        <setting>
            <header><xsl:value-of select="."/></header>
            <xsl:call-template name="getLine">
                <xsl:with-param name="next" select="./following-sibling::*[1]"/>
            </xsl:call-template>
        </setting>
    </xsl:template>
    
    <!-- content handled by section, don't automatically output each line--> 
    <xsl:template mode="text" match="line | break"/>

    <!--
    Named Support Templates 
    -->
    <!-- recursively add lines/breaks to a section: terminate on double break, next section header, or unexpected element  -->
    <xsl:template name="getLine">
        <xsl:param name="next"/>
        <xsl:choose>
            <!-- element is a line --> 
            <xsl:when test="$next/self::line">
                <xsl:choose>
                    <!-- beginning of next section, terminate -->
                    <xsl:when test="upper-case($next) = 'THE PRODUCTION TEAM' or upper-case($next) = 'THE CAST'"/>                        
                    <!-- else include and process next element -->
                    <xsl:otherwise>
                        <xsl:choose>
                            <!-- put play title line in line of type playTitle; 
                                check against dc:title, use starts-with since subtitle may not be present-->
                            <xsl:when test="starts-with(upper-case($next/ancestor::program/metadata/dc:title), upper-case($next))">
                                <line type="playTitle"><xsl:value-of select="$next"/></line>
                            </xsl:when>
                            <!-- or simply copy a regular line -->
                            <xsl:otherwise>
                                <xsl:copy-of select="$next"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!-- continue with next element -->
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
    
    <!-- recursively populate cast/crew elements -->
    <xsl:template name="getCredit">
        <xsl:param name="next"/>
        <xsl:choose>
            <!-- element is a line, add as credit and process next element -->
            <xsl:when test="$next/self::line">
                <xsl:choose>
                    <!-- comma indicates there are multiple people listed for this role -->
                    <xsl:when test="contains($next, ',')">
                        <xsl:call-template name="makeOneCredit">
                            <xsl:with-param name="piece1" select="substring-before($next, ',')"/>
                            <xsl:with-param name="piece2" select="substring-after($next, ',')"/>
                            <xsl:with-param name="delim" select="','"></xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <!-- alternately check for ampersand in names only (at least one occurence but not early in line) -->
                    <xsl:when test="contains($next, '&amp;') and not(contains(substring($next,1,15), '&amp;'))">
                        <xsl:call-template name="makeOneCredit">
                            <xsl:with-param name="piece1" select="substring-before($next, ' &amp;')"/>
                            <xsl:with-param name="piece2" select="substring-after($next, ' &amp;')"/>
                            <xsl:with-param name="delim" select="' &amp;'"></xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <!-- simplest case: assume single person -->
                    <xsl:otherwise>
                        <xsl:call-template name="makeOneCredit">
                            <xsl:with-param name="piece1" select="$next"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- continue with next line -->
                <xsl:call-template name="getCredit">
                    <xsl:with-param name="next" select="$next/following-sibling::*[1]"/>
                </xsl:call-template>
            </xsl:when>
            <!-- element is not a line, we are done here -->
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <!-- build one credit element for getCredit -->
    <xsl:template name="makeOneCredit">
        <!-- the base element text, required -->
        <xsl:param name="piece1"/>
        <!-- everything after a first delimiter, optional -->
        <xsl:param name="piece2"/>
        <!-- the delimiter used to define piece2, optional -->
        <xsl:param name="delim"/>
        
        <!-- split the base string into a sequence of words -->
        <xsl:variable name="words" select="tokenize($piece1, ' ')"/>
        <!-- include extra words in talent if there are initials (words of length 1 that aren't an ampersand, or length 2 with a period) -->
        <xsl:variable name="offset" select="1 + count($words[(string-length() = 1 and . != '&amp;') or (string-length() = 2 and contains(., '.'))])"/>
        
        <!-- create the credit element, guessing role and talent based on position -->
        <credit>
            <role>
                <!-- include each word before last()-$offset in the role, typically all but last 2 or 3-->
                <xsl:value-of select="$words[position() &lt; (last()-$offset)]" separator=" "/>  
            </role>
            <talent>
                <!-- include each word from last()-$offset on in talent, generally the last 2 or 3  -->
                <xsl:value-of select="$words[position() >= (last()-$offset)]" separator=" "/>
                <!-- add delimiter and second piece if applicable -->
                <xsl:if test="$piece2">
                    <xsl:value-of select="concat($delim, $piece2)"/>
                </xsl:if>
            </talent>
        </credit>
    </xsl:template>
    
    <!-- populate biography elements -->
    <xsl:template name="groupEntries">
        <xsl:param name="start"/>
        <!-- group consecutive lines, adapted from example at http://www.java2s.com/Code/XML/XSLT-stylesheet/Groupingwithgroupadjacent.htm -->
        <xsl:for-each-group select="$start/following-sibling::*" group-adjacent="boolean(self::line)">
            <!-- create one entry for each group -->
            <xsl:if test="current-grouping-key()">
                <entry>
                    <!-- include text of each line in the group, joined by a space  -->
                    <xsl:value-of select="current-group()" separator=" "/>
                </entry>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>

</xsl:stylesheet>
