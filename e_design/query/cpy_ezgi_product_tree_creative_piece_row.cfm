<!---
    File: cpy_ezgi_product_tree_creative_piece_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfquery name="get_piece_info" datasource="#dsn3#"> <!---Kaynak Parçanın Parça Bilgileri Çekiliyor--->
	SELECT       
    	DESIGN_MAIN_ROW_ID, 
        DESIGN_PACKAGE_ROW_ID, 
        DESIGN_ID, 
        MASTER_PRODUCT_ID, 
        PIECE_TYPE, 
        PIECE_NAME, 
        PIECE_CODE, 
        PIECE_STATUS, 
        PIECE_COLOR_ID, 
       	PIECE_RELATED_ID, 
        PIECE_DETAIL, 
        PIECE_AMOUNT, 
        MATERIAL_ID, 
        TRIM_TYPE, 
        TRIM_SIZE, 
        TRIM_1,
       	TRIM_2,
       	TRIM_3,
     	TRIM_4, 
        IS_FLOW_DIRECTION, 
        BOYU, 
        ENI, 
        KESIM_BOYU, 
        KESIM_ENI, 
        KALINLIK, 
        AGIRLIK,
        BOY_FARK,
      	EN_FARK,
        CANALIZING_TYPE
	FROM            
    	EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
	WHERE        
    	PIECE_ROW_ID = #attributes.design_piece_row_id#
</cfquery>
<cfif get_piece_info.recordcount>
	<cfparam name="attributes.design_main_row_id" default="#get_piece_info.DESIGN_MAIN_ROW_ID#">
	<cfparam name="attributes.design_package_row_id" default="#get_piece_info.DESIGN_PACKAGE_ROW_ID#">
    <cfparam name="attributes.design_id" default="#get_piece_info.DESIGN_ID#">
    <cfparam name="attributes.piece_color_id" default="#get_piece_info.PIECE_COLOR_ID#">
</cfif>
<cfif get_piece_info.PIECE_TYPE eq 1> <!---Yonga Levha İse--->
	<cfquery name="get_yonga_levha" datasource="#dsn3#">
        SELECT STOCK_ID FROM EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK) WHERE LIST_ORDER_NO = 1 AND COLOR_ID = #attributes.piece_color_id# AND THICKNESS_ID = #get_piece_info.KALINLIK#
    </cfquery>
	<cfif get_yonga_levha.recordcount eq 1> <!---Tek Yonga Levha Bulduysa İşleme Devam--->
        <cfset yonga_levha_material_id = get_yonga_levha.STOCK_ID>
    <cfelseif get_yonga_levha.recordcount gte 2> <!---Birden Fazla Yonga Levha Bulduysa Geri--->
        <script type="text/javascript">
            alert('<cf_get_lang dictionary_id='968.İlgili Renkten Birden Fazla Yonga Levha Bulunmuştur. Öncelikle Sorunu Giderin !'>');
        </script>
        <cfabort>
    <cfelse> <!---Yonga Levha Bulamadıysa Geri--->
        <script type="text/javascript">
            alert('<cf_get_lang dictionary_id='969.İlgili Renkten Yonga Levha Bulunamamıştır !'>');
        </script>
        <cfabort>
    </cfif>
</cfif>
<cfif get_piece_info.PIECE_TYPE eq 3> <!---Montaj Ürünü İse--->
	<cfquery name="get_montage" datasource="#dsn3#">
		
  	</cfquery>
