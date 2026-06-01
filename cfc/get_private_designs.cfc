<cffunction name="get_designs_" returntype="query">
	<cfargument name="dsn_alias" default="">
	<cfargument name="keyword" default="">
    <cfargument name="oby" default="">
    <cfargument name="status" default="">
    <cfargument name="design_type" default="">
	<cfargument name="color_type" default="">
	<cfargument name="is_prototip" default="">
    <cfargument name="member_name" default="">
    <cfargument name="company_id" default="">
    <cfargument name="consumer_id" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="get_designs" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (
            SELECT
                *
            FROM
                (
                    SELECT
                        *
                    FROM
                        (
                            SELECT  
                                *,
                                CASE
                                    WHEN O.COMPANY_ID IS NOT NULL THEN
                                       (
                                        SELECT     
                                            FULLNAME
                                        FROM         
                                            #dsn_alias#.COMPANY WITH (NOLOCK)
                                        WHERE     
                                            COMPANY_ID = O.COMPANY_ID
                                        )
                                    WHEN O.CONSUMER_ID IS NOT NULL THEN      
                                        (	
                                        SELECT     
                                            CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                                        FROM         
                                            #dsn_alias#.CONSUMER WITH (NOLOCK)
                                        WHERE     
                                            CONSUMER_ID = O.CONSUMER_ID
                                        )
                                END
                                    AS UNVAN
                            FROM 
                                EZGI_DESIGN O WITH (NOLOCK)
                            WHERE 
                                ISNULL(IS_PRIVATE,0) = 1
                            
								<cfif isdefined('arguments.process_stage') and len(arguments.process_stage)>
                                    AND PROCESS_STAGE = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_stage#">
                                </cfif>
                                <cfif len(arguments.company_id) and len(arguments.member_name)>
                                    AND COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#">
                                </cfif>
                                <cfif len(arguments.consumer_id) and len(arguments.member_name)>
                                    AND CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#">
                                </cfif>
                                <cfif arguments.status eq 2>
                                    AND STATUS = 1
                                <cfelseif arguments.status eq 3>
                                    AND STATUS = 0
                                </cfif>
                        ) AS TBL
                ) AS TBL1
            WHERE
                1=1
                <cfif isdefined('arguments.keyword') and len(arguments.keyword)>
                    AND 
                    (
                        UNVAN LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> OR
                        DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> OR
                        DESIGN_ID IN 
                        			(
                                        SELECT        
                                            EDM.DESIGN_ID
                                        FROM            
                                            EZGI_DESIGN_MAIN_ROW AS EDM INNER JOIN
                                            OFFER_ROW AS OFR ON EDM.WRK_ROW_RELATION_ID = OFR.WRK_ROW_ID INNER JOIN
                                            OFFER AS O ON OFR.OFFER_ID = O.OFFER_ID
                                        WHERE        
                                            O.OFFER_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                               		)
                    )
                </cfif>
   		),
        CTE2 AS (
                    SELECT
                        CTE1.*,
                        ROW_NUMBER() OVER (	ORDER BY
                                            <cfif arguments.oby eq 1>
                                                RECORD_DATE
                                            <cfelseif arguments.oby eq 2>
												RECORD_DATE DESC
                                            </cfif>
                                        ) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
                    FROM
                        CTE1
				)
      	SELECT
			CTE2.*
		FROM
			CTE2
		WHERE
			RowNum BETWEEN #startrow# and #startrow#+(#maxrows#-1)
	</cfquery>
	<cfreturn get_designs>
</cffunction>
        	