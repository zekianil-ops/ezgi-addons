<!---
    File: add_ezgi_metarial_talep.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---Bu sayfa İçin Bakım Yapılmaktadır.  Zeki Anıl GÜLŞEN
<cfdump expand="yes" var="#attributes#">
<cfabort>--->
<cfquery name="get_process_type" datasource="#dsn#">
	SELECT        
    	TOP (1) PR.PROCESS_ROW_ID
	FROM          
    	PROCESS_TYPE AS P INNER JOIN
     	PROCESS_TYPE_ROWS AS PR ON P.PROCESS_ID = PR.PROCESS_ID INNER JOIN
      	PROCESS_TYPE_OUR_COMPANY AS PC ON PR.PROCESS_ID = PC.PROCESS_ID
	WHERE        
    	P.FACTION LIKE N'%purchase.add_internaldemand,%' AND 
        PC.OUR_COMPANY_ID = #session.ep.company_id#
</cfquery>
<cfif not get_process_type.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='1079.İç Talep Kaydetmek İçin Süreçte Yetkili Olmalısınız!'>");
        window.history.go(-1);
	</script>
	<cfabort>
</cfif>
<cfquery name="get_default" datasource="#dsn3#">
	SELECT       
    	EMAD.DEFAULT_RAW_STORE_ID, 
        EMAD.DEFAULT_RAW_LOC_ID, 
        EMAD.DEFAULT_PRODUCTION_STORE_ID, 
        EMAD.DEFAULT_PRODUCTION_LOC_ID, 
        EMAD.POINT_METHOD, 
        EMAD.CONTROL_METHOD,
        EMAD.FABRIC_CAT
	FROM            
    	EZGI_MASTER_PLAN_DEFAULTS AS EMAD INNER JOIN
     	EZGI_MASTER_PLAN AS EMAP ON EMAD.SHIFT_ID = EMAP.MASTER_PLAN_CAT_ID
	WHERE        
    	EMAP.MASTER_PLAN_ID = #attributes.master_plan_id#
</cfquery>
<cfparam name="attributes.total_control" default="0">
<cfset out_department = get_default.DEFAULT_PRODUCTION_STORE_ID>
<cfset out_location = get_default.DEFAULT_PRODUCTION_LOC_ID>
<cfset in_department = get_default.DEFAULT_RAW_STORE_ID>
<cfset in_location = get_default.DEFAULT_RAW_LOC_ID>
<cfif isdefined('attributes.order_id')>
	<cfquery name="get_order_no" datasource="#dsn3#">
        SELECT     
            ORDER_NUMBER
        FROM         
            ORDERS
        WHERE     
            ORDER_ID = #attributes.order_id#
    </cfquery>
</cfif>
<cfset stock_id_list = ''>
<cfloop list="#attributes.p_order_id_list#" index="i">
	<cfset stock_id_list = ListAppend(stock_id_list,Listgetat(i,1,'_'))>
    <cfset 'AMOUNT_#Listgetat(i,1,'_')#' = Listgetat(i,2,'_')>
