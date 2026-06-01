<!---
    File: list_ezgi_iflow_workstation_load.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/02/2025
    Description:
--->
<cfparam name="attributes.station_date" default="DateFormat(now(), dateformat_style)">
<cf_date tarih="attributes.station_date">
<cfif attributes.type eq 1>
	<cfquery name="upd_p_operation" datasource="#dsn3#">
    	UPDATE 
        	PRODUCTION_OPERATION
		SET         
    	<cfif len(attributes.station_id)>
        	O_STATION_IP = #attributes.station_id#, 
          	O_STATION_START_DATE = #attributes.station_date#
        <cfelse>
        	O_STATION_IP = NULL, 
         	O_STATION_START_DATE = NULL
        </cfif>	
     	WHERE  
        	P_OPERATION_ID = #attributes.p_operation_id#
    </cfquery>
    <cfif len(attributes.station_id)>
        <cfquery name="get_p_operation" datasource="#dsn3#">
        	SELECT
            	P_OPERATION_ID
            FROM
            	PRODUCTION_OPERATION
          	WHERE
            	O_STATION_IP = #attributes.station_id# AND
          		O_STATION_START_DATE = #attributes.station_date#
          	ORDER BY
            	O_CURRENT_NUMBER,
                O_START_DATE,
             	P_OPERATION_ID     
        </cfquery>
        <cfset row_sort = 1>
        <cfloop query="get_p_operation">
        	<cfquery name="upd_p_operation" datasource="#dsn3#">
            	UPDATE 
                    PRODUCTION_OPERATION
                SET 
                	O_CURRENT_NUMBER = #row_sort#
              	WHERE
                	P_OPERATION_ID = #get_p_operation.P_OPERATION_ID#	
            </cfquery>
            <cfset row_sort = row_sort+1>
        </cfloop>
    </cfif>
</cfif>
<cfquery name="get_stations" datasource="#dsn3#">
	SELECT 
    	ISNULL(W.EZGI_KATSAYI, 0) AS EZGI_KATSAYI, 
     	ISNULL(W.ACTIVE,0) ,
        W.STATION_NAME, 
        W.STATION_ID, 
        W.EZGI_SETUP_TIME ,
        ISNULL(WP.DEFAULT_STATUS, 0)         
	FROM     
   		WORKSTATIONS_PRODUCTS AS WP INNER JOIN
    	WORKSTATIONS AS W ON WP.WS_ID = W.STATION_ID
	WHERE  
    	WP.OPERATION_TYPE_ID = #attributes.operation_type_id# AND
        ISNULL(W.ACTIVE,0) = 1
 	ORDER BY
    	ISNULL(WP.DEFAULT_STATUS, 0) DESC,
    	ISNULL(W.ACTIVE,0) DESC,
        W.STATION_NAME
