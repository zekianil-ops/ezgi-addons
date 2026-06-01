<!---
    File: dsp_ezgi_product_tree_import.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---Design Sorgusu--->
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_DEFAULTS
</cfquery>
<cfquery name="get_design_info" datasource="#dsn3#">
	SELECT 
    	PRODUCT_CAT.HIERARCHY,
        ED.DESIGN_NAME, 
        ED.PROCESS_ID,
       	ED.PRODUCT_CATID,
        ED.PROCESS_ID,
        PRODUCT_CAT.PRODUCT_CAT,
        ISNULL(IS_PROTOTIP,0) IS_PROTOTIP
   	FROM 
    	EZGI_DESIGN AS ED INNER JOIN PRODUCT_CAT ON 
        ED.PRODUCT_CATID = PRODUCT_CAT.PRODUCT_CATID 
  	WHERE 
    	ED.DESIGN_ID = #attributes.design_id#
</cfquery>
<!---Design Sorgusu--->
<cfset is_transfer = 1>
<cfset urun_type = 0>
<cfinclude template="../query/cnt_ezgi_product_tree_import_ortak.cfm">
<!---<cfdump var="#get_product_tree#">--->
<cfif get_product_tree.recordcount>
	<cfquery name="get_workcube_product_tree" datasource="#dsn3#">
    	SELECT        
         	SR.AMOUNT AS AMOUNT, 
          	ISNULL(SR.OPERATION_TYPE_ID,0) AS OPERATION_TYPE_ID, 
         	ISNULL(SR.STOCK_ID,0) AS RELATED_ID
		FROM            
        	SPECT_MAIN AS S INNER JOIN
        	SPECT_MAIN_ROW AS SR ON S.SPECT_MAIN_ID = SR.SPECT_MAIN_ID
		WHERE        
       		S.STOCK_ID = #attributes.STOCK_ID#
       	ORDER BY
        	OPERATION_TYPE_ID DESC,
           	RELATED_ID
	</cfquery>
   	<cfoutput query="get_workcube_product_tree">
   		<cfset 'M_AMOUNT_#RELATED_ID#' = AMOUNT>
      	<cfset 'P_AMOUNT_#OPERATION_TYPE_ID#' =AMOUNT>
 	</cfoutput>
<cfelse>
	<cfset get_workcube_product_tree.recordcount=0>
</cfif>
<!---<cfdump var="#get_workcube_product_tree#">--->
<table class="dph">
    <tr>
        <td class="dpht">&nbsp;<cfoutput> <cf_get_lang dictionary_id="58783.Workcube">  <cf_get_lang dictionary_id="49.Ürün Ağacı Kontrol">  - #urun_adi#</cfoutput></td>
        <td class="dphb">
        	<cfoutput></cfoutput>&nbsp;&nbsp;
        </td>
	</tr>
