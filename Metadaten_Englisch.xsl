<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.faustedition.net/ns"

    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"

    xmlns:f="http://www.faustedition.net/ns" xpath-default-namespace="http://www.faustedition.net/ns"

    exclude-result-prefixes="xs f" version="2.0">

    <xsl:template match="@*|node()">

        <xsl:copy>

            <xsl:apply-templates select="@*|node()"/>

        </xsl:copy>

    </xsl:template>

    <xsl:template match="Dokument">

        <archivalDocument>

            <xsl:apply-templates select="@*|node()"/>   

        </archivalDocument>

    </xsl:template>

    

    <xsl:template match="@xsi:schemaLocation[parent::Dokument]">

        <xsl:attribute name="xsi:schemaLocation" select="'http://www.faustedition.net/ns https://faustedition.uni-wuerzburg.de/xml/schema/metadata.xsd'">

        </xsl:attribute>

    </xsl:template>

    

    <!-- Papierqualität wird nicht mehr erfasst -->

    <xsl:template match="Qualität"/>

    <!-- Papiersorte wird nicht mehr erfasst -->

    <xsl:template match="Papiersorte"/>

    

    <xsl:template match="Metadaten">

        <metadata>

            <xsl:apply-templates select="@*|node()"/> 

        </metadata>   

    </xsl:template>

    

    <xsl:template match="Aufbewahrungsort">

        <repository>

        <xsl:apply-templates select="@*|node()"/>

        </repository>

    </xsl:template>

    

    <xsl:template match="Aufbewahrungsort/text()">

        <xsl:value-of select="replace(.,'GSA','gsa')"/>

    </xsl:template>

    

    <xsl:template match="Sammlung">

        <collection>

            <xsl:apply-templates select="@*|node()"/>

        </collection>

    </xsl:template>   

    

    <xsl:template match="Signatur">

        <idno>

            <xsl:attribute name="type">gsa_1</xsl:attribute>

            <xsl:apply-templates select="@*|node()"/>

            </idno>

    </xsl:template>

    

    <xsl:template match="Provenienz">

        <history>

            <xsl:apply-templates select="@*|node()"/>

        </history>

    </xsl:template>

    

    <xsl:template match="Aufbewahrung">

        <container>

            <xsl:apply-templates select="@*|node()"/>

        </container>

    </xsl:template>

    

    <xsl:template match="Einband">

        <binding>

            <xsl:apply-templates select="@*|node()"/>

        </binding>

    </xsl:template>

    

    <xsl:template match="altIdentifier">

        <idno>

            <xsl:apply-templates select="@*|node()"/>

        </idno>

    </xsl:template>

    

    <xsl:template match="Foliierung-Paginierung">

        <xsl:comment>Numbering:<xsl:apply-templates select="@*|node()"/></xsl:comment>

    </xsl:template>

    

    <xsl:template match="Erhaltungszustand">

        <condition>

            <xsl:apply-templates select="@*|node()"/>

        </condition>

    </xsl:template>

    

    <xsl:template match="Seite">

        <xsl:apply-templates select="node()"/>

    </xsl:template>

    

    <xsl:template match="Zählung">

        <xsl:comment>numberingList:<xsl:apply-templates select="@*|node()"/></xsl:comment>

    </xsl:template>

    

    <xsl:template match="Art[parent::Zählung]">

        <xsl:comment>type:<xsl:apply-templates select="@*|node()"/></xsl:comment>

    </xsl:template>

    

    <xsl:template match="Position">

        <xsl:comment>position:<xsl:apply-templates select="@*|node()"/></xsl:comment>       

    </xsl:template>

    

    <xsl:template match="Gezählt">

        <xsl:comment>counted:<xsl:apply-templates select="@*|node()"/></xsl:comment>         

    </xsl:template>

    

    <xsl:template match="Ungezählt">

        <xsl:comment>uncounted:<xsl:apply-templates select="@*|node()"/></xsl:comment>

    </xsl:template>

    

     <xsl:template match="Hand">

        <xsl:comment>hand:<xsl:apply-templates select="@*|node()"/></xsl:comment>  

     </xsl:template>

    

    <xsl:template match="Schreibmaterial">

        <xsl:comment>writing:medium:<xsl:apply-templates select="@*|node()"/></xsl:comment>

    </xsl:template>

    

    <xsl:template match="Umfang">

        <xsl:comment>volume:<xsl:apply-templates select="@*|node()"/></xsl:comment>

    </xsl:template>

    

    <xsl:template match="Umfang/@Einheit[. = 'Blatt']">

        <xsl:attribute name="{name()}">

            <xsl:text>scope</xsl:text>

        </xsl:attribute>

    </xsl:template>

    

    <xsl:template match="Papierbeschreibung[parent::Metadaten]">

        <xsl:apply-templates select="@*|node()"/>

    </xsl:template>

    

    <xsl:template match="Papierart">

        <paperType>

            <xsl:apply-templates select="@*|node()"/>

        </paperType>

    </xsl:template>

    

    <xsl:template match="Papierart/text()">

        <xsl:value-of select="replace(.,'Postpapier','Briefpapier')"/>

    </xsl:template>

    

    <xsl:template match="Farbe">

        <paperColour>

            <xsl:apply-templates select="@*|node()"/>

        </paperColour>

    </xsl:template>

