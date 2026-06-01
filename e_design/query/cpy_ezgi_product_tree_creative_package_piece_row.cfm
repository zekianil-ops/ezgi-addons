<!---
    File: cpy_ezgi_product_tree_creative_package_piece_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 	
<cfquery name="cpy_piece" datasource="#dsn3#">
    INSERT INTO 
        EZGI_DESIGN_PIECE_ROWS
        (
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
            CANALIZING_TYPE, 
            BOY_FARK,
            EN_FARK,
            RECORD_EMP, 
            RECORD_IP, 
            RECORD_DATE
        )
    SELECT    
    	DISTINCT    
        #attributes.DESIGN_MAIN_ROW_ID#, 
        <cfif (isdefined('attributes.package_row_id') and len(attributes.package_row_id) and Evaluate('PIECE_TYPE_#cpy_piece_id#') eq 3) or (isdefined('to_package_select') and isdefined('sub_piece') and sub_piece eq 0)>
        	#attributes.package_row_id#,
        <cfelse>
        	#get_max_id.max_id#,
        </cfif> 
        #get_old_design_id.DESIGN_ID#, 
        MASTER_PRODUCT_ID, 
        PIECE_TYPE,
        <cfif isdefined('attributes.workcube_select2')> <!---Tanımlıysa Gelen Parçanın Parça Adını Gönderilecek Tasarıma Uydurur --->
       		REPLACE(PIECE_NAME,'#get_new_design_id.MAIN_ROW_SETUP_NAME#','#get_old_design_id.MAIN_ROW_SETUP_NAME#') AS PIECE_NAME, 
       	<cfelse>
        	PIECE_NAME,
        </cfif>
        PIECE_CODE, 
        PIECE_STATUS, 
        PIECE_COLOR_ID,
        <cfif isdefined('attributes.workcube_select') or Evaluate('PIECE_TYPE_#cpy_piece_id#') eq 4>
        	PIECE_RELATED_ID,
        <cfelse>
        	NULL,
        </cfif>
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
        CANALIZING_TYPE,
        BOY_FARK,
      	EN_FARK,
        #session.ep.userid#,
        '#cgi.remote_addr#',
        #now()#
    FROM            
        EZGI_DESIGN_PIECE AS EDP WITH (NOLOCK)
    WHERE        
        PIECE_ROW_ID = #cpy_piece_id# AND 
        PIECE_STATUS = 1
</cfquery>
<cfquery name="get_piece_max_id" datasource="#dsn3#">
    SELECT MAX(PIECE_ROW_ID) AS MAX_ID FROM EZGI_DESIGN_PIECE_ROWS
</cfquery>
<cfset 'new_piece_row_id_#cpy_piece_id#' = get_piece_max_id.max_id>
<cfif Evaluate('PIECE_TYPE_#cpy_piece_id#') eq 3>
	<cftry>
        <cfquery name="get_sub_piece_row" datasource="#dsn3#">
        	SELECT 
                EPR.RELATED_PIECE_ROW_ID, 
                EPR.AMOUNT, 
                EPR.SIRA_NO, 
                EPR.PIECE_ROW_ROW_TYPE
			FROM     
            	EZGI_DESIGN_PIECE_ROW AS EPR WITH (NOLOCK) LEFT OUTER JOIN
                EZGI_DESIGN_PIECE_ROWS AS EP WITH (NOLOCK) ON EPR.RELATED_PIECE_ROW_ID = EP.PIECE_ROW_ID
			WHERE  
            	EPR.PIECE_ROW_ID = #cpy_piece_id# AND 
                NOT (EPR.RELATED_PIECE_ROW_ID IS NULL) AND 
                NOT (EP.PIECE_ROW_ID IS NULL)
        </cfquery>
        <cfloop query="get_sub_piece_row">
            <cfquery name="cpy_piece_row" datasource="#dsn3#">
                INSERT INTO 
                    EZGI_DESIGN_PIECE_ROW
                    (
                        PIECE_ROW_ID, 
                        RELATED_PIECE_ROW_ID, 
                        AMOUNT, 
                        SIRA_NO, 
                        PIECE_ROW_ROW_TYPE
                    )
                VALUES
                    (
                        #get_piece_max_id.max_id#,
                        #Evaluate('new_piece_row_id_#get_sub_piece_row.RELATED_PIECE_ROW_ID#')#,
                        #get_sub_piece_row.AMOUNT#,
                        #get_sub_piece_row.SIRA_NO#,
                        #get_sub_piece_row.PIECE_ROW_ROW_TYPE#
                    )
            </cfquery>
        </cfloop>
        <cfcatch type="any">
        	<cfdump var="#get_sub_piece_row#">
            <p><strong>#get_sub_piece_row.RELATED_PIECE_ROW_ID# Tanımlanamayan Hatalı Alt Parça Stok Bağlantısı.<strong><p>
            <cfabort>
    	</cfcatch>
 	</cftry>
  	<cfquery name="upd_ezgi_piece_row_row" datasource="#dsn3#"> <!---Yeni Parça ID si EZGI Id ye güncelleniyor--->
     	UPDATE 
        	EZGI_DESIGN_PIECE_ROW 
    	SET 
      		EZGI_PIECE_ROW_ROW_ID = PIECE_ROW_ROW_ID
     	WHERE 
       		PIECE_ROW_ID = #get_piece_max_id.max_id# AND
         	EZGI_PIECE_ROW_ROW_ID IS NULL
 	</cfquery>
