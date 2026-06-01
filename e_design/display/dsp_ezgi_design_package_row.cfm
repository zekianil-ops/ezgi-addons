<!---
    File: dsp_ezgi_design_package_row.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfsetting showdebugoutput="yes">
<cfquery name="get_package_row" datasource="#dsn3#">
	SELECT 
    	* ,
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
<cf_box title="#paketler#" id="package_" >
	<div id="package_">
        <cf_form_list id="table3">
            <cfform name="dsp_package_row" action="">
            <thead>
                <tr style="height:30px">
                    <th style="width:20px;text-align:center">
                        <cfoutput>
                        <cfif isdefined('attributes.design_main_row_id')>
                            <span class="icn-md icon-copy" style="cursor:pointer" onclick="cpy_package_row(#attributes.design_main_row_id#);" title="<cf_get_lang dictionary_id='834.Ortak Paket Ekle'>"></span>
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
                        <cfif PACKAGE_RELATED_ID gt 0>
                            <span class="icn-md icon-check" title="<cf_get_lang dictionary_id='218.Stok Kartı'>" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_detail_product&sid=#PACKAGE_RELATED_ID#','list');"></span>
                        <cfelse>
                            <!---<img src="/images/stopped.gif" id="attach_2_#PACKAGE_ROW_ID#">--->
                            <span class="icn-md icon-link" style="cursor:pointer;" title="<cf_get_lang dictionary_id="840.Stok Kartı İlişkilendir">" onclick="relation_product_row(2,#PACKAGE_ROW_ID#)"></span>
                        </cfif>
                    </td>
                    <td title="#PACKAGE_NAME#" style="text-align:left;cursor: pointer;<cfif isdefined('attributes.design_package_row_id') and attributes.design_package_row_id eq PACKAGE_ROW_ID>background-color:LightGray</cfif>" nowrap onclick="imp_package_row(#PACKAGE_ROW_ID#)">
                        <input name="packagename#currentrow#" type="text" readonly="readonly" value="#PACKAGE_NAME#" style="width:100%; border:none;cursor:pointer;<cfif isdefined('attributes.design_package_row_id') and attributes.design_package_row_id eq PACKAGE_ROW_ID>background-color:LightGray</cfif>">
                    </td>
                    <td style="text-align:center;cursor: pointer;<cfif isdefined('attributes.design_package_row_id') and attributes.design_package_row_id eq PACKAGE_ROW_ID>background-color:LightGray</cfif>">
                        <i onclick="upd_package_row(#PACKAGE_ROW_ID#);" class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>"></i>
                    </td>
                </tr>
                <cfif not PACKAGE_PARTNER_ID gt 0>
                <tr type="columnSort" class="hidden_element">
                    <td colspan="3">
                        <table style="width: 100%; margin-left: 0px">
                            <tbody class="sorter" data-design_package_row_id = "#PACKAGE_ROW_ID#" data-design_package_number = "#PACKAGE_NUMBER#">
                                <tr id="frm_row_exit#currentrow#_btm"><td colspan="20" class="sorter-title text-center">Buraya Sürükleyin!</td></tr>
                            </tbody>
                        </table>
                    </td>
                </tr>
                </cfif>
            </cfoutput>
           </tbody>
        </cf_form_list>
	</div>
