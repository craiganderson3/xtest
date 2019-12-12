<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:v3="urn:hl7-org:v3" xmlns:str="http://exslt.org/strings" 
	xmlns:exsl="http://exslt.org/common" xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/" 
	exclude-result-prefixes="exsl msxsl v3 xsl xsi str">

	<xsl:template name="HCHeadStyles">
		<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous"/>
		<link rel="stylesheet" type="text/css" href="{$css}"/>
		<style>
		/* ADDED FOR DS*/
		h1, .h1 {
		  font-family: 'Rubik', sans-serif;
		  font-weight: 200; }

		h2, .h2, h4, .h4 {
		  font-family: 'Rubik', sans-serif;
		  font-weight: 400; }

		h3, .h3 {
		  font-family: 'Rubik', sans-serif;
		  font-weight: 500; }

		h6, .h6 {
		  font-weight: 700; }

		.highlight {
		  color: #467B8D;
		  font-weight: bold; }

		.card-title {
		  font-weight: 700; }

		.btn {
		  font-weight: 600 !important;
		  font-family: 'Nunito Sans', sans-serif; }

		.ext-links div {
		  display: inline; }

		a.ext-link-text {
		  color: black;
		  display: inline-block;
		  padding-left: 10px;
		  font-size: 20px;
		  vertical-align: middle; }

		.aurora-skip {
		  left: 45%;
		  background-color: #002D42;
		  padding: 5px;
		  color: white; }

		a {
		  color: #0278A4; }		
		
		/*!
		 * Fix word wrap for buttons and centering for Title Page
		 */		
		.btn { white-space: normal !important; word-wrap: break-word; }
		
		.TitlePage p  { text-align: center !important; }
		.TitlePage h1 { text-align: center !important; }
		.TitlePage h2 { text-align: center !important; }
		.TitlePage h3 { text-align: center !important; }
		
		.hc-header { background-color: #335075; }

		/*!
		 * Very simplistic CSS Paged Media for Print expands all accordion items and forces a page break after the Title Page
		 */				
		@media print {
		
/*			html, body {
				border: 1px solid white !important;
				height: 99% !important;
				page-break-after: avoid !important;
				page-break-before: avoid !important;
			} */
		
			.collapse { display: block !important; height: auto !important; }
			.hide-in-print { display: none; }			
/*			#accordion-section { display: table; page-break-after: always; }
			.reorder-in-print { display: table-footer-group; }
			.keep-order-in-print { display: table-header-group; } */
			.ForcePageBreak { page-break-after: always; }
			.SuppressPageBreak { page-break-after: avoid; }
			.card { border-width: 0; }
			.card-header { display: none; }
		}
		
		@media screen {
			.hide-in-screen { display: none; }
		}

		/* removed some older simple sidebar stuff */
		nav a:active, a:focus, a:hover { color: #335075; }
		nav a:hover { border-bottom: 1px solid; }
			
		</style>
		<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
		<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
	</xsl:template>
	
	<!-- templates for the sidebar - if any of these become too generic, promote them up in this stylesheet -->
	
	<xsl:template match="v3:structuredBody" mode="navigation">
		<ul class="list-unstyled components">
			<xsl:for-each select="v3:component/v3:section">
				<xsl:choose>
					<xsl:when test="v3:code[@code='MP'] | v3:code[@code='1']">
						<xsl:variable name="unique-section-id"><xsl:value-of select="v3:id/@root"/></xsl:variable>
						<li>
							<a href="#{$unique-section-id}" data-toggle="collapse" aria-expanded="false" class="dropdown-toggle">
								PRODUCT DETAILS
							</a>
							<ul class="collapse list-unstyled small" id="{$unique-section-id}">
								<li>
									<a href="#company-details" data-toggle="collapse">Company Details</a>
								</li>
								<xsl:for-each select="v3:subject/v3:manufacturedProduct">
									<xsl:variable name="unique-product-id">
										<xsl:apply-templates select="v3:manufacturedProduct" mode="generateUniqueIdentifier">
											<xsl:with-param name="position"><xsl:value-of select="position()"/></xsl:with-param>
										</xsl:apply-templates>									
									</xsl:variable>
									<xsl:variable name="unique-product-label">
										<xsl:apply-templates select="v3:manufacturedProduct" mode="generateUniqueLabel">
											<xsl:with-param name="position"><xsl:value-of select="position()"/></xsl:with-param>
										</xsl:apply-templates>									
									</xsl:variable>
									<li>
										<a href="#{$unique-product-id}" data-toggle="collapse">
											<xsl:value-of select="$unique-product-label"/>
										</a>
									</li>
								</xsl:for-each>
							</ul>
						</li>
					</xsl:when>
					<xsl:when test="v3:code[@code='TP'] | v3:code[@code='2']">		
						<xsl:variable name="unique-section-id"><xsl:value-of select="v3:id/@root"/></xsl:variable>
						<li>
							<a href="#{$unique-section-id}" data-toggle="collapse">
								<xsl:value-of select="translate(v3:code/@displayName, $lower, $upper)"/>
							</a>
						</li>					
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="unique-section-id"><xsl:value-of select="v3:id/@root"/></xsl:variable>
						<li>
							<a href="#{$unique-section-id}" data-toggle="collapse">
								<xsl:value-of select="translate(v3:code/@displayName, $lower, $upper)"/>
							</a>
						</li>					
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</ul>	
	</xsl:template>

</xsl:transform>