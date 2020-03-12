1. Contents of the product-monograph folder.

Samples and stylesheets in relationship to each other:
 - samples
 - schema
 - style-sheet/spl_canada.xsl
 - style-sheet/spl_canada_screen.xsl
 - style-sheet/spl_canada_i18n.xsl
 - style-sheet/spl_common.xsl
 - style-sheet/spl_canada.css
 
The spl_canada.xsl stylesheet references its siblings, spl_canada_screen.xsl, spl_common.xsl, 
and spl_canada_i18n.xsl. The spl_canada.xsl stylesheet contains the root template and a number of 
supporting templates. The spl_common.xsl stylesheet contains a number of templates that were inherited 
from FDA, and the other two stylesheets provide templates for onscreen navigation and bilingual language 
support. The spl_canada.css contains a number of styles that were inherited from FDA, and a number of
styles that extend Bootstrap to meet the requirements of the Aurora Design Guide.

2. This should be the only processing instruction referenced in the SPM XML:

<?xml-stylesheet type="text/xsl" href="http://cease353.github.io/xtest/current/spl_canada.xsl"?>

Once you change the stylesheet processing instruction in one of the SPM XML files, 
you should be able to transform it into HTML using Oxygen or a similar XML tool, and then render it 
using your local browser.

3. JavaScript Technology Stack

 - Bootstrap 4.4.1 (includes ScrollSpy)
 - JQuery 3.4.1
 - Popper 1.16.0
 - StickyFill 2.0.5

Stickyfill is a polyfill which has been used specifically to support IE scrolling.

4. Aurora and FDA Stylesheets

We are currently using the FDA styles for styles within the drug monograph itself, and the Bootstrap
Bundle contained styles. These are similar to the styles referenced in the Aurora Design Guide, although
we are not using the actual Aurora javascript and css. The Bootstrap 4 Bundle contains the Popper library,
and we are also using the JQuery Slim version and StickyFill polyfill library.

Bootstrap 4 provides exceptional modern browser support, and aligns closely with Aurora. Alternatively,
we could use Bootstrap 3, which provides broader support for older browsers. Their are advantages to
both approaches. We are currently testing with the latest versions of Internet Explorer, Edge and Firefox.
Future plans involve creating Health Canada specific css which will replace the FDA css, and can then
be used in conjunction with the Bootstrap css and javascript. The FDA javascript is no longer needed.

5. Web Navigation and Responsive Design

Sidebar navigation is hidden for small screen sizes and can be used on larger screens. Sidebar
navigation and the accordion collapsing is essentially the same thing: clicking a menu item and
the corresponding accordion header have the same effect. In both cases, the behaviour is to show
or hide a section of content.

Bootstrap Scrollspy is a library which synchronizes scrolling and navigation. The navigation menu 
currently does not extend below the second level of sections.

In the current implementation, the width of the sidebar navigation has been fixed to 400px to
resolve an issue I discovered with accordion resizing. Realistically, it makes sense to fix the
sidebar navigation size to always fit the longest expected top level heading.

6. Internationalization, Labels and Local Date Formats

Internationalization and local date formatting maintained in the spl_canada_i18n.xsl transform file.
Where it is possible, Display Names should be used. Where static labels are required, these need to
be internationalized. These are necessary for any fields that are Required but not Mandatory.

7. Decisions Required

 - There are advantages to using Bootstrap 3 vs. Bootstrap 4. Both are viable options and we are 
   currently using BS4. They provide different kinds of compatibility with modern and older browsers.
   
 - In addition to templates that have been overridden by SPL Canada, the following areas have been removed:
   Mixins, Pesticides, Substances, PLR Sections, Indication Sections, Document Types, Other Ingredients,
   Observation Criterion and Analytes, REMS templates, Highlights and Disclaimers, Indexes, Document Model, 
   Cross Reference Model, Complicated Section Numbering and Effective Date templates, Pharmacological Class,
   LDD/BULK/FILL/LABEL, Display Limitations and Conditions of Use, Interactions and Adverse Reactions
       
 - We are currently working with CSS3 Paged Media to support a print view, as opposed to using XSL:FO
   to generate a separate PDF document. Both are viable options, but Paged Media is a simplified approach.

8. Known Issues

 - Print TOC does not exist.
 - There is a minor problem with responsive resizing at some screen resolutions which causes content to render under the navigation sidebar.
 
 There are limitations with client-side rendering on each of the major browsers, which is why we recommend 
 using Oxygen or a similar tool. If we host our XSL on Github Pages, there is a limitation for Chrome, 
 because Chrome serves XSL as application/xml,rather than text/xml, as described at the bottom of this thread:
 https://stackoverflow.com/questions/2981524/how-can-i-make-xslt-work-in-chrome
 
 Using WeasyPrint Service from Docker Container from BC Gov:
 curl -v -X POST -d @test.htm -JLO http://127.0.0.1:5002/pdf?filename=result.pdf
 