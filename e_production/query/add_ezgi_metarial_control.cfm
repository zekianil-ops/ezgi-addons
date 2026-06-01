<!---
    File: add_ezgi_metarial_control.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfif isdefined('attributes.total_lot_row') and attributes.total_lot_row gt 0>
	<cftransaction>
        <cfloop from="1" to="#attributes.total_lot_row#" index="lot_row">
            <cfquery name="get_old_stock" datasource="#dsn3#">
                SELECT
                    POR_STOCK_ID,    
                    STOCK_ID, 
                    AMOUNT
                FROM         
                    PRODUCTION_ORDERS_STOCKS
                WHERE     
                    POR_STOCK_ID IN (#Evaluate('attributes.por_stock_id_#lot_row#')#)
            </cfquery>
            <cfquery name="get_old_stock_total" dbtype="query">
                SELECT     
                    STOCK_ID, 
                    SUM(AMOUNT) AS AMOUNT
                FROM         
                    get_old_stock
                WHERE     
                    POR_STOCK_ID IN (#Evaluate('attributes.por_stock_id_#lot_row#')#)
                GROUP BY 
                    STOCK_ID
            </cfquery>
            <cfoutput query="get_old_stock_total">
                <cfif AMOUNT gt 0>
                    <cfset 'oran_#lot_row#_#STOCK_ID#' = (Filternum(Evaluate('T_AMOUNT_#lot_row#_#STOCK_ID#')) - AMOUNT)/AMOUNT>
                <cfelse>
                    <cfset 'oran_#lot_row#_#STOCK_ID#' = 0>
                </cfif>
            </cfoutput>

            <cfif Evaluate('attributes.upd_#lot_row#') eq 1>
                <cfloop query="get_old_stock">
                    <cfquery name="upd_metarial_control" datasource="#dsn3#">
                        UPDATE 
                            EZGI_METARIAL_CONTROL
                        SET
                            STATUS= <cfif isdefined('var_yok_#lot_row#_#POR_STOCK_ID#') and len(evaluate('var_yok_#lot_row#_#POR_STOCK_ID#'))>#Evaluate('var_yok_#lot_row#_#POR_STOCK_ID#')#<cfelse>NULL</cfif>,
                            PASTAL_CODE= <cfif isdefined('pastal_code_#lot_row#_#POR_STOCK_ID#') and len(evaluate('pastal_code_#lot_row#_#POR_STOCK_ID#'))>'#Evaluate('pastal_code_#lot_row#_#POR_STOCK_ID#')#'<cfelse>NULL</cfif>,
                            UPDATE_EMP=#session.ep.userid#,  
                            UPDATE_DATE=#now()#, 
                            UPDATE_IP='#CGI.REMOTE_ADDR#'
                        WHERE     
                            POR_STOCK_ID = #get_old_stock.POR_STOCK_ID# AND
                            <cfif isdefined('attributes.lot_no_#lot_row#') and len(Evaluate('attributes.lot_no_#lot_row#'))>
                                LOT_NO = '#Evaluate("attributes.lot_no_#lot_row#")#' 
                            <cfelseif isdefined('attributes.order_id_#lot_row#') and len(Evaluate('attributes.order_id_#lot_row#'))>
                                ORDER_ID = #Evaluate("attributes.order_id_#lot_row#")#
                            </cfif>
                    </cfquery>
                    <cfset new_amount = NumberFormat((Evaluate('oran_#lot_row#_#STOCK_ID#') * amount) + amount,'9.99')>
                    <cfquery name="upd_product_orders_stocks" datasource="#dsn3#">
                        UPDATE    
                            PRODUCTION_ORDERS_STOCKS
                        SET              
                            AMOUNT = #new_amount#
                        WHERE     
                            POR_STOCK_ID = #get_old_stock.POR_STOCK_ID#
                    </cfquery>
                </cfloop>
            <cfelse>     
                <cfloop query="get_old_stock">
                    <cfquery name="ADD_METARIAL_CONTROL" datasource="#dsn3#">
                        INSERT INTO 
                            EZGI_METARIAL_CONTROL
                            (
                            <cfif isdefined('attributes.lot_no_#lot_row#') and len(Evaluate('attributes.lot_no_#lot_row#'))>
                                LOT_NO,
                            <cfelseif isdefined('attributes.order_id_#lot_row#') and len(Evaluate('attributes.order_id_#lot_row#'))>
                                ORDER_ID,
                            </cfif>
                            POR_STOCK_ID, 
                            AMOUNT,
                            PASTAL_CODE,
                            RECORD_EMP, 
                            RECORD_DATE, 
                            RECORD_IP
                            )
                        VALUES     
                            (
                            <cfif isdefined('attributes.lot_no_#lot_row#') and len(Evaluate('attributes.lot_no_#lot_row#'))>
                                '#Evaluate("attributes.lot_no_#lot_row#")#',
                            <cfelseif isdefined('attributes.order_id_#lot_row#') and len(Evaluate('attributes.order_id_#lot_row#'))>
                                #Evaluate("attributes.order_id_#lot_row#")#,
                            </cfif>
                            #get_old_stock.POR_STOCK_ID#,
                            #evaluate('attributes.old_amount_#lot_row#_#POR_STOCK_ID#')#,
                            '#evaluate('attributes.pastal_code_#lot_row#_#POR_STOCK_ID#')#',
                            #session.ep.userid#,
                            #now()#,
                            '#CGI.REMOTE_ADDR#'
                            )
                    </cfquery>
                    <cfset new_amount = NumberFormat((Evaluate('oran_#lot_row#_#STOCK_ID#') * amount) + amount,'9.99')>
                    <cfquery name="upd_product_orders_stocks" datasource="#dsn3#">
                        UPDATE    
                            PRODUCTION_ORDERS_STOCKS
                        SET              
                            AMOUNT = #new_amount#
                        WHERE     
                            POR_STOCK_ID = #get_old_stock.POR_STOCK_ID#
                    </cfquery>
                </cfloop>
            </cfif>        
        
        </cfloop>
    </cftransaction>
</cfif>
<script language="javascript">
	wrk_opener_reload();
	window.close()
</script>