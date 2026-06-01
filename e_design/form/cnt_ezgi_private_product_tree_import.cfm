<!---
    File: cnt_ezgi_private_product_tree_import.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---Design Sorgusu--->
<cf_xml_page_edit>
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS ORDER BY COLOR_NAME
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
        ED.DESIGN_NAME, 
        ED.PROCESS_ID,
        ISNULL(ED.IS_PROTOTIP,0) AS IS_PROTOTIP
   	FROM 
    	EZGI_DESIGN AS ED WITH (NOLOCK)
  	WHERE 
    	ED.DESIGN_ID = #attributes.design_id#
</cfquery>
<cfquery name="GET_PROTOTIP" datasource="#dsn3#"> <!---Tasarım Özelleştirilebilir mi Kontrol Ediliyor--->
	SELECT        
        ERM.DESIGN_MAIN_NAME, 
        ED.DESIGN_NAME
	FROM            
    	EZGI_DESIGN_MAIN_ROW AS ERM WITH (NOLOCK) INNER JOIN
      	EZGI_DESIGN AS ED WITH (NOLOCK) ON ERM.DESIGN_ID = ED.DESIGN_ID
	WHERE        
    	ERM.DESIGN_MAIN_ROW_ID IN
                             	(
                                	SELECT        
                                    	MAIN_PROTOTIP_ID
                               		FROM            
                                 		EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
                               		WHERE        
                                    	DESIGN_ID = #attributes.design_id#
                               	) AND 
      	ERM.MAIN_PROTOTIP_ID IS NULL AND 
        ISNULL(ED.IS_PROTOTIP,0) = 0
</cfquery>
<cfif GET_PROTOTIP.recordcount>
	<script type="text/javascript">
		alert("<cfoutput query="GET_PROTOTIP">#DESIGN_MAIN_NAME# , </cfoutput><cf_get_lang dictionary_id='33260.Ürün Özelleştirilebilir Olmadığı İçin Spekt Kaydedemezsiniz'>!");
		window.close()
	</script>
    <cfabort>
</cfif>
<cfquery name="GET_PROTOTIP" datasource="#dsn3#"> <!---Master Ürünler Özelleştirilebilir mi Kontrol Ediliyor--->
	SELECT        
    	S.PRODUCT_CODE, 
        S.PRODUCT_NAME
	FROM            
   		EZGI_DESIGN_MAIN_ROW AS ERM WITH (NOLOCK) INNER JOIN
		STOCKS AS S WITH (NOLOCK) ON ERM.DESIGN_MAIN_RELATED_ID = S.STOCK_ID
	WHERE        
    	ERM.DESIGN_MAIN_ROW_ID IN
                             	(
                                	SELECT        
                                    	MAIN_PROTOTIP_ID
                               		FROM            
                                    	EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
                               		WHERE        
                                    	DESIGN_ID = #attributes.design_id#
                              	) AND 
       	ERM.MAIN_PROTOTIP_ID IS NULL AND 
        ISNULL(S.IS_PROTOTYPE,0) = 0
</cfquery>
<cfif GET_PROTOTIP.recordcount>
	<script type="text/javascript">
		alert("<cfoutput query="GET_PROTOTIP">#PRODUCT_CODE# - #PRODUCT_NAME# , </cfoutput><cf_get_lang dictionary_id='33260.Ürün Özelleştirilebilir Olmadığı İçin Spekt Kaydedemezsiniz'>!");
		window.close()
	</script>
    <cfabort>
