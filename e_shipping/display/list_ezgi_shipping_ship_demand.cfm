<cfset demand_id_list = ''>
<cfif isdefined('attributes.sil') and attributes.sil eq 1>
	<cfquery name="del_demand_row" datasource="#dsn3#">
    	DELETE FROM 
        	EZGI_SHIPPING_DEMAND
		WHERE  
        	ORDER_ROW_ID = #attributes.order_row_id# AND 
            DEMAND_ORDER_ROW_ID = #attributes.demand_order_row_id#
    </cfquery>
    <cflocation url="#request.self#?fuseaction=sales.popup_list_ezgi_shipping_ship_demand&order_row_id=#attributes.order_row_id#" addtoken="No">
</cfif>
<cfif isdefined('attributes.ekle') and attributes.ekle eq 1>
	<cfquery name="add_demand_row" datasource="#dsn3#" result="MAX_ID">
    	INSERT INTO 
        	EZGI_SHIPPING_DEMAND
            (
            	ORDER_ROW_ID, 
                DEMAND_ORDER_ROW_ID, 
                EMPLOYEE_ID, 
                DEMAND_EMPLOYEE_ID, 
                DEMAND_STATUS_ID, 
                START_DATE,
                SHIPPING_DEMAND_STAGE
          	)
		VALUES 
        	(
            	#attributes.order_row_id#,
                #attributes.demand_order_row_id#,
                #attributes.empolyee_id#,
                #attributes.demand_empolyee_id#,
                1,
                #now()#,
                #attributes.PROCESS_STAGE#
          	)
    </cfquery>
    <cfquery name="get_position" datasource="#dsn#">
    	SELECT POSITION_ID FROM EMPLOYEE_POSITIONS WHERE EMPLOYEE_ID = #attributes.demand_empolyee_id# AND IS_MASTER = 1
    </cfquery>
    <cf_workcube_process 
        is_upd='1' 
        old_process_line='0'
        process_stage='#attributes.process_stage#' 
        record_member='#session.ep.userid#' 
        record_date='#now()#'
        action_table='EZGI_SHIPPING_DEMAND'
        action_column='SHIPPING_DEMAND_ID'
        action_id='#MAX_ID.IDENTITYCOL#'
        action_page='#request.self#?fuseaction=sales.list_ezgi_shipping_demand&event=upd'
        warning_description = 'Sevk Aşama Talebi'>
  	<cfquery name="upd_page_warning" datasource="#dsn#">
    	UPDATE
    		PAGE_WARNINGS
       	SET
        	POSITION_CODE = #get_position.POSITION_ID#
      	WHERE
        	ACTION_ID = #MAX_ID.IDENTITYCOL#
    </cfquery>
    <cflocation url="#request.self#?fuseaction=sales.popup_list_ezgi_shipping_ship_demand&order_row_id=#attributes.order_row_id#" addtoken="No">
</cfif>
<cfquery name="Get_Order_Row" datasource="#dsn3#">
	SELECT 
    	ORR1.STOCK_ID,
        ORR1.QUANTITY, 
        ISNULL(SP1.SPECT_MAIN_ID, 0) AS SPECT_MAIN_ID
	FROM     
    	ORDER_ROW AS ORR1 WITH (NOLOCK) LEFT OUTER JOIN
        SPECTS AS SP1 WITH (NOLOCK) ON ORR1.SPECT_VAR_ID = SP1.SPECT_VAR_ID
	WHERE  
    	ORR1.ORDER_ROW_ID = #attributes.order_row_id# AND 
        ORR1.ORDER_ROW_CURRENCY = - 1
