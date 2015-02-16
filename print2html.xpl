<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
	<p:input port="source" primary="true"/>
	<p:output port="result" primary="true"/>
	
	<p:serialization port="result" method="html"/>
	
	<p:import href="apply-edits.xpl"/>
	
	<f:apply-edits/>
	
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="print2html.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
</p:declare-step>