<cfcomponent extends = "cfc.queryJSONConverter">
    <cfset dsn = application.systemParam.systemParam().dsn />
    <cfset dsn1 = "#dsn#_product" />
    <cfset dsn3 = "#dsn#_#session.ep.company_id#" />

    <cffunction name="set_piece" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="piece_row_id" type="numeric">
        <cfargument name="design_package_row_id" type="numeric">
        
        <cfset response = structNew() />

        <cftry>
            <cfquery name="q_set_piece" datasource="#dsn3#">
                UPDATE 
                	EZGI_DESIGN_PIECE_ROWS 
              	SET 
                	DESIGN_PACKAGE_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.design_package_row_id#">
                WHERE 
                	PIECE_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.piece_row_id#">
            </cfquery>
            <cfset response.status = true />
            <cfcatch type="any">
                <cfset response.status = false />
            </cfcatch>
        </cftry>

        <cfreturn replace(serializeJSON(response),"//","") />
    </cffunction>

    <cffunction name="get_piece" access="remote" returntype="query">
        <cfargument name="design_package_row_id" type="any" default="">
        <cfargument name="design_main_row_id" type="any" default="">
        <cfargument name="design_id" type="any" default="">
        <cfargument name="piece_type_select" type="any" default="">
        <cfargument name="piece_name_search" type="any" default="">
        <cfargument name="sort_id" type="any" default="">
        <cfargument name="startrow" type="numeric">
        <cfargument name="maxrows" type="numeric">

        <cfquery name="q_get_piece" datasource="#dsn3#">
            WITH CTE1 AS(
            	SELECT 
                    EDP.AGIRLIK,
                    EDP.BOYU,
                    EDP.DESIGN_ID,
                    EDP.DESIGN_MAIN_ROW_ID,
                    EDP.DESIGN_PACKAGE_ROW_ID,
                    EDP.ENI,
                    EDP.IS_FLOW_DIRECTION,
                    EDP.KALINLIK,
                    EDP.KESIM_BOYU,
                    EDP.KESIM_ENI,
                    EDP.MASTER_PRODUCT_ID,
                    EDP.MATERIAL_ID,
                    EDP.PACKAGE_IS_MASTER,
                    EDP.PACKAGE_PARTNER_ID,
                    EDP.PIECE_AMOUNT,
                    EDP.PIECE_CODE,
                    EDP.PIECE_COLOR_ID,
                    EDP.PIECE_DETAIL,
                    EDP.PIECE_IS_MASTER,
                    EDP.PIECE_NAME,
                    EDP.PIECE_PARTNER_ID,
                    EDP.PIECE_RELATED_ID,
                    EDP.PIECE_ROW_ID,
                    EDP.PIECE_STATUS,
                    EDP.PIECE_TYPE,
                    EDP.TRIM_SIZE,
                    EDP.TRIM_TYPE,
                    EDMR.DESIGN_MAIN_NAME,
                    EDPKG.PACKAGE_NUMBER,
                    PPD.PROPERTY_DETAIL AS KALINLIK_,
                    ISNULL(ORTAK_PARCA.ORTAK_PARCA, 0) AS ORTAK_PARCA,
                    ISNULL(USED_AMOUNT.USED_AMOUNT, 0) AS USED_AMOUNT
                FROM 
                    EZGI_DESIGN_PIECE AS EDP WITH (NOLOCK) LEFT JOIN 
                    EZGI_DESIGN_MAIN_ROW AS EDMR WITH (NOLOCK) ON EDMR.DESIGN_MAIN_ROW_ID = EDP.DESIGN_MAIN_ROW_ID LEFT JOIN 
                    EZGI_DESIGN_PACKAGE AS EDPKG WITH (NOLOCK) ON EDPKG.PACKAGE_ROW_ID = EDP.DESIGN_PACKAGE_ROW_ID LEFT JOIN 
                    #dsn1#.PRODUCT_PROPERTY_DETAIL AS PPD WITH (NOLOCK) ON PPD.PROPERTY_DETAIL_ID = EDP.KALINLIK LEFT JOIN 
                    (
                        SELECT 
                            E1.PIECE_RELATED_ID, 
                            COUNT(*) AS ORTAK_PARCA
                        FROM 
                            EZGI_DESIGN_PIECE_ROWS E1 WITH (NOLOCK) INNER JOIN
                            EZGI_DESIGN E2 WITH (NOLOCK) ON E1.DESIGN_ID = E2.DESIGN_ID
                        WHERE 
                            E1.PIECE_TYPE <> 4 AND
                            ISNULL(E2.IS_PRIVATE,0) = 0
                        GROUP BY 
                            E1.PIECE_RELATED_ID
                    ) AS ORTAK_PARCA ON ORTAK_PARCA.PIECE_RELATED_ID = EDP.PIECE_RELATED_ID LEFT JOIN 
                    (
                        SELECT 
                            EPR.RELATED_PIECE_ROW_ID,
                            SUM(EPR.AMOUNT * EP.PIECE_AMOUNT) AS USED_AMOUNT
                        FROM 
                            EZGI_DESIGN_PIECE_ROW AS EPR WITH (NOLOCK) INNER JOIN 
                            EZGI_DESIGN_PIECE_ROWS AS EP WITH (NOLOCK) ON EPR.PIECE_ROW_ID = EP.PIECE_ROW_ID
                        GROUP BY 
                            EPR.RELATED_PIECE_ROW_ID
                    ) AS USED_AMOUNT ON USED_AMOUNT.RELATED_PIECE_ROW_ID = EDP.PIECE_ROW_ID
             	WHERE 
                    1 = 1
                    <cfif isdefined('arguments.design_package_row_id') and len(arguments.design_package_row_id)>
                        AND EDP.DESIGN_PACKAGE_ROW_ID = #arguments.design_package_row_id#
                    <cfelseif isdefined('arguments.design_main_row_id') and len(arguments.design_main_row_id)>
                        AND EDP.DESIGN_MAIN_ROW_ID = #arguments.design_main_row_id#
                    <cfelseif isdefined('arguments.design_id') and len(arguments.design_id)>
                        AND EDP.DESIGN_ID = #arguments.design_id#
                    </cfif>
                    <cfif isdefined('arguments.piece_type_select') and len(arguments.piece_type_select)>
                        AND EDP.PIECE_TYPE = #arguments.piece_type_select#
                    </cfif>
                    <cfif isdefined('arguments.piece_name_search') and len(arguments.piece_name_search)>
                        AND EDP.PIECE_NAME LIKE '%#arguments.piece_name_search#%'
                    </cfif>
                GROUP BY 
                    EDP.AGIRLIK,	
                    EDP.BOYU,	
                    EDP.DESIGN_ID,	
                    EDP.DESIGN_MAIN_ROW_ID,	
                    EDP.DESIGN_PACKAGE_ROW_ID,	
                    EDP.ENI,	
                    EDP.IS_FLOW_DIRECTION,	
                    EDP.KALINLIK,	
                    EDP.KESIM_BOYU,	
                    EDP.KESIM_ENI,	
                    EDP.MASTER_PRODUCT_ID,	
                    EDP.MATERIAL_ID,	
                    EDP.PACKAGE_IS_MASTER,	
                    EDP.PACKAGE_PARTNER_ID,	
                    EDP.PIECE_AMOUNT,	
                    EDP.PIECE_CODE,	
                    EDP.PIECE_COLOR_ID,	
                    EDP.PIECE_DETAIL,	
                    EDP.PIECE_IS_MASTER,	
                    EDP.PIECE_NAME,	
                    EDP.PIECE_PARTNER_ID,	
                    EDP.PIECE_RELATED_ID,	
                    EDP.PIECE_ROW_ID,	
                    EDP.PIECE_STATUS,	
                    EDP.PIECE_TYPE,	
                    EDP.TRIM_SIZE,	
                    EDP.TRIM_TYPE,
                    EDMR.DESIGN_MAIN_NAME,
                    EDPKG.PACKAGE_NUMBER,
                    PPD.PROPERTY_DETAIL,
                    ORTAK_PARCA.ORTAK_PARCA,
                   	USED_AMOUNT.USED_AMOUNT
            ),
            CTE2 AS (
                SELECT
                    CTE1.*,
                    ROW_NUMBER() OVER (
                        ORDER BY
                        <cfif arguments.sort_id eq 5>
                            DESIGN_MAIN_NAME,CAST(PIECE_CODE AS INT)
                        <cfelseif arguments.sort_id eq 4> 
                            DESIGN_MAIN_NAME,PACKAGE_NUMBER
                        <cfelseif arguments.sort_id eq 3>
                            PIECE_COLOR_ID,DESIGN_MAIN_NAME
                        <cfelseif arguments.sort_id eq 2>
                            DESIGN_MAIN_NAME,PIECE_NAME
                        <cfelseif arguments.sort_id eq 1>
                            BOYU
                        <cfelseif arguments.sort_id eq 0>
                            PIECE_TYPE,DESIGN_MAIN_NAME
                        <cfelseif arguments.sort_id eq 6>
                            ENI,DESIGN_MAIN_NAME
                        <cfelseif arguments.sort_id eq 7>
                            KALINLIK,DESIGN_MAIN_NAME
                        <cfelseif arguments.sort_id eq 8>
                            PIECE_AMOUNT,DESIGN_MAIN_NAME
                        <cfelseif arguments.sort_id eq 9>
                            IS_FLOW_DIRECTION,DESIGN_MAIN_NAME
                        <cfelse>
                            DESIGN_PACKAGE_ROW_ID DESC
                        </cfif>
                    ) AS RowNum,
                    (SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
                FROM
                    CTE1
            )
            SELECT
                CTE2.*
            FROM
                CTE2
            WHERE
                RowNum BETWEEN #arguments.startrow# and #arguments.startrow# + (#arguments.maxrows# - 1)
        </cfquery>

        <cfreturn q_get_piece />
    </cffunction>

    <cffunction name="get_piece_json" access="remote" returntype="any" returnformat="JSON">
        <!--- <cfset sleep(500) /> --->
        <cfreturn replace( serializeJSON( this.returnData( replace( serializeJSON( this.get_piece( argumentCollection = arguments ) ),'//','' ) ) ), '//', '' ) />
    </cffunction>
</cfcomponent>