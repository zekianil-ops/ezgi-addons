<cfif not isnumeric(attributes.department_in)>
	<cfset loc_in = listgetat(attributes.department_in,2,"-")>
	<cfset attributes.department_in = listfirst(attributes.department_in,"-")>
</cfif>
<!--- ayni lokasyonda tanımlanan rafin ayni olmamasi icin --->
<cfif isdefined('attributes.place_status') and attributes.place_status eq 1> <!--- pasif yapılacaksa kontrol yapılmıyor --->
	<cfquery name="GET_PRODUCT_PLACE" datasource="#DSN3#">
		SELECT
			SHELF_CODE
		FROM
			PRODUCT_PLACE 
		WHERE 
			SHELF_CODE = '#attributes.shelf_code#' AND
			STORE_ID = #attributes.department_in# AND
			PRODUCT_PLACE_ID <> #attributes.product_place_id#
	</cfquery>
	<cfif get_product_place.recordcount>
		<script type="text/javascript">
			alert("<cf_get_lang no ='889.Seçmiş Olduğunuz Lokasyonda Bu İsimli Bir Raf Tanımı Mevcut'> !");
			history.back();
		</script>
		<cfabort>
	</cfif>
</cfif>
<cf_date tarih='attributes.START_DATE'>
<cf_date tarih='attributes.FINISH_DATE'>
    <cfquery name="UPD_PRODUCT_PLACE" datasource="#DSN3#">
        UPDATE
            PRODUCT_PLACE
        SET
            PRODUCT_ID = <cfif isdefined('attributes.product_id') and len(attributes.product_id)>#attributes.product_id#<cfelse>NULL</cfif>,
            PLACE_STOCK_ID = <cfif isdefined('attributes.stock_id') and len(attributes.stock_id)>#attributes.stock_id#<cfelse>NULL</cfif>,
            PLACE_STATUS = <cfif isdefined('attributes.place_status')>1<cfelse>0</cfif>,
            STORE_ID = #attributes.department_in#,
            <cfif isDefined("loc_in")> 
            LOCATION_ID = #loc_in#,
            </cfif>
            SHELF_TYPE = #attributes.shelf_type#,
            SHELF_CODE = '#attributes.shelf_code#',
            QUANTITY = <cfif isdefined('attributes.quantity') and len(attributes.quantity)>#attributes.quantity#<cfelse>NULL</cfif>,
            START_DATE = #attributes.start_date#,   
            FINISH_DATE = #attributes.finish_date#,
            DETAIL = '#attributes.detail#',
            HEIGHT = <cfif len(attributes.height)>#attributes.height#<cfelse>NULL</cfif>,
            WIDTH = <cfif len(attributes.width)>#attributes.width#<cfelse>NULL</cfif>,
            DEPTH = <cfif len(attributes.depth)>#attributes.depth#<cfelse>NULL</cfif>,
            MIN_STOCK = <cfif isdefined("attributes.min_stock") and len(attributes.min_stock)>#min_stock#<cfelse>NULL</cfif>,
          	MAX_STOCK = <cfif isdefined("attributes.max_stock") and len(attributes.max_stock)>#max_stock#<cfelse>NULL</cfif>,
          	COLLECT_SORT = <cfif isdefined("attributes.collect_sort") and len(attributes.collect_sort)>#collect_sort#<cfelse>NULL</cfif>,
          	SHELF_SORT = <cfif isdefined("attributes.shelf_sort") and len(attributes.shelf_sort)>#shelf_sort#<cfelse>NULL</cfif>,
          	SHELF_SIZE_TYPE = <cfif isdefined("attributes.shelf_size_type") and len(attributes.shelf_size_type)>#shelf_size_type#<cfelse>NULL</cfif>,
            PLACE_CAT_ID = <cfif isdefined("attributes.shelves_cat") and len(attributes.shelves_cat)>#attributes.shelves_cat#<cfelse>NULL</cfif>,
            UPDATE_EMP = #session.ep.userid#,
            UPDATE_EMP_IP = '#cgi.remote_addr#',	                           
            UPDATE_DATE = #now()#
        WHERE
            PRODUCT_PLACE_ID = #attributes.product_place_id#	
    </cfquery>
    <cfquery name="DEL_PROD_PLACE_ROW" datasource="#DSN3#">
        DELETE FROM PRODUCT_PLACE_ROWS WHERE PRODUCT_PLACE_ID = #attributes.product_place_id#
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
                    #attributes.product_place_id#,
                    <cfif isdefined("attributes.pid#i#") and len(evaluate('attributes.pid#i#'))>#evaluate('attributes.pid#i#')#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.stock_id#i#") and len(evaluate('attributes.stock_id#i#'))>#evaluate('attributes.stock_id#i#')#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.quantity#i#") and len(evaluate('attributes.quantity#i#'))>#evaluate('attributes.quantity#i#')#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.collect_type#i#") and len(evaluate('attributes.collect_type#i#'))>#evaluate('attributes.collect_type#i#')#<cfelse>NULL</cfif>
                )
            </cfquery>
        </cfif>
    </cfloop>
    <cfset attributes.actionId = attributes.product_place_id >
	<script type="text/javascript">
        <cfif not isdefined("attributes.draggable")>
            wrk_opener_reload();
            self.close();
        <cfelse>
            closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );
            location.reload();
        </cfif>
    </script>
