<!---
    File: form_shipping_control_fis.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfif attributes.is_type eq 1>
    <cfquery name="GET_SHIP_ROW" datasource="#dsn3#">
        SELECT     
            STOCK_CODE, 
            STOCK_CODE_2, 
            PRODUCT_ID, 
            PRODUCT_NAME, 
            UNIT, 
            AMOUNT, 
            SHIPPING_ID,
            SHIPPING_ROW_ID, 
            STOCK_ID,
            PRODUCT_NAME2,
           	CASE
            	WHEN 
                	PRODUCT_TREE_AMOUNT IS NOT NULL
              	THEN
                	PRODUCT_TREE_AMOUNT
             	ELSE             
                    ISNULL(
                            (
                            SELECT        
                            	SUM(EPS.PAKET_SAYISI) AS PAKET_SAYISI
							FROM           
                            	EZGI_PAKET_SAYISI AS EPS INNER JOIN
                        		SPECTS AS S ON EPS.MODUL_SPECT_ID = S.SPECT_MAIN_ID
							WHERE        
                            	S.SPECT_VAR_ID = TBL.SPECT_VAR_ID
                            ) * AMOUNT
                    	, 0)
           	END 
                AS PAKET_SAYISI, 
            ISNULL(
                    (
                    SELECT     
                        SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                    FROM         
                        EZGI_SHIPPING_PACKAGE_LIST
                    WHERE     
                        SHIPPING_ROW_ID = TBL.SHIPPING_ROW_ID AND 
                        SHIPPING_ID = TBL.SHIPPING_ID AND 
                        TYPE = 1
                    )
            , 0) AS CONTROL_AMOUNT,
            LOT_NO
        FROM         
            (
            SELECT     
            	S.STOCK_CODE, 
                S.STOCK_CODE_2, 
                S.PRODUCT_ID, 
                S.PRODUCT_NAME, 
                ORR.UNIT, 
                ORR.QUANTITY AS AMOUNT, 
                ORR.SPECT_VAR_ID,
                ESRR.SHIP_RESULT_ID AS SHIPPING_ID, 
                ESRR.SHIP_RESULT_ROW_ID AS SHIPPING_ROW_ID,
             	S.STOCK_ID,
                S.PRODUCT_TREE_AMOUNT,
                ORR.PRODUCT_NAME2,
                (
                    SELECT 
                        TOP(1) PO.LOT_NO
                    FROM      
                        PRODUCTION_ORDERS_ROW AS PORR INNER JOIN
                        PRODUCTION_ORDERS AS PO ON PORR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
                    WHERE     
                        PORR.TYPE = 1 AND 
                        PORR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
                ) AS LOT_NO
			FROM         
            	ORDER_ROW AS ORR INNER JOIN
                EZGI_SHIP_RESULT_ROW AS ESRR ON ORR.ORDER_ROW_ID = ESRR.ORDER_ROW_ID INNER JOIN
                STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID
			WHERE     
            	ESRR.SHIP_RESULT_ID = #attributes.ship_id# AND
                ORR.ORDER_ROW_CURRENCY = -6 AND
                ISNULL(S.IS_PROTOTYPE,0) = 1
            ) AS TBL  
     	UNION ALL
         SELECT     
            STOCK_CODE, 
            STOCK_CODE_2, 
            PRODUCT_ID, 
            PRODUCT_NAME, 
            UNIT, 
            AMOUNT, 
            SHIPPING_ID,
            SHIPPING_ROW_ID, 
            STOCK_ID,
            PRODUCT_NAME2,
           	ISNULL(
           		(
                    SELECT     
                        SUM(PAKET_SAYISI) AS PAKET_SAYISI
                    FROM         
                        EZGI_PAKET_SAYISI
                    WHERE     
                        MODUL_ID = TBL.STOCK_ID
            	) * AMOUNT
         	, 0) AS PAKET_SAYISI, 
            ISNULL(
                    (
                    SELECT     
                        SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                    FROM         
                        EZGI_SHIPPING_PACKAGE_LIST
                    WHERE     
                        SHIPPING_ROW_ID = TBL.SHIPPING_ROW_ID AND 




                        SHIPPING_ID = TBL.SHIPPING_ID AND 
                        TYPE = 1
                    )
            , 0) AS CONTROL_AMOUNT,
            LOT_NO
        FROM         
            (
            SELECT     
            	S.STOCK_CODE, 
                S.STOCK_CODE_2, 
                S.PRODUCT_ID, 
                S.PRODUCT_NAME, 
                ORR.UNIT, 
                ORR.QUANTITY AS AMOUNT, 
                ESRR.SHIP_RESULT_ID AS SHIPPING_ID, 
                ESRR.SHIP_RESULT_ROW_ID AS SHIPPING_ROW_ID,
             	S.STOCK_ID,
                S.PRODUCT_TREE_AMOUNT,
                ORR.PRODUCT_NAME2,
                (
                    SELECT 
                        TOP (1) PO.LOT_NO
                    FROM      
                        PRODUCTION_ORDERS_ROW AS PORR INNER JOIN
                        PRODUCTION_ORDERS AS PO ON PORR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
                    WHERE     
                        PORR.TYPE = 1 AND 
                        PORR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
                ) AS LOT_NO
			FROM         
            	ORDER_ROW AS ORR INNER JOIN
                EZGI_SHIP_RESULT_ROW AS ESRR ON ORR.ORDER_ROW_ID = ESRR.ORDER_ROW_ID INNER JOIN
                STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID
			WHERE     
            	ESRR.SHIP_RESULT_ID = #attributes.ship_id# AND
                ORR.ORDER_ROW_CURRENCY = -6 AND
                ISNULL(S.IS_PROTOTYPE,0) = 0
            ) AS TBL  
     	ORDER BY
        	SHIPPING_ROW_ID                   
    </cfquery>
