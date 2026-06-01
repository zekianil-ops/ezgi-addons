<!---
    File: dsp_ezgi_private_design_piece_row.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.piece_type_select" default=""> 
<cfquery name="get_piece_row" datasource="#dsn3#">
	SELECT DISTINCT 
      	EDP.AGIRLIK, 
        EDP.BOYU, 
        EDP.DESIGN_ID, 
        EDP.DESIGN_MAIN_ROW_ID, 
        EDP.DESIGN_PACKAGE_ROW_ID, 
        EDP.ENI, 
        EDP.IS_FLOW_DIRECTION, 
        EDP.KALINLIK, 
        EDP.KESIM_BOYU, 
        EDP.KESIM_ENI, 
        EDP.MASTER_PRODUCT_ID, 
        EDP.MATERIAL_ID, 
        EDP.PACKAGE_IS_MASTER, 
        EDP.PACKAGE_PARTNER_ID, 
        EDP.PIECE_AMOUNT, 
        EDP.PIECE_CODE, 
        EDP.PIECE_COLOR_ID, 
        EDP.PIECE_DETAIL, 
        EDP.PIECE_IS_MASTER, 
       	EDP.PIECE_NAME, 
        EDP.PIECE_PARTNER_ID, 
        EDP.PIECE_RELATED_ID, 
        EDP.PIECE_ROW_ID, 
        EDP.PIECE_STATUS, 
        EDP.PIECE_TYPE, 
        EDP.TRIM_SIZE, 
        EDP.TRIM_TYPE, 
        EDP.PIECE_SPECT_RELATED_ID, 
        EDMR.DESIGN_MAIN_NAME, 
        EDPK.PACKAGE_NUMBER, 
        PPD.PROPERTY_DETAIL AS KALINLIK_, 
        ISNULL(EPR_COUNT.SAYI, 0) AS ORTAK_PARCA, 
        ISNULL(ST.IS_PROTOTYPE, 0) AS IS_PROTOTYPE, 
      	ISNULL(USED_AMT.TOTAL_AMOUNT, 0) AS USED_AMOUNT
	FROM            
    	EZGI_DESIGN_PIECE AS EDP WITH (NOLOCK) LEFT OUTER JOIN
     	EZGI_DESIGN_MAIN_ROW AS EDMR WITH (NOLOCK) ON EDP.DESIGN_MAIN_ROW_ID = EDMR.DESIGN_MAIN_ROW_ID LEFT OUTER JOIN
        EZGI_DESIGN_PACKAGE AS EDPK WITH (NOLOCK) ON EDP.DESIGN_PACKAGE_ROW_ID = EDPK.PACKAGE_ROW_ID LEFT OUTER JOIN
        #dsn1_alias#.PRODUCT_PROPERTY_DETAIL AS PPD WITH (NOLOCK) ON EDP.KALINLIK = PPD.PROPERTY_DETAIL_ID LEFT OUTER JOIN
     	(
        	SELECT        
            	PIECE_RELATED_ID, 
                COUNT(*) AS SAYI
        	FROM            
            	EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
         	WHERE        
            	PIECE_TYPE <> 4
           	GROUP BY 
            	PIECE_RELATED_ID
     	) AS EPR_COUNT ON EPR_COUNT.PIECE_RELATED_ID = EDP.PIECE_RELATED_ID LEFT OUTER JOIN
   		(
        	SELECT        
            	STOCK_ID,
                IS_PROTOTYPE
          	FROM            
            	STOCKS WITH (NOLOCK)
     	) AS ST ON ST.STOCK_ID = EDP.PIECE_RELATED_ID LEFT OUTER JOIN
    	(
        	SELECT        
            	EPR.RELATED_PIECE_ROW_ID, 
                SUM(EPR.AMOUNT * EP.PIECE_AMOUNT) AS TOTAL_AMOUNT
        	FROM            
            	EZGI_DESIGN_PIECE_ROW AS EPR WITH (NOLOCK) INNER JOIN
             	EZGI_DESIGN_PIECE_ROWS AS EP WITH (NOLOCK) ON EPR.PIECE_ROW_ID = EP.PIECE_ROW_ID
         	GROUP BY 
            	EPR.RELATED_PIECE_ROW_ID
      	) AS USED_AMT ON USED_AMT.RELATED_PIECE_ROW_ID = EDP.PIECE_ROW_ID
  	WHERE 
    	<cfif isdefined('attributes.design_package_row_id')>
    		EDP.DESIGN_PACKAGE_ROW_ID = #attributes.design_package_row_id#
       	<cfelseif isdefined('attributes.design_main_row_id')>
        	EDP.DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
        <cfelse>
        	EDP.DESIGN_ID = #attributes.design_id#
        </cfif>
        <cfif len(attributes.piece_type_select)>
        	AND EDP.PIECE_TYPE = #attributes.piece_type_select#
        </cfif>
  	ORDER BY
    	<cfif attributes.sort_id eq 5>
        	DESIGN_MAIN_NAME,PIECE_CODE
        <cfelseif attributes.sort_id eq 4> 
        	DESIGN_MAIN_NAME,PACKAGE_NUMBER
        <cfelseif attributes.sort_id eq 3>
        	PIECE_COLOR_ID,DESIGN_MAIN_NAME
        <cfelseif attributes.sort_id eq 2>
        	DESIGN_MAIN_NAME,PIECE_NAME
        <cfelseif attributes.sort_id eq 1>
        	BOYU
        <cfelseif attributes.sort_id eq 0>
        	PIECE_TYPE,DESIGN_MAIN_NAME
       	<cfelseif attributes.sort_id eq 6>
        	ENI,DESIGN_MAIN_NAME
        <cfelseif attributes.sort_id eq 7>
        	KALINLIK,DESIGN_MAIN_NAME
        <cfelseif attributes.sort_id eq 8>
        	PIECE_AMOUNT,DESIGN_MAIN_NAME
        <cfelseif attributes.sort_id eq 9>
        	IS_FLOW_DIRECTION,DESIGN_MAIN_NAME
        </cfif>    
