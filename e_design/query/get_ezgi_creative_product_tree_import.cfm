<!---
    File: get_ezgi_creative_product_tree_import.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<!---Design Sorgusu--->
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WITH (NOLOCK) ORDER BY COLOR_NAME
</cfquery>
<cfoutput query="get_colors">
	<cfset 'COLOR_NAME_#COLOR_ID#' = COLOR_NAME>
</cfoutput>
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
</cfquery>
<cfquery name="get_product_cat_piece" datasource="#dsn3#">
  	SELECT HIERARCHY FROM PRODUCT_CAT WITH (NOLOCK) WHERE PRODUCT_CATID = #get_defaults.DEFAULT_PIECE_CAT_ID#
</cfquery>
<cfquery name="get_product_cat_package" datasource="#dsn3#">
  	SELECT HIERARCHY FROM PRODUCT_CAT WITH (NOLOCK) WHERE PRODUCT_CATID = #get_defaults.DEFAULT_PACKAGE_CAT_ID#
</cfquery>
<cfquery name="get_design_info" datasource="#dsn3#">
	SELECT 
    	PRODUCT_CAT.HIERARCHY,
        ED.DESIGN_NAME, 
        ED.PROCESS_ID,
       	ED.PRODUCT_CATID,
        PRODUCT_CAT.PRODUCT_CAT 
   	FROM 
    	EZGI_DESIGN AS ED WITH (NOLOCK) INNER JOIN PRODUCT_CAT WITH (NOLOCK) ON 
        ED.PRODUCT_CATID = PRODUCT_CAT.PRODUCT_CATID 
  	WHERE 
    	ED.DESIGN_ID = #attributes.design_id#
</cfquery>
<!---Design Sorgusu--->
<!---Parça Sorgusu--->
<cfquery name="get_piece_all" datasource="#dsn3#">
	SELECT        
    	E.PIECE_ROW_ID, 
        E.PIECE_NAME, 
        E.PIECE_CODE, 
        E.PIECE_COLOR_ID,
        E.PIECE_AMOUNT, 
        E.PIECE_DETAIL,
        ISNULL(TBL_1.AMOUNT, 0) AS USED_AMOUNT, 
        E.DESIGN_PACKAGE_ROW_ID, 
        E.DESIGN_MAIN_ROW_ID, 
        E.PIECE_RELATED_ID, 
      	E.PIECE_TYPE,
        0 AS SAME_PIECE_ID
	FROM            
    	EZGI_DESIGN_PIECE AS E WITH (NOLOCK) LEFT OUTER JOIN
      	(
        	SELECT        
            	RELATED_PIECE_ROW_ID, 
                SUM(AMOUNT) AS AMOUNT
         	FROM            
            	EZGI_DESIGN_PIECE_ROW WITH (NOLOCK)
         	GROUP BY 
            	RELATED_PIECE_ROW_ID
     	) AS TBL_1 ON E.PIECE_ROW_ID = TBL_1.RELATED_PIECE_ROW_ID
	WHERE        
    	E.PIECE_STATUS = 1 AND 
        E.DESIGN_ID = #attributes.design_id#
</cfquery>
<!---Parça Sorgusu--->
<!---Paket Sorgusu--->
<cfquery name="get_package_all" datasource="#dsn3#">
	SELECT        
    	PACKAGE_ROW_ID, 
        PACKAGE_NUMBER, 
        PACKAGE_NAME, 
        PACKAGE_BOYU, 
        PACKAGE_ENI, 
        PACKAGE_KALINLIK, 
        PACKAGE_WEIGHT, 
        PACKAGE_AMOUNT, 
        PACKAGE_DETAIL, 
        PACKAGE_RELATED_ID,
        DESIGN_MAIN_ROW_ID,
      	(SELECT DESIGN_MAIN_NAME FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = EZGI_DESIGN_PACKAGE.DESIGN_MAIN_ROW_ID AND DESIGN_MAIN_STATUS = 1) AS DESIGN_MAIN_NAME,
        ISNULL((
        	SELECT        
            	COUNT(*) AS PARCA_SAYISI
          	FROM            
            	EZGI_DESIGN_PIECE WITH (NOLOCK)
          	WHERE        
            	PIECE_STATUS = 1
      		GROUP BY 
            	DESIGN_PACKAGE_ROW_ID
          	HAVING        
            	DESIGN_PACKAGE_ROW_ID = EZGI_DESIGN_PACKAGE.PACKAGE_ROW_ID
   		), 0) AS PARCA_SAYISI
	FROM            
    	EZGI_DESIGN_PACKAGE WITH (NOLOCK)
	WHERE        
    	DESIGN_ID = #attributes.design_id# AND
    	PACKAGE_RELATED_ID IS NULL	
</cfquery>
<cfquery name="get_package_1" dbtype="query">
  	SELECT        
        PACKAGE_NUMBER, 
        PACKAGE_NAME, 
        PACKAGE_BOYU, 
        PACKAGE_ENI, 
        PACKAGE_KALINLIK, 
        PACKAGE_WEIGHT, 
        PACKAGE_AMOUNT, 
        PACKAGE_DETAIL, 
        PACKAGE_ROW_ID,
        DESIGN_MAIN_ROW_ID
    FROM
        get_package_all
    GROUP BY 
        PACKAGE_NUMBER, 
        PACKAGE_NAME, 
        PACKAGE_BOYU, 
        PACKAGE_ENI, 
        PACKAGE_KALINLIK, 
        PACKAGE_WEIGHT, 
        PACKAGE_AMOUNT, 
        PACKAGE_DETAIL, 
        PACKAGE_ROW_ID,
        DESIGN_MAIN_ROW_ID
    ORDER BY 
        PACKAGE_NAME
</cfquery>

<!---Paket Sorgusu--->
<!---Modül Sorgusu--->
<cfquery name="get_main_all" datasource="#dsn3#">
	SELECT        
    	EDM.DESIGN_MAIN_ROW_ID, 
        EDM.DESIGN_MAIN_NAME, 
        EDP.PACKAGE_RELATED_ID, 
        EDP.PACKAGE_ROW_ID, 
        EDP.PACKAGE_NUMBER, 
        EDP.PACKAGE_DETAIL,
        EDP.PACKAGE_AMOUNT
	FROM            
    	EZGI_DESIGN_MAIN_ROW AS EDM WITH (NOLOCK) LEFT OUTER JOIN
     	EZGI_DESIGN_PACKAGE AS EDP WITH (NOLOCK) ON EDM.DESIGN_MAIN_ROW_ID = EDP.DESIGN_MAIN_ROW_ID
	WHERE        
    	EDM.DESIGN_ID = #attributes.design_id# AND 
        EDM.DESIGN_MAIN_STATUS = 1
</cfquery>
<cfquery name="get_main_1" dbtype="query">
	SELECT        
       	DESIGN_MAIN_ROW_ID, 
        DESIGN_MAIN_NAME
	FROM
       	get_main_all
    GROUP BY 
       	DESIGN_MAIN_ROW_ID, 
        DESIGN_MAIN_NAME
	ORDER BY 
     	DESIGN_MAIN_NAME
</cfquery>
<!---Modül Sorgusu--->