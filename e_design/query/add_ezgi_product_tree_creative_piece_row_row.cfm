<!---
    File: add_ezgi_product_tree_creative_piece_row_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 
<cfquery name="add_piece_row" datasource="#dsn3#">
  	INSERT INTO 
   		EZGI_DESIGN_PIECE_ROW
    	(
            PIECE_ROW_ID, 
            SIRA_NO,
            PIECE_ROW_ROW_TYPE,
            AMOUNT,
            EZGI_PIECE_ROW_ROW_ID,
            <cfif attributes.row_row_type eq 4>
            	RELATED_PIECE_ROW_ID
            <cfelse>
            	STOCK_ID
          	</cfif>
            <cfif isdefined('attributes.piece_detail_')>
                ,PIECE_DETAIL
            </cfif>
    	)
	VALUES        
    	(
      		#get_max_id.max_id#,
            #attributes.sira_no#,
            #attributes.row_row_type#,
            #attributes.miktar#,
            <cfif isdefined('attributes.ezgi_piece_row_row_id') and len(attributes.ezgi_piece_row_row_id) and attributes.ezgi_piece_row_row_id gt 0>#attributes.ezgi_piece_row_row_id#<cfelse>NULL</cfif>,
            #attributes.stock_id#
            <cfif isdefined('attributes.piece_detail_')>
                ,'#attributes.piece_detail_#'
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
<cfif attributes.row_row_type eq 4> <!---Ürün Montajda Kullanıldıysa Paket Numarası Temizleniyor--->
    <cfquery name="upd_piece_package_id" datasource="#dsn3#">
        UPDATE 
        	EZGI_DESIGN_PIECE_ROWS 
      	SET 
        	DESIGN_PACKAGE_ROW_ID = NULL ,
            PIECE_FLOOR = NULL ,
            PIECE_PACKAGE_ROTA = NULL 
       	WHERE 
        	PIECE_ROW_ID = #attributes.stock_id#
    </cfquery>
</cfif>