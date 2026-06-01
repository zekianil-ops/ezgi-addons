<!---
    File: cnt_ezgi_import_private_creative_workcube.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 	


<cfset is_transfer = 1>
<cfset urun_type = 0>
<cfset attributes.is_configure = 1>
<cfquery name="get_defaults" datasource="#dsn3#">
    SELECT  
        EDP.*,      
        S1.STOCK_ID AS PROTOTIP_PIECE_1_STOCK_ID, 
        S2.STOCK_ID AS PROTOTIP_PIECE_2_STOCK_ID, 
        S3.STOCK_ID AS PROTOTIP_PIECE_3_STOCK_ID
    FROM            
        STOCKS AS S3 WITH (NOLOCK) INNER JOIN
        EZGI_DESIGN_PIECE_ROWS AS EDPR3 WITH (NOLOCK) ON S3.STOCK_ID = EDPR3.PIECE_RELATED_ID RIGHT OUTER JOIN
        EZGI_DESIGN_DEFAULTS AS EDP WITH (NOLOCK) ON EDPR3.PIECE_ROW_ID = EDP.PROTOTIP_PIECE_3_ID LEFT OUTER JOIN
        EZGI_DESIGN_PIECE_ROWS AS EDPR2 WITH (NOLOCK) INNER JOIN
        STOCKS AS S2 WITH (NOLOCK) ON EDPR2.PIECE_RELATED_ID = S2.STOCK_ID ON EDP.PROTOTIP_PIECE_2_ID = EDPR2.PIECE_ROW_ID LEFT OUTER JOIN
        STOCKS AS S1 WITH (NOLOCK) INNER JOIN
        EZGI_DESIGN_PIECE_ROWS AS EDPR1 WITH (NOLOCK) ON S1.STOCK_ID = EDPR1.PIECE_RELATED_ID ON EDP.PROTOTIP_PIECE_1_ID = EDPR1.PIECE_ROW_ID
</cfquery>
<cfquery name="get_colors" datasource="#dsn3#">
    SELECT * FROM EZGI_COLORS WITH (NOLOCK) ORDER BY COLOR_NAME
</cfquery>
<cfoutput query="get_colors">
    <cfset 'COLOR_NAME_#COLOR_ID#' = COLOR_NAME>
