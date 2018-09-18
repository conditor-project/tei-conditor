<?xml version="1.0" encoding="UTF-8"?>
<!-- <xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:redirect="org.apache.xalan.xslt.extensions.Redirect"
    extension-element-prefixes="redirect"> -->

	<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:redirect="org.apache.xalan.xslt.extensions.Redirect"
		extension-element-prefixes="redirect" xmlns="http://www.tei-c.org/ns/1.0">
<!-- sépare les notices TEI de teiCorpus en notices uniques, nommées PMID.xml dans dossier spécifique, mais souci avec xmlns
		OU :
	sépare les notices source. OK -->
<xsl:output encoding="UTF-8" indent="no"/>

<xsl:param name="AN"/>

<xsl:template match="/teiCorpus">
	<xsl:for-each select="TEI">
		
		<xsl:variable name="PMID" select=".//idno[@type='pubmed']"/>  <!-- evite de séparer les Articlebooks et Articles -->
			
			
			<redirect:write file="{concat('TEI/PubmedUnic_', $AN, '/', $PMID, '_0.xml')}">  <!-- _0 tant que pb du xmlns="" pas résolu -->
				<!-- <TEI xmlns="http://www.tei-c.org/ns/1.0"> cree ensuite un xmlns vide sur text car copy-of ./*-->
				<!-- <TEI> ne met pas l'espace de noms -->
					<!-- <xsl:attribute name="xmlns">http://www.tei-c.org/ns/1.0</xsl:attribute> il n'aime pas ...-->
					<xsl:copy-of select="."/>
				<!-- </TEI> -->
			</redirect:write>
	</xsl:for-each>
</xsl:template>
		
		<xsl:template match="/PubmedArticleSet">
			<xsl:for-each select="PubmedArticle">
				<xsl:variable name="PMID" select="./*/PMID"/>
				<redirect:write file="{concat('PubmedUnic_', $AN, '/', $PMID, '.xml')}">
					<xsl:copy-of select="."/>
				</redirect:write>
			</xsl:for-each>
			<xsl:for-each select="PubmedBookArticle">
				<xsl:variable name="PMID" select=".//PMID"/>
				<redirect:write file="{concat('PubmedUnic', $AN, '/', $PMID, '.xml')}">
					<xsl:copy-of select="."/>
				</redirect:write>
			</xsl:for-each>
		</xsl:template>

</xsl:stylesheet>
