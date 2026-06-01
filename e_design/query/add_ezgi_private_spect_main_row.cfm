<!---
    File: add_ezgi_private_spect_main_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfquery name="add_spect_main_row" datasource="#dsn3#">
	INSERT INTO 
    	SPECT_MAIN_ROW
      	(
        	SPECT_MAIN_ID, 
            PRODUCT_ID, 
            STOCK_ID, 
            AMOUNT, 
            PRODUCT_NAME, 
            IS_PROPERTY, 
            IS_CONFIGURE, 
            IS_SEVK, 
            RELATED_MAIN_SPECT_ID, 
            LINE_NUMBER, 
            IS_PHANTOM, 
            OPERATION_TYPE_ID, 
         	QUESTION_ID, 
            STATION_ID, 
            IS_FREE_AMOUNT, 
            FIRE_AMOUNT, 
            FIRE_RATE, 
            DETAIL
      	)
	VALUES        
    	(
         	#Evaluate('attributes.SPECT_MAIN_ID_#i#')#,
            <cfif  isdefined('attributes.product_id') and len(attributes.product_id) and len(attributes.product_name)>#attributes.product_id#<cfelse>NULL</cfif>,
			<cfif len(attributes.add_stock_id) and len(attributes.product_name)>#attributes.add_stock_id#<cfelse>NULL</cfif>,
            #attributes.AMOUNT#,
            <cfif len(attributes.add_stock_id) and len(attributes.product_name)>'#attributes.product_name#'<cfelse>NULL</cfif>,
            <cfif get_product_tree.RELATED_ID eq 0>3<cfelse>0</cfif>,
            <cfif get_product_tree.RELATED_ID eq 0>1<cfelse>0</cfif>,
            0,
            <cfif attributes.spect_related_id gt 0>#attributes.spect_related_id#<cfelse>NULL</cfif>,
            0,
            <cfif isdefined('attributes.is_phantom') and len(attributes.is_phantom)>1<cfelse>0</cfif>,
            <cfif isdefined('attributes.operation_type_id') and len(attributes.operation_type_id) and not len(attributes.product_name)>#attributes.operation_type_id#<cfelse>NULL</cfif>,
            0,
            0,
            0,
            0,
            0,
            '-'
    	)
</cfquery>