</cfif>
<cfif get_piece_info.PIECE_TYPE eq 1 or get_piece_info.PIECE_TYPE eq 3> <!---Yonga Levha veya Montaj Ürünü İse PCV Tanımlama--->
	<cfquery name="get_pvc_old" datasource="#dsn3#">
    	SELECT        
        	EDPR.STOCK_ID, 
            EDPR.AMOUNT, 
            EDPR.SIRA_NO, 
            EDPR.PIECE_ROW_ROW_TYPE, 
            EPP.COLOR_ID, 
            EPP.THICKNESS_ID, 
            EPP.KALINLIK_ETKISI_NAME AS KALINLIK_ETKISI,
            EPP.KALINLIK_ETKISI_CODE AS KALINLIK_ETKISI_CODE
		FROM            
        	EZGI_DESIGN_PIECE_ROW AS EDPR WITH (NOLOCK) INNER JOIN
         	EZGI_DESIGN_PRODUCT_PROPERTIES_UST AS EPP WITH (NOLOCK) ON EDPR.STOCK_ID = EPP.STOCK_ID
		WHERE        
        	EDPR.PIECE_ROW_ID = #attributes.design_piece_row_id#  AND 
            EDPR.PIECE_ROW_ROW_TYPE = 1
		ORDER BY 
        	EDPR.SIRA_NO
    </cfquery>
    <cfif get_pvc_old.recordcount>
        <cfloop query="get_pvc_old">
        	<cfquery name="get_pvc_new" datasource="#dsn3#">
            	SELECT 
                	STOCK_ID 
               	FROM 
                	EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK)
               	WHERE 
                	COLOR_ID = #attributes.piece_color_id# AND 
                    LIST_ORDER_NO = 3 AND 
                    THICKNESS_ID = #THICKNESS_ID# AND 
                    KALINLIK_ETKISI_CODE= '#KALINLIK_ETKISI_CODE#'
            </cfquery>
            <cfif get_pvc_new.recordcount eq 1> <!---Tek PVC Bulduysa İşleme Devam--->
                <cfset 'pvc_related_product_id_#SIRA_NO#' = get_pvc_new.STOCK_ID>
            <cfelseif get_pvc_new.recordcount gte 2> <!---Birden Fazla PVC Bulduysa Geri--->
                <script type="text/javascript">
                    alert('<cf_get_lang dictionary_id='970.İlgili Renkten Birden Fazla PVC Bulunmuştur. Öncelikle Sorunu Giderin !'>');
                </script>
                <cfabort>
            <cfelse> <!---PVC Bulamadıysa Geri--->
            	<cfset 'pvc_related_product_id_#SIRA_NO#' = get_pvc_old.stock_id>
            </cfif>
        </cfloop>
  	<cfelse> <!---PVC Listesi Alınamadıysa--->
    
    </cfif>
</cfif>
<cfquery name="get_piece_row" datasource="#dsn3#">
	SELECT STOCK_ID, AMOUNT, SIRA_NO, PIECE_ROW_ROW_TYPE FROM EZGI_DESIGN_PIECE_ROW WITH (NOLOCK) WHERE PIECE_ROW_ID = #attributes.design_piece_row_id#
</cfquery>
<cfif not isdefined('all_tree')>
    <cfquery name="get_design_piece_row" datasource="#dsn3#">
        SELECT TOP (1) * FROM EZGI_DESIGN_PIECE WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id# ORDER BY CAST(PIECE_CODE AS INT) DESC
    </cfquery>
    <cfif left(get_design_piece_row.PIECE_CODE,1) eq 0>
        <cfset new_piece_code = right(get_design_piece_row.PIECE_CODE,1)*1 + 1>
    <cfelse>
        <cfset new_piece_code = get_design_piece_row.PIECE_CODE*1 + 1>
    </cfif>
    <cfif len(new_piece_code) eq 1>
        <cfset new_piece_code = '0#new_piece_code#'>
    </cfif>
<cfelse>
	<cfset new_piece_code = get_piece_info.PIECE_CODE>
