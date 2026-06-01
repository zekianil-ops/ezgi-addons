<!---
    File: add_ezgi_product_tree_creative_import_efurniturecad_for_offer.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/11/2025
    Description: E-Furniture Cad üzerinden Teklif ilişkili Özel Mobilya Tasarım Oluşturma Sorgusu
--->

<cfdump var="#attributes#">
<!---Standart Kontroller--->

<cfset attributes.parca_1 = 963>
<cfset attributes.parca_2 = 964>
<cfset attributes.parca_3 = 965>

<cfquery name="GET_DESIGN_DEFAULTS" datasource="#dsn3#">
    SELECT        
        EDR3.PIECE_RELATED_ID AS PIECE_RELATED_ID3, 
        EDR2.PIECE_RELATED_ID AS PIECE_RELATED_ID2, 
        EDR1.PIECE_RELATED_ID AS PIECE_RELATED_ID1, 
        EDM.DESIGN_MAIN_ROW_ID
    FROM            
        EZGI_DESIGN_MAIN_ROW AS EDM WITH (NOLOCK) RIGHT OUTER JOIN
        EZGI_DESIGN_DEFAULTS AS EDD WITH (NOLOCK) ON EDM.DESIGN_MAIN_ROW_ID = EDD.PROTOTIP_PACKAGE_ID LEFT OUTER JOIN
        EZGI_DESIGN_PIECE_ROWS AS EDR3 WITH (NOLOCK) ON EDD.PROTOTIP_PIECE_3_ID = EDR3.PIECE_ROW_ID LEFT OUTER JOIN
        EZGI_DESIGN_PIECE_ROWS AS EDR2 WITH (NOLOCK) ON EDD.PROTOTIP_PIECE_2_ID = EDR2.PIECE_ROW_ID LEFT OUTER JOIN
        EZGI_DESIGN_PIECE_ROWS AS EDR1 WITH (NOLOCK) ON EDD.PROTOTIP_PIECE_1_ID = EDR1.PIECE_ROW_ID
</cfquery>
<cfif not GET_DESIGN_DEFAULTS.recordcount or not len(GET_DESIGN_DEFAULTS.DESIGN_MAIN_ROW_ID) or not len(GET_DESIGN_DEFAULTS.PIECE_RELATED_ID1) or not len(GET_DESIGN_DEFAULTS.PIECE_RELATED_ID2) or not len(GET_DESIGN_DEFAULTS.PIECE_RELATED_ID3)>
	E-Design Genel Tanımlarda Özel Tasarım Tanımlarını Yapınız
	<cfdump var="#GET_DESIGN_DEFAULTS#">
    <cfabort>
</cfif>
<cfquery name="get_master_packages" datasource="#dsn3#">
	SELECT 
    	PACKAGE_ROW_ID, 
        PACKAGE_RELATED_ID, 
        CAST(PACKAGE_NUMBER AS INT) AS PACKAGE_NUMBER
	FROM     
    	EZGI_DESIGN_PACKAGE_ROW
	WHERE  
    	DESIGN_MAIN_ROW_ID = #GET_DESIGN_DEFAULTS.DESIGN_MAIN_ROW_ID#
	ORDER BY 
    	PACKAGE_NUMBER
</cfquery>
<cfset sira = 1>
<cfif get_master_packages.recordcount>
	<cfoutput query="get_master_packages">
    	<cfset 'PACKAGE_RELATED_ID_#PACKAGE_NUMBER#' = PACKAGE_RELATED_ID>
        <cfif get_master_packages.PACKAGE_NUMBER neq sira>
            <script type="text/javascript">
                alert("Master Paket Tanımlarında #sira# Nolu Paket Bulunamadı!");
                window.close()
            </script>
            <cfabort>
        </cfif>
        <cfset sira = sira+1>
    </cfoutput>
<cfelse>
	<script type="text/javascript">
    	alert("Master Paket Tanımlarında Paket Bulunamadı!");
    	window.close()
 	</script>
	<cfabort>
</cfif>
<!---Standart Kontroller--->