</cfquery>
<!---<cfdump var="#get_piece_row#">--->
<!---ERP üzerinde Parça Stok Kartları da açılacaksa Aynı İsimli Kart Varmı--->
<cfif get_design.PROCESS_ID eq 1>
	<cfoutput query="get_piece_row">
        <cfset renk_adi = ''>
        <cfif isdefined('COLOR_NAME_#PIECE_COLOR_ID#')><cfset renk_adi = Evaluate('COLOR_NAME_#PIECE_COLOR_ID#')></cfif>
        <cfset urun_adi = '#get_design.design_name# #PIECE_NAME# (#renk_adi#)'> 
		<cfquery name="get_same_product" datasource="#dsn3#">
        	SELECT STOCK_ID FROM STOCKS WHERE PRODUCT_NAME = '#urun_adi#'
        </cfquery>
        <cfif get_same_product.recordcount>
			<cfset 'same#PIECE_ROW_ID#' = urun_adi>
        </cfif>
	</cfoutput>
</cfif>
<cfsavecontent  variable="pieces">
	<cf_get_lang dictionary_id='61.Parçalar'>
</cfsavecontent>
<cf_seperator title="#pieces#" id="piece_" is_closed="1">
<div id="piece_">
    <cf_form_list id="table6">
        <thead>
        	<tr>
                <th style="text-align:right;height:15px;background-color:gainsboro; border:solid; border-color:white" colspan="15">
                	<cfoutput>
                   		<span class="icn-md icon-trash-o" style="cursor:pointer" onclick="design_delete_row();" title="<cf_get_lang dictionary_id='57463.Sil'>"></span>&nbsp;
                    <cfif isdefined('attributes.design_main_row_id')>
                    	<span class="icn-md icon-copy" style="cursor:pointer" onclick="cpy_piece();" title="<cf_get_lang dictionary_id='57476.Kopyala '>"></span>&nbsp;
                        <span class="icn-md icon-add" style="cursor:pointer" onclick="add_piece_row();" title="<cf_get_lang dictionary_id='44630.Ekle'>"></span>&nbsp;
                   	</cfif>
                  	<cfif not isdefined('attributes.design_package_row_id') and isdefined('attributes.design_main_row_id')>
                        <span class="icn-md icon-exchange" style="cursor:pointer" onclick="add_import_piece_row();" title="<cf_get_lang dictionary_id='58568.Transfer'>"></span>&nbsp;
                    </cfif>
                	<a href="javascript://" onClick="gizle_goster(creative_detail);connectAjax();gizle_goster_nested('tasarim_goster','tasarim_gizle');">
                    	<img id="tasarim_goster" style="cursor:pointer;" src="/images/list_minus.gif" title="<cf_get_lang dictionary_id='946.Malzeme ve İşçilik Bilgileri Göster'> <cf_get_lang dictionary_id='58596.Göster'>" >
                      	<img id="tasarim_gizle" style="cursor:pointer;display:none;" src="/images/list_plus.gif" title="<cf_get_lang dictionary_id='47.Malzeme ve İşçilik Bilgileri Gizle'> <cf_get_lang dictionary_id='58628.Gizle'>">
                  	</a>
                	</cfoutput>
                </th>
          	</tr>
            <tr>
                <th style="text-align:center;width:30px;height:30px;cursor:pointer"><cf_get_lang dictionary_id="58577.Sıra"></th>
                <th style="text-align:center;width:30px;cursor:pointer"><img src="/images/workdevxml.gif" style="text-align:center" title=""></th>
                <th style="text-align:center;width:30px;cursor:pointer">
                	<select name="piece_type_select" id="piece_type_select" style="width:30px; height:20px" onchange="piece_type_select_(this.value);">
                    	<option value="" <cfif attributes.piece_type_select eq ''>selected</cfif> ><cf_get_lang dictionary_id="39076.Tüm"></option>
                        <option value="1" <cfif attributes.piece_type_select eq 1>selected</cfif> ><cf_get_lang dictionary_id="207.YNG"></option>
                        <option value="2" <cfif attributes.piece_type_select eq 2>selected</cfif> ><cf_get_lang dictionary_id="208.GNL"></option>
                        <option value="3" <cfif attributes.piece_type_select eq 3>selected</cfif> ><cf_get_lang dictionary_id="209.MNJ"></option>
                        <option value="4" <cfif attributes.piece_type_select eq 4>selected</cfif> ><cf_get_lang dictionary_id="210.HAM"></option>
                    </select>
                </th>
                <th style="text-align:center;width:30px;cursor:pointer" onclick="sort_piece_row(5);"><cf_get_lang dictionary_id="58585.Kod"></th>
                <th style="text-align:center;width:100%;cursor:pointer" onclick="sort_piece_row(2);"><cf_get_lang dictionary_id="44019.Ürün"></th>
                <th style="text-align:center;width:40px;cursor:pointer" onclick="sort_piece_row(1);">&nbsp;<cf_get_lang dictionary_id="99.Boy">&nbsp;</th>
                <th style="text-align:center;width:40px;cursor:pointer" onclick="sort_piece_row(6);">&nbsp;<cf_get_lang dictionary_id="98.En">&nbsp;</th>
                <th style="text-align:center;width:30px;cursor:pointer" onclick="sort_piece_row(7);">&nbsp;<cf_get_lang dictionary_id="211.Kln">&nbsp;</th>
                <th style="text-align:center;width:40px;cursor:pointer" onclick="sort_piece_row(8);">&nbsp;<cf_get_lang dictionary_id="212.Mik">&nbsp;</th>
                <th style="text-align:center;width:90px;cursor:pointer" onclick="sort_piece_row(3);">&nbsp;<cf_get_lang dictionary_id="199.Renk">&nbsp;</th>
                <th style="text-align:center;width:30px;cursor:pointer" onclick="sort_piece_row(9);">&nbsp;<cf_get_lang dictionary_id="213.Dsn">&nbsp;</th>
                <th style="text-align:center;width:30px;cursor:pointer" onclick="sort_piece_row(4);">&nbsp;<cf_get_lang dictionary_id="839.PNo">&nbsp;</th>
                <th style="text-align:center;width:30px;cursor:pointer"><cf_get_lang dictionary_id="214.RF"></th>
                <th style="text-align:center;<cfif not isdefined('attributes.design_package_row_id') and isdefined('attributes.design_main_row_id') and not get_piece_row.recordcount>width:60px<cfelse>width:20px</cfif>" nowrap="nowrap">
                </th>
                <th style="text-align:center;width:20px;">
                	<input type="checkbox" name="all_piece" id="all_piece" onClick="javascript: wrk_select_piece('all_piece','select_piece_row',<cfoutput>#get_piece_row.recordcount#</cfoutput>);">
                </th>
            </tr>
        </thead>
        <tbody>
        <cfoutput query="get_piece_row">
        	<input type="hidden" name="new_stock_id_3_#PIECE_ROW_ID#" id="new_stock_id_3_#PIECE_ROW_ID#" value="">
            <input type="hidden" name="new_product_id_3_#PIECE_ROW_ID#" id="new_product_id_3_#PIECE_ROW_ID#" value="">
            <tr id="frm_row_exit#currentrow#">
                <td nowrap="nowrap" title="<cfif PACKAGE_PARTNER_ID gt 0><cf_get_lang dictionary_id="64.Ortak Paket Parçası"></cfif>" style="text-align:right;cursor: pointer; vertical-align:middle;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray</cfif>">
                	<cfif PIECE_TYPE eq 1 or PIECE_TYPE eq 2>
                		<span class="icn-md icon-copy" style="cursor:pointer" onclick="copy_piece_row(#PIECE_ROW_ID#);" title="<cf_get_lang dictionary_id='57476.Kopyala'>"></span>
                  	</cfif>
                	#currentrow#
              	</td>
                <td style="text-align:center;cursor: pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray<cfelse><cfif PACKAGE_PARTNER_ID gt 0>background-color:MistyRose<cfelse><cfif ORTAK_PARCA gt 1 and IS_PROTOTYPE eq 0>background-color:Gainsboro</cfif></cfif></cfif>">
                	<cfif PIECE_SPECT_RELATED_ID gt 0 or PIECE_TYPE eq 4 or PACKAGE_PARTNER_ID gt 0 or IS_PROTOTYPE eq 0>
                    	<span class="icn-md icon-check" title="<cfif PACKAGE_PARTNER_ID gt 0><cf_get_lang dictionary_id="64.Ortak Paket Parçası"><cfelse><cfif ORTAK_PARCA gt 1 or IS_PROTOTYPE eq 0><cf_get_lang dictionary_id="63.Ortak Parça"><cfelse><cf_get_lang dictionary_id="218.Stok Kartı"></cfif></cfif>" onClick="windowopen('#request.self#?fuseaction=objects.popup_detail_product&sid=#PIECE_RELATED_ID#','list')"></span>
                    <cfelseif PACKAGE_PARTNER_ID lte 0>
                    	<a href="javascript://" onClick="relation_product_row(3,#PIECE_ROW_ID#);">
                            <span class="icn-md icon-link" id="attach_3_#PIECE_ROW_ID#" title="<cf_get_lang dictionary_id='840.Stok Kartı İlişkilendir'>"></span>
                            <img src="/images/icons_valid.gif" id="icons_3_#PIECE_ROW_ID#" title="<cf_get_lang dictionary_id='218.Stok Kartı'>" style="display:none">
                        </a>
                    </cfif>
                </td>
                <td style="text-align:center;cursor: pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray</cfif>" onclick="upd_piece_row(#PIECE_ROW_ID#);">
                	<cfif PIECE_TYPE eq 1>
                		<img src="/images/butcegider.gif" title="<cf_get_lang dictionary_id='62.Yonga Levha'>">
                  	<cfelseif PIECE_TYPE eq 2>
                    	<img src="/images/arrow_up.png" title="<cf_get_lang dictionary_id='402.Genel Reçete'>">
                    <cfelseif PIECE_TYPE eq 3>
                		<img src="/images/elements.gif" title="<cf_get_lang dictionary_id='403.Montaj Ürünü'>">
                	<cfelseif PIECE_TYPE eq 4>
                    	<img src="/images/promo_multi.gif" title="<cf_get_lang dictionary_id='404.Hammadde'>">
                    </cfif>
                </td>
                <td style="text-align:center;cursor:pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">#PIECE_CODE#</td>
                <td <cfif Len(PIECE_NAME) gt 28>title="#PIECE_NAME#"</cfif> style="text-align:left;cursor: pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">
                	<input name="productname#currentrow#" type="text" readonly="readonly" value="#PIECE_NAME#" style="width:100%; border:none;cursor:pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray</cfif>">
                
                </td>
                <td style="text-align:center;cursor:pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">#BOYU#</td>
                <td style="text-align:center;cursor: pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">#ENI#</td>
                <td style="text-align:center;cursor: pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">#KALINLIK_#</td>
                <td style="text-align:center;cursor: pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">#PIECE_AMOUNT#</td>
                <td title="<cfif isdefined('COLOR_NAME_#PIECE_COLOR_ID#')><cfif Len(Evaluate('COLOR_NAME_#PIECE_COLOR_ID#')) gt 12>#Evaluate('COLOR_NAME_#PIECE_COLOR_ID#')#</cfif></cfif>" style="text-align:left;cursor: pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">&nbsp;
                	<cfif isdefined('COLOR_NAME_#PIECE_COLOR_ID#')>&nbsp;#Evaluate('COLOR_NAME_#PIECE_COLOR_ID#')#&nbsp;</cfif>
                </td>
                <td style="text-align:center;cursor: pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">
                	<cfif PIECE_TYPE eq 1>
						<cfif IS_FLOW_DIRECTION eq 0>
                            <img src="images/production/false.png" style="width:15px; height:15px" />
                        <cfelse>
                            <img src="images/production/true.png" style="width:15px; height:15px" />
                        </cfif>
                    </cfif>
                </td>
                <td style="text-align:center;cursor: pointer;<cfif USED_AMOUNT neq 0><cfif USED_AMOUNT eq PIECE_AMOUNT>background-color:LimeGreen<cfelseif USED_AMOUNT lt PIECE_AMOUNT>background-color:yellow<cfelseif USED_AMOUNT gt PIECE_AMOUNT>background-color:coral</cfif><cfelse><cfif not len(PACKAGE_NUMBER)>background-color:red<cfelse><cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray</cfif></cfif></cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);"><cfif USED_AMOUNT neq 0>K-#USED_AMOUNT#<cfelse>#PACKAGE_NUMBER#</cfif>
                	
                </td>
                <td style="text-align:center;cursor: pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray</cfif>" >
					<cfif PIECE_TYPE neq 4>
                    	<span class="fa fa-barcode" style="cursor:pointer" onclick="dsp_piece_row(#PIECE_ROW_ID#);" title="<cf_get_lang dictionary_id='855.İş Emri Görünüm'>"></span>
                    </cfif>
               	</td>
                <td style="text-align:center;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray</cfif>">
                	<cfif PACKAGE_PARTNER_ID gt 0 or (IS_PROTOTYPE eq 0 and PIECE_TYPE neq 4)>
                    	<img src="/images/lock_buton.gif" title="<cf_get_lang dictionary_id='64.Ortak Paket Parçası'>">
                    <cfelse>
                    	<i onclick="upd_piece_row(#PIECE_ROW_ID#);" class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i>
                   	</cfif>
                </td>
                <td style="text-align:center;">
                	<cfif PACKAGE_PARTNER_ID gt 0>
                    <cfelse>
                		<input type="checkbox" name="select_piece_row_#PIECE_ROW_ID#" value="#PIECE_ROW_ID#" id="select_piece_row#currentrow#"/>
                   	</cfif>
                </td>
            </tr>
        </cfoutput>
       </tbody>
    </cf_form_list>
