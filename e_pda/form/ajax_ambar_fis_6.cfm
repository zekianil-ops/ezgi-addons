<!---
    File: ajax_ambar_fis_6.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/03/2025
    Description: Sipariş Bazlı Ambar Fişi Sipariş Bulma Ajax
---> 
<cfif isdefined('attributes.ordernumber')>
	<cfquery name="get_order" datasource="#dsn3#">
        SELECT DISTINCT      
           	ORDER_ID, 
         	ORDER_NUMBER, 
         	COMPANY_ID, 
        	CONSUMER_ID
        FROM            
            ORDERS
        WHERE        
			ORDER_NUMBER = '#attributes.ordernumber#'
    </cfquery>
<cfelse>
    <cfquery name="get_order" datasource="#dsn3#">
        SELECT DISTINCT      
            ORR.ORDER_ID, 
            O.ORDER_NUMBER, 
            O.COMPANY_ID, 
            O.CONSUMER_ID
        FROM            
            ORDER_ROW AS ORR INNER JOIN
            SPECTS AS SP ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
            ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID
        WHERE        
            SP.SPECT_MAIN_ID = #attributes.spectmainid# AND 
            ORR.ORDER_ROW_CURRENCY NOT IN (- 3, - 8, - 9, - 10)
    </cfquery>
</cfif>
<cf_basket id="report_side">
	<cf_grid_list sort="0">
         	<thead>
                <tr>
                	<th style="text-align:center; height:20px; width:25px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th style="text-align:center; width:70px"><cf_get_lang dictionary_id='58211.Sipariş No'></th>
                   	<th style="text-align:center;"><cf_get_lang dictionary_id='57457.Müşteri'></th>
                </tr>
        	</thead>
            
        	<tbody>
            	<cfif get_order.recordcount>
              		<cfoutput query="get_order">
                        <tr>
                            <td style="text-align:right; height:30px">#Currentrow#</td>
                            <td style="text-align:center" nowrap="nowrap">
                            	<a href="#request.self#?fuseaction=pda.add_ambar_fis_6&order_id=#ORDER_ID#" class="tableyazi">#ORDER_NUMBER#</a>
                            </td>
                            <td style="text-align:left">
                            	<cfif len(COMPANY_ID)>
                                	#get_par_info(COMPANY_ID,1,1,0)#
                                <cfelseif len(CONSUMER_ID)>
                                	#get_cons_info(CONSUMER_ID,0,0)#
                                </cfif>
                            </td>
                       	</tr>
                	</cfoutput>
             	</cfif>
           	</tbody>
    </cf_grid_list>
</cf_basket>