<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <!--This script takes as input document a master QGIS template, and references a CSV with names and positions of elements in an ArcGIS template-->
    <!--It uses this to generated a set of standard QGIS templates, populating them with the correct values-->
    <!--Ant Scott, MapAction July 2020-->

    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!--The file name of the element values document-->
    <xsl:variable name="v_values-doc" select="'../ArcGIS_settings/ma_templates_element_values.csv'"/>

    <!-- The file name of the QGIS master template-->
    <xsl:variable name="v_template-master" select="'../ma_qgis_master_v1.qpt'"/>

    <!--The prefix for the Arc version used in the element values document-->
    <xsl:variable name="v_arc-version" select="'arcmap-10.6_'"/>

    <xsl:template match="/">
        <!--Process the master template doc once for each template -->
        <xsl:apply-templates select="document($v_template-master)" mode="m_templates">
            <xsl:with-param name="p_template-name">
                <xsl:value-of select="'arcmap-10.6_reference_landscape_bottom.mxd'"/>
            </xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="document($v_template-master)" mode="m_templates">
            <xsl:with-param name="p_template-name">
                <xsl:value-of select="'arcmap-10.6_reference_landscape_side.mxd'"/>
            </xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="document($v_template-master)" mode="m_templates">
            <xsl:with-param name="p_template-name">
                <xsl:value-of select="'arcmap-10.6_reference_portrait_bottom.mxd'"/>
            </xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="document($v_template-master)" mode="m_templates">
            <xsl:with-param name="p_template-name">
                <xsl:value-of select="'arcmap-10.6_thematic_landscape.mxd'"/>
            </xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="document($v_template-master)" mode="m_templates">
            <xsl:with-param name="p_template-name">
                <xsl:value-of select="'arcmap-10.6_thematic_portrait.mxd'"/>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="/Layout" mode="m_templates">
        <xsl:param name="p_template-name"/>
        <!--Create QGIS template based on source template name-->
        <xsl:result-document
            href="{concat(substring-before(substring-after($p_template-name,$v_arc-version),'.'),'.qpt')}">
            <xsl:copy>
                <xsl:apply-templates select="@* | node()" mode="m_templates">
                    <xsl:with-param name="p_template-name" select="$p_template-name"/>
                </xsl:apply-templates>
            </xsl:copy>
        </xsl:result-document>
    </xsl:template>

    <!-- Change the name of the template to a qgis version -->
    <xsl:template match="/Layout/@name" mode="m_templates">
        <xsl:param name="p_template-name"/>
        <xsl:attribute name="name">
            <xsl:value-of
                select="substring-before(substring-after($p_template-name, $v_arc-version), '.')"/>
        </xsl:attribute>
    </xsl:template>

    <!-- Change the paper size depending on portrait or landscape -->
    <xsl:template match="/Layout/PageCollection/LayoutItem/@size" mode="m_templates">
        <xsl:param name="p_template-name"/>
        <xsl:message>
            <xsl:value-of select="$p_template-name"/>
        </xsl:message>
        <xsl:choose>
            <xsl:when test="contains($p_template-name, 'portrait')">
                <xsl:attribute name="size">
                    <xsl:value-of select="'297,420,mm'"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="size">
                    <xsl:value-of select="'420,297,mm'"/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Set position for each item-->
    <xsl:template match="/Layout/LayoutItem/@position | /Layout/LayoutItem/@positionOnPage"
        mode="m_templates">
        <xsl:param name="p_template-name"/>
        <xsl:variable name="v_attribute" select="local-name()"/>
        <xsl:variable name="v_id" select="parent::LayoutItem/@id"/>
        <xsl:variable name="v_attribute" select="local-name()"/>
        <xsl:variable name="v_reference-point" select="../@referencePoint"/>
        <xsl:variable name="v_item-exists">
            <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                <xsl:variable name="v_row" select="tokenize(., ',')"/>
                <!-- When the item exists in the lookup, using the position settings -->
                <xsl:choose>
                    <xsl:when
                        test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')"
                        >T</xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$v_item-exists = 'T'">
                <xsl:attribute name="{$v_attribute}">
                    <xsl:call-template name="t_get_xy">
                        <xsl:with-param name="p_element" select="$v_id"/>
                        <xsl:with-param name="p_template-name" select="$p_template-name"/>
                        <xsl:with-param name="p_reference-point" select="$v_reference-point"/>
                    </xsl:call-template>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="{$v_attribute}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--Include only items which are in the lookup-->
    <xsl:template match="/Layout/LayoutItem" mode="m_templates">
        <xsl:param name="p_template-name"/>
        <xsl:variable name="v_attribute" select="local-name()"/>
        <xsl:variable name="v_id" select="@id"/>
        <xsl:variable name="v_this-item" select="."/>
        <xsl:variable name="v_item-exists">
            <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                <xsl:variable name="v_row" select="tokenize(., ',')"/>
                <!-- When the item exists in the lookup, using the position settings -->
                <xsl:choose>
                    <xsl:when
                        test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')"
                        >T</xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$v_item-exists = 'T'">
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()" mode="m_templates">
                        <xsl:with-param name="p_template-name" select="$p_template-name"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <!--    <xsl:template match="/Layout/LayoutItem/Extent/@ymax" mode="m_templates">
        <xsl:attribute name="ymax">
            <xsl:choose>
                <xsl:when test="../../@id = 'Main map'">
                    <xsl:message>
                        <xsl:value-of select="../../@id"/>
                    </xsl:message>
                    <xsl:value-of select="format-number(number(../@ymin) + 10675, '0')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="format-number(number(../@ymin) + 264297, '0')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

