<cffunction name="get_virtual_offers_" returntype="query">
    <cfargument name="keyword" default="">
    <cfargument name="offer_stage" default="">
    <cfargument name="sort_type" default="">
    <cfargument name="branch_id" default="">
    <cfargument name="durum_siparis" default="">
    <cfargument name="member_cat_type" default="">
    <cfargument name="consumer_id" default="">
    <cfargument name="company_id" default="">
    <cfargument name="member_name" default="">
    <cfargument name="member_type" default="">
    <cfargument name="bayi_consumer_id" default="">
    <cfargument name="bayi_company_id" default="">
    <cfargument name="bayi_member_name" default="">
    <cfargument name="bayi_member_type" default="">
    <cfargument name="record_emp_id" default="">
    <cfargument name="record_emp_name" default="">
    <cfargument name="sales_emp_id" default="">
    <cfargument name="sales_emp_name" default="">
    <cfargument name="category_name" default="">
    <cfargument name="currency_type" default="">
    <cfargument name="list_type" default="">
    <cfargument name="currency_id" default="">
    <cfargument name="sales_type" default="">
    <cfargument name="project_type" default="">
    <cfargument name="start_date" default="">
    <cfargument name="finish_date" default="">
    <cfargument name="deliver_start_date" default="">
    <cfargument name="deliver_finish_date" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="get_virtual_offers" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (
        SELECT        
        	O.VIRTUAL_OFFER_ID, 
            O.VIRTUAL_OFFER_NUMBER, 
	    	O.VIRTUAL_OFFER_HEAD, 
            O.VIRTUAL_OFFER_DATE, 
            O.VIRTUAL_OFFER_DETAIL, 
            O.VIRTUAL_OFFER_STATUS, 
            O.VIRTUAL_OFFER_STAGE,
            O.CONSUMER_ID, 
            O.COMPANY_ID, 
            O.PARTNER_ID, 
            O.REF_NO,
            O.RECORD_EMP,
            O.RECORD_DATE,
            O.RECORD_PAR,
            O.MEMBER_TYPE,
            O.PARTNER_COMPANY_ID,
            O.SALES_COMPANY_ID,
            O.BRANCH_ID,
            O.REVISION_NO,
            O.FINISHDATE,
            ISNULL(O.NETTOTAL,0) NETTOTAL,
            ISNULL(O.TAXTOTAL,0) TAXTOTAL,
            ISNULL((
            		SELECT  TOP (1)     
                    	OFR.OFFER_ID
					FROM            
                    	EZGI_VIRTUAL_OFFER_ROW AS OFFR INNER JOIN
                    	OFFER_ROW AS OFR ON OFFR.WRK_ROW_RELATION_ID = OFR.WRK_ROW_ID
					WHERE        
                    	OFFR.VIRTUAL_OFFER_ID = O.VIRTUAL_OFFER_ID
            
         	),0) AS OFFER_ID
            <cfif arguments.list_type eq 2>
            	, 
                ORR.VIRTUAL_OFFER_ROW_ID, 
                ORR.PRODUCT_TYPE, 
                ORR.PRODUCT_ID, 
                ORR.PRODUCT_NAME, 
                ORR.PRODUCT_NAME2,
                ORR.QUANTITY, 
                ORR.UNIT, 
                ORR.VIRTUAL_OFFER_ROW_CURRENCY, 
                ORR.IS_STANDART,
                ORR.DELIVER_AMOUNT
            </cfif>
		FROM            
        	EZGI_VIRTUAL_OFFER AS O
            <cfif arguments.list_type eq 2>
                ,
                EZGI_VIRTUAL_OFFER_ROW AS ORR 
            </cfif>
      	WHERE
        	VIRTUAL_OFFER_STATUS = 1
            <cfif arguments.list_type eq 2>
            	AND O.VIRTUAL_OFFER_ID = ORR.VIRTUAL_OFFER_ID
                <cfif len(arguments.currency_id)>
                	<cfif len(arguments.currency_type)>
                    	AND ORR.VIRTUAL_OFFER_ROW_CURRENCY <> #arguments.currency_id#
                    <cfelse>
                		AND ORR.VIRTUAL_OFFER_ROW_CURRENCY = #arguments.currency_id#
                    </cfif>
                </cfif>
            <cfelse>
            	<cfif len(arguments.currency_id)>
                	<cfif len(arguments.currency_type)>
                    	AND O.VIRTUAL_OFFER_ID IN
                        						(
                                					SELECT DISTINCT 
                                                    	VIRTUAL_OFFER_ID
													FROM         
                                                    	EZGI_VIRTUAL_OFFER_ROW
													WHERE        
                                                    	VIRTUAL_OFFER_ROW_CURRENCY <> #arguments.currency_id#
                                				)
                    <cfelse>
                		AND O.VIRTUAL_OFFER_ID IN
                        						(
                                					SELECT DISTINCT 
                                                    	VIRTUAL_OFFER_ID
													FROM         
                                                    	EZGI_VIRTUAL_OFFER_ROW
													WHERE        
                                                    	VIRTUAL_OFFER_ROW_CURRENCY = #arguments.currency_id#
                                				)
                    </cfif>
                </cfif>
            </cfif>
            <cfif len(arguments.member_name)>
            	<cfif isdefined('arguments.company_id') and len(arguments.company_id)>
                    AND O.COMPANY_ID =#arguments.company_id#
                </cfif>
                <cfif isdefined('arguments.consumer_id') and len(arguments.consumer_id)>
                    AND O.CONSUMER_ID =#arguments.consumer_id# 
                </cfif>
           	</cfif>
            <cfif len(arguments.bayi_member_name)>
            	<cfif isdefined('arguments.bayi_company_id') and len(arguments.bayi_company_id)>
                    AND O.SALES_COMPANY_ID = #arguments.bayi_company_id#
                </cfif>
           	</cfif>
            <cfif len(arguments.keyword)>
            	AND 
                (
                	O.VIRTUAL_OFFER_NUMBER LIKE '%#arguments.keyword#%' OR
                    O.VIRTUAL_OFFER_DETAIL LIKE '%#arguments.keyword#%' OR
                    O.VIRTUAL_OFFER_HEAD LIKE '%#arguments.keyword#%' 
              	)
            </cfif>
            <cfif len(arguments.record_emp_name) and len(arguments.record_emp_id)>
            	AND O.RECORD_EMP = #arguments.record_emp_id#
            </cfif>
            <cfif len(arguments.sales_emp_name) and len(arguments.sales_emp_id)>
            	AND O.VIRTUAL_OFFER_EMPLOYEE_ID = #arguments.sales_emp_id#
            </cfif>
            <cfif arguments.durum_siparis eq 1>
            	AND ISNULL((
            		SELECT TOP (1)        
                    	OFR.OFFER_ID 
					FROM            
                    	EZGI_VIRTUAL_OFFER_ROW AS OFFR INNER JOIN
                    	OFFER_ROW AS OFR ON OFFR.WRK_ROW_RELATION_ID = OFR.WRK_ROW_ID
					WHERE        
                    	OFFR.VIRTUAL_OFFER_ID = O.VIRTUAL_OFFER_ID
         			),0) > 0
             <cfelseif arguments.durum_siparis eq 2>   
                AND ISNULL((
            		SELECT  TOP (1)      
                    	OFR.OFFER_ID  
					FROM            
                    	EZGI_VIRTUAL_OFFER_ROW AS OFFR INNER JOIN
                    	OFFER_ROW AS OFR ON OFFR.WRK_ROW_RELATION_ID = OFR.WRK_ROW_ID
					WHERE        
                    	OFFR.VIRTUAL_OFFER_ID = O.VIRTUAL_OFFER_ID
         			),0) <= 0
            </cfif>
            <cfif session.ep.ISBRANCHAUTHORIZATION eq 1>
            	AND ISNULL(O.BRANCH_ID,0) IN 
                				(
                                SELECT        
                                	BRANCH_ID
								FROM   
                                	#dsn_alias#.EMPLOYEE_POSITION_BRANCHES
								WHERE        
                                	POSITION_CODE = #session.ep.POSITION_CODE# AND 
                                    DEPARTMENT_ID IS NULL
                                
                                )
            </cfif>
            <cfif len(arguments.branch_id)>
            	AND O.BRANCH_ID = #arguments.branch_id#
            </cfif>
            <cfif len(arguments.offer_stage)>
            	AND VIRTUAL_OFFER_STAGE IN (#arguments.offer_stage#)
            </cfif>
            <cfif arguments.sales_type eq 1>
            	AND SALES_COMPANY_ID IS NOT NULL
           	<cfelseif arguments.sales_type eq 2>
            	AND BRANCH_ID IS NOT NULL	
            </cfif>
            <cfif arguments.project_type eq 1>
            	AND ISNULL(PROJECT_ID,0)>0
           	<cfelseif arguments.project_type eq 2>
                AND (ISNULL(PROJECT_ID,0) = 0 OR ISNULL(PROJECT_ID,0) =-1)
            </cfif>
            <cfif len(arguments.start_date)>
            	AND O.VIRTUAL_OFFER_DATE >= #arguments.start_date#
            </cfif>
            <cfif len(arguments.finish_date)>
            	AND O.VIRTUAL_OFFER_DATE <= #arguments.finish_date#
            </cfif>
            <cfif len(arguments.deliver_start_date)>
            	AND O.FINISHDATE >= #arguments.deliver_start_date#
            </cfif>
            <cfif len(arguments.deliver_finish_date)>
            	AND O.FINISHDATE <= #arguments.deliver_finish_date#
            </cfif>
    	),
           CTE2 AS (
				SELECT
					CTE1.*,
					ROW_NUMBER() OVER (	ORDER BY
										<cfif arguments.sort_type eq 2>
                                            VIRTUAL_OFFER_NUMBER
                                        <cfelseif arguments.sort_type eq 3>
                                            RECORD_DATE DESC
                                        <cfelseif arguments.sort_type eq 4>
                                            VIRTUAL_OFFER_DATE
                                        <cfelseif arguments.sort_type eq 5>
                                            VIRTUAL_OFFER_DATE desc
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
	<cfreturn get_virtual_offers>
</cffunction>
        	