</cfif>
<cftransaction>
    <cfquery name="add_piece" datasource="#dsn3#"> <!---Parça Kopyalama--->
        INSERT INTO 
            EZGI_DESIGN_PIECE_ROWS
            (
        		PIECE_RELATED_ID,
                PIECE_NAME, 
                PIECE_COLOR_ID, 
                MASTER_PRODUCT_ID, 
                MATERIAL_ID, 
                TRIM_TYPE,
                TRIM_SIZE, 
                TRIM_1,
                TRIM_2,
                TRIM_3,
                TRIM_4, 
                IS_FLOW_DIRECTION, 
                BOYU, 
                ENI, 
                KALINLIK,
                PIECE_DETAIL, 
                PIECE_CODE,
                PIECE_TYPE,
                DESIGN_MAIN_ROW_ID, 
                DESIGN_PACKAGE_ROW_ID, 
                DESIGN_ID,
                PIECE_STATUS,
                PIECE_AMOUNT,
                AGIRLIK,
                KESIM_BOYU, 
            	KESIM_ENI,
                CANALIZING_TYPE,
                BOY_FARK,
           	 	EN_FARK,
                RECORD_EMP, 
                RECORD_IP, 
                RECORD_DATE
            )
        VALUES        
            (
            	<cfif get_piece_info.PIECE_TYPE eq 4>#get_piece_info.PIECE_RELATED_ID#<cfelse>NULL</cfif>,
                <cfif len(get_piece_info.PIECE_NAME)>'#get_piece_info.PIECE_NAME#'<cfelse>NULL</cfif>,
                <cfif len(attributes.piece_color_id)>#attributes.piece_color_id#<cfelse>NULL</cfif>,
                <cfif len(get_piece_info.MASTER_PRODUCT_ID)>#get_piece_info.MASTER_PRODUCT_ID#<cfelse>NULL</cfif>,
                <cfif isdefined('yonga_levha_material_id') and len(yonga_levha_material_id) and (get_piece_info.PIECE_TYPE eq 1 or get_piece_info.PIECE_TYPE eq 3)>#yonga_levha_material_id#<cfelse>NULL</cfif>,
                <cfif len(get_piece_info.TRIM_TYPE)>#get_piece_info.TRIM_TYPE#<cfelse>NULL</cfif>,
           		<cfif len(get_piece_info.TRIM_SIZE)>#get_piece_info.TRIM_SIZE#<cfelse>NULL</cfif>,
                <cfif len(get_piece_info.TRIM_1)>#get_piece_info.TRIM_1#<cfelse>NULL</cfif>,
             	<cfif len(get_piece_info.TRIM_2)>#get_piece_info.TRIM_2#<cfelse>NULL</cfif>,
              	<cfif len(get_piece_info.TRIM_3)>#get_piece_info.TRIM_3#<cfelse>NULL</cfif>,
              	<cfif len(get_piece_info.TRIM_4)>#get_piece_info.TRIM_4#<cfelse>NULL</cfif>,
                <cfif len(get_piece_info.IS_FLOW_DIRECTION)>#get_piece_info.IS_FLOW_DIRECTION#<cfelse>0</cfif>,
                <cfif len(get_piece_info.BOYU)>#get_piece_info.BOYU#<cfelse>NULL</cfif>,
                <cfif len(get_piece_info.ENI)>#get_piece_info.ENI#<cfelse>NULL</cfif>,
                <cfif len(get_piece_info.KALINLIK)>#get_piece_info.KALINLIK#<cfelse>NULL</cfif>,
                <cfif len(get_piece_info.PIECE_DETAIL)>'#get_piece_info.PIECE_DETAIL#'<cfelse>NULL</cfif>,
                '#new_piece_code#',
                #get_piece_info.PIECE_TYPE#,
                #attributes.design_main_row_id#,
                <cfif len(attributes.design_package_row_id)>#attributes.design_package_row_id#<cfelse>NULL</cfif>,
                #attributes.design_id#,
                #get_piece_info.PIECE_STATUS#,
                #get_piece_info.PIECE_AMOUNT#,
                <cfif len(get_piece_info.AGIRLIK)>#get_piece_info.AGIRLIK#<cfelse>NULL</cfif>,
                <cfif len(get_piece_info.KESIM_BOYU)>#get_piece_info.KESIM_BOYU#<cfelse>NULL</cfif>,
                <cfif len(get_piece_info.KESIM_ENI)>#get_piece_info.KESIM_ENI#<cfelse>NULL</cfif>,
                <cfif len(get_piece_info.CANALIZING_TYPE)>#get_piece_info.CANALIZING_TYPE#<cfelse>NULL</cfif>,
                <cfif len(get_piece_info.BOY_FARK)>#get_piece_info.BOY_FARK#<cfelse>NULL</cfif>,
                <cfif len(get_piece_info.EN_FARK)>#get_piece_info.EN_FARK#<cfelse>NULL</cfif>,
                #session.ep.userid#,
                '#cgi.remote_addr#',
                #now()#
            )
    </cfquery>
     <cfquery name="get_max_id" datasource="#dsn3#">
        SELECT MAX(PIECE_ROW_ID) AS MAX_ID FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
    </cfquery>
   	<cfloop query="get_piece_row">
     	<cfquery name="add_piece_row" datasource="#dsn3#"> <!---Satır Kopyalama--->
            INSERT INTO 
                EZGI_DESIGN_PIECE_ROW
                (
                    PIECE_ROW_ID, 
                    SIRA_NO,
                    PIECE_ROW_ROW_TYPE,
                    AMOUNT,
                    <cfif get_piece_row.PIECE_ROW_ROW_TYPE eq 4>
                        RELATED_PIECE_ROW_ID
                    <cfelse>
                        STOCK_ID
                    </cfif>
                )
            VALUES        
                (
                    #get_max_id.max_id#,
                    #get_piece_row.SIRA_NO#,
                    #get_piece_row.PIECE_ROW_ROW_TYPE#,
                    #get_piece_row.AMOUNT#,
                    <cfif get_piece_row.PIECE_ROW_ROW_TYPE eq 1>
                    	#Evaluate('pvc_related_product_id_#SIRA_NO#')#
                   	<cfelseif get_piece_row.PIECE_ROW_ROW_TYPE eq 0>
                  		#yonga_levha_material_id#
                   	<cfelseif get_piece_row.PIECE_ROW_ROW_TYPE eq 4>
                    
                    <cfelse>
                    	#get_piece_row.STOCK_ID#
                    </cfif>
                )
        </cfquery>
        <cfquery name="upd_ezgi_piece_row_row" datasource="#dsn3#"> <!---Yeni Parça ID si EZGI Id ye güncelleniyor--->
            UPDATE 
                EZGI_DESIGN_PIECE_ROW 
            SET 
                EZGI_PIECE_ROW_ROW_ID = PIECE_ROW_ROW_ID
            WHERE 
                PIECE_ROW_ID = #get_max_id.max_id# AND
                EZGI_PIECE_ROW_ROW_ID IS NULL
        </cfquery>
  	</cfloop>  
    <cfif get_piece_info.PIECE_TYPE eq 1 or get_piece_info.PIECE_TYPE eq 2 or get_piece_info.PIECE_TYPE eq 3> <!---Operasyon Kopyalama--->
     	<cfquery name="cpy_rota" datasource="#dsn3#">
          	INSERT INTO 
             	EZGI_DESIGN_PIECE_ROTA
              	(
                    PIECE_ROW_ID, 
                    OPERATION_TYPE_ID, 
                    SIRA, 
                    AMOUNT
              	)
         	SELECT      
              	#get_max_id.max_id#, 
             	OPERATION_TYPE_ID, 
              	SIRA, 
             	AMOUNT
          	FROM            
              	EZGI_DESIGN_PIECE_ROTA WITH (NOLOCK)
         	WHERE        
             	PIECE_ROW_ID = #attributes.design_piece_row_id#
    	</cfquery>
    </cfif>
    <cfquery name="cpy_piece_prototip" datasource="#dsn3#">
        INSERT INTO 
            EZGI_DESIGN_PIECE_PROTOTIP
            (
                PIECE_ROW_ID, 
                QUESTION_ID, 
                BOY_FORMUL, 
                EN_FORMUL, 
                IS_AMOUNT_CHANGE, 
                IS_PRICE_CHANGE, 
                AMOUNT_FORMUL, 
                PRIVATE_PRICE_TYPE, 
                PRIVATE_PRICE, 
                PRIVATE_PRICE_MONEY
            )
        SELECT        
            #get_max_id.max_id#,
            QUESTION_ID, 
            BOY_FORMUL, 
            EN_FORMUL, 
            IS_AMOUNT_CHANGE, 
            IS_PRICE_CHANGE, 
            AMOUNT_FORMUL, 
            PRIVATE_PRICE_TYPE, 
            PRIVATE_PRICE, 
            PRIVATE_PRICE_MONEY
        FROM          
            EZGI_DESIGN_PIECE_PROTOTIP WITH (NOLOCK)
        WHERE        
            PIECE_ROW_ID = #attributes.design_piece_row_id#
    </cfquery>
    <cfquery name="cpy_piece_prototip_alternatives" datasource="#dsn3#">
        INSERT INTO 
            EZGI_DESIGN_PIECE_PROTOTIP_ALTERNATIVE
            (
                PIECE_ROW_ID, 
                ALTERNATIVE_PIECE_ROW_ID, 
                ALTERNATIVE_STOCK_ID, 
                ALTERNATIVE_AMOUNT_FORMUL, 
                ALTERNATIVE_AMOUNT
            )
        SELECT        
            #get_max_id.max_id#,
            ALTERNATIVE_PIECE_ROW_ID, 
            ALTERNATIVE_STOCK_ID, 
            ALTERNATIVE_AMOUNT_FORMUL, 
            ALTERNATIVE_AMOUNT
        FROM            
            EZGI_DESIGN_PIECE_PROTOTIP_ALTERNATIVE WITH (NOLOCK)
        WHERE        
            PIECE_ROW_ID = #attributes.design_piece_row_id#
    </cfquery>
    <cfquery name="upd_ezgi_piece_row_row" datasource="#dsn3#"> <!---Yeni Parça ID si EZGI Id ye güncelleniyor--->
        UPDATE 
            EZGI_DESIGN_PIECE_ROW 
        SET 
            EZGI_PIECE_ROW_ROW_ID = PIECE_ROW_ROW_ID
        WHERE 
            PIECE_ROW_ID = #get_max_id.max_id# AND
            EZGI_PIECE_ROW_ROW_ID IS NULL
    </cfquery>
