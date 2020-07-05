# maptemplates-qgis
A set of scripts to generate QGIS templates which replicate ArcGIS templates

**Summary**

MapAction's master templates are stored in Arc, and a reference CSV document generated containing settings (position, dimensions) for all elements.

QGIS templates are generated using an XSLT script which runs against a master template and the settings document to create a template set to match the Arc originals.

**Resources**
1. Reference CSV with schedule of elements and position/dimension values per element
2. Master QGIS template containing a complete set of all required elements across all templates, with ID values corresponding to those in the CSV
3. XSLT to generate output

**Processing**
1. Make any required changes to the master QGIS template -e.g. new elements or changed names
2. Process the source files (the CSV and the master template) using the XSLT - you will need an XSLT 2.0 processor for this, for example Saxon
3. The result will be a set of template files, one for each template specified in the spreadsheet
4. Open each template in QGIS and check for and fix any errors
