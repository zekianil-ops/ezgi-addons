<cf_xml_page_edit>
<cfquery name="get_general_info" datasource="#dsn#">
	SELECT ISNULL(IS_SERIAL_CONTROL_LOCATION,0) AS IS_SERIAL_CONTROL_LOCATION FROM OUR_COMPANY_INFO WHERE COMP_ID = #session.ep.company_id#
</cfquery>
<cfquery name="get_shippng_plan" datasource="#dsn3#">
	<cfif attributes.is_type eq 1>
        SELECT     
            ESR.SHIP_RESULT_ID, 
            ESR.DELIVER_EMP, 
            ESR.NOTE, 
            ESR.DELIVER_PAPER_NO, 
            ESR.REFERENCE_NO, 
            ESR.OUT_DATE, 
            SM.SHIP_METHOD,
            SM.SHIP_METHOD SHIP_METHOD_TYPE,
            ESR.DELIVERY_DATE, 
            ESR.DEPARTMENT_ID,
            ESR.LOCATION_ID, 
            ESR.SHIP_STAGE, 
            ESR.COMPANY_ID, 
            ESR.PARTNER_ID, 
            ESR.CONSUMER_ID ,
            ISNULL(ESR.IS_SEVK_EMIR,0) AS IS_SEVK_EMIR
        FROM         
            EZGI_SHIP_RESULT AS ESR INNER JOIN
            #dsn_alias#.SHIP_METHOD AS SM ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID
        WHERE     
            ESR.SHIP_RESULT_ID = #attributes.iid#
  	<cfelse>
    	SELECT     
            ESR.SHIP_RESULT_INTERNALDEMAND_ID, 
            ESR.DELIVER_EMP, 
            ESR.NOTE, 
            ESR.SHIP_RESULT_INTERNALDEMAND_ID AS DELIVER_PAPER_NO, 
            ESR.REFERENCE_NO, 
            ESR.OUT_DATE, 
            SM.SHIP_METHOD,
            SM.SHIP_METHOD SHIP_METHOD_TYPE,
            ESR.DELIVERY_DATE, 
            ESR.DEPARTMENT_ID,
            ESR.LOCATION_ID, 
            ESR.DEPARTMENT_IN_ID,
            ESR.LOCATION_IN_ID,
            ESR.SHIP_STAGE, 
            ISNULL(ESR.IS_SEVK_EMIR,0) AS IS_SEVK_EMIR
        FROM         
            EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
            #dsn_alias#.SHIP_METHOD AS SM ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID
        WHERE     
            ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.iid#
    </cfif>
</cfquery>