</cfquery>
<cfquery name="get_order_demand_control" datasource="#dsn3#"> <!---Talep Edilen Sipariş Satırına Rezerve edilenleri çekiyorum--->
	SELECT 
    	ESD.ORDER_ROW_ID, 
    	ESD.DEMAND_ORDER_ROW_ID, 
        ESD.EMPLOYEE_ID, 
        ESD.DEMAND_EMPLOYEE_ID, 
        ESD.DEMAND_STATUS_ID, 
        ESD.START_DATE, 
        ESD.FINISH_DATE,
        ORR1.QUANTITY
	FROM     
    	EZGI_SHIPPING_DEMAND AS ESD INNER JOIN
        ORDER_ROW AS ORR ON ESD.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
        ORDER_ROW AS ORR1 ON ESD.DEMAND_ORDER_ROW_ID = ORR1.ORDER_ROW_ID INNER JOIN
        ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN
        ORDERS AS O1 ON ORR1.ORDER_ID = O1.ORDER_ID
	WHERE  
    	ESD.ORDER_ROW_ID = #attributes.order_row_id# AND
        ORR1.ORDER_ROW_CURRENCY = - 6 AND
        ESD.DEMAND_STATUS_ID = 1 <!---Talep Onay Bekliyor--->
</cfquery>
<cfset control_order_id_list = ValueList(get_order_demand_control.DEMAND_ORDER_ROW_ID)>
<cfif Get_Order_Row.recordcount>
	<cfquery name="get_order_demand_control_group" dbtype="query">
    	SELECT
        	SUM(QUANTITY) AS TOTAL
      	FROM
        	get_order_demand_control
    </cfquery>
	<cfquery name="Get_Order_Row_2" datasource="#dsn3#">
		SELECT 
        	ES.DELIVER_PAPER_NO,
        	O.COMPANY_ID, 
            O.CONSUMER_ID,
        	ORR1.PRODUCT_NAME, 
            ORR1.STOCK_ID, 
            ISNULL(SP1.SPECT_MAIN_ID, 0) AS SPECT_MAIN_ID, 
            O.ORDER_NUMBER, 
            O.ORDER_DATE, 
            O.ORDER_STAGE, 
            ORR1.ORDER_ROW_ID, 
            ORR1.ORDER_ID,
            ORR1.QUANTITY, 
            O.DELIVERDATE,
            O.ORDER_EMPLOYEE_ID
		FROM     
        	EZGI_SHIP_RESULT AS ES WITH (NOLOCK) INNER JOIN
          	EZGI_SHIP_RESULT_ROW AS ESR WITH (NOLOCK) ON ES.SHIP_RESULT_ID = ESR.SHIP_RESULT_ID RIGHT OUTER JOIN
        	ORDER_ROW AS ORR1 WITH (NOLOCK) INNER JOIN
          	ORDERS AS O WITH (NOLOCK) ON ORR1.ORDER_ID = O.ORDER_ID ON ESR.ORDER_ROW_ID = ORR1.ORDER_ROW_ID LEFT OUTER JOIN
          	SPECTS AS SP1 WITH (NOLOCK) ON ORR1.SPECT_VAR_ID = SP1.SPECT_VAR_ID
		WHERE  
        	ORR1.ORDER_ROW_CURRENCY = - 6 AND 
            ORR1.STOCK_ID = #Get_Order_Row.STOCK_ID# AND 
            O.PURCHASE_SALES = 1
            <cfif Get_Order_Row.SPECT_MAIN_ID gt 0>
            	AND SP1.SPECT_MAIN_ID = #Get_Order_Row.SPECT_MAIN_ID#
            </cfif>
            <cfif get_order_demand_control.recordcount and get_order_demand_control_group.TOTAL gte Get_Order_Row.QUANTITY>
            	AND ORR1.ORDER_ROW_ID IN (#control_order_id_list#)
            </cfif>
      	ORDER BY
        	O.DELIVERDATE desc
  	</cfquery>
   	<cfif Get_Order_Row_2.recordcount>	
    	<cfset order_stage_id_list = ValueList(Get_Order_Row_2.ORDER_STAGE)>
        <cfset demand_order_row_id_list = ValueList(Get_Order_Row_2.ORDER_ROW_ID)>
        <cfquery name="get_order_demand" datasource="#dsn3#">
        	SELECT 
            	ESD.SHIPPING_DEMAND_ID, 
                ESD.ORDER_ROW_ID, 
                ESD.DEMAND_ORDER_ROW_ID, 
                ESD.EMPLOYEE_ID, 
                ESD.DEMAND_EMPLOYEE_ID, 
                ESD.DEMAND_STATUS_ID, 
                ESD.START_DATE, 
                ESD.FINISH_DATE, 
                ORR1.ORDER_ROW_CURRENCY
			FROM     
            	EZGI_SHIPPING_DEMAND AS ESD INNER JOIN
                ORDER_ROW AS ORR ON ESD.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                ORDER_ROW AS ORR1 ON ESD.DEMAND_ORDER_ROW_ID = ORR1.ORDER_ROW_ID INNER JOIN
                ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN
                ORDERS AS O1 ON ORR1.ORDER_ID = O1.ORDER_ID
			WHERE  
            	ESD.DEMAND_ORDER_ROW_ID IN (#demand_order_row_id_list#) AND 
                ORR1.ORDER_ROW_CURRENCY = - 6
		</cfquery>
        <cfloop query="get_order_demand">
			<cfset demand_id_list = ListAppend(demand_id_list, DEMAND_ORDER_ROW_ID)>
		</cfloop>
        
    	<cfquery name="get_stage" datasource="#dsn#">
        	SELECT 
            	PTR.PROCESS_ROW_ID, 
                PTR.STAGE
			FROM     
            	PROCESS_TYPE AS PT WITH (NOLOCK) INNER JOIN
                PROCESS_TYPE_ROWS AS PTR WITH (NOLOCK) ON PT.PROCESS_ID = PTR.PROCESS_ID
			WHERE  
            	PTR.PROCESS_ROW_ID IN (#order_stage_id_list#)
        </cfquery>
        <cfoutput query="get_stage">
        	<cfset 'STAGE_#PROCESS_ROW_ID#' = STAGE>
        </cfoutput>
    </cfif>
</cfif>
<cfsavecontent variable="ezgi_header">Sevk Aşamasındaki Siparişler</cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#ezgi_header#">
    	<cfform name="add_demand" id="add_demand" method="post" action="#request.self#?fuseaction=sales.popup_list_ezgi_shipping_ship_demand&order_row_id=#attributes.order_row_id#">	
    		<cf_basket_form id="form_add_demand">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                       		<cf_box_elements>
                            	<div class="form-group" id="form_ul_keyword">
                                	<cf_workcube_process is_upd='0' is_detail='0'>
                				</div>
                          	</cf_box_elements>
                  	</div>
              	</div>
       		</cf_basket_form>
            <cf_basket id="form_add_demand_basket">
            	<cf_grid_list sort="0">
                	<thead>
                        <tr>
                        	<th style="width:25px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        	<th style="width:65px"><cf_get_lang dictionary_id='58211.Sipariş No'></th>
                            <th style="width:65px"><cf_get_lang dictionary_id='29501.Sipariş Tarihi'></th>
                            <th style="width:65px"><cf_get_lang dictionary_id='60609.Termin Tarihi'></th>
                            <th><cf_get_lang dictionary_id='57457.Müşteri'></th>
                            <th style="width:150px"><cf_get_lang dictionary_id='58795.Müşteri Temsilcisi'></th>
                            <th style="width:50px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            <th style="width:80px"><cf_get_lang dictionary_id='58859.Süreç'></th>
                            <th style="width:60px"><cf_get_lang dictionary_id='382.Sevk Plan No'></th>
                            <th style="width:25px"></th>
                     	</tr>
                  	</thead>
                     <tbody id="table_1">
						<cfif Get_Order_Row.recordcount and Get_Order_Row_2.recordcount>
                            <cfoutput query="Get_Order_Row_2">
                            	<tr>
                                    <td style="height:30px; text-align:right">#currentrow#</td>
                                    <td style="text-align:center" nowrap>#ORDER_NUMBER#</td>
                                    <td style="text-align:center">#DateFormat(ORDER_DATE,dateformat_style)#</td>
                                    <td style="text-align:center">#DateFormat(DELIVERDATE,dateformat_style)#</td>
                                    <td style="text-align:left">
                                    	<cfif Len(COMPANY_ID)>
                                        	#get_par_info(COMPANY_ID,1,1,0)# Sirket Ünvani
                                        <cfelseif Len(CONSUMER_ID)>
                                        	#get_cons_info(CONSUMER_ID,0,0)#
                                        </cfif>
                                    </td>
                                    <td style="text-align:left">#get_emp_info(ORDER_EMPLOYEE_ID,0,0)#</td>
                                    <td style="text-align:right">#AmountFormat(QUANTITY)#</td>
                                    <td style="text-align:left"><cfif isdefined('STAGE_#ORDER_STAGE#')>#Evaluate('STAGE_#ORDER_STAGE#')#</cfif></td>
                                    <td style="text-align:center" nowrap>#DELIVER_PAPER_NO#</td>
                                    <td style="text-align:center">
                                    	<cfif ListFind(control_order_id_list,Get_Order_Row_2.ORDER_ROW_ID)>
                                        	<a href="javascript://" onClick="sil(#attributes.ORDER_ROW_ID#,#ORDER_ROW_ID#,#session.ep.userid#,#ORDER_EMPLOYEE_ID#);">
                                        		<img src="images/delete_list.gif">
                                          	</a>
                                       	<cfelse>
                                        	<cfif ListFind(demand_id_list,Get_Order_Row_2.ORDER_ROW_ID)>
                                            	<img src="images/lock.gif">
                                            <cfelse>
                                                <a href="javascript://" onClick="ekle(#attributes.ORDER_ROW_ID#,#ORDER_ROW_ID#,#session.ep.userid#,#ORDER_EMPLOYEE_ID#);">
                                                    <img src="/images/plus_list.gif" align="absmiddle" border="0">
                                                </a>
                                            </cfif>	
                                        </cfif>
                                    </td>
                              	</tr>
                            </cfoutput>
                        </cfif>
                    </tbody>
               	</cf_grid_list>   
          	</cf_basket> 
     	</cfform>
	</cf_box>
</div>                        
<script language="javascript">
	function sil(order_row_id,demand_order_row_id,empolyee_id,demand_empolyee_id)
	{
		if(process_cat_control())
		{
			sor = confirm('Talebi Siliyorum ?');
			if(sor ==true)
			{
				document.getElementById("add_demand").action = "<cfoutput>#request.self#?fuseaction=sales.popup_list_ezgi_shipping_ship_demand&order_row_id=#attributes.order_row_id#</cfoutput>&sil=1&demand_order_row_id="+demand_order_row_id+"&empolyee_id="+empolyee_id+"&demand_empolyee_id="+demand_empolyee_id;
				document.getElementById("add_demand").submit();
			}
			else
				return false;
		}
		else
			return false;
	}
	function ekle(order_row_id,demand_order_row_id,empolyee_id,demand_empolyee_id)
	{
		if(process_cat_control())
		{
			sor = confirm('İlgili Müşteri Temsilcisinden Talep Ediyorum ?');
			if(sor ==true)
			{
				document.getElementById("add_demand").action = "<cfoutput>#request.self#?fuseaction=sales.popup_list_ezgi_shipping_ship_demand&order_row_id=#attributes.order_row_id#</cfoutput>&ekle=1&demand_order_row_id="+demand_order_row_id+"&empolyee_id="+empolyee_id+"&demand_empolyee_id="+demand_empolyee_id;
				document.getElementById("add_demand").submit();
			}
			else
				return false;
		}
		else
			return false;
	}
	function control()
	{
		if(process_cat_control())
			return true;
		else
			return false;
	}
</script>