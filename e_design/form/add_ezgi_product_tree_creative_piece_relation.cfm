<!---
    File: add_ezgi_product_tree_creative_piece_relation.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.urun" default="">
<cfparam name="attributes.pid" default="">
<cfparam name="attributes.sid" default="">
<cfif isdefined('attributes.piece_id') and len(attributes.piece_id)>
    <cfquery name="get_name" datasource="#dsn3#">
        SELECT        
            EP.DESIGN_ID, 
            EP.PIECE_NAME, 
            EP.PIECE_COLOR_ID, 
            EC.COLOR_NAME, 
            ED.DESIGN_NAME
        FROM            
            EZGI_DESIGN_PIECE AS EP WITH (NOLOCK) INNER JOIN
            EZGI_COLORS AS EC WITH (NOLOCK) ON EP.PIECE_COLOR_ID = EC.COLOR_ID INNER JOIN
            EZGI_DESIGN AS ED WITH (NOLOCK) ON EP.DESIGN_ID = ED.DESIGN_ID
        WHERE        
            EP.PIECE_ROW_ID = #attributes.piece_id#
    </cfquery>
    <cfset urun_adi = '#get_name.DESIGN_NAME# #get_name.PIECE_NAME#'> <!---Parça Ürün Adı Tanımı--->
    <cfsavecontent variable="head_name"><cf_get_lang dictionary_id="45.Parça"></cfsavecontent>
    <cfif len(get_name.COLOR_NAME)>
        <cfset urun_adi = "#urun_adi# (#get_name.COLOR_NAME#)">
    </cfif>
<cfelseif isdefined('attributes.package_id') and len(attributes.package_id)>
	<cfquery name="get_name" datasource="#dsn3#">
		SELECT PACKAGE_NAME FROM EZGI_DESIGN_PACKAGE_ROW WITH (NOLOCK) WHERE PACKAGE_ROW_ID = #attributes.package_id#
  	</cfquery>
    <cfset urun_adi = get_name.PACKAGE_NAME> <!---Paket Ürün Adı Tanımı--->
    <cfsavecontent variable="head_name"><cf_get_lang dictionary_id="100.Paket"></cfsavecontent>
<cfelseif isdefined('attributes.main_id') and len(attributes.main_id)>
	<cfquery name="get_name" datasource="#dsn3#">
    	SELECT DESIGN_MAIN_NAME FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #attributes.main_id#
  	</cfquery>
    <cfset urun_adi = get_name.DESIGN_MAIN_NAME> <!---Modül Ürün Adı Tanımı--->
    <cfsavecontent variable="head_name"><cf_get_lang dictionary_id="141.Modül"></cfsavecontent>
