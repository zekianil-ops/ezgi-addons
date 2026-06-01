<cf_date tarih='attributes.d_date'>
<cfquery name="GET_PRODUCT_PLACE" datasource="#DSN3#">
	SELECT
	DISTINCT
	<cfif isdefined('attributes.shelve_pro_cat') and len(attributes.shelve_pro_cat)>
		S.BARCOD,
		S.PRODUCT_NAME,
		S.STOCK_ID,
	<cfelse>
		'' AS BARCOD,
		'' AS PRODUCT_NAME,
		'' AS STOCK_ID,
	</cfif>
		P.PRODUCT_PLACE_ID,
		P.PRODUCT_ID,
		P.PLACE_STOCK_ID,
        P.PLACE_CAT_ID,
		P.STORE_ID,
		P.LOCATION_ID,
		P.SHELF_TYPE,
		P.SHELF_CODE,
		P.QUANTITY,
		P.DETAIL,
		P.START_DATE,
		P.PLACE_STATUS,
		P.FINISH_DATE,
		P.RECORD_DATE,
		P.RECORD_EMP,
		P.UPDATE_DATE,
		P.UPDATE_EMP,
        P.WIDTH,
        P.HEIGHT,
        P.DEPTH,
        P.PLACE_STATUS,
   		P.MIN_STOCK,	
     	P.MAX_STOCK,
     	P.COLLECT_SORT,
    	P.SHELF_SORT,
     	P.SHELF_SIZE_TYPE,
		SHELF.SHELF_NAME,
        (SELECT COUNT(*) AS SAY FROM EZGI_WM_SERIAL_NO_LAST_STATUS AS EVL INNER JOIN EZGI_WM_IS_SERIAL_NO_LIVE AS EVM ON EVL.SERIAL_NO = EVM.SERIAL_NO WHERE NOT (EVL.SHELF_CODE IS NULL) AND EVL.PRODUCT_PLACE_ID = P.PRODUCT_PLACE_ID) AS SAYI
	FROM
		PRODUCT_PLACE P,
		<cfif isdefined('attributes.stock_id') and len(attributes.stock_id) and isdefined('attributes.product_name') and len(attributes.product_name) or isdefined('attributes.shelve_pro_cat') and len(attributes.shelve_pro_cat)>
			PRODUCT_PLACE_ROWS PR,
		</cfif>	
		<cfif isdefined('attributes.shelve_pro_cat') and len(attributes.shelve_pro_cat)>
            STOCKS S,
		</cfif>
		<cfif isdefined("attributes.branch_id")>
            #dsn_alias#.DEPARTMENT D,
		</cfif>	
		#dsn_alias#.SHELF SHELF
	WHERE 
		P.SHELF_TYPE = SHELF.SHELF_ID 
        <cfif isdefined("attributes.product_place_id") and len(attributes.product_place_id)>
            AND P.PRODUCT_PLACE_ID = #attributes.product_place_id#
		</cfif>
        <cfif isdefined('attributes.shelves_cat') and len(attributes.shelves_cat)>
           AND P.PLACE_CAT_ID = #attributes.shelves_cat#
       	</cfif>
		<cfif isdefined("attributes.branch_id") and len(attributes.place_status)>
            AND P.PLACE_STATUS = <cfif place_status eq 1>1<cfelse>0</cfif>
		</cfif>
        <cfif isdefined('attributes.stock_id') and len(attributes.stock_id) and isdefined('attributes.product_name') and len(attributes.product_name) or isdefined('attributes.shelve_pro_cat') and len(attributes.shelve_pro_cat)>
            AND P.PRODUCT_PLACE_ID = PR.PRODUCT_PLACE_ID
            <cfif isdefined('attributes.stock_id') and len(attributes.stock_id) and isdefined('attributes.product_name') and len(attributes.product_name)>
	            AND PR.STOCK_ID = #attributes.stock_id#
			</cfif>
            <cfif isdefined('attributes.shelve_pro_cat') and len(attributes.shelve_pro_cat)>
            	AND PR.PRODUCT_ID = S.PRODUCT_ID
            	AND S.PRODUCT_CATID = #attributes.SHELVE_PRO_CAT#
            </cfif>
		</cfif>
		<cfif isdefined("attributes.branch_id")>
            AND D.DEPARTMENT_ID=P.STORE_ID
            AND D.BRANCH_ID = #attributes.BRANCH_ID#
		</cfif>
		<cfif isDefined("attributes.shelf_type") and len(attributes.shelf_type)>
            AND SHELF_TYPE = #attributes.shelf_type#
		</cfif>
		<cfif isDefined("attributes.store") and len(attributes.store)>
            AND P.STORE_ID = #attributes.store#
		</cfif>
        <cfif isdefined('attributes.place_status') and len(attributes.place_status)>
            AND PLACE_STATUS= #attributes.place_status#
		</cfif>
		<cfif isDefined('attributes.store_loc_id') >
			<cfif not isnumeric(attributes.store_loc_id)>
				<cfset attributes.store_loc_id=listgetat(attributes.store_loc_id,1,"-")>
				AND STORE_ID = #attributes.store_loc_id#
			<cfelse>
				AND STORE_ID = #attributes.store_loc_id#
			</cfif>
		</cfif>
		<cfif isDefined('attributes.keyword') and len(attributes.keyword)>
		AND 
			(
				P.DETAIL LIKE '#attributes.keyword#%' OR
				P.SHELF_CODE LIKE '#attributes.keyword#%'
			)
		</cfif>
        <cfif isdefined("attributes.empty_shelf") and attributes.empty_shelf eq 1>
			AND P.PRODUCT_PLACE_ID NOT IN (SELECT DISTINCT PRODUCT_PLACE_ID FROM PRODUCT_PLACE_ROWS)
		</cfif>
	ORDER BY 
		P.SHELF_CODE
</cfquery>
<cfif len(GET_PRODUCT_PLACE.PRODUCT_PLACE_ID)>
	<cfquery name="GET_PROD_PLACE_ROWS" datasource="#DSN3#">
		SELECT
			PP.PRODUCT_PLACE_ID,
			PP.PRODUCT_ID,
			PP.STOCK_ID,
			PP.AMOUNT,
            PP.PACKING_SIZE_TYPE_ID,
			S.PRODUCT_NAME + ' ' + ISNULL(S.PROPERTY,'') AS PRODUCT_NAME,
			S.STOCK_CODE,
			P.PRODUCT_CODE_2 AS SPECIAL_CODE
		FROM
			PRODUCT_PLACE_ROWS PP,
			STOCKS S
			LEFT JOIN PRODUCT AS P ON P.PRODUCT_ID = S.PRODUCT_ID
		WHERE
			PP.PRODUCT_ID = S.PRODUCT_ID AND
			PP.STOCK_ID = S.STOCK_ID AND
			PP.PRODUCT_PLACE_ID = #GET_PRODUCT_PLACE.PRODUCT_PLACE_ID#
	</cfquery>
<cfelse>
	<cfset GET_PROD_PLACE_ROWS.recordcount = 0>
</cfif>
