<!---
    File: ajax_ambar_fis_6.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/03/2025
    Description: Sipariş Bazlı Ambar Fişi Sipariş Kontrol Ajax
	---> 

<cfif isdefined('attributes.order_id')>
	<cfquery name="get_period_id" datasource="#dsn#">
    	SELECT TOP(1)       
        	PERIOD_YEAR
		FROM            
        	SETUP_PERIOD
		WHERE        
        	OUR_COMPANY_ID = #session.ep.company_id# AND 
            PERIOD_YEAR < #session.ep.period_year#
        ORDER BY
        	PERIOD_YEAR desc
	</cfquery>
    <cfset last_year = session.ep.period_year -1> 
	<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
    	SELECT
        	SUM(PAKET_SAYISI) AS PAKETSAYISI,
         	ORDER_NUMBER, 
            ORDER_ROW_ID,
            QUANTITY,
         	STOCK_ID, 
         	PRODUCT_NAME, 
         	SPECT_MAIN_ID,
          	MODUL_PRODUCT_ID,
          	MODUL_PRODUCT_NAME,
         	BARCOD,
            ISNULL((
            		SELECT 
                  		SUM(CONTROL_AMOUNT) CONTROL_AMOUNT
                   	FROM
                     	( 
                       	SELECT        
                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                        FROM   
                                   
                            #dsn2_alias#.STOCK_FIS AS SF INNER JOIN
                            #dsn2_alias#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                            SPECTS AS SP ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                            STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                        WHERE        
                            SF.FIS_TYPE = 113 AND 
                            SF.REF_NO = TBL.ORDER_NUMBER AND 
                            SFR.STOCK_ID = TBL.STOCK_ID AND
                            ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                            ISNULL(S.IS_PROTOTYPE,0) = 1
                       		<!---<cfif get_period_id.recordcount>
                            	UNION ALL
                            	SELECT        
                                    SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                                FROM   
                                           
                                    #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS AS SF INNER JOIN
                                    #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                                    SPECTS AS SP ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                                    STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                                WHERE        
                                    SF.FIS_TYPE = 113 AND 
                                    SF.REF_NO = TBL.ORDER_NUMBER AND 
                                    SFR.STOCK_ID = TBL.STOCK_ID AND
                                    ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                                    ISNULL(S.IS_PROTOTYPE,0) = 1
                            </cfif>--->
                        UNION ALL
                        SELECT        
                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                        FROM   
                            #dsn2_alias#.STOCK_FIS AS SF INNER JOIN
                            #dsn2_alias#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                            STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                        WHERE        
                            SF.FIS_TYPE = 113 AND 
                            SF.REF_NO = TBL.ORDER_NUMBER AND 
                            SFR.STOCK_ID = TBL.STOCK_ID AND
                            ISNULL(S.IS_PROTOTYPE,0) = 0
                            <!---<cfif get_period_id.recordcount>
                            	UNION ALL
                                SELECT        
                                    SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                                FROM   
                                    #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS AS SF INNER JOIN
                                    #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                                    STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                                WHERE        
                                    SF.FIS_TYPE = 113 AND 
                                    SF.REF_NO = TBL.ORDER_NUMBER AND 
                                    SFR.STOCK_ID = TBL.STOCK_ID AND
                                    ISNULL(S.IS_PROTOTYPE,0) = 0
                            </cfif>--->
                		) AS TBL_5
        	),0) AS CONTROL_AMOUNT
     	FROM
        	(
            SELECT 
            	SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI,
                ORR.ORDER_ROW_ID,
                ORR.QUANTITY, 
                O.ORDER_NUMBER, 
                EPS.PAKET_ID STOCK_ID,
                P1.PRODUCT_NAME, 
                P1.BARCOD, 
                EPS.RELATED_MAIN_SPECT_ID AS SPECT_MAIN_ID,
                P.PRODUCT_ID AS MODUL_PRODUCT_ID,
                P.PRODUCT_NAME AS MODUL_PRODUCT_NAME
			FROM     
            	(
                	SELECT 
                    	SM.SPECT_MAIN_ID AS MODUL_SPECT_ID, 
                        SM.STOCK_ID AS MODUL_ID, 
                        SMR.STOCK_ID AS PAKET_ID, 
                        S2.BARCOD, 
                        SMR.AMOUNT AS PAKET_SAYISI, 
                        SMR.RELATED_MAIN_SPECT_ID
                  	FROM      
                    	SPECT_MAIN AS SM INNER JOIN
                      	SPECT_MAIN_ROW AS SMR ON SM.SPECT_MAIN_ID = SMR.SPECT_MAIN_ID INNER JOIN
                      	STOCKS AS S ON SM.STOCK_ID = S.STOCK_ID INNER JOIN
                     	STOCKS AS S2 ON SMR.STOCK_ID = S2.STOCK_ID
                  	WHERE   
                    	ISNULL(S.IS_PROTOTYPE, 0) = 1 AND 
                        ISNULL(S.IS_KARMA, 0) = 0 AND 
                        S2.STOCK_CODE LIKE N'01.151.01.01%' AND 
                        S.PACKAGE_CONTROL_TYPE = 2
            	) AS EPS INNER JOIN
                ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                SPECTS AS SP WITH (NOLOCK) ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
                ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN
             	#dsn1_alias#.PRODUCT AS P WITH (NOLOCK) ON ORR.PRODUCT_ID = P.PRODUCT_ID ON EPS.MODUL_SPECT_ID = SP.SPECT_MAIN_ID INNER JOIN
             	#dsn1_alias#.PRODUCT AS P1 WITH (NOLOCK) INNER JOIN
           		#dsn1_alias#.STOCKS AS S WITH (NOLOCK) ON P1.PRODUCT_ID = S.PRODUCT_ID ON EPS.PAKET_ID = S.STOCK_ID
			WHERE  
            	ORR.ORDER_ID = #attributes.order_id# AND 
                ISNULL(P.IS_PROTOTYPE, 0) = 1
			GROUP BY 
            	O.ORDER_NUMBER, 
                P1.PRODUCT_NAME, 
                P1.BARCOD, 
                EPS.RELATED_MAIN_SPECT_ID, 
                EPS.PAKET_ID,
                ORR.ORDER_ROW_ID,
                ORR.QUANTITY,
                P.PRODUCT_ID,
                P.PRODUCT_NAME
                	
    		<!---SELECT 
            	SUM(ORR.QUANTITY*EPS.PAKET_SAYISI) AS PAKET_SAYISI,   
                ORR.ORDER_ROW_ID,
                ORR.QUANTITY,
            	O.ORDER_NUMBER, 
                EPS.PAKET_ID AS STOCK_ID, 
                P1.PRODUCT_NAME, 
              	P1.BARCOD,
                SP.SPECT_MAIN_ID,
             	P.PRODUCT_ID AS MODUL_PRODUCT_ID,
                P.PRODUCT_NAME AS MODUL_PRODUCT_NAME
			FROM            
            	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                SPECTS AS SP WITH (NOLOCK) ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
                ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN
                #dsn1_alias#.PRODUCT AS P WITH (NOLOCK) ON ORR.PRODUCT_ID = P.PRODUCT_ID INNER JOIN
              	EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID INNER JOIN
             	#dsn1_alias#.STOCKS AS S WITH (NOLOCK) ON EPS.PAKET_ID = S.STOCK_ID INNER JOIN
                #dsn1_alias#.PRODUCT AS P1 WITH (NOLOCK) ON S.PRODUCT_ID = P1.PRODUCT_ID
			WHERE        
            	ORR.ORDER_ID = #attributes.order_id# AND 
                ISNULL(P.IS_PROTOTYPE,0) = 1
          	GROUP BY
            	O.ORDER_NUMBER,
                ORR.ORDER_ROW_ID, 
                ORR.QUANTITY,
                EPS.PAKET_ID, 
                P1.PRODUCT_NAME, 
                P1.BARCOD,
                SP.SPECT_MAIN_ID,
                P.PRODUCT_ID,
                P.PRODUCT_NAME--->
			UNION ALL
			SELECT  
            	SUM(ORR.QUANTITY*EPS.PAKET_SAYISI) AS PAKET_SAYISI,  
                ORR.ORDER_ROW_ID,
                ORR.QUANTITY,  
            	O.ORDER_NUMBER, 
                EPS.PAKET_ID, 
                P1.PRODUCT_NAME, 
                P1.BARCOD,
                0 AS SPECT_MAIN_ID,
                P.PRODUCT_ID AS MODUL_PRODUCT_ID,
                P.PRODUCT_NAME AS MODUL_PRODUCT_NAME
			FROM            
            	#dsn1_alias#.STOCKS AS S WITH (NOLOCK) INNER JOIN
             	EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID INNER JOIN
                #dsn1_alias#.PRODUCT AS P1 WITH (NOLOCK) ON S.PRODUCT_ID = P1.PRODUCT_ID INNER JOIN
              	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN 
                ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN
            	#dsn1_alias#.PRODUCT AS P WITH (NOLOCK) ON ORR.PRODUCT_ID = P.PRODUCT_ID ON EPS.MODUL_ID = ORR.STOCK_ID
			WHERE        
            	ORR.ORDER_ID = #attributes.order_id# AND 
                ISNULL(P.IS_PROTOTYPE,0) = 0
          	GROUP BY
            	O.ORDER_NUMBER,
                ORR.ORDER_ROW_ID, 
                ORR.QUANTITY,
                EPS.PAKET_ID, 
                P1.PRODUCT_NAME,
                P1.BARCOD,
                P.PRODUCT_ID,
                P.PRODUCT_NAME
         	) AS TBL
      	GROUP BY
        	ORDER_NUMBER, 
           	ORDER_ROW_ID,
          	QUANTITY,
         	STOCK_ID, 
         	PRODUCT_NAME, 
         	SPECT_MAIN_ID,
            MODUL_PRODUCT_ID,
          	MODUL_PRODUCT_NAME,
          	BARCOD
      	order by
        	SPECT_MAIN_ID,
         	PRODUCT_NAME   	
    </cfquery>
    <cfquery name="get_order_row" dbtype="query">
        SELECT
            ORDER_NUMBER, 
            ORDER_ROW_ID,
            QUANTITY,
         	MODUL_PRODUCT_ID,
          	MODUL_PRODUCT_NAME, 
           	SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT,
            SUM(PAKETSAYISI) AS PAKETSAYISI
        FROM
            GET_SHIP_PACKAGE_LIST
        GROUP BY
 			ORDER_NUMBER, 
            ORDER_ROW_ID,
            QUANTITY,
         	MODUL_PRODUCT_ID,
          	MODUL_PRODUCT_NAME
    </cfquery>
    <cf_basket id="report_side">
        <cf_grid_list sort="0">
                <thead>
                    <tr>
                        <th style="text-align:center; height:20px; width:25px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                   		<th style="width:30px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                        <th style="width:30px"><cf_get_lang dictionary_id='100.Paket'></th>
                        <th style="width:30px"><cf_get_lang dictionary_id='45358.Kontrol'></th>
                    </tr>
                </thead>
                
                <tbody>
                    <cfif get_order_row.recordcount>
                        <cfoutput query="get_order_row">
                        	<input type="hidden" name="row_display_#order_row_id#" id="row_display_#order_row_id#" value="1">
                            <tr onclick="seviyelendir(#order_row_id#);" style="font-weight:bold">
                                <td style="text-align:right; height:25px">#Currentrow#</td>
                                <td style="text-align:left" nowrap="nowrap">#MODUL_PRODUCT_NAME#</td>
                                <td style="text-align:right">#QUANTITY#</td>
                                <td style="text-align:right">#PAKETSAYISI#</td>
                                <td style="text-align:right">#CONTROL_AMOUNT#</td>
                            </tr>
                            <cfquery name="get_sub_order_row" dbtype="query">
                            	SELECT
                                    ORDER_NUMBER, 
                                    ORDER_ROW_ID,
                                    SPECT_MAIN_ID,
                                    STOCK_ID, 
         							PRODUCT_NAME,
									CONTROL_AMOUNT,
                              		PAKETSAYISI
                                FROM
                                    GET_SHIP_PACKAGE_LIST
                             	WHERE
                                	ORDER_ROW_ID = #ORDER_ROW_ID# AND
                                    CONTROL_AMOUNT >0
                            </cfquery>
                            <tr id="sub_order_detail#order_row_id#" class="nohover" style="display:none" >
                             	<td colspan="5">
                                 	<table style="width:100%" cellpadding="2" cellspacing="0" border="1">
                                    	<tr style="font-weight:bold; text-align:center; background-color:gainsboro; height:15px">
                                        	<td style="text-align:center;color:cadetblue; width:20px"><cf_get_lang dictionary_id='58577.Sıra'></td> 
                                         	<td style="text-align:center;color:cadetblue;"><cf_get_lang dictionary_id='58221.Ürün Adı'></td> 
                                        	<td style="text-align:center;color:cadetblue; width:30px"><cf_get_lang dictionary_id='100.Paket'></td> 
                                         	<td style="text-align:center;color:cadetblue; width:30px"><cf_get_lang dictionary_id='45358.Kontrol'></td> 
                                   		</tr>   
                                        <cfloop query="get_sub_order_row">  
                                        	<tr>
                                            	<td style="text-align:right; height:15px">#Currentrow#</td>
                                             	<td style="text-align:left" nowrap="nowrap">#PRODUCT_NAME#<cfif SPECT_MAIN_ID gt 0><font color="red"> - #SPECT_MAIN_ID#</font></cfif></td>
                                              	<td style="text-align:right">#PAKETSAYISI#</td>
                                             	<td style="text-align:right">#CONTROL_AMOUNT#</td>
                                          	</tr>
                                     	</cfloop>
                                  	</table>
                              	</td>
                            </tr>
                        </cfoutput>
                    </cfif>
                </tbody>
        </cf_grid_list>
    </cf_basket>
</cfif>
<script language="javascript" type="text/javascript">
 	function seviyelendir(order_row_id)
	{
		if(document.getElementById('row_display_'+order_row_id).value==1)
		{
			document.getElementById('sub_order_detail'+order_row_id).style.display='';	
			document.getElementById('row_display_'+order_row_id).value = 0
		}
		else
		{
			document.getElementById('sub_order_detail'+order_row_id).style.display='none';
			document.getElementById('row_display_'+order_row_id).value =1
		}
	}
</script>