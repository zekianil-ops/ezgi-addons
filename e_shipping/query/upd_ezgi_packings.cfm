<!---<cfdump var="#attributes#"><cfabort>--->
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfif isdefined('attributes.sil')>
	<cftransaction>
        <cfquery name="del_fis" datasource="#dsn3#">
            DELETE FROM EZGI_PACKING WHERE PACKING_ID = #attributes.packing_id#
        </cfquery>
        <cfquery name="del_row" datasource="#dsn3#">
            DELETE FROM EZGI_PACKING_ROW WHERE PACKING_ID = #attributes.packing_id#
        </cfquery>
    </cftransaction>
    <cflocation url="#request.self#?fuseaction=sales.list_ezgi_packings" addtoken="no">
<cfelse>
	<cfquery name="get_upd" datasource="#dsn3#">
        SELECT 
        	*,
        		(
                	SELECT 
                    	ORDER_NUMBER
					FROM     
                    	ORDERS
					WHERE  
                    	ORDER_ID = EZGI_PACKING.ORDER_ID
              	) AS 
        	ORDER_NUMBER 
     	FROM 
        	EZGI_PACKING 
      	WHERE 
        	PACKING_ID = #attributes.packing_id#
    </cfquery>
    <cfif get_upd.TYPE eq 2 or get_upd.TYPE eq 3 or get_upd.TYPE eq 4>
        <!---<cfloop list="#attributes.action_id#" index="i">
            <cfif ListGetAt(i,3,'-') gt 0>
            	<cfquery name="get_info" datasource="#dsn3#">
                	SELECT     
                    	EOVR.EZGI_ID, 
                        EVO.COMPANY_ID, 
                        EVO.CONSUMER_ID, 
                        EVO.BRANCH_ID, 
                        EVO.SALES_COMPANY_ID
					FROM       
                    	EZGI_VIRTUAL_OFFER_ROW AS EOVR INNER JOIN
                 		EZGI_DESIGN_MAIN_ROW AS EDMR ON EOVR.WRK_ROW_RELATION_ID = EDMR.WRK_ROW_RELATION_ID INNER JOIN
                  		EZGI_DESIGN AS ED ON EDMR.DESIGN_ID = ED.DESIGN_ID INNER JOIN
                  		EZGI_VIRTUAL_OFFER AS EVO ON EOVR.VIRTUAL_OFFER_ID = EVO.VIRTUAL_OFFER_ID
					WHERE     
                    	EDMR.MAIN_SPECT_RELATED_ID = #ListGetAt(i,3,'-')#
                </cfquery>
                <cfif not get_info.recordcount>
                    <cfquery name="get_info" datasource="#dsn3#">
                        SELECT     
                            ED.CONSUMER_ID, 
                            ED.COMPANY_ID
                        FROM        
                            EZGI_DESIGN_MAIN_ROW AS EDM INNER JOIN
                            EZGI_DESIGN AS ED ON EDM.DESIGN_ID = ED.DESIGN_ID
                        WHERE     
                            EDM.MAIN_SPECT_RELATED_ID = #ListGetAt(i,3,'-')#
                    </cfquery>
                </cfif>
                <cfif get_info.recordcount and (len(get_info.COMPANY_ID) or len(get_info.CONSUMER_ID))>
                	<cfset company_id = get_info.COMPANY_ID>
                    <cfset consumer_id = get_info.CONSUMER_ID>
                	<cfbreak>
                <cfelse>
                	<cfset company_id = ''>
                    <cfset consumer_id = ''>
                </cfif>
            </cfif>
        </cfloop>--->
        <cfif get_upd.TYPE eq 3>
            <cfloop list="#attributes.action_id#" index="i">
                <cfif ListGetAt(i,3,'-') gt 0>
                    <cfquery name="get_info_sub" datasource="#dsn3#">
                        SELECT     
                        	EFRR.TIP, 
                            EFRR.KONUM, 
                            EFRR.DAIRE, 
                            EFRR.MEKAN, 
                            EOVR.EZGI_ID
						FROM        
                        	EZGI_VIRTUAL_OFFER_ROW AS EOVR INNER JOIN
                 			EZGI_DESIGN_MAIN_ROW AS EDMR ON EOVR.WRK_ROW_RELATION_ID = EDMR.WRK_ROW_RELATION_ID INNER JOIN
                  			EZGI_DESIGN AS ED ON EDMR.DESIGN_ID = ED.DESIGN_ID LEFT OUTER JOIN
                  			EZGI_VIRTUAL_OFFER_ROW_FLOOR AS EFRR ON EOVR.EZGI_ID = EFRR.EZGI_ID
						WHERE     
                        	EDMR.MAIN_SPECT_RELATED_ID = #ListGetAt(i,3,'-')#
                    </cfquery>
                    <cfif get_info_sub.recordcount>
                        <cfset tip = get_info_sub.TIP>
                        <cfset konum = get_info_sub.KONUM>
                        <cfset daire = get_info_sub.DAIRE>
                        <cfset mekan = get_info_sub.MEKAN>
                        <cfbreak>
                    <cfelse>
                        <cfset tip = ''>
                        <cfset konum = ''>
                        <cfset daire = ''>
                        <cfset mekan = ''>
                    </cfif>
                </cfif>
            </cfloop>
       	</cfif>
    </cfif>
	<cftransaction>
        <cfquery name="upd" datasource="#dsn3#">
            UPDATE      
                EZGI_PACKING
            SET  
            	STATUS = 1              
                <cfif get_upd.TYPE eq 2>
                	, DETAIL = 'Sipariş No : #get_upd.order_number#'
                </cfif>
                <cfif get_upd.TYPE eq 3 and get_info_sub.recordcount>
                	, DETAIL = 'TIP : #TIP# - KONUM : #KONUM# - DAIRE : #DAIRE# - MEKAN : #MEKAN#'
                </cfif>
                <cfif get_upd.TYPE eq 4>
                	, DETAIL = 'LOT_NO : #get_upd.lot_no#'
                </cfif>
            WHERE        
                PACKING_ID = #attributes.packing_id#
        </cfquery>
        <cfquery name="del_row" datasource="#dsn3#">
            DELETE FROM EZGI_PACKING_ROW WHERE PACKING_ID = #attributes.packing_id#
        </cfquery>
        <cfloop list="#attributes.action_id#" index="i">
            <cfif Len(ListGetAt(i,2,'-')) and ListGetAt(i,4,'-') gt 0>
                <cfquery name="add_row" datasource="#dsn3#">
                INSERT INTO 
                    EZGI_PACKING_ROW
                    (
                        PACKING_ID, 
                        AMOUNT, 
                        STOCK_ID, 
                        SPECT_MAIN_ID
                        <cfif get_defaults.PALET_BARCODE_LOT eq 1>,LOT_NO</cfif>
                    )
                VALUES        
                    (
                        #attributes.packing_id#,
                        #ListGetAt(i,4,'-')#,
                        #ListGetAt(i,2,'-')#,
                        <cfif Len(ListGetAt(i,3,'-'))>#ListGetAt(i,3,'-')#<cfelse>NULL</cfif>
                        <cfif get_defaults.PALET_BARCODE_LOT eq 1>,<cfif Len(ListGetAt(i,5,'-')) gt 0>#ListGetAt(i,5,'-')#<cfelse>NULL</cfif></cfif>
                    )
                        
                </cfquery>
            </cfif>
        </cfloop>
    </cftransaction>
 	<cflocation url="#request.self#?fuseaction=sales.list_ezgi_packings&event=upd&packing_id=#attributes.packing_id#" addtoken="no">
 </cfif>