</cfif>
<cfsavecontent variable="message"><cfoutput>#head_name# <cf_get_lang dictionary_id="34312.İlişki Ekle"> - #urun_adi#</cfoutput></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#message#" collapsable="0" resize="0" scroll="1">
		<cfform name="add_piece_relation" method="post" action="">
        	<cfif isdefined('attributes.piece_id') and len(attributes.piece_id)>
             	<cfinput name="piece_id" id="piece_id" value="#attributes.piece_id#" type="hidden">
           		<cfinput name="piece_name" id="piece_name" value="#urun_adi#" type="hidden">
        	<cfelseif isdefined('attributes.package_id') and len(attributes.package_id)>
            	<cfinput name="package_id" id="package_id" value="#attributes.package_id#" type="hidden">
          		<cfinput name="package_name" id="package_name" value="#urun_adi#" type="hidden">
           	<cfelseif isdefined('attributes.main_id') and len(attributes.main_id)>
            	<cfinput name="main_id" id="main_id" value="#attributes.main_id#" type="hidden">
          		<cfinput name="main_name" id="main_name" value="#urun_adi#" type="hidden">
           	</cfif>
            <cf_box_elements>
            	<div class="col col-12">
                    <div class="form-group" id="urun">
                        <div class="input-group">
                        	<cfsavecontent variable="message1"><cf_get_lang dictionary_id="58221.Ürün Adı"></cfsavecontent>
                         	<input type="text" name="urun" id="urun" value="<cfoutput>#attributes.urun#</cfoutput>" style="width:280px; vertical-align:middle">
                          	<input type="hidden" name="pid" id="pid" value="<cfoutput>#attributes.pid#</cfoutput>">
                         	<input type="hidden" name="sid" id="sid" value="<cfoutput>#attributes.sid#</cfoutput>">
                            <span class="input-group-addon icon-ellipsis btnPointer" style="cursor:pointer" onclick="relation_product_row();" title="<cf_get_lang_main no='170.Ekle'>"></span>
                       </div>
                    </div>
                </div>
          	</cf_box_elements>
            
           	<cf_box_footer>
            	<cfsavecontent variable="kontrol"><cf_get_lang dictionary_id='52787.Kontrol Et'></cfsavecontent>
				<cfsavecontent variable="urun_list"><cf_get_lang dictionary_id='58942.Ürün Listesi'></cfsavecontent>
         		<cfif isdefined('attributes.sid') and len(attributes.sid)>
                	<cf_workcube_buttons 
                  		is_upd='0' 
                    	add_function='kontrol(4)'
                        is_cancel='1'>
               	<cfelseif isdefined('attributes.main_id') and len(attributes.main_id)>
                  	<cf_workcube_buttons 
                  		is_upd='0' 
                    	add_function='kontrol(1)'
                        insert_info="#kontrol#"
                        insert_alert = '#urun_list#'
                        is_cancel='1'>
              	<cfelseif isdefined('attributes.package_id') and len(attributes.package_id)> 
                  	<cf_workcube_buttons 
                  		is_upd='0' 
                    	add_function='kontrol(2)'
                        insert_info="#kontrol#"
                        insert_alert = '#urun_list#'
                        is_cancel='1'>
             	<cfelse>
                  	<cf_workcube_buttons 
                  		is_upd='0' 
                    	add_function='kontrol(3)'
                        insert_info="#kontrol#"
                        insert_alert = '#urun_list#'
                        is_cancel='1'>  	
           		</cfif>
      		</cf_box_footer>
            <br>
            <cf_box_elements>
           		<cfif isdefined('attributes.sid') and len(attributes.sid)>
                	<cfif isdefined('attributes.piece_id') and len(attributes.piece_id)>
                        <cfset attributes.design_piece_row_id = attributes.piece_id>
                    <cfelseif isdefined('attributes.package_id') and len(attributes.package_id)>
                    	<cfset attributes.design_package_row_id = attributes.package_id>
                   	<cfelseif isdefined('attributes.main_id') and len(attributes.main_id)>
                    	<cfset attributes.design_main_row_id = attributes.main_id>
                    </cfif>
                	<cfinclude template="../query/get_ezgi_product_tree_creative_material.cfm">
                    <cfquery name="get_material" dbtype="query">
                    	SELECT * FROM get_material ORDER BY PRODUCT_NAME
                    </cfquery>
                    <cfquery name="get_karma" datasource="#dsn3#">
                    	SELECT 
                        	KP.STOCK_ID, 
                            KP.PRODUCT_AMOUNT
						FROM     
                        	#dsn1_alias#.KARMA_PRODUCTS AS KP WITH (NOLOCK) INNER JOIN
                  			STOCKS AS S WITH (NOLOCK) ON KP.KARMA_PRODUCT_ID = S.PRODUCT_ID
						WHERE  
                        	S.IS_KARMA = 1 AND 
                            S.STOCK_ID = #attributes.sid#
                    </cfquery>
                    <cfquery name="get_product_tree" datasource="#dsn3#">
                    	SELECT 
                        	STOCK_CODE, 
                           	PRODUCT_NAME,
                            BIRIM,
                            SUM(AMOUNT) AS AMOUNT
                       	FROM
                        	(
                            <cfif get_karma.recordcount>
                            	<cfloop query="get_karma">
                                    SELECT       
                                        STOCK_CODE, 
                                        PRODUCT_NAME,
                                        (
                                            SELECT        
                                                MAIN_UNIT
                                            FROM           
                                                PRODUCT_UNIT WITH (NOLOCK)
                                            WHERE        
                                                PRODUCT_UNIT_STATUS = 1 AND 
                                                PRODUCT_ID = E.PRODUCT_ID AND 
                                                IS_MAIN = 1
                                        ) AS BIRIM,
                                        AMOUNT * AMOUNT2 * AMOUNT3 * AMOUNT4 * AMOUNT5 * #get_karma.PRODUCT_AMOUNT# AS AMOUNT
                                    FROM            
                                        EZGI_PRODUCT_TREE_BOM1 AS E WITH (NOLOCK)
                                    WHERE        
                                        STOCK_ID = #get_karma.STOCK_ID#
                                        AND IS_PRODUCTION = 0
                                  	<cfif get_karma.currentrow lt get_karma.recordcount>UNION ALL</cfif>
                             	</cfloop>
                            <cfelse>
                                SELECT       
                                    STOCK_CODE, 
                                    PRODUCT_NAME,
                                    (
                                        SELECT        
                                            MAIN_UNIT
                                        FROM           
                                            PRODUCT_UNIT WITH (NOLOCK)
                                        WHERE        
                                            PRODUCT_UNIT_STATUS = 1 AND 
                                            PRODUCT_ID = E.PRODUCT_ID AND 
                                            IS_MAIN = 1
                                    ) AS BIRIM,
                                    AMOUNT * AMOUNT2 * AMOUNT3 * AMOUNT4 * AMOUNT5 AS AMOUNT
                                FROM            
                                    EZGI_PRODUCT_TREE_BOM1 AS E WITH (NOLOCK)
                                WHERE        
                                    STOCK_ID = #attributes.sid#
                                    AND IS_PRODUCTION = 0
                         	</cfif>
                       		) AS TBL
                       	GROUP BY
                        	STOCK_CODE, 
                           	PRODUCT_NAME,
                            BIRIM    
                      	ORDER BY
                        	PRODUCT_NAME
                    </cfquery>
                    <table style="width:100%; height:100%" cellpadding="0" cellspacing="0" border="1" bordercolor="silver">
                        <tr>
                            <td style="width:50%; height:100%; vertical-align:top">
                                <table style="width:100%;">
                               		<tr valign="top">
                                        <td style="text-align:center;width:100%; height:25px; vertical-align:middle; font-family:Verdana, Geneva, sans-serif; font-size:12px">
                                        	<strong><cf_get_lang dictionary_id="105.Tasarım Tanımları"></strong>
                                        </td>
                                   	</tr>
                                    <tr valign="top">
                                        <td width="100%" valign="top">
                                        	<cf_flat_list>
                                        		<thead>
                                                	<tr style="height:30px">
                                                            <th style="text-align:right;width:30px"><cf_get_lang dictionary_id="58577.Sıra"></th>
                                                            <th style="text-align:left;width:365px"><cf_get_lang dictionary_id="57657.Ürün"></th>
                                                            <th style="text-align:right;width:50px"><cf_get_lang dictionary_id="57635.Miktar"></th>  
                                                            <th style="text-align:left;width:30px"><cf_get_lang dictionary_id="57636.Birim"></th>             
                                                   	</tr>
                                               	</thead>
                                           		<tbody>
                                              	<cfoutput query="get_material">
                                                 	<tr>
                                                     	<td style="text-align:right">#currentrow#&nbsp;</td>
                                                      	<td nowrap <cfif Len(PRODUCT_NAME) gt 50>title="#PRODUCT_NAME#"</cfif> style="width:190px">
                                                          	&nbsp;#Left(PRODUCT_NAME,50)#<cfif len(PRODUCT_NAME) gte 50>...</cfif>
                                                                
                                                    	</td>
                                                    	<td style="text-align:right;">#AmountFormat(AMOUNT)#&nbsp;</td>
                                                   		<td style="text-align:left;" <cfif len(MAIN_UNIT) gte 2>title="#MAIN_UNIT#"</cfif>>&nbsp;#Left(MAIN_UNIT,2)#<cfif len(MAIN_UNIT) gt 2>.</cfif></td>
                                                  	</tr>
                                              	</cfoutput>
                                           		</tbody>
                                        	</cf_flat_list>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td width="50%" height="100%" valign="top">
                                <table style="width:100%; height:400px">
                                	<tr valign="top">
                                        <td style="text-align:center;width:100%; height:25px; vertical-align:middle; font-family:Verdana, Geneva, sans-serif; font-size:12px">
                                        	<strong><cf_get_lang dictionary_id="106.ERP Ürün Ağacı Tanımları"></strong>
                                        </td>
                                   	</tr>
                                    <tr valign="top">
                                        <td width="100%" valign="top">
                                        	<cf_flat_list>
                                        		<thead>
                                                 	<tr style="height:30px">
                                                    	<th style="text-align:right;width:30px"><cf_get_lang dictionary_id="58577.Sıra"></th>
                                                     	<th style="text-align:left;width:365px"><cf_get_lang dictionary_id="57657.Ürün"></th>
                                                     	<th style="text-align:right;width:50px"><cf_get_lang dictionary_id="57635.Miktar"></th>  
                                                     	<th style="text-align:left;width:30px"><cf_get_lang dictionary_id="57636.Birim"></th>             
                                                 	</tr>
                                             	</thead>
                                              	<tbody>
                                             	<cfoutput query="get_product_tree">
                                                 	<tr>
                                                   		<td style="text-align:right">#currentrow#&nbsp;</td>
                                                      	<td nowrap <cfif Len(PRODUCT_NAME) gt 50>title="#PRODUCT_NAME#"</cfif> style="width:190px">
                                                          	&nbsp;#Left(PRODUCT_NAME,50)#<cfif len(PRODUCT_NAME) gte 50>...</cfif>
                                                      	</td>
                                                     	<td style="text-align:right;">#AmountFormat(AMOUNT)#&nbsp;</td>
                                                        <cfif isdefined('get_product_tree.BIRIM')>
                                                      		<td style="text-align:left;" <cfif len(BIRIM) gte 2>title="#BIRIM#"</cfif>>&nbsp;#Left(BIRIM,2)#<cfif len(BIRIM) gt 2>.</cfif></td>
                                                        <cfelseif isdefined('get_product_tree.MAIN_UNIT')>
                                                        	<td style="text-align:left;" <cfif len(MAIN_UNIT) gte 2>title="#MAIN_UNIT#"</cfif>>&nbsp;#Left(MAIN_UNIT,2)#<cfif len(MAIN_UNIT) gt 2>.</cfif></td>
                                                        <cfelse>
                                                        	<td style="text-align:left;">&nbsp;</td>
                                                        </cfif>
                                                   	</tr>
                                              	</cfoutput>
                                           		</tbody>
                                        	</cf_flat_list>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </cfif>
          	</cf_box_elements>
        </cfform>
  	</cf_box>
