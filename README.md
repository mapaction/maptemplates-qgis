# maptemplates-qgis
A set of scripts to generate QGIS templates which replicate ArcGIS templates

**Summary**

MapAction's master templates are stored in Arc, and a reference document maintained containing settings (position, dimensions) for all elements.

QGIS templates are maintained using a script which runs against a master template and this document to create a template set to match the Arc originals.

**Resources**
1. Output set (jpg of PDF) of original Arc templates
2. Reference spreadsheet with schedule of elements and postion/dimension values per spreadsheet
3. XML version of spreadsheet converted from CSV using http://convertcsv.com/csv-to-xml.htm to create XML lookup file
4. Master QGIS template containing a complete set of all required elements across all templates, with ID values corresponding to those in the spreadsheet
5. Script (XSLT) to generate output
6. Empty QGIS project to hold all Layouts

**Processing**
1. Create a new Print Layout using the current master template, and ensure it contains all required elements for all templates
2. If changed nees to be made, create a new master template
3. Ensure the reference spreadsheet is fully completed, and save as CSV
4. Convert to 'vanilla' XML using http://convertcsv.com/csv-to-xml.htm - the root element should be <root>, with a <row> for each row, and child elements corresponding to column headings
5. Process the XML source files (the converted CSV and the master template) using the XSLT  script - you will need an XSLT 2.0 processor for this, for example Saxon
6. The result will be a set of template files, one for each template specified in the spreadsheet
7. Open each template in a new QGIS project and check for errors - at the moment the main map needs to be slightly resized
8. If you make any changes, save the updated layout as new template, overwriting the previous one
  
At the end of the process you should have a set of templates and a project with all templates represented as print layouts
