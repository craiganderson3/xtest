<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:v3="urn:hl7-org:v3" xmlns:str="http://exslt.org/strings" 
	xmlns:exsl="http://exslt.org/common" xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/" 
	exclude-result-prefixes="exsl msxsl v3 xsl xsi str">
	<xsl:import href="../FDA spl_stylesheet_6_2/spl-common.xsl"/>
	<xsl:import href="spl_canada_nav.xsl"/>
	<xsl:import href="spl_canada_i18n.xsl"/>
	
	<!-- This is the CSS link put into the output -->
	<xsl:param name="css">http://www.accessdata.fda.gov/spl/stylesheet/spl.css</xsl:param>
	<xsl:variable name="lang">
		<xsl:choose>
			<xsl:when test="v3:document/v3:languageCode[@code='1']">en</xsl:when>
			<xsl:when test="v3:document/v3:languageCode[@code='2']">fr</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:output method="html" encoding="iso-8859-1" version="4.0" doctype-public="-//W3C//DTD HTML 4.01//EN" indent="no"/>
    <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>

	<!-- template starts at bottom with /v3:document, which contains HTML head and body -->
	
	<!-- global templates like date formatting -->
	<xsl:template name="string-to-date">
		<xsl:param name="text"/>
		<xsl:param name="displayMonth">true</xsl:param>
		<xsl:param name="displayDay">true</xsl:param>
		<xsl:param name="displayYear">true</xsl:param>
		<xsl:param name="delimiter">-</xsl:param>
		<xsl:if test="string-length($text) > 7">
			<xsl:variable name="year" select="substring($text,1,4)"/>
			<xsl:variable name="month" select="substring($text,5,2)"/>
			<xsl:variable name="day" select="substring($text,7,2)"/>
			<xsl:if test="$displayYear = 'true'">
				<xsl:value-of select="$year"/>
				<xsl:value-of select="$delimiter"/>
			</xsl:if>
			<xsl:if test="$displayMonth = 'true'">
				<xsl:value-of select="$month"/>
				<xsl:value-of select="$delimiter"/>
			</xsl:if>
			<xsl:if test="$displayDay = 'true'">
				<xsl:value-of select="$day"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- templates for the content - if any of these become too generic, promote them up in this stylesheet -->
	<xsl:template match="v3:structuredBody">
		<div id="accordion-section">
			<xsl:for-each select="v3:component/v3:section">
				<xsl:variable name="unique-section-id"><xsl:value-of select="v3:id/@root"/></xsl:variable>
				<xsl:if test="$unique-section-id">
					<div>
						<xsl:attribute name="class">
							<xsl:choose>
								<xsl:when test="v3:code[@code='1']|v3:code[@code='MP']">card m-2 hide-in-print</xsl:when>
								<xsl:otherwise>card m-2</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute> 
						<div class="card-header m-0 p-0" id="heading-{$unique-section-id}">
							<!-- removed bg-primary for now and added some additional styles on the button theme -->
							<button class="btn hc-header text-white text-left w-100" data-toggle="collapse" data-target="#{$unique-section-id}" aria-expanded="true" aria-controls="collapseOne">
								<xsl:choose>
									<xsl:when test="v3:code[@code='1']|v3:code[@code='MP']">
										<xsl:value-of select="translate($labels/productDetails[@lang = $lang], $lower, $upper)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="translate(v3:code/@displayName, $lower, $upper)"/>
									</xsl:otherwise>
								</xsl:choose>
							</button>
						</div>
						<div id="{$unique-section-id}" class="collapse mx-3 pb-3" aria-labelledby="heading-{$unique-section-id}" data-parent="#accordion-section">
							<xsl:choose>
								<xsl:when test="v3:code[@code='1']|v3:code[@code='MP']">
									<xsl:call-template name="HCProductInfo"/>
								</xsl:when>
								<xsl:when test="v3:code[@code='TP']">
									<span class="TitlePage">
										<xsl:apply-templates select="."/>
									</span>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="."/>
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
					<xsl:if test="v3:code[@code='TP']">
						<div class="ForcePageBreak"> </div>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
		</div>
	</xsl:template>
	
	<xsl:template mode="HCSectionHead" match="v3:section">
		<xsl:param name="section-title"><xsl:value-of select="v3:title"/></xsl:param>
		<a>
			<xsl:attribute name="name">
				<xsl:value-of select="v3:id/@root"/>
			</xsl:attribute>
		</a>
		<div class="card-header">
			<xsl:attribute name="title"><xsl:value-of select="v3:id/@root"/></xsl:attribute>
			<xsl:value-of select="$section-title"/>
		</div>
	</xsl:template>
	
	<!-- this is the product info section -->
	<xsl:template name="HCProductInfo">
		<div id="accordion-product">
			<xsl:apply-templates select="/v3:document/v3:author/v3:assignedEntity/v3:representedOrganization" mode="card"/>
			<xsl:apply-templates select="/v3:document/v3:author/v3:assignedEntity/v3:representedOrganization/v3:assignedEntity/v3:assignedOrganization" mode="card"/>
			<xsl:for-each select="v3:subject/v3:manufacturedProduct">
				<xsl:variable name="unique-product-id">
					<xsl:apply-templates select="v3:manufacturedProduct" mode="generateUniqueIdentifier">
						<xsl:with-param name="position"><xsl:value-of select="position()"/></xsl:with-param>
					</xsl:apply-templates>
				</xsl:variable>
				<div class="card mt-3">
					<div class="card-header m-0 p-0 bg-primary" id="heading-{$unique-product-id}">
							<!-- removed bg-primary for now and added some additional styles on the button theme -->
						<button class="btn hc-header text-white text-left w-100" data-toggle="collapse" data-target="#{$unique-product-id}" aria-expanded="true" aria-controls="collapseOne">
							<xsl:apply-templates select="v3:manufacturedProduct" mode="generateUniqueLabel">
								<xsl:with-param name="position"><xsl:value-of select="position()"/></xsl:with-param>
							</xsl:apply-templates>
						</button>
					</div>
					<div id="{$unique-product-id}" class="collapse mx-3" aria-labelledby="heading-{$unique-product-id}" data-parent="#accordion-product">
						<xsl:apply-templates mode="subjects" select="v3:manufacturedProduct"/>
					</div>
				</div>
			</xsl:for-each>
		</div>
	</xsl:template>

	<xsl:template match="//v3:author/v3:assignedEntity/v3:representedOrganization" mode="card">
		<div class="card mt-3">
			<div class="card-header m-0 p-0 bg-primary" id="heading-company-details">
				<button class="btn hc-header text-white text-left w-100" data-toggle="collapse" data-target="#company-details" aria-expanded="true" aria-controls="collapseOne">
					<xsl:value-of select="$labels/companyDetails[@lang = $lang]"/>
				</button>
			</div>
			<div id="company-details" class="collapse mx-3" aria-labelledby="heading-company-details" data-parent="#accordion-product">
				<xsl:apply-templates mode="subjects" select="."/>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template match="//v3:author/v3:assignedEntity/v3:representedOrganization/v3:assignedEntity/v3:assignedOrganization" mode="card">
		<div class="card mt-3">
			<div class="card-header m-0 p-0 bg-primary" id="heading-distributor-details">
				<button class="btn hc-header text-white text-left w-100" data-toggle="collapse" data-target="#distributor-details" aria-expanded="true" aria-controls="collapseOne">
					<xsl:value-of select="$labels/distribDetails[@lang = $lang]"/>
				</button>
			</div>
			<div id="distributor-details" class="collapse mx-3" aria-labelledby="heading-distributor-details" data-parent="#accordion-product">
				<xsl:apply-templates mode="subjects" select="."/>
			</div>
		</div>
	</xsl:template>

	<!-- collapsed spacing is important here in order to use this as an identifier, and the translate at the end replaces spaces with '-' and removes '#' -->
	<xsl:template mode="generateUniqueIdentifier" match="v3:manufacturedProduct">
		<xsl:param name="position"/>
		<xsl:variable name="uniqueId">Prod<xsl:value-of select="$position"/>-<xsl:value-of select="v3:name"/>
			<xsl:for-each select="v3:ingredient[starts-with(@classCode,'ACTI')]">-<xsl:value-of select="//v3:activeMoiety/v3:code/@displayName"/>-<xsl:value-of select="v3:quantity/v3:numerator/@value"/>
				<xsl:value-of select="v3:quantity/v3:numerator/@unit"/>
			</xsl:for-each>-<xsl:value-of select="v3:formCode[@codeSystem='2.16.840.1.113883.2.20.6.3']/@displayName"/>
		</xsl:variable>
		<xsl:value-of select="translate($uniqueId,' #', '-')"/>
	</xsl:template>

	<xsl:template mode="generateUniqueLabel" match="v3:manufacturedProduct">
		<xsl:param name="position"/>
		Product #<xsl:value-of select="$position"/><xsl:text> </xsl:text><xsl:value-of select="v3:name"/> 
		(<xsl:value-of select="v3:asEntityWithGeneric/v3:genericMedicine/v3:name"/>), 		
		<xsl:for-each select="v3:ingredient[starts-with(@classCode,'ACTI')]">
			<xsl:if test="position() > 1">/ </xsl:if>
			<xsl:value-of select="//v3:activeMoiety/v3:code/@displayName"/>&#160;
			<xsl:value-of select="v3:quantity/v3:numerator/@value"/>&#160;
			<xsl:value-of select="v3:quantity/v3:numerator/@unit"/>&#160;
		</xsl:for-each>
		<xsl:value-of select="v3:formCode[@codeSystem='2.16.840.1.113883.2.20.6.3']/@displayName"/>
	</xsl:template>

	<!-- override FDA Product Info section -->
	<xsl:template name="ProductInfoBasic">
		<tr>
			<td>
				<table width="100%" cellpadding="3" cellspacing="0" class="contentTablePetite">
					<tr>
						<td colspan="2" class="formHeadingTitle">
							<xsl:value-of select="$labels/productInfo[@lang = $lang]"/>
						</td>
					</tr>
					<tr class="formTableRowAlt">
						<td class="formLabel">
							<xsl:value-of select="$labels/brandName[@lang = $lang]"/>
						</td>
						<td class="formItem">
							<xsl:value-of select="v3:name"/>
						</td>
					</tr>
					<tr class="formTableRow">
						<td class="formLabel">	
							<xsl:value-of select="$labels/nonPropName[@lang = $lang]"/>
						</td>
						<td class="formItem">
							<xsl:value-of select="v3:asEntityWithGeneric/v3:genericMedicine/v3:name"/>
						</td>
					</tr>
					<tr class="formTableRowAlt">
						<td class="formLabel">	
							<xsl:value-of select="$labels/din[@lang = $lang]"/>
						</td>
						<td class="formItem">
							<xsl:value-of select="v3:code/@code"/>
						</td>
					</tr>
					<tr class="formTableRow">
						<td class="formLabel">
							<xsl:value-of select="$labels/adminRoute[@lang = $lang]"/>
						</td>
						<td class="formItem">
							<xsl:value-of select="../v3:consumedIn/v3:substanceAdministration/v3:routeCode/@displayName"/>
						</td>
					</tr>
					<tr class="formTableRowAlt">
						<td class="formLabel">
							<xsl:value-of select="$labels/dosageForm[@lang = $lang]"/>
						</td>
						<td class="formItem">
							<xsl:value-of select="v3:formCode/@displayName"/>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</xsl:template>
	
	<!-- Overide FDA Ingredients -->
	<!-- display the ingredient information (both active and inactive) -->
	<xsl:template name="ActiveIngredients">
		<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
			<tr>
				<td colspan="3" class="formHeadingTitle">	
					<xsl:value-of select="$labels/activeIngredients[@lang = $lang]"/>
				</td>
			</tr>
			<tr>
				<th class="formTitle" scope="col">
					<xsl:value-of select="$labels/ingredientName[@lang = $lang]"/>
				</th>
				<th class="formTitle" scope="col">
					<xsl:value-of select="$labels/basisOfStrength[@lang = $lang]"/>
				</th>
				<th class="formTitle" scope="col">
					<xsl:value-of select="$labels/strength[@lang = $lang]"/>
				</th>
			</tr>
			<xsl:if test="not(v3:ingredient[starts-with(@classCode, 'ACTI')]|v3:activeIngredient)">
				<tr>
					<td colspan="3" class="formItem" align="center">
						<xsl:value-of select="$labels/noActiveFound[@lang = $lang]"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:for-each select="v3:ingredient[starts-with(@classCode, 'ACTI')]|v3:activeIngredient">
				<tr>
					<xsl:attribute name="class">
						<xsl:choose>
							<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
							<xsl:otherwise>formTableRowAlt</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:for-each select="(v3:ingredientSubstance|v3:activeIngredientSubstance)[1]">
						<td class="formItem">
							<strong>
								<xsl:value-of select="v3:name"/>
							</strong>
							<xsl:text> (</xsl:text>
							<xsl:for-each select="v3:code/@code">
<!--							<xsl:text>UNII: </xsl:text> -->
								<xsl:value-of select="."/>
								<xsl:if test="position()!=last()"> and </xsl:if>
							</xsl:for-each>
							<xsl:text>) </xsl:text>
							<xsl:if test="normalize-space(v3:activeMoiety/v3:activeMoiety/v3:name)">
								<xsl:text> (</xsl:text>
								<xsl:for-each select="v3:activeMoiety/v3:activeMoiety/v3:name">
									<xsl:value-of select="."/>
									<xsl:text> - </xsl:text>
<!--								<xsl:text>UNII:</xsl:text> -->
									<xsl:value-of select="../v3:code/@code"/>
									<xsl:if test="position()!=last()">, </xsl:if>
								</xsl:for-each>
								<xsl:text>) </xsl:text>
							</xsl:if>
							<xsl:for-each select="../v3:subjectOf/v3:substanceSpecification/v3:code[@codeSystem = '2.16.840.1.113883.6.69' or @codeSystem = '2.16.840.1.113883.3.6277']/@code">
								<xsl:text> (Source NDC: </xsl:text>
								<xsl:value-of select="."/>
								<xsl:text>)</xsl:text>
							</xsl:for-each>
						</td>
						<td class="formItem">
							<xsl:choose>
								<xsl:when test="../@classCode='ACTIR'">
									<xsl:value-of select="v3:asEquivalentSubstance/v3:definingSubstance/v3:name"/>
								</xsl:when>
								<xsl:when test="../@classCode='ACTIB'">
									<xsl:value-of select="v3:name"/>
								</xsl:when>
								<xsl:when test="../@classCode='ACTIM'">
									<xsl:value-of select="v3:activeMoiety/v3:activeMoiety/v3:name"/>
								</xsl:when>
							</xsl:choose>
						</td>
					</xsl:for-each>
					<td class="formItem">
						<xsl:value-of select="v3:quantity/v3:numerator/@value"/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:numerator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:numerator/@unit"/></xsl:if>
						<xsl:if test="(v3:quantity/v3:denominator/@value and normalize-space(v3:quantity/v3:denominator/@value)!='1') 
													or (v3:quantity/v3:denominator/@unit and normalize-space(v3:quantity/v3:denominator/@unit)!='1')"> &#160;in&#160;<xsl:value-of select="v3:quantity/v3:denominator/@value"
													/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:denominator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:denominator/@unit"/>
							</xsl:if></xsl:if>
					</td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>

	<xsl:template name="InactiveIngredients">
		<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
			<tr>
				<td colspan="2" class="formHeadingTitle">
					<xsl:value-of select="$labels/inactiveIngredients[@lang = $lang]"/>
				</td>
			</tr>
			<tr>
				<th class="formTitle" scope="col">
					<xsl:value-of select="$labels/ingredientName[@lang = $lang]"/>
				</th>
				<th class="formTitle" scope="col">
					<xsl:value-of select="$labels/strength[@lang = $lang]"/>
				</th>
			</tr>
			<xsl:if test="not(v3:ingredient[@classCode='IACT']|v3:inactiveIngredient)">
				<tr>
					<td colspan="2" class="formItem" align="center">
						<xsl:value-of select="$labels/noInactiveFound[@lang = $lang]"/>					
					</td>
				</tr>
			</xsl:if>			
			<xsl:for-each select="v3:ingredient[@classCode='IACT']|v3:inactiveIngredient">
				<tr>
					<xsl:attribute name="class">
						<xsl:choose>
							<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
							<xsl:otherwise>formTableRowAlt</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:for-each select="(v3:ingredientSubstance|v3:inactiveIngredientSubstance)[1]">
						<td class="formItem">
							<strong>
								<xsl:for-each select="v3:code">
									<xsl:value-of select="@displayName"/>
								</xsl:for-each>
							</strong>
						</td>
					</xsl:for-each>
					<td class="formItem">
						<xsl:value-of select="v3:quantity/v3:numerator/@value"/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:numerator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:numerator/@unit"/></xsl:if>
						<xsl:if test="v3:quantity/v3:denominator/@value and normalize-space(v3:quantity/v3:denominator/@unit)!='1'"> &#160;in&#160;<xsl:value-of select="v3:quantity/v3:denominator/@value"
						/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:denominator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:denominator/@unit"/>
							</xsl:if></xsl:if>
					</td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>

	<!-- Product Characteristics now use simplified templating -->
	<xsl:template name="characteristics-new">
		<xsl:call-template name="characteristics-old"/>
	</xsl:template>

	<xsl:template match="v3:characteristic">
		<xsl:param name="class">formTableRow</xsl:param>
		<xsl:param name="label"><xsl:value-of select="v3:code/@displayName"/></xsl:param>
		<tr class="{$class}">
			<td class="formLabel">
				<xsl:value-of select="$label"/>
			</td>
			<td class="formItem">
				<!-- TODO this is less than ideal -->
				<xsl:value-of select="v3:value[@xsi:type='ST']/text()"/>
				<xsl:value-of select="v3:value/@displayName"/>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template name="listedCharacteristicRow">
		<xsl:param name="path" select="."/>
		<xsl:param name="class">formTableRow</xsl:param>
		<xsl:param name="label"><xsl:value-of select="$path/v3:code/@displayName"/></xsl:param>
		<tr class="{$class}">
			<td class="formLabel">
				<xsl:value-of select="$label"/>
			</td>
			<td class="formItem">			
				<xsl:for-each select="$path/v3:value">
					<xsl:if test="position() > 1">,&#160;</xsl:if>
					<xsl:value-of select="./@displayName"/>
					<xsl:if test="normalize-space(./v3:originalText)"> (<xsl:value-of select="./v3:originalText"/>)</xsl:if>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>

	<!-- TODO all of these characteristic labels need to be passed in as language based -->
	<xsl:template name="characteristics-old">
		<table class="contentTablePetite" cellSpacing="0" cellPadding="3" width="100%">
			<tbody>
				<tr>
					<td class="formHeadingTitle" colspan="2">
						<xsl:value-of select="$labels/productCharacteristics[@lang = $lang]"/>
					</td>
				</tr>
				<xsl:apply-templates select="../v3:subjectOf/v3:characteristic[v3:code/@code='1']">
					<xsl:with-param name="label" select="$labels/productType[@lang = $lang]"/>
				</xsl:apply-templates>
				<xsl:call-template name="listedCharacteristicRow">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='2']"/>
					<xsl:with-param name="label" select="$labels/color[@lang = $lang]"/>
					<xsl:with-param name="class">formTableRowAlt</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="listedCharacteristicRow">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='3']"/>
					<xsl:with-param name="label" select="$labels/shape[@lang = $lang]"/>
				</xsl:call-template>
				<!-- this is the existing FDA templating -->
				<tr class="formTableRowAlt">
					<xsl:call-template name="size">
						<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='4']"/>
					</xsl:call-template>
				</tr>
				<xsl:apply-templates select="../v3:subjectOf/v3:characteristic[v3:code/@code='5']">
					<xsl:with-param name="label" select="$labels/score[@lang = $lang]"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="../v3:subjectOf/v3:characteristic[v3:code/@code='6']">
					<xsl:with-param name="label" select="$labels/imprint[@lang = $lang]"/>
					<xsl:with-param name="class">formTableRowAlt</xsl:with-param>
				</xsl:apply-templates>
				<xsl:call-template name="listedCharacteristicRow">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='7']"/>
					<xsl:with-param name="label" select="$labels/flavor[@lang = $lang]"/>
				</xsl:call-template>
				<xsl:apply-templates select="../v3:subjectOf/v3:characteristic[v3:code/@code='8']">
					<xsl:with-param name="label" select="$labels/combinationProduct[@lang = $lang]"/>
					<xsl:with-param name="class">formTableRowAlt</xsl:with-param>
				</xsl:apply-templates>
				<xsl:apply-templates select="../v3:subjectOf/v3:characteristic[v3:code/@code='9']">
					<xsl:with-param name="label" select="$labels/pharmaStandard[@lang = $lang]"/>
				</xsl:apply-templates>
				<xsl:call-template name="listedCharacteristicRow"> <!-- Schedule -->
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='10']"/>
					<xsl:with-param name="class">formTableRowAlt</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="listedCharacteristicRow"> <!-- Therapeutic Class -->
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='11']"/>
				</xsl:call-template>
			</tbody>
		</table>
	</xsl:template>

	<!-- override packageInfo template to consolidate rows that have the same package number - some templating still specific to FDA business rules -->
	<xsl:template name="packageInfo">
		<xsl:param name="path"/>
		<xsl:param name="number" select="1"/>
		<tr>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$number mod 2 = 0">formTableRow</xsl:when>
					<xsl:otherwise>formTableRowAlt</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<th scope="row" class="formItem">
				<xsl:value-of select="$number"/>
			</th>
				<td class="formItem">						
					<xsl:for-each select="$path/ancestor-or-self::v3:asContent/*[self::v3:containerPackagedProduct or self::v3:containerPackagedMedicine]">
						<xsl:sort select="position()" order="descending"/>
						<xsl:variable name="current" select="."/>
						<xsl:for-each select="v3:code[1]/@code">
							<xsl:if test="not(/v3:document/v3:code/@code = '58474-8')">
								<xsl:for-each select="$itemCodeSystems/label[@codeSystem = current()/../@codeSystem][approval/@code = current()/ancestor::*[self::v3:manufacturedProduct or self::v3:manufacturedMedicine or self::v3:partProduct or self::v3:partMedicine][1]/../v3:subjectOf/v3:approval/v3:code/@code or @drug = count(current()/ancestor::*[self::v3:manufacturedProduct or self::v3:manufacturedMedicine or self::v3:partProduct or self::v3:partMedicine][1]/v3:asEntityWithGeneric)][1]/@name">
									<xsl:value-of select="."/>
									<xsl:text>:</xsl:text>
								</xsl:for-each>
							</xsl:if>	
							<xsl:value-of select="."/>
						</xsl:for-each>
						<br/>
					</xsl:for-each>
				</td>
				<td class="formItem">
					<xsl:for-each select="$path/ancestor-or-self::v3:asContent/*[self::v3:containerPackagedProduct or self::v3:containerPackagedMedicine]">
						<xsl:sort select="position()" order="descending"/>
						<xsl:variable name="current" select="."/>
						<xsl:for-each select="../v3:quantity">
							<xsl:for-each select="v3:numerator">
								<xsl:value-of select="@value"/>
								<xsl:text> </xsl:text>
								<xsl:if test="@unit[. != '1']">
									<xsl:value-of select="@unit"/>
								</xsl:if>
							</xsl:for-each>
							<xsl:text> in </xsl:text>
							<xsl:for-each select="v3:denominator">
								<xsl:value-of select="@value"/>
								<xsl:text> </xsl:text>
							</xsl:for-each>
						</xsl:for-each>
						<xsl:value-of select="v3:formCode/@displayName"/>
						<xsl:for-each select="../v3:subjectOf/v3:characteristic">
							<xsl:if test="../../v3:quantity or ../../v3:containerPackagedProduct[v3:formCode[@displayName]] or ../preceding::v3:subjectOf"></xsl:if>
							<xsl:variable name="def" select="$CHARACTERISTICS/*/*/v3:characteristic[v3:code[@code = current()/v3:code/@code and @codeSystem = current()/v3:code/@codeSystem]][1]"/>
							<xsl:variable name="name" select="($def/v3:code/@displayName|$def/v3:code/@p:displayName)[1]" xmlns:p="http://pragmaticdata.com/xforms" />
							<xsl:variable name="cname" select="$CHARACTERISTICS/*/*/v3:characteristic[v3:code[@code = current()/v3:code/@code]]/v3:value[@code = current()/v3:value/@code]/@displayName"/>
							<xsl:choose>
								<xsl:when test="$cname">
									<xsl:text>; </xsl:text>
									<xsl:value-of select="$cname" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>; </xsl:text>
									<xsl:value-of select="$name"/>
									<xsl:text> = </xsl:text>
									<xsl:value-of select="(v3:value[not(../v3:code/@code = 'SPLCMBPRDTP')]/@code|v3:value/@value)[1]"/>
								</xsl:otherwise>
							</xsl:choose>						
						</xsl:for-each>
						<br/>
					</xsl:for-each>
				</td>
				<td class="formItem">						
					<xsl:call-template name="string-to-date">
						<xsl:with-param name="text">
							<xsl:value-of select="../../v3:subjectOf/v3:marketingAct/v3:effectiveTime/v3:low/@value"/>
						</xsl:with-param>
					</xsl:call-template>
				</td>
				<td class="formItem">					
					<xsl:call-template name="string-to-date">
						<xsl:with-param name="text">
							<xsl:value-of select="../../v3:subjectOf/v3:marketingAct/v3:effectiveTime/v3:high/@value"/>
						</xsl:with-param>
					</xsl:call-template>
				</td>
			</tr>
	</xsl:template>

	<xsl:template name="partQuantity">
		<xsl:param name="path" select="."/>
		<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
			<tr>
				<td colspan="5" class="formHeadingTitle">Quantity of Parts</td>
			</tr>
			<tr>
				<th scope="col" width="5" class="formTitle">Part&#160;#</th>
				<th scope="col" class="formTitle">Package Quantity</th>
				<th scope="col" class="formTitle">Total Product Quantity</th>
			</tr>
			<xsl:for-each select="$path/v3:part">
				<tr>
					<xsl:attribute name="class">
						<xsl:choose>
							<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
							<xsl:otherwise>formTableRowAlt</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<td width="5" class="formItem">
						<strong>Part <xsl:value-of select="position()"/></strong>
					</td>
					<td class="formItem">
						<!-- TODO cleanup - are there ever going to be multiple quanities? what is the cardinality here? -->
						<xsl:for-each select="v3:quantity/v3:denominator">
							<xsl:value-of select="@value"/>
							<xsl:text> </xsl:text>
						</xsl:for-each>
						<xsl:value-of select="*[self::v3:partProduct or self::partMedicine]/v3:asContent/*[self::v3:containerPackagedProduct or self::v3:containerPackagedMedicine]/v3:formCode/@displayName"/>
						<xsl:text> </xsl:text>
					</td>							
					<td class="formItem">
						<xsl:value-of select="v3:quantity/v3:numerator/@value"/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:numerator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:numerator/@unit"/></xsl:if>
						<xsl:if test="(v3:quantity/v3:denominator/@value and normalize-space(v3:quantity/v3:denominator/@value)!='1') 
														or (v3:quantity/v3:denominator/@unit and normalize-space(v3:quantity/v3:denominator/@unit)!='1')"> &#160;in&#160;<xsl:value-of select="v3:quantity/v3:denominator/@value"
														/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:denominator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:denominator/@unit"/>
							</xsl:if></xsl:if>
					</td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>

	<!-- templates for the sidebar - if any of these become too generic, promote them up in this stylesheet -->

	<!-- GO HERE -->

	<!-- templates for the main document, including sidebar and content -->
		
	<xsl:template match="/" priority="1">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>   
				<meta name="documentId">
					<xsl:attribute name="content"><xsl:value-of select="v3:document/v3:id/@root"/></xsl:attribute>
				</meta>
				<meta name="documentSetId">
					<xsl:attribute name="content"><xsl:value-of select="v3:document/v3:setId/@root"/></xsl:attribute>
				</meta>
				<meta name="documentVersionNumber">
					<xsl:attribute name="content"><xsl:value-of select="v3:document/v3:versionNumber/@value"/></xsl:attribute>
				</meta>
				<meta name="documentEffectiveTime">
					<xsl:attribute name="content"><xsl:value-of select="v3:document/v3:effectiveTime/@value"/></xsl:attribute>
				</meta>
				<title><xsl:value-of select="v3:document/v3:title"/></title>
				<xsl:call-template name="HCHeadStyles"/>
			</head>
			<body class="spl" id="spl">
				<xsl:for-each select="v3:document/v3:component/v3:structuredBody">
					<xsl:for-each select="v3:component/v3:section">
						<xsl:choose>
