<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:variable name="v_template-name" select="'arcgis_10_2_reference_landscape_side_v4.mxd'"/>
    <xsl:variable name="v_values-doc" select="'ma_templates_element_values.xml'"/>
    <xsl:variable name="v_template-master" select="'ma_qgis_master_v1.qpt'"/>

    <xsl:template match="/">
        <!--Process the master template doc once for each unique value of template in the lookup -->
        <xsl:for-each-group select="root/row" group-by="template">
            <xsl:apply-templates select="document($v_template-master)" mode="m_templates">
                <xsl:with-param name="p_template-name">
                    <xsl:value-of select="template"/>
                </xsl:with-param>
            </xsl:apply-templates>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="/Layout" mode="m_templates">
        <xsl:param name="p_template-name"/>
        <!-- Output a new template document for each template -->
        <xsl:result-document
            href="{concat('qgis_',substring-before(substring-after($p_template-name,'arcgis_10_2_'),'.'),'.qpt')}">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()" mode="m_templates">
                    <xsl:with-param name="p_template-name" select="$p_template-name"/>
                </xsl:apply-templates>
            </xsl:copy>
        </xsl:result-document>
    </xsl:template>

    <!-- Change the name of the tempate to a qgis version -->

    <xsl:template match="/Layout/@name" mode="m_templates">
        <xsl:param name="p_template-name"/>
        <xsl:attribute name="name">
            <xsl:value-of
                select="substring-before(substring-after($p_template-name,'arcgis_10_2_'),'.')"/>
        </xsl:attribute>
    </xsl:template>

    <!-- Change the paper size depending on portrait or landscape -->
    <xsl:template match="/Layout/PageCollection/LayoutItem/@size" mode="m_templates">
        <xsl:param name="p_template-name"/>
        <xsl:message>
            <xsl:value-of select="$p_template-name"/>
        </xsl:message>
        <xsl:choose>
            <xsl:when test="contains($p_template-name,'portrait')">
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
        <xsl:variable name="v_id" select="../@id"/>
        <xsl:choose>
            <!-- When the item exists in the lookup, using the position settings -->
            <xsl:when
                test="not($v_id='') and document($v_values-doc)/root/row[template=$p_template-name][normalize-space(element)=$v_id]">
                <xsl:attribute name="{$v_attribute}">
                    <xsl:call-template name="t_get_xy">
                        <xsl:with-param name="p_element" select="$v_id"/>
                        <xsl:with-param name="p_template-name" select="$p_template-name"/>
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
        <xsl:choose>
            <xsl:when
                test="document($v_values-doc)/root/row[template=$p_template-name][normalize-space(element)=$v_id]">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()" mode="m_templates">
                        <xsl:with-param name="p_template-name" select="$p_template-name"/>
                    </xsl:apply-templates>
                </xsl:copy>

            </xsl:when>
            <xsl:otherwise/>

        </xsl:choose>
    </xsl:template>

    <!-- Set siz for each item-->
    <xsl:template match="/Layout/LayoutItem/@size" mode="m_templates">
        <xsl:param name="p_template-name"/>
        <xsl:variable name="v_attribute" select="local-name()"/>
        <xsl:variable name="v_id" select="../@id"/>
        <xsl:choose>
            <xsl:when
                test="not($v_id='') and document($v_values-doc)/root/row[template=$p_template-name][normalize-space(element)=$v_id]">
                <xsl:attribute name="{$v_attribute}">
                    <xsl:value-of
                        select="concat(document($v_values-doc)/root/row[template=$p_template-name][normalize-space(element)=$v_id]/width,',',document($v_values-doc)/root/row[template=$p_template-name][normalize-space(element)=$v_id]/height,',mm')"
                    />
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="{$v_attribute}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--Calculate xy postions - all anchor points are top left-->
    <xsl:template name="t_get_xy">
        <xsl:param name="p_element"/>
        <xsl:param name="p_template-name"/>
        <xsl:variable name="v_page-height">
            <xsl:choose>
                <xsl:when test="contains($p_template-name,'portrait')">420</xsl:when>
                <xsl:otherwise>297</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_x">
            <xsl:value-of
                select="document($v_values-doc)/root/row[template=$p_template-name][normalize-space(element)=$p_element]/position_x"
            />
        </xsl:variable>
        <xsl:variable name="v_y">
            <xsl:value-of
                select="$v_page-height - (document($v_values-doc)/root/row[template=$p_template-name][normalize-space(element)=$p_element]/position_y + document($v_values-doc)/root/row[template=$p_template-name][normalize-space(element)=$p_element]/height)"
            />
        </xsl:variable>
        <xsl:value-of select="concat($v_x,',',$v_y,',mm')"/>
    </xsl:template>

    <xsl:template match="@*|node()" mode="m_templates">
        <xsl:param name="p_template-name"/>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="m_templates">
                <xsl:with-param name="p_template-name" select="$p_template-name"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:param name="p_template-name"/>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()">
                <xsl:with-param name="p_template-name"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
