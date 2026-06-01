<cfcomponent>
	<cffunction name="get_orders_fnc" returntype="query">
		<cfargument name="ajax" default="">
		<cfargument name="branch_id" default="">
		<cfargument name="station_id" default="">
		<cfargument name="department_id" default="">
		<cfargument name="stock_id_" default="">
		<cfargument name="product_name" default="">
		<cfargument name="durum_siparis" default="">
		<cfargument name="priority" default="">
		<cfargument name="position_code" default="">
		<cfargument name="position_name" default="">
		<cfargument name="short_code_id" default="">
		<cfargument name="short_code_name" default="">
		<cfargument name="keyword" default="">
		<cfargument name="start_date" default="">
		<cfargument name="finish_date" default="">
		<cfargument name="start_date_order" default="">
		<cfargument name="finish_date_order" default="">
		<cfargument name="sales_partner" default="">
		<cfargument name="sales_partner_id" default="">
		<cfargument name="order_employee" default="">
		<cfargument name="order_employee_id" default="">
		<cfargument name="member_name" default="">
		<cfargument name="company_id" default="">
		<cfargument name="consumer_id" default="">
		<cfargument name="project_head" default="">
		<cfargument name="project_id" default="">
		<cfargument name="member_cat_type" default="">
		<cfargument name="spect_main_id" default="">
		<cfargument name="product_id_" default="">
		<cfargument name="spect_name" default="">
		<cfargument name="category_name" default="">
		<cfargument name="category" default="">
		<cfargument name="date_filter" default="">
		<cfquery name="get_general_info" datasource="#this.dsn3#">
            SELECT ISNULL(IS_SERIAL_CONTROL_LOCATION,0) AS IS_SERIAL_CONTROL_LOCATION FROM #this.dsn_alias#.OUR_COMPANY_INFO WHERE COMP_ID = #session.ep.company_id#
        </cfquery>
		<cfif isdefined('arguments.ajax')><!--- Üretimdeki Çizelge Sayfasından geliyor ise --->
			<cfif isdefined('arguments.branch_id') and len(arguments.branch_id) and isdefined('arguments.station_id') and not len(arguments.station_id)><!--- Şube veya departman seçilmiş ancak istasyon seçilmemiş ise --->
				<cfquery name="GET_BRANCH_STATIONS" datasource="#this.DSN3#">
					SELECT STATION_ID FROM WORKSTATIONS WHERE BRANCH = #arguments.branch_id# <cfif isdefined('arguments.department_id')and len(arguments.department_id)> AND DEPARTMENT = #arguments.department_id#</cfif>
				</cfquery>
				<cfset arguments.station_id = ValueList(GET_BRANCH_STATIONS.STATION_ID,',')>
			</cfif>
			<!--- İstasyon SEçilmiş ise --->
			<cfif isdefined('arguments.station_id') and len(arguments.station_id)><!--- İstasyon seçili ise --->
				<cfquery name="GET_STATIONS_PRODUCT" datasource="#this.DSN3#">
					SELECT 
						STOCK_ID 
					FROM 
						WORKSTATIONS_PRODUCTS 
					WHERE 
						STOCK_ID IS NOT NULL AND
						WS_ID IN (#arguments.station_id#)
				</cfquery>
				<cfset station_stock_id_list = ValueList(GET_STATIONS_PRODUCT.STOCK_ID,',')>
			</cfif>				
		</cfif>
		<cfquery name="GET_ORDERS" datasource="#this.DSN3#">
			SELECT DISTINCT
				ISNULL((SELECT SPECT_MAIN_ID FROM SPECTS WHERE SPECT_VAR_ID =ORR.SPECT_VAR_ID),0) AS SPECT_MAIN_ID,
				ORR.PRODUCT_ID,
				ORR.ORDER_ROW_ID,
				ORR.QUANTITY, 
				ORR.UNIT,
				ORR.ORDER_ROW_CURRENCY,
				ORR.SPECT_VAR_ID,
				S.PROPERTY, 
				CASE WHEN S.STOCK_CODE = '' THEN '_' ELSE ISNULL(S.STOCK_CODE,'_') END AS STOCK_CODE,
				ORR.UNIT2,
				ORR.AMOUNT2,
				ORR.DELIVER_DATE AS ROW_DELIVER_DATE,
				S.STOCK_ID,
				S.PRODUCT_NAME,
				S.STOCK_CODE,
				O.ORDER_ID,
				O.ORDER_NUMBER,
				O.ORDER_HEAD,
				O.OTHER_MONEY,
				O.TAX,
				O.GROSSTOTAL, 
				O.ORDER_DATE, 
				O.DELIVERDATE, 
				O.RECORD_EMP,
				O.COMPANY_ID,
				S.PRODUCT_ID,
				O.CONSUMER_ID,
				O.PROJECT_ID,
				ORR.WRK_ROW_ID,
				ORR.RESERVE_TYPE,
				CAST(O.ORDER_DETAIL AS NVARCHAR(250)) ORDER_DETAIL,
				O.ORDER_EMPLOYEE_ID
			FROM 
				ORDERS O,
				ORDER_ROW ORR, 
				STOCKS S,
				PRODUCT_UNIT PU
			WHERE
            	<!---ISNULL(S.IS_SERIAL_NO, 0) = 0 AND--->
				( (O.PURCHASE_SALES = 1 AND O.ORDER_ZONE = 0) OR (O.PURCHASE_SALES = 0 AND O.ORDER_ZONE = 1) ) AND <!--- SADECE SATIŞ SİPARİŞLER ---> 
				PU.PRODUCT_ID = S.PRODUCT_ID AND
				ORR.STOCK_ID = S.STOCK_ID AND
				ORR.PRODUCT_ID = S.PRODUCT_ID AND
				S.IS_PRODUCTION = 1 AND
				ORR.ORDER_ID = O.ORDER_ID AND
				O.ORDER_STATUS = 1
				<cfif isdefined('arguments.stock_id_') and len(arguments.stock_id_) and len(arguments.product_name)>
					AND S.STOCK_ID IN (#arguments.stock_id_#)
				</cfif>	
				<cfif arguments.durum_siparis eq 1>
					AND ORR.ORDER_ROW_ID IN (SELECT POR.ORDER_ROW_ID FROM PRODUCTION_ORDERS_ROW POR,PRODUCTION_ORDERS PO WHERE PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID AND POR.ORDER_ROW_ID IS NOT NULL AND PO.IS_STAGE<>-1)
				<cfelseif arguments.durum_siparis eq 0>
					AND ORR.ORDER_ROW_ID NOT IN (SELECT POR.ORDER_ROW_ID FROM PRODUCTION_ORDERS_ROW POR,PRODUCTION_ORDERS PO WHERE PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID AND POR.ORDER_ROW_ID IS NOT NULL AND PO.IS_STAGE<>-1) <cfif get_general_info.IS_SERIAL_CONTROL_LOCATION> <!---Seri No Çalışacaksa ---> AND (SELECT COUNT(*) AS AMOUNT FROM EZGI_WM_SERIAL_NO_ORDER_LAST_STATUS AS EW INNER JOIN EZGI_WM_IS_SERIAL_NO_LIVE AS EWL ON EW.SERIAL_NO = EWL.SERIAL_NO WHERE EW.RESERVE_ORDER_ROW_ID = ORR.ORDER_ROW_ID) = 0 AND	ORR.ORDER_ROW_CURRENCY = -5 AND (SELECT COUNT(*) AS AMOUNT FROM PRODUCTION_ORDERS_ROW WHERE ORDER_ROW_ID = ORR.ORDER_ROW_ID)=0</cfif>
				<cfelseif arguments.durum_siparis eq 2>
					AND ORR.ORDER_ROW_ID IN (SELECT POR.ORDER_ROW_ID FROM PRODUCTION_ORDERS_ROW POR,PRODUCTION_ORDERS PO WHERE PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID AND POR.ORDER_ROW_ID IS NOT NULL AND PO.IS_STAGE=-1)
				<cfelseif arguments.durum_siparis eq 3>
					AND ORR.ORDER_ROW_ID NOT IN (SELECT POR.ORDER_ROW_ID FROM PRODUCTION_ORDERS_ROW POR,PRODUCTION_ORDERS PO WHERE PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID AND POR.ORDER_ROW_ID IS NOT NULL AND PO.IS_STAGE=-1)
				<cfelseif arguments.durum_siparis eq 4>
					AND ORR.ORDER_ROW_ID NOT IN (
                    								SELECT 
                                                		POR.ORDER_ROW_ID 
                                               		FROM 
                                               			PRODUCTION_ORDERS_ROW POR,
                                               			PRODUCTION_ORDERS PO 
                                               		WHERE 
                                                    	PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID AND 
                                                        POR.ORDER_ROW_ID IS NOT NULL AND 
                                                        PO.IS_STAGE<>-1
                                             	) 
                <cfelseif arguments.durum_siparis eq 5>
                	AND ORR.ORDER_ROW_ID IN (	SELECT 
                    								POR.ORDER_ROW_ID 
                                              	FROM 
                                                	PRODUCTION_ORDERS_ROW POR,
                                                    PRODUCTION_ORDERS PO 
                                               	WHERE 
                                                	PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID AND 
                                                    POR.ORDER_ROW_ID IS NOT NULL AND 
                                                    PO.IS_STAGE<>-1
                                           	)
					AND ORR.QUANTITY > (
                    						SELECT 
                                            	SUM(PO.QUANTITY) QUANTITY 
                                           	FROM 
                                            	PRODUCTION_ORDERS_ROW 
                                                POR,PRODUCTION_ORDERS PO 
                                         	WHERE 
                                            	PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID AND 
                                                POR.ORDER_ROW_ID = ORR.ORDER_ROW_ID AND 
                                                PO.IS_STAGE<>-1 AND 
                                                ORR.STOCK_ID = PO.STOCK_ID
                                     	)
				<cfelseif arguments.durum_siparis eq 6>
                	AND ORR.ORDER_ROW_ID IN (SELECT POR.ORDER_ROW_ID FROM PRODUCTION_ORDERS_ROW POR,PRODUCTION_ORDERS PO WHERE PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID AND POR.ORDER_ROW_ID IS NOT NULL AND PO.IS_STAGE=-1)
					AND ORR.QUANTITY > (SELECT SUM(PO.QUANTITY) QUANTITY FROM PRODUCTION_ORDERS_ROW POR,PRODUCTION_ORDERS PO WHERE PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID AND POR.ORDER_ROW_ID = ORR.ORDER_ROW_ID AND PO.IS_STAGE=-1 AND ORR.STOCK_ID = PO.STOCK_ID)
				<cfelse>
					AND	ORR.ORDER_ROW_CURRENCY = -5
				</cfif>
				<cfif len(arguments.priority)>
					AND O.PRIORITY_ID = #arguments.priority#
				</cfif>
				<cfif len(arguments.position_code) and len(arguments.position_name)>
					AND S.PRODUCT_CATID IN(SELECT 
												PC2.PRODUCT_CATID
											FROM 
												PRODUCT_CAT PC1,
												PRODUCT_CAT PC2 
											WHERE 
												PC1.POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.position_code#">
												AND (PC2.HIERARCHY LIKE PC1.HIERARCHY+'.%' OR PC1.HIERARCHY LIKE PC2.HIERARCHY+'.%' OR PC1.PRODUCT_CATID=PC2.PRODUCT_CATID)
											)
				</cfif>
				<cfif isdefined("arguments.short_code_id") and len(arguments.short_code_id) and len(arguments.short_code_name)>
					AND	S.SHORT_CODE_ID = #arguments.short_code_id# 
				</cfif>	
				<cfif isdefined("arguments.brand_id") and len(arguments.brand_id) and len(arguments.brand_name)>
					AND	S.BRAND_ID = #arguments.brand_id#
				</cfif>	
				<cfif len(arguments.keyword)>
					AND O.ORDER_NUMBER LIKE '<cfif len(arguments.keyword) gt 2>%</cfif>#arguments.keyword#%'
				</cfif>
				<cfif len(arguments.start_date)>
					AND O.DELIVERDATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.start_date#">
				</cfif>
				<cfif len(arguments.finish_date)>
					AND O.DELIVERDATE < #DATEADD('d',1,arguments.finish_date)#
				</cfif>
				<cfif len(arguments.start_date_order)>
					AND O.ORDER_DATE >= #arguments.start_date_order#
				</cfif>
				<cfif len(arguments.finish_date_order)>
					AND O.ORDER_DATE < #DATEADD('d',1,arguments.finish_date_order)#
				</cfif>
				<cfif len(arguments.sales_partner) and len(arguments.sales_partner_id)>
					AND O.SALES_PARTNER_ID = #arguments.sales_partner_id#
				</cfif>
				<cfif len(arguments.order_employee) and len(arguments.order_employee_id)>
					AND O.ORDER_EMPLOYEE_ID = #arguments.order_employee_id#
				</cfif>
				<cfif len(arguments.member_name) and len(arguments.company_id)><!--- (arguments.member_type is 'partner') and  --->
					AND O.COMPANY_ID = #arguments.company_id#
				</cfif>
				<cfif len(arguments.member_name) and len(arguments.consumer_id)><!--- (arguments.member_type is 'consumer') and  --->
					AND O.CONSUMER_ID = #arguments.consumer_id#
				</cfif>
				<cfif isdefined('arguments.project_head') and len(arguments.project_head) and len(arguments.project_id)>
					AND O.PROJECT_ID = #arguments.project_id#	
				</cfif>
				<cfif isdefined("arguments.member_cat_type") and listlen(arguments.member_cat_type,'-') eq 2 and listfirst(arguments.member_cat_type,'-') eq '1'>
					AND O.COMPANY_ID IN (SELECT COMPANY_ID FROM #this.dsn_alias#.COMPANY WHERE COMPANYCAT_ID = #listlast(arguments.member_cat_type,'-')#) 
				<cfelseif isdefined("arguments.member_cat_type") and arguments.member_cat_type eq 1>
					AND O.COMPANY_ID IN (SELECT C.COMPANY_ID  FROM #this.dsn_alias#.COMPANY C,#this.dsn_alias#.COMPANY_CAT CAT WHERE C.COMPANYCAT_ID = CAT.COMPANYCAT_ID)
				</cfif>
				<cfif isdefined("arguments.member_cat_type") and listlen(arguments.member_cat_type,'-') eq 2 and listfirst(arguments.member_cat_type,'-') eq '2'>
					AND O.CONSUMER_ID IN (SELECT CONSUMER_ID FROM #this.dsn_alias#.CONSUMER WHERE CONSUMER_CAT_ID = #listlast(arguments.member_cat_type,'-')#)
				<cfelseif isdefined("arguments.member_cat_type") and arguments.member_cat_type eq 2>
					AND O.CONSUMER_ID IN (SELECT C.CONSUMER_ID FROM #this.dsn_alias#.CONSUMER C,#this.dsn_alias#.CONSUMER_CAT CAT WHERE C.CONSUMER_CAT_ID = CAT.CONSCAT_ID)
				</cfif>
				<!--- Üretim Çizelge Detayından geliyorsa seçilen istasyonda üretilebilen ürünler gelsin sadece. --->
				<cfif isdefined('arguments.ajax') and ( (isdefined('arguments.station_id') and  len(arguments.station_id)) or (isdefined('arguments.branch_id') and  len(arguments.branch_id)) or (isdefined('arguments.department_id') and  len(arguments.department_id)))>
					AND S.STOCK_ID IN (<cfif isdefined('station_stock_id_list') and len(station_stock_id_list)>#station_stock_id_list#<cfelse>0</cfif>)
				</cfif>
				<cfif isdefined('arguments.spect_main_id') and len(arguments.spect_main_id) and isdefined('arguments.product_id_') and len(arguments.product_name) and len(arguments.spect_name)>
					AND ORR.SPECT_VAR_ID IN(SELECT SPECT_VAR_ID FROM SPECTS WHERE SPECT_MAIN_ID IN (SELECT SPECT_MAIN_ID FROM SPECTS WHERE SPECT_MAIN_ID = #arguments.spect_main_id#))
				</cfif>
				<cfif isdefined('arguments.category_name') and len(arguments.category)>
					AND S.STOCK_CODE LIKE '#arguments.category#.%'
				</cfif>	
   		</cfquery>
		<cfreturn GET_ORDERS>
	</cffunction>
</cfcomponent>