</cfoutput>
<cfquery name="get_design_info" datasource="#dsn3#">
    SELECT 
        ED.DESIGN_NAME, 
        ED.PROCESS_ID ,
        (SELECT MEMBER_CODE FROM #dsn_alias#.COMPANY WHERE COMPANY_ID = ED.COMPANY_ID) AS MEMBER_CODE,
        ISNULL(ED.IS_PROTOTIP,0) AS IS_PROTOTIP
    FROM 
        EZGI_DESIGN AS ED  WITH (NOLOCK) 	
    WHERE 
        ED.DESIGN_ID = #attributes.design_id#
</cfquery>
<cfif not len(get_defaults.PROTOTIP_PIECE_1_STOCK_ID) or not len(get_defaults.PROTOTIP_PIECE_2_STOCK_ID) or not len(get_defaults.PROTOTIP_PIECE_3_STOCK_ID)>
    <script type="text/javascript">
        alert("<cf_get_lang dictionary_id='149.Önce Tasarım Genel Default Bilgilerini Tanımlayınız!'>");
        window.close()
    </script>
    <cfabort>
</cfif>
<cfif Listlen(attributes.iid_list)>
    <cfloop list="#attributes.iid_list#" index="i"> <!---Kontrol Döngüsü--->
        <cfif isdefined('attributes.select_#i#') and len(Evaluate('attributes.select_#i#'))>
            <cfif Evaluate('attributes.upd_type_#i#') eq 2><!---Düzenleme Şekli - Ürün Ağacı İçerik Düzenleme İse--->
                <cfif isdefined('attributes.STOCK_ID_#i#')>
                    <cfif ListGetAt(i,1,'_') eq 1> <!---Parça İse--->
                        
                    <cfelseif ListGetAt(i,1,'_') eq 2> <!---Paket İse--->
                    
                    <cfelseif ListGetAt(i,1,'_') eq 3> <!---Modül İse--->
                        
                    </cfif>
                </cfif>
            <cfelseif Evaluate('attributes.upd_type_#i#') eq 1><!---Düzenleme Şekli - Ürün Yeni Açılacak İse--->
                <cfif ListGetAt(i,1,'_') eq 1> <!---Parça İse--->
                    <cfquery name="get_piece_all" datasource="#dsn3#">
                        SELECT        
                            E.PIECE_ROW_ID, 
                            E.PIECE_NAME, 
                            E.PIECE_CODE, 
                            E.PIECE_COLOR_ID,
                            E.PIECE_AMOUNT, 
                            E.PIECE_DETAIL,
                            ISNULL(TBL_1.AMOUNT, 0) AS USED_AMOUNT, 
                            E.DESIGN_PACKAGE_ROW_ID, 
                            E.DESIGN_MAIN_ROW_ID, 
                            E.PIECE_RELATED_ID, 
                            E.PIECE_TYPE,
                            0 AS SAME_PIECE_ID
                        FROM            
                            EZGI_DESIGN_PIECE_ROWS AS E WITH (NOLOCK) LEFT OUTER JOIN
                            (
                                SELECT        
                                    RELATED_PIECE_ROW_ID, 
                                    SUM(AMOUNT) AS AMOUNT
                                FROM            
                                    EZGI_DESIGN_PIECE_ROW WITH (NOLOCK)
                                GROUP BY 
                                    RELATED_PIECE_ROW_ID
                            ) AS TBL_1 ON E.PIECE_ROW_ID = TBL_1.RELATED_PIECE_ROW_ID
                        WHERE        
                            E.PIECE_ROW_ID = #ListGetAt(i,2,'_')#
                    </cfquery>
                    <cfif get_piece_all.recordcount>
                        <cfquery name="get_piece_1_control" dbtype="query"> <!---Paket Tanımlanmamış Parça Kontrolü--->
                            SELECT * FROM  get_piece_all WHERE PIECE_TYPE IN (1, 2, 3) AND DESIGN_PACKAGE_ROW_ID IS NULL AND USED_AMOUNT = 0
                        </cfquery>
                        <!---Pakete Girmemiş Parça Var mı?--->
                        <cfif get_piece_1_control.recordcount>
                            <script type="text/javascript">
                                alert("<cf_get_lang dictionary_id='954.Parçalar İçinde Paket Tanımlanmamış Satırlar Mevcut Önce Düzenleme Yapınız!'>");
                                window.close();
                            </script>
                            <cfabort>
                        </cfif>
                    <cfelse>
                        <script type="text/javascript">
                            alert("<cf_get_lang dictionary_id='955.Parça Silinmiş!'>");
                            window.close();
                        </script>
                        <cfabort>
                    </cfif>
                <cfelseif ListGetAt(i,1,'_') eq 2> <!---Paket İse--->
                    <cfquery name="get_package_all" datasource="#dsn3#">
                        SELECT        
                            EDP.PACKAGE_ROW_ID, 
                            EDP.PACKAGE_NUMBER, 
                            EDP.PACKAGE_NAME, 
                            EDP.PACKAGE_BOYU, 
                            EDP.PACKAGE_ENI, 
                            EDP.PACKAGE_KALINLIK, 
                            EDP.PACKAGE_WEIGHT, 
                            EDP.PACKAGE_AMOUNT, 
                            EDP.PACKAGE_DETAIL, 
                            EDP.PACKAGE_RELATED_ID,
                            EDP.DESIGN_MAIN_ROW_ID,
                            EDM.DESIGN_MAIN_NAME,
                            1 AS PARCA_SAYISI
                        FROM            
                            EZGI_DESIGN_PACKAGE EDP WITH (NOLOCK) LEFT JOIN
                            EZGI_DESIGN_MAIN_ROW EDM WITH (NOLOCK) ON EDP.DESIGN_MAIN_ROW_ID = EDM.DESIGN_MAIN_ROW_ID
                        WHERE        
                            PACKAGE_ROW_ID = #ListGetAt(i,2,'_')#
                    </cfquery>
                    <cfquery name="get_package_piece_control" dbtype="query">
                        SELECT PACKAGE_ROW_ID, PACKAGE_NAME, PACKAGE_NUMBER FROM get_package_all WHERE PARCA_SAYISI=0
                    </cfquery>
                    <cfif get_package_piece_control.recordcount><!---Parça Tanımlanmamış Paket Var mı?--->
                        <script type="text/javascript">
                            alert("<cf_get_lang dictionary_id='100.Paket'>: <cfoutput>#get_package_piece_control.PACKAGE_NAME#</cfoutput> <cf_get_lang dictionary_id='957.Bu Pakete Parça Tanımlanmamıştır. Lütfen Düzenleme Yapınız!'>");
                            window.close();
                        </script>
                        <cfabort>
                    </cfif>
                <cfelseif ListGetAt(i,1,'_') eq 3> <!---Modül İse--->
                    <cfquery name="get_main_all" datasource="#dsn3#">
                        SELECT        
                            EDM.DESIGN_MAIN_ROW_ID, 
                            EDM.DESIGN_MAIN_NAME, 
                            EDP.PACKAGE_RELATED_ID, 
                            EDP.PACKAGE_ROW_ID, 
                            EDP.PACKAGE_NUMBER, 
                            EDP.PACKAGE_DETAIL,
                            EDP.PACKAGE_AMOUNT
                        FROM            
                            EZGI_DESIGN_MAIN_ROW AS EDM WITH (NOLOCK) LEFT OUTER JOIN
                            EZGI_DESIGN_PACKAGE AS EDP WITH (NOLOCK) ON EDM.DESIGN_MAIN_ROW_ID = EDP.DESIGN_MAIN_ROW_ID
                        WHERE        
                            EDM.DESIGN_MAIN_ROW_ID = #ListGetAt(i,2,'_')# 
                    </cfquery>
                    <cfquery name="get_main_control" dbtype="query">
                        SELECT * FROM get_main_all WHERE PACKAGE_ROW_ID IS NULL
                    </cfquery>
                    <cfif get_main_control.recordcount> <!---Boş Modül Tanımı Var mı?--->
                        <script type="text/javascript">
                            alert("<cf_get_lang dictionary_id='141.Modül'>: <cfoutput>#get_main_control.DESIGN_MAIN_NAME#</cfoutput> <cf_get_lang dictionary_id='960.Bu Modüle Paket Tanımlanmamıştır. Lütfen Düzenleme Yapınız!'>");
                            window.close();
                        </script>
                        <cfabort>
                    </cfif>
                </cfif>
            </cfif>
        </cfif>
    </cfloop>
    <cftransaction>
        <!---Buraya Kadar Gelmişse Sorun Yok Demektir. Öncelikle Spec Kaydedilmesi gereken Ürünleri Kaydediyoruz--->
        <cfloop list="#attributes.iid_list#" index="i"> <!---Yeniden Döndürüyoruz--->
                <cfif isdefined('attributes.select_#i#') and len(Evaluate('attributes.select_#i#'))>
                    <cfif Evaluate('attributes.upd_type_#i#') eq 1><!---Düzenleme Şekli - Ürün Ağacı İçerik Düzenleme İse--->
                        <cfif ListGetAt(i,1,'_') eq 1> <!---Parça İse--->
                            <cfquery name="get_piece_all" datasource="#dsn3#">
                                SELECT        
                                    PIECE_ROW_ID, 
                                    PIECE_NAME,
                                    PIECE_COLOR_ID,
                                    PIECE_DETAIL,
                                    PIECE_RELATED_ID,
                                    PIECE_TYPE,
                                    (
                                        SELECT        
                                            WRK_ROW_RELATION_ID
                                        FROM            
                                            EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
                                        WHERE        
                                            DESIGN_MAIN_ROW_ID = EZGI_DESIGN_PIECE.DESIGN_MAIN_ROW_ID 
                                    ) AS WRK_ROW_RELATION_ID,
                                    (
                                        SELECT        
                                            O.OFFER_NUMBER
                                        FROM           
                                            EZGI_DESIGN_MAIN_ROW AS EDM WITH (NOLOCK) INNER JOIN
                                            OFFER_ROW AS OFR WITH (NOLOCK) ON EDM.WRK_ROW_RELATION_ID = OFR.WRK_ROW_ID INNER JOIN
                                            OFFER AS O WITH (NOLOCK) ON OFR.OFFER_ID = O.OFFER_ID
                                        WHERE        
                                            EDM.DESIGN_MAIN_ROW_ID = EZGI_DESIGN_PIECE.DESIGN_MAIN_ROW_ID 
                                    ) AS OFFER_NUMBER
                                FROM            
                                    EZGI_DESIGN_PIECE
                                WHERE        
                                    PIECE_ROW_ID = #ListGetAt(i,2,'_')#
                            </cfquery>
                            <cfset PIECE_TYPE = get_piece_all.PIECE_TYPE >
                            <cfset urun_adi = '#get_design_info.DESIGN_NAME# #get_piece_all.PIECE_NAME# - #get_design_info.MEMBER_CODE# - #get_piece_all.OFFER_NUMBER# - #get_piece_all.WRK_ROW_RELATION_ID#'> <!---Ürün Adı Tanımı--->
                            <cfif len(get_piece_all.PIECE_RELATED_ID)> <!---Tasarımdaki Parça Stok ID ile gelmiş ise onu kullanıyoruz.--->
                                <cfset 'attributes.STOCK_ID_#i#' = get_piece_all.PIECE_RELATED_ID>
                            </cfif>
                            <cfinclude template="../query/add_ezgi_private_spect_main.cfm"> <!---Yeni Main_Spect Açıyoruz--->
                            <cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Yeni Açılan Main_Spect İle Parçayı İlşkilendiriyoruz.--->
                                UPDATE 
                                    EZGI_DESIGN_PIECE_ROWS 
                                SET 
                                    PIECE_SPECT_RELATED_ID = #GET_MAX.SPECT_MAIN_ID#
                                WHERE 
                                    PIECE_ROW_ID = #get_piece_all.PIECE_ROW_ID#
                            </cfquery>
                            <cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Yeni Açılan Main_Spect in Stok _ıd si İle Parçayı İlşkilendiriyoruz.--->
                                UPDATE 
                                    EZGI_DESIGN_PIECE_ROWS 
                                SET 
                                    PIECE_RELATED_ID = #Evaluate('attributes.STOCK_ID_#i#')#
                                WHERE 
                                    PIECE_ROW_ID = #get_piece_all.PIECE_ROW_ID# AND
                                    PIECE_RELATED_ID IS NULL
                            </cfquery>
                            <cfoutput>'attributes.STOCK_ID_#i#' = #Evaluate('attributes.STOCK_ID_#i#')#<br></cfoutput>
                            <cfset 'attributes.upd_type_#i#' = 2> <!---Artık Reçete Yapılabilir Hale Getiriyoruz--->
                            <cfset 'attributes.SPECT_MAIN_ID_#i#' = GET_MAX.SPECT_MAIN_ID>
                        <cfelseif ListGetAt(i,1,'_') eq 2> <!---Paket İse--->
                            <cfquery name="get_package_all" datasource="#dsn3#">
                                SELECT        
                                    PACKAGE_ROW_ID, 
                                    PACKAGE_NAME,
                                    PACKAGE_DETAIL,
                                    (
                                        SELECT        
                                            WRK_ROW_RELATION_ID
                                        FROM            
                                            EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
                                        WHERE        
                                            DESIGN_MAIN_ROW_ID = EZGI_DESIGN_PACKAGE.DESIGN_MAIN_ROW_ID 
                                    ) AS WRK_ROW_RELATION_ID,
                                    (
                                        SELECT        
                                            O.OFFER_NUMBER
                                        FROM           
                                            EZGI_DESIGN_MAIN_ROW AS EDM WITH (NOLOCK) INNER JOIN
                                            OFFER_ROW AS OFR WITH (NOLOCK) ON EDM.WRK_ROW_RELATION_ID = OFR.WRK_ROW_ID INNER JOIN
                                            OFFER AS O WITH (NOLOCK) ON OFR.OFFER_ID = O.OFFER_ID
                                        WHERE        
                                            EDM.DESIGN_MAIN_ROW_ID = EZGI_DESIGN_PACKAGE.DESIGN_MAIN_ROW_ID 
                                    ) AS OFFER_NUMBER
                                FROM            
                                    EZGI_DESIGN_PACKAGE WITH (NOLOCK)
                                WHERE        
                                    PACKAGE_ROW_ID = #ListGetAt(i,2,'_')#
                            </cfquery>
                            <cfset urun_adi = '#get_package_all.PACKAGE_NAME# - #get_design_info.MEMBER_CODE# - #get_package_all.OFFER_NUMBER# - #get_package_all.WRK_ROW_RELATION_ID#'> <!---Ürün Adı Tanımı--->
                            <cfinclude template="../query/add_ezgi_private_spect_main.cfm"> <!---Yeni Main_Spect Açıyoruz--->
                            <cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Yeni Açılan Main_Spect İle Parçayı İlşkilendiriyoruz.--->
                                UPDATE 
                                    EZGI_DESIGN_PACKAGE_ROW 
                                SET 
                                    PACKAGE_SPECT_RELATED_ID = #GET_MAX.SPECT_MAIN_ID#,
                                    PACKAGE_RELATED_ID = #Evaluate('attributes.STOCK_ID_#i#')#
                                WHERE  
                                    PACKAGE_ROW_ID = #get_package_all.PACKAGE_ROW_ID#
                            </cfquery>
                            <cfset 'attributes.upd_type_#i#' = 2> <!---Artık Reçete Yapılabilir Hale Getiriyoruz--->
                            <cfset 'attributes.SPECT_MAIN_ID_#i#' = GET_MAX.SPECT_MAIN_ID>
                        <cfelseif ListGetAt(i,1,'_') eq 3> <!---Modül İse--->
                            <cfquery name="get_main_all" datasource="#dsn3#">
                                SELECT        
                                    DESIGN_MAIN_ROW_ID, 
                                    DESIGN_MAIN_NAME,
                                    WRK_ROW_RELATION_ID,
                                    (
                                        SELECT        
                                            O.OFFER_NUMBER
                                        FROM            
                                            OFFER_ROW AS OFR WITH (NOLOCK) INNER JOIN
                                            OFFER AS O WITH (NOLOCK) ON OFR.OFFER_ID = O.OFFER_ID
                                        WHERE        
                                            OFR.WRK_ROW_ID = EZGI_DESIGN_MAIN_ROW.WRK_ROW_RELATION_ID
                                    ) AS OFFER_NUMBER
                                FROM            
                                    EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
                                WHERE        
                                    DESIGN_MAIN_ROW_ID = #ListGetAt(i,2,'_')# 
                            </cfquery>
                            <cfset urun_adi = '#get_main_all.DESIGN_MAIN_NAME# - #get_design_info.MEMBER_CODE# - #get_main_all.OFFER_NUMBER# - #get_main_all.WRK_ROW_RELATION_ID#'> <!---Ürün Adı Tanımı--->
                            <cfinclude template="add_ezgi_private_spect_main.cfm"> <!---Yeni Main_Spect Açıyoruz--->
                            <cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Yeni Açılan Main_Spect İle Parçayı İlşkilendiriyoruz.--->
                                UPDATE EZGI_DESIGN_MAIN_ROW SET MAIN_SPECT_RELATED_ID = #GET_MAX.SPECT_MAIN_ID# WHERE DESIGN_MAIN_ROW_ID = #get_main_all.DESIGN_MAIN_ROW_ID#
                            </cfquery>
                            <cfquery name="upd_offer_row_info" datasource="#dsn3#">
                                UPDATE 
                                    OFFER_ROW
                                SET                
                                    SPECT_VAR_ID = #get_spect_var_max.SPECT_VAR_ID#, 
                                    SPECT_VAR_NAME = '#urun_adi#'
                                WHERE        
                                    WRK_ROW_ID = '#get_main_all.WRK_ROW_RELATION_ID#'
                            </cfquery>
                            <cfset 'attributes.upd_type_#i#' = 2> <!---Artık Reçete Yapılabilir Hale Getiriyoruz--->
                            <cfset 'attributes.SPECT_MAIN_ID_#i#' = GET_MAX.SPECT_MAIN_ID>
                        </cfif>
                    </cfif>
                </cfif>
        </cfloop>
        <!---Ürün Reçete Kaydı veya Düzeltme Başlangıcı--->
        <cfloop list="#attributes.iid_list#" index="i"> <!---İşlem Döngüsü--->
            <cfif isdefined('attributes.select_#i#') and len(Evaluate('attributes.select_#i#'))>
                <cfif Evaluate('attributes.upd_type_#i#') eq 2> <!---Düzenleme Şekli - Ürün Reçetesi Farklı İse--->
                    <cfif isdefined('SPECT_MAIN_ID_#i#')> <!--- Spect Main Tanımlı İse--->
                        <cfquery name="del_product_tree" datasource="#dsn3#"> <!---Spect_Main_row lar siliniyor--->
                            DELETE FROM SPECT_MAIN_ROW WHERE SPECT_MAIN_ID = #Evaluate('attributes.SPECT_MAIN_ID_#i#')#
                        </cfquery>
                    </cfif>
                    <cfif ListGetAt(i,1,'_') eq 1> <!---Parça İse Parça Tipini Arıyoruz--->
                        <cfquery name="get_stock_control" datasource="#dsn3#">
                            SELECT PIECE_TYPE FROM EZGI_DESIGN_PIECE WITH (NOLOCK) WHERE PIECE_ROW_ID = #ListGetAt(i,2,'_')#
                        </cfquery>
                        <cfset PIECE_TYPE = get_stock_control.PIECE_TYPE >
                    <cfelse>
                        <cfset PIECE_TYPE = 0>
                    </cfif>
                    <cfset type = ListGetAt(i,1,'_')>
                    <cfset IID = ListGetAt(i,2,'_')>
                    <cfinclude template="../query/cnt_ezgi_product_tree_import_ortak.cfm">
                    <cfquery name="get_product_tree" dbtype="query">
                        SELECT * FROM get_product_tree ORDER BY OPERATION_TYPE_ID DESC, RELATED_ID
                    </cfquery>
                    <cfif get_product_tree.recordcount>
                        <cfloop query="#get_product_tree#">
                            <cfif get_product_tree.RELATED_ID eq 0> <!---Operasyon İse--->
                                <cfset attributes.add_stock_id = ''>
                                <cfset attributes.UNIT_ID = ''>
                                <cfset attributes.spect_main_id = ''>
                                <cfset attributes.product_id = ''>
                                <cfset attributes.product_name = ''>
                                <cfset attributes.operation_type_id = get_product_tree.OPERATION_TYPE_ID>
                                <cfset attributes.AMOUNT = get_product_tree.AMOUNT>
                                <cfset attributes.process_stage_ = get_defaults.DEFAULT_PRODUCT_TREE_PROCESS_STAGE>
                                <cfset attributes.spect_related_id = 0>
                            <cfelse><!---Ürün İse--->
                                <cfif not len(get_product_tree.RELATED_ID)>
                                	Hata : Stok ID bağlantı sorunu
                                    <cfdump var="#get_product_tree#"><cfdump var="#get_material_3#"><cfabort>
                                    
                                </cfif>
                                <cfquery name="get_stock_info" datasource="#dsn3#"><!--- Stok Bilgileri Toplanıyor--->
                                    SELECT        
                                        S.PRODUCT_ID, 
                                        P.PRODUCT_CODE, 
                                        P.PRODUCT_NAME,
                                        ISNULL(P.IS_PROTOTYPE,0) AS IS_PROTOTYPE,
                                        ISNULL(P.IS_PRODUCTION,0) AS IS_PRODUCTION,
                                        PU.MAIN_UNIT, 
                                        PU.PRODUCT_UNIT_ID,
                                        <cfif get_defaults.IS_HIZMET_PHANTOM eq 1>
                                            CASE
                                                WHEN ISNULL(P.IS_PRODUCTION,0) = 0
                                                THEN 0
                                                ELSE
                                                    ISNULL((
                                                            SELECT 
                                                                PRODUCT_CATID 
                                                            FROM 
                                                                PRODUCT_CAT WITH (NOLOCK) 
                                                            WHERE 
                                                                LIST_ORDER_NO IN (1,5) AND PRODUCT_CATID = S.PRODUCT_CATID),0) 
                                            END AS IS_PHANTOM
                                        <cfelse>
                                            0 AS IS_PHANTOM
                                        </cfif>
                                    FROM            
                                        STOCKS AS S WITH (NOLOCK) INNER JOIN
                                        PRODUCT AS P WITH (NOLOCK) ON S.PRODUCT_ID = P.PRODUCT_ID INNER JOIN
                                        PRODUCT_UNIT AS PU WITH (NOLOCK) ON P.PRODUCT_ID = PU.PRODUCT_ID
                                    WHERE        
                                        S.STOCK_ID = #get_product_tree.RELATED_ID# AND 
                                        PU.IS_MAIN = 1
                                </cfquery>
                                <cfif get_stock_info.recordcount>
                                    <cfif get_stock_info.IS_PRODUCTION>
                                        <cfif get_stock_info.IS_PROTOTYPE>
                                            <cfset attributes.spect_related_id = get_product_tree.SPECT_RELATED_ID>
                                        <cfelse>
                                            <cfquery name="get_spect_main_id" datasource="#dsn3#">
                                                SELECT        
                                                    TOP (1) SPECT_MAIN_ID
                                                FROM   
                                                    SPECT_MAIN WITH (NOLOCK)
                                                WHERE        
                                                    STOCK_ID = #get_product_tree.RELATED_ID#
                                                ORDER BY 
                                                    SPECT_MAIN_ID DESC
                                            </cfquery>
                                            <cfset attributes.spect_related_id = get_spect_main_id.SPECT_MAIN_ID>
                                        </cfif>
                                    <cfelse>
                                        <cfset attributes.spect_related_id = get_product_tree.SPECT_RELATED_ID>
                                    </cfif>
                                    
                                    <cfset attributes.product_id = get_stock_info.PRODUCT_ID>
                                    <cfset attributes.product_name = get_stock_info.PRODUCT_NAME>
                                    <cfset attributes.add_stock_id = get_product_tree.RELATED_ID>
                                    <cfset attributes.UNIT_ID = get_stock_info.PRODUCT_UNIT_ID>
                                    <cfset attributes.main_unit = get_stock_info.MAIN_UNIT>
                                    <cfset attributes.AMOUNT = get_product_tree.AMOUNT>
                                    
                                    <cfset attributes.process_stage_ = get_defaults.DEFAULT_PRODUCT_TREE_PROCESS_STAGE>
                                    <cfset attributes.operation_type_id = ''>
                                    <cfif get_defaults.IS_HIZMET_PHANTOM eq 1>
                                        <cfif GET_STOCK_INFO.IS_PHANTOM gt 0>
                                            <cfset attributes.is_phantom = 1>
                                        <cfelse>
                                            <cfset attributes.is_phantom = ''>
                                        </cfif>
                                    <cfelse>
                                        <cfset attributes.is_phantom = ''>
                                    </cfif>
                                <cfelse>
                                    <cfoutput>#get_product_tree.RELATED_ID#</cfoutput> STOCK_ID ile Eklenecek Ürüne Ait Bilgi Bulunamadı.
                                    <cfabort>
                                </cfif>
                            </cfif>
                            <cfinclude template="add_ezgi_private_spect_main_row.cfm">
                        </cfloop>
                    </cfif>
                </cfif>
            </cfif>
        </cfloop>
    </cftransaction>
    <cfif isdefined('attributes.popup_window')>
        <script type="text/javascript">
            wrk_opener_reload();
            window.close()
        </script>
    <cfelse>
        <cfif isdefined('attributes.design_main_row_id')>
            <cflocation url="#request.self#?fuseaction=prod.popup_cnt_ezgi_private_product_tree_import&design_id=#attributes.design_id#&design_main_row_id=#attributes.design_main_row_id#" addtoken="No">
        <cfelse>
            <cflocation url="#request.self#?fuseaction=prod.popup_cnt_ezgi_private_product_tree_import&design_id=#attributes.design_id#" addtoken="No">
        </cfif>
    </cfif>
<cfelse>
    Eşitleme Yapılacak Tasarım Kaydı Bulunamadı
    <cfabort>
</cfif>