<cfquery name="get_offer" datasource="#dsn3#">
	SELECT    
    	CASE
       		WHEN O.COMPANY_ID IS NOT NULL THEN
         		(
                        SELECT     
                            FULLNAME
                        FROM         
                            #dsn_alias#.COMPANY WITH (NOLOCK)
                        WHERE     
                            COMPANY_ID = O.COMPANY_ID
     			)
        	WHEN O.CONSUMER_ID IS NOT NULL THEN      
         		(	
                        SELECT     
                            CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                        FROM         
                            #dsn_alias#.CONSUMER WITH (NOLOCK)
                        WHERE     
                            CONSUMER_ID = O.CONSUMER_ID
       			)
     	END AS UNVAN,    
    	OFFER_ID, 
        OFFER_NUMBER, 
        OFFER_HEAD, 
        OFFER_DETAIL, 
        CONSUMER_ID, 
        COMPANY_ID, 
        PARTNER_ID, 
        EMPLOYEE_ID
	FROM            
    	OFFER O WITH (NOLOCK)
	WHERE        
    	OFFER_ID = #attributes.OFFER_ID#
</cfquery>
<cfquery name="get_offer_row_control" datasource="#dsn3#">
	SELECT 
    	OFR.OFFER_ROW_ID, 
        OFR.PRODUCT_ID, 
        OFR.STOCK_ID, 
        OFR.WRK_ROW_ID
	FROM     
    	OFFER_ROW AS OFR WITH (NOLOCK) LEFT OUTER JOIN
        (
        	SELECT 
            	EDMR.DESIGN_MAIN_ROW_ID, 
                EDMR.OFFER_ROW_ID
        	FROM      
            	EZGI_DESIGN AS ED WITH (NOLOCK) INNER JOIN
                EZGI_DESIGN_MAIN_ROW AS EDMR WITH (NOLOCK) ON ED.DESIGN_ID = EDMR.DESIGN_ID
       		WHERE   
            	ISNULL(ED.IS_PRIVATE, 0) = 1
     	) AS TBL ON OFR.OFFER_ROW_ID = TBL.OFFER_ROW_ID
	WHERE  
    	OFR.OFFER_ID = #attributes.OFFER_ID# AND 
        TBL.DESIGN_MAIN_ROW_ID IS NULL
</cfquery>


<cfif not get_offer_row_control.recordcount>
	Teklifte Transfer Edilecek Satır Bulunmuyor
	<cfdump var="#get_offer_row#">
    <cfabort>
<cfelse>
	<cfset offer_row_id_list = ValueList(get_offer_row_control.OFFER_ROW_ID)>
</cfif>

<cfset attributes.efurniturecad = 1>

<cfset attributes.design_type = 1>
<cfset attributes.is_active = 1>
<cfset attributes.detail = get_offer.OFFER_DETAIL>
<cfif len(get_offer.COMPANY_ID)>
	<cfset attributes.consumer_id =''>
	<cfset attributes.company_id = get_offer.COMPANY_ID>
    <cfset attributes.member_type = 'consumer'>
<cfelseif len(get_offer.CONSUMER_ID)>
    <cfset attributes.consumer_id = get_offer.CONSUMER_ID>
    <cfset attributes.company_id = ''>
    <cfset attributes.member_type = 'consumer'>
<cfelse>
    Üye Tanımı Yapılmamış
	<cfdump var="#get_offer#">
    <cfabort>
</cfif>
<cfset attributes.member_name = get_offer.UNVAN>

