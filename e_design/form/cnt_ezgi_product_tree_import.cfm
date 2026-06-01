<!---
    File: cnt_ezgi_product_tree_import.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---Design Sorgusu--->
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WITH (NOLOCK) ORDER BY COLOR_NAME
</cfquery>
<cfoutput query="get_colors">
	<cfset 'COLOR_NAME_#COLOR_ID#' = COLOR_NAME>
</cfoutput>
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
</cfquery>
<cfquery name="get_product_cat_piece" datasource="#dsn3#">
  	SELECT HIERARCHY FROM PRODUCT_CAT WITH (NOLOCK) WHERE PRODUCT_CATID = #get_defaults.DEFAULT_PIECE_CAT_ID#
</cfquery>
<cfquery name="get_product_cat_package" datasource="#dsn3#">
  	SELECT HIERARCHY FROM PRODUCT_CAT WITH (NOLOCK) WHERE PRODUCT_CATID = #get_defaults.DEFAULT_PACKAGE_CAT_ID#
</cfquery>
<cfquery name="get_design_info" datasource="#dsn3#">
	SELECT 
    	PRODUCT_CAT.HIERARCHY,
        ED.DESIGN_NAME, 
        ED.PROCESS_ID,
       	ED.PRODUCT_CATID,
        ISNULL(ED.IS_PROTOTIP,0) AS IS_PROTOTIP,
        PRODUCT_CAT.PRODUCT_CAT 
   	FROM 
    	EZGI_DESIGN AS ED WITH (NOLOCK) INNER JOIN PRODUCT_CAT WITH (NOLOCK) ON 
        ED.PRODUCT_CATID = PRODUCT_CAT.PRODUCT_CATID 
  	WHERE 
    	ED.DESIGN_ID = #attributes.design_id#
