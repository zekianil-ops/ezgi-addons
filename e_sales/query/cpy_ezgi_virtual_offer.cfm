<cfif isdefined('attributes.cpy_virtual_offer_id')>
	<cflock name="#CREATEUUID()#" timeout="60">
        <cftransaction>
            <cfquery name="get_gen_paper" datasource="#dsn3#">
                SELECT 
                    * 
                FROM 
                    GENERAL_PAPERS 
                WHERE 
                    ZONE_TYPE = 0 AND PAPER_TYPE = 0
            </cfquery>
            <cfset paper_code = evaluate('get_gen_paper.OFFER_NO')>
            <cfset paper_number = evaluate('get_gen_paper.OFFER_NUMBER') +1>
            <cfset paper_full = '#paper_code#-#paper_number#'>
            <cfquery name="SET_MAX_PAPER" datasource="#dsn3#">
                UPDATE
                    GENERAL_PAPERS
                SET
                    OFFER_NUMBER = OFFER_NUMBER+1
                WHERE
                    PAPER_TYPE = 0 AND
                    ZONE_TYPE = 0
            </cfquery>
            <cfoutput>#paper_full#</cfoutput>
        </cftransaction>
    </cflock>
<cfelseif isdefined('attributes.rvs_virtual_offer_id')>  
	<cfquery name="get_revision_info" datasource="#dsn3#">
    	SELECT 
        	VIRTUAL_OFFER_ID,
        	ISNULL(REVISION_NO,0) REVISION_NO, 
            ISNULL(REVISION_ID,0) REVISION_ID 
       	FROM 
        	EZGI_VIRTUAL_OFFER 
       	WHERE 
        	VIRTUAL_OFFER_ID = #attributes.rvs_virtual_offer_id#
    </cfquery>
    <cfif get_revision_info.REVISION_ID gt 0>
     	<cfset revision_no_ = get_revision_info.REVISION_NO + 1>
        <cfset revision_id_ = get_revision_info.REVISION_ID>
   	<cfelse>
    	<cfset revision_no_ = 1>
        <cfset revision_id_ = get_revision_info.VIRTUAL_OFFER_ID>
    </cfif>        
