<!---
    File: add_ezgi_cargo_matching.cfm
    Folder: Add_Ons\ezgi\e_pda\query
    Author: Ezgi Yazılım
    Date: 01/06/2024
    Description:
--->
<!---<cfdump var="#attributes#"><cfabort>--->
<cfif len(attributes.stock_id)>
		<cfif attributes.control_amount gt 1>
            <cfquery name="DELETE_PACKAGE_LIST" datasource="#DSN2#">
                UPDATE
                    #dsn3_alias#.EZGI_SHIPPING_PACKAGE_LIST
                SET
                    CONTROL_AMOUNT = #attributes.control_amount#,
                    RECORD_DATE = #now()#,
                    RECORD_EMP = #session.ep.userid#
                WHERE 
                    SHIPPING_ID = #attributes.SHIP_ID# AND 
                    TYPE = #attributes.is_type# AND 
                    STOCK_ID = #attributes.stock_id#		
            </cfquery>
        <cfelse>
            <cfquery name="ADD_PACKAGE_LIST" datasource="#dsn2#">
                INSERT INTO 
                    #dsn3_alias#.EZGI_SHIPPING_PACKAGE_LIST
                    (
                        SHIPPING_ID,
                        STOCK_ID,
                        SPECT_MAIN_ID,
                        AMOUNT,
                        CONTROL_AMOUNT,
                        CONTROL_STATUS,
                        TYPE,
                        RECORD_DATE,
                        RECORD_EMP
                    )
                VALUES
                    (
                        #attributes.SHIP_ID#,
                        #attributes.stock_id#,
                        NULL,
                        #attributes.amount#,
                        #attributes.control_amount#,
                        2,
                        #attributes.is_type#,
                        #now()#,
                        #session.ep.userid#
                    )
            </cfquery>
        </cfif>
        <cfif attributes.stock_fis eq 1>
        	<cfquery name="get_shipping" datasource="#dsn2#">
        		SELECT
                    SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                    PAKET_ID AS STOCK_ID, 
                    BARCOD, 
                    STOCK_CODE, 
                    PRODUCT_NAME, 
                    SHIP_RESULT_ID
                FROM
                    (     
                    SELECT     
                        SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                        EPS.PAKET_ID, 
                        S.BARCOD, 
                        S.STOCK_CODE, 
                        S.PRODUCT_NAME, 
                        ESR.SHIP_RESULT_ID,
                        ESRR.ORDER_ROW_ID
                    FROM
                        #dsn3_alias#.EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
                        #dsn3_alias#.EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                        #dsn3_alias#.ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                        #dsn3_alias#.EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                        #dsn3_alias#.STOCKS AS S WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID INNER JOIN
                        #dsn3_alias#.STOCKS AS S1 WITH (NOLOCK) ON S1.STOCK_ID = ORR.STOCK_ID
                    WHERE      
                        ESR.SHIP_RESULT_ID = #attributes.ship_id# AND
                        ORR.ORDER_ROW_CURRENCY = -6 AND
                        ISNULL(S1.IS_PROTOTYPE,0) = 0
                    GROUP BY
                        EPS.PAKET_ID, 
                        S.BARCOD, 
                        S.STOCK_CODE, 
                        S.PRODUCT_NAME, 
                        ESR.SHIP_RESULT_ID,
                        ESRR.ORDER_ROW_ID,
                        ORR.ORDER_ROW_ID
                    ) AS TBL1
                GROUP BY
                    PAKET_ID, 
                    BARCOD, 
                    STOCK_CODE, 
                    PRODUCT_NAME, 
                    SHIP_RESULT_ID
        	</cfquery>
            <cfif get_shipping.recordcount>
                <cfoutput query="get_shipping">
                	<cfquery name="get_collect_shelf" datasource="#dsn2#">
                		SELECT 
                        	PP.PRODUCT_PLACE_ID, 
                            PPR.STOCK_ID
						FROM     
                        	#dsn3_alias#.PRODUCT_PLACE AS PP INNER JOIN
                  			#dsn3_alias#.PRODUCT_PLACE_ROWS AS PPR ON PP.PRODUCT_PLACE_ID = PPR.PRODUCT_PLACE_ID
						WHERE  
                        	PP.PLACE_STATUS = 1 AND 
                            PPR.STOCK_ID = #get_shipping.STOCK_ID# AND 
                            PP.SHELF_TYPE = 1
                	</cfquery>
                	<cfif not get_collect_shelf.recordcount>
                    	<cfdump var="#get_collect_shelf#">
                        Raf Tanımı Yapılmamış
                        <cfabort>
                    <cfelseif get_collect_shelf.recordcount gt 1>
                    	<cfdump var="#get_collect_shelf#">
                        Toplama Raflarına #PRODUCT_NAME# Birden Fazla Raf Tanımı Yapılmış
                        <cfabort>
                    <cfelse>
                    	<cfset row_line = '#currentrow#-#get_shipping.STOCK_ID#-#get_shipping.PAKET_SAYISI#-#get_collect_shelf.PRODUCT_PLACE_ID#'>
                        <cfif get_shipping.recordcount eq 1>
                        	<cfset attributes.action_id = '#row_line#'>
                        <cfelse>
                        	<cfset attributes.action_id = '#attributes.action_id#,#row_line#'>
                        </cfif>
                    </cfif>
				</cfoutput>
                <cfset attributes.ambarfis = 14>
                <cfinclude template="add_ambar_fis.cfm">
            </cfif>
        </cfif>
</cfif>