<cfif get_shippng_plan.recordcount>
	<cfquery name="get_default_department" datasource="#dsn#">
    	SELECT DEFAULT_MK_TO_RF_DEP, DEFAULT_MK_TO_RF_LOC, DEFAULT_RF_TO_SV_DEP,DEFAULT_RF_TO_SV_LOC FROM EZGI_PDA_DEPARTMENT_DEFAULTS WHERE EPLOYEE_ID = #session.ep.userid#
    </cfquery>
    
    <cfif get_default_department.recordcount>
    	<cfset default_dep = ListGetAt(get_default_department.DEFAULT_MK_TO_RF_DEP,2)>
        <cfset default_loc = ListGetAt(get_default_department.DEFAULT_MK_TO_RF_LOC,2)>
        <cfif isdefined('x_depo') and listlen(x_depo,'-') eq 2>
    		<cfset exit_dep = ListGetAt(x_depo,1,'-')>
        	<cfset exit_loc = ListGetAt(x_depo,2,'-')>
    	<cfelse>
        	<cfset exit_dep = 0>
        	<cfset exit_loc = 0>
    	</cfif>
    <cfelse>
    	<cfif isdefined('x_depo') and listlen(x_depo,'-') eq 2>
    		<cfset exit_dep = ListGetAt(x_depo,1,'-')>
        	<cfset exit_loc = ListGetAt(x_depo,2,'-')>
    	<cfelse>
        	<cfset exit_dep = ''>
        	<cfset exit_loc = ''>
    	</cfif>
    	<cfset default_dep =''>
        <cfset default_loc =''>
    </cfif>


	<cfparam name="attributes.reference_no" default="#get_shippng_plan.REFERENCE_NO#">
    <cfparam name="attributes.ship_method_id" default="#get_shippng_plan.SHIP_METHOD_TYPE#">
    <cfparam name="attributes.ship_method_name" default="#get_shippng_plan.SHIP_METHOD#">

    <cfquery name="get_department" datasource="#dsn#">
		SELECT     
        	DEPARTMENT.DEPARTMENT_HEAD, 
            DEPARTMENT.BRANCH_ID, 
            DEPARTMENT.DEPARTMENT_ID, 
            STOCKS_LOCATION.LOCATION_ID, 
            STOCKS_LOCATION.COMMENT
		FROM         
    		DEPARTMENT INNER JOIN
        	STOCKS_LOCATION ON DEPARTMENT.DEPARTMENT_ID = STOCKS_LOCATION.DEPARTMENT_ID
  	  	WHERE     
        	DEPARTMENT.DEPARTMENT_ID = #get_shippng_plan.DEPARTMENT_ID# AND 
            STOCKS_LOCATION.LOCATION_ID = #get_shippng_plan.LOCATION_ID#    
	</cfquery>
    <cfif attributes.is_type eq 2>
        <cfquery name="get_department_in" datasource="#dsn#">
            SELECT     
                DEPARTMENT.DEPARTMENT_HEAD, 
                DEPARTMENT.BRANCH_ID, 
                DEPARTMENT.DEPARTMENT_ID, 
                STOCKS_LOCATION.LOCATION_ID, 
                STOCKS_LOCATION.COMMENT
            FROM         
                DEPARTMENT INNER JOIN
                STOCKS_LOCATION ON DEPARTMENT.DEPARTMENT_ID = STOCKS_LOCATION.DEPARTMENT_ID
            WHERE     
                DEPARTMENT.DEPARTMENT_ID = #get_shippng_plan.DEPARTMENT_IN_ID# AND 
                STOCKS_LOCATION.LOCATION_ID = #get_shippng_plan.LOCATION_IN_ID#    
        </cfquery>
   	</cfif>
    <cfparam name="attributes.branch_id" default="#get_department.BRANCH_ID#">
    <cfparam name="attributes.department_id" default="#get_department.DEPARTMENT_ID#">
    <cfparam name="attributes.location_id" default="#get_department.LOCATION_ID#">
    <cfparam name="attributes.department_name" default="#get_department.DEPARTMENT_HEAD#-#get_department.COMMENT#">
    <cfquery name="get_order_det" datasource="#DSN3#">
    	SELECT     
            TBL2.TYPE, 
            TBL2.ORDER_ROW_ID, 
            TBL2.DELIVER_DATE, 
            TBL2.ORDER_DATE AS SV_ORDER_DATE, 
            TBL2.COMPANY_ID AS SV_COMPANY_ID, 
            TBL2.ORDER_NUMBER AS SV_ORDER_NUMBER, 
            TBL2.ORDER_ID AS SV_ORDER_ID, 
            TBL2.DURUM, 
            TBL.ORDER_ROW_AMOUNT,
            TBL.IS_TYPE, 
            TBL.SHIP_RESULT_ID, 
            TBL.OUT_DATE, 
            TBL.SHIP_METHOD_TYPE, 
            TBL.DELIVER_PAPER_NO, 
            TBL.LOCATION_ID, 
            TBL.DEPARTMENT_ID, 
            TBL.DEPARTMENT_IN, 
            ORR4.SPECT_VAR_ID,
            ORR4.STOCK_ID, 
            ORR4.PRODUCT_ID,
            ORR4.QUANTITY, 
            ORR4.PRODUCT_NAME2,
            ORR4.ORDER_ROW_CURRENCY,
            ORR4.UNIT BIRIM, 
            ORR4.ORDER_ROW_ID AS SA_ORDER_ROW_ID,
            ORR4.WRK_ROW_ID,
            O4.ORDER_ID AS SA_ORDER_ID, 
            O4.COMPANY_ID AS SA_COMPANY_ID, 
            O4.EMPLOYEE_ID AS SA_EMPLOYEE_ID, 
            O4.CONSUMER_ID AS SA_CONSUMER_ID, 
            O4.ORDER_DETAIL AS SA_ORDER_DETAIL, 
            O4.ORDER_NUMBER AS SA_ORDER_NUMBER, 
            O4.ORDER_DATE AS SA_ORDER_DATE, 
            O4.REF_NO,
            O4.IS_INSTALMENT,
            (
        	SELECT     
          		STOCK_CODE
			FROM         
            	STOCKS
			WHERE     
          		 STOCK_ID=ORR4.STOCK_ID
       		) AS STOCK_CODE,
            (
        	SELECT     
          		STOCK_CODE_2
			FROM         
            	STOCKS
			WHERE     
          		 STOCK_ID=ORR4.STOCK_ID
       		) AS STOCK_CODE_2,
            (
        	SELECT     
          		PRODUCT_NAME
			FROM         
            	STOCKS
			WHERE     
          		 STOCK_ID=ORR4.STOCK_ID
       		) AS PRODUCT_NAME,
            (
        	SELECT     
          		IS_KARMA
			FROM         
            	STOCKS
			WHERE     
          		 STOCK_ID=ORR4.STOCK_ID
       		) AS IS_KARMA,
            (
            SELECT     
            	SPECT_MAIN_ID
			FROM         
            	SPECTS
			WHERE     
            	SPECT_VAR_ID = ORR4.SPECT_VAR_ID
            ) AS SPECT_MAIN_ID,
            (
            	SELECT
                	SUM(REAL_STOCK) AS REAL_STOCK
              	FROM
                	(
                    SELECT   
                        MIN(TOPLAM) AS REAL_STOCK
                    FROM            
                        (
                            SELECT        
                                ISNULL(SUM(TBL.REAL_STOCK), 0) AS TOPLAM, 
                                KP.KARMA_PRODUCT_ID, 
                                KP.PRODUCT_ID
                            FROM            
                                (
                                    SELECT        
                                        STOCK_IN - STOCK_OUT AS REAL_STOCK, 
                                        PRODUCT_ID
                                    FROM            
                                        #dsn2_alias#.STOCKS_ROW
                                        <cfif exit_dep gt 0>
                                            WHERE        
                                                STORE = #exit_dep# AND 
                                                STORE_LOCATION = #exit_loc#
                                        </cfif>
                                    UNION ALL
                                    SELECT        
                                        STOCK_IN - STOCK_OUT AS REAL_STOCK, 
                                        PRODUCT_ID
                                    FROM            
                                        #dsn2_alias#.STOCKS_ROW AS SR
                                    WHERE        
                                        (UPD_ID IS NULL) AND 
                                        (STOCK_IN - STOCK_OUT > 0) 
                                        <cfif exit_dep gt 0>
                                            AND
                                            STORE = #exit_dep# AND 
                                            STORE_LOCATION = #exit_loc#
                                        </cfif>
                                ) AS TBL RIGHT OUTER JOIN
                                #dsn1_alias#.KARMA_PRODUCTS AS KP ON TBL.PRODUCT_ID = KP.PRODUCT_ID
                            GROUP BY 
                                KP.KARMA_PRODUCT_ID, 
                                KP.PRODUCT_ID
                        ) AS TBL2
                    GROUP BY 
                        KARMA_PRODUCT_ID
                    HAVING        
                        KARMA_PRODUCT_ID = ORR4.PRODUCT_ID
                    UNION ALL
                    SELECT        
                        ISNULL(SUM(TBL.REAL_STOCK), 0) AS REAL_STOCK
                    FROM            
                        (
                            SELECT        
                                STOCK_IN - STOCK_OUT AS REAL_STOCK, 
                                PRODUCT_ID
                            FROM            
                                #dsn2_alias#.STOCKS_ROW
                                <cfif exit_dep gt 0>
                                    WHERE        
                                        STORE = #exit_dep# AND 
                                        STORE_LOCATION = #exit_loc#
                                </cfif>
                            UNION ALL
                            SELECT        
                                STOCK_IN - STOCK_OUT AS REAL_STOCK, 
                                PRODUCT_ID
                            FROM            
                                #dsn2_alias#.STOCKS_ROW AS SR
                            WHERE        
                                (UPD_ID IS NULL) AND 
                                (STOCK_IN - STOCK_OUT > 0) 
                                <cfif exit_dep gt 0>
                                    AND
                                    STORE = #exit_dep# AND 
                                    STORE_LOCATION = #exit_loc#
                                </cfif>
                        ) AS TBL LEFT OUTER JOIN
                        #dsn1_alias#.KARMA_PRODUCTS AS KP ON TBL.PRODUCT_ID = KP.PRODUCT_ID
                    GROUP BY 
                        KP.KARMA_PRODUCT_ID, 
                        TBL.PRODUCT_ID
                    HAVING        
                        KP.KARMA_PRODUCT_ID IS NULL AND 
                        TBL.PRODUCT_ID = ORR4.PRODUCT_ID
             	) AS DPL
           	) AS DEPO
        FROM         
            (
            SELECT     
                1 AS TYPE, 
                EORR.ORDER_ROW_ID, 
                ORR1.STOCK_ID, 
                ORR1.DELIVER_DATE, 
                O1.ORDER_DATE, 
                O1.COMPANY_ID, 
                O1.ORDER_NUMBER, 
                O1.ORDER_ID, 
                EORR.O_DURUM1 AS DURUM
            FROM          
                EZGI_ORDER_REL_RESULT AS EORR INNER JOIN
                ORDER_ROW AS ORR1 ON EORR.ORDER_ROW_ID1 = ORR1.ORDER_ROW_ID INNER JOIN
                ORDERS AS O1 ON ORR1.ORDER_ID = O1.ORDER_ID INNER JOIN
                STOCKS AS S ON ORR1.STOCK_ID=S.STOCK_ID
           	WHERE  
                ISNULL(S.IS_SERIAL_NO, 0) = 0
            UNION ALL
            SELECT     
                2 AS TYPE, 
                EORR.ORDER_ROW_ID, 
                ORR2.STOCK_ID, 
                ORR2.DELIVER_DATE, 
                O2.ORDER_DATE, 
                O2.COMPANY_ID, 
                O2.ORDER_NUMBER, 
                O2.ORDER_ID, 
                EORR.O_DURUM2 AS DURUM
            FROM         
                ORDERS AS O2 INNER JOIN
                ORDER_ROW AS ORR2 ON O2.ORDER_ID = ORR2.ORDER_ID INNER JOIN
                EZGI_ORDER_REL_RESULT AS EORR ON ORR2.ORDER_ROW_ID = EORR.ORDER_ROW_ID2 INNER JOIN
                STOCKS AS S ON ORR2.STOCK_ID=S.STOCK_ID
           	WHERE  
                ISNULL(S.IS_SERIAL_NO, 0) = 0
            UNION ALL
            SELECT     
                3 AS TYPE, 
                EORR.ORDER_ROW_ID, 
                PO.STOCK_ID, 
                PO.FINISH_DATE AS DELIVER_DATE, 
                PO.START_DATE AS ORDER_DATE, 
                PO.STATION_ID AS COMPANY_ID, 
                PO.LOT_NO AS ORDER_NUMBER, 
                PO.P_ORDER_ID AS ORDER_ID, 
                EORR.P_DURUM AS DURUM
            FROM         
                PRODUCTION_ORDERS AS PO INNER JOIN
                EZGI_ORDER_REL_RESULT AS EORR ON PO.P_ORDER_ID = EORR.P_ORDER_ID INNER JOIN
             	STOCKS AS S ON PO.STOCK_ID=S.STOCK_ID
           	WHERE  
                ISNULL(S.IS_SERIAL_NO, 0) = 0
          	<cfif get_general_info.IS_SERIAL_CONTROL_LOCATION>
                UNION ALL
                SELECT
                    DISTINCT
                    21 AS TYPE, 
                    ORR.ORDER_ROW_ID, 
                    ORR.STOCK_ID, 
                    '' AS DELIVER_DATE, 
                    '' AS ORDER_DATE, 
                    0 AS COMPANY_ID, 
                    EVLS.SERIAL_NO AS ORDER_NUMBER, 
                    0 AS ORDER_ID, 
                    2 AS DURUM
                FROM     
                    ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                    STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
                    EZGI_WM_SERIAL_NO_ORDER_LAST_STATUS AS EVLS ON ORR.ORDER_ROW_ID = EVLS.RESERVE_ORDER_ROW_ID LEFT OUTER JOIN
                    (
                        SELECT 
                            EVR.ORDER_ROW_ID
                        FROM      
                            PRODUCTION_ORDERS_ROW AS EVR INNER JOIN
                            PRODUCTION_ORDERS AS PO ON EVR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
                        WHERE   
                            NOT (EVR.ORDER_ROW_ID IS NULL)
                    ) AS TTL ON EVLS.RESERVE_ORDER_ROW_ID = TTL.ORDER_ROW_ID
                WHERE  
                    ISNULL(S.IS_SERIAL_NO, 0) = 1 AND
                    EVLS.TYPE = 2
                UNION ALL
                SELECT DISTINCT 
                    11 AS TYPE, 
                    ORR.ORDER_ROW_ID, 
                    ORR.STOCK_ID, 
                    PO.FINISH_DATE AS DELIVER_DATE, 
                    '' AS ORDER_DATE, 
                    0 AS COMPANY_ID, 
                    CASE
                        WHEN LEN(EWM.SERIAL_NO)>0
                        THEN EWM.SERIAL_NO
                        ELSE
                        PO.LOT_NO
                    END AS ORDER_NUMBER, 
                    0 AS ORDER_ID, 
                    2 AS DURUM
                FROM     
                    PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
                    PRODUCTION_ORDERS_ROW AS EWM ON PO.P_ORDER_ID = EWM.PRODUCTION_ORDER_ID INNER JOIN
                    ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                    STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
                    ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID ON EWM.ORDER_ROW_ID = ORR.ORDER_ROW_ID
                WHERE  
                    ISNULL(PO.PRODUCTION_LEVEL, 0) = '0' AND 
                    ISNULL(S.IS_SERIAL_NO, 0) = 1 
                    
                </cfif>
                ) AS TBL2 RIGHT OUTER JOIN
                (
                <cfif is_type eq 1>
                    SELECT     
                        ESR.IS_TYPE, 
                        ESRR.ORDER_ROW_AMOUNT,
                        ESR.SHIP_RESULT_ID, 
                        ESR.OUT_DATE, 
                        ESR.SHIP_METHOD_TYPE, 
                        ESR.DELIVER_PAPER_NO, 
                        ESR.LOCATION_ID, 
                        ESR.DEPARTMENT_ID, 
                        ESR.DEPARTMENT_ID AS DEPARTMENT_IN, 
                        ESRR.ORDER_ROW_ID,
                        ESR.IS_SEVK_EMIR
                    FROM         
                        EZGI_SHIP_RESULT AS ESR INNER JOIN
                        EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID
                    WHERE      
                        ESR.SHIP_RESULT_ID = #attributes.iid#
                <cfelse>
                	SELECT     
                        ESR.IS_TYPE, 
                        ESRR.ORDER_ROW_AMOUNT,
                        ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID, 
                        ESR.OUT_DATE, 
                        ESR.SHIP_METHOD_TYPE, 
                        ESR.SHIP_RESULT_INTERNALDEMAND_ID AS DELIVER_PAPER_NO, 
                        ESR.LOCATION_ID, 
                        ESR.DEPARTMENT_ID, 
                        ESR.DEPARTMENT_IN_ID AS DEPARTMENT_IN, 
                        ESRR.ORDER_ROW_ID,
                        ESR.IS_SEVK_EMIR
                    FROM         
                        EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                        EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID
                    WHERE      
                        ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.iid#
          	</cfif>
            ) AS TBL ON TBL2.ORDER_ROW_ID = TBL.ORDER_ROW_ID INNER JOIN
            ORDER_ROW AS ORR4 ON TBL.ORDER_ROW_ID = ORR4.ORDER_ROW_ID INNER JOIN
            ORDERS AS O4 ON ORR4.ORDER_ID = O4.ORDER_ID
      	WHERE
        	TBL.SHIP_RESULT_ID =  #attributes.iid# 
	</cfquery>
    <cfset order_row_id_list = Valuelist(get_order_det.ORDER_ROW_ID)>