-->
    <!-- Set size for each item-->
    <xsl:template match="/Layout/LayoutItem/@size" mode="m_templates">
        <xsl:param name="p_template-name"/>
        <xsl:variable name="v_attribute" select="local-name()"/>
        <xsl:variable name="v_id" select="../@id"/>
        <xsl:variable name="v_value" select="."/>
        <xsl:variable name="v_item-exists">
            <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                <xsl:variable name="v_row" select="tokenize(., ',')"/>
                <!-- When the item exists in the lookup, using the position settings -->
                <xsl:choose>
                    <xsl:when
                        test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')"
                        >T</xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$v_item-exists = 'T'">
                <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                    <xsl:variable name="v_row" select="tokenize(., ',')"/>
                    <!-- When the item exists in the lookup, using the position settings -->
                    <xsl:choose>
                        <xsl:when
                            test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')">
                            <xsl:variable name="v_height" select="normalize-space($v_row[6])"/>
                            <xsl:variable name="v_width" select="normalize-space($v_row[7])"/>
                            <xsl:attribute name="{$v_attribute}">
                                <xsl:value-of select="concat($v_width, ',', $v_height, ',mm')"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$v_value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--Height and Y settings for maps have to be set as data driven, otherwise they are overwritten by extent-->
    <!--Main map height-->
    <xsl:template
        match="/Layout/LayoutItem[@id = ('Main map')]/LayoutObject/dataDefinedProperties/Option[@type = 'Map']/Option[@name = 'properties']/Option[@name = 'dataDefinedHeight']/Option[@name = 'expression']/@value"
        mode="m_templates">
        <xsl:param name="p_template-name"/>
        <xsl:variable name="v_attribute" select="local-name()"/>
        <xsl:variable name="v_id" select="'Main map'"/>
        <xsl:variable name="v_value" select="."/>
        <xsl:variable name="v_item-exists">
            <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                <xsl:variable name="v_row" select="tokenize(., ',')"/>
                <!-- When the item exists in the lookup, using the position settings -->
                <xsl:choose>
                    <xsl:when
                        test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')"
                        >T</xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="v_item-exists">
            <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                <xsl:variable name="v_row" select="tokenize(., ',')"/>
                <!-- When the item exists in the lookup, using the position settings -->
                <xsl:choose>
                    <xsl:when
                        test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')"
                        >T</xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$v_item-exists = 'T'">
                <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                    <xsl:variable name="v_row" select="tokenize(., ',')"/>

                    <!-- When the item exists in the lookup, using the position settings -->
                    <xsl:choose>
                        <xsl:when
                            test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')">
                            <xsl:variable name="v_height" select="normalize-space($v_row[6])"/>
                            <xsl:attribute name="{$v_attribute}">
                                <xsl:value-of select="$v_height"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$v_value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--Location map height-->
    <xsl:template
        match="/Layout/LayoutItem[@id = ('Location map')]/LayoutObject/dataDefinedProperties/Option[@type = 'Map']/Option[@name = 'properties']/Option[@name = 'dataDefinedHeight']/Option[@name = 'expression']/@value"
        mode="m_templates">
        <xsl:param name="p_template-name"/>
        <xsl:variable name="v_attribute" select="local-name()"/>
        <xsl:variable name="v_id" select="'Location map'"/>
        <xsl:variable name="v_value" select="."/>
        <xsl:variable name="v_item-exists">
            <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                <xsl:variable name="v_row" select="tokenize(., ',')"/>
                <!-- When the item exists in the lookup, using the position settings -->
                <xsl:choose>
                    <xsl:when
                        test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')"
                        >T</xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="v_item-exists">
            <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                <xsl:variable name="v_row" select="tokenize(., ',')"/>
                <!-- When the item exists in the lookup, using the position settings -->
                <xsl:choose>
                    <xsl:when
                        test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')"
                        >T</xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$v_item-exists = 'T'">
                <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                    <xsl:variable name="v_row" select="tokenize(., ',')"/>

                    <!-- When the item exists in the lookup, using the position settings -->
                    <xsl:choose>
                        <xsl:when
                            test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')">
                            <xsl:variable name="v_height" select="normalize-space($v_row[6])"/>
                            <xsl:attribute name="{$v_attribute}">
                                <xsl:value-of select="$v_height"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$v_value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--Main map Y-->
    <xsl:template
        match="/Layout/LayoutItem[@id = ('Main map')]/LayoutObject/dataDefinedProperties/Option[@type = 'Map']/Option[@name = 'properties']/Option[@name = 'dataDefinedPositionY']/Option[@name = 'expression']/@value"
        mode="m_templates">
        <xsl:param name="p_template-name"/>
        <xsl:variable name="v_page-height">
            <xsl:choose>
                <xsl:when test="contains($p_template-name, 'portrait')">420</xsl:when>
                <xsl:otherwise>297</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_attribute" select="local-name()"/>
        <xsl:variable name="v_id" select="'Main map'"/>
        <xsl:variable name="v_value" select="."/>
        <xsl:variable name="v_item-exists">
            <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                <xsl:variable name="v_row" select="tokenize(., ',')"/>
                <!-- When the item exists in the lookup, using the position settings -->
                <xsl:choose>
                    <xsl:when
                        test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')"
                        >T</xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="v_item-exists">
            <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                <xsl:variable name="v_row" select="tokenize(., ',')"/>
                <!-- When the item exists in the lookup, using the position settings -->
                <xsl:choose>
                    <xsl:when
                        test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')"
                        >T</xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$v_item-exists = 'T'">
                <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                    <xsl:variable name="v_row" select="tokenize(., ',')"/>

                    <!-- When the item exists in the lookup, using the position settings -->
                    <xsl:choose>
                        <xsl:when
                            test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')">
                            <xsl:variable name="v_y" select="normalize-space($v_row[5])"/>
                            <xsl:attribute name="{$v_attribute}">
                                <xsl:value-of select="$v_page-height - number($v_y)"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$v_value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--Location map Y-->
    <xsl:template
        match="/Layout/LayoutItem[@id = ('Location map')]/LayoutObject/dataDefinedProperties/Option[@type = 'Map']/Option[@name = 'properties']/Option[@name = 'dataDefinedPositionY']/Option[@name = 'expression']/@value"
        mode="m_templates">
        <xsl:param name="p_template-name"/>
        <xsl:variable name="v_page-height">
            <xsl:choose>
                <xsl:when test="contains($p_template-name, 'portrait')">420</xsl:when>
                <xsl:otherwise>297</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_attribute" select="local-name()"/>
        <xsl:variable name="v_id" select="'Location map'"/>
        <xsl:variable name="v_value" select="."/>
        <xsl:variable name="v_item-exists">
            <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                <xsl:variable name="v_row" select="tokenize(., ',')"/>
                <!-- When the item exists in the lookup, using the position settings -->
                <xsl:choose>
                    <xsl:when
                        test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')"
                        >T</xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="v_item-exists">
            <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                <xsl:variable name="v_row" select="tokenize(., ',')"/>
                <!-- When the item exists in the lookup, using the position settings -->
                <xsl:choose>
                    <xsl:when
                        test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')"
                        >T</xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$v_item-exists = 'T'">
                <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                    <xsl:variable name="v_row" select="tokenize(., ',')"/>

                    <!-- When the item exists in the lookup, using the position settings -->
                    <xsl:choose>
                        <xsl:when
                            test="$v_row[1] = $p_template-name and $v_row[2] = $v_id and not($v_id = '')">
                            <xsl:variable name="v_y" select="normalize-space($v_row[5])"/>
                            <xsl:attribute name="{$v_attribute}">
                                <xsl:value-of select="$v_page-height - number($v_y)"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$v_value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--Calculate xy postions - all anchor points are bottom left-->
    <xsl:template name="t_get_xy">
        <xsl:param name="p_element"/>
        <xsl:param name="p_template-name"/>
        <xsl:param name="p_reference-point"/>
        <xsl:variable name="v_page-height">
            <xsl:choose>
                <xsl:when test="contains($p_template-name, 'portrait')">420</xsl:when>
                <xsl:otherwise>297</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_x">
            <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                <xsl:variable name="v_row" select="tokenize(., ',')"/>
                <!-- When the item exists in the lookup, using the position settings -->
                <xsl:choose>
                    <xsl:when test="$v_row[1] = $p_template-name and $v_row[2] = $p_element">
                        <xsl:value-of select="$v_row[4]"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="v_y">
            <xsl:for-each select="tokenize(unparsed-text($v_values-doc), '\n')">
                <xsl:variable name="v_row" select="tokenize(., ',')"/>
                <!-- When the item exists in the lookup, using the position settings -->
                <xsl:choose>
                    <xsl:when test="$v_row[1] = $p_template-name and $v_row[2] = $p_element">
                        <xsl:value-of select="$v_row[5]"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="concat($v_x, ',', ($v_page-height - $v_y), ',mm')"/>
    </xsl:template>

    <xsl:template match="@* | node()" mode="m_templates">
        <xsl:param name="p_template-name"/>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="m_templates">
                <xsl:with-param name="p_template-name" select="$p_template-name"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@* | node()">
        <xsl:param name="p_template-name"/>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()">
                <xsl:with-param name="p_template-name"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