<!--							<xsl:when test="v3:code[@code='1']|v3:code[@code='MP']">
								<section class="hide-in-print">
									<xsl:apply-templates mode="subjects" select="//v3:subject/v3:manufacturedProduct"/>
								</section>
							</xsl:when> -->
							<xsl:when test="v3:code[@code='TP']">
								<section class="TitlePage ForcePageBreak">
									<xsl:apply-templates select="."/>
								</section>
<!--								<div class="TitlePage ForcePageBreak">
									<xsl:call-template name="renderTableOfContents"/>
								</div> -->
							</xsl:when>
							<xsl:otherwise>
								<section>
									<xsl:apply-templates select="."/>
								</section>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:for-each>
				<section class="hide-in-screen">
					<xsl:apply-templates mode="subjects" select="//v3:subject/v3:manufacturedProduct"/>
				</section>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="renderTableOfContents">
		<!-- Generate the Table of Contents only if the SPL is PLR. -->
		<xsl:variable name="indexRtf">
			<xsl:apply-templates mode="index" select="/v3:document"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="function-available('exsl:node-set')">
				<xsl:apply-templates mode="twocolumn" select="exsl:node-set($indexRtf)">
					<xsl:with-param name="class">Index</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="function-available('msxsl:node-set')">
				<xsl:apply-templates mode="twocolumn" select="msxsl:node-set($indexRtf)">
					<xsl:with-param name="class">Index</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">required function node-set is not available, this XSLT processor cannot handle the transform</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:transform>