</cfif>
<cflock name="#CREATEUUID()#" timeout="90">
 	<cftransaction>
    	<cfif isdefined('attributes.rvs_virtual_offer_id')> 
        	<cfquery name="upd_virtual_offer" datasource="#dsn3#">
            	UPDATE
                	EZGI_VIRTUAL_OFFER
               	SET
                	VIRTUAL_OFFER_STATUS = 0
               	WHERE
                	VIRTUAL_OFFER_ID = #attributes.rvs_virtual_offer_id#
            </cfquery>
        </cfif>
    	<cfquery name="cpy_virtual_offer" datasource="#dsn3#">
        	INSERT INTO 
            	EZGI_VIRTUAL_OFFER
               	(
                	VIRTUAL_OFFER_DETAIL, 
                    VIRTUAL_OFFER_NUMBER,
                    <cfif isdefined('attributes.rvs_virtual_offer_id')>   
                        REVISION_NO,
                        REVISION_ID,
                    </cfif>
                    VIRTUAL_OFFER_DATE, 
                    VIRTUAL_OFFER_STAGE, 
                    VIRTUAL_OFFER_STATUS, 
                    VIRTUAL_OFFER_HEAD, 
                    PURCHASE_SALES, 
                    COMPANY_ID, 
                    PARTNER_ID, 
                	CONSUMER_ID, 
                    PRIORITY_ID, 
                    MEMBER_TYPE, 
                    PROJECT_ID, 
                    DELIVERDATE, 
                    FINISHDATE, 
                    DUE_DATE, 
                    DUE_VALUE, 
                    REF_NO, 
                    GROSSTOTAL, 
                    NETTOTAL, 
                    DISCOUNTTOTAL, 
                    SUB_DISCOUNTTOTAL, 
                    BRANCH_ID, 
                  	PARTNER_COMPANY_ID, 
                    SALES_COMPANY_ID,
                    RECORD_DATE, 
                    RECORD_EMP, 
                    RECORD_IP
              	)
			SELECT        
            	VIRTUAL_OFFER_DETAIL, 
                <cfif isdefined('attributes.cpy_virtual_offer_id')>   
            		'#paper_full#',
               	<cfelseif isdefined('attributes.rvs_virtual_offer_id')> 
               		VIRTUAL_OFFER_NUMBER,
               	</cfif>
                <cfif isdefined('attributes.rvs_virtual_offer_id')>   
               		#REVISION_NO_#,
                    #REVISION_ID_#,
               	</cfif> 
                VIRTUAL_OFFER_DATE, 
                VIRTUAL_OFFER_STAGE, 
                1, 
                VIRTUAL_OFFER_HEAD, 
                PURCHASE_SALES, 
                COMPANY_ID, 
                PARTNER_ID, 
               	CONSUMER_ID, 
                PRIORITY_ID, 
                MEMBER_TYPE, 
                PROJECT_ID, 
                DELIVERDATE, 
                FINISHDATE, 
                DUE_DATE, 
                DUE_VALUE, 
                REF_NO, 
                GROSSTOTAL, 
                NETTOTAL, 
                DISCOUNTTOTAL, 
                SUB_DISCOUNTTOTAL, 
                BRANCH_ID, 
             	PARTNER_COMPANY_ID, 
                SALES_COMPANY_ID,
                #now()#,
           		#session.ep.userid#,
             	'#cgi.remote_addr#'
			FROM            
           		EZGI_VIRTUAL_OFFER AS EVR
			WHERE     
            	<cfif isdefined('attributes.cpy_virtual_offer_id')>   
            		VIRTUAL_OFFER_ID = #attributes.cpy_virtual_offer_id#
               	<cfelseif isdefined('attributes.rvs_virtual_offer_id')> 
               		VIRTUAL_OFFER_ID = #attributes.rvs_virtual_offer_id#
               	</cfif>
        </cfquery>
        <cfquery name="get_max_id" datasource="#dsn3#">
        	SELECT MAX(VIRTUAL_OFFER_ID) AS MAX_ID FROM EZGI_VIRTUAL_OFFER
      	</cfquery>
        <cfquery name="cpy_money" datasource="#dsn3#">
          	INSERT INTO 
           		EZGI_VIRTUAL_OFFER_MONEY
          		(
             		MONEY_TYPE, 
                	ACTION_ID, 
                  	RATE2, 
                 	RATE1, 
                  	IS_SELECTED
            	)
          	SELECT        
            	MONEY_TYPE, 
                #get_max_id.MAX_ID#,
                RATE2, 
                RATE1, 
                IS_SELECTED
			FROM     
            	EZGI_VIRTUAL_OFFER_MONEY
			WHERE  
            	<cfif isdefined('attributes.cpy_virtual_offer_id')>   
            		ACTION_ID = #attributes.cpy_virtual_offer_id#
               	<cfelseif isdefined('attributes.rvs_virtual_offer_id')> 
               		ACTION_ID = #attributes.rvs_virtual_offer_id#
               	</cfif>      
      	</cfquery>
        <cfif isdefined('attributes.rvs_virtual_offer_id')>
            <cfquery name="EZGI_VIRTUAL_OFFER_PAYMENT" datasource="#dsn3#">
                INSERT INTO 
                    EZGI_VIRTUAL_OFFER_PAYMENT
                    (
                        VIRTUAL_OFFER_ID, 
                        PAYMENT_TYPE_ID, 
                        DUEDATE, 
                        AMOUNT, 
                        MONEY, 
                        TOTAL, 
                        TOTAL_MONEY, 
                        DETAIL
                    )
                SELECT     
                    #get_max_id.MAX_ID#,
                    PAYMENT_TYPE_ID, 
                    DUEDATE, AMOUNT, 
                    MONEY, 
                    TOTAL, 
                    TOTAL_MONEY, 
                    DETAIL
                FROM        
                    EZGI_VIRTUAL_OFFER_PAYMENT
                WHERE     
                    VIRTUAL_OFFER_ID = #attributes.rvs_virtual_offer_id#
            </cfquery>
        </cfif>
        <cfquery name="get_row_id" datasource="#dsn3#">
        	SELECT
            	EZGI_ID
        	FROM            
            	EZGI_VIRTUAL_OFFER_ROW
			WHERE        
            	<cfif isdefined('attributes.cpy_virtual_offer_id')>   
            		VIRTUAL_OFFER_ID = #attributes.cpy_virtual_offer_id#
               	<cfelseif isdefined('attributes.rvs_virtual_offer_id')> 
               		VIRTUAL_OFFER_ID = #attributes.rvs_virtual_offer_id#
               	</cfif>
          	ORDER BY 
              	VIRTUAL_OFFER_ROW_ID
        </cfquery>
        <cfset old_ezgi_id_list = ValueList(get_row_id.EZGI_ID)>
        <cfif ListLen(old_ezgi_id_list)>
            <cfloop list="#old_ezgi_id_list#" index="i">
                <cfquery name="cpy_virtual_offer_row" datasource="#dsn3#">
                    INSERT INTO 
                        EZGI_VIRTUAL_OFFER_ROW
                        (
                            VIRTUAL_OFFER_ID, 
                            IS_STANDART, 
                            PRODUCT_ID, 
                            STOCK_ID, 
                            PRODUCT_NAME, 
                            STOCK_CODE, 
                            QUANTITY, 
                            UNIT, 
                            VIRTUAL_OFFER_ROW_CURRENCY, 
                            PRODUCT_NAME2, 
                            PRICE, 
                            OTHER_MONEY, 
                            DISCOUNT_1, 
                            DISCOUNT_2, 
                            DISCOUNT_3, 
                            DISCOUNT_COST, 
                            COST, 
                            BOY, 
                            EN, 
                            DERINLIK, 
                            YON,
                            PRODUCT_CODE_2, 
                            TAX,
                            WRK_ROW_ID, 
                            WRK_ROW_RELATION_ID,
                            PURCHASE_PRICE, 
                          	PURCHASE_PRICE_MONEY, 
                          	COST_PRICE, 
                           	COST_PRICE_MONEY,
                            P_PURCHASE_PRICE, 
                          	P_PURCHASE_PRICE_MONEY, 
                         	P_DISCOUNT_1, 
                         	P_DISCOUNT_2, 
                         	P_DISCOUNT_3, 
                          	P_DISCOUNT_4, 
                         	P_DISCOUNT_5,
                            SORT_NO,
                            PRICE_CAT_ID
                        )

                    SELECT        
                        #get_max_id.MAX_ID#, 
                        IS_STANDART, 
                        PRODUCT_ID, 
                        STOCK_ID, 
                        PRODUCT_NAME, 
                        STOCK_CODE, 
                        QUANTITY, 
                        UNIT, 
                        <cfif isdefined('attributes.cpy_virtual_offer_id')>   
                            1,
                        <cfelseif isdefined('attributes.rvs_virtual_offer_id')> 
                            VIRTUAL_OFFER_ROW_CURRENCY,
                        </cfif>
                        PRODUCT_NAME2, 
                        PRICE, 
                        OTHER_MONEY, 
                        DISCOUNT_1, 
                        DISCOUNT_2, 
                     	DISCOUNT_3, 
                     	DISCOUNT_COST, 
                      	COST, 
                        BOY, 
                        EN, 
                        DERINLIK, 
                        YON,
                        PRODUCT_CODE_2, 
                        TAX,
                        <cfif isdefined('attributes.cpy_virtual_offer_id')>
                        	NULL,
                            NULL,
                        <cfelseif isdefined('attributes.rvs_virtual_offer_id')>
                            WRK_ROW_ID, 
                            WRK_ROW_RELATION_ID,
                        </cfif>
                        PURCHASE_PRICE, 
                     	PURCHASE_PRICE_MONEY, 
                       	COST_PRICE, 
                       	COST_PRICE_MONEY,
                    	P_PURCHASE_PRICE, 
                     	P_PURCHASE_PRICE_MONEY, 
                      	P_DISCOUNT_1, 
                     	P_DISCOUNT_2, 
                    	P_DISCOUNT_3, 
                     	P_DISCOUNT_4, 
                     	P_DISCOUNT_5,
                        SORT_NO,
                        PRICE_CAT_ID
                    FROM            
                        EZGI_VIRTUAL_OFFER_ROW E
                    WHERE        
                       EZGI_ID = #i# 
                </cfquery>
                <cfquery name="upd_ezgi_id" datasource="#dsn3#">
                    UPDATE EZGI_VIRTUAL_OFFER_ROW SET EZGI_ID = VIRTUAL_OFFER_ROW_ID WHERE VIRTUAL_OFFER_ID = #get_max_id.MAX_ID#
                </cfquery>
                <cfquery name="get_max_row_id" datasource="#dsn3#">
                    SELECT MAX(VIRTUAL_OFFER_ROW_ID) AS MAX_ROW_ID FROM EZGI_VIRTUAL_OFFER_ROW
                </cfquery>
                <cfquery name="add_row_detail" datasource="#dsn3#">
                    INSERT INTO 
                        EZGI_VIRTUAL_OFFER_ROW_DETAIL
                        (
                            EZGI_ID, 
                            AMOUNT, 
                            LAST_AMOUNT,
                            SALES_PRICE, 
                            SALES_PRICE_MONEY, 
                            PURCHASE_PRICE, 
                            PURCHASE_PRICE_MONEY, 
                            COST_PRICE, 
                            COST_PRICE_MONEY, 
                            STOCK_ID, 
                            PRODUCT_CODE, 
                            PRODUCT_NAME, 
                            MAIN_UNIT, 
                            PIECE_ROW_ID, 
                            PIECE_TYPE, 
                            QUESTION_ID, 
                            IS_AMOUNT_CHANGE, 
                            IS_PRICE_CHANGE, 
                            BOY_FORMUL, 
                            EN_FORMUL, 
                            AMOUNT_FORMUL, 
                            NOT_STANDART_RATE, 
                            DESIGN_EN, 
                            DESIGN_BOY,
                            PRIVATE_PRICE_TYPE, 
                            PRIVATE_PRICE_MONEY, 
                            PRIVATE_PRICE
                        )
                    SELECT        
                        #get_max_row_id.MAX_ROW_ID#, 
                        AMOUNT, 
                        LAST_AMOUNT,
                        SALES_PRICE, 
                        SALES_PRICE_MONEY, 
                        PURCHASE_PRICE, 
                        PURCHASE_PRICE_MONEY, 
                        COST_PRICE, 
                        COST_PRICE_MONEY, 
                        STOCK_ID, 
                        PRODUCT_CODE, 
                        PRODUCT_NAME, 
                        MAIN_UNIT, 
                        PIECE_ROW_ID, 
                        PIECE_TYPE, 
                        QUESTION_ID, 
                        IS_AMOUNT_CHANGE, 
                        IS_PRICE_CHANGE, 
                        BOY_FORMUL, 
                        EN_FORMUL, 
                        AMOUNT_FORMUL, 
                        NOT_STANDART_RATE, 
                        DESIGN_EN, 
                        DESIGN_BOY,
                        PRIVATE_PRICE_TYPE, 
                        PRIVATE_PRICE_MONEY, 
                        PRIVATE_PRICE
                    FROM            
                        EZGI_VIRTUAL_OFFER_ROW_DETAIL
                    WHERE        
                        EZGI_ID = #i# 
                </cfquery>
                <cfquery name="cpy_EZGI_VIRTUAL_OFFER_ROW_IMPORT" datasource="#dsn3#">
                    INSERT INTO              
                        EZGI_VIRTUAL_OFFER_ROW_IMPORT
                        (
                            EZGI_ID, 
                            POZ_ID, 
                            PACKAGE_ROW_ID, 
                            PIECE_ID, 
                            PIECE_ROW_ID, 
                            PIECE_TYPE, 
                            STOCK_ID, 
                            PRODUCT_NAME, 
                            AMOUNT, 
                            BOY, 
                            EN, 
                            KALINLIK,
                            YON, 
                            DETAY, 
                            PVC1, 
                            PVC2, 
                            PVC3, 
                            PVC4,
                            CANAL_DETAIL, 
                            COVER_MODEL, 
                            HOLE_QUANTITY, 
                            MATERIAL_MEASURE1, 
                            MATERIAL_MEASURE2, 
                            MATERIAL_AMOUNT, 
                            PACKAGE_DETAIL, 
                            OPERATION_CODE1, 
                            OPERATION_CODE2, 
                            VIRTUAL_MATERIAL
                        )
                    SELECT
                 		#get_max_row_id.MAX_ROW_ID#, 
                       	POZ_ID, 
                      	PACKAGE_ROW_ID, 
                      	PIECE_ID, 
                     	PIECE_ROW_ID, 
                       	PIECE_TYPE, 
                     	STOCK_ID, 
                      	PRODUCT_NAME, 
                      	AMOUNT, 
                      	BOY, 
                     	EN, 
                      	KALINLIK,
                     	YON, 
                      	DETAY, 
                     	PVC1, 
                       	PVC2, 
                       	PVC3, 
                      	PVC4,
                        CANAL_DETAIL, 
                        COVER_MODEL, 
                        HOLE_QUANTITY, 
                        MATERIAL_MEASURE1, 
                        MATERIAL_MEASURE2, 
                        MATERIAL_AMOUNT, 
                        PACKAGE_DETAIL, 
                        OPERATION_CODE1, 
                        OPERATION_CODE2, 
                        VIRTUAL_MATERIAL
                  	FROM
                    	EZGI_VIRTUAL_OFFER_ROW_IMPORT
                    WHERE        
                        EZGI_ID = #i#       
            	</cfquery>
               	<cfquery name="cpy_EZGI_VIRTUAL_OFFER_ROW_IMPORT_ROTA" datasource="#dsn3#">
                	INSERT INTO 
                     	EZGI_VIRTUAL_OFFER_ROW_IMPORT_ROTA
                     	(
                         	EZGI_ID, 
                        	PIECE_ID, 
                          	PIECE_ROW_ID, 
                          	PIECE_TYPE, 
                          	OPERATION_TYPE_ID, 
                         	AMOUNT
                     	)
               		SELECT
                   		#get_max_row_id.MAX_ROW_ID#,  
                      	PIECE_ID, 
                     	PIECE_ROW_ID, 
                    	PIECE_TYPE, 
                     	OPERATION_TYPE_ID, 
                   		AMOUNT
                   	FROM
                   		EZGI_VIRTUAL_OFFER_ROW_IMPORT_ROTA
                   	WHERE        
                        EZGI_ID = #i# 
            	</cfquery>
                <cfquery name="cpy_EZGI_VIRTUAL_OFFER_ROW_IMPORT_FILE" datasource="#dsn3#">
                    INSERT INTO 
                        EZGI_VIRTUAL_OFFER_ROW_IMPORT_FILE
                        (
                            EZGI_ID, 
                            FILE_TYPE_ID, 
                            FILE_NAME
                        )
                    SELECT        
                        #get_max_row_id.MAX_ROW_ID#, 
                        FILE_TYPE_ID, 
                        FILE_NAME
                    FROM            
                        EZGI_VIRTUAL_OFFER_ROW_IMPORT_FILE
                    WHERE        
                        EZGI_ID = #i# 
                </cfquery>
                <cfquery name="cpy_EZGI_VIRTUAL_OFFER_ROW_FLOOR" datasource="#dsn3#">
                	INSERT INTO 
                    	EZGI_VIRTUAL_OFFER_ROW_FLOOR
                  		(
                        	EZGI_ID, 
                            TIP, 
                            KONUM, 
                            DAIRE, 
                            MEKAN, 
                            IS_PRINT
                     	)
					SELECT     
                    	#get_max_row_id.MAX_ROW_ID#,
                        TIP, 
                        KONUM, 
                        DAIRE, 
                        MEKAN, 
                        IS_PRINT
					FROM      
                    	EZGI_VIRTUAL_OFFER_ROW_FLOOR
					WHERE     
                    	EZGI_ID = #i#
               	</cfquery> 
                <cfquery name="cpy_EZGI_VIRTUAL_OFFER_ROW_DESCRIPTION" datasource="#dsn3#">
                	INSERT INTO 
                    	EZGI_VIRTUAL_OFFER_ROW_DESCRIPTION
                  		(
                        	EZGI_ID, 
                            DESCRIPTION
                      	)
					SELECT     
                    	#get_max_row_id.MAX_ROW_ID#, 
                        DESCRIPTION
					FROM        
                    	EZGI_VIRTUAL_OFFER_ROW_DESCRIPTION
					WHERE     
                    	EZGI_ID = #i#
                </cfquery>
                <cfquery name="cpy_EZGI_VIRTUAL_OFFER_ROW_MONTAGE" datasource="#dsn3#">
                	INSERT INTO 
                    	EZGI_VIRTUAL_OFFER_ROW_MONTAGE
                  		(
                        	EZGI_ID, 
                            STOCK_ID, 
                            AMOUNT
                      	)
					SELECT     
                    	#get_max_row_id.MAX_ROW_ID#,  
                        STOCK_ID, 
                        AMOUNT
					FROM      
                    	EZGI_VIRTUAL_OFFER_ROW_MONTAGE
					WHERE     
                    	EZGI_ID = #i#
                </cfquery>
                <cfquery name="cpy_EZGI_MONTAGE_ROW" datasource="#dsn3#">
                	INSERT INTO 
                    	EZGI_MONTAGE_ROW
                  		(
                        	EZGI_ID, 
                            MONTAGE_ID, 
                            STOCK_ID, 
                            PRODUCT_NAME, 
                            AMOUNT, 
                            MAIN_UNIT, 
                            PRODUCT_UNIT_ID, 
                            PRICE, 
                            OTHER_MONEY, 
                            IS_HZM, 
                            ROW_TOTAL, 
                            WRK_ROW_RELATION_ID, 
                            STATUS
                      	)
					SELECT     
                    	#get_max_row_id.MAX_ROW_ID#, 
                        MONTAGE_ID, 
                        STOCK_ID, 
                        PRODUCT_NAME, 
                        AMOUNT, 
                        MAIN_UNIT, 
                        PRODUCT_UNIT_ID, 
                        PRICE, 
                        OTHER_MONEY, 
                        IS_HZM, 
                        ROW_TOTAL, 
                        <cfif isdefined('attributes.cpy_virtual_offer_id')>
                            NULL,
                        <cfelseif isdefined('attributes.rvs_virtual_offer_id')>
                            WRK_ROW_RELATION_ID,
                        </cfif>
                        STATUS
					FROM        
                    	EZGI_MONTAGE_ROW
					WHERE     
                    	EZGI_ID = #i#
              	</cfquery>
            </cfloop>
       	<cfelse>
        	<cfdump var="#get_row_id#">
        	Kopyalanacak Satır Bulunamadı.
        	<cfabort>
        </cfif>
    </cftransaction>
</cflock>