</cftransaction>
<cfif not isdefined('all_tree')> <!---Genel Kopyalama İşleminden Gelmediyse--->
	<cfset url_adres = '&design_piece_row_id=#get_max_id.max_id#'>
    <cfif isdefined('attributes.design_id') and len(attributes.design_id)>
        <cfset url_adres = '#url_adres#&design_id=#attributes.design_id#'>
    </cfif>
    <cfif isdefined('attributes.design_main_row_id') and len(attributes.design_main_row_id)>
        <cfset url_adres = '#url_adres#&design_main_row_id=#attributes.design_main_row_id#'>
    </cfif>
    <cfif isdefined('attributes.design_package_row_id') and len(attributes.design_package_row_id)>
        <cfset url_adres = '#url_adres#&design_package_row_id=#attributes.design_package_row_id#'>
    </cfif>
    <cfif isdefined('this_tree')> <!---Parça Güncelleme Sayfasından Geldiyse--->
    	<cflocation url="#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_piece_row&design_piece_row_id=#get_max_id.max_id#" addtoken="no">
   	<cfelseif isdefined('is_private')> <!---Özel Tasarım Parça Güncelleme Sayfasından Geldiyse--->
    	<cflocation url="#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=upd#url_adres#" addtoken="no">
    <cfelse> <!---Tasarım Güncellemedeki Parça Liste Sayfasından Geldiyse--->
    	<cflocation url="#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd#url_adres#" addtoken="no">
    </cfif>
</cfif>