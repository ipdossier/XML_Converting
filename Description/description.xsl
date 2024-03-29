<?xml version='1.0'?>
<!-- http://sourceware.org/ml/xsl-list/2002-02/msg00662.html -->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- Output format settings -->
	<xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes" indent="no" />
	<xsl:template match="/">
		<html>
		<head>
			<style>
			b.paragraph {
				margin-right: 10px; 
			}
			.smallcaps {
				font-variant: small-caps
			}

			div.list {
 		   	  padding-left: 1.5em;
    		  text-indent:-1.5em;
			}

			</style>
		</head>
		<body>
		<xsl:apply-templates select="//heading|//p"/>
		</body></html>
		
	</xsl:template>

	<!-- Identity template, provides default behavior that copies all content into the output -->
    <!-- Please refer this from below URLs 
    	- http://stackoverflow.com/questions/5876382/using-xslt-to-copy-all-nodes-in-xml-with-support-for-special-cases 
    	- http://en.wikipedia.org/wiki/Identity_transform 
    -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

	<xsl:template match="//p"> 
		<div>
	 		<xsl:copy>
				<xsl:if test="@num != '0000'">
	 				<xsl:attribute name="id"><xsl:value-of select="@num" /></xsl:attribute>
					<xsl:element name="b">
						<xsl:attribute name="class">paragraph</xsl:attribute>
						<xsl:text>[</xsl:text>
						<xsl:value-of select="@num" />
						<xsl:text>]</xsl:text>
					</xsl:element>
	 			</xsl:if>
	 			<xsl:apply-templates select="@*|node()"/>
				<!--   			
				<xsl:apply-templates select="b | i | o | u | sup | sub | smallcaps | br | pre | dl | ul | ol | crossref | figref | patcit | nplcit | bio-deposit | img | chemistry | maths | tables | table-external-doc" />  
				-->	
			</xsl:copy>
		</div>
 	</xsl:template>
 	
 	<xsl:template match="smallcaps">
		<span>
			<xsl:attribute name="style">font-variant: small-caps;</xsl:attribute> 
			<xsl:apply-templates/>
		</span>
 	</xsl:template>
   
   <!-- @TODO Need to complete -->
   	<xsl:template match="o">
		<span>		
			<xsl:attribute name="style">text-decoration:overline</xsl:attribute> 
			<xsl:apply-templates/>
		</span>
   	</xsl:template>

	<!-- @TODO
		Need to implement an attribute list-style, the values are dash, bullet and none
	 -->
	<xsl:template match="ul">
		<div>
			<xsl:variable name="style_value">
				<!-- In the below style, the attribute padding-left and text-indent will 
					 make a more pretty paragraph -->
				<xsl:text>text-indent:-1.5em;</xsl:text>
				<xsl:choose>
					<!-- list items, it need to make space on both sides, otherwise the 
						content might cut -->
					<xsl:when test="./li/@num != '0000'">
						<xsl:text>padding-left:20px;padding-right:20px;</xsl:text>
					</xsl:when>
					<!-- an empty indented box -->
					<xsl:otherwise><xsl:text>width:100%;padding-left:20px;</xsl:text></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:attribute name="style"><xsl:value-of select="$style_value"/></xsl:attribute>
		
			<xsl:for-each select="./li">
				<xsl:call-template name="generate.listitem">
					<xsl:with-param name="id"><xsl:value-of select="@num" /></xsl:with-param>
					<xsl:with-param name="content"><xsl:value-of select="text()"></xsl:value-of></xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</div>	
	</xsl:template>
	
	<xsl:template name="generate.listitem">
		<xsl:param name="id" select="0000"/>
		<xsl:param name="content"/>
		<xsl:choose>
			<xsl:when test="$id != '0000'">
				<p>
					<xsl:attribute name="id"><xsl:value-of select="$id" /></xsl:attribute>
					<xsl:element name="b">
						<xsl:attribute name="class">paragraph</xsl:attribute>
						<xsl:text>[</xsl:text>
						<xsl:value-of select="@num" />
						<xsl:text>]</xsl:text>
					</xsl:element>
					<xsl:apply-templates/>
				</p>			
	
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		
		</xsl:choose>