</cfif>
<cfquery name="cpy_piece_row" datasource="#dsn3#">
    INSERT INTO 
        EZGI_DESIGN_PIECE_ROW
        (
            PIECE_ROW_ID, 
            RELATED_PIECE_ROW_ID, 
            STOCK_ID, 
            AMOUNT, 
            SIRA_NO, 
            PIECE_ROW_ROW_TYPE
        )
    SELECT        
        #get_piece_max_id.max_id#, 
        RELATED_PIECE_ROW_ID, 
        STOCK_ID, 
        AMOUNT, 
        SIRA_NO, 
        PIECE_ROW_ROW_TYPE
    FROM
        EZGI_DESIGN_PIECE_ROW WITH (NOLOCK)
    WHERE        
        PIECE_ROW_ID = #cpy_piece_id# AND
        PIECE_ROW_ROW_TYPE <> 4
</cfquery>
<cfquery name="upd_ezgi_piece_row_row" datasource="#dsn3#"> <!---Yeni Parça ID si EZGI Id ye güncelleniyor--->
  	UPDATE 
    	EZGI_DESIGN_PIECE_ROW 
	SET 
 		EZGI_PIECE_ROW_ROW_ID = PIECE_ROW_ROW_ID
 	WHERE 
    	PIECE_ROW_ID = #get_piece_max_id.max_id# AND
     	EZGI_PIECE_ROW_ROW_ID IS NULL
</cfquery>
<cfquery name="cpy_piece_rota" datasource="#dsn3#">
	INSERT INTO 
    	EZGI_DESIGN_PIECE_ROTA
     	(
        	PIECE_ROW_ID, 
            OPERATION_TYPE_ID, 
            SIRA, 
            AMOUNT
      	)
	SELECT        
    	#get_piece_max_id.max_id#, 
        OPERATION_TYPE_ID, 
        SIRA, 
        AMOUNT
	FROM            
    	EZGI_DESIGN_PIECE_ROTA WITH (NOLOCK)
	WHERE        
    	PIECE_ROW_ID = #cpy_piece_id#
</cfquery>

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
        #get_piece_max_id.max_id#,
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
    	PIECE_ROW_ID = #cpy_piece_id#
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
        #get_piece_max_id.max_id#, 
        ALTERNATIVE_PIECE_ROW_ID, 
        ALTERNATIVE_STOCK_ID, 
        ALTERNATIVE_AMOUNT_FORMUL, 
        ALTERNATIVE_AMOUNT
	FROM            
    	EZGI_DESIGN_PIECE_PROTOTIP_ALTERNATIVE WITH (NOLOCK)
	WHERE        
    	PIECE_ROW_ID = #cpy_piece_id#
</cfquery>
<cfif isdefined('attributes.workcube_select')> <!---Ortak Parça Kopyalama İse resimler de ilişkilendirilsin--->
	<cfquery name="add_image" datasource="#dsn3#">
    	INSERT INTO 
        	EZGI_DESIGN_PIECE_IMAGES
            (
            	DESIGN_PIECE_ROW_ID, 
                PATH, DETAIL, 
                IMAGE_SIZE, 
                IS_INTERNET, 
                PATH_SERVER_ID, 
                IS_EXTERNAL_LINK, 
                VIDEO_LINK, 
                VIDEO_PATH, 
                PRD_IMG_NAME, 
                LANGUAGE_ID, 
                UPDATE_DATE, 
                UPDATE_IP, 
                UPDATE_EMP
          	)
    	SELECT 
        	#get_piece_max_id.max_id#, 
            PATH, 
            DETAIL, 
            IMAGE_SIZE, 
            IS_INTERNET, 
            PATH_SERVER_ID, 
            IS_EXTERNAL_LINK, 
            VIDEO_LINK, 
            VIDEO_PATH, 
            PRD_IMG_NAME, 
            LANGUAGE_ID, 
            #now()#,
            '#cgi.remote_addr#',
            #session.ep.userid#
		FROM     
        	EZGI_DESIGN_PIECE_IMAGES WITH (NOLOCK)
		WHERE  
        	DESIGN_PIECE_ROW_ID = #cpy_piece_id#
    </cfquery>
</cfif>