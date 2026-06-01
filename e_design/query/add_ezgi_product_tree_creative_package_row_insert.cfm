	<cfset package_name = "#get_design_main_row.DESIGN_MAIN_NAME# - #package_number# .#getLang('main',2903)#">
    <cfquery name="add_package" datasource="#dsn3#">
        INSERT INTO 
            EZGI_DESIGN_PACKAGE_ROW
            (
                DESIGN_ID, 
                DESIGN_MAIN_ROW_ID, 
                PACKAGE_NUMBER, 
                PACKAGE_NAME, 
                PACKAGE_COLOR_ID, 
                PACKAGE_AMOUNT
                <cfif isdefined('is_private') and package_number gt 0>
                    ,PACKAGE_RELATED_ID
                </cfif>
            )
        VALUES
            (
                #get_design_main_row.DESIGN_ID#,
                #get_design_main_row.DESIGN_MAIN_ROW_ID#,
                #package_number#,
                '#package_name#',
                #get_design_main_row.DESIGN_MAIN_COLOR_ID#,
                1
                <cfif isdefined('is_private') and package_number gt 0>
                    ,#get_related_id.STOCK_ID#
                </cfif>
            )
    </cfquery>
    <cfquery name="get_max_id" datasource="#dsn3#">
        SELECT MAX(PACKAGE_ROW_ID) AS MAX_ID FROM EZGI_DESIGN_PACKAGE_ROW WITH (NOLOCK)
    </cfquery>
 	<cfquery name="add_rota" datasource="#dsn3#">
    	INSERT INTO 
			EZGI_DESIGN_PIECE_ROTA
			(
				PACKAGE_ROW_ID, 
				OPERATION_TYPE_ID, 
				SIRA, 
				AMOUNT
			)
		VALUES
         	(   
            	#get_max_id.MAX_ID#,     
				#GET_DEFAULT_PACKING.OPERATION_TYPE_ID#,
				0, 
				1
			)
    </cfquery>