</div>
<script type="text/javascript">
	function relation_product_row(product_type, creative_id, satir_no)
	{
		<cfif isdefined('attributes.piece_id') and len(attributes.piece_id)>
			windowopen("<cfoutput>#request.self#?fuseaction=objects.popup_ezgi_product_names&list_order_no=8&product_id=add_piece_relation.pid&field_id=add_piece_relation.sid&field_name=add_piece_relation.urun&keyword=#urun_adi#</cfoutput>",'list');
		<cfelseif isdefined('attributes.package_id') and len(attributes.package_id)>
			windowopen("<cfoutput>#request.self#?fuseaction=objects.popup_ezgi_product_names&list_order_no=7&product_id=add_piece_relation.pid&field_id=add_piece_relation.sid&field_name=add_piece_relation.urun&keyword=#urun_adi#&package_id=#attributes.package_id#</cfoutput>",'list');
		<cfelseif isdefined('attributes.main_id') and len(attributes.main_id)>
			windowopen("<cfoutput>#request.self#?fuseaction=objects.popup_ezgi_product_names&list_order_no=6&product_id=add_piece_relation.pid&field_id=add_piece_relation.sid&field_name=add_piece_relation.urun&keyword=#urun_adi#&main_id=#attributes.main_id#</cfoutput>",'list');
		</cfif>
	}
	function kontrol(type)
	{
		if(document.getElementById('sid').value == '')
		{
			alert('Önce Ürün Seçiniz !');	
			document.getElementById('piece_boy').focus();
			return false;
		}
		else
		{
			if(type==1)
			{
				
			<cfif isdefined('attributes.main_id') and len(attributes.main_id)>
            	document.getElementById("add_piece_relation").action = "<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_product_tree_creative_piece_relation&main_id=#attributes.main_id#</cfoutput>";
			</cfif>
			}
			else if(type==2)
			{
			<cfif isdefined('attributes.package_id') and len(attributes.package_id)>
            	document.getElementById("add_piece_relation").action = "<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_product_tree_creative_piece_relation&package_id=#attributes.package_id#</cfoutput>";
			</cfif>
			}
			else if(type==3)
			{
			<cfif isdefined('attributes.piece_id') and len(attributes.piece_id)>
              	document.getElementById("add_piece_relation").action = "<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_product_tree_creative_piece_relation&piece_id=#attributes.piece_id#</cfoutput>";	
          	</cfif>
			}
			else
			{
				document.getElementById("add_piece_relation").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_add_ezgi_product_tree_creative_piece_relation";
			}
			document.getElementById("add_piece_relation").submit();	
		}
	}
</script>