<cfelse>
    <cfquery name="GET_SHIP_ROW" datasource="#dsn3#">
    	SELECT     
            STOCK_CODE, 
            STOCK_CODE_2, 
            PRODUCT_ID, 
            PRODUCT_NAME, 
            UNIT, 
            AMOUNT, 
            SHIPPING_ID,
            SHIPPING_ROW_ID, 
            STOCK_ID,
            PRODUCT_NAME2,
           	CASE
            	WHEN 
                	PRODUCT_TREE_AMOUNT IS NOT NULL
              	THEN
                	PRODUCT_TREE_AMOUNT
             	ELSE             
                    ISNULL(
                            (
                            SELECT        
                            	SUM(EPS.PAKET_SAYISI) AS PAKET_SAYISI
							FROM           
                            	EZGI_PAKET_SAYISI AS EPS INNER JOIN
                        		SPECTS AS S ON EPS.MODUL_SPECT_ID = S.SPECT_MAIN_ID
							WHERE        
                            	S.SPECT_VAR_ID = TBL.SPECT_VAR_ID
                            ) * AMOUNT
                    	, 0)
           	END 
                AS PAKET_SAYISI, 
            ISNULL(
                    (
                    SELECT     
                        SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                    FROM         
                        EZGI_SHIPPING_PACKAGE_LIST
                    WHERE     
                        SHIPPING_ROW_ID = TBL.SHIPPING_ROW_ID AND 
                        SHIPPING_ID = TBL.SHIPPING_ID AND 
                        TYPE = 2
                    )
            , 0) AS CONTROL_AMOUNT,
            LOT_NO
        FROM         
            (
            SELECT     
            	S.STOCK_CODE, 
                S.STOCK_CODE_2, 
                S.PRODUCT_ID, 
                S.PRODUCT_NAME, 
                ORR.UNIT, 
                ORR.QUANTITY AS AMOUNT, 
                ORR.SPECT_VAR_ID,
                ESRR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIPPING_ID, 
                ESRR.SHIP_RESULT_INTERNALDEMAND_ROW_ID AS SHIPPING_ROW_ID,
             	S.STOCK_ID,
                S.PRODUCT_TREE_AMOUNT,
                ORR.PRODUCT_NAME2,
                (
                    SELECT 
                        TOP(1) PO.LOT_NO
                    FROM      
                        PRODUCTION_ORDERS_ROW AS PORR INNER JOIN
                        PRODUCTION_ORDERS AS PO ON PORR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
                    WHERE     
                        PORR.TYPE = 1 AND 
                        PORR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
                ) AS LOT_NO
			FROM         
            	ORDER_ROW AS ORR INNER JOIN
                EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ORR.ORDER_ROW_ID = ESRR.ORDER_ROW_ID INNER JOIN
                STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID
			WHERE     
            	ESRR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND
                ORR.ORDER_ROW_CURRENCY = -6 AND
                ISNULL(S.IS_PROTOTYPE,0) = 1
            ) AS TBL  
     	UNION ALL
         SELECT     
            STOCK_CODE, 
            STOCK_CODE_2, 
            PRODUCT_ID, 
            PRODUCT_NAME, 
            UNIT, 
            AMOUNT, 
            SHIPPING_ID,
            SHIPPING_ROW_ID, 
            STOCK_ID,
            PRODUCT_NAME2,
           	ISNULL(
           		(
                    SELECT     
                        SUM(PAKET_SAYISI) AS PAKET_SAYISI
                    FROM         
                        EZGI_PAKET_SAYISI
                    WHERE     
                        MODUL_ID = TBL.STOCK_ID
            	) * AMOUNT
         	, 0) AS PAKET_SAYISI, 
            ISNULL(
                    (
                    SELECT     
                        SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                    FROM         
                        EZGI_SHIPPING_PACKAGE_LIST
                    WHERE     
                        SHIPPING_ROW_ID = TBL.SHIPPING_ROW_ID AND 


                        SHIPPING_ID = TBL.SHIPPING_ID AND 
                        TYPE = 2
                    )
            , 0) AS CONTROL_AMOUNT,
            LOT_NO
        FROM         
            (
            SELECT     
            	S.STOCK_CODE, 
                S.STOCK_CODE_2, 
                S.PRODUCT_ID, 
                S.PRODUCT_NAME, 
                ORR.UNIT, 
                ORR.QUANTITY AS AMOUNT, 
                ESRR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIPPING_ID, 
                ESRR.SHIP_RESULT_INTERNALDEMAND_ROW_ID AS SHIPPING_ROW_ID,
             	S.STOCK_ID,
                S.PRODUCT_TREE_AMOUNT,
                ORR.PRODUCT_NAME2,
                (
                    SELECT 
                        TOP (1) PO.LOT_NO
                    FROM      
                        PRODUCTION_ORDERS_ROW AS PORR INNER JOIN
                        PRODUCTION_ORDERS AS PO ON PORR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
                    WHERE     
                        PORR.TYPE = 1 AND 
                        PORR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
                ) AS LOT_NO
			FROM         
            	ORDER_ROW AS ORR INNER JOIN
                EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ORR.ORDER_ROW_ID = ESRR.ORDER_ROW_ID INNER JOIN
                STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID
			WHERE     
            	ESRR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND
                ORR.ORDER_ROW_CURRENCY = -6 AND
                ISNULL(S.IS_PROTOTYPE,0) = 0
            ) AS TBL  
     	ORDER BY
        	SHIPPING_ROW_ID 
    </cfquery>
