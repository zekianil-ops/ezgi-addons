<!---
    File: add_ezgi_product_tree_creative_main_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 
<cfquery name="GET_DEFAULT_MODUL" datasource="#dsn3#">
	SELECT        
    	OTT.OPERATION_TYPE_ID
	FROM           
    	OPERATION_TYPES AS OTT WITH (NOLOCK) INNER JOIN
     	EZGI_DESIGN_DEFAULTS AS EDD WITH (NOLOCK) ON OTT.OPERATION_TYPE_ID = EDD.DEFAULT_MAIN_OPERATION_TYPE_ID
</cfquery>
<cfif not GET_DEFAULT_MODUL.recordcount>
	<script type="text/javascript">
		alert(<cf_get_lang dictionary_id='1172.Genel Default Tanımlarda Modül Operasyonu Tanımlı Değil. Düzenleyip Tekrar Deneyin'>);
		
		window.close()
	</script>
    <cfabort>
</cfif>
<cftransaction>
    <cfquery name="add_process" datasource="#dsn3#">
        INSERT INTO 
            EZGI_DESIGN_MAIN_ROW
            (
                DESIGN_ID, 
                DESIGN_MAIN_NAME, 
                DESIGN_MAIN_COLOR_ID, 
                MAIN_ROW_SETUP_ID, 
                DESIGN_MAIN_STATUS, 
                KARMA_KOLI_MIKTAR, 
                OLCU1,
                OLCU2,
                OLCU3,
                SALES_PRICE,
                MONEY,
                MAIN_PROTOTIP_TYPE,
                MEASURE_ID,
                PRIVATE_PRICE_TYPE,
                PRIVATE_PRICE,
                PRIVATE_PRICE_MONEY,
                RECORD_EMP, 
                RECORD_IP, 
                RECORD_DATE
            )
        VALUES        
            (
                #attributes.design_id#,
                '#attributes.design_name_main_row#',
                #attributes.color_type#,
                #attributes.setup_type#,
                1,
                <cfif len(attributes.main_row_amount)>#attributes.main_row_amount#<cfelse>NULL</cfif>,
                <cfif len(attributes.olcu1)>#attributes.olcu1#<cfelse>NULL</cfif>,
                <cfif len(attributes.olcu2)>#attributes.olcu2#<cfelse>NULL</cfif>,
                <cfif len(attributes.olcu3)>#attributes.olcu3#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.sales_price') and len(attributes.sales_price)>#filternum(attributes.sales_price)#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.money') and len(attributes.money)>'#attributes.money#'<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.spect_type') and len(attributes.spect_type)>'#attributes.spect_type#'<cfelse>0</cfif>,
                <cfif isdefined('attributes.spect_type') and attributes.spect_type eq 1 and isdefined('attributes.measure_id') and len(attributes.measure_id)>#attributes.measure_id#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.private_price_type') and isdefined('attributes.private_price_type') and len(attributes.private_price_type)>'#attributes.private_price_type#'<cfelse>0</cfif>,
                <cfif isdefined('attributes.private_price_type') and isdefined('attributes.private_price') and attributes.private_price_type neq 0>#FilterNum(attributes.private_price,2)#<cfelse>0</cfif>,
                <cfif isdefined('attributes.private_price_type') and isdefined('attributes.private_price_money') and attributes.private_price_type eq 1>'#attributes.private_price_money#'<cfelse>NULL</cfif>,
                #session.ep.userid#,
                '#cgi.remote_addr#',
                #now()#
            )
    </cfquery>
    <cfquery name="get_max_id" datasource="#dsn3#">
        SELECT MAX(DESIGN_MAIN_ROW_ID) AS MAX_ID FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
    </cfquery>
    <cfquery name="add_rota" datasource="#dsn3#">
    	INSERT INTO 
			EZGI_DESIGN_PIECE_ROTA
			(
				MAIN_ROW_ID, 
				OPERATION_TYPE_ID, 
				SIRA, 
				AMOUNT
			)
		VALUES
         	(   
            	#get_max_id.MAX_ID#,     
				#GET_DEFAULT_MODUL.OPERATION_TYPE_ID#,
				1, 
				1
			)
    </cfquery>
</cftransaction>
<script type="text/javascript">
        wrk_opener_reload();
        window.close();
</script>