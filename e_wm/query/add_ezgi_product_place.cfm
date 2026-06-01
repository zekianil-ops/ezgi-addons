<cfif not isnumeric(attributes.department_in)>
	<cfset loc_in = listgetat(attributes.department_in,2,"-")>
	<cfset attributes.department_in=listgetat(attributes.department_in,1,"-")>
</cfif>
<!--- ayni lokasyonda tanımlanan rafin ayni olmamasi icin --->
<cfquery name="GET_PRODUCT_PLACE" datasource="#DSN3#">
	SELECT SHELF_CODE FROM PRODUCT_PLACE WHERE SHELF_CODE = '#attributes.shelf_code#' AND STORE_ID = #attributes.department_in# AND PLACE_STATUS = 1
</cfquery>

<cfif get_product_place.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='37901.Seçmiş Olduğunuz Lokasyonda Bu İsimli Bir Raf Tanımı Mevcut'> !");
        <cfif isDefined("attributes.draggable")>
            location.reload();
        <cfelse>
            history.back();
        </cfif>
	</script>
	<cfabort>
</cfif>
<cf_date tarih='attributes.START_DATE'>
<cf_date tarih='attributes.FINISH_DATE'>
<cflock name="#CreateUUID()#" timeout="60">
	<cftransaction>
        <cfquery name="ADD_PRODUCT_PLACE" datasource="#DSN3#" result="MAX_ID">
            INSERT INTO
                PRODUCT_PLACE
            (
                STORE_ID,
                <cfif isDefined("LOC_IN")>
                LOCATION_ID,
                </cfif>
                SHELF_TYPE,
                SHELF_CODE,  
                START_DATE,    
                FINISH_DATE,  
                DETAIL,
                HEIGHT,
                WIDTH,
                DEPTH,
                PLACE_STATUS,
                MIN_STOCK,
                MAX_STOCK,
                COLLECT_SORT,
                SHELF_SORT,
                SHELF_SIZE_TYPE,
                PLACE_CAT_ID,
                RECORD_EMP,  
                RECORD_EMP_IP,                              
                RECORD_DATE		
            )
            VALUES
            (
                #attributes.department_in#,
                <cfif isDefined("loc_in")> 
                #loc_in#,
                </cfif>
                #attributes.shelf_type#,
                '#attributes.shelf_code#',
                #attributes.start_date#,
                #attributes.finish_date#,
                <cfif len(attributes.detail)>'#attributes.detail#'<cfelse>NULL</cfif>,
                <cfif len(attributes.height)>#attributes.height#<cfelse>NULL</cfif>,
                <cfif len(attributes.width)>#attributes.width#<cfelse>NULL</cfif>,
                <cfif len(attributes.depth)>#attributes.depth#<cfelse>NULL</cfif>,				
                <cfif isdefined("attributes.place_status")>1<cfelse>0</cfif>,
                <cfif isdefined("attributes.min_stock") and len(attributes.min_stock)>#min_stock#<cfelse>NULL</cfif>,
                <cfif isdefined("attributes.max_stock") and len(attributes.max_stock)>#max_stock#<cfelse>NULL</cfif>,
                <cfif isdefined("attributes.collect_sort") and len(attributes.collect_sort)>#collect_sort#<cfelse>NULL</cfif>,
                <cfif isdefined("attributes.shelf_sort") and len(attributes.shelf_sort)>#shelf_sort#<cfelse>NULL</cfif>,
                <cfif isdefined("attributes.shelf_size_type") and len(attributes.shelf_size_type)>#shelf_size_type#<cfelse>NULL</cfif>,
                <cfif isdefined("attributes.shelves_cat") and len(attributes.shelves_cat)>#attributes.shelves_cat#<cfelse>NULL</cfif>,
                #session.ep.userid#,
                '#cgi.remote_addr#',		
                #now()#
            )	
        </cfquery>
        <cfquery name="GET_PRODUCT" datasource="#DSN3#">
            SELECT MAX(PRODUCT_PLACE_ID) AS MAX_PROD_PLACE_ID FROM PRODUCT_PLACE
        </cfquery>
        <cfloop from="1" to="#attributes.record_num#" index="i">
			<cfif evaluate("attributes.row_kontrol#i#") neq 0>			
            	<cfquery name="ADD_PROD_PLACE_ROWS" datasource="#DSN3#">
                	INSERT INTO
                    	PRODUCT_PLACE_ROWS
                    (
                        PRODUCT_PLACE_ID,
                        PRODUCT_ID,
                        STOCK_ID,
                        AMOUNT,
                        PACKING_SIZE_TYPE_ID                     
                    )
                    VALUES
                    (
                    	#GET_PRODUCT.MAX_PROD_PLACE_ID#,
                    	<cfif isdefined("attributes.pid#i#") and len(evaluate('attributes.pid#i#'))>#evaluate('attributes.pid#i#')#<cfelse>NULL</cfif>,
                        <cfif isdefined("attributes.stock_id#i#") and len(evaluate('attributes.stock_id#i#'))>#evaluate('attributes.stock_id#i#')#<cfelse>NULL</cfif>,
                        <cfif isdefined("attributes.quantity#i#") and len(evaluate('attributes.quantity#i#'))>#evaluate('attributes.quantity#i#')#<cfelse>NULL</cfif>,
                        <cfif isdefined("attributes.collect_type#i#") and len(evaluate('attributes.collect_type#i#'))>#evaluate('attributes.collect_type#i#')#<cfelse>NULL</cfif>
                    )
                </cfquery>
			</cfif>
        </cfloop>
	</cftransaction>
</cflock>
<cfset attributes.actionId = MAX_ID.IDENTITYCOL >
<script type="text/javascript">
    <cfif not isdefined("attributes.draggable")>
        wrk_opener_reload();
	    window.close();
    <cfelse>
        closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );
        location.reload();
    </cfif>
</script>