</div>
<script type="text/javascript">
	function add_piece_row()
	{
		<cfif isdefined('attributes.design_main_row_id')>
			windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_product_tree_creative_piece_row&design_main_row_id=#attributes.design_main_row_id#<cfif isdefined("attributes.design_package_row_id") and len(attributes.design_package_row_id)>&package_row_id=#attributes.design_package_row_id#</cfif></cfoutput>','list');
		</cfif>
	}
	function add_import_piece_row()
	{
		<cfif isdefined('attributes.design_main_row_id')>
			windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_product_tree_creative_import_piece_row&design_main_row_id=#attributes.design_main_row_id#</cfoutput>','small');
		</cfif>
	}
	function upd_piece_row(piece_row_id)
	{
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_upd_ezgi_product_tree_creative_piece_row&design_piece_row_id='+piece_row_id,'list');
	}
	function copy_piece_row(piece_row_id)
	{
		window.location ="<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_cpy_ezgi_product_tree_creative_piece_row&is_private=1&design_piece_row_id="+piece_row_id;	
	}
	function dsp_piece_row(piece_row_id)
	{
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_dsp_ezgi_product_tree_creative_piece_row&design_piece_row_id='+piece_row_id,'wide');
	}
	function cpy_piece()
	{
		<cfif isdefined('attributes.design_main_row_id')>
			windowopen("<cfoutput>#request.self#?fuseaction=prod.popup_cpy_ezgi_product_tree_creative_package_row&main=1&design_main_row_id=#attributes.design_main_row_id#<cfif isdefined("attributes.design_package_row_id") and len(attributes.design_package_row_id)>&package_row_id=#attributes.design_package_row_id#</cfif>"</cfoutput>,'list');
		</cfif>
	}
	function wrk_select_piece(all_piece,select_piece_row,number)
	{
		for(var pic_rws=1; pic_rws <= number; pic_rws++)
		{
			if(document.getElementById('select_piece_row'+pic_rws)==undefined)
			{
				
			}
			else
			{
				if(document.getElementById(all_piece).checked == true)
				{
					if(document.getElementById('select_piece_row'+pic_rws).checked == false)
						document.getElementById('select_piece_row'+pic_rws).checked = true;
				}
				else
				{
					if(document.getElementById('select_piece_row'+pic_rws).checked == true)
						document.getElementById('select_piece_row'+pic_rws).checked = false;
				}
			}
		}
	}
</script>