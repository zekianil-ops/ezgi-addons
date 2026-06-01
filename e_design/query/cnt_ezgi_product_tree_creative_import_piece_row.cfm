<!---
    File: cnt_ezgi_product_tree_creative_import_piece_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 	

<cfquery name="dbl_satirlar_1" dbtype="query">
 	SELECT design_code_piece_row, COUNT(*) AS SAYI FROM satirlar GROUP BY design_code_piece_row HAVING COUNT(*) > 1
</cfquery>
<cfquery name="dbl_satirlar_2" dbtype="query">
 	SELECT default_type, COUNT(*) AS SAYI FROM satirlar GROUP BY default_type HAVING COUNT(*) > 1
</cfquery>

<cfif dbl_satirlar_1.recordcount>
	<script type="text/javascript">
    	alert("<cf_get_lang dictionary_id='961.Parça Kodu Birden Fazla Tekrarlanmış.'>");
      	history.back();
   	</script>
    <cfabort>
</cfif>
<cfif dbl_satirlar_2.recordcount>
	<script type="text/javascript">
    	alert("<cf_get_lang dictionary_id='962.Default Parça ID Birden Fazla Tekrarlanmış.'>");
      	
   	</script>
</cfif>

<cfloop query="satirlar">
	<cfset attributes.piece_type = satirlar.piece_type>
	<cfif  attributes.piece_type eq 1>
		<cfset satir = currentrow + 1>
        <!---Değer Kontrol Satırları--->
        <cfif not isnumeric(satirlar.design_code_piece_row) or satirlar.design_code_piece_row lte 0>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Satır'> :<cfoutput>#satir#</cfoutput><cf_get_lang dictionary_id='1006.Bu Satırdaki Parça Kodunu Kontrol Ediniz.'>");
                history.back();
            </script>
            <cfabort>
        </cfif>
        <cfif not isnumeric(satirlar.default_type) or satirlar.default_type lte 0>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Satır'> :<cfoutput>#satir#</cfoutput><cf_get_lang dictionary_id='1005.Bu Satırdaki Default Parça ID sini Kontrol Ediniz.'>");
                history.back();
            </script>
            <cfabort>
        </cfif>
        <cfif (len(satirlar.color_type) gt 0 and not isnumeric(satirlar.color_type)) or (len(satirlar.color_type) gt 0 and satirlar.color_type lte 0)>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Satır'> :<cfoutput>#satir#</cfoutput><cf_get_lang dictionary_id='1004.Bu Satırdaki Renk ID sini Kontrol Ediniz.'>");
                history.back();
            </script>
            <cfabort>
        </cfif>
        <cfif not isnumeric(satirlar.piece_amount) or satirlar.piece_amount lte 0>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Satır'> :<cfoutput>#satir#</cfoutput> <cf_get_lang dictionary_id='1003.Bu Satırdaki Parça Miktarını Kontrol Ediniz.'>");
                history.back();
            </script>
            <cfabort>
        </cfif>
        <cfif (len(satirlar.piece_kalinlik) gt 0 and not isnumeric(satirlar.piece_kalinlik)) or (len(satirlar.piece_kalinlik) gt 0 and satirlar.piece_kalinlik lte 0)>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Satır'> :<cfoutput>#satir#</cfoutput><cf_get_lang dictionary_id='58508.Bu Satırdaki Kalınlık ID sini Kontrol Ediniz.'>");
                history.back();
            </script>
            <cfabort>
        </cfif>
        <cfif not isnumeric(satirlar.piece_boy) or satirlar.piece_boy lte 0>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Satır'> :<cfoutput>#satir#</cfoutput><cf_get_lang dictionary_id='1013.Bu Satırdaki Parça Boyunu Kontrol Ediniz.'>");
                history.back();
            </script>
            <cfabort>
        </cfif>
        <cfif not isnumeric(satirlar.piece_en) or satirlar.piece_en lte 0>

            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Bu Satırdaki Parça Enini Kontrol Ediniz.'> :<cfoutput>#satir#</cfoutput><cf_get_lang dictionary_id='1012.Bu Satırdaki Parça Enini Kontrol Ediniz.'>");
                history.back();
            </script>
            <cfabort>
        </cfif>
        <cfif (len(satirlar.piece_package_no) gt 0 and not isnumeric(satirlar.piece_package_no)) or (len(satirlar.piece_package_no) gt 0 and satirlar.piece_package_no lte 0)>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Satır'> :<cfoutput>#satir#</cfoutput><cf_get_lang dictionary_id='1011.Bu Satırdaki Paket ID sini Kontrol Ediniz.'>");
                history.back();
            </script>
            <cfabort>
        </cfif>
        <cfif (len(satirlar.pvc_materials_1) gt 0 and not isnumeric(satirlar.pvc_materials_1)) or (len(satirlar.pvc_materials_1) gt 0 and satirlar.pvc_materials_1 lte 0)>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Satır'> :<cfoutput>#satir#</cfoutput> <cf_get_lang dictionary_id='1010.Bu Satırdaki 1.Kısa Kenar Değerini Kontrol Ediniz.'>");
                history.back();
            </script>
            <cfabort>
        </cfif>
        <cfif (len(satirlar.pvc_materials_2) gt 0 and not isnumeric(satirlar.pvc_materials_2)) or (len(satirlar.pvc_materials_2) gt 0 and satirlar.pvc_materials_2 lte 0)>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Satır'> :<cfoutput>#satir#</cfoutput> <cf_get_lang dictionary_id='1009.Bu Satırdaki 2.Kısa Kenar Değerini Kontrol Ediniz.'>");
                history.back();
            </script>
            <cfabort>
        </cfif>
        <cfif (len(satirlar.pvc_materials_3) gt 0 and not isnumeric(satirlar.pvc_materials_3)) or (len(satirlar.pvc_materials_3) gt 0 and satirlar.pvc_materials_3 lte 0)>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Satır'> :<cfoutput>#satir#</cfoutput> <cf_get_lang dictionary_id='1008.Bu Satırdaki 1.Uzun Kenar Değerini Kontrol Ediniz.'>");
                history.back();
            </script>
            <cfabort>
        </cfif>
        <cfif (len(trim(satirlar.pvc_materials_4)) gt 0 and not isnumeric(trim(satirlar.pvc_materials_4))) or (len(trim(satirlar.pvc_materials_4)) gt 0 and trim(satirlar.pvc_materials_4) lt 0)>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Satır'> :<cfoutput>#satir#</cfoutput> <cf_get_lang dictionary_id='1007.Bu Satırdaki 2.Uzun Kenar Değerini Kontrol Ediniz.'>");
                history.back();
            </script>
            <cfabort>
        </cfif>
        <!---PVC Stok ID Kontrol Satırları--->
        <cfif satirlar.anahtar_1 eq 1 and len(satirlar.anahtar_1)>
            <cfquery name="control_stock_id" datasource="#dsn3#">
                SELECT STOCK_ID FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #satirlar.pvc_materials_1#
            </cfquery>
            <cfif not control_stock_id.recordcount>
                <script type="text/javascript">
                    alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cfoutput>#satir#. Satırdaki #satirlar.pvc_materials_1# STOCK_ID Değerini Kontrol Ediniz.</cfoutput>");
                    history.back();
                </script>
                <cfabort>
            </cfif>
        </cfif>
        <cfif satirlar.anahtar_2 eq 1 and len(satirlar.anahtar_2)>
            <cfquery name="control_stock_id" datasource="#dsn3#">
                SELECT STOCK_ID FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #satirlar.pvc_materials_2#
            </cfquery>
            <cfif not control_stock_id.recordcount>
                <script type="text/javascript">
                    alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cfoutput>#satir#. Satırdaki #satirlar.pvc_materials_2# STOCK_ID Değerini Kontrol Ediniz.</cfoutput>");
                    history.back();
                </script>
                <cfabort>
            </cfif>
        </cfif>
        <cfif satirlar.anahtar_3 eq 1 and len(satirlar.anahtar_3)>
            <cfquery name="control_stock_id" datasource="#dsn3#">
                SELECT STOCK_ID FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #satirlar.pvc_materials_3#
            </cfquery>
            <cfif not control_stock_id.recordcount>
                <script type="text/javascript">
                    alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cfoutput>#satir#. Satırdaki #satirlar.pvc_materials_3# STOCK_ID Değerini Kontrol Ediniz.</cfoutput>");
                    history.back();
                </script>
                <cfabort>
            </cfif>
        </cfif>
        <cfif satirlar.anahtar_4 eq 1 and len(satirlar.anahtar_4)>
            <cfquery name="control_stock_id" datasource="#dsn3#">
                SELECT STOCK_ID FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #satirlar.pvc_materials_4#
            </cfquery>
            <cfif not control_stock_id.recordcount>
                <script type="text/javascript">
                    alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cfoutput>#satir#. Satırdaki #satirlar.pvc_materials_4# <cf_get_lang dictionary_id='966.STOCK_ID Değerini Kontrol Ediniz.'></cfoutput>");
                    history.back();
                </script>
                <cfabort>
            </cfif>
        </cfif>
        <!---Defaut_type Kontrolü--->
        <cfquery name="get_default_name" dbtype="query">
            SELECT PIECE_DEFAULT_NAME FROM get_piece_defaults WHERE PIECE_DEFAULT_ID = #satirlar.default_type#
        </cfquery>
        <cfif not get_default_name.recordcount>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cfoutput>#satir#. Satırdaki #satirlar.default_type# <cf_get_lang dictionary_id='964.Default Parça ID si Değerini Kontrol Ediniz.'></cfoutput>");
                history.back();
            </script>
            <cfabort>
        <cfelse>
            <cfset 'PIECE_DEFAULT_NAME_#satirlar.default_type#' = '#main_setup_name# #get_default_name.PIECE_DEFAULT_NAME#'>
        </cfif>
        <!---Paket No Kontrolü--->
        <cfif len(satirlar.piece_package_no)>
            <cfquery name="get_paket_no" dbtype="query">
                SELECT * FROM get_design_package_row WHERE PACKAGE_NUMBER = #satirlar.piece_package_no#
            </cfquery>
            <cfif not get_paket_no.recordcount>
                <script type="text/javascript">
                    alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cfoutput>#satir#. Satırdaki #satirlar.piece_package_no# <cf_get_lang dictionary_id='965.Paket No Değerini Kontrol Ediniz.'></cfoutput>");
                    history.back();
                </script>
                <cfabort>
            <cfelse>
                <cfset 'PACKAGE_ROW_ID_#satirlar.piece_package_no#' = get_paket_no.PACKAGE_ROW_ID>
            </cfif>
        </cfif>
        <!---Yonga Levha Kontrolü--->
        <cfif not len(satirlar.color_type)>
            <cfset ezgi_color_id = get_design_main_row.DESIGN_MAIN_COLOR_ID>
        <cfelse>
            <cfset ezgi_color_id = satirlar.color_type>
        </cfif>
        <cfif not len(satirlar.piece_kalinlik)>
            <cfset ezgi_kalinlik_id = default_thickness>
        <cfelse>
            <cfset ezgi_kalinlik_id = satirlar.piece_kalinlik>
        </cfif>
        <cfquery name="get_yonga_levha" datasource="#DSN3#">
            SELECT        
                *
            FROM            
                EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK)
            WHERE        
                LIST_ORDER_NO = 1 AND  
                COLOR_ID = #ezgi_color_id# AND
                THICKNESS_ID = #ezgi_kalinlik_id#
            ORDER BY 
                PRODUCT_NAME
        </cfquery>
        
        <cfif not get_yonga_levha.recordcount>
            <cfdump var="#get_yonga_levha#"><cfabort>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='967.Belirtilen Kalınlık ve Renkte Yonga Levha Tanımlanmamıştır!'>");
                history.back();
            </script>
            <cfabort>
        <cfelse>
             <cfset 'yonga_levha_#ezgi_color_id#_#ezgi_kalinlik_id#' = get_yonga_levha.STOCK_ID>
        </cfif>
  	</cfif>