<!--    <xsl:template match="Qualität">

        <quality>

            <xsl:apply-templates select="@*|node()"/>

        </quality>

        </xsl:template>-->

    

    <xsl:template match="Steglinienabstand">

        <chainLines>

            <xsl:apply-templates select="@*|node()"/>

        </chainLines>

    </xsl:template>

    

    <xsl:template match="WZeichen[parent::Papierbeschreibung]">

        <xsl:apply-templates select="@*|node()"/>

    </xsl:template>

    

    <xsl:template match="Wasserzeichen-Listen-Nummer">

        <xsl:comment>watermarkId:<xsl:apply-templates select="@*|node()"/></xsl:comment>

    </xsl:template>

    

    <xsl:template match="Wasserzeichen[parent::WZeichen]">

        <xsl:comment>watermark<xsl:apply-templates select="@*|node()"/></xsl:comment>

    </xsl:template>

    

    <xsl:template match="Beschreibung">

        <xsl:comment>description:<xsl:apply-templates select="@*|node()"/></xsl:comment>

    </xsl:template>

    

    <xsl:template match="Größe">

          <dimensions>

              <xsl:apply-templates select="@*|node()"/>

          </dimensions>

    </xsl:template>

    

    <xsl:template match="Höhe">

        <height>

            <xsl:apply-templates select="@*|node()"/>

        </height>            

    </xsl:template>

    

    <xsl:template match="Breite">

        <width>

            <xsl:apply-templates select="@*|node()"/>

        </width>

    </xsl:template>

    

    <xsl:template match="Gegenzeichen">

        <xsl:comment>countermarkDesc:<xsl:apply-templates select="@*|node()"/></xsl:comment>

    </xsl:template>

    

    <xsl:template match="Ränder">

        <edges>

            <xsl:apply-templates select="@*|node()"/>

        </edges>

    </xsl:template>

    

    <xsl:template match="Ränder/text()">

        <xsl:value-of select="replace(.,'beschnitten','cut')"/>

    </xsl:template>

    

    <xsl:template match="Bindung[parent::Metadaten]">

        <xsl:apply-templates select="@*|node()"/>

    </xsl:template>

    

    <xsl:template match="Bindematerial">

        <bindingMaterial>

            <xsl:apply-templates select="@*|node()"/>

        </bindingMaterial>

    </xsl:template>

    

    <xsl:template match="Abstand[parent::Stichlöcher]">

        <stabMark>

            <xsl:apply-templates select="@*|node()"/> 

        </stabMark>

    </xsl:template>

    

    <xsl:template match="Stichlöcher"/>

    

    <xsl:template match="Blatteigenschaften[parent::Metadaten]">

        <xsl:apply-templates select="@*|node()"/>

    </xsl:template>

    

    <xsl:template match="Blattmaße">

        <dimensions>

            <xsl:apply-templates select="@*|node()"/>

        </dimensions>

    </xsl:template>

    

    <xsl:template match="Format">

        <format>

            <xsl:apply-templates select="@*|node()"/>

        </format>

    </xsl:template>

    

    <xsl:template match="ErhaltungszustandBlatt">

        <leafCondition>

            <xsl:apply-templates select="@*|node()"/>

        </leafCondition>

    </xsl:template>

    

    <xsl:template match="Steglinienanzahl">

        <xsl:comment>chainlinesCount:<xsl:apply-templates select="@*|node()"/></xsl:comment>

    </xsl:template>

    

    <xsl:template match="Bemerkung">

        <note>

            <xsl:apply-templates select="@*|node()"/>

        </note>

    </xsl:template>

    

    <xsl:template match="Lage[parent::Dokument]">

        <xsl:apply-templates select="@*|node()"/>

    </xsl:template>

    

    <xsl:template match="Klassifikation">

        <classification>

            <xsl:apply-templates select="@*|node()"/>

        </classification>

    </xsl:template>

    

    <xsl:template match="Doppelblatt">

        <sheet>

            <xsl:apply-templates select="@*|node()"/>

        </sheet>

    </xsl:template>

    

    <xsl:template match="Bogenblatt">

        <leaf>

            <xsl:apply-templates select="@*|node()"/>

        </leaf>

    </xsl:template>

    

    <xsl:template match="Einzelblatt">

        <disjunctLeaf>

            <xsl:apply-templates select="@*|node()"/>

        </disjunctLeaf>

    </xsl:template>

    

    <xsl:template match="Blattnummer">

        <xsl:comment>Blattnummer: <xsl:apply-templates select="@*|node()"/></xsl:comment>

    </xsl:template>

    

    <xsl:template match="node()[child::text()[.='s.u.']]"/>  

    <xsl:template match="node()[child::text()[.='w.o.']]"/>

    <xsl:template match="node()[child::text()[.='k.A.']]"/>

    

    <xsl:template match="@Einheit">

        <xsl:attribute name="unit">

            <xsl:value-of select="."/>

        </xsl:attribute>

    </xsl:template>

    

    <!--<xsl:template match="*[not(child::*[child::text()[.!='s.u.']])]"></xsl:template>-->

    <xsl:template match="Mühle">

        <paperMill>

        <xsl:apply-templates select="@*|node()"/>

        </paperMill>

    </xsl:template>

    

    <xsl:template match="ASeite">

        <xsl:apply-templates select="@*|node()"/>

    </xsl:template>

    

    <xsl:template match="Maße">

        <dimensions>

            <xsl:apply-templates select="@*|node()"/>

        </dimensions>

    </xsl:template>

    

    <xsl:template match="Anbringung">

        <patch>

            <xsl:apply-templates select="@*|node()"/>

        </patch>

    </xsl:template>

    

    <xsl:template match="Foliierung">

        <xsl:apply-templates select="@*|node()"/>

    </xsl:template>

    

    <xsl:template match="Anbringungsweise">

        <xsl:apply-templates select="@*|node()"/>

    </xsl:template>



    <xsl:template match="Art[parent::Anbringungsweise]">

        <patchType>

            <xsl:apply-templates select="@*|node()"/>

        </patchType>

    </xsl:template>

    

    <xsl:template match="WelchesZeichen">

        <references>

            <xsl:apply-templates select="@*|node()"/>

        </references>

    </xsl:template>

    

    <xsl:template match="@Art[parent::WelchesZeichen]">

       <xsl:attribute name="type">

           <xsl:value-of select="."/>

       </xsl:attribute> 

    </xsl:template>



    <xsl:template match="Digitalisat">

        <docTranscript>

            <xsl:attribute name="uri">

                <xsl:value-of select="./text()"/>

            </xsl:attribute>

            <xsl:apply-templates select="@*|node()"/>

        </docTranscript>

    </xsl:template>

    

    <xsl:template match="Digitalisat/text()"/>

</xsl:stylesheet>

