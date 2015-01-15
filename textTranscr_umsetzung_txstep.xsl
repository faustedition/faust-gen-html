<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:ge="http://www.tei-c.org/ns/geneticEditions" xmlns:f="http://www.faustedition.net/ns"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">
    <!-- Idenity Transformation -->
    <xsl:template match="@*|node()">
        <xsl:choose>
            <xsl:when test="name()='f:revType'"/>
            <xsl:when test="name()='ge:stage'"/>
            <xsl:when test="name()='f:correction'"/>
            <!-- (weil diese Attribute Störungen verursachen) -->
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Einfache Hinzufügung -->
    <xsl:template match="add">
        <xsl:text>{+</xsl:text>
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
        <xsl:text>+}</xsl:text>
    </xsl:template>
    <!-- Hinzufügung in einer einfachen Ersetzung -->
    <xsl:template match="add[parent::subst]">
        <xsl:text>⟨</xsl:text>
        <xsl:text>˻</xsl:text>
        <hi>
            <xsl:text>:</xsl:text>
        </hi>
        <xsl:apply-templates select="node()"/>
        <xsl:text>⟩</xsl:text>
    </xsl:template>
    <!-- Erste Hinzufügung in einer zweifachen Ersetzung -->
    <xsl:template match="add[parent::subst[parent::del[parent::subst]]]">
        <xsl:text>⟨</xsl:text>
        <xsl:text>˻</xsl:text>
        <hi>
            <xsl:text>:</xsl:text>
        </hi>
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <!-- Erste Hinzufügung in einer zweifachen Ersetzung -->
    <xsl:template match="add[parent::subst[child::del[child::subst]]]">
        <hi><xsl:text>:</xsl:text></hi>
        <xsl:apply-templates select="node()"/>
        <xsl:text>⟩</xsl:text>
    </xsl:template>
    <xsl:template match="addSpan">
        <l>
            <xsl:text>⟨</xsl:text>
            <hi>
                <xsl:text>erg↓</xsl:text>
            </hi>
            <xsl:text>⟩</xsl:text>
        </l>
    </xsl:template>
    <xsl:template match="anchor">
        <l>
            <xsl:text>⟨</xsl:text>
            <hi>
                <xsl:text>↑erg/tilgt?</xsl:text>
            </hi>
            <xsl:text>⟩</xsl:text>
        </l>
    </xsl:template>
    <xsl:template match="app">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="app/text()"/>
    <!--
    <xsl:template match="choice/text()"/>
    <xsl:template match="choice">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>-->
    <xsl:template match="corr"/>
    <!-- Beschädigung der Inskription  und Textverlust -->
    <xsl:template match="damage">
        <xsl:text>◌</xsl:text>
        <xsl:apply-templates select="node()"/>
        <xsl:text>◌</xsl:text>
    </xsl:template>
    <xsl:template match="damageSpan">
        <l>
            <xsl:text>◌…◌</xsl:text>
        </l>
    </xsl:template>
    <!-- Einfache Tilgung -->
    <xsl:template match="del">
        <xsl:text>{-</xsl:text>
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
        <xsl:text>-}</xsl:text>
    </xsl:template>
    <!-- Äußere Tilgung bei zwei Tilgungen -->
    <xsl:template match="del[child::del]">
        <xsl:text>˻˻</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>⟨</xsl:text>
        <xsl:text>˻˻</xsl:text>
        <hi>
            <xsl:text>tilgt</xsl:text>
        </hi>
        <xsl:text>⟩</xsl:text>
    </xsl:template>
    <!-- Zunächst Getilgtes bei rückgängig gemachter Ersetzung-->
    <xsl:template match="del[child::restore]">
        <xsl:text>˻</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- Sofortrevision -->
    <xsl:template match="del[matches(@f:revType, 'instant')]">
        <xsl:text>⟨</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>></xsl:text>
        <xsl:text>⟩</xsl:text>
    </xsl:template>
    <!-- Zunächst Hinzugefügtes bei einer rückgängig gemachter Ersetzung -->
    <xsl:template match="del[parent::add[parent::subst[child::del[child::restore]]]]">
        <!--<xsl:text>></xsl:text>-->
        <xsl:apply-templates select="node()"/>
        <xsl:text> </xsl:text>
        <hi>
            <xsl:text>restit</xsl:text>
        </hi>
        <!--<xsl:text>⟩</xsl:text>-->
    </xsl:template>
    <!-- Getilgtes in Ersetzung -->
    <xsl:template match="del[parent::subst]">
        <xsl:text>˻</xsl:text>
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="del[parent::subst[child::del[child::subst]]]">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="delSpan">
        <l>
            <xsl:text>⟨</xsl:text>
            <hi>
                <xsl:text>tilgt↓</xsl:text>
            </hi>
            <xsl:text>⟩</xsl:text>
        </l>
    </xsl:template>
    <xsl:template match="ex"/>
    <xsl:template match="expan"/>
    <xsl:template match="g[matches(@ref, '#parenthesis_left')]">
        <xsl:text>(</xsl:text>
    </xsl:template>
    <xsl:template match="g[matches(@ref, '#parenthesis_right')]">
        <xsl:text>)</xsl:text>
    </xsl:template>
    <xsl:template match="gap">
        <xsl:text>×…×</xsl:text>
    </xsl:template>
    <xsl:template match="gap[matches(@quantity, '1')]">
        <xsl:text>×</xsl:text>
    </xsl:template>
    <xsl:template match="gap[matches(@quantity, '2')]">
        <xsl:text>××</xsl:text>
    </xsl:template>
    <xsl:template match="gap[matches(@quantity, '3')]">
        <xsl:text>×××</xsl:text>
    </xsl:template>
    <!--    <xsl:template match="gap[matches(@precision, 'medium')]">
        <xsl:text>×…×</xsl:text>
    </xsl:template>
    -->
    <xsl:template match="lem">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="profileDesc"/>
    <xsl:template match="rdg">
        <app>
            <rdg>
                <xsl:apply-templates/>
            </rdg>
        </app>
    </xsl:template>
    <xsl:template match="revisionDesc"/>
    <xsl:template match="space[parent::add]">
        <xsl:text>***</xsl:text>
    </xsl:template>
    <xsl:template match="space[parent::del]">
        <xsl:text>***</xsl:text>
    </xsl:template>
    <xsl:template match="space[parent::l]">
        <xsl:text>***</xsl:text>
    </xsl:template>
    <xsl:template match="space[parent::body]">
        <l>
            <xsl:text>***</xsl:text>
        </l>
    </xsl:template>
    <xsl:template match="space[parent::p]">
        <xsl:text>***</xsl:text>
    </xsl:template>
    <xsl:template match="space[parent::sp]">
        <l>
            <xsl:text>***</xsl:text>
        </l>
    </xsl:template>
    <xsl:template match="supplied">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <xsl:template match="subst/text()"/>
    <xsl:template match="subst">
        <xsl:apply-templates/>
    </xsl:template>
    <!--<xsl:template match="teiHeader"/>-->
    <!-- Zeichen -->
    <!--    <xsl:template match="orig/text()">
        <xsl:variable name="tmp1" select=" replace(.,'a','ä')"/>
        <xsl:variable name="tmp2" select=" replace($tmp1,'o','ö')"/>
        <xsl:variable name="tmp3" select=" replace($tmp2,'u','ü')"/>
        <xsl:value-of select="$tmp3"/>
    </xsl:template>
-->
    <!--    <xsl:template match="orig/text()">
        <xsl:value-of select=" replace(., 'a','ä')"></xsl:value-of>
        </xsl:template>
    -->
    <!--<xsl:template match="orig/text()">
        <xsl:value-of select=" replace(., 'o','ö')"></xsl:value-of>
        </xsl:template>
        <xsl:template match="orig/text()">
        <xsl:value-of select=" replace(., 'u','ü')"></xsl:value-of>
        </xsl:template>-->
    <!--    <xsl:template match="text()[parent::orig]">
        <xsl:value-of select="replace('a', 'a','ä')"></xsl:value-of>
        </xsl:template>
        <xsl:template match="text()[parent::orig]">
        <xsl:value-of select=" replace('o', 'o','ö')"></xsl:value-of>
        </xsl:template>
        <xsl:template match="text()[parent::orig]">
        <xsl:value-of select=" replace('u', 'u','ü')"></xsl:value-of>
        </xsl:template>
    -->
    <xsl:template match="unclear">
        <xsl:text>{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="unclear[matches(@cert, 'high')]">
        <xsl:text>{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="unclear[matches(@cert, 'low')]">
        <xsl:text>{{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}}</xsl:text>
    </xsl:template>

</xsl:stylesheet>