</cf_box>
<script type="text/javascript">

	var packageCounter = parseInt("<cfoutput>#get_package_row.recordCount#</cfoutput>") + 1
		,design_package_row_id = "<cfoutput>#attributes.design_package_row_id?:''#</cfoutput>";

	function add_package_row(design_main_row_id)
	{
		if( design_main_row_id != '' ){
			var data = new FormData();
			data.append("design_main_row_id", design_main_row_id);
			AjaxControlPostDataJson( "AddOns/ezgi/cfc/package.cfc?method=set_package", data, function (response) {
				if(response.STATUS){

					var checkTitle = "", checkColor = "", checkIcon = "";

					if(response.DATA.length){
						packageData = response.DATA;
						packageData.forEach(el => {

							checkTitle = el.PACKAGE_IS_MASTER > 0 ? "<cf_get_lang dictionary_id="838.Master Ortak Paket">" : (el.PACKAGE_PARTNER_ID > 0 ? "<cf_get_lang dictionary_id="59.Ortak Paket">" : "");
							if(design_package_row_id == el.PACKAGE_ROW_ID) checkColor = "LightGray";
							else{
								if(el.PACKAGE_IS_MASTER > 0) checkColor = "Green";
								else if(el.PACKAGE_PARTNER_ID > 0) checkColor = "MistyRose";
								else checkColor = "";
							}
							checkIcon = (el.PACKAGE_RELATED_ID > 0)
										? $("<span>").addClass("icn-md icon-check").attr({"title": "<cf_get_lang dictionary_id='218.Stok Kartı'>", "onclick": "openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_detail_product&sid=" + el.PACKAGE_RELATED_ID + "','list')"})
										: $("<img>").attr({"id": "attach_2_" + el.PACKAGE_ROW_ID + "","src": "/images/stopped.gif"})

							$("<tr>").attr({"id": "frm_row_exit" + packageCounter + ""}).append(
								$("<td>").css({"text-align": "center", "cursor": "pointer", "background-color": checkColor}).attr({"title": checkTitle}).append( checkIcon ),
								$("<td>").css({"text-align": "left", "cursor": "pointer", "background-color": (design_package_row_id == el.PACKAGE_ROW_ID ? "LightGray" : "")}).attr({"title": el.PACKAGE_NAME, "onclick": "imp_package_row("+ el.PACKAGE_ROW_ID +")"}).append(
									$("<input>").css({"width": "100%", "border": "none", "cursor": "pointer", "background-color": ( design_package_row_id == el.PACKAGE_ROW_ID ? "LightGray" : "" )}).attr({"type": "text", "name": "packagename" + packageCounter + "", "readonly": "readonly"}).val(el.PACKAGE_NAME)
								),
								$("<td>").css({"text-align": "center", "cursor": "pointer", "background-color": (design_package_row_id == el.PACKAGE_ROW_ID ? "LightGray" : "")}).append(
									$("<i>").addClass("fa fa-pencil").attr({"title": "<cf_get_lang dictionary_id='57464.Güncelle'>", "onclick": "upd_package_row(" + el.PACKAGE_ROW_ID + ")"})
								)
							).appendTo($("#table3 > tbody"));

							$("<tr>").addClass("hidden_element").attr({"type": "columnSort"}).append(
								$("<td>").attr({"colspan":"3"}).append(
									$("<table>").css({"width": "100%", "margin-left": "0px"}).append(
										$("<tbody>").addClass("sorter").attr({"data-design_package_row_id": el.PACKAGE_ROW_ID, "data-design_package_number": el.PACKAGE_NUMBER}).append(
											$("<tr>").attr({"id": "frm_row_exit"+ packageCounter +"_btm"}).append(
												$("<td>").addClass("sorter-title text-center").attr({"colspan": "20"}).text("Buraya Sürükleyin!")
											)
										)
									)
								)
							).appendTo($("#table3 > tbody"));
							
							packageCounter++;
						});

						packagePanel.find("> tbody tr[type=columnSort] tbody").sortable(sortableSettings.package);
					}
				}else{
					alert(response.MESSAGE);
				}
			});
		}

		<!--- <cfif isdefined('attributes.design_main_row_id')>
			windowopen("<cfoutput>#request.self#?fuseaction=prod.emptypopup_add_ezgi_product_tree_creative_package_row&design_main_row_id=#attributes.design_main_row_id#</cfoutput>",'small')

		</cfif> --->

	}
	function cpy_package_row()
	{
		<cfif isdefined('attributes.design_main_row_id')>
		{
		windowopen("<cfoutput>#request.self#?fuseaction=prod.popup_cpy_ezgi_product_tree_creative_package_row&design_main_row_id=#attributes.design_main_row_id#"</cfoutput>,'list');
		}
		</cfif>
	}
	function upd_package_row(package_row_id)
	{
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_upd_ezgi_product_tree_creative_package_row&design_package_row_id='+package_row_id,'small');
	}
</script>