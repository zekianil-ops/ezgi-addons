<div class="col col-12 col-xs-12">
	<cf_box>
     	<cf_grid_list>
        	<thead>       
                <tr>
                    <th style="height:25px"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                    <th><cf_get_lang dictionary_id='57657.Ürün'></th>
                    <th width="60" style="text-align:right;"><cf_get_lang dictionary_id='57452.Stok'></th>
                    <th width="60" style="text-align:right;"><cf_get_lang dictionary_id='36601.Min Stok'></th>
                    <th width="60" style="text-align:right;" title="<cf_get_lang dictionary_id='30008.Satınalma Siparişleri.'>"><cf_get_lang dictionary_id='57611.Sipariş'></th>
                    <th width="60" style="text-align:right;"><cf_get_lang dictionary_id='1071.Tedarik(Gün)'></th>
                    <th width="60" style="text-align:right;"><cf_get_lang dictionary_id='36437.İhtiyaç'></th>
                    <th width="25" style="text-align:right;"></th>
                </tr>
          	</thead>
            <tbody>
                <cfquery name="get_kontrol_1" datasource="#dsn3#">
                	SELECT 
                    	POS.STOCK_ID, 
                        POS.AMOUNT
					FROM         
                    	EZGI_METARIAL_CONTROL AS EMC INNER JOIN
                      	PRODUCTION_ORDERS_STOCKS AS POS ON EMC.POR_STOCK_ID = POS.POR_STOCK_ID
					WHERE     
                    	<cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
                        	EMC.LOT_NO = '#attributes.lot_no#' AND
                        <cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
                            EMC.ORDER_ID = #get_orders_info.ORDER_ID# AND
                            POS.POR_STOCK_ID IN (#por_stock_id_list#) AND
                        </cfif>
                        EMC.STATUS = 2
                </cfquery>
                <!---<cfdump expand="yes" var="#get_kontrol_1#">--->
                <cfquery name="METARIAL_KONTROL" dbtype="query">
                    SELECT
                        STOCK_ID, 
                        SUM(AMOUNT) AS AMOUNT
                    FROM         
                        get_kontrol_1
                    GROUP BY 
                        STOCK_ID
                </cfquery>
                <cfoutput query="METARIAL_KONTROL">
                    <cfset 'm_kontrol_#STOCK_ID#' = AMOUNT>
                </cfoutput>
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
                        <cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
                        	EMR.LOT_NO = '#attributes.lot_no#'
                        <cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
                            EMR.LOT_NO = '#get_orders_info.ORDER_number#'
                        </cfif>
                 </cfquery>
                 <cfif get_ic_talep.recordcount>
                 	<cfoutput query="get_ic_talep">
                    	<cfset 'ACTION_ID_#STOCK_ID#' = ACTION_ID>
                        <cfset 'INTERNAL_NUMBER_#STOCK_ID#' = INTERNAL_NUMBER>
                    </cfoutput>
                 </cfif>
                <cfoutput query="get_malzeme_group">
                    
                    <tr style="height:20px"> 
                        <td>
                            #PRODUCT_CODE#
                        </td>
                        <td>#PRODUCT_NAME#</td>
                        <td style="text-align:right;"><cfif isdefined('PRODUCT_STOCK_#STOCK_ID#')>#evaluate('PRODUCT_STOCK_#STOCK_ID#')#<cfelse>0</cfif></td>
                        <td style="text-align:right;"><cfif isdefined('MINIMUM_STOCK_#STOCK_ID#')>#evaluate('MINIMUM_STOCK_#STOCK_ID#')#<cfelse>0</cfif></td>
                        <td style="text-align:right;">
                            <cfif isdefined('ARTAN_STOCK_#STOCK_ID#')>
                                    #evaluate('ARTAN_STOCK_#STOCK_ID#')#
                            <cfelse>
                                0
                            </cfif>
                        </td>
                        <td style="text-align:right;"><cfif isdefined('PROVISION_TIME_#STOCK_ID#')>#evaluate('PROVISION_TIME_#STOCK_ID#')#<cfelse>0</cfif></td>
                        <td style="text-align:right;">
                            <cfif isdefined('m_kontrol_#STOCK_ID#')>
                                #TlFormat(Evaluate('m_kontrol_#STOCK_ID#'))#
                            <cfelse>
                                0
                            </cfif>
                        </td>

                        <td style="text-align:center; vertical-align:middle">
                        	<cfif isdefined('ACTION_ID_#STOCK_ID#')>
								<cfset action_id = Evaluate('ACTION_ID_#STOCK_ID#')>
                                <a href="#request.self#?fuseaction=purchase.list_internaldemand&event=upd&id=#action_id#"><img src="/images/update_list.gif" title="<cf_get_lang dictionary_id='57464.Güncelle'>" border="0"></a>
                            <cfelse>
								<cfif isdefined('m_kontrol_#STOCK_ID#')>
                                    <input type="checkbox" name="select_production" value="#STOCK_ID#_#Evaluate('m_kontrol_#STOCK_ID#')#">
                                <cfelse>
                                	&nbsp;
                                </cfif>
                          	</cfif>
                        </td>
                    </tr>
                </cfoutput>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="8" style="text-align:right; vertical-align:middle; height:30px">
                    	<!---<button onClick="grupla();" style="height:30px; width:100px; background-color:mediumturquoise; border:none; color:white">İç Talep Oluştur</button>--->
                        <input type="button" value="İç Talep Oluştur" onClick="grupla();" style="height:30px; width:100px; background-color:silver">
                  	</td>
                </tr> 	
            </tfoot>
      	<cf_grid_list>
   	</cf_box>
</div>