<!---<cftransaction>--->
	<cfinclude template="add_ezgi_private_product_tree_creative.cfm"><!--- Özel Mobilya Tasarımı Oluşturmaya Git--->
    <cfset attributes.design_id = get_maxid.max_id>
    
    <cfquery name="ADD_MAIN_INFO" datasource="#DSN3#"><!--- Her Satır İçin Ayrı Bir Modül Satırı Açılıyor--->
    	INSERT INTO 
        	EZGI_DESIGN_MAIN_ROW
      	(
        	DESIGN_ID,
        	OFFER_ROW_ID,
            WRK_ROW_RELATION_ID,  
            DESIGN_MAIN_NAME, 
            DESIGN_MAIN_COLOR_ID, 
            MAIN_ROW_SETUP_ID, 
            DESIGN_MAIN_RELATED_ID, 
            OLCU1, 
            OLCU2,  
            DESIGN_MAIN_CODE,
            KARMA_KOLI_MIKTAR,
            MAIN_PROTOTIP_ID,
            MAIN_PROTOTIP_TYPE
       	)
    	SELECT  
        	#attributes.design_id#,      
        	ORR.OFFER_ROW_ID, 
            ORR.WRK_ROW_ID, 
            E.DESIGN_MAIN_NAME, 
            E.DESIGN_MAIN_COLOR_ID, 
            E.MAIN_ROW_SETUP_ID, 
            E.DESIGN_MAIN_RELATED_ID, 
            E.OLCU1, 
            E.OLCU2, 
            E.DESIGN_MAIN_CODE, 
         	ORR.QUANTITY,
            E.DESIGN_MAIN_ROW_ID,
            ISNULL(E.MAIN_PROTOTIP_TYPE,0) MAIN_PROTOTIP_TYPE
		FROM            
        	OFFER_ROW AS ORR WITH (NOLOCK) INNER JOIN
        	EZGI_DESIGN_MAIN_ROW AS E WITH (NOLOCK) ON ORR.STOCK_ID = E.DESIGN_MAIN_RELATED_ID
		WHERE        
        	ORR.OFFER_ROW_ID IN (#offer_row_id_list#) AND 
            ORR.OFFER_ID = #attributes.OFFER_ID# AND
            E.OFFER_ROW_ID IS NULL
    </cfquery>
    <cfquery name="get_main_info" datasource="#dsn3#">
    	SELECT * FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE OFFER_ROW_ID IN (#offer_row_id_list#)
    </cfquery>
    
  	<cfloop query="get_main_info"> <!---Modüller Döndürülüyor--->
    	<cfif not len(get_main_info.WRK_ROW_RELATION_ID)>
        	<script type="text/javascript">
                alert("EFurnitureCAD dosyasında Modül (WRK_ROW_RELATION_ID) Boştur!");
                window.close()
            </script>
            <cfabort>
        </cfif>
    	<cfset attributes.design_main_row_id = get_main_info.DESIGN_MAIN_ROW_ID>
        <!---Modüle Rota Ekleniyor--->
    	<cfquery name="add_main_rota" datasource="#dsn3#">
        	INSERT INTO 
            	EZGI_DESIGN_PIECE_ROTA
             	(
                	OPERATION_TYPE_ID, 
                    SIRA, 
                    AMOUNT, 
                    MAIN_ROW_ID
              	)
			SELECT     
            	OPERATION_TYPE_ID, 
                SIRA, 
                AMOUNT, 
                #attributes.design_main_row_id#
			FROM        
            	EZGI_DESIGN_PIECE_ROTA WITH (NOLOCK)
			WHERE     
            	(
                	MAIN_ROW_ID =
                      			(
                                	SELECT     
                                    	MAIN_PROTOTIP_ID
                       				FROM        
                                    	EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
                       				WHERE     
                                    	DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
                               	)
              	)
        </cfquery>
    	<cfset hata_id = 0>
        <cfset cad_dsn3 = '#dsn#_efurniturecad_#session.ep.company_id#'>
        <!---Modülle İlişkili E-FurnitureCAD Ana ID bulunuyor--->
        <cfquery name="get_efurniturecad_rel" datasource="#cad_dsn3#">
            SELECT TOP (1) WA_PRODUCT_TREE_ID FROM WORKCUBE_AUTOCAD_PRODUCT_TREE WITH (NOLOCK) WHERE WRK_ROW_ID = '#get_main_info.WRK_ROW_RELATION_ID#' ORDER BY WA_PRODUCT_TREE_ID DESC
        </cfquery>
        
        <cfif not get_efurniturecad_rel.recordcount>
            <script type="text/javascript">
                alert("EFurnitureCAD dosyasında Modül (WRK_ROW_RELATION_ID) İlişkisi Bulunamadı!");
                window.close()
            </script>
            <cfabort>
        </cfif>
        <cfif get_efurniturecad_rel.recordcount gt 1>
            <script type="text/javascript">
                alert("EFurnitureCAD dosyasında Modül (WRK_ROW_RELATION_ID) İlişkisi 1 den fazla Bulundu!");
                window.close()
            </script>
            <cfabort>
        </cfif>
        
        <cfset attributes.efurniturecad_id = get_efurniturecad_rel.WA_PRODUCT_TREE_ID>
        <cfinclude template="upd_ezgi_product_tree_creative_main_row_from_efurniturecad.cfm"><!--- Paket ve Parçaları Oluşturmaya Git--->
        
		<!---Stok İlişkilendirma İşlemi Başlangıcı--->
        <!---PAKETLER--->
        <cfquery name="get_all_packages" datasource="#dsn3#"> <!---Yeni Oluşan Paketlerin listesini Çekiyorum--->
        	SELECT
            	PACKAGE_ROW_ID, 
            	CAST(PACKAGE_NUMBER AS INT) AS PACKAGE_NUMBER
			FROM     
            	EZGI_DESIGN_PACKAGE_ROW
			WHERE  
            	DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
			ORDER BY 
            	PACKAGE_NUMBER  
        </cfquery>
        <cfloop query="get_all_packages">
        	<cfquery name="upd_package_stock_related" datasource="#dsn3#">
        		UPDATE
            		EZGI_DESIGN_PACKAGE_ROW
             	SET
                	PACKAGE_RELATED_ID = #Evaluate('PACKAGE_RELATED_ID_#get_all_packages.PACKAGE_NUMBER#')#
             	WHERE
                	PACKAGE_ROW_ID = #get_all_packages.PACKAGE_ROW_ID#
         	</cfquery> 
            <cfif isdefined('get_efurniturecad_package')>
            	<cfquery name="get_cad_package_info" dbtype="query">
                	SELECT * FROM get_efurniturecad_package WHERE PACKAGE_NUMBER = #get_all_packages.PACKAGE_NUMBER#
                </cfquery>
                <cfif get_cad_package_info.recordcount>
                	<cfquery name="upd_package_info" datasource="#dsn3#">
                        UPDATE
                            EZGI_DESIGN_PACKAGE_ROW
                        SET
                            PACKAGE_NUMBER = #get_all_packages.PACKAGE_NUMBER#
                            <cfif len(get_cad_package_info.PACKAGE_NAME)>
                            	,PACKAGE_NAME = '#get_cad_package_info.PACKAGE_NAME#'
                            </cfif>
                            <cfif len(get_cad_package_info.PACKAGE_DEPTH)>
                            	,PACKAGE_KALINLIK = #get_cad_package_info.PACKAGE_DEPTH#
                            </cfif>
                            <cfif len(get_cad_package_info.PACKAGE_LENGTH)>
                            	,PACKAGE_BOYU = #get_cad_package_info.PACKAGE_LENGTH#
                            </cfif>
                            <cfif len(get_cad_package_info.PACKAGE_WIDTH)>
                            	,PACKAGE_ENI = #get_cad_package_info.PACKAGE_WIDTH#
                            </cfif>
                            <cfif len(get_cad_package_info.PACKAGE_WEIGHT)>
                            	,PACKAGE_WEIGHT = #get_cad_package_info.PACKAGE_WEIGHT#
                            </cfif>
                            <cfif isdefined('PACKAGE_COLOR_ID_#get_all_packages.PACKAGE_NUMBER#')>
                            	,PACKAGE_COLOR_ID = #Evaluate('PACKAGE_COLOR_ID_#get_all_packages.PACKAGE_NUMBER#')#
                            </cfif>
                        WHERE
                            PACKAGE_ROW_ID = #get_all_packages.PACKAGE_ROW_ID#
                    </cfquery> 
                </cfif>
            </cfif>      	
        </cfloop>
        <!---PAKETLER--->
        
        <!---PARÇALAR--->
  		<cfquery name="get_all_pieces" datasource="#dsn3#"> <!---Yeni Oluşan Parçaların listesini Çekiyorum--->
        	SELECT PIECE_ROW_ID, PIECE_TYPE FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id# AND PIECE_TYPE <> 4
        </cfquery>
        <cfloop from="1" to="3" index="prow">
            <cfquery name="get_pieces_type1" dbtype="query">
                SELECT PIECE_ROW_ID FROM get_all_pieces WHERE PIECE_TYPE = #prow#
            </cfquery>
            <cfif get_pieces_type1.recordcount>
                <cfset row_id_list = ValueList(get_pieces_type1.PIECE_ROW_ID)>
                <cfquery name="upd_piece_stock_related" datasource="#dsn3#">
                	UPDATE
                    	EZGI_DESIGN_PIECE_ROWS
                  	SET
                    	PIECE_RELATED_ID = #Evaluate('GET_DESIGN_DEFAULTS.PIECE_RELATED_ID#prow#')#
                  	WHERE
                    	PIECE_ROW_ID IN (#row_id_list#)	
                </cfquery>
            </cfif>
        </cfloop>
        <!---PARÇALAR--->
    	<!---Stok İlişkilendirma İşlemi Bitişi--->
    </cfloop>     
     
<!---</cftransaction>--->
<script type="text/javascript">
	alert("<cf_get_lang dictionary_id='260.Aktarım Başarıyla Tamamlanmıştır'>");
  	wrk_opener_reload();
	window.close();
</script>