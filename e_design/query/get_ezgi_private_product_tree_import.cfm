<!---
    File: get_ezgi_private_product_tree_import.cfm
    Folder: Add_Ons\ezgi\e_design\query
    Author: Ezgi Yazılım
    Date: 01/01/2026
    Description:
---> 
<cfquery name="get_satirlar" datasource="#dsn3#">
	SELECT 
    	*
  	FROM
    	(
        SELECT        
            3 AS TYPE, 
            0 AS PIECE_TYPE, 
            EDR.DESIGN_MAIN_COLOR_ID AS COLOR_ID,
            EDR.DESIGN_MAIN_NAME AS DESIGN_ROW_NAME, 
            S.PRODUCT_NAME, 
            SM.SPECT_MAIN_NAME AS PRODUCT_CODE, 
            EDR.DESIGN_MAIN_ROW_ID AS IID, 
            S.STOCK_ID, 
            S.PRODUCT_STATUS,
            0 AS PARTNER_ID,
            SM.SPECT_MAIN_ID,
            ISNULL(S.IS_PROTOTYPE,0) IS_PROTOTYPE
        FROM            
          	EZGI_DESIGN_MAIN_ROW AS EDR WITH (NOLOCK) LEFT OUTER JOIN
          	SPECT_MAIN AS SM WITH (NOLOCK) ON EDR.MAIN_SPECT_RELATED_ID = SM.SPECT_MAIN_ID LEFT OUTER JOIN
         	STOCKS AS S WITH (NOLOCK) ON EDR.DESIGN_MAIN_RELATED_ID = S.STOCK_ID
        WHERE        
            EDR.DESIGN_ID = #attributes.design_id# AND
           	ISNULL(S.IS_PROTOTYPE,0) = 1
            <cfif isdefined('attributes.design_main_row_id') and len(attributes.design_main_row_id)>
                AND EDR.DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
            </cfif>
      	<cfif get_design_info.PROCESS_ID lte 2> <!---Modül + Paket--->
			UNION ALL
			SELECT        
				2 AS TYPE, 
				0 AS PIECE_TYPE, 
				EDP.PACKAGE_COLOR_ID AS COLOR_ID,
				EDP.PACKAGE_NAME AS DESIGN_ROW_NAME, 
				SM.SPECT_MAIN_NAME AS PRODUCT_NAME, 
				S.PRODUCT_CODE, 
				EDP.PACKAGE_ROW_ID AS IID, 
				S.STOCK_ID, 
				S.PRODUCT_STATUS,
                ISNULL(EDP.PACKAGE_PARTNER_ID,0) AS PARTNER_ID,
                SM.SPECT_MAIN_ID,
                ISNULL(S.IS_PROTOTYPE,0) IS_PROTOTYPE
			FROM            
				EZGI_DESIGN_PACKAGE AS EDP WITH (NOLOCK) LEFT OUTER JOIN
             	SPECT_MAIN AS SM WITH (NOLOCK) ON EDP.PACKAGE_SPECT_RELATED_ID = SM.SPECT_MAIN_ID LEFT OUTER JOIN
              	STOCKS AS S WITH (NOLOCK) ON EDP.PACKAGE_RELATED_ID = S.STOCK_ID
			WHERE        
				EDP.DESIGN_ID = #attributes.design_id# AND
                ISNULL(S.IS_PROTOTYPE,0) = 1
				<cfif isdefined('change_package_row_id_list') and Listlen(change_package_row_id_list)><!---Sanal Teklif - Revizyon takibinden Geliyorsa--->
                	AND EDP.PACKAGE_ROW_ID IN (#ListDeleteDuplicates(change_package_row_id_list,',')#)
                </cfif>
                <cfif isdefined('attributes.design_main_row_id') and len(attributes.design_main_row_id)>
                    AND EDP.DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
                </cfif>
		</cfif>
        <cfif get_design_info.PROCESS_ID eq 1> <!---Modül + Paket + Parça--->
            UNION ALL
            SELECT        
                1 AS TYPE, 
                EDE.PIECE_TYPE, 
                EDE.PIECE_COLOR_ID AS COLOR_ID,
                EDE.PIECE_NAME AS DESIGN_ROW_NAME, 
                SM.SPECT_MAIN_NAME AS PRODUCT_NAME, 
                S.PRODUCT_CODE, 
                EDE.PIECE_ROW_ID AS IID, 
                S.STOCK_ID, 
                S.PRODUCT_STATUS,
                ISNULL(EDE.PACKAGE_PARTNER_ID,0) PARTNER_ID,
                SM.SPECT_MAIN_ID,
               	ISNULL(S.IS_PROTOTYPE,0) IS_PROTOTYPE
            FROM            
             	EZGI_DESIGN_PIECE AS EDE WITH (NOLOCK) LEFT OUTER JOIN
              	SPECT_MAIN AS SM WITH (NOLOCK) ON EDE.PIECE_SPECT_RELATED_ID = SM.SPECT_MAIN_ID LEFT OUTER JOIN
            	STOCKS AS S WITH (NOLOCK) ON EDE.PIECE_RELATED_ID = S.STOCK_ID
            WHERE        
                EDE.DESIGN_ID = #attributes.design_id# AND
                EDE.PIECE_TYPE <> 4 AND
                (ISNULL(S.STOCK_ID,0) = 0 OR (ISNULL(S.IS_PROTOTYPE,0) = 1 AND ISNULL(S.STOCK_ID,0) >0))
                <cfif isdefined('change_piece_row_id_list') and Listlen(change_piece_row_id_list)><!---Sanal Teklif - Revizyon takibinden Geliyorsa--->
                	AND EDE.PIECE_ROW_ID IN (#ListDeleteDuplicates(change_piece_row_id_list,',')#)
                </cfif>
                <cfif isdefined('attributes.design_main_row_id') and len(attributes.design_main_row_id)>
                    AND EDE.DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
                </cfif>
       	</cfif>
        ) AS TBL
 	ORDER BY
    	TYPE,
        PIECE_TYPE
</cfquery>
