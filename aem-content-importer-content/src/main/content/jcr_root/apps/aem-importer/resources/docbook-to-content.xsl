<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization"
        exclude-result-prefixes="xs"
        xmlns:xhtml="http://www.w3.org/1999/xhtml"
        xmlns:sling="http://sling.apache.org/jcr/sling/1.0"
        xmlns:cq="http://www.day.com/jcr/cq/1.0"
        xmlns:jcr="http://www.jcp.org/jcr/1.0"
        xmlns:nt="http://www.jcp.org/jcr/nt/1.0"
        xmlns:pd="http://www.adobe.com/pando/1.0"
        xmlns:saxon="http://saxon.sf.net"
        xmlns:d="data:,dpc"
        version="3.0">


<!--**********************************
DocBook_n.xml (full doc) to JCR format
V1.0 Bertrand Sauviat February 2015
***************************************

Local use
/!\ this is an XSLT 3.0 transformation /!\
java -jar saxon9he.jar email_n.xml docbook-to-content.xsl -o:out.xml
The HTML files are stored in a "html" folder
-->

<xsl:import href="htmlparse.xsl"/>
<xsl:output method="xml" indent="yes"/>
<xsl:strip-space elements="*"/>

<!-- Header template -->
<xsl:template match="book">
	<xsl:param name="codeBook" select="@id"/>

	<jcr:root xmlns:sling="http://sling.apache.org/jcr/sling/1.0"
          xmlns:cq="http://www.day.com/jcr/cq/1.0"
          xmlns:jcr="http://www.jcp.org/jcr/1.0"
          xmlns:nt="http://www.jcp.org/jcr/nt/1.0"
          xmlns:pd="http://www.adobe.com/pando/1.0"
          jcr:primaryType="cq:Page">
	  	<jcr:content jcr:primaryType="nt:unstructured" jcr:title="Adobe Campaign" sling:resourceType="wcm/foundation/components/page">
			<par jcr:primaryType="nt:unstructured" sling:resourceType="wcm/foundation/components/parsys">
				<sitemap jcr:primaryType="nt:unstructured" sling:resourceType="foundation/components/sitemap" rootPath="/content/docbook-import"/>
			</par>
		</jcr:content>

		   <xsl:call-template name="chapterCreation">
		   		<xsl:with-param name="codeBook" select="$codeBook"/>
		   </xsl:call-template>
	</jcr:root>
</xsl:template>




<!-- VTL structure creation template -->
<xsl:template name="chapterCreation">
<xsl:param name="codeBook"/>
	<xsl:for-each select="child::chapter">
		<xsl:variable name="escapeName">
			<xsl:call-template name="cleanName">
					<xsl:with-param name="currentTitle" select="child::title"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="buildRecurrentStructure">
			<xsl:with-param name="localName" select="$escapeName"/>
			<xsl:with-param name="codeBook" select="$codeBook"/>
		</xsl:call-template>
	</xsl:for-each>
</xsl:template>





<!-- Recursive template to build VTL Page tree -->
<xsl:template name="buildRecurrentStructure">
	<xsl:param name="localName"/>
	<xsl:param name="codeBook"/>
	<xsl:variable name="fileName" select="concat($codeBook,'_',$localName,'.html')"/>

	<xsl:element name="{$localName}">
			<xsl:attribute name="jcr:primaryType" select="'cq:Page'"/>
			<xsl:element name="jcr:content">
				<xsl:attribute name="jcr:primaryType" select="'nt:unstructured'"/>
				<xsl:attribute name="jcr:title" select="child::title"/>
				<xsl:attribute name="sling:resourceType" select="'wcm/foundation/components/page'"/>
				<xsl:element name="par">
				 	<xsl:attribute name="jcr:primaryType" select="'nt:unstructured'"/>
				 	<xsl:attribute name="sling:resourceType" select="'wcm/foundation/components/parsys'"/>
				 	<xsl:element name="text">
				 		<xsl:attribute name="jcr:primaryType" select="'nt:unstructured'"/>
				 		<xsl:attribute name="sling:resourceType" select="'wcm/foundation/components/text'"/>
				 		<xsl:attribute name="textIsRich" select="'true'"/>
				 		<xsl:attribute name="text">
				 			<xsl:call-template name="retrieveHTMLContent">
				 				<xsl:with-param name="HTMLfileName" select="$fileName"/>
				 			</xsl:call-template>
				 		</xsl:attribute>
			 		</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:for-each select="child::sect1">
				<xsl:variable name="escapeName">
					<xsl:call-template name="cleanName">
							<xsl:with-param name="currentTitle" select="child::title"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:call-template name="buildRecurrentStructure">
					<xsl:with-param name="localName" select="concat($localName,'_',$escapeName)"/>
					<xsl:with-param name="codeBook" select="$codeBook"/>
				</xsl:call-template>
			</xsl:for-each>
	</xsl:element>
</xsl:template>





<!-- Parse and retrieve the <body> content of each HTML file -->
<xsl:template name="retrieveHTMLContent">
	<xsl:param name="HTMLfileName"/>
	<xsl:variable name="fullPath" select="concat('html/',$HTMLfileName)"/>

	<xsl:variable name="output">
    <output:serialization-parameters name="output">
        <output:method value="html"/>
    </output:serialization-parameters>
	</xsl:variable>

	<xsl:for-each select="d:htmlparse(unparsed-text($fullPath,'UTF-8'))">
		<xsl:for-each select="descendant::xhtml:body">
			<xsl:copy-of select="serialize(.,$output/output:serialization-parameters)"/>
		</xsl:for-each>
	</xsl:for-each>

</xsl:template>




<!-- Template to transform title tags in clean HTML filename (same as in the legacy XML2HTML transformation)-->
<xsl:template name="cleanName">
	<xsl:param name="codeBook"/>
	<xsl:param name="currentTitle"/>

	<xsl:variable name="strFrom">àâäáîïíôöóùûüéèêëçñ !?,&quot;:&amp;'/&lt;&gt;#()"ÜüÖÄ</xsl:variable>
	<xsl:variable name="strTo">aaaaiiiooouuueeeecn____~-e_-__-___UuOA</xsl:variable>
	<xsl:variable name="finalString" select="translate($currentTitle, $strFrom, $strTo)"/>
	<xsl:value-of select="$finalString"/>
</xsl:template>

</xsl:stylesheet>
