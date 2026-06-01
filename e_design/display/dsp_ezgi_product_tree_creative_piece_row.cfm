<!---
    File: dsp_ezgi_product_tree_creative_piece_row.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<style>
	<!--
		 .center 
		{
			 margin-left: auto;
			 margin-right: auto;
			  width: 80%;
		 }
	
	.Gri_1 {
		font-family: Arial, Helvetica, sans-serif;
		font-size: 13px;
		font-weight: bold;
		color: #020202;
		background-color: #BDBDBD;
		text-align: center;
		vertical-align: middle;
		border: 1px solid #2B2B2B;
	}
	.Gri_2 {
		font-family: Arial, Helvetica, sans-serif;
		font-size: 10px;
		font-weight: bold;
		color: #020202;
		background-color: #BDBDBD;
		text-align: center;
		vertical-align: middle;
		border: 1px solid #2B2B2B;
	}
	.Beyaz_1 {
		font-family: Arial, Helvetica, sans-serif;
		font-size: 12px;
		font-weight: bold;
		color: #020202;
		background-color: #FFFFFF;
		text-align: center;
		vertical-align: middle;
		border: 1px solid #2B2B2B;
	}
	.Beyaz_2 {
		font-family: Arial, Helvetica, sans-serif;
		font-size: 10px;
		font-weight: bold;
		color: #020202;
		background-color: #FFFFFF;
		text-align: left;
		vertical-align: middle;
		border: 1px solid #2B2B2B;
	}
	.Beyaz_3 {
		font-family: Arial, Helvetica, sans-serif;
		font-size: 10px;
		font-weight: bold;
		color: #020202;
		background-color: #FFFFFF;
		text-align: center;
		vertical-align: middle;
		border: 1px solid #2B2B2B;
	}
	.Beyaz_4 {
		font-family: Arial, Helvetica, sans-serif;
		font-size: 9px;
		font-weight: bold;
		color: #020202;
		background-color: #FFFFFF;
		text-align: center;
		vertical-align: middle;
		border: 1px solid #2B2B2B;
	}
	.Beyaz_5{
		font-family: Arial, Helvetica, sans-serif;
		font-size: 9px;
		font-weight: bold;
		color: #020202;
		background-color: #FFFFFF;
		text-align: center;
		vertical-align: middle;
		border: 1px solid #2B2B2B;
	}
	.text_1 {
		font-family: Arial, Helvetica, sans-serif;
		font-size: 11px;
		color: #020202;
		background-color: #FFFFFF;
		text-align: center;
		vertical-align: middle;
	}
	.textbox {
		background-color: #FFFFFF;
		border: 0px none #FFFFFF;
	}
	.butonbeyaz {
		background-color: #999999;
		border: 1px solid #FFFFFF;
		color: #FFFFFF;
	}
	.Baslik1 {
		font-size: 20px;
	}
	.Baslik2 {
		font-weight: bold;
		font-size: 10px;
	}
	.Baslik3 {
		font-weight: bold;
		font-size: 14px;
	}
	.Baslik4 {
		font-weight: bold;
		font-size: 10px;
	}
	.baslik6 {
		font-size: 6px;
		font-weight: bold;
		word-spacing: 1mm;
	}
	.baslik7 {
	
		font-size: 56px;
		font-weight: bold;
	
	}
	.icerik1 {
		font-size: 9px;
	}
	.icerik2 {
		font-size: 7px;
	}
	.th {
		background-color: #999999;
		border: 1px solid #2B2B2B;
	}
	.thc {
		background-color: #FFFFFF;
		border: 1px solid #2B2B2B;
	}
	-->
	</style>
		<cfset get_default.DEFAULT_IS_STATION_OR_IS_OPERATION = 0>
		<cfquery name="get_colors" datasource="#dsn3#">
			SELECT * FROM EZGI_COLORS ORDER BY COLOR_NAME
		</cfquery>
		<cfoutput query="get_colors">
			<cfset 'COLOR_NAME_#COLOR_ID#' = COLOR_NAME>
		</cfoutput>
	
		<cfquery name="CHECK" datasource="#DSN#">
			SELECT
				COMPANY_NAME,
				TEL_CODE,
				TEL,TEL2,
				TEL3,
				TEL4,
				FAX,
				ADDRESS,
				WEB,
				EMAIL,
				ASSET_FILE_NAME3,
				ASSET_FILE_NAME2,
				ASSET_FILE_NAME1
			FROM
				OUR_COMPANY
			WHERE 
				COMP_ID = #session.ep.company_id#
		</cfquery>
		<cfquery name="get_product_print" datasource="#dsn3#">
			SELECT DISTINCT
				PIECE_ROW_ID,
				PIECE_TYPE, 
				PIECE_NAME, 
				PIECE_CODE, 
				PIECE_COLOR_ID, 
				PIECE_DETAIL, 
				PIECE_AMOUNT, 
				TRIM_TYPE, 
				TRIM_SIZE, 
				IS_FLOW_DIRECTION, 
				BOYU, 
				ENI, 
				KESIM_BOYU, 
				KESIM_ENI, 
				KALINLIK,
				MATERIAL_ID,
				(SELECT DESIGN_NAME FROM EZGI_DESIGN WHERE DESIGN_ID = E.DESIGN_ID) as DESIGN_MAIN_NAME,
				(SELECT PACKAGE_NUMBER FROM EZGI_DESIGN_PACKAGE WHERE PACKAGE_ROW_ID = E.DESIGN_PACKAGE_ROW_ID) as PACKAGE_NUMBER,
				(SELECT PROPERTY_DETAIL FROM #dsn1_alias#.PRODUCT_PROPERTY_DETAIL WHERE PROPERTY_DETAIL_ID = E.KALINLIK) AS KALINLIK_,
				ISNULL((SELECT SUM(AMOUNT) AS AMOUNT FROM EZGI_DESIGN_PIECE_ROW WHERE RELATED_PIECE_ROW_ID=E.PIECE_ROW_ID GROUP BY RELATED_PIECE_ROW_ID),0) AS 		USED_AMOUNT
			FROM 
				EZGI_DESIGN_PIECE_ROWS E
			WHERE 
				PIECE_TYPE <> 4 AND 
				PIECE_STATUS = 1
				<cfif isdefined('attributes.design_package_row_id') and len(attributes.design_package_row_id)>
					AND DESIGN_PACKAGE_ROW_ID = #attributes.design_package_row_id#
				</cfif>
				<cfif isdefined('attributes.design_main_row_id') and len(attributes.design_main_row_id)>
					AND DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
				</cfif>
				<cfif isdefined('attributes.design_piece_row_id') and len(attributes.design_piece_row_id)> 
					AND PIECE_ROW_ID = #attributes.design_piece_row_id#
				</cfif>
				<cfif isdefined('attributes.design_id') and len(attributes.design_id)>
					AND DESIGN_ID = #attributes.design_id#
				</cfif>
		</cfquery>
		<cfset product_cat_id_list = ValueList(get_product_print.MATERIAL_ID)>
		<cfset product_cat_id_list = ListDeleteDuplicates(product_cat_id_list,',')>
		<cfif len(product_cat_id_list)>
			<cfquery name="get_malzeme" datasource="#dsn3#">
				SELECT        
					PT.STOCK_ID, 
					PC.PRODUCT_CAT
				FROM            
					PRODUCT_TREE AS PT INNER JOIN
					STOCKS AS S ON PT.RELATED_ID = S.STOCK_ID INNER JOIN
					PRODUCT_CAT AS PC ON S.PRODUCT_CATID = PC.PRODUCT_CATID
				WHERE        
					PT.STOCK_ID IN (#product_cat_id_list#) AND 
					PT.RELATED_ID IS NOT NULL 
				GROUP BY 
					PT.STOCK_ID,
					PC.PRODUCT_CAT
			</cfquery>
			<cfoutput query="get_malzeme">
				<cfset 'PRODUCT_CAT_#STOCK_ID#' = PRODUCT_CAT>
			</cfoutput>
		</cfif>
	<cfquery name="GET_DEFAULT_QUANTITY" datasource="#dsn3#">
		SELECT D.PRODUCT_QUANTITY FROM EZGI_DESIGN_PIECE AS E INNER JOIN EZGI_DESIGN AS D ON E.DESIGN_ID = D.DESIGN_ID WHERE E.PIECE_ROW_ID = #attributes.design_piece_row_id#
	</cfquery>
	<cfset attributes.product_quantity = GET_DEFAULT_QUANTITY.PRODUCT_QUANTITY>
	<div id="dvCntr" class="center">
		 <fieldset>
		 <legend><b><span id="spnHeader"><cf_get_lang dictionary_id="108.Refakat Fişi"></span></b></legend>
			  <table style="width:90%; height:95% margin-left:auto; margin-right:auto; margin-top:auto" border="0">
				  <tr>
					 <td><cfloop query="get_product_print"><cfinclude template="frm_refakat_fisi.cfm"></cfloop></td>	
				  </tr>
			   </table>
		 </fieldset>
	</div>
	