<!---
    File: add_ezgi_private_spect_main.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfset wrk_id = "#dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmss')#_#session.ep.userid#_#Evaluate('attributes.STOCK_ID_#i#')#_#round(rand()*100)#_2">
<cfif not isdefined('attributes.STOCK_ID_#i#') or not len(Evaluate('attributes.STOCK_ID_#i#'))>
	<cfif ListGetAt(i,1,'_') eq 1> <!---Parça İse--->
        <cfif PIECE_TYPE eq 1>
        	<cfset 'attributes.STOCK_ID_#i#' = get_defaults.PROTOTIP_PIECE_1_STOCK_ID> 
      	<cfelseif PIECE_TYPE eq 2>
        	<cfset 'attributes.STOCK_ID_#i#' = get_defaults.PROTOTIP_PIECE_2_STOCK_ID> 
        <cfelseif PIECE_TYPE eq 3>
        	<cfset 'attributes.STOCK_ID_#i#' = get_defaults.PROTOTIP_PIECE_3_STOCK_ID> 
        </cfif>             
 	<cfelseif ListGetAt(i,1,'_') eq 2> <!---Paket İse--->
     	<cfset 'attributes.STOCK_ID_#i#' = get_defaults.PROTOTIP_PACKAGE_STOCK_ID>  
  	<cfelseif ListGetAt(i,1,'_') eq 3> <!---Modül İse--->
      	<cfabort>             
  	</cfif>
</cfif>
<cfquery name="get_product_id" datasource="#dsn3#">
	SELECT PRODUCT_ID FROM #dsn1_alias#.STOCKS WITH (NOLOCK) WHERE STOCK_ID = #Evaluate('attributes.STOCK_ID_#i#')#
</cfquery>

<cfquery name="add_spect_main" datasource="#dsn3#">
	INSERT INTO 
    	SPECT_MAIN
     	(
            WRK_ID, 
            SPECT_MAIN_NAME, 
            SPECT_TYPE, 
            DETAIL, 
            PRODUCT_ID, 
            STOCK_ID, 
            IS_TREE, 
            SPECT_STATUS, 
            FUSEACTION, 
            IS_LIMITED_STOCK, 
            RECORD_EMP, 
            RECORD_IP, 
            RECORD_DATE
      	)
	VALUES        
    	(
            '#wrk_id#',
            '#urun_adi#',
            1,
            NULL,
            #get_product_id.product_id#,
            #Evaluate('attributes.STOCK_ID_#i#')#,
            0,
            1,
            'prod.emptypopup_cnt_ezgi_import_private_creative_workcube',
            0,
            #session.ep.userid#,
            '#cgi.remote_addr#',
        	#now()#
        )
</cfquery>
<cfquery name="get_max" datasource="#dsn3#">
	SELECT MAX(SPECT_MAIN_ID) AS SPECT_MAIN_ID FROM SPECT_MAIN WITH (NOLOCK)
</cfquery>
<cfquery name="add_spect_var" datasource="#dsn3#">
	INSERT INTO 
    	SPECTS
    	(
        	WRK_ID, 
            SPECT_VAR_NAME, 
            SPECT_TYPE, 
            PRODUCT_ID, 
            STOCK_ID, 
            TOTAL_AMOUNT, 
            OTHER_MONEY_CURRENCY, 
            OTHER_TOTAL_AMOUNT, 
            IS_TREE, 
            PRODUCT_AMOUNT, 
         	PRODUCT_AMOUNT_CURRENCY, 
            SPECT_MAIN_ID, 
            MARJ_TOTAL_AMOUNT, 
            MARJ_OTHER_TOTAL_AMOUNT, 
            MARJ_AMOUNT, 
            MARJ_PERCENT, 
            IS_LIMITED_STOCK, 
            RECORD_EMP, 
            RECORD_IP, 
         	RECORD_DATE
      	)
	VALUES        
    	(
            '#wrk_id#',
            '#urun_adi#',
            1,
            #get_product_id.product_id#,
            #Evaluate('attributes.STOCK_ID_#i#')#,
            0,
            '#session.ep.money#',
            0,
            0,
            0,
            '#session.ep.money#',
            #GET_MAX.SPECT_MAIN_ID#,
           	0,
            0,
            0,
            0,
            0,
            #session.ep.userid#,
            '#cgi.remote_addr#',
        	#now()#
        )
</cfquery>
<cfquery name="get_spect_var_max" datasource="#dsn3#">
	SELECT MAX(SPECT_VAR_ID) AS SPECT_VAR_ID FROM SPECTS WITH (NOLOCK)
</cfquery>