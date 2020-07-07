# maptemplates-qgis
A set of scripts to generate QGIS templates which replicate ArcGIS templates

**Summary**

MapAction's master templates are stored in Arc, and a reference document generated from them containing settings (position, dimensions) for all elements.

QGIS templates are maintained using an XSLT script which runs against a master template and the settings document to create a template set to match layout the Arc originals.

**Resources**
1. Reference CSV with schedule of elements and position/dimension values per element
2. Master QGIS template containing a complete set of all required elements across all templates, with ID values corresponding to those in the CSV
3. Copy of https://github.com/mapaction/mapaction-toolbox/blob/master/arcgis10_mapping_tools/MapAction/MapAction/Resources/language_config.xml to hold text translations for templates
4. XSLT to generate output


**Processing**
1. Make any required changes to the master QGIS template -e.g. new elements or changed names
2. Process the source files (with the master template as the imnput docuement) using the XSLT - you will need an XSLT 2.0 processor for this, for example Saxon. Make sure that the document references at the topf of the XSLT are correct.
3. The result will be a set of template files, one for each template specified in the XSLT, in each of the languages in language_config.xml
