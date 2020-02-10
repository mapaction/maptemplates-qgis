# maptemplates-qgis
A set of scripts to generate QGIS templates which replicate ArcGIS templates

**Summary**

MapAction's master templates are stored in Arc, and a reference document generated containing settings (position, dimensions) for all elements.

QGIS templates are maintained using an XSLT script which runs against a master template and the settings document to create a template set to match layout the Arc originals.

**Resources**
1. Reference CSV with schedule of elements and position/dimension values per element
2. XML version of CSV converted using http://convertcsv.com/csv-to-xml.htm to create XML lookup file
3. Master QGIS template containing a complete set of all required elements across all templates, with ID values corresponding to those in the CSV
4. XSLT to generate output
5. QGIS project to hold all Layouts

**Processing**
1. Make any required changes to the master QGIS template -e.g. new elements or changed names
2. Remove any empty rows in the CSV and convert to 'vanilla' XML using http://convertcsv.com/csv-to-xml.htm - the root element should be <root>, with a <row> for each row, and child elements corresponding to column headings
3. Process the XML source files (the converted CSV and the master template) using the XSLT - you will need an XSLT 2.0 processor for this, for example Saxon
4. The result will be a set of template files, one for each template specified in the spreadsheet
5. Open each template in QGIS and check for errors - at the moment the main map needs to be slightly resized
6. Save the updated layout as a new template, overwriting the previous one
  
At the end of the process you should have a set of templates and a project with all templates represented as print layouts
