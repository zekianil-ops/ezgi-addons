<cfquery name="get_default" datasource="#dsn3#">
	SELECT       
    	POINT_METHOD,
        FABRIC_CAT,
        CONTROL_METHOD
	FROM            
    	EZGI_MASTER_PLAN_DEFAULTS
	WHERE        
    	SHIFT_ID = 1
</cfquery>
<cfquery name="GET_CURRENT_DATE_P_ORDERS" datasource="#dsn3#">
        SELECT        
            EOS.LOT_NO, 
            EOS.P_ORDER_ID, 
            EOS.P_ORDER_NO, 
            EOS.STOCK_CODE, 
            EOS.STOCK_ID, 
            EOS.PRODUCT_ID, 
            EOS.PRODUCT_NAME, 
            EOS.SPECT_VAR_NAME, 
            EOS.QUANTITY, 
            EOS.SPEC_MAIN_ID, 
            EOS.START_DATE, 
            O.DELIVERDATE,
            O.ORDER_DETAIL, 
            ISNULL(O.ORDER_ID,0) AS ORDER_ID,
            O.ORDER_NUMBER, 
            O.ORDER_DATE, 
            O.COMPANY_ID, 
            O.CONSUMER_ID, 
            O.EMPLOYEE_ID,
            CASE
           		WHEN O.COMPANY_ID IS NOT NULL THEN
                   (
                    SELECT     
                      	NICKNAME
					FROM         
                    	#dsn_alias#.COMPANY
					WHERE     
                   		COMPANY_ID = O.COMPANY_ID
                  	)
            	WHEN O.CONSUMER_ID IS NOT NULL THEN      
                   	(	
                  	SELECT     
                     	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
					FROM         
                      	#dsn_alias#.CONSUMER
					WHERE     
                		CONSUMER_ID = O.CONSUMER_ID
               		)
           		WHEN O.EMPLOYEE_ID IS NOT NULL THEN
                  	(
                   	SELECT     
                    	EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
					FROM         
                  		#dsn_alias#.EMPLOYEES
					WHERE     
                     	EMPLOYEE_ID = O.EMPLOYEE_ID
                 	)
       		END AS UNVAN
        FROM            
            ORDERS AS O INNER JOIN
            PRODUCTION_ORDERS_ROW AS PORR ON O.ORDER_ID = PORR.ORDER_ID RIGHT OUTER JOIN
            EZGI_OPERATION_S AS EOS ON PORR.PRODUCTION_ORDER_ID = EOS.P_ORDER_ID
        WHERE        
            EOS.PRODUCTION_LEVEL = N'0' AND
            EOS.STOCK_CODE LIKE '01.152.%' AND 
            O.ORDER_ID = #attributes.order_id#
        GROUP BY 
            EOS.LOT_NO, 
            EOS.P_ORDER_ID, 
            EOS.P_ORDER_NO, 
            EOS.STOCK_CODE, 
            EOS.STOCK_ID, 
            EOS.PRODUCT_ID, 
            EOS.PRODUCT_NAME, 
            EOS.SPECT_VAR_NAME, 
            EOS.QUANTITY, 
            EOS.SPEC_MAIN_ID, 
            EOS.START_DATE, 
            O.DELIVERDATE,
            O.ORDER_DETAIL,
            O.ORDER_ID,
            O.ORDER_NUMBER, 
            O.ORDER_DATE, 
            O.COMPANY_ID, 
            O.CONSUMER_ID, 
            O.EMPLOYEE_ID
        ORDER BY
            O.ORDER_NUMBER,
            EOS.PRODUCT_NAME
   	</cfquery>
    <cfif GET_CURRENT_DATE_P_ORDERS.recordcount>
    	<cfset p_order_id_list = Valuelist(GET_CURRENT_DATE_P_ORDERS.P_ORDER_ID)>
        <cfquery name="get_sub_orders" datasource="#dsn3#">
        	SELECT DISTINCT 
            	P_ORDER_ID
			FROM            
            	(
                	SELECT        
                    	P_ORDER_ID
               		FROM            
                   		EZGI_R_ORDER
                	WHERE        
                   		P_ORDER_ID IN (#p_order_id_list#)
                 	UNION ALL
                  	SELECT        
                    	P_ORDER_ID1
                  	FROM            
                   		EZGI_R_ORDER AS EZGI_R_ORDER_1
                 	WHERE        
                    	P_ORDER_ID IN (#p_order_id_list#) AND 
                   		NOT (P_ORDER_ID1 IS NULL)
               		UNION ALL
                 	SELECT        
                    	P_ORDER_ID2
                  	FROM       
                    	EZGI_R_ORDER AS EZGI_R_ORDER_2
                	WHERE        
                    	P_ORDER_ID IN (#p_order_id_list#) AND 
                        NOT (P_ORDER_ID2 IS NULL)
            	) AS TBL
        </cfquery>
        <cfset sub_p_order_id_list = ValueList(get_sub_orders.P_ORDER_ID)>
    	<cfquery name="get_operations" datasource="#dsn3#">
        	SELECT 
            	EOS.P_ORDER_ID,       
            	EOS.P_OPERATION_ID, 
                EOS.OPERATION_TYPE_ID, 
                EOS.AMOUNT, 
                EOS.STAGE, 
                EOS.LOT_NO,
                EOS.PRODUCT_NAME,
                ISNULL(SUM(EOS.REAL_AMOUNT), 0) AS REAL_AMOUNT
			FROM            
           		EZGI_OPERATION_S AS EOS INNER JOIN
             	PRODUCTION_ORDERS AS PO ON EOS.LOT_NO = PO.LOT_NO
			WHERE        
            	PO.P_ORDER_ID IN (#sub_p_order_id_list#)
			GROUP BY 
            	EOS.P_ORDER_ID,  
            	EOS.P_OPERATION_ID, 
                EOS.OPERATION_TYPE_ID, 
                EOS.AMOUNT, 
                EOS.STAGE,
                EOS.LOT_NO,
                EOS.PRODUCT_NAME
        </cfquery>
    </cfif> 
<thead>  
 	<tr align="right" class="color-list">
    	<th style="width:20px; text-align:center">&nbsp;S.No&nbsp;</th>
    	<th style="width:300px;text-align:center">&nbsp;Ürün Adı&nbsp;</th>
      	<th style="width:50px; text-align:center">&nbsp;Miktar&nbsp;</th>
     	<th style="text-align:center; width:20px"><div id="Ay6" style="font:normal normal bold 11px tahoma;writing-mode:tb-rl;filter:fliph flipv; text-align:center">Optimizasyon</div></th>
     	<th style="text-align:center; width:20px"><div id="Ay6" style="font:normal normal bold 11px tahoma;writing-mode:tb-rl;filter:fliph flipv; text-align:center">K.Durum</div></th>
     	<!---<th style="text-align:center; width:20px"><div id="Ay1" style="font:normal normal bold 11px tahoma;writing-mode:tb-rl;filter:fliph flipv; text-align:center">K.Metraj</div></th>--->
      	<th style="text-align:center; width:20px"><div id="Ay2" style="font:normal normal bold 11px tahoma;writing-mode:tb-rl;filter:fliph flipv; text-align:center">K.Kesim</div></th>
     	<!---<th style="text-align:center; width:20px"><div id="Ay3" style="font:normal normal bold 11px tahoma;writing-mode:tb-rl;filter:fliph flipv; text-align:center">Tasnif</div></th>--->
      	<th style="text-align:center; width:20px"><div id="Ay4" style="font:normal normal bold 11px tahoma;writing-mode:tb-rl;filter:fliph flipv; text-align:center">Dikiş</div></th>
     	<th style="text-align:center; width:20px"><div id="Ay5" style="font:normal normal bold 11px tahoma;writing-mode:tb-rl;filter:fliph flipv; text-align:center">Döşeme</div></th>
     	<!---<th style="text-align:center; width:20px"><div id="Ay7" style="font:normal normal bold 11px tahoma;writing-mode:tb-rl;filter:fliph flipv; text-align:center">Montaj</div></th>--->
     	<th style="text-align:center; width:20px"><div id="Ay8" style="font:normal normal bold 11px tahoma;writing-mode:tb-rl;filter:fliph flipv; text-align:center">Ambalaj</div></th>
    </tr>
</thead>
<tbody>
	<cfif GET_CURRENT_DATE_P_ORDERS.recordcount>
        		<cfoutput query="GET_CURRENT_DATE_P_ORDERS">
                	<cfquery name="sub_orders" datasource="#dsn3#">
                        SELECT DISTINCT 
                            P_ORDER_ID
                        FROM            
                            (
                                SELECT        
                                    P_ORDER_ID
                                FROM            
                                    EZGI_R_ORDER
                                WHERE        
                                    P_ORDER_ID = #GET_CURRENT_DATE_P_ORDERS.P_ORDER_ID#
                                UNION ALL
                                SELECT        
                                    P_ORDER_ID1
                                FROM            
                                    EZGI_R_ORDER AS EZGI_R_ORDER_1
                                WHERE        
                                    P_ORDER_ID = #GET_CURRENT_DATE_P_ORDERS.P_ORDER_ID# AND 
                                    NOT (P_ORDER_ID1 IS NULL)
                                UNION ALL
                                SELECT        
                                    P_ORDER_ID2
                                FROM       
                                    EZGI_R_ORDER AS EZGI_R_ORDER_2
                                WHERE        
                                    P_ORDER_ID = #GET_CURRENT_DATE_P_ORDERS.P_ORDER_ID# AND 
                                    NOT (P_ORDER_ID2 IS NULL)
                            ) AS TBL
                    </cfquery>
        			<cfset sub_order_id_list = ValueList(sub_orders.P_ORDER_ID)>
                	<cfquery name="get_operation" dbtype="query">
                        SELECT        
                            P_OPERATION_ID, 
                            OPERATION_TYPE_ID, 
                            AMOUNT, 
                            STAGE, 
                            REAL_AMOUNT,
                            PRODUCT_NAME
                        FROM            
                            get_operations
                        WHERE
                            P_ORDER_ID IN (#sub_order_id_list#)
                      	ORDER BY
                        	OPERATION_TYPE_ID
                    </cfquery>
					<tr > 
						<td style="text-align:right;height:25px">#currentrow#&nbsp;</td>
                        <td style="text-align:left" nowrap="nowrap">#PRODUCT_NAME#</td>
                        <td style="text-align:right" nowrap="nowrap">#Tlformat(QUANTITY,2)#</td>
                        <cfquery name="get_kontrol_0" datasource="#dsn3#"> <!---Optimizasyona ve Var-yok a giren emirler soruluyor--->
                                                SELECT DISTINCT 
                                                    POS.STOCK_ID, 
                                                    POS.AMOUNT,
                                                    EMC.STATUS
                                                FROM         
                                                    EZGI_METARIAL_CONTROL AS EMC INNER JOIN
                                                    PRODUCTION_ORDERS_STOCKS AS POS ON EMC.POR_STOCK_ID = POS.POR_STOCK_ID
                                                WHERE     
                                                	<cfif get_default.CONTROL_METHOD eq 1 or ORDER_ID eq 0>
                                                        EMC.LOT_NO = '#lot_no#'
                                                    <cfelseif get_default.CONTROL_METHOD eq 2 and ORDER_ID gt 0>
                                                        EMC.ORDER_ID = #order_id#
                                                    </cfif>
                                                     
                  		</cfquery>
                     	<cfquery name="get_kontrol_1" dbtype="query"> <!---Var Denilenler Bulunuyor--->
                                                SELECT
                                                    STOCK_ID, 
                                                    AMOUNT
                                                FROM         
                                                    get_kontrol_0
                                                WHERE     
                                                    STATUS = 1
              			</cfquery>

                     	<cfquery name="get_kontrol_2" dbtype="query"> <!---Yok Denilenler Bulunuyor--->
                                                SELECT
                                                    STOCK_ID, 
                                                    AMOUNT
                                                FROM         
                                                    get_kontrol_0
                                                WHERE     
                                                    STATUS = 2
                                            </cfquery>
                                            <cfquery name="get_ezgi_metarial_control" dbtype="query"> <!---Yok Denilenler Guruplanıyor--->
                                                SELECT
                                                    STOCK_ID, 
                                                    SUM(AMOUNT) AS AMOUNT
                                                FROM         
                                                    get_kontrol_2
                                                GROUP BY 
                                                    STOCK_ID
                   		</cfquery>
                      	<cfquery name="get_ezgi_metarial_control_0" dbtype="query"> <!---Optimizasyondan Geçen heşey guruplanıyor--->
                                                SELECT
                                                    STOCK_ID, 
                                                    SUM(AMOUNT) AS AMOUNT
                                                FROM         
                                                    get_kontrol_0
                                                GROUP BY 
                                                    STOCK_ID
                    	</cfquery>
                     	<cfloop query="get_ezgi_metarial_control_0">
                     		<cfset 'CONTROL_#GET_CURRENT_DATE_P_ORDERS.lot_no#_#get_ezgi_metarial_control_0.STOCK_ID#'= get_ezgi_metarial_control_0.AMOUNT>
                     	</cfloop>
                      	<cfquery name="get_ic_talep" datasource="#dsn3#">
                                            	SELECT     
                                             		I.INTERNAL_NUMBER, 
                                                 	EMR.ACTION_ID, 
                                                  	IR.STOCK_ID
                                              	FROM         
                                                   	EZGI_METARIAL_RELATIONS AS EMR INNER JOIN
                                                   	INTERNALDEMAND AS I ON EMR.ACTION_ID = I.INTERNAL_ID INNER JOIN
                                                   	INTERNALDEMAND_ROW AS IR ON I.INTERNAL_ID = IR.I_ID
                                              	WHERE     
                                               		EMR.TYPE = 1 AND 
                                                    <cfif get_default.CONTROL_METHOD eq 1 or ORDER_ID eq 0>
                                                        EMR.LOT_NO = '#lot_no#' AND 
                                                    <cfelseif get_default.CONTROL_METHOD eq 2 and ORDER_ID gt 0>
                                                        EMR.LOT_NO = '#ORDER_NUMBER#' AND 
                                                    </cfif>
                                                    IR.STOCK_ID IN 
                                                    				(
                                                                	SELECT     
                                                                   		STOCK_ID
																	FROM         
                                                                     	STOCKS
																	WHERE     
                                                                     	STOCK_CODE LIKE N'#get_default.FABRIC_CAT#%'
                                                                  	)
                     	</cfquery>
                                            
                     	<cfquery name="get_period" datasource="#dsn3#">
                                                SELECT     

                                                    PERIOD_ID
                                                FROM         
                                                    EZGI_METARIAL_RELATIONS
                                                WHERE     
                                                    TYPE = 2 AND 
                                                    LOT_NO = '#lot_no#'
                     	</cfquery>
                    	<cfset teslim = 0>
                     	<cfset teslim_1 = 0>
                    	<cfif get_period.recordcount>
                        	<cfset period_list = ValueList(get_period.PERIOD_ID)>
                           	<cfquery name="get_period_ship_dsns" datasource="#dsn3#">
                             	SELECT PERIOD_YEAR,OUR_COMPANY_ID,PERIOD_ID FROM #dsn_alias#.SETUP_PERIOD WHERE PERIOD_ID IN (#period_list#)
                         	</cfquery>
                     	</cfif>
                     	<cfif isdefined('period_list') and listlen(period_list) and period_list neq 0>
                         	<cfquery name="get_control_ambar_fis" datasource="#DSN3#">
                                                    SELECT 
                                                        STOCK_ID,
                                                        SUM(AMOUNT) AMOUNT
                                                    FROM
                                                        (
                                                        <cfloop query="get_period_ship_dsns">
                                                            SELECT     
                                                                SFR.STOCK_ID, 
                                                                SFR.AMOUNT
                                                            FROM         
                                                                EZGI_METARIAL_RELATIONS INNER JOIN
                                                                #dsn#_#get_period_ship_dsns.PERIOD_YEAR#_#get_period_ship_dsns.OUR_COMPANY_ID#.STOCK_FIS_ROW AS SFR ON EZGI_METARIAL_RELATIONS.ACTION_ID = SFR.FIS_ID
                                                            WHERE     
                                                                EZGI_METARIAL_RELATIONS.TYPE = 2 AND 
                                                                EZGI_METARIAL_RELATIONS.PERIOD_ID = #get_period_ship_dsns.period_id# AND 
                                                                EZGI_METARIAL_RELATIONS.LOT_NO = N'#GET_CURRENT_DATE_P_ORDERS.lot_no#' AND
                                                                SFR.STOCK_ID IN (
                                                                				SELECT     
                                                                                	STOCK_ID
																				FROM         
                                                                                	STOCKS
																				WHERE     
                                                                                	STOCK_CODE LIKE N'#get_default.FABRIC_CAT#%'
                                                                              	)
                                                            <cfif currentrow neq get_period_ship_dsns.recordcount> UNION ALL </cfif> 
                                                        </cfloop>
                                                        ) TBL
                                                    GROUP BY
                                                        STOCK_ID 			
                       		</cfquery>
                       		<cfif get_control_ambar_fis.recordcount>
								<cfif get_control_ambar_fis.recordcount neq get_ezgi_metarial_control_0.recordcount>
                                 	<cfset teslim = 2>		
                             	<cfelse>
                                 	<cfset teslim = 1>
                             	</cfif>
                          	<cfelse>
                            	<cfset teslim = 0>
                         	</cfif>
                    	</cfif>
                        <td style="text-align:center; width:20px" title="">
                       		<cfif get_kontrol_0.recordcount eq 0>
 								<img src="/images/production/offlineuser.gif" title="<cf_get_lang dictionary_id='516.Optimizasyon Onay Verilmedi'>" border="0">
                         	<cfelse>
                            	<img src="/images/production/onlineuser_1.gif" title="<cf_get_lang dictionary_id='517.Optimizasyon Onay Verildi'>">
                          	</cfif> 
                        </td>
                        <td style="text-align:center" title="">
                     		<cfif get_kontrol_0.recordcount>
								<cfif get_kontrol_1.recordcount neq get_kontrol_0.recordcount>	
                                 	<cfif get_ic_talep.recordcount eq 0>
                                     	<img src="/images/production/offlineuser.gif" title="<cf_get_lang dictionary_id='518.İç Talep Verilmedi'>">
                                 	<cfelse>
                                    	<cfif get_ic_talep.recordcount neq get_ezgi_metarial_control.recordcount>
                                    		<img src="/images/production/onlineuser.gif" title="<cf_get_lang dictionary_id='519.İç Talep Eksik Verildi'>">
                                      	<cfelse>
                                         	<cfif teslim eq 0>
                                            	<img src="/images/production/onlineuser_2.gif" title="<cf_get_lang dictionary_id='520.İç Talep Tam Verildi'>">
                                         	<cfelseif teslim eq 1>
                                            	<img src="/images/production/onlineuser_1.gif" title="<cf_get_lang dictionary_id='521.Tam Ambar Fişi'>">
                                          	<cfelseif teslim eq 2>
                                             	<img src="/images/production/onlineuser_3.gif" title="<cf_get_lang dictionary_id='522.Eksik Ambar Fişi'>">
                                       		</cfif>      
                                   		</cfif>
                                 	</cfif>
                            	<cfelse>
                             		<cfif teslim eq 0>
                                     	<img src="/images/production/onlineuser_2.gif" title="<cf_get_lang dictionary_id='523.Kumaşlar Mevcut'>">
                                   	<cfelseif teslim eq 1>
                                     	<img src="/images/production/onlineuser_1.gif" title="<cf_get_lang dictionary_id='521.Tam Ambar Fişi'>">
                                 	<cfelseif teslim eq 2>
                                   		<img src="/images/production/onlineuser_3.gif" title="<cf_get_lang dictionary_id='522.Eksik Ambar Fişi'>">
                                  	</cfif>
                            	</cfif>
                         	</cfif>              
                        </td>
                        <!---<td style="text-align:center" title="Kumaş Metraj">
                        	<cfloop query="get_operation">
                            	<cfif get_operation.OPERATION_TYPE_ID eq 2 or get_operation.OPERATION_TYPE_ID eq 1004>
									<cfif get_operation.STAGE eq 0>
                            			<img src="/images/yellow_glob.gif" title="#PRODUCT_NAME#">
                        			<cfelseif get_operation.STAGE eq 1>
                            			<img src="/images/green_glob.gif" title="#PRODUCT_NAME#">
                        			<cfelseif get_operation.STAGE eq 3>
                             			<img src="/images/red_glob.gif" title="#PRODUCT_NAME#">
                                   	<cfelse>
			                             <img src="/images/blue_glob.gif" title="#PRODUCT_NAME#"> 
                        			</cfif> 
                           		</cfif>
                            </cfloop>
                        </td>--->
                        
                		<td style="text-align:center" title="Kumaş Kesim">
                        	<cfloop query="get_operation">
                            	<cfif get_operation.OPERATION_TYPE_ID eq 26>
									<cfif get_operation.STAGE eq 0>
                            			<img src="/images/yellow_glob.gif" title="#PRODUCT_NAME#">
                        			<cfelseif get_operation.STAGE eq 1>
                            			<img src="/images/green_glob.gif" title="#PRODUCT_NAME#">
                        			<cfelseif get_operation.STAGE eq 3>
                             			<img src="/images/red_glob.gif" title="#PRODUCT_NAME#">
                                   	<cfelse>
			                             <img src="/images/blue_glob.gif" title="#PRODUCT_NAME#"> 
                        			</cfif> 
                           		</cfif>
                            </cfloop>
                        </td>
                        <!---<td style="text-align:center" title="Tasnif">
                        	<cfloop query="get_operation">
                            	<cfif get_operation.OPERATION_TYPE_ID eq 4>
									<cfif get_operation.STAGE eq 0>
                            			<img src="/images/yellow_glob.gif" title="#PRODUCT_NAME#">
                        			<cfelseif get_operation.STAGE eq 1>
                            			<img src="/images/green_glob.gif" title="#PRODUCT_NAME#">
                        			<cfelseif get_operation.STAGE eq 3>
                             			<img src="/images/red_glob.gif" title="#PRODUCT_NAME#">
                                   	<cfelse>
			                             <img src="/images/blue_glob.gif" title="#PRODUCT_NAME#"> 
                        			</cfif> 
                           		</cfif>
                            </cfloop>
                        </td>--->
                		<td style="text-align:center" title="Dikiş - Dikiş+Baskı">
                        	<cfloop query="get_operation">
                            	<cfif get_operation.OPERATION_TYPE_ID eq 27>
									<cfif get_operation.STAGE eq 0>
                            			<img src="/images/yellow_glob.gif" title="#PRODUCT_NAME#">
                        			<cfelseif get_operation.STAGE eq 1>
                            			<img src="/images/green_glob.gif" title="#PRODUCT_NAME#">
                        			<cfelseif get_operation.STAGE eq 3>
                             			<img src="/images/red_glob.gif" title="#PRODUCT_NAME#">
                                   	<cfelse>
			                             <img src="/images/blue_glob.gif" title="#PRODUCT_NAME#"> 
                        			</cfif> 
                           		</cfif>
                            </cfloop>
                        </td>
                		<td style="text-align:center" title="Döşeme">
                        	<cfloop query="get_operation">
                            	<cfif  get_operation.OPERATION_TYPE_ID eq 29>
									<cfif get_operation.STAGE eq 0>
                            			<img src="/images/yellow_glob.gif" title="#PRODUCT_NAME#">
                        			<cfelseif get_operation.STAGE eq 1>
                            			<img src="/images/green_glob.gif" title="#PRODUCT_NAME#">
                        			<cfelseif get_operation.STAGE eq 3>
                             			<img src="/images/red_glob.gif" title="#PRODUCT_NAME#">
                                   	<cfelse>
			                             <img src="/images/blue_glob.gif" title="#PRODUCT_NAME#"> 
                        			</cfif> 
                           		</cfif>
                            </cfloop>
                        </td>

                		<!---<td style="text-align:center" title="Montaj">
                        	<cfloop query="get_operation">
                            	<cfif  get_operation.OPERATION_TYPE_ID eq 11>
									<cfif get_operation.STAGE eq 0>
                            			<img src="/images/yellow_glob.gif" title="#PRODUCT_NAME#">
                        			<cfelseif get_operation.STAGE eq 1>
                            			<img src="/images/green_glob.gif" title="#PRODUCT_NAME#">
                        			<cfelseif get_operation.STAGE eq 3>
                             			<img src="/images/red_glob.gif" title="#PRODUCT_NAME#">
                                   	<cfelse>
			                             <img src="/images/blue_glob.gif" title="#PRODUCT_NAME#"> 
                        			</cfif> 
                           		</cfif>
                            </cfloop>
                        </td>--->
                		<td style="text-align:center" title="Ambalaj">
                        	<cfloop query="get_operation">
                            	<cfif get_operation.OPERATION_TYPE_ID eq 31>
									<cfif get_operation.STAGE eq 0>
                            			<img src="/images/yellow_glob.gif" title="#PRODUCT_NAME#">
                        			<cfelseif get_operation.STAGE eq 1>
                            			<img src="/images/green_glob.gif" title="#PRODUCT_NAME#">
                        			<cfelseif get_operation.STAGE eq 3>
                             			<img src="/images/red_glob.gif" title="#PRODUCT_NAME#">
                                   	<cfelse>
			                             <img src="/images/blue_glob.gif" title="#PRODUCT_NAME#"> 
                        			</cfif> 
                           		</cfif>
                            </cfloop>
						</td>
						</td>
                  	</tr>
               	</cfoutput>
			</cfif>
       	</tbody>