<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs set"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:set="http://exslt.org/sets"
    version="2.0">
    
    
    <xsl:template match="/">
        <xsl:call-template name="createLayer">
          <xsl:with-param name="layerName" select="'stf_persName'"/>
        </xsl:call-template>
        
        <xsl:apply-templates select="//text"/>
    </xsl:template>
    
    <xsl:template name="createLayer">
        <xsl:param name="layerName"/>
        [
        
        <xsl:for-each select="//stf[@xml:id=$layerName]/*">
            <xsl:variable name="from" select="if(@stf_from) then @stf_from else @stf_target"/>
            <xsl:variable name="to" select="if(@stf_to) then @stf_to else @stf_target"/>
            <xsl:variable name="from2" select="translate(substring-before(concat($from, ','), ','), '#', '')"/>
            <xsl:variable name="to2" select="translate(substring-before(concat($to, ','), ','), '#', '')"/>
            <xsl:variable name="fragment">
                <xsl:copy-of select="//*[@xml:id=$from2]"/>
              <xsl:call-template name="set:intersection">
                  <xsl:with-param name="nodes1" select="//*[@xml:id=$from2]/following::*"/>
                  <xsl:with-param name="nodes2" select="//*[@xml:id=$to2]/preceding::*"/>
              </xsl:call-template> 
                <xsl:if test="$from2!=$to2">
                    <xsl:copy-of select="//*[@xml:id=$to2]"/>
                </xsl:if>
            </xsl:variable>
            
            <xsl:variable name="content">
                [
                <xsl:for-each select="$fragment/*">
                    <xsl:text>{</xsl:text>
                    "id": "<xsl:value-of select="./@xml:id"/>"
                    <xsl:text>}</xsl:text>
                    <xsl:if test="position()!=last()">, </xsl:if>
                </xsl:for-each>
                ]
            </xsl:variable>
       
            
            {
            "first": "<xsl:value-of select="$from2"/>",
            "last": "<xsl:value-of select="$to2"/>",
            "class": "<xsl:value-of select="$layerName"/>",
            "fragment": <xsl:copy-of select="$content"/>}
            <xsl:if test="position()!=last()"><xsl:text>, &#xa;</xsl:text></xsl:if>
        </xsl:for-each>
        ]
    </xsl:template>
    
    <xsl:template name="set:intersection">
        <xsl:param name="nodes1" select="/.."/>
        <xsl:param name="nodes2" select="/.."/>
        <xsl:apply-templates select="$nodes1[count(.|$nodes2) = count($nodes2)]" mode="set:intersection"/>
    </xsl:template>
    <xsl:template match="node()|@*" mode="set:intersection">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="div">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="@*|node()" priority="-1" mode="#default">
        <xsl:copy>
            <!-- apply templates (including this one) to its children using whatever mode we're currently using -->
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@xml:id">
        <xsl:attribute name="id">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
</xsl:stylesheet>