</cfquery>
<!---Design Sorgusu--->
<cfquery name="get_satirlar" datasource="#dsn3#">
	SELECT 
    	*
  	FROM
    	(
        SELECT        
            3 AS TYPE, 
            0 AS PIECE_TYPE, 
            EDR.DESIGN_MAIN_COLOR_ID AS COLOR_ID,
            EDR.DESIGN_MAIN_NAME AS DESIGN_ROW_NAME, 
            S.PRODUCT_NAME, 
            S.PRODUCT_CODE, 
            EDR.DESIGN_MAIN_ROW_ID AS IID, 
            S.STOCK_ID, 
            S.PRODUCT_STATUS,
            0 AS PARTNER_ID,
            ISNULL(MAIN_PROTOTIP_TYPE,0) AS MAIN_PROTOTIP_TYPE
        FROM            
            EZGI_DESIGN_MAIN_ROW AS EDR WITH (NOLOCK) LEFT OUTER JOIN
            STOCKS AS S WITH (NOLOCK) ON EDR.DESIGN_MAIN_RELATED_ID = S.STOCK_ID
        WHERE        
            EDR.DESIGN_ID = #attributes.design_id#
            <cfif isdefined('attributes.design_main_row_id') and len(attributes.design_main_row_id)>
                AND EDR.DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
            </cfif>
      	<cfif get_design_info.PROCESS_ID lte 2> <!---Modül + Paket--->
			UNION ALL
			SELECT        
				2 AS TYPE, 
				0 AS PIECE_TYPE, 
				EDP.PACKAGE_COLOR_ID AS COLOR_ID,
				EDP.PACKAGE_NAME AS DESIGN_ROW_NAME, 
				S.PRODUCT_NAME, 
				S.PRODUCT_CODE, 
				EDP.PACKAGE_ROW_ID AS IID, 
				S.STOCK_ID, 
				S.PRODUCT_STATUS,
                ISNULL(EDP.PACKAGE_PARTNER_ID,0) AS PARTNER_ID,
                ISNULL((SELECT MAIN_PROTOTIP_TYPE FROM EZGI_DESIGN_MAIN_ROW WHERE DESIGN_MAIN_ROW_ID = EDP.DESIGN_MAIN_ROW_ID),0) AS MAIN_PROTOTIP_TYPE
			FROM            
				EZGI_DESIGN_PACKAGE AS EDP WITH (NOLOCK) LEFT OUTER JOIN
				STOCKS AS S WITH (NOLOCK) ON EDP.PACKAGE_RELATED_ID = S.STOCK_ID
			WHERE        
				EDP.DESIGN_ID = #attributes.design_id#
                <cfif isdefined('attributes.design_main_row_id') and len(attributes.design_main_row_id)>
                    AND EDP.DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
                </cfif>
		</cfif>
        <cfif get_design_info.PROCESS_ID eq 1> <!---Modül + Paket + Parça--->
            UNION ALL
            SELECT        
                1 AS TYPE, 
                EDE.PIECE_TYPE, 
                EDE.PIECE_COLOR_ID AS COLOR_ID,
                EDE.PIECE_NAME AS DESIGN_ROW_NAME, 
                S.PRODUCT_NAME, 
                S.PRODUCT_CODE, 
                EDE.PIECE_ROW_ID AS IID, 
                S.STOCK_ID, 
                S.PRODUCT_STATUS,
                ISNULL(EDE.PACKAGE_PARTNER_ID,0) PARTNER_ID,
                ISNULL((SELECT MAIN_PROTOTIP_TYPE FROM EZGI_DESIGN_MAIN_ROW WHERE DESIGN_MAIN_ROW_ID = EDE.DESIGN_MAIN_ROW_ID),0) AS MAIN_PROTOTIP_TYPE
            FROM            
                EZGI_DESIGN_PIECE AS EDE WITH (NOLOCK) LEFT OUTER JOIN
                STOCKS AS S WITH (NOLOCK) ON EDE.PIECE_RELATED_ID = S.STOCK_ID
            WHERE        
                EDE.DESIGN_ID = #attributes.design_id# AND
                EDE.PIECE_TYPE <> 4
                <cfif isdefined('attributes.design_main_row_id') and len(attributes.design_main_row_id)>
                    AND EDE.DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
                </cfif>
       	</cfif>
        ) AS TBL
 	ORDER BY
    	TYPE,
        PIECE_TYPE