</table>
<table class="dpm" align="center">
    <tr>
    	<td valign="top" class="dpml">
        	<cfform name="upd_piece_relation" method="post" action="#request.self#?fuseaction=prod.emptypopup_cnt_ezgi_import_creative_workcube">
            	<cf_form_box>
                	<cfinput name="iid_list" id="iid_list" value="#attributes.type#_#attributes.iid#" type="hidden">
               		<cfinput name="design_id" id="design_id" value="#attributes.design_id#" type="hidden">
                 	<cfinput name="upd_type_#attributes.type#_#attributes.iid#" id="upd_type_#attributes.type#_#attributes.iid#" value="#attributes.upd_type#" type="hidden">
                  	<cfinput name="stock_id_#attributes.type#_#attributes.iid#" id="stock_id_#attributes.type#_#attributes.iid#" value="#attributes.stock_id#" type="hidden">
                    <cfinput name="select_#attributes.type#_#attributes.iid#" id="select_#attributes.type#_#attributes.iid#" value="1" type="hidden">
                    <cfinput name="popup_window" value="1" type="hidden">
                    <table style="width:100%">
                    	<tr>
                       		<td style="width:75%"></td>
                         	<td style="text-align:right; vertical-align:middle; height:25px">
                                <cfsavecontent variable="vazgec"><cf_get_lang dictionary_id="57462.Vazgeç"></cfsavecontent>
                                <cfsavecontent variable="esitle"><cf_get_lang dictionary_id="58783.Eşitle"></cfsavecontent>
                            	<cfinput type="button" value="#vazgec#" name="cnc_buton" onClick="window.close();">&nbsp;
                              	<cfinput type="submit" value="#esitle#" name="upd_buton" onClick="upd_kontrol();">&nbsp;
                         	</td>
                      	</tr>
                  	</table>
                </cf_form_box>
                <cfif get_workcube_product_tree.recordcount>
                	<cfquery name="get_product_tree" dbtype="query">
                     	SELECT * FROM get_product_tree ORDER BY OPERATION_TYPE_ID DESC, RELATED_ID
                   	</cfquery>
                    <cfoutput query="get_product_tree">
                    	<cfset 'R_AMOUNT_#RELATED_ID#' = AMOUNT>
                        <cfset 'O_AMOUNT_#OPERATION_TYPE_ID#' =AMOUNT>
                    </cfoutput>
                	<cfset stock_id_list = ValueList(get_product_tree.related_id)>
                    <cfset operation_type_id_list = ValueList(get_product_tree.OPERATION_TYPE_ID)>
                    <cfif ListLen(stock_id_list)>
                        <cfquery name="get_stock_info" datasource="#dsn1#">
                            SELECT        
                                S.PRODUCT_ID, 
                                S.STOCK_ID,
                                P.PRODUCT_CODE, 
                                P.PRODUCT_NAME,
                                PU.MAIN_UNIT
                            FROM            
                                STOCKS AS S INNER JOIN
                                PRODUCT AS P ON S.PRODUCT_ID = P.PRODUCT_ID INNER JOIN
                                PRODUCT_UNIT AS PU ON P.PRODUCT_ID = PU.PRODUCT_ID
                            WHERE        
                                S.STOCK_ID IN (#stock_id_list#) AND 
                                PU.IS_MAIN = 1
                        </cfquery>
                        <cfoutput query="get_stock_info">
                        	<cfset 'A_PRODUCT_NAME_#STOCK_ID#' = PRODUCT_NAME>
                            <cfset 'A_PRODUCT_CODE_#STOCK_ID#' = PRODUCT_CODE>
                            <cfset 'A_MAIN_UNIT_#STOCK_ID#' = MAIN_UNIT>
                            <cfset 'A_PRODUCT_ID_#STOCK_ID#' = PRODUCT_ID>
                        </cfoutput>
                        <cfquery name="get_operation_info" datasource="#dsn3#">
                        	SELECT OPERATION_TYPE_ID, OPERATION_TYPE FROM OPERATION_TYPES WHERE OPERATION_TYPE_ID IN (#operation_type_id_list#)
                        </cfquery>
                        <cfoutput query="get_operation_info">
                        	<cfset 'A_OPERATION_TYPE_#OPERATION_TYPE_ID#' = OPERATION_TYPE>
                        </cfoutput>
                    </cfif>
                    <table style="width:100%;height:400px" cellpadding="0" cellspacing="0" border="1" bordercolor="silver">
                        <tr>
                            <td style="width:50%; height:400px; vertical-align:top">
                                <table style="width:100%;">
                               		<tr valign="top">
                                        <td style="text-align:center;width:100%; height:25px; vertical-align:middle; font-family:Verdana, Geneva, sans-serif; font-size:12px">
                                        	<strong><cf_get_lang dictionary_id="105.Tasarım Tanımları"></strong>
                                        </td>
                                   	</tr>
                                    <tr valign="top">
                                        <td width="100%" valign="top">
                                        	<cf_form_list id="table1">
                                        		<thead>
                                                	<tr style="height:30px">
                                                            <th style="text-align:right;width:30px"><cf_get_lang dictionary_id="58577.Sıra"></th>
                                                            <th style="text-align:left;width:325px"><cf_get_lang dictionary_id="44019.Ürün"></th>
                                                            <th style="text-align:right;width:90px"><cf_get_lang dictionary_id="57635.Miktar"></th>  
                                                            <th style="text-align:left;width:30px"><cf_get_lang dictionary_id="57636.Birim"></th>             
                                                   	</tr>
                                               	</thead>
                                           		<tbody>
                                              	<cfoutput query="get_product_tree">
                                                 	<tr>
                                                     	<td style="text-align:right">#currentrow#&nbsp;</td>
                                                        <cfif RELATED_ID eq 0>
                                                        	<td nowrap <cfif Len(Evaluate('A_OPERATION_TYPE_#OPERATION_TYPE_ID#')) gt 50>title="#Evaluate('A_OPERATION_TYPE_#OPERATION_TYPE_ID#')#"</cfif> style="width:190px">
                                                                &nbsp;#Left(Evaluate('A_OPERATION_TYPE_#OPERATION_TYPE_ID#'),50)#
                                                                <cfif len(Evaluate('A_OPERATION_TYPE_#OPERATION_TYPE_ID#')) gte 50>...</cfif>
                                                                    
                                                            </td>
                                                        <cfelse>
                                                            <td nowrap <cfif Len(Evaluate('A_PRODUCT_NAME_#RELATED_ID#')) gt 50>title="#Evaluate('A_PRODUCT_NAME_#RELATED_ID#')#"</cfif> style="width:190px">
                                                                &nbsp;#Left(Evaluate('A_PRODUCT_NAME_#RELATED_ID#'),50)#
                                                                <cfif len(Evaluate('A_PRODUCT_NAME_#RELATED_ID#')) gte 50>...</cfif>
                                                                    
                                                            </td>
                                                        </cfif>
                                                        <cfif RELATED_ID eq 0>
                                                     		<td style="text-align:right;;<cfif not isdefined('P_AMOUNT_#OPERATION_TYPE_ID#') or (isdefined('P_AMOUNT_#OPERATION_TYPE_ID#') and TlFormat(Evaluate('P_AMOUNT_#OPERATION_TYPE_ID#'),8) neq TLFormat(AMOUNT,8))>color:red</cfif>">#TLFormat(AMOUNT,8)#&nbsp;</td>	
                                                        <cfelse>
                                                        	<td style="text-align:right;;<cfif not isdefined('M_AMOUNT_#RELATED_ID#') or (isdefined('M_AMOUNT_#RELATED_ID#') and TlFormat(Evaluate('M_AMOUNT_#RELATED_ID#'),8) neq TLFormat(AMOUNT,8))>color:red</cfif>">#TLFormat(AMOUNT,8)#&nbsp;</td>
                                                        </cfif>
                                                        <cfif RELATED_ID eq 0>
                                                        	<td></td>
                                                        <cfelse>
                                                   			<td style="text-align:left;" <cfif len(Evaluate('A_MAIN_UNIT_#RELATED_ID#')) gte 2>title="#Evaluate('A_MAIN_UNIT_#RELATED_ID#')#"</cfif>>&nbsp;#Left(Evaluate('A_MAIN_UNIT_#RELATED_ID#'),2)#<cfif len(Evaluate('A_MAIN_UNIT_#RELATED_ID#')) gt 2>.</cfif></td>
                                                        </cfif>
                                                  	</tr>
                                              	</cfoutput>
                                           		</tbody>
                                        	</cf_form_list>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <cfset stock_id_list = ValueList(get_workcube_product_tree.related_id)>
							<cfset operation_type_id_list = ValueList(get_workcube_product_tree.OPERATION_TYPE_ID)>
                            <cfif ListLen(stock_id_list)>
                                <cfquery name="get_stock_info" datasource="#dsn1#">
                                    SELECT        
                                        S.PRODUCT_ID, 
                                        S.STOCK_ID,
                                        P.PRODUCT_CODE, 
                                        P.PRODUCT_NAME,
                                        PU.MAIN_UNIT
                                    FROM            
                                        STOCKS AS S INNER JOIN
                                        PRODUCT AS P ON S.PRODUCT_ID = P.PRODUCT_ID INNER JOIN
                                        PRODUCT_UNIT AS PU ON P.PRODUCT_ID = PU.PRODUCT_ID
                                    WHERE        
                                        S.STOCK_ID IN (#stock_id_list#) AND 
                                        PU.IS_MAIN = 1
                                </cfquery>
                                <cfoutput query="get_stock_info">
                                    <cfset 'PRODUCT_NAME_#STOCK_ID#' = PRODUCT_NAME>
                                    <cfset 'PRODUCT_CODE_#STOCK_ID#' = PRODUCT_CODE>
                                    <cfset 'MAIN_UNIT_#STOCK_ID#' = MAIN_UNIT>
                                    <cfset 'PRODUCT_ID_#STOCK_ID#' = PRODUCT_ID>
                                </cfoutput>
                                <cfquery name="get_operation_info" datasource="#dsn3#">
                                    SELECT OPERATION_TYPE_ID, OPERATION_TYPE FROM OPERATION_TYPES WHERE OPERATION_TYPE_ID IN (#operation_type_id_list#)
                                </cfquery>
                                <cfoutput query="get_operation_info">
                                    <cfset 'OPERATION_TYPE_#OPERATION_TYPE_ID#' = OPERATION_TYPE>
                                </cfoutput>
                           	</cfif>
                            <td width="50%" height="100%" valign="top">
                                <table style="width:100%; height:400px">
                                	<tr valign="top">
                                        <td style="text-align:center;width:100%; height:25px; vertical-align:middle; font-family:Verdana, Geneva, sans-serif; font-size:12px">
                                        	<strong><cf_get_lang dictionary_id="106.ERP Ürün Ağacı Tanımları"></strong>
                                        </td>
                                   	</tr>
                                    <tr valign="top">
                                        <td width="100%" valign="top">
                                        	<cf_form_list id="table2">
                                        		<thead>
                                                 	<tr style="height:30px">
                                                    	<th style="text-align:right;width:30px"><cf_get_lang dictionary_id="58577.Sıra"></th>
                                                        <th style="text-align:left;width:325px"><cf_get_lang dictionary_id="44019.Ürün"></th>
                                                        <th style="text-align:right;width:90px"><cf_get_lang dictionary_id="57635.Miktar"></th>  
                                                        <th style="text-align:left;width:30px"><cf_get_lang dictionary_id="57636.Birim"></th>              
                                                 	</tr>
                                             	</thead>
                                              	<tbody>
                                             	<cfoutput query="get_workcube_product_tree">
                                                 	<tr>
                                                   		<td style="text-align:right">#currentrow#&nbsp;</td>
                                                      	<cfif RELATED_ID eq 0>
                                                        	<td nowrap <cfif Len(Evaluate('OPERATION_TYPE_#OPERATION_TYPE_ID#')) gt 50>title="#Evaluate('OPERATION_TYPE_#OPERATION_TYPE_ID#')#"</cfif> style="width:190px;<cfif not isdefined('A_OPERATION_TYPE_#OPERATION_TYPE_ID#')>color:red</cfif>">
                                                                &nbsp;#Left(Evaluate('OPERATION_TYPE_#OPERATION_TYPE_ID#'),50)#
                                                                <cfif len(Evaluate('OPERATION_TYPE_#OPERATION_TYPE_ID#')) gte 50>...</cfif>
                                                                    
                                                            </td>
                                                        <cfelse>
                                                            <td nowrap <cfif Len(Evaluate('PRODUCT_NAME_#RELATED_ID#')) gt 50>title="#Evaluate('PRODUCT_NAME_#RELATED_ID#')#"</cfif> style="width:190px">
                                                                &nbsp;#Left(Evaluate('PRODUCT_NAME_#RELATED_ID#'),50)#
                                                                <cfif len(Evaluate('PRODUCT_NAME_#RELATED_ID#')) gte 50>...</cfif>
                                                                    
                                                            </td>
                                                        </cfif>
                                                        <cfif RELATED_ID eq 0>
                                                     		<td style="text-align:right;;<cfif not isdefined('O_AMOUNT_#OPERATION_TYPE_ID#') or (isdefined('O_AMOUNT_#OPERATION_TYPE_ID#') and TlFormat(Evaluate('O_AMOUNT_#OPERATION_TYPE_ID#'),8) neq TLFormat(AMOUNT,8))>color:red</cfif>">#TLFormat(AMOUNT,8)#&nbsp;</td>	
                                                        <cfelse>
                                                        	<td style="text-align:right;;<cfif not isdefined('R_AMOUNT_#RELATED_ID#') or (isdefined('R_AMOUNT_#RELATED_ID#') and TlFormat(Evaluate('R_AMOUNT_#RELATED_ID#'),8) neq TLFormat(AMOUNT,8))>color:red</cfif>">#TLFormat(AMOUNT,8)#&nbsp;</td>
                                                        </cfif>
                                                        <cfif RELATED_ID eq 0>
                                                        	<td></td>
                                                        <cfelse>
                                                      		<td style="text-align:left;" <cfif len(Evaluate('MAIN_UNIT_#RELATED_ID#')) gte 2>title="#Evaluate('MAIN_UNIT_#RELATED_ID#')#"</cfif>>&nbsp;#Left(Evaluate('MAIN_UNIT_#RELATED_ID#'),2)#<cfif len(Evaluate('MAIN_UNIT_#RELATED_ID#')) gt 2>.</cfif></td>
                                                      	</cfif>
                                                   	</tr>
                                              	</cfoutput>
                                           		</tbody>
                                        	</cf_form_list>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </cfif>
         	</cfform>
     	</td>
 	</tr>
</table>