</cfquery>
<cfset station_id_list = ValueList(get_stations.STATION_ID)>
<cfif ListLen(station_id_list)>
    <cfquery name="get_station_operations" datasource="#dsn3#">
    	<!---SELECT 
            STAGE, 
            O_STATION_IP, 
            SUM(ISNULL(AMOUNT,0)*ISNULL(O_TOTAL_PROCESS_TIME,0)) AS O_TOTAL_PROCESS_TIME
        FROM  
        	PRODUCTION_OPERATION   
        WHERE  
            O_STATION_IP IN (#station_id_list#) AND 
            O_STATION_START_DATE = #attributes.station_date#
      	GROUP BY
        	STAGE, 
            O_STATION_IP--->
        SELECT 
            PORR.STAGE, 
            PORR.O_STATION_IP, 
            SUM(ISNULL(PORR.AMOUNT,0)*ISNULL(EOOT.OPTIMUM_TIME,0)) AS O_TOTAL_PROCESS_TIME
        FROM     
        	PRODUCTION_OPERATION AS PORR INNER JOIN
        	PRODUCTION_ORDERS AS PO ON PORR.P_ORDER_ID = PO.P_ORDER_ID LEFT OUTER JOIN
        	EZGI_OPERATION_OPTIMUM_TIME AS EOOT ON PO.STOCK_ID = EOOT.STOCK_ID AND PORR.OPERATION_TYPE_ID = EOOT.OPERATION_TYPE_ID
        WHERE  
            PORR.O_STATION_IP IN (#station_id_list#) AND 
            PORR.O_STATION_START_DATE = #attributes.station_date#
      	GROUP BY
        	PORR.STAGE, 
            PORR.O_STATION_IP
    </cfquery>
    <cfquery name="get_station_operations_group" dbtype="query">
    	SELECT 
            O_STATION_IP, 
            SUM(O_TOTAL_PROCESS_TIME) AS O_TOTAL_PROCESS_TIME
      	FROM
    		get_station_operations
       	GROUP BY
        	O_STATION_IP
    </cfquery>
    <cfif get_station_operations.recordcount>
    	<cfoutput query="get_station_operations_group">
        	<cfset 'O_TOTAL_PROCESS_TIME_#O_STATION_IP#' = O_TOTAL_PROCESS_TIME>
        </cfoutput>
        <cfoutput query="get_station_operations">
        	<cfset 'O_TOTAL_PROCESS_TIME_#O_STATION_IP#_#STAGE#' = O_TOTAL_PROCESS_TIME>
        </cfoutput>
    </cfif>
</cfif>
<cf_box>
	<cf_grid_list id="station_panel" sort="0">   
      	<thead>
         	<tr valign="middle">
             	<th style="text-align:center; vertical-align:middle"><cf_get_lang dictionary_id='58834.İstasyon'></th>
                <th style="width:40px; text-align:center; vertical-align:middle"><cf_get_lang dictionary_id='558.Katsayı'></th>
                <th style="width:70px;text-align:center; vertical-align:middle"><cf_get_lang dictionary_id='576.Doluluk'></th>
                <th style="width:70px;text-align:center; vertical-align:middle"><cf_get_lang dictionary_id='58456.Oran'></th>
                <th style="width:25px;text-align:center; vertical-align:middle"></th>
           	</tr>
     	</thead>
 		<tbody>
             <cfif get_stations.recordcount>
             	<cfoutput query="get_stations">
                	<tr>
                    	<td>#STATION_NAME#</td>
                        <td style="text-align:center">#EZGI_KATSAYI#</td>
                        <td style="text-align:center">
                        	<cfif isdefined('O_TOTAL_PROCESS_TIME_#STATION_ID#')>
								#AmountFormat(Evaluate('O_TOTAL_PROCESS_TIME_#STATION_ID#'))#
                                <cfset row_total = Evaluate('O_TOTAL_PROCESS_TIME_#STATION_ID#')>
							<cfelse>
                            	#AmountFormat(0)#
                                <cfset row_total = 0>
                            </cfif>
                        </td>
                        <td style="text-align:center">
                          	<cfif day_time gt 0 and row_total gt 0>
                          		#AmountFormat(row_total/day_time/EZGI_KATSAYI*100)#
                          	<cfelse>
                          		#AmountFormat(0)#
                          	</cfif>
                        </td>
                        <td style="text-align:center">
                        	<cfif isdate(attributes.station_date)>
								<cfset iid= '#get_stations.STATION_ID#-#DateFormat(attributes.station_date,dateformat_style)#'>
                                <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_ezgi_print_files&print_type=284&iid=#iid#','list');">
                                    <i class="fa fa-print" title="<cf_get_lang dictionary_id='57474.Yazdır'>" alt="<cf_get_lang dictionary_id='57474.Yazdır'>"></i>
                                </a>
                            </cfif>
                       	</td>
                    </tr>
                </cfoutput>
             </cfif>                   
     	</tbody>
	</cf_grid_list>
</cf_box>