</cfif>
<cfif isdefined('attributes.type') and attributes.type eq 1>
	<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id='733.Detay Göster'></cfsavecontent>
<cfelse>
	<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id='762.Sevkiyat Planı Ekle'></cfsavecontent>
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#ezgi_header#">
    	<cfform name="add_packet_ship" id="add_packet_ship" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_ezgi_shipping&iid=#attributes.iid#">	
    		<cf_basket_form id="upd_default_measure">
            
                <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
            						<div class="col col-6 col-xs-12" type="column" index="1" sort="true">
                                    	<div class="form-group" id="item-stage">
	                            			<label class="col col-4 col-xs-12"></label>
	                            			<div class="col col-8 col-xs-12">
                                             	
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-company">
	                            			<label class="col col-4 col-xs-12">
                                            	<span style=" font-weight:bold">
                                                	<cfif attributes.is_type eq 1>
                                                		<cf_get_lang dictionary_id='57519.Cari Hesap'>
                                                    <cfelse>
                                                    	<cf_get_lang dictionary_id='1116.Sevk Edilecek Şube'>
                                                    </cfif>
                                               	</span>
                                           	</label>
	                            			<div class="col col-8 col-xs-12">
                                            	<cfif attributes.is_type eq 1>
                                              		<cfoutput>#get_par_info(get_shippng_plan.company_id,1,0,0)#</cfoutput>
                                               	<cfelse>
                                                   	<cfoutput>#get_department_in.DEPARTMENT_HEAD#</cfoutput> 	
                                             	</cfif>
                                          	</div>
                                      	</div>
                                      	<div class="form-group" id="item-yetkili">
	                            			<label class="col col-4 col-xs-12"><span style=" font-weight:bold"><cf_get_lang dictionary_id='57578.Yetkili'></span></label>
	                            			<div class="col col-8 col-xs-12">
                                            	<cfif attributes.is_type eq 1>
													<cfif Len(get_shippng_plan.CONSUMER_ID)>
                                                        <cfoutput>#get_cons_info(get_shippng_plan.CONSUMER_ID,0,0)#</cfoutput>
                                                    <cfelse>
                                                        <cfoutput>#get_par_info(get_shippng_plan.partner_id,0,-1,0)#</cfoutput>
                                                    </cfif>
                                                </cfif>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-sevk">
	                            			<label class="col col-4 col-xs-12"><span style=" font-weight:bold"><cf_get_lang dictionary_id='29500.Sevk Yöntemi'></span></label>
	                            			<div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                	<cfif isdefined("attributes.ship_method_name")><cfoutput>#attributes.ship_method_name#</cfoutput><cfelseif isdefined('get_ship_method')><cfoutput>#get_ship_method.ship_method#</cfoutput></cfif>
                                				</div>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-detail">
	                            			<label class="col col-4 col-xs-12"><span style=" font-weight:bold"><cf_get_lang dictionary_id='57629.Açıklama'></span></label>
	                            			<div class="col col-8 col-xs-12">
                                             	<cfoutput>#get_shippng_plan.NOTE#</cfoutput>
                                          	</div>
                                     	</div>
                                 	</div>
                                    <div class="col col-6 col-xs-12" type="column" index="2" sort="true">
                                    	<div class="form-group" id="item-paper">
	                            			<label class="col col-4 col-xs-12"><span style=" font-weight:bold"><cf_get_lang dictionary_id='39884.Sevkiyat No'></span></label>
	                            			<div class="col col-8 col-xs-12">
                                             	<cfoutput>#get_shippng_plan.DELIVER_PAPER_NO#</cfoutput>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-department">
	                            			<label class="col col-4 col-xs-12"><span style=" font-weight:bold"><cf_get_lang dictionary_id='58794.Referans No'></span></label>
	                            			<div class="col col-8 col-xs-12">
                                             	<cfoutput>#attributes.reference_no#</cfoutput>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-code">

	                            			<label class="col col-4 col-xs-12"><span style=" font-weight:bold"><cf_get_lang dictionary_id='29428.Çıkış Depo'></span></label>
	                            			<div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                            		<cfoutput>#attributes.department_name#</cfoutput>
                                				</div>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-outdate">
	                            			<label class="col col-4 col-xs-12"><span style=" font-weight:bold"><cf_get_lang dictionary_id='45463.Depo Çıkış Tarihi'></span></label>
	                            			<div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                             		<cfoutput>#dateformat(get_shippng_plan.OUT_DATE,dateformat_style)# #timeformat(get_shippng_plan.OUT_DATE,'HH:MM')#</cfoutput>
                                                </div>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-deliverdate">
	                            			<label class="col col-4 col-xs-12"><span style=" font-weight:bold"><cf_get_lang dictionary_id='57645.Teslim Tarihi'></span></label>
	                            			<div class="col col-4 col-xs-12">
                                            	<div class="input-group">
                                                	<cfoutput>#dateformat(get_shippng_plan.DELIVERY_DATE,dateformat_style)# #timeformat(get_shippng_plan.DELIVERY_DATE,'HH:MM')#</cfoutput>
                                                </div>
                                          	</div>
                                     	</div>
                                    	<div class="form-group" id="item-deliveremp">
	                            			<label class="col col-4 col-xs-12"><span style=" font-weight:bold"><cf_get_lang dictionary_id='1109.Sevk Planlayan'></span></label>
	                            			<div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                	<cfoutput>#get_emp_info(get_shippng_plan.DELIVER_EMP,0,0)#</cfoutput>
                                				</div>
                                          	</div>
                                     	</div>    
                                        
                                 	</div>
                               	</cf_box_elements>
                                
                          	</div>
                      	</div>
             	</div>
         	</cf_basket_form>
      	</cfform>
            <cf_basket id="upd_default_measure_bask">
            	<cf_grid_list sort="0">
                	<thead>
                        <tr>
                        	<th style="width:80px"><cf_get_lang dictionary_id='58211.Sipariş No'></th>
                            <th style="width:80px"><cf_get_lang dictionary_id='29501.Sipariş Tarihi'></th>
                            <th style="width:100px"><cf_get_lang dictionary_id='57634.Üretici Kodu'></th>
                            <th style="width:390px"><cf_get_lang dictionary_id='57657.Ürün'></th>
                            <th style="width:80px"><cf_get_lang dictionary_id='58763.Depo'></th>
                            <th style="width:80px"><cf_get_lang dictionary_id='30795.Sevk Emirleri'></th>
                            <th style="text-align:center; width:15px">
                                <cfif isdefined('attributes.type') and attributes.type eq 1>
                                    <cf_get_lang dictionary_id='538.DRM'>
                                <cfelse>
                                    <input type="checkbox" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="grupla(-1);">
                                </cfif>
                            </th>
                            <th style="width:90px"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></th>
                            <th style="width:90px"><cf_get_lang dictionary_id='35990.Bağlantı'></th>
                        </tr>
                    </thead>
                    <tbody id="table2">
                        <cfset irs_top=0>
                        <cfif get_order_det.recordcount>
                        	<cfquery name="get_order_det_group" dbtype="query">
                            	SELECT
                                	SA_ORDER_ROW_ID,
                                	QUANTITY,
                                	STOCK_ID,
                                    PRODUCT_ID,
                                    SA_ORDER_ID,
                                    SA_ORDER_NUMBER,
                                    SA_ORDER_DATE,
                                    STOCK_CODE,
                                    PRODUCT_NAME,
                                    IS_KARMA,
                                    DEPO,
                                    ORDER_ROW_AMOUNT,
                                    WRK_ROW_ID,
                                    ORDER_ROW_CURRENCY,
                                    STOCK_CODE_2
                                FROM
                                  	get_order_det  
                              	GROUP BY
                                	SA_ORDER_ROW_ID,
                                	QUANTITY,
                                	STOCK_ID,
                                    PRODUCT_ID,
                                    SA_ORDER_ID,
                                    SA_ORDER_NUMBER,
                                    SA_ORDER_DATE,
                                    STOCK_CODE,
                                    PRODUCT_NAME,
                                    IS_KARMA,
                                    DEPO,
                                    ORDER_ROW_AMOUNT,
                                    WRK_ROW_ID,
                                    ORDER_ROW_CURRENCY,
                                    STOCK_CODE_2
                            </cfquery>
                            <cfoutput query="get_order_det_GROUP">
                            	<cfquery name="get_order_det_DETAIL" dbtype="query">
                                    SELECT
                                        TYPE,
                                        SV_ORDER_NUMBER,
                                        DURUM,
                                        SA_ORDER_DATE,
                                        DELIVER_DATE
                                    FROM
                                        get_order_det  
                                    WHERE
                                        WRK_ROW_ID='#get_order_det_GROUP.WRK_ROW_ID#'	
                                </cfquery>
                                <cfset detail_rows = get_order_det_DETAIL.recordcount>
                                <cfset stock_id=get_order_det_GROUP.STOCK_ID>
                                <tr>
                                    <td rowspan="#detail_rows#" style="height:30px">
                                        <cfif attributes.is_type eq 1>
                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.list_order&event=upd&order_id=#get_order_det_GROUP.sa_order_id#','longpage');" class="tableyazi" title="<cf_get_lang_main no='3532.Satış Siparişine Git'>">
                                                #get_order_det_GROUP.SA_ORDER_NUMBER#
                                            </a>
                                        <cfelse>
                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.upd_fast_sale&order_id=#get_order_det_GROUP.sa_order_id#','wide');" class="tableyazi" title="<cf_get_lang_main no='3532.Satış Siparişine Git'>">
                                                #get_order_det_GROUP.SA_ORDER_NUMBER#
                                            </a>
                                        </cfif>
                                    </td>
                                    <td rowspan="#detail_rows#">#DateFormat(SA_ORDER_DATE,dateformat_style)#</td>
                                    <td rowspan="#detail_rows#">#get_order_det_GROUP.STOCK_CODE_2#</td>
                                    <td rowspan="#detail_rows#">#get_order_det_GROUP.PRODUCT_NAME#</td>

                                    <td rowspan="#detail_rows#" style="text-align:right;">
                                        <cfif IS_KARMA eq 1>
                                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_dsp_karma_koli&pid=#product_id#','small');">#AmountFormat(get_order_det_GROUP.DEPO)#</a>
                                        <cfelse>
                                            #AmountFormat(get_order_det_GROUP.DEPO)#
                                        </cfif>
                                        
                                    </td>
                                    <td rowspan="#detail_rows#" style="text-align:right;">#AmountFormat(get_order_det_GROUP.QUANTITY)#</td>
                                    <td rowspan="#detail_rows#" style="text-align:center;">
                                     	<cfif order_row_currency eq -8 or order_row_currency eq -9 or order_row_currency eq -10 or order_row_currency eq -3>
                                         	<img src="/images/b_ok.gif" border="0" title="<cf_get_lang dictionary_id='766.İşlem Yapılamaz'>" />
                                      	<cfelseif order_row_currency eq -6>
                                          	<img src="/images/c_ok.gif" border="0" title="<cf_get_lang dictionary_id='775.Sevk Emri Verildi.'>" />
                                     	<cfelse>
                                        	<cfif x_is_reserve eq 0>
                                            	<input type="checkbox" name="select_production" value="#WRK_ROW_ID#">
                                            <cfelse>
                                            	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_list_ezgi_shipping_ship_demand&order_row_id=#get_order_det_group.SA_ORDER_ROW_ID#','list');" class="tableyazi" title="Rezervasyon Talebi">
                                            		<img src="images/branch_change.gif">
                                                </a>
                                            </cfif>
                                      	</cfif>
                                    </td>
                                    <cfset t = 1>
                                    <cfloop query="get_order_det_DETAIL">
                                      	<cfif t eq 0>
                                        	<tr>
                                     	</cfif>
                                        <td style="text-align:center; font-weight:bold">
                                        	#DateFormat(get_order_det_DETAIL.DELIVER_DATE,dateformat_style)#
                                        </td>
                                       	<td style="text-align:center; font-weight:bold">
                                        	<cfif get_order_det_DETAIL.TYPE eq 3>
                                                <font color="<cfif get_order_det_DETAIL.durum eq 1>green<cfelseif get_order_det_DETAIL.durum eq 2>red<cfelseif get_order_det_DETAIL.durum eq 0>orange<cfelse>blue</cfif>">
                                                    #get_order_det_DETAIL.SV_ORDER_NUMBER#
                                                </font>
                                            <cfelse>
                                                #get_order_det_DETAIL.SV_ORDER_NUMBER#
                                            </cfif>
                                        </td>
                                      	
                                 		</tr>
                                   		<cfif t eq 1>
                                         	<cfset t = 0>
                                       	</cfif>
                                 	</cfloop>
                            </cfoutput>
                        </cfif>
                    </tbody>
                    <tfoot>
                        <tr>
                            <cfif isdefined('attributes.type') and attributes.type eq 1>
                                <td colspan="9" style="height:30px; text-align:left"></td>
                            <cfelse>
                                <td colspan="6" style="height:30px; text-align:left">
                                    <select name="select_name" id="select_name" onchange="degisim();">
                                        <option value="1" <cfif get_shippng_plan.IS_SEVK_EMIR eq 1>selected</cfif>><cf_get_lang dictionary_id='775.Sevkiyata Emir Verildi'></option>
                                        <option value="0" <cfif get_shippng_plan.IS_SEVK_EMIR eq 0>selected</cfif>><cf_get_lang dictionary_id='776.Sevkiyata Emir Verilmedi'></option>
                                    </select>
                                </td>
                                <td colspan="3" style="height:30px; text-align:right">
                                	<cfif x_is_reserve eq 0> <!---Otomatik Rezerveasyon Yoksa--->
                                    	<button  value="" name="gonder" onClick="grupla();" style="width:100px; height:25px;">&nbsp;<cf_get_lang dictionary_id='45593.Sevk Et'></button>
                                	</cfif>
                                </td>
                            </cfif>
                        </tr>
                    </tfoot>
            	</cf_grid_list>  
        	</cf_basket>
   	</cf_box>
</div>
<script language="javascript">
	function grupla(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
			order_row_id_list = '';
			chck_leng = document.getElementsByName('select_production').length;
			for(ci=0;ci<chck_leng;ci++)
			{
				var my_objets = document.all.select_production[ci];
				if(chck_leng == 1)
					var my_objets =document.all.select_production;
				if(type == -1)
				{//hepsini seç denilmişse	
					if(my_objets.checked == true)
						my_objets.checked = false;
					else
						my_objets.checked = true;
				}
				else
				{
					if(my_objets.checked == true)

						order_row_id_list +=my_objets.value+',';
				}
			}
			order_row_id_list = order_row_id_list.substr(0,order_row_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(order_row_id_list!='')
			{
				window.location='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_upd_ezgi_order_row&order_row_id_list='+order_row_id_list;
			}
	}
	function degisim()
	{
		sevk_emir = document.getElementById('select_name').value;
		window.location='<cfoutput>#request.self#?fuseaction=sales.emptypopup_upd_ezgi_sevk_emir&upd_id=#attributes.iid#&is_type=#attributes.is_type#</cfoutput>&sevk_emir='+sevk_emir;
	}
</script>