</cfquery>
<!---<cfdump var="#get_satirlar#">--->
<cfset is_update = 0>
<cfset paket_stop = 0>
<cfset modul_stop = 0>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfform name="old_product" id="old_product" method="post" action="#request.self#?fuseaction=prod.emptypopup_cnt_ezgi_import_creative_workcube">
        <cfinput name="design_id" value="#attributes.design_id#" type="hidden">
        <cfif isdefined('attributes.design_main_row_id')>
            <cfinput name="design_main_row_id" value="#attributes.design_main_row_id#" type="hidden">
        </cfif>
    	<cfsavecontent variable="title"><cf_get_lang dictionary_id="49.Ürün Ağacı Kontrol"></cfsavecontent>
        <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
            <cf_grid_list>
            	<thead>
                    <tr>
                        <th style="text-align:center; width:25px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        <th style="text-align:center; width:80px"><cf_get_lang dictionary_id="537.Ürün Tipi"></th>
                        <th style="text-align:center; width:250px"><cf_get_lang dictionary_id='925.Tasarım Ürün Adı'></th>
                        <th style="text-align:center;"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                       <!--- <th style="text-align:center; width:90px">Ürün Kodu</th>--->
                        <th style="text-align:center; width:120px"><cf_get_lang dictionary_id='57894.Statü'></th>
                        <th style="text-align:center; width:20px"><cf_get_lang dictionary_id='57482.Aşama'></th>
                        <th style="text-align:center; width:20px"></th>
                    </tr>
                </thead>
                <tbody>
                <cfif get_satirlar.recordcount>
                    <cfset is_transfer = 1>
                    <cfset urun_type = 0>
                   <!--- <cfdump var="#get_satirlar#">--->
                    <cfoutput query="get_satirlar">
                        <cfset hata = 0>
                        <cfif type eq 1 and (PIECE_TYPE eq 1 or PIECE_TYPE eq 2 or PIECE_TYPE eq 3)> <!---Yarı Maül Parçalar Ürün Adı Tanımı--->
                            <cfif get_satirlar.COLOR_ID lte 0>
                                <cfset urun_adi = "#get_design_info.DESIGN_NAME# #get_satirlar.DESIGN_ROW_NAME#" >
                            <cfelse>
                                <cfset urun_adi = "#get_design_info.DESIGN_NAME# #get_satirlar.DESIGN_ROW_NAME# (#Evaluate('COLOR_NAME_#get_satirlar.COLOR_ID#')#)">
                            </cfif>
                        <cfelse>
                            <cfset urun_adi = DESIGN_ROW_NAME>
                        </cfif>
                        <cfset RECETE_ADI = get_satirlar.PRODUCT_NAME>
                        
                        <cfinclude template="../query/cnt_ezgi_product_tree_import_ortak.cfm">
                        <cfif get_product_tree.recordcount> <!---Tasarımda Ağaç Yapılacak Satır Varsa--->
                            <cfif partner_id eq 0>
                                <cfif len(get_satirlar.STOCK_ID)> <!---Tasarımdaki Ürün, Workcube Ürünle Bağlı mı--->
                                    <cfif get_defaults.DEFAULT_MAIN_TRANSFER_TYPE eq 2 and get_satirlar.TYPE eq 3 and get_design_info.IS_PROTOTIP neq 1><!---Ürün Modül İse ve Default Transfer Karma Koli İse ve Ürün Özelleştirilebilir Değilse--->
                                        <cfquery name="get_workcube_broduct_tree" datasource="#dsn3#"><!---kARMA kOLİ bİLGİLERİ aLINIYOR--->
                                            SELECT        
                                                KP.PRODUCT_AMOUNT AS AMOUNT, 
                                                0 AS OPERATION_TYPE_ID, 
                                                KP.STOCK_ID AS RELATED_ID
                                            FROM            
                                                #dsn1_alias#.KARMA_PRODUCTS AS KP WITH (NOLOCK) INNER JOIN
                                                #dsn1_alias#.STOCKS AS S WITH (NOLOCK) ON KP.KARMA_PRODUCT_ID = S.PRODUCT_ID
                                            WHERE        
                                                S.STOCK_ID = #get_satirlar.STOCK_ID#
                                        </cfquery>
                                        <cfquery name="get_product_tree" dbtype="query"> <!---tASARIM lİSTESİNDEN oPERASYONLAR tEMİZLENİYOR--->
                                            SELECT * FROM get_product_tree WHERE OPERATION_TYPE_ID = 0
                                        </cfquery>
                                    <cfelse> <!---Default Transfer Karma Koli dEĞİL İse--->
                                        <cfquery name="get_workcube_broduct_tree" datasource="#dsn3#">
                                            SELECT        
                                                ISNULL(RELATED_ID,0) AS RELATED_ID, 
                                                ISNULL(OPERATION_TYPE_ID, 0) AS OPERATION_TYPE_ID, 
                                                AMOUNT
                                            FROM        
                                                PRODUCT_TREE WITH (NOLOCK)
                                            WHERE        
                                                STOCK_ID = #get_satirlar.STOCK_ID#
                                        </cfquery>
                                    </cfif>
                                    <cfif isdefined('QUESTION_DIFF_#get_satirlar.IID#')>
                                    	<cfset hata =4><!---Tasarımla Ağaç Arasındaki Alternatif Soru ID--->
                                    </cfif>
                                    <cfif get_workcube_broduct_tree.recordcount eq get_product_tree.recordcount> <!---Tasarımla Ağaç Arasındaki Satır Sayısı Eşitse--->
                                        <cfloop query="get_workcube_broduct_tree">
                                            <cfset "TREE_#get_satirlar.TYPE#_#get_satirlar.IID#_#get_satirlar.PIECE_TYPE#_#get_workcube_broduct_tree.OPERATION_TYPE_ID#_#get_workcube_broduct_tree.RELATED_ID#" = AMOUNT>
                                        </cfloop>
                                        <cfloop query="get_product_tree">
                                            <cfif isdefined("TREE_#get_satirlar.TYPE#_#get_satirlar.IID#_#get_satirlar.PIECE_TYPE#_#get_product_tree.OPERATION_TYPE_ID#_#get_product_tree.RELATED_ID#") and Round(Evaluate("TREE_#get_satirlar.TYPE#_#get_satirlar.IID#_#get_satirlar.PIECE_TYPE#_#get_product_tree.OPERATION_TYPE_ID#_#get_product_tree.RELATED_ID#")*100000000)/100000000 eq Round(amount*100000000)/100000000> <!---Tasarımla Ağaç Arasındaki Satır Miktarı Eşitse--->
                                                <cfset hata =0>
                                            <cfelse>
                                                <cfset hata =1> <!---Tasarımla Ağaç Arasındaki Satır Miktarı Farklı--->
                                                <cfbreak>
                                            </cfif>
                                        </cfloop>
                                    <cfelse>
                                        <cfset hata =2><!---Tasarımla Ağaç Arasındaki Satır Sayısı Farklı--->
                                        <cfif type eq 1> 
                                            <cfset paket_stop = 1>
                                            <cfset modul_stop = 1>
                                        <cfelseif type eq 2>
                                            <cfset modul_stop = 1>
                                        </cfif>
                                    </cfif>
                                <cfelse>
                                    <cfset hata =3> <!---Tasarımdaki Ürün, Workcube Ürünle Bağlı Değil--->
                                    <cfif type eq 1> 
                                        <cfset paket_stop = 1>
                                        <cfset modul_stop = 1>
                                    <cfelseif type eq 2>
                                        <cfset modul_stop = 1>
                                    </cfif>
                                </cfif>
                            </cfif>
                        <cfelse>
                            <cf_get_lang dictionary_id='169.Tasarımda Reçete Transferi Yapılacak Bilgi Yok'>
                            <!---<cfabort>--->
                        </cfif>
                        <cfif urun_type neq type>
                            <tr><td colspan="8" style="height:1mm">&nbsp;</td></tr>
                            <cfset urun_type = type> 
                        </cfif>
                        
                            
                         <!---#currentrow# - #hata# - #type# - #paket_stop# - #modul_stop#<br />--->
                        <tr id="row_#currentrow#">
                            <td style="text-align:center;" nowrap="nowrap">#currentrow#&nbsp;</td>
                            <td style="text-align:left;" nowrap="nowrap">&nbsp;
                                <cfif type eq 1>
                                    <cfif PIECE_TYPE eq 1>
                                        <cf_get_lang dictionary_id='62.Yonga Levha'>
                                    <cfelseif PIECE_TYPE eq 2>
                                        <cf_get_lang dictionary_id='402.Genel Reçete'>
                                    <cfelseif PIECE_TYPE eq 3>
                                        <cf_get_lang dictionary_id='403.Montaj Ürünü'>
                                    <cfelseif PIECE_TYPE eq 4>
                                        <cf_get_lang dictionary_id='404.Hammadde'>
                                    </cfif>
                                <cfelseif type eq 2>
                                    <cfset PIECE_TYPE eq 0>
                                    <cf_get_lang dictionary_id='100.Paket'>
                                <cfelseif type eq 3>
                                    <cfset PIECE_TYPE eq 0>
                                    <cf_get_lang dictionary_id='141.Modül'>
                                </cfif>
                            </td>
                            <td style="text-align:left;" nowrap="nowrap">&nbsp;#urun_adi#</td>
                            <td style="text-align:left;" nowrap="nowrap">&nbsp;
                                <cfif urun_adi neq RECETE_ADI>
                                    <span style="color:red"><strong>#RECETE_ADI#</strong></span>
                                <cfelse>
                                    #RECETE_ADI#
                                </cfif>
                               
                            </td>
                            <cfif partner_id eq 0>
                                <cfif hata eq 1 or hata eq 2 or hata eq 4>
                                    <cfset is_update = 1>
                                    <cfset upd_type = 2><!---Ürün Reçetesi Farklı--->
                                    <td style="text-align:center;" nowrap="nowrap"><span style="color:red"><strong><cfif hata eq 1><cf_get_lang dictionary_id='926.Ürün Miktarı Farklı'><cfelseif hata eq 2><cf_get_lang dictionary_id='930.Ürün Sayısı Farklı'></cfif></strong></span></td>
                                    <td style="text-align:center;" nowrap="nowrap">
                                        <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_dsp_ezgi_product_tree_import&upd_type=#upd_type#&type=#type#&piece_type=#piece_type#&IID=#IID#&stock_id=#get_satirlar.STOCK_ID#&design_id=#attributes.design_id#&urun_adi=#urun_adi#<cfif isdefined("attributes.design_main_row_id") and len(attributes.design_main_row_id)>&design_main_row_id=#attributes.design_main_row_id#</cfif>','wide');">
                                            <img src="images/control.gif" title="<cf_get_lang dictionary_id='927.Ürün Reçetesi Farklı'>" />
                                        </a>
                                    </td>
                                    <td style="text-align:center;" nowrap="nowrap">
                                        <cfif type eq 1 or (type eq 2 and paket_stop eq 0) or (type eq 3 and modul_stop eq 0)>
                                            <input type="checkbox" id="select_#type#_#IID#" name="select_#type#_#IID#" value="1" checked>
                                        <cfelse>
                                            <input type="checkbox" id="select_#type#_#IID#" name="select_#type#_#IID#" value="1" readonly="readonly" disabled="disabled">
                                        </cfif>
                                        <cfinput name="iid_list" value="#get_satirlar.TYPE#_#get_satirlar.IID#" type="hidden">
                                        <cfinput name="upd_type_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#upd_type#" type="hidden">
                                        <cfinput name="stock_id_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#get_satirlar.STOCK_ID#" type="hidden">
                                    </td>
                                <cfelseif hata eq 3> 
                                    <cfset is_update = 1>
                                    <cfset upd_type = 1><!---Ürün Transferi Eksik--->
                                    <td style="text-align:center;" nowrap="nowrap"><span style="color:red"><strong><cf_get_lang dictionary_id='172.Ürün Transferi Eksik'></strong></span></td>
                                    <td style="text-align:center;" nowrap="nowrap">
                                        <img src="images/ok_list_empty.gif" title="<cf_get_lang dictionary_id='173.Ürün Reçetesi Transfer Edilecek'>" />
                                    </td>
                                    <td style="text-align:center;" nowrap="nowrap">
                                        <cfif type eq 1 or (type eq 2 and paket_stop eq 0) or (type eq 3 and modul_stop eq 0)>
                                            <input type="checkbox" id="select_#type#_#IID#" name="select_#type#_#IID#" value="1" checked>
                                        <cfelse>
                                            <input type="checkbox" id="select_#type#_#IID#" name="select_#type#_#IID#" value="1" readonly="readonly" disabled="disabled">
                                        </cfif>
                                        <cfinput name="iid_list" value="#get_satirlar.TYPE#_#get_satirlar.IID#" type="hidden">
                                        <cfinput name="upd_type_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#upd_type#" type="hidden">
                                        <cfinput name="stock_id_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#get_satirlar.STOCK_ID#" type="hidden">
                                    </td>
                                <cfelse>
                                    <cfif urun_adi neq RECETE_ADI> 
                                        <cfset is_update = 1>
                                        <cfset upd_type = 3><!---Ürün Adı Uyumsuz--->
                                        <td style="text-align:center;" nowrap="nowrap"><span style="color:red"><strong><cf_get_lang dictionary_id='931.Ürün Adı Uyumsuz'></strong></span></td>
                                        <td style="text-align:center;" nowrap="nowrap">
                                            <img src="images/d_ok.gif" title="<cf_get_lang dictionary_id='931.Ürün Adı Uyumsuz'>" />
                                        </td>
                                        <td style="text-align:center;" nowrap="nowrap">
                                            <input type="checkbox" id="select_#type#_#IID#" name="select_#type#_#IID#" value="1">
                                            <cfinput name="iid_list" value="#get_satirlar.TYPE#_#get_satirlar.IID#" type="hidden">
                                            <cfinput name="upd_type_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#upd_type#" type="hidden">
                                            <cfinput name="stock_id_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#get_satirlar.STOCK_ID#" type="hidden">
                                            <cfinput name="urun_adi_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#urun_adi#" type="hidden">
                                        </td>
                                    <cfelseif PRODUCT_STATUS neq 1> 
                                        <cfset is_update = 1>
                                        <cfset upd_type = 4><!---Ürün Pasif Edilmiş--->
                                        <td style="text-align:center;" nowrap="nowrap"><span style="color:red"><strong><cf_get_lang dictionary_id='176.Ürün Pasif Edilmiş'></strong></span></td>
                                        <td style="text-align:center;" nowrap="nowrap">
                                            <img src="images/d_ok.gif" title="<cf_get_lang dictionary_id='176.Ürün Pasif Edilmiş'>" />
                                        </td>
                                        <td style="text-align:center;" nowrap="nowrap">
                                            <input type="checkbox" id="select_#type#_#IID#" name="select_#type#_#IID#" value="1">
                                            <cfinput name="iid_list" value="#get_satirlar.TYPE#_#get_satirlar.IID#" type="hidden">
                                            <cfinput name="upd_type_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#upd_type#" type="hidden">
                                            <cfinput name="stock_id_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#get_satirlar.STOCK_ID#" type="hidden">
                                        </td>
                                    <cfelse>
                                        <td style="text-align:center;" nowrap="nowrap"><span style="color:green"><strong><cf_get_lang dictionary_id='175.Uyumlu'></strong></span></td>
                                        <td style="text-align:center;" nowrap="nowrap"><img src="images/c_ok.gif" title="<cf_get_lang dictionary_id='175.Uyumlu'>" /></td>
                                        <td style="text-align:center;" nowrap="nowrap"></td>
                                    </cfif>
                                </cfif>
                            <cfelse>
                                <td style="text-align:center;" nowrap="nowrap"><span style="color:green"><strong><cf_get_lang dictionary_id='175.Uyumlu'></strong></span></td>
                                <td style="text-align:center;" nowrap="nowrap">
                                    <img src="images/c_ok.gif" title="<cf_get_lang dictionary_id='175.Uyumlu'>" />
                                </td>
                                <td style="text-align:center;" nowrap="nowrap">
                                    <img src="images/lock_buton.gif" title="<cf_get_lang dictionary_id='175.Uyumlu'>" />
                                </td>
                            </cfif>
                        </tr>
                    </cfoutput>
                    <tfoot>
                        <tr>
                            <td colspan="8" height="20" style="text-align:right">
                                <cfif is_update eq 1>
                                <cfsavecontent variable="wrk_upd"><cf_get_lang dictionary_id="928.Workcube Güncelle"></cfsavecontent>
                                <cf_workcube_buttons is_upd='1' is_delete='0' add_function='control_product_tree()' insert_info='#wrk_upd#'> 
                                </cfif>       
                            </td>
                        </tr>
                    </tfoot>
                <cfelse>
                    <tr> 
                        <td colspan="4" height="20"><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</td>
                    </tr>
                </cfif>
                </tbody>
            </cf_grid_list>
      	</cf_box>
  	</cfform>
</div>
<script language="javascript">
	function control_product_tree()
	{
		
		return true;
	}
</script>