<?xml version="1.1" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="xml" indent="yes"/>



    <xsl:template match="@* | node()" priority="-1" mode="add-id #default">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <!-- create seg for each word or ponctuation or others -->
    <xsl:template match="//body//text()[not(ancestor::note | ancestor::reg | ancestor::corr)]">
        <xsl:analyze-string regex="(\w+|[.,?!-;:])" select=".">
            <xsl:matching-substring>
                <seg>
                    <xsl:value-of select="."/>
                </seg>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <!-- create xml:id for each seg -->
    <xsl:template match="//seg" mode="add-id">
        <xsl:for-each select=".">
            <xsl:choose>
                <xsl:when test="matches(., '(\w+)')">
                    <!-- 
                    <xsl:choose>
                        <xsl:when test=".[following-sibling::lb[@break = 'no']][1]">
                            <xsl:copy>
                                <xsl:attribute name="xml:id">
                                    w<xsl:number level="any"/>.<xsl:number/>
                                </xsl:attribute>
                                <xsl:value-of select="."/>
                            </xsl:copy>
                        </xsl:when>
                       
                        <xsl:when test=".[preceding-sibling::lb[@break = 'no']][1]">
                            <xsl:copy>
                                <xsl:attribute name="xml:id">
                                    <xsl:number level="any"/>.<xsl:number/>
                                </xsl:attribute>
                                <xsl:value-of select="."/>
                            </xsl:copy>
                        </xsl:when>
                        
                        <xsl:otherwise>-->
                    <xsl:copy>
                        <xsl:attribute name="xml:id"> w<xsl:number level="any"/>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="matches(., '[.,?!:;-]')">
                    <xsl:copy>
                        <xsl:attribute name="xml:id"> pc<xsl:number level="any"/>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                    </xsl:copy>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy>
                        <xsl:attribute name="xml:id"> seg<xsl:number level="any"/>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="/" mode="create_stf">

        <xsl:variable name="copy_text">
            <xsl:for-each select="//text//seg">
                <xsl:copy>
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="@xml:id"/>
                    </xsl:attribute>
                    <xsl:value-of select="node()"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>


        <xsl:variable name="create_stf_persName">
            <xsl:for-each select="//text//persName">
                <xsl:choose>
                    <xsl:when test="./count(seg) > 1">
                        <!-- when it (<name>) consists of more than one word -->
                        <persName stf_from="{./seg[position() = 1]/@xml:id}"
                            stf_to="{./seg[last()]/@xml:id}"/>
                        <xsl:choose>
                            <xsl:when test=".[@key]">
                                <xsl:attribute name="key">
                                    <xsl:value-of select="./@key"/>
                                </xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <persName stf_target="#{.//seg/@xml:id}"/>
                        <xsl:choose>
                            <xsl:when test=".[@key]">
                                <xsl:attribute name="key">
                                    <xsl:value-of select="./@key"/>
                                </xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>


        <xsl:variable name="create_stf_hi">
            <xsl:for-each select="//text//hi">
                <xsl:choose>
                    <xsl:when test="./ancestor::seg">
                        <!-- when it (<hi>) is only   a part of/smaller than/nested in    a word -->
                        <hi
                            stf_target="#{../@xml:id},{string-length(substring-before(.., .)) + 1},{string-length(.)}"
                            rend="{@rend}"/>
                    </xsl:when>
                    <xsl:when test="./count(seg) > 1">
                        <!-- when it (<hi>) consists of more than one word -->
                        <hi stf_from="#{./seg[position() = 1]/@xml:id}"
                            stf_to="#{./seg[last()]/@xml:id}" rend="{@rend}"/>
                    </xsl:when>
                    <xsl:when test="./seg and ./*/seg">
                        <!-- when it (<hi>) includes a word and other tags -->
                        <hi stf_from="#{.//*[position() = 1]/@xml:id}"
                            stf_to="#{./*[last()]/@xml:id}" rend="{@rend}"/>
                    </xsl:when>
                    <xsl:when test="./*/count(seg) > 1">
                        <!-- when it (<hi>) includes a tag containing more than one word -->
                        <hi stf_from="#{.//*[position() = 1]/@xml:id}"
                            stf_to="#{.//*[last()]/@xml:id}" rend="{@rend}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- when it (<hi>) surrounds a single word -->
                        <hi stf_target="#{.//seg/@xml:id}" rend="{@rend}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>


        <xsl:variable name="create_stf_choice_reg">
            <xsl:for-each select="//text//choice[reg and orig]">
                <xsl:choose>
                    <xsl:when test="./ancestor::seg">
                        <!-- when it (<choice>) is only   a part of/smaller than/nested in    a word -->
                        <reg
                            stf_target="#{../@xml:id},{string-length(substring-before(.., .)) + 1},{string-length(orig)}">
                            <xsl:value-of select="reg"/>
                        </reg>
                    </xsl:when>
                    <xsl:when test="orig/count(seg) > 1">
                        <!-- when it (<choice>) consists of more than one word -->
                        <reg stf_from="#{orig/seg[position() = 1]/@xml:id}"
                            stf_to="#{orig/seg[last()]/@xml:id}">
                            <xsl:value-of select="reg"/>
                        </reg>
                    </xsl:when>
                    <xsl:otherwise>
                        <reg stf_target="#{.//seg/@xml:id}">
                            <xsl:value-of select="reg"/>
                        </reg>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="create_stf_choice_corr">
            <xsl:for-each select="//text//choice[sic and corr]">
                <xsl:choose>
                    <xsl:when test="./ancestor::seg">
                        <!-- when it (<choice>) is only   a part of/smaller than/nested in    a word -->
                        <corr
                            stf_target="#{../@xml:id},{string-length(substring-before(.., .)) + 1},{string-length(sic)}">
                            <xsl:value-of select="corr"/>
                        </corr>
                    </xsl:when>
                    <xsl:when test="sic/count(seg) > 1">
                        <!-- when it (<choice>) consists of more than one word -->
                        <corr stf_from="#{sic/seg[position() = 1]/@xml:id}"
                            stf_to="#{sic/seg[last()]/@xml:id}">
                            <xsl:value-of select="corr"/>
                        </corr>
                    </xsl:when>
                    <xsl:otherwise>
                        <corr stf_target="#{.//seg/@xml:id}">
                            <xsl:value-of select="corr"/>
                        </corr>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>


        <xsl:variable name="create_stf_unclear">
            <xsl:for-each select="//text//unclear">
                <xsl:choose>
                    <xsl:when test="./ancestor::seg">
                        <!-- when it (<unclear>) is only   a part of/smaller than/nested in    a word -->
                        <unclear
                            stf_target="#{../@xml:id},{string-length(substring-before(.., .)) + 1},{string-length(.)}"
                            reason="{@reason}"/>
                    </xsl:when>
                    <xsl:when test="./count(seg) > 1">
                        <!-- when it (<unclear>) consists of more than one word -->
                        <unclear stf_from="#{./seg[position() = 1]/@xml:id}"
                            stf_to="#{./seg[last()]/@xml:id}" reason="{@reason}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- when it (<unclear>) surrounds a single word -->
                        <unclear stf_target="#{.//seg/@xml:id}" reason="{@reason}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
       

        <xsl:variable name="create_stf_note">
            <xsl:for-each select="//text//note">
                <note stf_target="#{./preceding::seg[position() = 1]/@xml:id}" resp="{./@resp}">
                    <xsl:copy-of select="./text()"/>
                </note>
            </xsl:for-each>
        </xsl:variable>


        <xsl:variable name="create_stf_column">
            <xsl:for-each select="//text//cb">
                <xsl:choose>
                    <xsl:when test="count(following::seg) > 1">
                        <div type="column">
                            <xsl:choose>
                                <xsl:when test=".[@n]">
                                    <xsl:attribute name="n">
                                        <xsl:value-of select="./@n"/>
                                    </xsl:attribute>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:attribute name="stf_from">
                                <xsl:text>#</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="ancestor::seg">
                                        <xsl:value-of select="../@xml:id"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="string-length(substring-before(.., .)) + 2"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                            select="following::seg[position() = 1]/@xml:id"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="stf_to">
                                <xsl:text>#</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="following::cb[position() = 1]/ancestor::seg">
                                        <xsl:value-of
                                            select="following::cb[position() = 1]/../@xml:id"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="string-length(substring-before(.., .)) + 1"/>
                                    </xsl:when>
                                    <xsl:when test="not(following::cb)">
                                        <xsl:value-of select="following::seg[last()]/@xml:id"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                            select="following::cb[position() = 1]/preceding::seg[position() = 1]/@xml:id"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </div>
                    </xsl:when>
                    <xsl:when test="not(following::seg)"/>
                    <xsl:otherwise>
                        <div type="column" n="{@n}"
                            stf_target="#{following::seg[position() = 1]/@xml:id}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>


        <xsl:variable name="create_stf_page">
            <xsl:for-each select="//text//pb">
                <xsl:choose>
                    <xsl:when test="count(following::seg) > 1">
                        <div type="page">
                            <xsl:choose>
                                <xsl:when test=".[@rend]">
                                    <xsl:attribute name="rend">
                                        <xsl:value-of select="./@rend"/>
                                    </xsl:attribute>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:attribute name="stf_from">
                                <xsl:text>#</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="ancestor::seg">
                                        <xsl:value-of select="../@xml:id"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="string-length(substring-before(.., .)) + 2"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="following::seg[1]/@xml:id"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="stf_to">
                                <xsl:text>#</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="following::pb[1]/ancestor::seg">
                                        <xsl:value-of select="following::pb[1]/../@xml:id"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="string-length(substring-before(.., .)) + 1"/>
                                    </xsl:when>
                                    <xsl:when test="not(following::pb)">
                                        <xsl:value-of select="following::seg[last()]/@xml:id"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                            select="following::pb[1]/preceding::seg[1]/@xml:id"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>


                            <!--
                                
                                NEST COLUMNS !!!
                                
                                want to have columns here inside, IF cb/@stf_from >= pb/@stf_from    and    cb/@to =< pb/@stf_from  !!!
                                same thing should be done with lines  
                                
                                this does not work ...  -->
                            <xsl:copy-of
                                select="
                                    $create_stf_column[//cb/number(following::seg[1]/@xml:id/translate(., 'w', '')) >=
                                    //pb/number(following::seg[1]/@xml:id/translate(., 'w', ''))]"/>





                        </div>
                    </xsl:when>
                    <xsl:when test="not(following::seg)"/>
                    <xsl:otherwise>
                        <div type="page" n="{@n}"
                            stf_target="#{following::seg[position() = 1]/@xml:id}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>



        <xsl:variable name="create_stf_line">
            <xsl:for-each select="//text//lb">
                <xsl:choose>
                    <xsl:when test="count(following::seg) > 1">
                        <div type="line">
                            <xsl:choose>
                                <xsl:when test=".[@n]">
                                    <xsl:attribute name="n">
                                        <xsl:value-of select="./@n"/>
                                    </xsl:attribute>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:attribute name="stf_from">
                                <xsl:text>#</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="ancestor::seg">
                                        <xsl:value-of select="../@xml:id"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="string-length(substring-before(.., .)) + 2"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                            select="following::seg[position() = 1]/@xml:id"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="stf_to">
                                <xsl:text>#</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="following::lb[position() = 1]/ancestor::seg">
                                        <xsl:value-of
                                            select="following::lb[position() = 1]/../@xml:id"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="string-length(substring-before(.., .)) + 1"/>
                                    </xsl:when>
                                    <xsl:when test="not(following::lb)">
                                        <xsl:value-of select="following::seg[last()]/@xml:id"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                            select="following::lb[position() = 1]/preceding::seg[position() = 1]/@xml:id"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </div>
                    </xsl:when>
                    <xsl:when test="not(following::seg)"/>
                    <xsl:otherwise>
                        <div type="line" n="{@n}"
                            stf_target="#{following::seg[position() = 1]/@xml:id}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>




        <!--    MAGDA
        <xsl:variable name="test">
            <xsl:for-each-group select="//pb | //cb" group-starting-with="pb">
                <group>
                    <xsl:for-each select="current-group()">
                        <elem><xsl:value-of select="name(.)"/>
                            
                            <xsl:value-of select="@n"></xsl:value-of>
                        </elem> 
                    </xsl:for-each>
                </group>
                
            </xsl:for-each-group>
        </xsl:variable> 
   -->


        <xsl:variable name="test1">
            <xsl:for-each-group select="//pb | //cb" group-starting-with="pb">
                <div type="page">
                    <xsl:choose>
                        <xsl:when test=".[@n]">
                            <xsl:attribute name="n">
                                <xsl:value-of select="./@n"/>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="stf_from">
                        <xsl:text>#</xsl:text>
                        <xsl:choose>
                            <xsl:when test="ancestor::seg">
                                <xsl:value-of select="../@xml:id"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="string-length(substring-before(.., .)) + 2"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="following::seg[1]/@xml:id"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="stf_to">
                        <xsl:text>#</xsl:text>
                        <xsl:choose>
                            <xsl:when test="following::pb[1]/ancestor::seg">
                                <xsl:value-of select="following::pb[1]/../@xml:id"/>
                                <xsl:text>,</xsl:text>
                                <xsl:value-of select="string-length(substring-before(.., .)) + 1"/>
                            </xsl:when>
                            <xsl:when test="not(following::pb)">
                                <xsl:value-of select="following::seg[last()]/@xml:id"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="following::pb[1]/preceding::seg[1]/@xml:id"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:for-each select="current-group()">
                        <div type="column">
                            <xsl:choose>
                                <xsl:when test=".[@n]">
                                    <xsl:attribute name="n">
                                        <xsl:value-of select="./@n"/>
                                    </xsl:attribute>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:attribute name="stf_from">
                                <xsl:text>#</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="ancestor::seg">
                                        <xsl:value-of select="../@xml:id"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="string-length(substring-before(.., .)) + 2"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                            select="following::seg[position() = 1]/@xml:id"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="stf_to">
                                <xsl:text>#</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="following::cb[position() = 1]/ancestor::seg">
                                        <xsl:value-of
                                            select="following::cb[position() = 1]/../@xml:id"/>
                                        <xsl:text>,</xsl:text>
                                        <xsl:value-of
                                            select="string-length(substring-before(.., .)) + 1"/>
                                    </xsl:when>
                                    <xsl:when test="not(following::cb)">
                                        <xsl:value-of select="following::seg[last()]/@xml:id"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                            select="following::cb[position() = 1]/preceding::seg[position() = 1]/@xml:id"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>

                        </div>
                    </xsl:for-each>
                </div>

            </xsl:for-each-group>
        </xsl:variable>




        <xsl:variable name="create_stf_l">
            <xsl:for-each select="//text//l">
                <xsl:choose>
                    <xsl:when test="./ancestor::seg">
                        <!-- when it (<l>) is only   a part of/smaller than/nested in    a word -->
                        <l
                            stf_target="#{../@xml:id},{string-length(substring-before(.., .)) + 1},{string-length(.)}"
                        />
                    </xsl:when>
                    <xsl:when test=".//count(seg) > 1">
                        <!-- when it (<l>) consists of more than one word -->
                        <l stf_from="#{(.//seg)[1]/@xml:id}" stf_to="#{(.//seg)[last()]/@xml:id}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- when it (<l>) surrounds a single word -->
                        <l stf_target="#{.//seg/@xml:id}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="create_stf_lg">
            <xsl:for-each select="//text//lg">
                <xsl:choose>
                    <xsl:when test=".//count(seg) > 1">
                        <!-- when it (<lg>) consists of more than one word -->
                        <lg stf_from="#{(.//seg)[1]/@xml:id}" stf_to="{(.//seg)[last()]/@xml:id}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- when it (<lg>) surrounds a single word -->
                        <lg stf_target="#{.//seg/@xml:id}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>


        <xsl:element name="TEI">
            <xsl:element name="standoff">
                <!-- 
                <xsl:element name="stf">
                    <xsl:attribute name="xml:id">stf_test</xsl:attribute>
                    <xsl:copy-of select="$test1"/>
                </xsl:element>
                <xsl:element name="stf">
                    <xsl:attribute name="xml:id">stf_structure</xsl:attribute>
                    <xsl:copy-of select="$test1"/>
                </xsl:element>
               -->
                <xsl:choose>
                    <xsl:when test="//pb">
                        <xsl:element name="stf">
                            <xsl:attribute name="xml:id">stf_page</xsl:attribute>
                            <xsl:copy-of select="$create_stf_page"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="//cb">
                        <xsl:element name="stf">
                            <xsl:attribute name="xml:id">stf_column</xsl:attribute>
                            <xsl:copy-of select="$create_stf_column"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="//lb">
                        <xsl:element name="stf">
                            <xsl:attribute name="xml:id">stf_line</xsl:attribute>
                            <xsl:copy-of select="$create_stf_line"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="//lg">
                        <xsl:element name="stf">
                            <xsl:attribute name="xml:id">stf_lg</xsl:attribute>
                            <xsl:copy-of select="$create_stf_lg"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="//l">
                        <xsl:element name="stf">
                            <xsl:attribute name="xml:id">stf_l</xsl:attribute>
                            <xsl:copy-of select="$create_stf_l"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="//persName">
                        <xsl:element name="stf">
                            <xsl:attribute name="xml:id">stf_persName</xsl:attribute>
                            <xsl:copy-of select="$create_stf_persName"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="//hi">
                        <xsl:element name="stf">
                            <xsl:attribute name="xml:id">stf_hi</xsl:attribute>
                            <xsl:copy-of select="$create_stf_hi"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="//reg">
                        <xsl:element name="stf">
                            <xsl:attribute name="xml:id">stf_choice_reg</xsl:attribute>
                            <xsl:copy-of select="$create_stf_choice_reg"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="//corr">
                        <xsl:element name="stf">
                            <xsl:attribute name="xml:id">stf_choice_corr</xsl:attribute>
                            <xsl:copy-of select="$create_stf_choice_corr"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="//unclear">
                        <xsl:element name="stf">
                            <xsl:attribute name="xml:id">stf_unclear</xsl:attribute>
                            <xsl:copy-of select="$create_stf_unclear"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="//note">
                        <xsl:element name="stf">
                            <xsl:attribute name="xml:id">stf_note</xsl:attribute>
                            <xsl:copy-of select="$create_stf_note"/>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
            </xsl:element>
            <xsl:element name="stf_text">
                <div>
                    <xsl:copy-of select="$copy_text"/>
                </div>
            </xsl:element>
        </xsl:element>
    </xsl:template>


    <!-- steps -->
    <xsl:template match="/">
        <xsl:variable name="all">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:variable name="tokenize_add-id">
            <xsl:apply-templates select="$all" mode="add-id"/>
        </xsl:variable>
        <xsl:variable name="create_stf">
            <xsl:apply-templates select="$tokenize_add-id" mode="create_stf"/>
        </xsl:variable>
        <xsl:copy-of select="$create_stf"/>
    </xsl:template>






</xsl:stylesheet>
