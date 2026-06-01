<!---
    File: dsp_ezgi_private_design_package_row.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_package_row" datasource="#dsn3#">
	SELECT 
    	PACKAGE_IS_MASTER,
        PACKAGE_PARTNER_ID,
        PACKAGE_RELATED_ID,
        PACKAGE_ROW_ID,
        PACKAGE_NAME,
        CASE
        	WHEN PACKAGE_PARTNER_ID > 0
            	THEN
               	(
                	SELECT        
                    	TOP (1) SPECT_MAIN_ID
                  	FROM            
                     	SPECT_MAIN
                 	WHERE        
                     	STOCK_ID = EZGI_DESIGN_PACKAGE.PACKAGE_RELATED_ID
                   	ORDER BY 
                     	SPECT_MAIN_ID DESC
              	)
    		ELSE
       			PACKAGE_SPECT_RELATED_ID
        END AS PACKAGE_SPECT_RELATED_ID,
        (SELECT DESIGN_MAIN_NAME FROM EZGI_DESIGN_MAIN_ROW WHERE DESIGN_MAIN_ROW_ID = EZGI_DESIGN_PACKAGE.DESIGN_MAIN_ROW_ID) as DESIGN_MAIN_NAME,
	(
		SELECT        
			EDS.MAIN_ROW_SETUP_CODE
		FROM           
			EZGI_DESIGN_MAIN_ROW_SETUP AS EDS INNER JOIN
          	EZGI_DESIGN_MAIN_ROW AS EDM ON EDS.MAIN_ROW_SETUP_ID = EDM.MAIN_ROW_SETUP_ID
		WHERE        
			EDM.DESIGN_MAIN_ROW_ID = EZGI_DESIGN_PACKAGE.DESIGN_MAIN_ROW_ID
	) AS CODE
  	FROM 
    	EZGI_DESIGN_PACKAGE
  	WHERE 
    	<cfif isdefined('attributes.design_main_row_id')>
    		DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
       	<cfelse>
        	DESIGN_ID = #attributes.design_id#
        </cfif>
 	ORDER BY
    	CODE,
    	PACKAGE_NUMBER
</cfquery>
<cfsavecontent  variable="paketler">
	<cf_get_lang dictionary_id='60.Paketler'>
</cfsavecontent>
<cf_seperator title="#paketler#" id="package_" is_closed="1">
<div id="package_">
    <cf_form_list id="table3">
    	<cfform name="dsp_package_row" action="">
            <thead>
                <tr style="height:30px">
                    <th style="width:20px;text-align:center">
                    	<cfoutput>
							<cfif isdefined('attributes.design_main_row_id')>
                                <span class="icn-md icon-copy" style="cursor:pointer" onclick="cpy_package_row(#attributes.design_main_row_id#);" title="<cf_get_lang dictionary_id='834.Ortak Paket Ekle'>"></span>
                            <cfelse>
                            	 <img src="/images/workdevxml.gif" style="text-align:center" title="">
                            </cfif>
                     	</cfoutput>
                   </th>
                    <th style="width:100%;cursor:pointer" onclick="imp_package_row();"><cf_get_lang dictionary_id="44019.Ürün"></th>
                    <th style="width:40px;text-align:center;">
                        <cfoutput>
                            <cfif isdefined('attributes.design_main_row_id')>
                            	<span class="icn-md icon-add" style="cursor:pointer" onclick="add_package_row(#attributes.design_main_row_id#);" title="<cf_get_lang dictionary_id='833.Paket Ekle'>"></span>
                            </cfif>
                        </cfoutput>
                    </th>
                </tr>
            </thead>
        </cfform>
        <tbody>
			<cfoutput query="get_package_row">
                <tr id="frm_row_exit#currentrow#">
                    <td title="<cfif PACKAGE_IS_MASTER gt 0><cf_get_lang dictionary_id="838.Master Ortak Paket"><cfelseif PACKAGE_PARTNER_ID gt 0><cf_get_lang dictionary_id="59.Ortak Paket"></cfif>" style="text-align:center;cursor: pointer;<cfif isdefined('attributes.design_package_row_id') and attributes.design_package_row_id eq PACKAGE_ROW_ID>background-color:LightGray<cfelse><cfif PACKAGE_IS_MASTER gt 0>background-color:Green<cfelseif PACKAGE_PARTNER_ID gt 0>background-color:MistyRose</cfif></cfif>">
                        <cfif PACKAGE_SPECT_RELATED_ID gt 0>
                        	<span class="icn-md icon-check" title="<cf_get_lang dictionary_id='218.Stok Kartı'>" onClick="windowopen('#request.self#?fuseaction=objects.popup_detail_product&sid=#PACKAGE_RELATED_ID#','list');"></span>

                        <cfelse>
                            <img src="/images/stopped.gif" id="attach_2_#PACKAGE_ROW_ID#">
                        </cfif>
                    </td>
                    <td title="#PACKAGE_NAME#" style="text-align:left;cursor: pointer;<cfif isdefined('attributes.design_package_row_id') and attributes.design_package_row_id eq PACKAGE_ROW_ID>background-color:LightGray</cfif>" nowrap onclick="imp_package_row(#PACKAGE_ROW_ID#)">
                        <input name="packagename#currentrow#" type="text" readonly="readonly" value="#PACKAGE_NAME#" style="width:100%; border:none;cursor:pointer;<cfif isdefined('attributes.design_package_row_id') and attributes.design_package_row_id eq PACKAGE_ROW_ID>background-color:LightGray</cfif>">
                    </td>
                    <td style="text-align:center;cursor: pointer;<cfif isdefined('attributes.design_package_row_id') and attributes.design_package_row_id eq PACKAGE_ROW_ID>background-color:LightGray</cfif>" >
                    	<i onclick="upd_package_row(#PACKAGE_ROW_ID#);" class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i>
                    </td>
                </tr>
            </cfoutput>
       </tbody>
    </cf_form_list>
</div>
<script type="text/javascript">
	function add_package_row()
	{
		<cfif isdefined('attributes.design_main_row_id')>
			windowopen("<cfoutput>#request.self#?fuseaction=prod.emptypopup_add_ezgi_product_tree_creative_package_row&is_private=1&design_main_row_id=#attributes.design_main_row_id#</cfoutput>",'small')

		</cfif>
	}
	function cpy_package_row()
	{
		<cfif isdefined('attributes.design_main_row_id')>
		{
		windowopen("<cfoutput>#request.self#?fuseaction=prod.popup_cpy_ezgi_product_tree_creative_package_row&private=1&design_main_row_id=#attributes.design_main_row_id#"</cfoutput>,'list');
		}
		</cfif>
	}
	function upd_package_row(package_row_id)
	{
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_upd_ezgi_product_tree_creative_package_row&design_package_row_id='+package_row_id,'small');
	}
</script>