</cfloop>

<cfset attributes.PIECE_TRIM_TYPE = get_main_defaults.DEFAULT_TRIM_TYPE>
<cfset attributes.trim_rate = TlFormat(get_main_defaults.DEFAULT_TRIM_AMOUNT,1)>
<cfloop query="satirlar">
	<cfset attributes.piece_type = satirlar.piece_type>
	<cfif  attributes.piece_type eq 1>
        <cfif len(satirlar.design_code_piece_row) eq 1>
            <cfset attributes.design_code_piece_row = '0#satirlar.design_code_piece_row#'>
        <cfelse>
            <cfset attributes.design_code_piece_row = satirlar.design_code_piece_row>
        </cfif>
        <cfset attributes.default_type = satirlar.default_type>
        <cfset attributes.piece_amount = satirlar.piece_amount>
        <cfset attributes.piece_boy = Tlformat(satirlar.piece_boy,1)>
        <cfset attributes.piece_en = Tlformat(satirlar.piece_en,1)>
        <cfif not len(satirlar.color_type)>
            <cfset ezgi_color_id = get_design_main_row.DESIGN_MAIN_COLOR_ID>
        <cfelse>
            <cfset ezgi_color_id = satirlar.color_type>
        </cfif>
        <cfif not len(satirlar.piece_kalinlik)>
            <cfset ezgi_kalinlik_id = default_thickness>
        <cfelse>
            <cfset ezgi_kalinlik_id = satirlar.piece_kalinlik>
        </cfif>
        <cfset attributes.color_type = ezgi_color_id>
        <cfset attributes.piece_kalinlik = ezgi_kalinlik_id>
        <cfif len(satirlar.piece_su_yonu)>
            <cfif satirlar.piece_su_yonu eq 0>
                <cfset attributes.piece_su_yonu = satirlar.piece_su_yonu>
            <cfelse>
                <cfset attributes.piece_su_yonu = 1>
            </cfif>
        <cfelse>
            <cfset attributes.piece_su_yonu = 1>
        </cfif>
        <!---<cfset attributes.piece_package_no = satirlar.piece_package_no>--->
        <cfif len(satirlar.piece_package_no)>
            <cfset attributes.piece_package_no = Evaluate('PACKAGE_ROW_ID_#satirlar.piece_package_no#')>
        <cfelse>
            <cfset attributes.piece_package_no = ''>
        </cfif>
        <cfif len(satirlar.anahtar_1)>
            <cfset attributes.anahtar_1 = satirlar.anahtar_1>
        <cfelse>
            <cfset attributes.anahtar_1 = 0>
        </cfif>
         <cfif len(satirlar.anahtar_2)>
            <cfset attributes.anahtar_2 = satirlar.anahtar_2>
        <cfelse>
            <cfset attributes.anahtar_2 = 0>
        </cfif>
         <cfif len(satirlar.anahtar_3)>
            <cfset attributes.anahtar_3 = satirlar.anahtar_3>
        <cfelse>
            <cfset attributes.anahtar_3 = 0>
        </cfif>
         <cfif len(satirlar.anahtar_4)>
            <cfset attributes.anahtar_4 = satirlar.anahtar_4>
        <cfelse>
            <cfset attributes.anahtar_4 = 0>
        </cfif>
        <cfset attributes.pvc_materials_1 = satirlar.pvc_materials_1>
        <cfset attributes.pvc_materials_2 = satirlar.pvc_materials_2>
        <cfset attributes.pvc_materials_3 = satirlar.pvc_materials_3>
        <cfset attributes.pvc_materials_4 = satirlar.pvc_materials_4>
        <cfif isdefined('satirlar.pvc_select_1')>
            <cfset attributes.pvc_select_1 = satirlar.pvc_select_1>
        </cfif>
        <cfif isdefined('satirlar.pvc_select_2')>
            <cfset attributes.pvc_select_2 = satirlar.pvc_select_2>
        </cfif>
        <cfif isdefined('satirlar.pvc_select_3')>
            <cfset attributes.pvc_select_3 = satirlar.pvc_select_3>
        </cfif>
        <cfif isdefined('satirlar.pvc_select_4')>
            <cfset attributes.pvc_select_4 = satirlar.pvc_select_4>
        </cfif>
        <cfset attributes.piece_detail = satirlar.piece_detail>
        <cfset attributes.design_name_piece_row = Evaluate('PIECE_DEFAULT_NAME_#satirlar.default_type#')>
        <cfset attributes.piece_yonga_levha = Evaluate('yonga_levha_#ezgi_color_id#_#ezgi_kalinlik_id#')>
        <cfinclude template="add_ezgi_product_tree_creative_piece_row.cfm">
 	<cfelseif attributes.piece_type eq 2>
    	<cfset satir = currentrow + 1>
        <!---Değer Kontrol Satırları--->
        <cfif not isnumeric(satirlar.design_code_piece_row) or satirlar.design_code_piece_row lte 0>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Satır'> :<cfoutput>#satir#</cfoutput> <cf_get_lang dictionary_id='1006.Bu Satırdaki Parça Kodunu Kontrol Ediniz.'>");
                <!---history.back();--->
            </script>
            <cfdump var="#satirlar#">
            <cfabort>
        </cfif>
        <cfif not isnumeric(satirlar.default_type) or satirlar.default_type lte 0>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Satır'> :<cfoutput>#satir#</cfoutput> <cf_get_lang dictionary_id='1005.Bu Satırdaki Default Parça ID sini Kontrol Ediniz.'>");
                history.back();
            </script>
            <cfabort>
        </cfif>
        <cfif (len(satirlar.color_type) gt 0 and not isnumeric(satirlar.color_type)) or (len(satirlar.color_type) gt 0 and satirlar.color_type lte 0)>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Satır'> :<cfoutput>#satir#</cfoutput><cf_get_lang dictionary_id='1004.Bu Satırdaki Renk ID sini Kontrol Ediniz.'>  ");
                history.back();
            </script>
            <cfabort>
        </cfif>
        <cfif not isnumeric(satirlar.piece_amount) or satirlar.piece_amount lte 0>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cf_get_lang dictionary_id='58508.Satır'> :<cfoutput>#satir#</cfoutput> <cf_get_lang dictionary_id='1003.Bu Satırdaki Parça Miktarını Kontrol Ediniz.'>");
                history.back();
            </script>
            <cfabort>
        </cfif>
        <!---Defaut_type Kontrolü--->
        <cfquery name="get_default_name" dbtype="query">
            SELECT PIECE_DEFAULT_NAME FROM get_piece_defaults WHERE PIECE_DEFAULT_ID = #satirlar.default_type#
        </cfquery>
        <cfif not get_default_name.recordcount>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='963.Geçersiz Bilgi !'> <cfoutput>#satir#. Satırdaki #satirlar.default_type# <cf_get_lang dictionary_id='964.Default Parça ID si Değerini Kontrol Ediniz.'></cfoutput>");
                history.back();
            </script>
            <cfabort>
        <cfelse>
            <cfset attributes.design_name_piece_row = '#main_setup_name# #get_default_name.PIECE_DEFAULT_NAME#'>
        </cfif>
        <cfset attributes.piece_detail = ''>
        <cfloop query="satirlar_row">
        	<cfset 'attributes.stock_id#satirlar_row.currentrow#' = piece_row_stock_id>
            <cfset 'attributes.quantity#satirlar_row.currentrow#' = piece_row_amount>
            <cfset 'attributes.row_kontrol#satirlar_row.currentrow#' = 1>
        </cfloop>
        <cfset record_num = satirlar_row.recordcount>
        <cfinclude template="add_ezgi_product_tree_creative_piece_row.cfm">
    </cfif>
</cfloop>

