<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:l="http://xproc.org/library"
                type="l:store" name="main">
  <p:input port="source" primary="true"/>
  <p:output port="result" primary="true"/>
  <p:output port="uri">
    <p:pipe step="store" port="result"/>
  </p:output>
  <p:option name="href" required="true"/>
  <p:option name="encoding" select="'utf-8'"/>
  <p:option name="method" select="'xml'"/>

  <p:store name="store">
    <p:with-option name="href" select="$href"/>
    <p:with-option name="method" select="$method"/>
    <p:with-option name="encoding" select="$encoding"/>
  </p:store>

  <p:identity>
    <p:input port="source">
      <p:pipe step="main" port="source"/>
    </p:input>
  </p:identity>
</p:declare-step>