<!-- 		<span> -->
<!-- 			<xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute> -->
<!-- 			<xsl:attribute name="class">box</xsl:attribute> -->
<!-- 		</span> -->
		
		
	</xsl:template>
		    
	<xsl:template match="heading">
		<div>
		<xsl:attribute name="style">text-align:center;</xsl:attribute>
			<!-- Heading has a tree level, so I mapped these levels with h4,5,6 sequentially -->
			<!-- for example, level 1 is h4, level 2 is h5 and so on -->
			<xsl:variable name="level" select="@level + 2"/>		
			<xsl:element name="{concat('h',$level)}">
				<xsl:if test="@id">
					<xsl:attribute name="id"><xsl:value-of select="@id" /></xsl:attribute>
				</xsl:if>
				<xsl:value-of select="text()"/>
			</xsl:element>
		</div>
	</xsl:template>

	<!-- tables tag converting logics -->
	<xsl:template match="tables">
		<div>
			<xsl:attribute name="style">margin-top:20px;</xsl:attribute>
			<xsl:if test="@id">
				<xsl:attribute name="id"><xsl:value-of select="@id" /></xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="table" />
		</div>
	</xsl:template>
	<xsl:template match="table">
		<div>
			<xsl:apply-templates select="tgroup" />
		</div>
	</xsl:template>
	<xsl:template match="tgroup">
		<xsl:param name="default.table.width" select="'100%'" />
		<table>
			<xsl:if test="../@pgwide=1">
				<xsl:attribute name="width">100%</xsl:attribute>
			</xsl:if>
			<xsl:if test="@align">
				<xsl:attribute name="align">
					<xsl:value-of select="@align" />
				</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="../@frame='TOPBOT'">
					<xsl:attribute name="style">border-top:thin solid black;border-bottom:thin solid black</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="border">0</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:variable name="colgroup">
				<colgroup>
					<xsl:call-template name="generate.colgroup">
						<xsl:with-param name="cols" select="@cols" />
					</xsl:call-template>
				</colgroup>
			</xsl:variable>
			<xsl:variable name="table.width">
				<xsl:choose>
					<xsl:when test="$default.table.width = ''">
						<xsl:text>100%</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$default.table.width" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:attribute name="width">
				<xsl:value-of select="$table.width" />
			</xsl:attribute>
			<xsl:copy-of select="$colgroup" />
			<xsl:apply-templates />
		</table>
	</xsl:template>
	<xsl:template match="colspec"></xsl:template>
	<xsl:template match="spanspec"></xsl:template>
	<xsl:template match="thead|tfoot">
		<xsl:element name="{name(.)}">
			<xsl:if test="@align">
				<xsl:attribute name="align">
					<xsl:value-of select="@align" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@char">
				<xsl:attribute name="char">
					<xsl:value-of select="@char" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@charoff">
				<xsl:attribute name="charoff">
					<xsl:value-of select="@charoff" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@valign">
				<xsl:attribute name="valign">
					<xsl:value-of select="@valign" />
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template match="tbody">
		<tbody>
			<xsl:if test="@align">
				<xsl:attribute name="align">
					<xsl:value-of select="@align" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@char">
				<xsl:attribute name="char">
					<xsl:value-of select="@char" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@charoff">
				<xsl:attribute name="charoff">
					<xsl:value-of select="@charoff" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@valign">
				<xsl:attribute name="valign">
					<xsl:value-of select="@valign" />
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates />
		</tbody>
	</xsl:template>
	<xsl:template match="row">
		<tr>
			<xsl:if test="@align">
				<xsl:attribute name="align">
					<xsl:value-of select="@align" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@char">
				<xsl:attribute name="char">
					<xsl:value-of select="@char" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@charoff">
				<xsl:attribute name="charoff">
					<xsl:value-of select="@charoff" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@valign">
				<xsl:attribute name="valign">
					<xsl:value-of select="@valign" />
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates />
		</tr>
	</xsl:template>
	<xsl:template match="thead/row/entry">
		<xsl:call-template name="process.cell">
			<xsl:with-param name="cellgi">
				<xsl:text>th</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="tbody/row/entry">
		<xsl:call-template name="process.cell">
			<xsl:with-param name="cellgi">
				<xsl:text>td</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="tfoot/row/entry">
		<xsl:call-template name="process.cell">
			<xsl:with-param name="cellgi">
				<xsl:text>th</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="process.cell">
		<xsl:param name="cellgi" select="td" />
		<xsl:variable name="empty.cell" select="count(node()) = 0" />
		<xsl:variable name="entry.colnum">
			<xsl:call-template name="entry.colnum" />
		</xsl:variable>
		<xsl:if test="$entry.colnum != ''">
			<xsl:variable name="prev.entry" select="preceding-sibling::*[1]" />
			<xsl:variable name="prev.ending.colnum">
				<xsl:choose>
					<xsl:when test="$prev.entry">
						<xsl:call-template name="entry.ending.colnum">
							<xsl:with-param name="entry" select="$prev.entry" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>0</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:call-template name="add-empty-entries">
				<xsl:with-param name="number">
					<xsl:choose>
						<xsl:when test="$prev.ending.colnum = ''">
							<xsl:text>0</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$entry.colnum - $prev.ending.colnum - 1" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:element name="{$cellgi}">
			<xsl:if test="@spanname">
				<xsl:variable name="namest"
					select="ancestor::tgroup/spanspec[@spanname=./@spanname]/@namest" />
				<xsl:variable name="nameend"
					select="ancestor::tgroup/spanspec[@spanname=./@spanname]/@nameend" />
				<xsl:variable name="colst"
					select="ancestor::*[colspec/@colname=$namest]/colspec[@colname=$namest]/@colnum" />
				<xsl:variable name="colend"
					select="ancestor::*[colspec/@colname=$nameend]/colspec[@colname=$nameend]/@colnum" />
				<xsl:attribute name="colspan">
					<xsl:value-of select="number($colend) - number($colst) + 1" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@morerows">
				<xsl:attribute name="rowspan">
					<xsl:value-of select="@morerows+1" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@namest">
				<xsl:attribute name="colspan">
					<xsl:call-template name="calculate.colspan" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@align">
				<xsl:attribute name="align">
					<xsl:value-of select="@align" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@char">
				<xsl:attribute name="char">
					<xsl:value-of select="@char" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@charoff">
				<xsl:attribute name="charoff">
					<xsl:value-of select="@charoff" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@valign">
				<xsl:attribute name="valign">
					<xsl:value-of select="@valign" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@rowsep='1'">
				<xsl:attribute name="style">border-bottom:thin solid black</xsl:attribute>
			</xsl:if>
			<xsl:if test="not(preceding-sibling::*) and ancestor::row/@id">
				<a name="{ancestor::row/@id}" />
			</xsl:if>
			<xsl:if test="@id">
				<a name="{@id}" />
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$empty.cell">
					<xsl:text>&#160;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	<xsl:template name="add-empty-entries">
		<xsl:param name="number" select="'0'" />
		<xsl:choose>
			<xsl:when test="$number &lt;= 0"></xsl:when>
			<xsl:otherwise>
				<td>&#160;</td>
				<xsl:call-template name="add-empty-entries">
					<xsl:with-param name="number" select="$number - 1" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="entry.colnum">
		<xsl:param name="entry" select="." />
		<xsl:choose>
			<xsl:when test="$entry/@colname">
				<xsl:variable name="colname" select="$entry/@colname" />
				<xsl:variable name="colspec"
					select="$entry/ancestor::tgroup/colspec[@colname=$colname]" />
				<xsl:call-template name="colspec.colnum">
					<xsl:with-param name="colspec" select="$colspec" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$entry/@namest">
				<xsl:variable name="namest" select="$entry/@namest" />
				<xsl:variable name="colspec"
					select="$entry/ancestor::tgroup/colspec[@colname=$namest]" />
				<xsl:call-template name="colspec.colnum">
					<xsl:with-param name="colspec" select="$colspec" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="count($entry/preceding-sibling::*) = 0">
				<xsl:text>1</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="pcol">
					<xsl:call-template name="entry.ending.colnum">
						<xsl:with-param name="entry"
							select="$entry/preceding-sibling::*[1]" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$pcol + 1" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="entry.ending.colnum">
		<xsl:param name="entry" select="." />
		<xsl:choose>
			<xsl:when test="$entry/@colname">
				<xsl:variable name="colname" select="$entry/@colname" />
				<xsl:variable name="colspec"
					select="$entry/ancestor::tgroup/colspec[@colname=$colname]" />
				<xsl:call-template name="colspec.colnum">
					<xsl:with-param name="colspec" select="$colspec" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$entry/@nameend">
				<xsl:variable name="nameend" select="$entry/@nameend" />
				<xsl:variable name="colspec"
					select="$entry/ancestor::tgroup/colspec[@colname=$nameend]" />
				<xsl:call-template name="colspec.colnum">
					<xsl:with-param name="colspec" select="$colspec" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="count($entry/preceding-sibling::*) = 0">
				<xsl:text>1</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="pcol">
					<xsl:call-template name="entry.ending.colnum">
						<xsl:with-param name="entry"
							select="$entry/preceding-sibling::*[1]" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$pcol + 1" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="colspec.colnum">
		<xsl:param name="colspec" select="." />
		<xsl:choose>
			<xsl:when test="$colspec/@colnum">
				<xsl:value-of select="$colspec/@colnum" />
			</xsl:when>
			<xsl:when test="$colspec/preceding-sibling::colspec">
				<xsl:variable name="prec.colspec.colnum">
					<xsl:call-template name="colspec.colnum">
						<xsl:with-param name="colspec"
							select="$colspec/preceding-sibling::colspec[1]" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$prec.colspec.colnum + 1" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>1</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="generate.colgroup">
		<xsl:param name="cols" select="1" />
		<xsl:param name="count" select="1" />
		<xsl:choose>
			<xsl:when test="$count>$cols"></xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="generate.col">
					<xsl:with-param name="countcol" select="$count" />
				</xsl:call-template>
				<xsl:call-template name="generate.colgroup">
					<xsl:with-param name="cols" select="$cols" />
					<xsl:with-param name="count" select="$count+1" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="generate.col">
		<xsl:param name="countcol" select="1" />
		<xsl:param name="colspecs" select="./colspec" />
		<xsl:param name="count" select="1" />
		<xsl:param name="colnum" select="1" />
		<xsl:choose>
			<xsl:when test="$count>count($colspecs)">
				<col />
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="colspec" select="$colspecs[$count=position()]" />
				<xsl:variable name="colspec.colnum">
					<xsl:choose>
						<xsl:when test="$colspec/@colnum">
							<xsl:value-of select="$colspec/@colnum" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$colnum" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$colspec.colnum=$countcol">
						<col>
							<xsl:if test="$colspec/@align">
								<xsl:attribute name="align">
									<xsl:value-of select="$colspec/@align" />
								</xsl:attribute>
							</xsl:if>
							<xsl:if test="$colspec/@colwidth">
								<xsl:attribute name="width">
									<xsl:value-of select="$colspec/@colwidth" />
								</xsl:attribute>
							</xsl:if>
							<xsl:if test="$colspec/@char">
								<xsl:attribute name="char">
									<xsl:value-of select="$colspec/@char" />
								</xsl:attribute>
							</xsl:if>
							<xsl:if test="$colspec/@charoff">
								<xsl:attribute name="charoff">
									<xsl:value-of select="$colspec/@charoff" />
								</xsl:attribute>
							</xsl:if>
						</col>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="generate.col">
							<xsl:with-param name="countcol" select="$countcol" />
							<xsl:with-param name="colspecs" select="$colspecs" />
							<xsl:with-param name="count" select="$count+1" />
							<xsl:with-param name="colnum">
								<xsl:choose>
									<xsl:when test="$colspec/@colnum">
										<xsl:value-of select="$colspec/@colnum + 1" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$colnum + 1" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="colspec.colwidth">
		<!-- when this macro is called, the current context must be an entry -->
		<xsl:param name="colname"></xsl:param>
		<!-- .. = row, ../.. = thead|tbody, ../../.. = tgroup -->
		<xsl:param name="colspecs" select="../../../../tgroup/colspec" />
		<xsl:param name="count" select="1" />
		<xsl:choose>
			<xsl:when test="$count>count($colspecs)"></xsl:when>
			<xsl:otherwise>
				<xsl:variable name="colspec" select="$colspecs[$count=position()]" />
				<xsl:choose>
					<xsl:when test="$colspec/@colname=$colname">
						<xsl:value-of select="$colspec/@colwidth" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="colspec.colwidth">
							<xsl:with-param name="colname" select="$colname" />
							<xsl:with-param name="colspecs" select="$colspecs" />
							<xsl:with-param name="count" select="$count+1" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="calculate.colspan">
		<xsl:param name="entry" select="." />
		<xsl:variable name="namest" select="$entry/@namest" />
		<xsl:variable name="nameend" select="$entry/@nameend" />
		<xsl:variable name="scol">
			<xsl:call-template name="colspec.colnum">
				<xsl:with-param name="colspec"
					select="$entry/ancestor::tgroup/colspec[@colname=$namest]" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="ecol">
			<xsl:call-template name="colspec.colnum">
				<xsl:with-param name="colspec"
					select="$entry/ancestor::tgroup/colspec[@colname=$nameend]" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$ecol - $scol + 1" />
	</xsl:template>
</xsl:stylesheet>
