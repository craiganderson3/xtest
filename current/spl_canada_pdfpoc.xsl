<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:v3="urn:hl7-org:v3" xmlns:str="http://exslt.org/strings" 
	xmlns:exsl="http://exslt.org/common" xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/" 
	exclude-result-prefixes="exsl msxsl v3 xsl xsi str">
	<xsl:import href="spl_canada.xsl"/>
	<!-- This is the CSS link put into the output -->
	<xsl:param name="css">http://cease353.github.io/xtest/current/spl_canada.css</xsl:param>


	<!-- NULL ROOT TEMPLATE - MIXIN SUPPORT DISABLED -->
	<xsl:template match="/" priority="1">
		<xsl:apply-templates select="/v3:document"/>
	</xsl:template>

	<!-- MAIN HTML PAGE TEMPLATING -->
	<xsl:template match="/v3:document" priority="1">
		<html>
			<xsl:apply-templates select="." mode="html-head"/>
			<body>
				<div class="container-fluid position-relative" id="content">
					<div class="row h-100">
						<xsl:apply-templates select="v3:component/v3:structuredBody" mode="main-document"/>
					</div>
				</div>
				<!-- put any required polyfills here -->
			</body>
		</html>
	</xsl:template>

	<xsl:template match="v3:document" mode="html-head">
		<head>
			<meta charset="utf-8"/>
			<meta name="viewport" content="width=device-width, initial-scale=1"/>
			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>   
			<meta name="documentId">
				<xsl:attribute name="content"><xsl:value-of select="v3:id/@root"/></xsl:attribute>
			</meta>
			<meta name="documentSetId">
				<xsl:attribute name="content"><xsl:value-of select="v3:setId/@root"/></xsl:attribute>
			</meta>
			<meta name="documentVersionNumber">
				<xsl:attribute name="content"><xsl:value-of select="v3:versionNumber/@value"/></xsl:attribute>
			</meta>
			<meta name="documentEffectiveTime">
				<xsl:attribute name="content"><xsl:value-of select="v3:effectiveTime/@value"/></xsl:attribute>
			</meta>
			<title><xsl:value-of select="v3:title"/></title>
			<link rel="stylesheet" type="text/css" href="{$css}"/>
			<style>
				
				/* pmh - I do not think this is going to work: */
				/*a::after {
				content: ", page " target-counter(attr(href), page );
				}
				.frontmatter a::after { content: leader('.') target-counter(attr(href url), page, lower-roman) }
				.bodymatter a::after { content: leader('.') target-counter(attr(href url), page, decimal) }
				@page { counter-increment: page }
				#pageNumber { content: counter(page) } */
				
			</style>
		</head>
	</xsl:template>	
	
	<!-- This is the main page content, which renders for both screen, with Product Details in front, and print, with Product Details at end -->	
	<xsl:template match="v3:structuredBody" mode="main-document">
		<main class="col">
			<div class="container-fluid" id="main">
				<div class="row position-relative">
					<div class="col">
						<xsl:for-each select="v3:component/v3:section">
							<xsl:variable name="unique-section-id"><xsl:value-of select="@ID"/></xsl:variable>
							<xsl:variable name="tri-code-value" select="substring(v3:code/@code, string-length(v3:code/@code)-2)"/>
							<xsl:choose>
								<xsl:when test="v3:code[@code='MP']">
								</xsl:when>
								<xsl:when test="$tri-code-value = '001'">
									<!-- TITLE PAGE - Note: force-page-break here does not work on FireFox -->
									<section class="card mb-2 force-page-break" id="{$unique-section-id}">
										<div class="spl title-page p-3">
											<xsl:for-each select="v3:component[1]/v3:section">
												<xsl:apply-templates select="v3:title"/>
												<xsl:apply-templates select="v3:text"/>
											</xsl:for-each>
										</div>
										<div class="spl container p-5">
											<div class="row">
												<div class="col-6">
													<xsl:for-each select="v3:component[2]/v3:section">
														<xsl:apply-templates select="v3:title"/>
														<xsl:apply-templates select="v3:text"/>
													</xsl:for-each>
												</div>
												<div class="col-6">
													<!-- TODO - this should probably just render every subsection with position greater than [2] -->
													<xsl:for-each select="v3:component[3]/v3:section">
														<xsl:apply-templates select="v3:title"/>
														<xsl:apply-templates select="v3:text"/>
													</xsl:for-each>
													<xsl:for-each select="v3:component[4]/v3:section">
														<xsl:apply-templates select="v3:title"/>
														<xsl:apply-templates select="v3:text"/>
													</xsl:for-each>
													<xsl:for-each select="v3:component[5]/v3:section">
														<xsl:apply-templates select="v3:title"/>
														<xsl:apply-templates select="v3:text"/>
													</xsl:for-each>
												</div>
											</div>
										</div>
									</section>
									<!-- PRINT ONLY TOC ON A SEPARATE PAGE -->
									<!-- pmh - I do not think this is going to work -->
									<section class="force-page-break" id="print-table-of-contents">
										<div class="spl">
											TEST TEST TEST POC FOR TABLE OF CONTENTS from Hadlima deb4ec67-8764-4b72-b7a5-0bae88db11a3
											<ol>
												<li class="frontmatter"><a href="#a16a94eb-e2be-45c0-8b2e-15d0d0eebea8">Part one</a></li>
												<li class="frontmatter"><a href="#d6a947eb-e2be-45c0-8b2e-15d0d0eebed8">Part two</a></li>
												<li class="bodymatter"><a href="#baa4d498-0fc3-4e44-b4b6-550140d4de5d">Part threebody</a></li>
											</ol>
										</div>
									</section>
								</xsl:when>
								<xsl:when test="$tri-code-value = '007'">
									<!-- RECENT MAJOR LABEL CHANGES -->
									<section class="card mb-2" id="{$unique-section-id}">
										<div class="spl recent-changes">
											<xsl:apply-templates select="."/>
										</div>
									</section>
								</xsl:when>
								<xsl:otherwise>
									<!-- NAVIGATION FOR DIFFERENT PARTS -->								
									<section class="card mb-2" id="{$unique-section-id}">
										<div class="spl">
											<xsl:apply-templates select="."/>
										</div>
									</section>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
						<!-- PRINT VERSION OF MANUFACTURED PRODUCT -->
						<section class="card" id="print-product-details">
							<div class="spl">
								<xsl:apply-templates mode="print" select="v3:author/v3:assignedEntity/v3:representedOrganization"/>
								<xsl:apply-templates mode="print" select="//v3:subject/v3:manufacturedProduct"/>
							</div>
						</section>
					</div>
				</div>				
			</div>
		</main>	
	</xsl:template>
		
</xsl:transform>