</cfif>    
<cfquery name="get_url" datasource="#dsn2#">
	SELECT
		SHIP_NUMBER,
    	DELIVER_STORE_ID,
        LOCATION
    FROM
    	SHIP
    WHERE
    	(SHIP_ID = #ship_id#)
</cfquery>
<cfset adres="#listgetat(attributes.fuseaction,1,'.')#.list_shipping&department_id=#department_id#&date1=#date1#&date2=#date2#&is_form_submitted=1&page=#page#&kontrol_status=#kontrol_status#">
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="add_fis" method="post" action="#request.self#?fuseaction=#adres#">
        	<cf_box_search>
                <div class="col col-12">
                	<div class="col col-10"></div>     	
                	<div class="col col-2">
                   	 	<input type="submit" value="<cf_get_lang dictionary_id='57432.Geri'>" name="1">
               	 	</div>
           	 </cf_box_search>
       	</cfform>
  	</cf_box>
    <cfsavecontent variable="title"><cfif attributes.is_type eq 1><b><cf_get_lang dictionary_id='382.Sevk Plan No'> :</b><cfelse><b><cf_get_lang dictionary_id='375.Sevk Talep No'> :</b></cfif><cfoutput>#attributes.DELIVER_PAPER_NO#</cfoutput></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
      	<cf_grid_list>
        	<thead>
              	<tr>
                 	<th style="width:100%"><cf_get_lang dictionary_id='45693.Stok Adı'></th>
                    <th style="width:15%"><cf_get_lang dictionary_id='39277.Paket Sayısı'></th>
                    <!-- sil -->
    				<th style="width:10%">&nbsp;&nbsp;&nbsp;</th>
                    <!-- sil -->
               	</tr>
          	</thead>
             <tbody>
             	<cfif GET_SHIP_ROW.recordcount>
             		<cfoutput query="GET_SHIP_ROW">
                    	<tr oncontextmenu="javascript:wrk_right_menu();return false;"> 
                            <td style="height:30px" class="form-group">
                            	<a href="#request.self#?fuseaction=pda.form_shipping_control_stock&ship_id=#ship_id#&f_stock_id=#GET_SHIP_ROW.stock_id#&department_id=#department_id#&date1=#date1#&date2=#date2#&page=#page#&kontrol_status=#kontrol_status#&product_name=#PRODUCT_NAME#&is_type=#attributes.is_type#&deliver_paper_no=#attributes.DELIVER_PAPER_NO#&shipping_row_id=#SHIPPING_ROW_ID#">
                                    #PRODUCT_NAME#
                                    <cfif LOT_NO neq 0 and len(LOT_NO)>
                                        - #LOT_NO#
                                    </cfif>
                                    <cfif len(PRODUCT_NAME2) and PRODUCT_NAME2 neq 0>
                                        <br>
                                        #PRODUCT_NAME2#
                                    </cfif>
                                </a>
                            </td>
                            <td style="text-align:center;color:FF0000;"><strong>#PAKET_SAYISI#</strong></td>
                            <!-- sil -->
                            <td style="text-align:center">
                             	<cfif PAKET_SAYISI eq 0>
                                	<img src="/images/plus_ques.gif" border="0" title="<cf_get_lang dictionary_id='29975.Barkod Yok'>.">
                             	<cfelseif PAKET_SAYISI - CONTROL_AMOUNT eq 0>
                                	<img src="/images/c_ok.gif" border="0" title="<cf_get_lang dictionary_id='330.Kontrol Edildi'>.">
                             	<cfelseif CONTROL_AMOUNT eq 0>
                                	<img src="/images/caution_small.gif" border="0" title="<cf_get_lang dictionary_id='331.Kontrol Edilmedi'>.">
                             	<cfelseif PAKET_SAYISI gt CONTROL_AMOUNT>
                                	<img src="/images/warning.gif" border="0" title="<cf_get_lang dictionary_id='332.Kontrol Eksik'>.">   
                             	</cfif>
                            </td> 
                            <!-- sil --> 
                       	</tr>     
                    </cfoutput>
               	</cfif>
             </tbody>
       	</cf_grid_list>
  	</cf_box>    
</div>

<script type="text/javascript">
	$('#keyword').focus();
	function input_control()
	{	
		return true;
	}
</script>