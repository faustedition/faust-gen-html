<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
  xmlns:pxf="http://exproc.org/proposed/steps/file"
  xmlns:l="http://xproc.org/library" type="f:metadata-html" name="main" version="1.0">

  <p:input port="source"><p:empty/></p:input>
  <p:input port="parameters" kind="parameter"/>
  <p:output port="result" sequence="true"/>
  <p:option name="paths" select="'paths'"/>
  

  <p:import href="library/recursive-directory-list.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
 
  <!-- Konfiguration laden -->
  <p:xslt name="config" template-name="param">
    <p:input port="source"><p:empty/></p:input>
    <p:input port="stylesheet"><p:document href="xslt/config.xsl"/></p:input>
    <p:with-param name="path_config" select="$paths"></p:with-param>
  </p:xslt>
  
  <p:group>
    <p:variable name="metahtml" select="//c:param[@name='metahtml']/@value"><p:pipe port="result" step="config"></p:pipe></p:variable>
    <p:variable name="source" select="//c:param[@name='source']/@value"><p:pipe port="result" step="config"/></p:variable>
    <p:variable name="debug" select="//c:param[@name='debug']/@value"><p:pipe port="result" step="config"/></p:variable>
    <p:variable name="builddir" select="resolve-uri(//c:param[@name='builddir']/@value)"><p:pipe port="result" step="config"/></p:variable>
    <cx:message log="info">  
      <p:input port="source"><p:pipe port="source" step="main"></p:pipe></p:input>      
      <p:with-option name="message" select="concat('Transforming metadata from ', $source)"/>
    </cx:message>
        


    <l:recursive-directory-list name="list">
      <p:with-option name="path" select="concat($source, '/document')"/>
    </l:recursive-directory-list>

    <p:for-each name="convert-metadata">
      <p:iteration-source select="//c:file[$debug or not(ends-with(@name, 'test.xml'))]"/>
      <p:variable name="filename" select="p:resolve-uri(/c:file/@name)"/>
      <p:variable name="basename" select="replace(replace(doc($filename)//f:idno[@type='faustedition'], 'α', 'alpha'), '[^A-Za-z0-9.-]', '_')"/>
      <p:variable name="outfile" select="concat($metahtml, $basename, '.html')"/>
      <p:variable name="searchfile" select="p:resolve-uri(concat('search/meta/', $basename, '.html'), $builddir)"/>
      
      
      <p:load>
        <p:with-option name="href" select="$filename"/>
      </p:load>
      
      <!--<cx:message log="info">        
        <p:with-option name="message" select="concat('Rendering metadata of ', //f:idno[@type='faustedition'], ' (', $filename, ') to HTML ...')"/>
      </cx:message>-->

      <p:xslt name="generate-html">
        <p:input port="stylesheet"><p:document href="xslt/faust-metadata.xsl"/></p:input>
        <!--<p:with-param name="builddir-resolved" select="$builddir"/>-->
        <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
      </p:xslt>
      
      <p:store encoding="utf-8" method="xhtml" include-content-type="false" indent="true">
        <p:with-option name="href" select="$outfile"/>
      </p:store>
      
      <p:store encoding="utf-8" method="xhtml" include-content-type="false" indent="false">
        <p:with-option name="href" select="$searchfile"/>
        <p:input port="source"><p:pipe port="result" step="generate-html"/></p:input>
      </p:store>
      
      <p:xslt>
        <p:input port="source"><p:pipe port="result" step="generate-html"/></p:input>
        <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
        <p:with-param name="from" select="replace($filename, concat('^', $source), 'faust://xml/')"/>
        <p:input port="stylesheet">
          <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.w3.org/1999/xhtml">
              <xsl:param name="from"/>  
              <xsl:template match="/">
                <f:citations>
                  <xsl:for-each select="//*/@data-bib-uri">
                    <xsl:for-each select="tokenize(., '\s+')">
                      <f:citation from="{$from}"><xsl:value-of select="."/></f:citation>                      
                    </xsl:for-each>
                  </xsl:for-each>
                </f:citations>
              </xsl:template>              
            </xsl:stylesheet>
          </p:inline>
        </p:input>
      </p:xslt>      
    </p:for-each>
    
    <p:identity name="converted-metadata"/>
    
    <p:identity><p:input port="source"><p:pipe port="result" step="list"/></p:input></p:identity>
    <cx:message message="Generating watermark table ..."/>

    <p:for-each name="list-wm">
      <p:iteration-source select="//c:file[$debug or not(ends-with(@name, 'test.xml'))]"/>
      <p:variable name="filename" select="p:resolve-uri(/c:file/@name)"/>            
      <p:load>
        <p:with-option name="href" select="$filename"/>
      </p:load>
      <p:add-attribute match="/*" attribute-name="faust-uri">
        <p:with-option name="attribute-value" select="replace($filename, concat('^', $source), 'faust://xml/')"/>
      </p:add-attribute>
    </p:for-each>
    
    <p:wrap-sequence wrapper="f:documents"/>
    
    <p:xslt>
      <p:input port="stylesheet"><p:document href="xslt/watermark-table.xsl"/></p:input>
      <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
    </p:xslt>
    
    <p:store indent="true" method="xhtml">
      <p:with-option name="href" select="resolve-uri('www/watermark-table.html', $builddir)"/>
    </p:store>
      
    
    <p:identity>
      <p:input port="source"><p:pipe port="result" step="list"></p:pipe></p:input>
    </p:identity>
    
    <p:for-each name="list-headnotes">
      <p:iteration-source select="//c:file[$debug or not(ends-with(@name, 'test.xml'))]"/>
      <p:variable name="filename" select="p:resolve-uri(/c:file/@name)"/>      
      
      <p:load>
        <p:with-option name="href" select="$filename"/>
      </p:load>
      
      <p:xslt>
        <p:input port="stylesheet">
          <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml">
              <xsl:import href="xslt/bibliography.xsl"/>
              <xsl:import href="xslt/utils.xsl"/>
              <xsl:template match="/">                
                <xsl:for-each select="(//f:metadata)[1]">
                  <xsl:variable name="sigil" select="f:idno[@type='faustedition']"/>
                  <xsl:variable name="sigil_n" select="replace(lower-case($sigil), '[ .*]', '')"/>
                  <xsl:variable name="sigil_t" select="f:sigil-for-uri($sigil)"/>                  
                  <div data-sigil="{$sigil}">                                    
                    <h3 class="sigil">
                      <a href="/document?sigil={$sigil_t}&amp;view=structure"><xsl:value-of select="f:idno[@type='faustedition']"/></a>
                      <span class="headnote"><xsl:value-of select="f:headNote"/></span>
                      <a id="{$sigil_n}" href="#{$sigil_n}">¶</a>
                    </h3>
                    <p class="first-note"><xsl:for-each select="f:headNote/following-sibling::f:note[1]">
                      <xsl:call-template name="parse-for-bib"/>
                    </xsl:for-each></p>
                  </div>                  
                </xsl:for-each>
              </xsl:template>
            </xsl:stylesheet>
          </p:inline>
        </p:input>
        <p:with-param name="builddir-resolved" select="$builddir"/>
      </p:xslt>
    </p:for-each>
    
    <p:wrap-sequence wrapper="f:doc" />     
        
    
    <p:xslt>
      <p:input port="stylesheet">
        <p:inline>
          <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml">
            <xsl:import href="xslt/utils.xsl"/>
            
            <xsl:import href="xslt/html-frame.xsl"/>
            
            <xsl:template match="/">             
              <xsl:call-template name="html-frame">
                <xsl:with-param name="content">
               
              <html>
                <head>
                  <title>Die ersten notes nach der headNote</title>
                  <style>
                    .headnote {
                      font-weight: normal;
                      margin-left: 2em;
                      color: gray;
                    }
                  </style>
                </head>
                <body>                  
                  <xsl:for-each select="//div">
                    <xsl:sort select="f:splitSigil(@data-sigil)[1]" stable="yes"/>
                    <xsl:sort select="f:splitSigil(@data-sigil)[2]" data-type="number"/>
                    <xsl:sort select="f:splitSigil(@data-sigil)[3]"/>   
                    <xsl:copy-of select="."/>
                  </xsl:for-each>                                 
                </body>
              </html>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:template>
          </xsl:stylesheet>
        </p:inline>
      </p:input>
    </p:xslt>
    
    <p:store method="xhtml">
      <p:with-option name="href" select="concat($metahtml, 'first-notes.html')"/>
    </p:store>
    
    <p:identity name="metadata-citations">
      <p:input port="source"><p:pipe port="result" step="converted-metadata"/></p:input>
    </p:identity>
  
  </p:group>
  
</p:declare-step>