</cfif>
<!---Design Sorgusu--->
<cfinclude template="../query/get_ezgi_private_product_tree_import.cfm">
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfform name="old_product" id="old_product" method="post" action="#request.self#?fuseaction=prod.emptypopup_cnt_ezgi_import_private_creative_workcube">
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
                        <th style="text-align:center; width:120px"><cf_get_lang dictionary_id='537.Ürün Tipi'></th>
                        <th style="text-align:center;"><cf_get_lang dictionary_id='925.Tasarım Ürün Adı'></th>
                        <!-- sil -->
                        <th style="text-align:center; width:20px"></th>
                        <th style="text-align:center; width:20px"></th>
                        <!-- sil -->
                    </tr>
                </thead>
                <tbody>
                    <cfif get_satirlar.recordcount>
                        <cfset is_transfer = 1>
                        <cfset urun_type = 0>
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
                            <cfif x_tree_control eq 1>
                            	<cfinclude template="../query/cnt_ezgi_product_tree_import_ortak.cfm">
								<cfif get_product_tree.recordcount> <!---Tasarımda Ağaç Yapılacak Satır Varsa--->
                                    <cfif len(get_satirlar.SPECT_MAIN_ID)> <!---Tasarımdaki Ürün, Workcube Ürünle Bağlı mı--->
                                        <cfquery name="get_workcube_broduct_tree" datasource="#dsn3#">
                                            SELECT 
                                                CASE
                                                    WHEN
                                                        (SELECT ISNULL(IS_PROTOTYPE,0) AS IS_PROTOTYPE FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID=SM.STOCK_ID) = 0
                                                    THEN
                                                        0
                                                    ELSE
                                                        ISNULL(RELATED_MAIN_SPECT_ID,0) 
                                                END
                                                    AS RELATED_MAIN_SPECT_ID,
                                                ISNULL(STOCK_ID,0) AS RELATED_ID, 
                                                ISNULL(OPERATION_TYPE_ID, 0) AS OPERATION_TYPE_ID, 
                                                AMOUNT
                                            FROM         
                                                SPECT_MAIN_ROW SM WITH (NOLOCK)
                                            WHERE        
                                                SPECT_MAIN_ID = #get_satirlar.SPECT_MAIN_ID#
                                        </cfquery>
                                        <cfset get_product_tree_ = queryNew("AMOUNT, LINE_NUMBER, OPERATION_TYPE_ID, RELATED_ID, SPECT_RELATED_ID","Decimal, integer, integer, integer, integer")/>
                                        <cfloop query="get_product_tree">
                                        <cfset Temp = QueryAddRow(get_product_tree_)>
                                            <cfquery name="get_stock_prototype" datasource="#dsn3#">
                                                SELECT ISNULL(IS_PROTOTYPE,0) IS_PROTOTYPE FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_product_tree.RELATED_ID# 
                                            </cfquery>
                                            
                                            <cfset Temp = QuerySetCell(get_product_tree_, "AMOUNT", AMOUNT)>
                                            <cfset Temp = QuerySetCell(get_product_tree_, "LINE_NUMBER", LINE_NUMBER)>
                                            <cfset Temp = QuerySetCell(get_product_tree_, "OPERATION_TYPE_ID", OPERATION_TYPE_ID)>
                                            <cfset Temp = QuerySetCell(get_product_tree_, "RELATED_ID", RELATED_ID)>
                                            <cfif get_stock_prototype.recordcount and get_stock_prototype.IS_PROTOTYPE eq 1>
                                                <cfset Temp = QuerySetCell(get_product_tree_, "SPECT_RELATED_ID", SPECT_RELATED_ID)>
                                            <cfelse>
                                                <cfset Temp = QuerySetCell(get_product_tree_, "SPECT_RELATED_ID", 0)>
                                            </cfif>
                                        </cfloop>
                                        <cfquery name="get_product_tree" dbtype="query">
                                            SELECT * FROM get_product_tree_
                                        </cfquery>
                                        <!---<cfdump var="#get_workcube_broduct_tree#"> <cfdump var="#get_product_tree#">--->
                                        <cfif get_workcube_broduct_tree.recordcount eq get_product_tree.recordcount> <!---Tasarımla Ağaç Arasındaki Satır Sayısı Eşitse--->
                                            <cfloop query="get_workcube_broduct_tree">
                                                <cfset "TREE_#get_satirlar.TYPE#_#get_satirlar.IID#_#get_satirlar.PIECE_TYPE#_#get_workcube_broduct_tree.OPERATION_TYPE_ID#_#get_workcube_broduct_tree.RELATED_ID#_#get_workcube_broduct_tree.RELATED_MAIN_SPECT_ID#" = AMOUNT>
                                            </cfloop>
                                            <cfloop query="get_product_tree">
                                                <cfif isdefined("TREE_#get_satirlar.TYPE#_#get_satirlar.IID#_#get_satirlar.PIECE_TYPE#_#get_product_tree.OPERATION_TYPE_ID#_#get_product_tree.RELATED_ID#_#get_product_tree.SPECT_RELATED_ID#") and Round(Evaluate("TREE_#get_satirlar.TYPE#_#get_satirlar.IID#_#get_satirlar.PIECE_TYPE#_#get_product_tree.OPERATION_TYPE_ID#_#get_product_tree.RELATED_ID#_#get_product_tree.SPECT_RELATED_ID#")*100000000)/100000000 eq Round(amount*100000000)/100000000> <!---Tasarımla Ağaç Arasındaki Satır Miktarı Eşitse--->
                                                    <cfset hata =0>
                                                <cfelse>
                                                    
                                                    <cfset hata =1> <!---Tasarımla Ağaç Arasındaki Satır Miktarı Farklı--->
                                                    <cfbreak>
                                                </cfif>
                                            </cfloop>
                                        <cfelse>
                                            <cfset hata =2><!---Tasarımla Ağaç Arasındaki Satır Sayısı Farklı--->
                                        </cfif>
                                    <cfelse>
                                        <cfset hata =3> <!---Tasarımdaki Ürün, Workcube Ürünle Bağlı Değil--->
                                    </cfif>
                                <cfelse>
                                    <cf_get_lang dictionary_id='169.Tasarımda Reçete Transferi Yapılacak Bilgi Yok'>
                                    <cfdump var="#get_product_tree#">
                                    <cfabort>
                                </cfif>
                            <cfelse>
								<cfset hata =3>
                                <cfset upd_type =1>
                            </cfif>
                            <cfif urun_type neq type>
                                <tr><td colspan="8" style="height:1mm">&nbsp;</td></tr>
                                <cfset urun_type = type> 
                            </cfif>
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
                                <cfif partner_id eq 0>
                                    <cfif hata eq 1 or hata eq 2>
                                        <cfset upd_type = 2><!---Ürün Reçetesi Farklı--->
                                        <!-- sil -->
                                        <td style="text-align:center;" nowrap="nowrap">
                                      		<img src="images/control.gif" title="<cf_get_lang dictionary_id='927.Ürün Reçetesi Farklı'>" />
                                        </td>
                                        <td style="text-align:center;" nowrap="nowrap">
                                            <input type="checkbox" id="select_#type#_#IID#" name="select_#type#_#IID#" value="1" checked>
                                            <cfinput name="iid_list" value="#get_satirlar.TYPE#_#get_satirlar.IID#" type="hidden">
                                            <cfinput name="upd_type_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#upd_type#" type="hidden">
                                            <cfinput name="stock_id_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#get_satirlar.STOCK_ID#" type="hidden">
                                            <cfinput name="spect_main_id_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#get_satirlar.SPECT_MAIN_ID#" type="hidden">

                                        </td>
                                        <!-- sil -->
                                    <cfelseif hata eq 3> 
                                        <cfset upd_type = 1><!---Ürün Transferi Eksik--->
                                        <!-- sil -->
                                        <td style="text-align:center;" nowrap="nowrap">
                                            <img src="images/control.gif" title="<cf_get_lang dictionary_id='173.Ürün Reçetesi Transfer Edilecek'>" />
                                        </td>
                                        <td style="text-align:center;" nowrap="nowrap">
                                            <input type="checkbox" id="select_#type#_#IID#" name="select_#type#_#IID#" value="1" checked>
                                            <cfinput name="iid_list" value="#get_satirlar.TYPE#_#get_satirlar.IID#" type="hidden">
                                            <cfinput name="upd_type_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#upd_type#" type="hidden">
                                            <cfinput name="stock_id_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#get_satirlar.STOCK_ID#" type="hidden">
                                            <cfinput name="spect_main_id_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#get_satirlar.SPECT_MAIN_ID#" type="hidden">
                                        </td>
                                        <!-- sil -->
                                    <cfelse>
                                        <cfif urun_adi neq RECETE_ADI> 
                                            <cfset upd_type = 3><!---Ürün Adı Uyumsuz--->
                                            <!-- sil -->
                                            <td style="text-align:center;" nowrap="nowrap">
                                                <img src="images/c_ok.gif" title="" />
                                            </td>
                                            <td style="text-align:center;" nowrap="nowrap">
                                                <cfinput name="iid_list" value="#get_satirlar.TYPE#_#get_satirlar.IID#" type="hidden">
                                                <cfinput name="upd_type_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#upd_type#" type="hidden">
                                                <cfinput name="stock_id_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#get_satirlar.STOCK_ID#" type="hidden">
                                                <cfinput name="spect_main_id_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#get_satirlar.SPECT_MAIN_ID#" type="hidden">
                                                <cfinput name="urun_adi_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#urun_adi#" type="hidden">
                                            </td>
                                            <!-- sil -->
                                        <cfelseif PRODUCT_STATUS neq 1> 
                                            <cfset upd_type = 4><!---Ürün Pasif Edilmiş--->
                                            <!-- sil -->
                                            <td style="text-align:center;" nowrap="nowrap">
                                                <img src="images/d_ok.gif" title="<cf_get_lang dictionary_id='176.Ürün Pasif Edilmiş'>" />
                                            </td>
                                            <td style="text-align:center;" nowrap="nowrap">
                                                <input type="checkbox" id="select_#type#_#IID#" name="select_#type#_#IID#" value="1">
                                                <cfinput name="iid_list" value="#get_satirlar.TYPE#_#get_satirlar.IID#" type="hidden">
                                                <cfinput name="upd_type_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#upd_type#" type="hidden">
                                                <cfinput name="stock_id_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#get_satirlar.STOCK_ID#" type="hidden">
                                                <cfinput name="spect_main_id_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#get_satirlar.SPECT_MAIN_ID#" type="hidden">
                                            </td>
                                            <!-- sil -->
                                        <cfelse>
                                        	<!-- sil -->
                                            <td style="text-align:center;" nowrap="nowrap"><img src="images/c_ok.gif" title="<cf_get_lang dictionary_id='175.Uyumlu'>" /></td>
                                            <td style="text-align:center;" nowrap="nowrap"></td>
                                            <!-- sil -->
                                        </cfif>
                                    </cfif>
                                <cfelse>
                                    <cfinput type="hidden" id="select_#type#_#IID#" name="select_#type#_#IID#" value="0">
                                    <cfinput name="iid_list" value="#get_satirlar.TYPE#_#get_satirlar.IID#" type="hidden">
                                    <cfinput name="upd_type_#get_satirlar.TYPE#_#get_satirlar.IID#" value="5" type="hidden">
                                    <cfinput name="stock_id_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#get_satirlar.STOCK_ID#" type="hidden">
                                    <cfinput name="spect_main_id_#get_satirlar.TYPE#_#get_satirlar.IID#" value="#get_satirlar.SPECT_MAIN_ID#" type="hidden">
                                    <!-- sil -->
                                    <td style="text-align:center;" nowrap="nowrap">
                                        <img src="images/lock_buton.gif" title="<cf_get_lang dictionary_id='175.Uyumlu'>" />
                                    </td>
                                    <td style="text-align:center;" nowrap="nowrap"></td>
                                    <!-- sil -->
                                </cfif>
                            </tr>
                        </cfoutput>
                        <tfoot>
                            <tr>
                            	<!-- sil -->
                                <td colspan="6" height="20" style="text-align:right">
                                    <cfsavecontent variable="upd_wcube"><cf_get_lang dictionary_id='928.Workcube Güncelle'></cfsavecontent>
                                    <cf_workcube_buttons is_upd='1' is_delete='0' add_function='control_product_tree()' insert_info="#upd_wcube#">            
                                </td>
                                <!-- sil -->
                            </tr>
                        </tfoot>
                    <cfelse>
                        <tr> 
                            <td colspan="6" height="20"><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</td>
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