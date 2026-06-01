<!---
    File: upd_ezgi_operation_group_insert.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfquery name="add_trace" datasource="#dsn3#">
 	INSERT INTO 
    	EZGI_PRODUCTION_ORDERS_TRACE
      	(
          	TRACE_NO, 
          	LOT_NO, 
          	AMOUNT, 
          	RECORD_ID, 
    		RECORD_IP,
          	RECORD_DATE
      	)
	VALUES 
      	(
         	'T#GET_ORDER.LOT_NO#_#trace_number#',
          	'#GET_ORDER.LOT_NO#',
           	#trace_amount_value#,
          	#session.ep.userid#,
           	'#cgi.remote_addr#',
			#now()#
 		)
</cfquery>