</cfloop>
<cfquery name="GET_LOT_K_KONT_ID" datasource="#dsn3#">
	SELECT     
    	PU.PRODUCT_UNIT_ID, 
        PU.MAIN_UNIT, 
        PS.PRICE, 
        PS.MONEY,
        S.PRODUCT_NAME, 
        S.TAX, 
        S.STOCK_ID, 
        S.PRODUCT_ID
	FROM         
    	STOCKS AS S INNER JOIN
        PRICE_STANDART AS PS ON S.PRODUCT_ID = PS.PRODUCT_ID INNER JOIN
        PRODUCT_UNIT AS PU ON S.PRODUCT_ID = PU.PRODUCT_ID
	WHERE     
    	PU.IS_MAIN = 1 AND 
        PS.PRICESTANDART_STATUS = 1 AND 
        PS.PURCHASESALES = 0 AND
        S.STOCK_ID IN (#stock_id_list#)
	ORDER BY 	
    	S.PRODUCT_NAME
</cfquery>
<cflock name="#CREATEUUID()#" timeout="20">
  	<cftransaction>
    <cfquery name="get_gen_paper" datasource="#dsn3#">
      	SELECT INTERNAL_NO, INTERNAL_NUMBER FROM GENERAL_PAPERS WHERE PAPER_TYPE IS NULL
   	</cfquery>
    <cfset paper_code = evaluate('get_gen_paper.INTERNAL_NO')>
    <cfset paper_number = evaluate('get_gen_paper.INTERNAL_NUMBER') +1>
    <cfset paper_full = '#paper_code#-#paper_number#'>
    <cfquery name="SET_MAX_PAPER" datasource="#DSN3#">
    	UPDATE GENERAL_PAPERS SET INTERNAL_NUMBER = INTERNAL_NUMBER+1 WHERE PAPER_TYPE IS NULL
   	</cfquery>
    <cfsavecontent variable="talep"><cf_get_lang dictionary_id='58798.İç Talep'></cfsavecontent>
	<cfquery name="ADD_INTERNALDEMAND" datasource="#dsn3#">
		INSERT INTO 
			INTERNALDEMAND
			(
				SERVICE_ID,
				INTERNAL_NUMBER,
				TO_POSITION_CODE,
				FROM_POSITION_CODE,
				TARGET_DATE,
				TOTAL,
				DISCOUNT,
				TOTAL_TAX,
				OTV_TOTAL,
				NET_TOTAL,
				SUBJECT,
				PRIORITY,
				INTERNALDEMAND_STATUS,
				IS_ACTIVE,
				NOTES,
				PROJECT_ID,
				INTERNALDEMAND_STAGE,
				DEPARTMENT_IN,
				LOCATION_IN,
				DEPARTMENT_OUT,
				LOCATION_OUT,
				REF_NO,
				SHIP_METHOD,
				WORK_ID,
			<cfif isdefined('form.basket_money')>
				OTHER_MONEY,
				OTHER_MONEY_VALUE,
			</cfif>
				RECORD_EMP,
				RECORD_DATE,
              	DEMAND_TYPE
		)
			VALUES
		(
				NULL,
				'#paper_full#',
				NULL,
				#SESSION.EP.USERID#,
				#now()#,
				<cfif isdefined("attributes.basket_gross_total") and len(attributes.basket_gross_total)>#attributes.basket_gross_total#<cfelse>0</cfif>,
				<cfif isdefined("attributes.BASKET_DISCOUNT_TOTAL") and len(attributes.BASKET_DISCOUNT_TOTAL)>#attributes.BASKET_DISCOUNT_TOTAL#<cfelse>0</cfif>,
				<cfif isdefined("attributes.basket_tax_total") and len(attributes.basket_tax_total)>#attributes.basket_tax_total#<cfelse>0</cfif>,
				<cfif isdefined("attributes.basket_otv_total") and len(attributes.basket_otv_total)>#attributes.basket_otv_total#<cfelse>0</cfif>,
				<cfif isdefined("attributes.basket_net_total") and len(attributes.basket_net_total)>#attributes.basket_net_total#<cfelse>0</cfif>,
				'#talep#',
				3,
				0,
				1,
				<cfif isdefined("attributes.notes")>'#attributes.notes#'<cfelse>''</cfif>,
				<cfif isdefined('attributes.project_id') and len(attributes.project_id)>#attributes.project_id#<cfelse>NULL</cfif>,
				#get_process_type.PROCESS_ROW_ID#,
				<cfif isdefined('in_department') and len(in_department)>#in_department#<cfelse>NULL</cfif>,
				<cfif isdefined('in_location') and len(in_location)>#in_location#<cfelse>NULL</cfif>,
				<cfif isdefined('out_department') and len(out_department)>#out_department#<cfelse>NULL</cfif>,
				<cfif isdefined('out_location') and len(out_location)>#out_location#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.ref_no") and len(attributes.ref_no)>'#attributes.ref_no#'<cfelse>NULL</cfif>,
				<cfif isDefined('attributes.SHIP_METHOD') and len(attributes.SHIP_METHOD)>
					#SHIP_METHOD#
				<cfelse>
					NULL
				</cfif>,
				<cfif isdefined('attributes.work_id') and len(attributes.work_id)>#attributes.work_id#<cfelse>NULL</cfif>,
				<cfif isdefined('form.basket_money')>
					'#form.basket_money#',
					#((form.basket_net_total*form.basket_rate1)/form.basket_rate2)#,
				</cfif>
				#SESSION.EP.USERID#,
				#now()#,
                0
		)
	</cfquery>
	<cfquery name="GET_MAX_INTERNALDEMAND_ID" datasource="#dsn3#">
		SELECT MAX(INTERNAL_ID) AS MAX_ID FROM INTERNALDEMAND
	</cfquery>
    <cfif isdefined('attributes.order_id')>
    	<cfquery name="ADD_RELATION" datasource="#dsn3#">
            INSERT INTO 
                EZGI_METARIAL_RELATIONS
                (
                ORDER_ID, 
                ACTION_ID, 
                TYPE
                )
            VALUES     
                (
                #attributes.order_id#,
                #GET_MAX_INTERNALDEMAND_ID.MAX_ID#,
                1
                )
        </cfquery>
    <cfelse>
        <cfquery name="ADD_RELATION" datasource="#dsn3#">
            INSERT INTO 
                EZGI_METARIAL_RELATIONS
                (
                LOT_NO, 
                ACTION_ID, 
                TYPE
                )
            VALUES     
                (
                '#lot_no#',
                #GET_MAX_INTERNALDEMAND_ID.MAX_ID#,
                1
                )
        </cfquery>
    </cfif>
    <cfif GET_LOT_K_KONT_ID.recordcount>
		<cfoutput query="GET_LOT_K_KONT_ID">
		<cfquery name="get_money" datasource="#dsn3#">
                SELECT     	RATE2 / RATE1 AS RATE_INFO
                FROM      	#dsn2_alias#.SETUP_MONEY AS SETUP_MONEY_1
                WHERE     	(MONEY = '#MONEY#')
            </cfquery>
			<cfquery name="ADD_INTERNALDEMAND_ROW" datasource="#DSN3#">
				INSERT INTO 
					INTERNALDEMAND_ROW 
					(
						I_ID, 
						PRODUCT_ID,
						STOCK_ID,
						QUANTITY,
						UNIT,
						UNIT_ID,
						PRICE,
						PRICE_OTHER,
						OTHER_MONEY,
						OTHER_MONEY_VALUE,
						TAX,
						DUEDATE,
						PRODUCT_NAME,
						PAY_METHOD_ID,
						DELIVER_DATE,
						DELIVER_DEPT,
						DISCOUNT_1,
						DISCOUNT_2,
						DISCOUNT_3,
						DISCOUNT_4,
						DISCOUNT_5,					
						DISCOUNT_6,
						DISCOUNT_7,
						DISCOUNT_8,
						DISCOUNT_9,
						DISCOUNT_10,					
						TAXTOTAL,
						NETTOTAL,				
						OTV_ORAN,
						OTVTOTAL,
						COST_PRICE,
						EXTRA_COST,
						MARJ,
						PROM_COMISSION,
						PROM_COST,
						DISCOUNT_COST,
						PROM_ID,
						IS_PROMOTION,
						PROM_STOCK_ID,
						IS_COMMISSION,
						UNIQUE_RELATION_ID,
						PROM_RELATION_ID,
						AMOUNT2,
						UNIT2,
						EXTRA_PRICE,
						EK_TUTAR_PRICE,
						EXTRA_PRICE_TOTAL,
						EXTRA_PRICE_OTHER_TOTAL,
						SHELF_NUMBER,
						BASKET_EXTRA_INFO_ID,
						PRICE_CAT,
						CATALOG_ID,
						LIST_PRICE,
						NUMBER_OF_INSTALLMENT,
						BASKET_EMPLOYEE_ID,
						KARMA_PRODUCT_ID,
						RESERVE_DATE,
						PRODUCT_NAME2,
						PRODUCT_MANUFACT_CODE,
						WRK_ROW_ID,
						WRK_ROW_RELATION_ID,
						PRO_MATERIAL_ID,
						WIDTH_VALUE,
						DEPTH_VALUE,
						HEIGHT_VALUE,
						ROW_PROJECT_ID
					)
				VALUES 
					(
						#GET_MAX_INTERNALDEMAND_ID.MAX_ID#,
						#PRODUCT_ID#,
						#STOCK_ID#,
						#Evaluate('AMOUNT_#STOCK_ID#')#,
						'#MAIN_UNIT#',
						#PRODUCT_UNIT_ID#,
						#PRICE#*#get_money.RATE_INFO#,
                        #PRICE#,
						'#MONEY#',
                        #PRICE#*#Evaluate('AMOUNT_#STOCK_ID#')#,
                        #TAX#,
						0,
						'#left(PRODUCT_NAME,250)#',
						NULL,
						NULL,						
						NULL,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
						NULL,
                        #PRICE#*#get_money.RATE_INFO#*#Evaluate('AMOUNT_#STOCK_ID#')#,
                        0,
                        0,
						0,
                        0,
                        0,
						NULL,
						0,
						NULL,
                        NULL,
						0,
						NULL,
						0,
						NULL,
                        NULL,
                        NULL,
                        NULL,
						NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
						NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        <cfif isdefined('attributes.order_id')>
                        	'#get_order_no.order_number#',
                        <cfelse>
                        	'#attributes.lot_no#',
                       	</cfif>     
                        NULL,
						NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL
					)
			</cfquery>
		</cfoutput>	
	</cfif>
	<cf_workcube_process 
		is_upd='1' 
		data_source='#dsn3#' 
		old_process_line='0'
		process_stage='12' 
		record_member='#session.ep.userid#' 
		record_date='#now()#' 
		action_page='#request.self#?fuseaction=purchase.list_internaldemand&event=upd&idid=#GET_MAX_INTERNALDEMAND_ID.MAX_ID#' 
		action_id='#GET_MAX_INTERNALDEMAND_ID.MAX_ID#'
		warning_description='İç Talep: #paper_full#'>
	</cftransaction>
</cflock>
<cflocation url="#request.self#?fuseaction=purchase.list_internaldemand&event=upd&id=#GET_MAX_INTERNALDEMAND_ID.max_id#" addtoken="No">

