<!---
    File: add_ezgi_spect_standart.cfm
    Folder: Add_Ons\ezgi\e_sales\form
    Author: Ezgi Yazılım
    Date: 01/01/2022
    Description:
--->
<!---<cfdump var="#attributes#">--->
<cfif not get_product.DESIGN_MAIN_ROW_ID gt 0>
	<script type="text/javascript">
		alert("Modül Bağlantısı Bulunamadı!");
		window.close()
	</script>
    <cfabort>
</cfif>
<cfparam name="attributes.measure_id" default="#get_product.MEASURE_ID#"> 
<cfquery name="get_image" datasource="#dsn1#">
	SELECT PRODUCT_IMAGEID, PATH FROM PRODUCT_IMAGES WHERE PRODUCT_ID = #get_product.PRODUCT_ID# AND IMAGE_SIZE = 0 
</cfquery>
<cfquery name="get_measure" datasource="#dsn3#">
	SELECT        
    	ER.MEASURE, 
        ER.IS_STANDART, 
        ISNULL(IS_DEFAULT,0) IS_DEFAULT, 
        ER.MEASURE_TYPE,
        ISNULL(ER.PRIVATE_RATE,0) AS PRIVATE_RATE, 
        ISNULL(ER.PRIVATE_PRICE,0) AS PRIVATE_PRICE, 
        ISNULL(ER.BIG_MEASURE,0) AS BIG_MEASURE, 
        ISNULL(ER.SMALL_MEASURE,0) AS SMALL_MEASURE, 
        ISNULL(ER.PRIVATE_MEASURE,0) AS PRIVATE_MEASURE,
        ISNULL(ER.PRIVATE2_MEASURE,0) AS PRIVATE2_MEASURE
	FROM            
  		EZGI_VIRTUAL_OFFER_ROW_MEASURE AS E WITH (NOLOCK) INNER JOIN
      	EZGI_VIRTUAL_OFFER_ROW_MEASURE_ROW AS ER WITH (NOLOCK) ON E.MEASURE_ID = ER.MEASURE_ID
	WHERE        
    	E.MEASURE_ID = #attributes.measure_id# AND 
        ISNULL(ER.IS_SPECIAL_MEASURE,0) = 0
    UNION ALL
    SELECT DISTINCT    
    	ER.MEASURE, 
        ER.IS_STANDART, 
        ISNULL(IS_DEFAULT,0) IS_DEFAULT, 
        ER.MEASURE_TYPE,
        ISNULL(ER.PRIVATE_RATE,0) AS PRIVATE_RATE, 
        ISNULL(ER.PRIVATE_PRICE,0) AS PRIVATE_PRICE, 
        ISNULL(ER.BIG_MEASURE,0) AS BIG_MEASURE, 
        ISNULL(ER.SMALL_MEASURE,0) AS SMALL_MEASURE, 
        ISNULL(ER.PRIVATE_MEASURE,0) AS PRIVATE_MEASURE,
        ISNULL(ER.PRIVATE2_MEASURE,0) AS PRIVATE2_MEASURE
	FROM            
        EZGI_VIRTUAL_OFFER_ROW_MEASURE AS E WITH (NOLOCK) INNER JOIN
        EZGI_VIRTUAL_OFFER_ROW_MEASURE_ROW AS ER WITH (NOLOCK) ON E.MEASURE_ID = ER.MEASURE_ID INNER JOIN
        EZGI_VIRTUAL_OFFER_SPECIAL_ROW AS ES ON ER.MEASURE_ID = ES.ROW_ID AND ER.MEASURE = ES.MEASURE AND ER.MEASURE_TYPE = ES.MEASURE_TYPE
	WHERE        
    	E.MEASURE_ID = #attributes.measure_id# AND 
        ISNULL(ER.IS_SPECIAL_MEASURE,0) = 1 AND
        ES.VIRTUAL_OFFER_ID = (SELECT DISTINCT VIRTUAL_OFFER_ID FROM EZGI_VIRTUAL_OFFER_ROW WHERE EZGI_ID = #attributes.ezgi_id#) AND
        ES.TYPE = 'measure'
</cfquery>
<cfquery name="get_heights" dbtype="query">
	SELECT * FROM get_measure WHERE MEASURE_TYPE = 1 ORDER BY MEASURE
</cfquery>
<cfquery name="get_widths" dbtype="query">
	SELECT * FROM get_measure WHERE MEASURE_TYPE = 2 ORDER BY MEASURE
</cfquery>
<cfquery name="get_depths" dbtype="query">
	SELECT * FROM get_measure WHERE MEASURE_TYPE = 3 ORDER BY MEASURE
</cfquery>
<cfquery name="get_heights_def" dbtype="query">
	SELECT * FROM get_measure WHERE MEASURE_TYPE = 1 AND  IS_DEFAULT = 1 ORDER BY MEASURE
</cfquery>
<cfquery name="get_widths_def" dbtype="query">
	SELECT * FROM get_measure WHERE MEASURE_TYPE = 2 AND IS_DEFAULT = 1 ORDER BY MEASURE
</cfquery>
<cfquery name="get_depths_def" dbtype="query">
	SELECT * FROM get_measure WHERE MEASURE_TYPE = 3 AND IS_DEFAULT = 1 ORDER BY MEASURE
</cfquery>
<cfif not get_ROW.recordcount>
	<cfparam name="attributes.not_standart_rate" default="0">
	<cfparam name="attributes.hesapla" default="0">
    <cfif get_heights_def.recordcount>
    	<cfparam name="attributes.height" default="#get_heights_def.measure#">
    <cfelse>
    	<cfparam name="attributes.height" default="#get_heights.measure#">
    </cfif>
    <cfif get_widths_def.recordcount>
    	<cfparam name="attributes.width" default="#get_widths_def.measure#">
    <cfelse>
    	<cfparam name="attributes.width" default="#get_widths.measure#">
    </cfif>
    <cfif get_depths_def.recordcount>
    	<cfparam name="attributes.depth" default="#get_depths_def.measure#">
    <cfelse>
    	<cfparam name="attributes.depth" default="#get_depths.measure#">
    </cfif>
    <cfparam name="attributes.side" default="1">
    <cfquery name="get_row" datasource="#dsn3#">
        SELECT        
        	EDP.PACKAGE_ROW_ID, 
            EDP.PACKAGE_NAME, 
            EDP.PACKAGE_AMOUNT,
            EDP.PACKAGE_NUMBER, 
            EDPP.PIECE_CODE, 
            EDPP.PIECE_RELATED_ID, 
            EDPP.PIECE_ROW_ID, 
            EDPP.PIECE_TYPE, 
            EDPP.PIECE_NAME, 
            EDPP.PIECE_AMOUNT, 
        	EDPT.QUESTION_ID, 
            EDPT.BOY_FORMUL, 
            EDPT.EN_FORMUL, 
            ISNULL(EDPT.IS_AMOUNT_CHANGE,0) AS IS_AMOUNT_CHANGE, 
            ISNULL(EDPT.IS_PRICE_CHANGE,0) IS_PRICE_CHANGE, 
            ISNULL(EDPT.PRIVATE_PRICE_TYPE,0) PRIVATE_PRICE_TYPE, 
            EDPT.AMOUNT_FORMUL,
            EDPT.PRICE_FORMUL,
            EDPT.PIECE_ROW_PROTOTIP_ID,
            ISNULL(EDPT.PRIVATE_PRICE,0) AS PRIVATE_PRICE,  
         	EDPT.PRIVATE_PRICE_MONEY
		FROM            
        	EZGI_DESIGN_PACKAGE AS EDP WITH (NOLOCK) INNER JOIN
         	EZGI_DESIGN_PIECE AS EDPP WITH (NOLOCK) ON EDP.PACKAGE_ROW_ID = EDPP.DESIGN_PACKAGE_ROW_ID LEFT OUTER JOIN
          	EZGI_DESIGN_PIECE_PROTOTIP AS EDPT WITH (NOLOCK) ON EDPP.PIECE_ROW_ID = EDPT.PIECE_ROW_ID
		WHERE        
        	EDP.DESIGN_MAIN_ROW_ID = #get_product.DESIGN_MAIN_ROW_ID# AND 
            EDPP.PIECE_TYPE <> 3 <!---AND
            EDP.PACKAGE_PARTNER_ID IS NULL--->
		UNION ALL
		SELECT        
        	EDP.PACKAGE_ROW_ID, 
            EDP.PACKAGE_NAME, 
            EDP.PACKAGE_AMOUNT, 
            EDP.PACKAGE_NUMBER,
            EDPRR.PIECE_CODE, 
            EDPRR.PIECE_RELATED_ID, 
            EDPRR.PIECE_ROW_ID, 
            EDPRR.PIECE_TYPE, 
            EDPRR.PIECE_NAME, 
            EDPRR.PIECE_AMOUNT, 
   			EDPT.QUESTION_ID, 
            EDPT.BOY_FORMUL, 
            EDPT.EN_FORMUL, 
            ISNULL(EDPT.IS_AMOUNT_CHANGE,0) AS IS_AMOUNT_CHANGE, 
            ISNULL(EDPT.IS_PRICE_CHANGE,0) IS_PRICE_CHANGE, 
            ISNULL(EDPT.PRIVATE_PRICE_TYPE,0) PRIVATE_PRICE_TYPE, 
            EDPT.AMOUNT_FORMUL,
            EDPT.PRICE_FORMUL,
            EDPT.PIECE_ROW_PROTOTIP_ID,
            ISNULL(EDPT.PRIVATE_PRICE,0) AS PRIVATE_PRICE, 
         	EDPT.PRIVATE_PRICE_MONEY
		FROM            
        	EZGI_DESIGN_PACKAGE AS EDP WITH (NOLOCK) INNER JOIN
         	EZGI_DESIGN_PIECE AS EDPP WITH (NOLOCK) ON EDP.PACKAGE_ROW_ID = EDPP.DESIGN_PACKAGE_ROW_ID INNER JOIN
          	EZGI_DESIGN_PIECE_ROW AS EDPR WITH (NOLOCK) ON EDPP.PIECE_ROW_ID = EDPR.PIECE_ROW_ID INNER JOIN
          	EZGI_DESIGN_PIECE_ROWS AS EDPRR WITH (NOLOCK) ON EDPR.RELATED_PIECE_ROW_ID = EDPRR.PIECE_ROW_ID LEFT OUTER JOIN
         	EZGI_DESIGN_PIECE_PROTOTIP AS EDPT WITH (NOLOCK) ON EDPRR.PIECE_ROW_ID = EDPT.PIECE_ROW_ID
		WHERE        
        	EDP.DESIGN_MAIN_ROW_ID = #get_product.DESIGN_MAIN_ROW_ID# AND 
            EDPP.PIECE_TYPE = 3 <!---AND
            EDP.PACKAGE_PARTNER_ID IS NULL--->
      	ORDER BY
        	PACKAGE_ROW_ID,
            PIECE_CODE
	</cfquery>
    <!---<cfdump var="#get_row#">--->
    <cfquery name="get_row" dbtype="query">
        SELECT * FROM GET_ROW WHERE NOT (PIECE_ROW_PROTOTIP_ID IS NULL) order by PACKAGE_NUMBER desc
    </cfquery>
    <cfquery name="GET_MAIN_ROW" datasource="#DSN3#">
        SELECT 
        	DESIGN_MAIN_NAME, 
            DESIGN_MAIN_RELATED_ID,
            ISNULL(PRIVATE_PRICE_TYPE,0) PRIVATE_PRICE_TYPE, 
            ISNULL(PRIVATE_PRICE,0) AS PRIVATE_PRICE, 
         	PRIVATE_PRICE_MONEY
       	FROM 
        	EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
       	WHERE 
        	DESIGN_MAIN_ROW_ID = #get_product.DESIGN_MAIN_ROW_ID#
    </cfquery>
    <cfif GET_MAIN_ROW.recordcount and len(GET_MAIN_ROW.DESIGN_MAIN_RELATED_ID)>
        <cfquery name="get_main_price" datasource="#dsn3#">
        	SELECT 
            	STOCK_ID, 
                ISNULL(PRICE,0) AS SALES_PRICE,
                ISNULL(OTHER_MONEY,'#session.ep.money#') AS SALES_PRICE_MONEY,
                ISNULL(PURCHASE_PRICE,0) AS PURCHASE_PRICE,
                ISNULL(PURCHASE_PRICE_MONEY,'#session.ep.money#') AS PURCHASE_PRICE_MONEY,
                ISNULL(COST_PRICE,0) AS COST_PRICE,
                ISNULL(COST_PRICE_MONEY,'#session.ep.money#') AS COST_PRICE_MONEY
			FROM     
            	EZGI_VIRTUAL_OFFER_ROW
			WHERE  
            	EZGI_ID = #attributes.ezgi_id#
        </cfquery>
  	</cfif>
<cfelse>
    <cfparam name="attributes.hesapla" default="1">
    <cfparam name="attributes.height" default="#get_product.BOY#">
    <cfparam name="attributes.width" default="#get_product.EN#">
    <cfparam name="attributes.depth" default="#get_product.DERINLIK#">
    <cfparam name="attributes.side" default="#get_product.YON#">
    <cfquery name="GET_MAIN_ROW" dbtype="query">
        SELECT 
        	PIECE_NAME AS DESIGN_MAIN_NAME, 
            STOCK_ID AS DESIGN_MAIN_RELATED_ID ,
            PRIVATE_PRICE_TYPE, 
            PRIVATE_PRICE, 
         	PRIVATE_PRICE_MONEY
      	FROM 
        	get_row
       	WHERE 
        	PIECE_TYPE = 0
    </cfquery>
    <cfquery name="get_main_price" dbtype="query">
     	SELECT 
        	STOCK_ID,       
         	SALES_PRICE, 
         	SALES_PRICE_MONEY,
        	PURCHASE_PRICE,
        	PURCHASE_PRICE_MONEY,
        	COST_PRICE,
         	COST_PRICE_MONEY
      	FROM 
        	get_row
     	WHERE    
        	PIECE_TYPE = 0    
 	</cfquery>
    <cfquery name="get_row" dbtype="query">
        SELECT * FROM GET_ROW WHERE PIECE_TYPE <> 0 
    </cfquery>
    <cfparam name="attributes.not_standart_rate" default="#get_row.not_standart_rate#">
    <cfif not isdefined('is_form_submitted')>
		<cfoutput query="get_row">
            <cfset 'attributes.alternative_stock_id_#get_row.PIECE_TYPE#_#get_row.PIECE_ROW_ID#' = STOCK_ID>
        </cfoutput>
    </cfif>
</cfif>
<cfset height = attributes.height>
<cfset width = attributes.width>
<cfset depth = attributes.depth>
<cfset side = attributes.side>
<!---Yükseklik İçin Ek Ölçüler Alınıyor--->
<cfquery name="get_heights_detail" dbtype="query">
	SELECT * FROM get_heights WHERE MEASURE = #height#
</cfquery>
<cfif not get_heights_detail.recordcount>
	<script type="text/javascript">
		alert("<cfoutput>#height#</cfoutput> Ölçüsüne Ait Kayıt Bulunamadı!");
		window.close()
	</script>
    <cfabort>
<cfelseif get_heights_detail.recordcount gt 1>
	<script type="text/javascript">


		alert("<cfoutput>#height#</cfoutput> Ölçüsüne Ait Birden Fazla Kayıt Bulundu!");
		window.close()
	</script>
    <cfabort>
<cfelse>
	<cfset height1 = get_heights_detail.BIG_MEASURE>
    <cfset height2 = get_heights_detail.SMALL_MEASURE>
    <cfset height3 = get_heights_detail.PRIVATE_MEASURE>
    <cfset height4 = get_heights_detail.PRIVATE2_MEASURE>
    <cfset height_private_rate = get_heights_detail.PRIVATE_RATE>
    <cfset height_private_price = get_heights_detail.PRIVATE_PRICE>
    
    <cfif get_heights_detail.PRIVATE_RATE gt 0>
        <cfset height_private_price_type = 2>
        <cfif get_heights_detail.PRIVATE_PRICE gt 0>
            <script type="text/javascript">
                alert("<cfoutput>#height#</cfoutput>Uzunluk ölçüsü için hem fiyat hem yüzde tanımlanmıştır. Ölçü adları tablosundan lütfen düzeltiniz!");
                window.close()
            </script>
        </cfif>
    <cfelse>
        <cfset height_private_price_type = 1>
    </cfif>
    
    <cfif get_heights_detail.IS_STANDART eq 0>
    	<cfset height_is_standart = 0>
   	<cfelse>
    	<cfset height_is_standart = 1>
    </cfif>
</cfif>
<!---Genişlik İçin Ek Ölçüler Alınıyor--->
<cfquery name="get_widths_detail" dbtype="query">
	SELECT * FROM get_widths WHERE MEASURE = #width#
</cfquery>
<cfif not get_widths_detail.recordcount>
	<script type="text/javascript">
		alert("<cfoutput>#width#</cfoutput> Ölçüsüne Ait Kayıt Bulunamadı!");
		window.close()
	</script>
    <cfabort>
<cfelseif get_widths_detail.recordcount gt 1>
	<script type="text/javascript">
		alert("<cfoutput>#width#</cfoutput> Ölçüsüne Ait Birden Fazla Kayıt Bulundu!");
		window.close()
	</script>
    <cfabort>
<cfelse>
	<cfset width1 = get_widths_detail.BIG_MEASURE>
    <cfset width2 = get_widths_detail.SMALL_MEASURE>
    <cfset width3 = get_widths_detail.PRIVATE_MEASURE>
    <cfset width4 = get_widths_detail.PRIVATE2_MEASURE>
    <cfset width_private_rate = get_widths_detail.PRIVATE_RATE>
    <cfset width_private_price = get_widths_detail.PRIVATE_PRICE>

    <cfif get_widths_detail.PRIVATE_RATE gt 0>
        <cfset width_private_price_type = 2>
        <cfif get_widths_detail.PRIVATE_PRICE gt 0>
            <script type="text/javascript">
                alert("<cfoutput>#width#</cfoutput> Genişlik ölçüsü için hem fiyat hem yüzde tanımlanmıştır. Ölçü adları tablosundan lütfen düzeltiniz!");
                window.close()
            </script>
        </cfif>
    <cfelse>
        <cfset width_private_price_type = 1>
    </cfif>

    <cfif get_widths_detail.IS_STANDART eq 0>
    	<cfset width_is_standart = 0>
   	<cfelse>
    	<cfset width_is_standart = 1>
    </cfif>
</cfif>
<!---Derinlik İçin Ek Ölçüler Alınıyor--->
<cfquery name="get_depths_detail" dbtype="query">
	SELECT * FROM get_depths WHERE MEASURE = #depth#
</cfquery>
<cfif not get_depths_detail.recordcount>
	<script type="text/javascript">
		alert("<cfoutput>#depth#</cfoutput> Ölçüsüne Ait Kayıt Bulunamadı!");
		window.close()
	</script>
    <cfabort>
<cfelseif get_depths_detail.recordcount gt 1>
	<script type="text/javascript">
		alert("<cfoutput>#depth#</cfoutput> Ölçüsüne Ait Birden Fazla Kayıt Bulundu!");
		window.close()
	</script>
    <cfabort>
<cfelse>
	<cfset depth1 = get_depths_detail.BIG_MEASURE>
    <cfset depth2 = get_depths_detail.SMALL_MEASURE>
    <cfset depth3 = get_depths_detail.PRIVATE_MEASURE>
    <cfset depth4 = get_depths_detail.PRIVATE2_MEASURE>
    <cfset depth_private_rate = get_depths_detail.PRIVATE_RATE>
    <cfset depth_private_price = get_depths_detail.PRIVATE_PRICE>

    <cfif get_depths_detail.PRIVATE_RATE gt 0>
        <cfset depth_private_price_type = 2>
        <cfif get_depths_detail.PRIVATE_PRICE gt 0>
            <script type="text/javascript">
                alert("<cfoutput>#depth#</cfoutput> Derinlik ölçüsü için hem fiyat hem yüzde tanımlanmıştır. Ölçü adları tablosundan lütfen düzeltiniz!");
                window.close()
            </script>
        </cfif>
    <cfelse>
        <cfset depth_private_price_type = 1>
    </cfif>

    <cfif get_depths_detail.IS_STANDART eq 0>
    	<cfset depth_is_standart = 0>
   	<cfelse>
    	<cfset depth_is_standart = 1>
    </cfif>
</cfif>

<cfquery name="get_row_4" dbtype="query">
	SELECT * FROM GET_ROW WHERE NOT (PIECE_ROW_PROTOTIP_ID IS NULL) AND PIECE_TYPE = 4
</cfquery>
<cfset piece_id_list_4 = ValueList(get_row_4.PIECE_ROW_ID)>
<cfset stock_id_list_4 = ValueList(get_row_4.PIECE_RELATED_ID)>
<!---<cfdump var="#get_row#">--->
<cfquery name="get_row_1" dbtype="query">
	SELECT * FROM GET_ROW WHERE NOT (PIECE_ROW_PROTOTIP_ID IS NULL) AND PIECE_TYPE <> 4
</cfquery>
<cfset piece_id_list_1 = ValueList(get_row_1.PIECE_ROW_ID)>
<cfquery name="get_questions_id" dbtype="query">
	SELECT QUESTION_ID FROM get_row_1 WHERE NOT(QUESTION_ID IS NULL)
    UNION ALL
    SELECT QUESTION_ID FROM get_row_4 WHERE NOT(QUESTION_ID IS NULL)
</cfquery>
<cfset question_id_list = ValueList(get_questions_id.QUESTION_ID)>
<cfif ListLen(question_id_list)>
	<cfquery name="get_questions" datasource="#dsn#">
    	SELECT QUESTION_ID, QUESTION_NAME FROM SETUP_ALTERNATIVE_QUESTIONS WHERE QUESTION_ID IN (#question_id_list#)
    </cfquery>
    <cfoutput query="get_questions">
    	<cfset 'QUESTION_NAME_#QUESTION_ID#' = QUESTION_NAME>
    </cfoutput>
</cfif>
<cfif ListLen(piece_id_list_4)>
    <cfif ListLen(stock_id_list_4)>
    	<cfif isdefined('attributes.piece_row_id') and ListLen(attributes.piece_row_id)>
            <cfloop list="#attributes.piece_row_id#" index="i">
                <cfif isdefined('ALTERNATIVE_STOCK_ID_4_#i#') and len(Evaluate('ALTERNATIVE_STOCK_ID_4_#i#'))>
                    <cfset stock_id_list_4 = ListAppend(stock_id_list_4,Evaluate('ALTERNATIVE_STOCK_ID_4_#i#'))>
                </cfif>
            </cfloop>
        </cfif>
        <cfquery name="get_price" datasource="#dsn3#">
            SELECT 
               	STOCK_ID,       
              	SALES_PRICE, 
              	SALES_PRICE_MONEY,
              	PURCHASE_PRICE,
              	PURCHASE_PRICE_MONEY,
               	COST_PRICE,
               	COST_PRICE_MONEY
            FROM
                EZGI_VIRTUAL_OFFER_PRICE_ROW
            WHERE        
				PRICE_CAT_ID = #get_product.PRICE_CAT_ID_# AND 
             	STOCK_ID IN (#stock_id_list_4#)
        </cfquery>

        <!---<cfdump var="#get_price#">--->
        <cfoutput query="get_price">
            <cfset 'SALES_PRICE_4_#STOCK_ID#' = SALES_PRICE>
            <cfset 'SALES_PRICE_MONEY_4_#STOCK_ID#' = SALES_PRICE_MONEY>
            <cfset 'PURCHASE_PRICE_4_#STOCK_ID#' = PURCHASE_PRICE>
            <cfset 'PURCHASE_PRICE_MONEY_4_#STOCK_ID#' = PURCHASE_PRICE_MONEY>
            <cfset 'COST_PRICE_4_#STOCK_ID#' = COST_PRICE>
            <cfset 'COST_PRICE_MONEY_4_#STOCK_ID#' = COST_PRICE_MONEY>
        </cfoutput>
    </cfif>
</cfif>
<cfif ListLen(piece_id_list_1)>
	<cfquery name="GET_ALTERNATIVE_1" datasource="#DSN3#">
    	SELECT 
        	PIECE_ROW_ID, 
            ALTERNATIVE_STOCK_ID, 
            ALTERNATIVE_AMOUNT_FORMUL, 
            ALTERNATIVE_AMOUNT, 
            PIECE_TYPE, 
            ALTERNATIVE_PIECE_ROW_ID, 
            PIECE_NAME
		FROM     
        	EZGI_DESGIN_ALTERNATIVE_PIECE
      	WHERE        
        	PIECE_ROW_ID IN (#piece_id_list_1#) AND
            ISNULL(IS_SPECIAL_MEASURE,0) = 0
     	UNION ALL
   		SELECT 
   		    A.PIECE_ROW_ID, 
   		    A.ALTERNATIVE_STOCK_ID, 
   		    A.ALTERNATIVE_AMOUNT_FORMUL, 
   		    A.ALTERNATIVE_AMOUNT, 
   		    A.PIECE_TYPE, 
            A.ALTERNATIVE_PIECE_ROW_ID, 
            A.PIECE_NAME
   		FROM
         	EZGI_DESGIN_ALTERNATIVE_PIECE AS A INNER JOIN
      		EZGI_VIRTUAL_OFFER_SPECIAL_ROW AS E ON A.PIECE_ROW_ID = E.ROW_ID AND A.ALTERNATIVE_PIECE_ROW_ID = E.MEASURE
		WHERE  
   			ISNULL(A.IS_SPECIAL_MEASURE,0) = 1 AND 
   		    E.TYPE = 'piece' AND 
   		    E.MEASURE_TYPE = 1 AND 
   		    E.VIRTUAL_OFFER_ID IN (SELECT VIRTUAL_OFFER_ID FROM EZGI_VIRTUAL_OFFER_ROW WHERE EZGI_ID = #attributes.ezgi_id#) AND
   		    A.PIECE_ROW_ID IN (#piece_id_list_1#)
   	</cfquery>
    <!---<cfdump var="#GET_ALTERNATIVE_1#">--->
    <cfset alternative_piece_id_list_1 = ValueList(GET_ALTERNATIVE_1.ALTERNATIVE_PIECE_ROW_ID)>
    <cfif ListLen(alternative_piece_id_list_1)>
        <cfquery name="get_price_1" datasource="#dsn3#">
            SELECT 
            	OFR.PIECE_ROW_ID,
                OFR.SALES_PRICE, 
                OFR.SALES_PRICE_MONEY,
                OFR.PURCHASE_PRICE,
                OFR.PURCHASE_PRICE_MONEY,
                OFR.COST_PRICE,
                OFR.COST_PRICE_MONEY,
                (SELECT PIECE_TYPE FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK) WHERE PIECE_ROW_ID = OFR.PIECE_ROW_ID) as PIECE_TYPE
            FROM
                EZGI_VIRTUAL_OFFER_PRICE_ROW AS OFR WITH (NOLOCK) INNER JOIN
                EZGI_VIRTUAL_OFFER_PRICE_LIST AS OFL WITH (NOLOCK) ON OFR.PRICE_CAT_ID = OFL.PRICE_CAT_ID
            WHERE        
                OFR.PRICE_CAT_ID = #get_product.PRICE_CAT_ID_# AND 
                OFL.STATUS = 1 AND 
                OFR.PIECE_ROW_ID IN (#alternative_piece_id_list_1#)
        </cfquery>
        <!---<cfdump var="#get_price_1#">--->
        <cfoutput query="get_price_1">
            <cfset 'SALES_PRICE_#get_price_1.PIECE_TYPE#_#get_price_1.PIECE_ROW_ID#' = SALES_PRICE>
            <cfset 'SALES_PRICE_MONEY_#get_price_1.PIECE_TYPE#_#get_price_1.PIECE_ROW_ID#' = SALES_PRICE_MONEY>
            <cfset 'PURCHASE_PRICE_#get_price_1.PIECE_TYPE#_#get_price_1.PIECE_ROW_ID#' = PURCHASE_PRICE>
            <cfset 'PURCHASE_PRICE_MONEY_#get_price_1.PIECE_TYPE#_#get_price_1.PIECE_ROW_ID#' = PURCHASE_PRICE_MONEY>
            <cfset 'COST_PRICE_#get_price_1.PIECE_TYPE#_#get_price_1.PIECE_ROW_ID#' = COST_PRICE>
            <cfset 'COST_PRICE_MONEY_#get_price_1.PIECE_TYPE#_#get_price_1.PIECE_ROW_ID#' = COST_PRICE_MONEY>
        </cfoutput>
  	</cfif>
</cfif>

<cfsavecontent variable="title_">
	<cfoutput>#getLang('objects',1529)# - #get_product.PRODUCT_NAME# - (#getLang('main',818)# = #get_product.SORT_NO#)</cfoutput>
</cfsavecontent>
<div class="col col-12">
    <cf_box title="#title_#">
    <cfform name="addSpecAll" id="addSpecAll" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_virtual_offer_row_spect_aktar">
        <cfinput name="ezgi_id" value="#attributes.ezgi_id#" type="hidden">
        <cfinput name="is_form_submitted" value="1" type="hidden">
        <cfinput name="upd_standart" value="1" type="hidden">
        <cfinput name="kilit_stage" value="#attributes.kilit_stage#" type="hidden">
        <cfif isdefined('attributes.revision')>
        	<cfinput type="hidden" name="revision" value="1">
        </cfif>
        <cfif isdefined('attributes.ezgi_kilit')>
        	<cfinput type="hidden" name="ezgi_kilit" value="#attributes.ezgi_kilit#">
        </cfif>
        <div class="col col-2" style="border:1px solid #ccc; height:182px; padding:0; box-sizing:border-box; overflow:hidden;">
            <div style="height:20px; line-height:20px; background-color:#ddd; text-align:center;">Müşteri Resmi</div>
                <table style="height:100%; width:100%;">
                    <tr>
                        <td id="spect_image_preview_cell" style="width:100%; height:160px; vertical-align:middle; text-align:center;" >
                        	<cfquery name="get_special_images" datasource="#dsn3#">
                            	SELECT TOP (1) 
                                	VIRTUAL_OFFER_ROW_IMPORT_FILE_ID, 
                                    EZGI_ID, 
                                    FILE_TYPE_ID, 
                                    FILE_NAME, 
                                    FILE_NAME_OLD
								FROM     
                                	EZGI_VIRTUAL_OFFER_ROW_IMPORT_FILE
								WHERE  
                                	EZGI_ID = #attributes.ezgi_id# AND
                                    FILE_TYPE_ID = 5
                            </cfquery>
                            <div style="width:100%; height:160px; display:flex; align-items:center; justify-content:center; flex-direction:column;">
                        	<cfif get_special_images.recordcount and len(get_special_images.FILE_NAME)>
                                <cfoutput><img src="/documents/temp/#get_special_images.FILE_NAME#" style="max-height:160px; max-width:160px; vertical-align:middle; cursor:pointer" onclick="openSpectImagePreview('/documents/temp/#JSStringFormat(get_special_images.FILE_NAME)#');"></cfoutput>
                            <cfelse>
                                <div id="spect_image_drop_zone" onclick="chooseSpectImage();" style="width:160px; min-height:160px; margin:0 auto; border:2px dashed #bbb; padding:10px; cursor:pointer; font-size:12px; color:#666; line-height:1.5; display:flex; align-items:center; justify-content:center; box-sizing:border-box; border-radius:6px; text-align:center; transition:all 0.15s ease;">
                                    Müşteri Resmini buraya bırak<br>veya seçmek için tıklayın
                                </div>
                                <input type="file" name="uploaded_file" id="uploaded_file" accept="image/*" style="display:none;" onchange="handleSpectImageSelect(this);">
                                <div id="spect_image_upload_status" style="display:none; margin-top:8px; color:#1d5fa7; font-weight:bold;">Resim yukleniyor...</div>
                            </cfif>
                            </div>
                        </td>
        			</tr>
              	</table>
      	</div>
        <div class="col col-4" style="border:1px solid #ccc; height:182px; padding:0; box-sizing:border-box; overflow:hidden;">
            <div style="height:20px; line-height:20px; background-color:#ddd; text-align:center;">Belgeler</div>
        </div>
        <div class="col col-4" style="border:1px solid #ccc; height:182px; padding:0; box-sizing:border-box; overflow:hidden;">
            <div style="height:20px; line-height:20px; background-color:#ddd; text-align:center;">Ölçüler</div>
        	<div class="col col-12">
            	<div class="col col-6">
                	<div class="col col-12">
                    	<label class="col col-6">Yön</label>
                    	<div class="col col-6">
                            <div class="form-group">
                            	<cfoutput>
                                    <select name="side" id="side" style="width:70px; height:20px" onChange="degisti();">
                                        <option value="1" <cfif attributes.side eq 1>selected</cfif>><cf_get_lang dictionary_id="82.Sağ"></option>
                                        <option value="2" <cfif attributes.side eq 2>selected</cfif>><cf_get_lang dictionary_id="85.Sol"></option>
                                        <option value="3" <cfif attributes.side eq 3>selected</cfif>><cf_get_lang dictionary_id="1297.Dışa Sağ"></option>
                                        <option value="4" <cfif attributes.side eq 4>selected</cfif>><cf_get_lang dictionary_id="1298.Dışa Sol"></option>
                                    </select>
                                </cfoutput>
                            </div>
                      	</div>
                 	</div>
                </div>
                <div class="col col-6">
                	<div class="col col-12">
                    	<label class="col col-6">Yükseklik (mm)</label>
                    	<div class="col col-6">
                            <div class="form-group">
                            	<select name="height" id="height" style="width:70px; height:20px; text-align:right" onChange="degisti(1);">
									<cfoutput query="get_heights">
                                        <option style="<cfif not IS_STANDART>color:red</cfif>" value="#measure#" <cfif attributes.height eq measure>selected</cfif>>#measure#</option>
                                    </cfoutput>
                                </select>
                            </div>
                      	</div>
                 	</div>
                    
                    <div class="col col-12">
                    	<label class="col col-6">Genişlik (mm)</label>
                    	<div class="col col-6">
                            <div class="form-group">
                            	<select name="width" id="width" style="width:70px; height:20px; text-align:right" onChange="degisti(2);">
									<cfoutput query="get_widths">
                                        <option style="<cfif not IS_STANDART>color:red</cfif>" value="#measure#" <cfif attributes.width eq measure>selected</cfif>>#measure#</option>
                                    </cfoutput>
                                </select>
                            </div>
                      	</div>
                 	</div>
                    
                    <div class="col col-12">
                    	<label class="col col-6">Derinlik (mm)</label>
                    	<div class="col col-6">
                            <div class="form-group">
                            	<select name="depth" id="depth" style="width:70px; height:20px; text-align:right" onChange="degisti(3);">
									<cfoutput query="get_depths">
                                        <option style="<cfif not IS_STANDART>color:red</cfif>" value="#measure#" <cfif attributes.depth eq measure>selected</cfif>>#measure#</option>
                                    </cfoutput>
                                </select>
                            </div>
                      	</div>
                 	</div>
                    
                </div>
         	</div>
        </div>
        <div class="col col-2" style="border:1px solid #ccc; height:182px; padding:0; box-sizing:border-box; overflow:hidden;">
            <div style="height:20px; line-height:20px; background-color:#ddd; text-align:center;">Ürün Resmi</div>
        	<table style="width:100%;">
                <tr>
                	<td style="height:160px; width:100%; text-align:center; vertical-align:middle;">
                        <div style="width:100%; height:160px; display:flex; align-items:center; justify-content:center;">
                    	<cfif len(get_image.PATH)>
                        	<cfoutput>
                    		<img src="/documents/product/#get_image.PATH#" style="max-height:160px; max-width:160px; vertical-align:middle">
                            </cfoutput>
                        </cfif>
                        </div>
                    </td>
              	</tr>
          	</table>
        </div>
        <div class="col col-12">
            <table style="width:100%;">
            	<tr>
                 	<td>
                     	<cf_flat_list>
                                <thead>
                                    <tr>
                                        <th style="width:30px"><cf_get_lang_main no='1165.Sıra'></th>
                                        <th><cf_get_lang_main no='809.Ürün Adı'></th>
                                        <th style="width:80px"><cf_get_lang dictionary_id="36454.Alternatif Sorusu"></th>
                                        <th style="text-align:200px"><cf_get_lang dictionary_id="45311.Alternatif Ürünler"></th>
                                        <th style="width:120px; text-align:center" nowrap><cf_get_lang_main no='2902.Boy'>-<cf_get_lang_main no='2901.En'>(mm)</th>
                                        <th style="width:60px"><cf_get_lang_main no='223.Miktar'></th>
                                        <th style="width:60px"><cf_get_lang_main no='223.Miktar'>2</th>
                                        <th style="width:70px"><cf_get_lang_main no='672.Fiyat'></th>
                                        <th style="width:40px"><cf_get_lang_main no='265.Döviz'></th>
                                        <th style="width:70px"><span style="color:red">Özel Farkı</span></th>
                                        <th style="width:70px"><cf_get_lang_main no='80.Toplam'></th>
                                        <th style="width:40px"><cf_get_lang_main no='265.Döviz'></th>
                                    </tr>
                                </thead>
                                <tbody>
                                	<cfset ozel_toplam = 0>
                                    <cfset ozel_bayi_toplam = 0>
                                	<cfset toplam = 0>
                                    <cfset purchase_total = 0>
                                    <cfset cost_total = 0>
                                    <cfif GET_MAIN_ROW.recordcount>
                                    	<cfoutput>
                                            <tr>
                                                <td style="text-align:right; font-weight:bold">0</td>
                                                <td style="text-align:left; font-weight:bold" nowrap>#GET_MAIN_ROW.DESIGN_MAIN_NAME#</td>
                                                <td style="text-align:left; font-weight:bold">Ana Ürün</td>
                                                <td></td>
                                                <td></td>
                                                <td style="text-align:right; font-weight:bold">
                                                	<input type="text" name="main_amount" id="main_amount" value="#TlFormat(1,4)#" style="text-align:right; width:60px; height:20px; font-weight:bold;border:none" readonly>
                                                </td>
                                                <td style="text-align:right; font-weight:bold">
                                                	<input type="text" name="main_amount2" id="main_amount2" value="#TlFormat(1,4)#" style="text-align:right; width:60px; height:20px; font-weight:bold;border:none" readonly>
                                                </td>
                                                <td style="text-align:right; font-weight:bold">
                                                    <cfif get_main_price.recordcount>
                                                        #TlFormat(get_main_price.SALES_PRICE,2)#
                                                    <cfelse>
                                                        <span style="color:red">
                                                            #TlFormat(0,2)#
                                                        </span>
                                                    </cfif>
                                                </td>
                                                <td style="text-align:left; font-weight:bold">
                                                    <cfif get_main_price.recordcount>
                                                        #get_main_price.SALES_PRICE_MONEY#
                                                    <cfelse>
                                                        <span style="color:red">
                                                            #session.ep.money#
                                                        </span>
                                                    </cfif>
                                                </td>
                                                <td style="text-align:right; color:red">
                                                	<cfif height_is_standart eq 0 or width_is_standart eq 0 or depth_is_standart eq 0><!--- Ana Ürün Yükseklik/Genişlik/Derinlik Özel Ölçüde Devreye Giriyor--->
                                                    	<cfif GET_MAIN_ROW.PRIVATE_PRICE_TYPE eq 1> <!---Özel Fiyat Tipi Sabit İse--->
                                                         	<cfif isdefined('RATE2_#GET_MAIN_ROW.PRIVATE_PRICE_MONEY#')>
                                                        		<cfset ozel_toplam = ozel_toplam+((GET_MAIN_ROW.PRIVATE_PRICE*Evaluate('RATE2_#GET_MAIN_ROW.PRIVATE_PRICE_MONEY#'))+(get_main_price.SALES_PRICE*Evaluate('RATE2_#GET_MAIN_ROW.PRIVATE_PRICE_MONEY#')))><!---Ana Ürün İçin Satış Özel Fiyatı--->
                                                                <cfset ozel_bayi_toplam = ozel_bayi_toplam+((GET_MAIN_ROW.PRIVATE_PRICE*Evaluate('RATE2_#GET_MAIN_ROW.PRIVATE_PRICE_MONEY#'))+(get_main_price.PURCHASE_PRICE*Evaluate('RATE2_#GET_MAIN_ROW.PRIVATE_PRICE_MONEY#')))><!---Ana Ürün İçin Bayi Alış Özel Fiyatı--->
                                                                        #TlFormat((PRIVATE_PRICE*Evaluate('RATE2_#GET_MAIN_ROW.PRIVATE_PRICE_MONEY#'))+(get_main_price.SALES_PRICE*Evaluate('RATE2_#GET_MAIN_ROW.PRIVATE_PRICE_MONEY#')),2)#
                                                       		</cfif>
                                                      	<cfelseif GET_MAIN_ROW.PRIVATE_PRICE_TYPE eq 2><!---Özel Fiyat Tipi Yüzde İse--->
                                                        	<cfif len(GET_MAIN_ROW.PRIVATE_PRICE)>
                                                      			<cfif isnumeric(get_main_price.SALES_PRICE)><!---Satış Fiyatı Hesapla ve Göster--->
                                                      				<cfset ozel_toplam = ozel_toplam+((GET_MAIN_ROW.PRIVATE_PRICE/100)*get_main_price.SALES_PRICE)>
                                                                    #TlFormat((GET_MAIN_ROW.PRIVATE_PRICE/100)*get_main_price.SALES_PRICE,2)#
                                                                <cfelse>
                                                                	#TlFormat(0,2)#
                                                                </cfif>
                                                                <cfif isnumeric(get_main_price.PURCHASE_PRICE)><!---Bayi Alış Fiyatı Hesapla--->
                                                      				<cfset ozel_bayi_toplam = ozel_bayi_toplam+((GET_MAIN_ROW.PRIVATE_PRICE/100)*get_main_price.PURCHASE_PRICE)>
                                                                </cfif>
                                                     		<cfelse>
                                                            	<script type="text/javascript">
																	alert("Dikkat : Özel Ölçü İçin Fark Fiyatı Girilmemiş.!");
																	window.close()
																</script>
                                                                <cfabort>
                                                            </cfif>
                                                        <cfelseif GET_MAIN_ROW.PRIVATE_PRICE_TYPE eq 3><!---Özel Fiyat Tipi Ölçü adı tablosuna bak ise--->
                                                            <cfif height_private_price_type eq 1 and height_is_standart eq 0> <!---Yükseklik İçin Ölçü adları tablosundaki Özel Fiyat Tipi Sabit İse--->
                                                                <cfif isdefined('RATE2_#session.ep.money#')>
                                                                    <cfset ozel_toplam = ozel_toplam+((height_private_price*Evaluate('RATE2_#session.ep.money#')))><!---Ana Ürün İçin Satış Özel Fiyatı--->
                                                                    <cfset ozel_bayi_toplam = ozel_bayi_toplam+((height_private_price*Evaluate('RATE2_#session.ep.money#')))><!---Ana Ürün İçin Bayi Alış Özel Fiyatı--->
                                                                    <!--- #TlFormat((height_private_price*Evaluate('RATE2_#session.ep.money#')),2)# --->
                                                                </cfif>

                                                            <cfelseif height_private_price_type eq 2 and height_is_standart eq 0><!--- Yükseklik İçin Ölçü adları tablosundaki Özel Fiyat Tipi Yüzde İse--->
                                                                <cfif len(height_private_rate)>
                                                                    <cfif isnumeric(get_main_price.SALES_PRICE)><!---Satış Fiyatı Hesapla ve Göster--->
                                                                        <cfset ozel_toplam = ozel_toplam+((height_private_rate/100)*get_main_price.SALES_PRICE)>
                                                                    </cfif>
                                                                    <cfif isnumeric(get_main_price.PURCHASE_PRICE)><!---Bayi Alış Fiyatı Hesapla--->
                                                                        <cfset ozel_bayi_toplam = ozel_bayi_toplam+((height_private_rate/100)*get_main_price.PURCHASE_PRICE)>
                                                                    </cfif>
                                                                <cfelse>
                                                                    <script type="text/javascript">
                                                                        alert("Dikkat : Özel Ölçü İçin Fark Fiyatı Girilmemiş.!");
                                                                        window.close()
                                                                    </script>
                                                                    <cfabort>
                                                                </cfif>
                                                            </cfif>
                                                            <cfif width_private_price_type eq 1 and width_is_standart eq 0> <!---Genişlik İçin Ölçü adları tablosundaki Özel Fiyat Tipi Sabit İse--->
                                                                <cfif isdefined('RATE2_#session.ep.money#')>
                                                                    <cfset ozel_toplam = ozel_toplam+((width_private_price*Evaluate('RATE2_#session.ep.money#')))><!---Ana Ürün İçin Satış Özel Fiyatı--->
                                                                    <cfset ozel_bayi_toplam = ozel_bayi_toplam+((width_private_price*Evaluate('RATE2_#session.ep.money#')))><!---Ana Ürün İçin Bayi Alış Özel Fiyatı--->
                                                                </cfif>

                                                            <cfelseif width_private_price_type eq 2 and width_is_standart eq 0><!--- Genişlik İçin Ölçü adları tablosundaki Özel Fiyat Tipi Yüzde İse--->
                                                                <cfif len(width_private_rate)>
                                                                    <cfif isnumeric(get_main_price.SALES_PRICE)><!---Satış Fiyatı Hesapla ve Göster--->
                                                                        <cfset ozel_toplam = ozel_toplam+((width_private_rate/100)*get_main_price.SALES_PRICE)>
                                                                    </cfif>
                                                                    <cfif isnumeric(get_main_price.PURCHASE_PRICE)><!---Bayi Alış Fiyatı Hesapla--->
                                                                        <cfset ozel_bayi_toplam = ozel_bayi_toplam+((width_private_rate/100)*get_main_price.PURCHASE_PRICE)>
                                                                    </cfif>
                                                                <cfelse>
                                                                    <script type="text/javascript">
                                                                        alert("Dikkat : Özel Ölçü İçin Fark Fiyatı Girilmemiş.!");
                                                                        window.close()
                                                                    </script>
                                                                    <cfabort>
                                                                </cfif>
                                                            </cfif>
                                                            <cfif depth_private_price_type eq 1 and depth_is_standart eq 0> <!---Genişlik İçin Ölçü adları tablosundaki Özel Fiyat Tipi Sabit İse--->
                                                                <cfif isdefined('RATE2_#session.ep.money#')>
                                                                    <cfset ozel_toplam = ozel_toplam+((depth_private_price*Evaluate('RATE2_#session.ep.money#')))><!---Ana Ürün İçin Satış Özel Fiyatı--->
                                                                    <cfset ozel_bayi_toplam = ozel_bayi_toplam+((depth_private_price*Evaluate('RATE2_#session.ep.money#')))><!---Ana Ürün İçin Bayi Alış Özel Fiyatı--->
                                                                </cfif>

                                                            <cfelseif depth_private_price_type eq 2 and depth_is_standart eq 0><!--- Genişlik İçin Ölçü adları tablosundaki Özel Fiyat Tipi Yüzde İse--->
                                                                <cfif len(depth_private_rate)>
                                                                    <cfif isnumeric(get_main_price.SALES_PRICE)><!---Satış Fiyatı Hesapla ve Göster--->
                                                                        <cfset ozel_toplam = ozel_toplam+((depth_private_rate/100)*get_main_price.SALES_PRICE)>
                                                                    </cfif>
                                                                    <cfif isnumeric(get_main_price.PURCHASE_PRICE)><!---Bayi Alış Fiyatı Hesapla--->
                                                                        <cfset ozel_bayi_toplam = ozel_bayi_toplam+((depth_private_rate/100)*get_main_price.PURCHASE_PRICE)>
                                                                    </cfif>
                                                                <cfelse>
                                                                    <script type="text/javascript">
                                                                        alert("Dikkat : Özel Ölçü İçin Fark Fiyatı Girilmemiş.!");
                                                                        window.close()
                                                                    </script>
                                                                    <cfabort>
                                                                </cfif>
                                                            </cfif>
                                                            #TlFormat(ozel_toplam,2)#
                                                        </cfif>
                                                    </cfif>
                                                </td>
                                                <td style="text-align:right; font-weight:bold">
                                                    <cfif get_main_price.recordcount>
                                                        #TlFormat(get_main_price.SALES_PRICE,2)#
                                                        <cfset toplam = toplam+get_main_price.SALES_PRICE>
                                                        <cfset purchase_total = purchase_total+get_main_price.PURCHASE_PRICE>
                                                        <cfset cost_total = cost_total+get_main_price.COST_PRICE>
                                                    <cfelse>
                                                        #TlFormat(0,2)#
                                                    </cfif>
                                                </td>
                                                <td style="text-align:left; font-weight:bold">
                                                    <cfif get_main_price.recordcount>
                                                        #get_main_price.SALES_PRICE_MONEY#
                                                    <cfelse>
                                                        <span style="color:red">
                                                            #session.ep.money#
                                                        </span>
                                                    </cfif>
                                                </td>
                                            </tr>


                                            <cfinput type="hidden" name="stock_id_0" value="#GET_MAIN_ROW.DESIGN_MAIN_RELATED_ID#">
                                            <cfinput type="hidden" name="piece_row_id" value="0">
                                            <cfinput type="hidden" name="PIECE_AMOUNT_0" value="1">
                                            <cfinput type="hidden" name="piece_type_0" value="0">
                                            <cfinput type="hidden" name="IS_PRICE_CHANGE_0" value="0">
                                            <cfinput type="hidden" name="IS_AMOUNT_CHANGE_0" value="0">
                                            <cfinput type="hidden" name="QUESTION_ID_0" value="0">
                                            <cfinput type="hidden" name="BOY_FORMUL_0" value="">
                                            <cfinput type="hidden" name="EN_FORMUL_0" value="">
                                            <cfinput type="hidden" name="AMOUNT_FORMUL_0" value="1">
                                            <cfinput type="hidden" name="PRICE_FORMUL_0" value="">
                                            
                                        	<cfinput type="hidden" name="sales_price_0" value="#get_main_price.SALES_PRICE#">
                                            <cfinput type="hidden" name="sales_price_money_0" value="#get_main_price.SALES_PRICE_MONEY#">
                                            <cfinput type="hidden" name="purchase_price_0" value="#get_main_price.PURCHASE_PRICE#">
                                            <cfinput type="hidden" name="purchase_price_money_0" value="#get_main_price.PURCHASE_PRICE_MONEY#">
                                            <cfinput type="hidden" name="cost_price_0" value="#get_main_price.COST_PRICE#">
                                            <cfinput type="hidden" name="cost_price_money_0" value="#get_main_price.COST_PRICE_MONEY#">
                                            <cfinput type="hidden" name="PRIVATE_PRICE_MONEY_0" value="#session.ep.money#">
                                         	<cfinput type="hidden" name="PRIVATE_PRICE_TYPE_0" value="#GET_MAIN_ROW.PRIVATE_PRICE_TYPE#">
                                           	<cfinput type="hidden" name="PRIVATE_PRICE_0" value="#GET_MAIN_ROW.PRIVATE_PRICE#">
                                        </cfoutput>
                                    </cfif>
                                	<cfif get_row.recordcount>
                                    	<cfset fuga = ''>
                                    	<cfoutput query="get_row">
                                        	
                                        	<cfinput type="hidden" name="piece_row_id" value="#get_row.PIECE_ROW_ID#">
                                            <cfinput type="hidden" name="piece_type_#get_row.PIECE_ROW_ID#" value="#get_row.PIECE_TYPE#">
                                            <cfinput type="hidden" name="IS_PRICE_CHANGE_#get_row.PIECE_ROW_ID#" value="#IS_PRICE_CHANGE#">
                                            <cfinput type="hidden" name="IS_AMOUNT_CHANGE_#get_row.PIECE_ROW_ID#" value="#IS_AMOUNT_CHANGE#">
                                            <cfinput type="hidden" name="QUESTION_ID_#get_row.PIECE_ROW_ID#" value="#QUESTION_ID#">
                                            <cfinput type="hidden" name="BOY_FORMUL_#get_row.PIECE_ROW_ID#" value="#BOY_FORMUL#">
                                            <cfinput type="hidden" name="EN_FORMUL_#get_row.PIECE_ROW_ID#" value="#EN_FORMUL#">
                                            <cfinput type="hidden" name="AMOUNT_FORMUL_#get_row.PIECE_ROW_ID#" value="#AMOUNT_FORMUL#">
                                            <cfinput type="hidden" name="PRICE_FORMUL_#get_row.PIECE_ROW_ID#" value="#PRICE_FORMUL#">
                                            
                                            <cfparam name="attributes.PIECE_AMOUNT_#get_row.PIECE_ROW_ID#" default="#TlFormat(get_row.piece_amount,4)#">
                                            <cfset currentAlternativeKey = "alternative_stock_id_#get_row.PIECE_TYPE#_#get_row.PIECE_ROW_ID#">
                                            <cfif !structKeyExists(attributes, currentAlternativeKey)>
                                            	<cfset attributes[currentAlternativeKey] = 0>
                                            </cfif>
                                            <cfset quantity = Filternum(Evaluate('attributes.PIECE_AMOUNT_#get_row.PIECE_ROW_ID#'),4)>
                                            <cfset amount = Filternum(Evaluate('attributes.PIECE_AMOUNT_#get_row.PIECE_ROW_ID#'),4)>
                                            <cfif isdefined('Package_ROW_ID')>
												<cfif fuga neq Package_ROW_ID>
                                                    <cfset fuga = Package_ROW_ID>
                                                    <tr>
                                                        <td colspan="13"><hr /></td>
                                                    </tr>
                                                </cfif>
                                            </cfif>
                                        	<tr>
                                            	<td style="text-align:right; font-weight:bold">#currentrow#</td>
                                                
                                                <td style="text-align:left">
                                                	<input type="text" border="0" name="ezg_piece_name" value="#PIECE_NAME#" style="border:none; width:200px; height:20px" readonly>
                                                </td>
                                                <td style="text-align:left">
                                                	<cfif isdefined('QUESTION_NAME_#QUESTION_ID#')>
                                                		#Evaluate('QUESTION_NAME_#QUESTION_ID#')#
                                                	</cfif>
                                                </td>
                                                <td style="text-align:left" nowrap>
                                                	<cfif isdefined('QUESTION_NAME_#QUESTION_ID#')>
														<cfif PIECE_TYPE eq 4>
                                                            <img src="images/listele.gif" id="listele_#currentrow#" onClick="select_goster(#currentrow#,#get_row.PIECE_ROW_ID#)">
                                                            <input type="text" name="alernative_select_#currentrow#" id="alernative_select_#currentrow#" value="" onBlur="bul_select(#currentrow#,#get_row.PIECE_ROW_ID#)" style="display:none; width:30px; height:20px;border-color:silver">
                                                            <input type="hidden" name="select_key_#currentrow#" id="select_key_#currentrow#" value="0">
                                                            <select name="alternative_stock_id_4_#get_row.PIECE_ROW_ID#" id="alternative_stock_id_4_#get_row.PIECE_ROW_ID#" data-question-id="#QUESTION_ID#" style="width:180px; height:25px;border-color:silver" onChange="syncAlternativeAnswers(this);degisti();" >													
                                                                <cfquery name="alternative_row" datasource="#DSN3#">
                                                                    SELECT 
                                                                        PIECE_ROW_ID, 
                                                                        ALTERNATIVE_STOCK_ID, 
                                                                        ALTERNATIVE_AMOUNT_FORMUL, 
                                                                        ALTERNATIVE_AMOUNT, 
                                                                        PRODUCT_NAME, 
                                                                        PIECE_TYPE
                                                                    FROM     
                                                                        EZGI_DESIGN_ALTERNATIVE_STOCKS
                                                                    WHERE
                                                                        PIECE_ROW_ID = #val(get_row.PIECE_ROW_ID)# AND
                                                                  		ISNULL(IS_SPECIAL_MEASURE,0) = 0
                                                                	UNION ALL
                                                                	SELECT 
                                                                     	A.PIECE_ROW_ID, 
                                                                      	A.ALTERNATIVE_STOCK_ID, 
                                                                      	A.ALTERNATIVE_AMOUNT_FORMUL, 
                                                                     	A.ALTERNATIVE_AMOUNT, 
                                                                     	A.PRODUCT_NAME, 
                                                                     	A.PIECE_TYPE
                                                                	FROM
                                                                   		EZGI_DESIGN_ALTERNATIVE_STOCKS AS A INNER JOIN
                  														EZGI_VIRTUAL_OFFER_SPECIAL_ROW AS E ON A.PIECE_ROW_ID = E.ROW_ID AND A.ALTERNATIVE_STOCK_ID = E.MEASURE
																	WHERE  
                                                                      	ISNULL(A.IS_SPECIAL_MEASURE,0) = 1 AND 
                                                                      	E.TYPE = N'piece' AND 
                                                                     	E.MEASURE_TYPE = 4 AND 
                                                                      	E.VIRTUAL_OFFER_ID IN (SELECT VIRTUAL_OFFER_ID FROM EZGI_VIRTUAL_OFFER_ROW WHERE EZGI_ID = #attributes.ezgi_id#) AND
                                                                      	A.PIECE_ROW_ID = #val(get_row.PIECE_ROW_ID)#
                                                                </cfquery>
                                                                <cfif alternative_row.recordcount lte 2000>
                                                                	<cfif alternative_row.recordcount neq 1>
                                                                    	<option value="0"><cf_get_lang_main no='322.Seçiniz'></option>
                                                                    </cfif>
                                                                    <cfloop query="alternative_row">
                                                                        <option value="#ALTERNATIVE_STOCK_ID#" <cfif structKeyExists(attributes, "alternative_stock_id_4_#get_row.PIECE_ROW_ID#") and attributes["alternative_stock_id_4_#get_row.PIECE_ROW_ID#"] eq ALTERNATIVE_STOCK_ID>selected style="font-weight:bold"</cfif>>#PRODUCT_NAME#</option>
                                                                    </cfloop>
                                                                <cfelse>
                                                                	<cfif structKeyExists(attributes, "alternative_stock_id_4_#get_row.PIECE_ROW_ID#") and attributes["alternative_stock_id_4_#get_row.PIECE_ROW_ID#"] gt 0>												
                                                                        <cfquery name="alternative_row" datasource="#DSN3#">
                                                                            SELECT 
                                                                                PIECE_ROW_ID, 
                                                                                ALTERNATIVE_STOCK_ID, 
                                                                                ALTERNATIVE_AMOUNT_FORMUL, 
                                                                                ALTERNATIVE_AMOUNT, 
                                                                                PRODUCT_NAME, 
                                                                                PIECE_TYPE
                                                                            FROM     
                                                                                EZGI_DESIGN_ALTERNATIVE_STOCKS
                                                                            WHERE
                                                                                PIECE_ROW_ID = #val(get_row.PIECE_ROW_ID)# AND
                                                                                ALTERNATIVE_STOCK_ID = #attributes["alternative_stock_id_4_#get_row.PIECE_ROW_ID#"]# AND
                                                                             	ISNULL(IS_SPECIAL_MEASURE,0) = 0
                                                                         	UNION ALL
                                                                         	SELECT 
                                                                                A.PIECE_ROW_ID, 
                                                                                A.ALTERNATIVE_STOCK_ID, 
                                                                                A.ALTERNATIVE_AMOUNT_FORMUL, 
                                                                                A.ALTERNATIVE_AMOUNT, 
                                                                                A.PRODUCT_NAME, 
                                                                                A.PIECE_TYPE
                                                                            FROM
                                                                           		EZGI_DESIGN_ALTERNATIVE_STOCKS AS A INNER JOIN
                  																EZGI_VIRTUAL_OFFER_SPECIAL_ROW AS E ON A.PIECE_ROW_ID = E.ROW_ID AND A.ALTERNATIVE_STOCK_ID = E.MEASURE
																			WHERE  
                                                                            	ISNULL(A.IS_SPECIAL_MEASURE,0) = 1 AND 
                                                                                E.TYPE = N'piece' AND 
                                                                                E.MEASURE_TYPE = 4 AND 
                                                                             	E.VIRTUAL_OFFER_ID IN (SELECT VIRTUAL_OFFER_ID FROM EZGI_VIRTUAL_OFFER_ROW WHERE EZGI_ID = #attributes.ezgi_id#) AND
                                                                                A.PIECE_ROW_ID = #val(get_row.PIECE_ROW_ID)# AND
                                                                                A.ALTERNATIVE_STOCK_ID = #attributes["alternative_stock_id_4_#get_row.PIECE_ROW_ID#"]#
                                                                        </cfquery>
                                                                        <cfloop query="alternative_row">
                                                                    		<option value="#ALTERNATIVE_STOCK_ID#" <cfif structKeyExists(attributes, "alternative_stock_id_4_#get_row.PIECE_ROW_ID#") and attributes["alternative_stock_id_4_#get_row.PIECE_ROW_ID#"] eq ALTERNATIVE_STOCK_ID>selected style="font-weight:bold"</cfif>>#PRODUCT_NAME#</option>
                                                                      	</cfloop>
                                                                    </cfif>
                                                                	<option value="0"><cf_get_lang dictionary_id="44674.Fitre Ederek Arayın"></option>
                                                                </cfif>
                                                            </select>
                                                            
                                                        <cfelse>
                                                        	<cfset alternativeRowCount = 0>
                                                            <cfloop query="GET_ALTERNATIVE_1">
                                                            	<cfif val(GET_ALTERNATIVE_1.PIECE_ROW_ID) eq val(get_row.PIECE_ROW_ID)>
                                                                	<cfset alternativeRowCount = alternativeRowCount + 1>
                                                                </cfif>
                                                            </cfloop>
                                                            <select name="alternative_stock_id_#get_row.PIECE_TYPE#_#get_row.PIECE_ROW_ID#" id="alternative_stock_id_#get_row.PIECE_TYPE#_#get_row.PIECE_ROW_ID#" data-question-id="#QUESTION_ID#" style="width:200px; height:25px;border-color:silver" onChange="syncAlternativeAnswers(this);degisti();">
                                                            	<cfif alternativeRowCount neq 1>
                                                                	<option value="0"><cf_get_lang_main no='322.Seçiniz'></option>
                                                                </cfif>
                                                                <cfloop query="GET_ALTERNATIVE_1">
                                                                    <cfif val(GET_ALTERNATIVE_1.PIECE_ROW_ID) eq val(get_row.PIECE_ROW_ID)>
                                                                    	<option value="#GET_ALTERNATIVE_1.ALTERNATIVE_PIECE_ROW_ID#" <cfif structKeyExists(attributes, currentAlternativeKey) and attributes[currentAlternativeKey] eq GET_ALTERNATIVE_1.ALTERNATIVE_PIECE_ROW_ID>selected style="font-weight:bold"</cfif>>#GET_ALTERNATIVE_1.PIECE_NAME#</option>
                                                                    </cfif>
                                                                </cfloop>
                                                            </select>
                                                        </cfif>
                                                    </cfif>
                                                </td>
                                                <td style="text-align:center" nowrap="nowrap">
                                                	<cfif len(boy_formul)>
                                                    	<cfset boy = Evaluate('#boy_formul#')>
                                                    	<input name="boy_#get_row.PIECE_ROW_ID#" type="text" id="boy_#get_row.PIECE_ROW_ID#" title="#boy_formul#" value="#boy#" style="width:40px; height:20px; text-align:right;border:none" readonly onChange="degisti();">
                                                    </cfif>
                                                	<cfif len(en_formul)>
                                                    	<cfset en = Evaluate('#en_formul#')>
                                                    	<input name="en_#get_row.PIECE_ROW_ID#" type="text" id="en_#get_row.PIECE_ROW_ID#" title="#en_formul#" value="#en#" style="width:40px; height:20px; text-align:right;border:none"  readonly onChange="degisti();">
                                                    </cfif>
                                                </td>
                                                <td style="text-align:right">
                                                	<input type="text" name="piece_amount_#get_row.PIECE_ROW_ID#" id="piece_amount_#get_row.PIECE_ROW_ID#" value="#TlFormat(quantity,4)#" style="text-align:right; width:60px; height:20px;border:none" onChange="degisti();" <cfif attributes.kilit_stage or IS_AMOUNT_CHANGE eq 0>readonly</cfif>>
                                                
                                                </td>
                                                
                                                <td style="text-align:right" title="#Evaluate('amount_formul')#">
                                                    <cfif len(amount_formul)>
                                                    	<cftry>
                                                    		<cfset amount2 = Evaluate('#amount_formul#')>
                                                        	<cfcatch type="Any">
																	<cfoutput>#amount_formul#</cfoutput>
                                                                <cfabort>
                                                            </cfcatch>
                                                        </cftry>
                                                    	<input name="amount2_#get_row.PIECE_ROW_ID#" type="text" id="amount2_#get_row.PIECE_ROW_ID#" value="#TlFormat(amount2,4)#" style="width:60px; height:20px; text-align:right;border:none" onChange="degisti();" <cfif attributes.kilit_stage or IS_AMOUNT_CHANGE eq 0>readonly</cfif>>
                                                    </cfif>
                                                </td>
                                                <td style="text-align:right">
                                                	<cfset selected_alternative_id = 0>
                                                	<cfif isdefined('QUESTION_NAME_#QUESTION_ID#')>
                                                    	<cfif PIECE_TYPE eq 4>
                                                        	<cfif structKeyExists(attributes, "alternative_stock_id_4_#get_row.PIECE_ROW_ID#") and len(attributes["alternative_stock_id_4_#get_row.PIECE_ROW_ID#"])>
                                                            	<cfset selected_alternative_id = attributes["alternative_stock_id_4_#get_row.PIECE_ROW_ID#"]>
                                                            </cfif>
                                                        <cfelse>
                                                        	<cfif structKeyExists(attributes, currentAlternativeKey) and len(attributes[currentAlternativeKey])>
                                                            	<cfset selected_alternative_id = attributes[currentAlternativeKey]>
                                                            </cfif>
                                                        </cfif>
                                                    </cfif>
                                                	<cfif isdefined('QUESTION_NAME_#QUESTION_ID#') and IS_PRICE_CHANGE eq 0><!---Alternatif Soru Varsa ve Fiyat Göster İse--->
														<cfif PIECE_TYPE eq 4>
                                                            <cfif structKeyExists(variables, "SALES_PRICE_4_#selected_alternative_id#")>
                                                                #TlFormat(variables["SALES_PRICE_4_#selected_alternative_id#"],2)#
                                                                <cfset sales_price_row = variables["SALES_PRICE_4_#selected_alternative_id#"]>
                                                                <cfset purchase_price_row = variables["PURCHASE_PRICE_4_#selected_alternative_id#"]>
                                                                <cfset cost_price_row = variables["COST_PRICE_4_#selected_alternative_id#"]>
                                                                
                                                            <cfelse>
                                                                <span style="color:red">
                                                                    #TlFormat(0,2)#
                                                                </span>
                                                                <cfset sales_price_row = 0>
                                                                <cfset purchase_price_row = 0>
                                                                <cfset cost_price_row = 0>
                                                            </cfif>
                                                        <cfelse>
                                                            <cfif structKeyExists(variables, "SALES_PRICE_#get_row.PIECE_TYPE#_#selected_alternative_id#")>
                                                                #TlFormat(variables["SALES_PRICE_#get_row.PIECE_TYPE#_#selected_alternative_id#"],2)#
                                                                <cfset sales_price_row = variables["SALES_PRICE_#get_row.PIECE_TYPE#_#selected_alternative_id#"]>
                                                                <cfset purchase_price_row = variables["PURCHASE_PRICE_#get_row.PIECE_TYPE#_#selected_alternative_id#"]>
                                                                <cfset cost_price_row = variables["COST_PRICE_#get_row.PIECE_TYPE#_#selected_alternative_id#"]>
                                                            <cfelse>
                                                                <span style="color:red">
                                                                    #TlFormat(0,2)#
                                                                </span>
                                                                <cfset sales_price_row = 0>
                                                                <cfset purchase_price_row = 0>
                                                                <cfset cost_price_row = 0>
                                                            </cfif>
                                                        </cfif>
                                                  	<cfelseif not isdefined('QUESTION_NAME_#QUESTION_ID#') and IS_PRICE_CHANGE eq 0> <!---Alternatif Soru Yoksa ve Fiyat Göster İse--->
                                                    	<cfif PIECE_TYPE eq 4>
                                                        	 <cfif structKeyExists(variables, "SALES_PRICE_4_#PIECE_RELATED_ID#")>
                                                             	#TlFormat(variables["SALES_PRICE_4_#PIECE_RELATED_ID#"],2)#

																<cfset sales_price_row = variables["SALES_PRICE_4_#PIECE_RELATED_ID#"]>
                                                                <cfset purchase_price_row = variables["PURCHASE_PRICE_4_#PIECE_RELATED_ID#"]>
                                                                <cfset cost_price_row = variables["COST_PRICE_4_#PIECE_RELATED_ID#"]>
                                                             <cfelse>
                                                             	#TlFormat(0,2)#
																<cfset sales_price_row = 0>
                                                                <cfset purchase_price_row = 0>
                                                                <cfset cost_price_row = 0>
                                                             </cfif>
                                                        <cfelse>
                                                        	#TlFormat(0,2)#
                                                            <cfset sales_price_row = 0>
                                                            <cfset purchase_price_row = 0>
                                                            <cfset cost_price_row = 0>
                                                        </cfif>
                                                    <cfelse><!---Fiyat Göster Değil İse--->
                                                    	#TlFormat(0,2)#
                                                      	<cfset sales_price_row = 0>
                                                     	<cfset purchase_price_row = 0>
                                                       	<cfset cost_price_row = 0>
                                                    </cfif>
                                               	</td>
                                                <td style="text-align:left">
                                                	<cfif isdefined('QUESTION_NAME_#QUESTION_ID#')>
														<cfif PIECE_TYPE eq 4>
                                                            <cfif structKeyExists(variables, "SALES_PRICE_MONEY_4_#selected_alternative_id#")>
                                                                #variables["SALES_PRICE_MONEY_4_#selected_alternative_id#"]#
                                                                <cfset sales_PRICE_ROW_MONEY = variables["SALES_PRICE_MONEY_4_#selected_alternative_id#"]>
                                                                <cfset purchase_price_row_money = variables["PURCHASE_PRICE_MONEY_4_#selected_alternative_id#"]>
                                                                <cfset cost_price_row_money = variables["COST_PRICE_MONEY_4_#selected_alternative_id#"]>
                                                            <cfelse>
                                                                <cfif get_main_price.recordcount>
                                                                    <span style="color:red">#get_main_price.SALES_PRICE_MONEY#</span>
                                                                    <cfset sales_PRICE_ROW_MONEY = get_main_price.SALES_PRICE_MONEY>
                                                                    <cfset purchase_price_row_money = get_main_price.SALES_PRICE_MONEY>
                                                                    <cfset cost_price_row_money = get_main_price.SALES_PRICE_MONEY>
                                                                <cfelse>
                                                                    <span style="color:red">#session.ep.money#</span>
                                                                    <cfset sales_PRICE_ROW_MONEY = session.ep.money>
                                                                    <cfset purchase_price_row_money = session.ep.money>
                                                                    <cfset cost_price_row_money = session.ep.money>
                                                                </cfif>
                                                            </cfif>
                                                        <cfelse>
                                                            <cfif structKeyExists(variables, "SALES_PRICE_MONEY_#get_row.PIECE_TYPE#_#selected_alternative_id#")>
                                                                #variables["SALES_PRICE_MONEY_#get_row.PIECE_TYPE#_#selected_alternative_id#"]#
                                                                <cfset sales_PRICE_ROW_MONEY = variables["SALES_PRICE_MONEY_#get_row.PIECE_TYPE#_#selected_alternative_id#"]>
                                                                <cfset purchase_price_row_money = variables["PURCHASE_PRICE_MONEY_#get_row.PIECE_TYPE#_#selected_alternative_id#"]>
                                                                <cfset cost_price_row_money = variables["COST_PRICE_MONEY_#get_row.PIECE_TYPE#_#selected_alternative_id#"]>
                                                            <cfelse>
                                                                <cfif get_main_price.recordcount>
                                                                    <span style="color:red">#get_main_price.SALES_PRICE_MONEY#</span>
                                                                    <cfset sales_PRICE_ROW_MONEY = get_main_price.SALES_PRICE_MONEY>
                                                                    <cfset purchase_price_row_money = get_main_price.SALES_PRICE_MONEY>
                                                                    <cfset cost_price_row_money = get_main_price.SALES_PRICE_MONEY>
                                                                <cfelse>
                                                                    <span style="color:red">#session.ep.money#</span>
                                                                    <cfset sales_PRICE_ROW_MONEY = session.ep.money>

                                                                    <cfset purchase_price_row_money = session.ep.money>
                                                                    <cfset cost_price_row_money = session.ep.money>
                                                                </cfif>
                                                            </cfif>
                                                        </cfif>
                                                    <cfelse>
                                                    	<cfif get_main_price.recordcount>
                                                            #get_main_price.SALES_PRICE_MONEY#
                                                            <cfset sales_PRICE_ROW_MONEY = get_main_price.SALES_PRICE_MONEY>
                                                            <cfset purchase_price_row_money = get_main_price.SALES_PRICE_MONEY>
                                                            <cfset cost_price_row_money = get_main_price.SALES_PRICE_MONEY>
                                                        <cfelse>
                                                            #session.ep.money#
															<cfset sales_PRICE_ROW_MONEY = session.ep.money>
                                                            <cfset purchase_price_row_money = session.ep.money>
                                                            <cfset cost_price_row_money = session.ep.money>
                                                        </cfif>
                                                    </cfif>
                                                </td>
                                                <td style="text-align:right; color:red">
                                                <cfif height_is_standart eq 0>
                                                	<cfif PIECE_TYPE eq 4> <!---Satır Hammadde İse--->
                                                    	<cfif len(amount_formul)>
                                                    		<cfif find('HEIGHT',#amount_formul#)> <!---Yükseklik İçin--->
                                                            	<cfif PRIVATE_PRICE_TYPE eq 1><!---Özel Fiyat Tipi Sabit mi?--->
                                                                	<cfif isdefined('RATE2_#sales_price_row_money#')>
                                                        				<cfset ozel_toplam = ozel_toplam+((PRIVATE_PRICE*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2)+(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                        <cfset ozel_bayi_toplam = ozel_bayi_toplam+((PRIVATE_PRICE*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2)+(purchase_PRICE_ROW*amount2*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2))>
																		#TlFormat((PRIVATE_PRICE*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2)+(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2),2)# 
                                                                  	</cfif>
                                                                    <cfif isdefined('RATE2_#purchase_price_row_money#')>
                                                                        <cfset ozel_bayi_toplam = ozel_bayi_toplam+((PRIVATE_PRICE*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2)+(purchase_PRICE_ROW*amount2*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                  	</cfif>
                                                                <cfelseif PRIVATE_PRICE_TYPE eq 2><!---Özel Fiyat Tipi Yüzde mi?--->
                                                                	<cfif isdefined('RATE2_#sales_price_row_money#')>
                                                        				<cfset ozel_toplam = ozel_toplam+((PRIVATE_PRICE/100)*(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                        #TlFormat((PRIVATE_PRICE/100)*(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2),2)# 
                                                                   	</cfif>
                                                                    <cfif isdefined('RATE2_#purchase_price_row_money#')>
                                                        				<cfset ozel_bayi_toplam = ozel_bayi_toplam+((PRIVATE_PRICE/100)*(purchase_PRICE_ROW*amount2*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                   	</cfif>
                                                                </cfif>
                                                           	<cfelseif find('WIDTH',#amount_formul#)> 
                                                            	<cfif PRIVATE_PRICE_TYPE eq 1>
                                                                	<cfif isdefined('RATE2_#sales_price_row_money#')>
                                                        				<cfset ozel_toplam = ozel_toplam+((PRIVATE_PRICE*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2)+(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                        #TlFormat((PRIVATE_PRICE*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2)+(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2),2)#
                                                                  	</cfif>
                                                                    <cfif isdefined('RATE2_#purchase_price_row_money#')>
                                                        				<cfset ozel_bayi_toplam = ozel_bayi_toplam+((PRIVATE_PRICE*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2)+(purchase_PRICE_ROW*amount2*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                  	</cfif>
                                                                <cfelseif PRIVATE_PRICE_TYPE eq 2>
                                                                	<cfif isdefined('RATE2_#sales_price_row_money#')>
                                                        				<cfset ozel_toplam = ozel_toplam+((PRIVATE_PRICE/100)*(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                        #TlFormat((PRIVATE_PRICE/100)*(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2),2)#
                                                                   	</cfif>
                                                                    <cfif isdefined('RATE2_#purchase_price_row_money#')>
                                                        				<cfset ozel_bayi_toplam = ozel_bayi_toplam+((PRIVATE_PRICE/100)*(purchase_PRICE_ROW*amount2*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                   	</cfif>
                                                                </cfif>
                                                            <cfelseif find('DEPTH',#amount_formul#)>
                                                            	<cfif PRIVATE_PRICE_TYPE eq 1>
                                                                	<cfif isdefined('RATE2_#sales_price_row_money#')>
                                                        				<cfset ozel_toplam = ozel_toplam+((PRIVATE_PRICE*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2)+(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                        #TlFormat((PRIVATE_PRICE*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2)+(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2),2)#
                                                                  	</cfif>
                                                                    <cfif isdefined('RATE2_#purchase_price_row_money#')>
                                                        				<cfset ozel_bayi_toplam = ozel_bayi_toplam+((PRIVATE_PRICE*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2)+(purchase_PRICE_ROW*amount2*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                  	</cfif>
                                                                <cfelseif PRIVATE_PRICE_TYPE eq 2>
                                                                	<cfif isdefined('RATE2_#sales_price_row_money#')>
                                                        				<cfset ozel_toplam = ozel_toplam+((PRIVATE_PRICE/100)*(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                        #TlFormat((PRIVATE_PRICE/100)*(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2),2)#
                                                                   	</cfif>
                                                                    <cfif isdefined('RATE2_#purchase_price_row_money#')>
                                                        				<cfset ozel_bayi_toplam = ozel_bayi_toplam+((PRIVATE_PRICE/100)*(purchase_PRICE_ROW*amount2*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                   	</cfif>
                                                                </cfif>
                                                            </cfif>
                                                       	</cfif>
                                                    <cfelse> <!---Satır Parça tipi 1,2,3 İse--->
                                                    	<cfif len(amount_formul)>
                                                    		<cfif find('HEIGHT',#boy_formul#)>
                                                            	<cfif PRIVATE_PRICE_TYPE eq 1>
                                                                	<cfif isdefined('RATE2_#sales_price_row_money#')>
                                                        				<cfset ozel_toplam = ozel_toplam+((PRIVATE_PRICE*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2)+(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                        #TlFormat((PRIVATE_PRICE*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2)+(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2),2)#
                                                                  	</cfif>
                                                                    <cfif isdefined('RATE2_#purchase_price_row_money#')>
                                                        				<cfset ozel_bayi_toplam = ozel_bayi_toplam+((PRIVATE_PRICE*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2)+(purchase_PRICE_ROW*amount2*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                  	</cfif>
                                                                <cfelseif PRIVATE_PRICE_TYPE eq 2>
                                                                	<cfif isdefined('RATE2_#sales_price_row_money#')>
                                                        				<cfset ozel_toplam = ozel_toplam+((PRIVATE_PRICE/100)*(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                        #TlFormat((PRIVATE_PRICE/100)*(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2),2)#
                                                                   	</cfif>
                                                                    <cfif isdefined('RATE2_#purchase_price_row_money#')>
                                                        				<cfset ozel_bayi_toplam = ozel_bayi_toplam+((PRIVATE_PRICE/100)*(purchase_PRICE_ROW*amount2*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                   	</cfif>
                                                                </cfif>
                                                           	<cfelseif find('WIDTH',#en_formul#)> 
                                                            	<cfif PRIVATE_PRICE_TYPE eq 1>
                                                                	<cfif isdefined('RATE2_#sales_price_row_money#')>
                                                        				<cfset ozel_toplam = ozel_toplam+((PRIVATE_PRICE*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2)+(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                        #TlFormat((PRIVATE_PRICE*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2)+(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2),2)#
                                                                  	</cfif>
                                                                    <cfif isdefined('RATE2_#purchase_price_row_money#')>
                                                        				<cfset ozel_bayi_toplam = ozel_bayi_toplam+((PRIVATE_PRICE*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2)+(purchase_PRICE_ROW*amount2*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                  	</cfif>
                                                                <cfelseif PRIVATE_PRICE_TYPE eq 2>
                                                                	<cfif isdefined('RATE2_#sales_price_row_money#')>
                                                        				<cfset ozel_toplam = ozel_toplam+((PRIVATE_PRICE/100)*(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')))>
                                                                        #TlFormat((PRIVATE_PRICE/100)*(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2),2)#
                                                                   	</cfif>
                                                                    <cfif isdefined('RATE2_#purchase_price_row_money#')>
                                                        				<cfset ozel_bayi_toplam = ozel_bayi_toplam+((PRIVATE_PRICE/100)*(purchase_PRICE_ROW*amount2*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                   	</cfif>
                                                                </cfif>
                                                            <cfelseif find('DEPTH',#en_formul#)>
                                                            	<cfif PRIVATE_PRICE_TYPE eq 1>
                                                                	<cfif isdefined('RATE2_#sales_price_row_money#')>
                                                        				<cfset ozel_toplam = ozel_toplam+((PRIVATE_PRICE*Evaluate('RATE2_#sales_price_row_money#'))+(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')))>
                                                                        #TlFormat((PRIVATE_PRICE*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2)+(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2),2)#
                                                                  	</cfif>
                                                                    <cfif isdefined('RATE2_#purchase_price_row_money#')>
                                                        				<cfset ozel_bayi_toplam = ozel_bayi_toplam+((PRIVATE_PRICE*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2)+(purchase_PRICE_ROW*amount2*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2))>
                                                                  	</cfif>
                                                                <cfelseif PRIVATE_PRICE_TYPE eq 2>
                                                                	<cfif isdefined('RATE2_#sales_price_row_money#')>
                                                        				<cfset ozel_toplam = ozel_toplam+((PRIVATE_PRICE/100)*(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')))>
                                                                        #TlFormat((PRIVATE_PRICE/100)*(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2),2)#
                                                                        
                                                                   	</cfif>
                                                                    <cfif isdefined('RATE2_#purchase_price_row_money#')>
                                                        				<cfset ozel_bayi_toplam = ozel_bayi_toplam+((PRIVATE_PRICE/100)*(purchase_PRICE_ROW*amount2*Evaluate('RATE2_#purchase_price_row_money#')/ROW_MONEY_RATE_2))>

                                                                   	</cfif>
                                                                </cfif>
                                                            </cfif>
                                                       	</cfif>
                                                    </cfif>
                                                </cfif>
                                                <cfinput type="hidden" name="PRIVATE_PRICE_MONEY_#get_row.PIECE_ROW_ID#" value="#PRIVATE_PRICE_MONEY#">
                                                <cfinput type="hidden" name="PRIVATE_PRICE_TYPE_#get_row.PIECE_ROW_ID#" value="#PRIVATE_PRICE_TYPE#">
                                                <cfinput type="hidden" name="PRIVATE_PRICE_#get_row.PIECE_ROW_ID#" value="#PRIVATE_PRICE#">
                                                </td>
                                                <td style="text-align:right" title="#Evaluate('price_formul')#">
                                                	<cfif isdefined('RATE2_#sales_price_row_money#') and isnumeric(SALES_PRICE_row) and isnumeric(Evaluate('RATE2_#sales_price_row_money#'))>
                                                    	<cfif len(price_formul)>
                                                            <cftry>
                                                                #TlFormat(SALES_PRICE_row*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2*Evaluate('#price_formul#'),2)#
																<cfset toplam = toplam+(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2*Evaluate('#price_formul#'))>
                                                                <cfset purchase_total = purchase_total+(purchase_price_row*amount2*Evaluate('RATE2_#purchase_PRICE_ROW_MONEY#')/ROW_MONEY_RATE_2*Evaluate('#price_formul#'))>
                                                                <cfset cost_total = cost_total+(cost_price_row*amount2*Evaluate('RATE2_#cost_PRICE_ROW_MONEY#')/ROW_MONEY_RATE_2*Evaluate('#price_formul#'))>
                                                                <cfcatch type="Any">
                                                                        <cfoutput>#price_formul#</cfoutput>
                                                                    <cfabort>
                                                                </cfcatch>
                                                            </cftry>
                                                        <cfelse>
                                                        	#TlFormat(SALES_PRICE_row*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2,2)#
															<cfset toplam = toplam+(sales_PRICE_ROW*amount2*Evaluate('RATE2_#sales_price_row_money#')/ROW_MONEY_RATE_2)>
                                                            <cfset purchase_total = purchase_total+(purchase_price_row*amount2*Evaluate('RATE2_#purchase_PRICE_ROW_MONEY#')/ROW_MONEY_RATE_2)>
                                                            <cfset cost_total = cost_total+(cost_price_row*amount2*Evaluate('RATE2_#cost_PRICE_ROW_MONEY#')/ROW_MONEY_RATE_2)>
                                                        </cfif>
                                                   	<cfelse>
                                                    	<span style="color:red">
                                                    		#TlFormat(0,2)#
                                                        </span>
                                                    </cfif>
                                               	</td>
                                                <td style="text-align:left">#get_main_price.SALES_PRICE_MONEY#</td>
                                                
                                            </tr>
                                            <cfinput type="hidden" name="sales_price_#get_row.PIECE_ROW_ID#" value="#sales_PRICE_ROW#">
                                            <cfinput type="hidden" name="sales_price_money_#get_row.PIECE_ROW_ID#" value="#sales_PRICE_ROW_money#">
                                            <cfinput type="hidden" name="purchase_price_#get_row.PIECE_ROW_ID#" value="#purchase_price_row#">
                                            <cfinput type="hidden" name="purchase_price_money_#get_row.PIECE_ROW_ID#" value="#purchase_price_row_money#">
                                            <cfinput type="hidden" name="cost_price_#get_row.PIECE_ROW_ID#" value="#cost_price_row#">
                                            <cfinput type="hidden" name="cost_price_money_#get_row.PIECE_ROW_ID#" value="#cost_price_row_money#">
                                        </cfoutput>
                                        <tr>
                                        	<cfoutput>

                                                <td colspan="8" style="text-align:left; color:red"><b>Özel Ürün Farkı</b></td>
                                                <td style="text-align:right"></td>
                                                <td style="text-align:right; color:red"><b>#TlFormat(ozel_toplam,2)#</b></td>
                                                <td style="text-align:right">#TlFormat(toplam,2)#</td>
                                                <td style="text-align:left; color:red">#get_main_price.SALES_PRICE_MONEY#</td>
                                            </cfoutput>
                                        </tr>
                                        <tr>
                                        	<cfoutput>
                                                <cfinput type="hidden" name="toplam" value="#ozel_toplam+toplam#">
                                              	<cfinput type="hidden" name="purchase_total" value="#ozel_bayi_toplam+purchase_total#">
                                              	<cfinput type="hidden" name="cost_total" value="#ozel_toplam+cost_total#">
                                                <cfinput type="hidden" name="money" value="#get_main_price.SALES_PRICE_MONEY#">
                                                <td colspan="10"><b>Toplam</b></td>

                                                <td style="text-align:right"><b>#TlFormat(ozel_toplam+toplam,2)#</b></td>
                                                <td style="text-align:left">#get_main_price.SALES_PRICE_MONEY#</td>
                                            </cfoutput>
                                        </tr>
                                    </cfif>
                         	</tbody>
                           	<tfoot>
                          		<tr>
                                	<td colspan="8" style="text-align:right; color:red; font-weight:bold; vertical-align:middle">
                                    	<cfif not isdefined('attributes.revision') and not attributes.kilit_stage>
                                            <span id="is_price_change_" <cfif not isdefined('attributes.is_form_submitted')>style="display:none"</cfif>>
                                                <input type="checkbox" name="is_price_change" id="is_price_change" value="1" checked><cf_get_lang_main no ='133.Teklif'> <cf_get_lang no ='1532.Fiyatı Güncelle'>
                                            </span>
                                        </cfif>
                                    </td>
                                 	<td colspan="4" style=" text-align:right">
                                 		<cfif get_product.is_prototip eq 1>
                                     		<cfif get_row.recordcount>
                                            	<span id="hesapla_" <cfif isdefined('attributes.is_form_submitted')>style="display:none"</cfif>>
                                                	<input type="button" name="vazgec" id="vazgec" value="Vazgeç" style="background-color:red" onClick="window.close();">
                                                    <input type="button" name="hesapla" id="hesapla" value="Hesapla" onClick="control(0);">
                                               	</span>
                                                <span id="guncelle_" <cfif not isdefined('attributes.is_form_submitted')>style="display:none"</cfif>>
                                                	<!---<input type="button" name="vazgec" id="vazgec" value="Vazgeç" style="background-color:red" onClick="window.close();">--->
                                                    <cfif not isdefined('attributes.ezgi_kilit')>
                                        				<cf_workcube_buttons is_upd='1' is_delete='0' is_cancel='1' add_function="control(1)">
                                                    </cfif>
                                             	</span>
                                        	</cfif>
                                      	<cfelse>
                                       		<font color="FF0000"><cf_get_lang no="870.Ürün Özelleştirilebilir Olmadığı İçin Spec Kaydedemezsiniz"> !</font>
                                     	</cfif>
                                 	</td>
                             	</tr>
                          	</tfoot>
                      	</cf_flat_list>
                  	</td>
               	</tr>
            </table>
        </div>
    </cfform>
	</cf_box>
</div>
<script type="text/javascript">
	function chooseSpectImage()
	{
		var fileInput = document.getElementById('uploaded_file');

		if(fileInput)
			fileInput.click();
	}
	function handleSpectImageSelect(input)
	{
		if(input.files && input.files.length)
			uploadSpectImage(input.files[0]);

		input.value = '';
	}
	function setSpectImageDropZoneState(isActive)
	{
		var dropZone = document.getElementById('spect_image_drop_zone');

		if(!dropZone)
			return;

		dropZone.style.backgroundColor = isActive ? '#d9efff' : '';
		dropZone.style.borderColor = isActive ? '#1e88e5' : '#bbb';
		dropZone.style.boxShadow = isActive ? '0 0 0 4px rgba(30,136,229,0.25)' : '';
		dropZone.style.transform = isActive ? 'scale(1.03)' : '';
		dropZone.style.color = isActive ? '#0d47a1' : '#666';
	}
	function handleSpectImageDragOver(event)
	{
		event.preventDefault();
		event.stopPropagation();
		setSpectImageDropZoneState(true);
		return false;
	}
	function handleSpectImageDragLeave(event)
	{
		event.preventDefault();
		event.stopPropagation();
		setSpectImageDropZoneState(false);
		return false;
	}
	function handleSpectImageDrop(event)
	{
		var droppedFile = null;

		event.preventDefault();
		event.stopPropagation();
		setSpectImageDropZoneState(false);

		if(!event.dataTransfer || !event.dataTransfer.files || !event.dataTransfer.files.length)
			return false;

		droppedFile = event.dataTransfer.files[0];
		uploadSpectImage(droppedFile);
		return false;
	}
	function renderSpectImagePreview(imageSrc)
	{
		var previewCell = document.getElementById('spect_image_preview_cell');
		var previewImage = null;

		if(!previewCell)
			return;

		previewCell.innerHTML = '';
		previewImage = document.createElement('img');
		previewImage.src = imageSrc;
		previewImage.style.height = '160px';
		previewImage.style.width = '160px';
		previewImage.style.verticalAlign = 'middle';
		previewImage.style.border = '1px solid #ddd';
		previewImage.style.padding = '2px';
		previewImage.style.cursor = 'pointer';
		previewImage.onclick = function() {
			openSpectImagePreview(imageSrc);
		};
		previewCell.appendChild(previewImage);
	}
	function renderSelectedSpectImage(file)
	{
		var fileReader = null;

		if(!file)
			return;

		fileReader = new FileReader();
		fileReader.onload = function(loadEvent) {
			renderSpectImagePreview(loadEvent.target.result);
		};
		fileReader.readAsDataURL(file);
	}
	function parseSpectImageUploadResponse(responseText)
	{
		var startMarker = '__SPECT_IMAGE_UPLOAD_JSON_START__';
		var endMarker = '__SPECT_IMAGE_UPLOAD_JSON_END__';
		var startIndex = responseText.indexOf(startMarker);
		var endIndex = responseText.indexOf(endMarker);
		var jsonText = '';
		var firstBrace = -1;
		var lastBrace = -1;

		if(startIndex > -1 && endIndex > startIndex)
		{
			jsonText = responseText.substring(startIndex + startMarker.length, endIndex);
			return JSON.parse(jsonText);
		}

		firstBrace = responseText.indexOf('{');
		lastBrace = responseText.lastIndexOf('}');

		if(firstBrace > -1 && lastBrace > firstBrace)
		{
			jsonText = responseText.substring(firstBrace, lastBrace + 1);
			return JSON.parse(jsonText);
		}

		return JSON.parse(responseText);
	}
	function normalizeSpectImageUploadResponse(responseData)
	{
		if(!responseData)
			return { success: false, message: '', file_name: '', file_path: '' };

		return {
			success: !!(responseData.success || responseData.SUCCESS),
			message: responseData.message || responseData.MESSAGE || '',
			file_name: responseData.file_name || responseData.FILE_NAME || '',
			file_path: responseData.file_path || responseData.FILE_PATH || ''
		};
	}
	function openSpectImagePreview(imageSrc)
	{
		var previewWindow = null;

		if(!imageSrc || !imageSrc.length)
			return false;

		previewWindow = window.open('', '_blank');

		if(!previewWindow)
			return false;

		previewWindow.document.write('<html><head><title>Resim Onizleme</title></head><body style="margin:0; display:flex; align-items:center; justify-content:center; background:#111;"><img src="' + imageSrc.replace(/"/g, '&quot;') + '" style="max-width:100%; max-height:100vh;"></body></html>');
		previewWindow.document.close();
		return true;
	}
	function uploadSpectImage(file)
	{
		var formElement = document.getElementById('addSpecAll');
		var statusElement = document.getElementById('spect_image_upload_status');
		var request = null;
		var formData = null;
		var responseData = null;

		if(!file || !formElement)
			return false;

		if(file.type && file.type.indexOf('image/') !== 0)
		{
			alert('Sadece resim dosyasi yukleyebilirsiniz.');
			return false;
		}

		renderSelectedSpectImage(file);
		if(statusElement)
			statusElement.style.display = '';

		formData = new FormData(formElement);
		formData.append('ajax_upload', '1');
		formData.append('import_file_type', '5');
		formData.append('ezgi_id', '<cfoutput>#attributes.ezgi_id#</cfoutput>');
		formData.set('uploaded_file', file);

		request = new XMLHttpRequest();
		request.open('POST', '<cfoutput>#request.self#?fuseaction=prod.emptypopup_upd_ezgi_virtual_offer_row_spect_aktar&import_file_type=5&ezgi_id=#attributes.ezgi_id#</cfoutput>', true);
		request.onreadystatechange = function() {
			if(request.readyState !== 4)
				return;

			if(statusElement)
				statusElement.style.display = 'none';

			try
			{
				responseData = normalizeSpectImageUploadResponse(parseSpectImageUploadResponse(request.responseText));
			}
			catch(error)
			{
				alert('Resim yukleme sirasinda hata olustu.');
				return;
			}

			if(request.status < 200 || request.status >= 300 || !responseData.success)
			{
				alert(responseData.message || 'Resim yukleme sirasinda hata olustu.');
				return;
			}

			if(responseData.file_path)
				renderSpectImagePreview(responseData.file_path);
		};
		request.send(formData);
		return true;
	}
	function initSpectImageUpload()
	{
		var dropZone = document.getElementById('spect_image_drop_zone');

		if(!dropZone)
			return;

		dropZone.addEventListener('dragover', handleSpectImageDragOver);
		dropZone.addEventListener('dragleave', handleSpectImageDragLeave);
		dropZone.addEventListener('drop', handleSpectImageDrop);
	}
	function control(type)
	{
		<cfoutput query="get_row">
			<cfif isdefined('QUESTION_NAME_#QUESTION_ID#')>
				piece_type = #get_row.PIECE_TYPE#;
				if(piece_type == 4)
				{
					if(document.getElementById('alternative_stock_id_4_#get_row.PIECE_ROW_ID#').value==0)
					{
						alert("#getLang('invoice',39)#");
						return false;
					}
				}
				else
				{
					if(document.getElementById('alternative_stock_id_#get_row.PIECE_TYPE#_#get_row.PIECE_ROW_ID#').value==0)
					{
						alert("#getLang('invoice',39)#");
						return false;
					}
				}
			</cfif>
		</cfoutput>
		if(type == 1)
		{
			return true;
		}
		if(type == 0)
		{
			document.getElementById("addSpecAll").action = "<cfoutput>#request.self#?fuseaction=prod.popup_upd_ezgi_virtual_offer_row_spect&ezgi_id=#attributes.ezgi_id#</cfoutput>";
			document.getElementById("addSpecAll").submit();
			return true;
		}
	}
	function degisti(measure)
	{
		document.getElementById('hesapla_').style.display = '';
		document.getElementById('guncelle_').style.display = 'none';
		if(measure == 1)
		{

			<cfoutput query="get_heights">
				if(document.getElementById('height').value == #measure#)
				{
					if(#IS_STANDART#==0)
					{
						alert('Dikkat Özel Ölçü Seçtiniz');
					}
					else if(document.getElementById('not_standart_rate'))
						document.getElementById('not_standart_rate').value=0;
				}	
			</cfoutput> 
		}

        if(measure == 2)
        {
            <cfoutput query="get_widths">
				if(document.getElementById('width').value == #measure#)
				{
					if(#IS_STANDART#==0)
					{
						alert('Dikkat Özel Ölçü Seçtiniz');
					}
					else if(document.getElementById('not_standart_rate'))
						document.getElementById('not_standart_rate').value=0;
				}	
			</cfoutput>
        }

        if(measure ==3){
            <cfoutput query="get_depths">
				if(document.getElementById('depth').value == #measure#)
				{
					if(#IS_STANDART#==0)
					{
						alert('Dikkat Özel Ölçü Seçtiniz');
					}
					else if(document.getElementById('not_standart_rate'))
						document.getElementById('not_standart_rate').value=0;
				}	
			</cfoutput>
        }
	}
	function syncAlternativeAnswers(sourceElement)
	{
		var questionId = '';
		var selectedValue = '';
		var selectedText = '';
		var questionSelects = [];
		var sourceReached = false;
		var i = 0;
		var targetIndex = -1;

		if(!sourceElement)
			return false;

		questionId = sourceElement.getAttribute('data-question-id');

		if(!questionId || sourceElement.selectedIndex < 0)
			return false;

		selectedValue = sourceElement.value;
		selectedText = sourceElement.options[sourceElement.selectedIndex].text;
		questionSelects = document.querySelectorAll('select[data-question-id="' + questionId + '"]');

		for(i = 0; i < questionSelects.length; i++)
		{
			if(questionSelects[i] === sourceElement)
			{
				sourceReached = true;
				continue;
			}

			if(!sourceReached)
				continue;

			targetIndex = findAlternativeOptionIndex(questionSelects[i], selectedValue, selectedText);

			if(targetIndex > -1)
				questionSelects[i].selectedIndex = targetIndex;
		}

		return true;
	}
	function findAlternativeOptionIndex(selectElement, selectedValue, selectedText)
	{
		var i = 0;

		if(!selectElement)
			return -1;

		for(i = 0; i < selectElement.options.length; i++)
		{
			if(selectElement.options[i].value == selectedValue)
				return i;
		}

		for(i = 0; i < selectElement.options.length; i++)
		{
			if(selectElement.options[i].text == selectedText)
				return i;
		}

		return -1;
	}
	function select_goster(alt_row,piece_row_id)
	{
		if(document.getElementById('select_key_'+alt_row).value==0)
		{
			document.getElementById('alernative_select_'+alt_row).style.display='';
			document.getElementById('select_key_'+alt_row).value=1; 
			document.getElementById('listele_'+alt_row).src = "images/listele2.gif";
			document.getElementById('alternative_stock_id_4_'+piece_row_id).style.width='140px';
		}
		else
		{
			document.getElementById('alernative_select_'+alt_row).style.display='none';
			document.getElementById('select_key_'+alt_row).value=0; 
			document.getElementById('listele_'+alt_row).src = "images/listele.gif";
			document.getElementById('alternative_stock_id_4_'+piece_row_id).style.width='180px';
		}
	}
	function bul_select(alt_row,piece_row_id)
	{
		keyw = document.getElementById('alernative_select_'+alt_row).value;
		if(keyw.length >=3)
		{
			/*var alternative_select = 
			wrk_query("SELECT ALTERNATIVE_STOCK_ID, PRODUCT_NAME FROM EZGI_DESIGN_ALTERNATIVE_STOCKS WHERE PIECE_ROW_ID="+piece_row_id+" AND  PRODUCT_NAME LIKE '%"+keyw+"%' ORDER BY PRODUCT_NAME","dsn3");*/
			
			var listParam = piece_row_id + "*" + keyw;
			var alternative_select = wrk_safe_query('get_alternative_piece_row_id_product_name_ezgi','dsn3',0,listParam);
		}
		var option_count_pname = document.getElementById('alternative_stock_id_4_'+piece_row_id).options.length; 
		for(x=option_count_pname;x>=0;x--)
			 document.getElementById('alternative_stock_id_4_'+piece_row_id).options[x] = null;
		if(alternative_select.recordcount != 0)
		{	
			document.getElementById('alternative_stock_id_4_'+piece_row_id).options[0] = new Option('Seçiniz','');
			for(var xx=0;xx<alternative_select.recordcount;xx++)
			{
				document.getElementById('alternative_stock_id_4_'+piece_row_id).options[xx+1]=new Option(alternative_select.PRODUCT_NAME[xx],alternative_select.ALTERNATIVE_STOCK_ID[xx]);
				document.getElementById('alternative_stock_id_4_'+piece_row_id).selectedIndex=xx+1;
			}
		}
		syncAlternativeAnswers(document.getElementById('alternative_stock_id_4_'+piece_row_id));
		degisti();
		select_goster(alt_row,piece_row_id);
	}
	initSpectImageUpload();
</script>