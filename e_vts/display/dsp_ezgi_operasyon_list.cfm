<!---
    File: dsp_ezgi_operasyon_list.cfm
    Folder: Add_Ons\ezgi\e-vts\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfquery name="get_qualite_control" datasource="#dsn3#">
	SELECT 
    	EZGI_VTS_QUALITY_CONTROL_OPERATION_ID
	FROM     
    	EZGI_VTS_SETUP
  	WHERE  
    	EZGI_VTS_DEPARTMENT_ID = 2 <!---Firmaya Göre Değişir--->
</cfquery>
<!---İstasyon Departmanına Bağlanmalı--->
<cfquery name="get_main" datasource="#dsn3#">
	SELECT
    	CASE 
       		WHEN 
           		(SELECT ISNULL(IS_PROTOTYPE,0) AS IS_PROTOTYPE FROM STOCKS WHERE STOCK_ID = EZGI_OPERATION_M.STOCK_ID) = 0
          	THEN 
            	PRODUCT_NAME
          	ELSE
          	(
             	SELECT        
                 	TOP (1) DESIGN_MAIN_NAME
             	FROM            
                 	EZGI_DESIGN_MAIN_ROW
              	WHERE        
               		MAIN_SPECT_RELATED_ID = EZGI_OPERATION_M.SPEC_MAIN_ID
                       		ORDER BY 
                       		    DESIGN_MAIN_ROW_ID DESC
                       		UNION ALL
                       		SELECT        
                       		    TOP (1) PACKAGE_NAME
                       		FROM        
                       		    EZGI_DESIGN_PACKAGE_ROW
                       		WHERE        
                       		    PACKAGE_SPECT_RELATED_ID = EZGI_OPERATION_M.SPEC_MAIN_ID
                       		ORDER BY 
                       		    PACKAGE_ROW_ID DESC
                       		UNION ALL
                       		SELECT        
                       		    TOP (1) PIECE_NAME
                       		FROM            
                       		    EZGI_DESIGN_PIECE_ROWS
                       		WHERE        
                       		    PIECE_SPECT_RELATED_ID = EZGI_OPERATION_M.SPEC_MAIN_ID
                       		ORDER BY 
                       		    PIECE_ROW_ID DESC
                        )
                END	AS PRODUCT_NAME,
        ISNULL((
        		SELECT
					SUM(POR_.AMOUNT) ORDER_AMOUNT
				FROM
					PRODUCTION_ORDER_RESULTS_ROW POR_,
					PRODUCTION_ORDER_RESULTS POO
				WHERE
					POR_.PR_ORDER_ID = POO.PR_ORDER_ID
					AND POO.P_ORDER_ID = EZGI_OPERATION_M.P_ORDER_ID
					AND POR_.TYPE = 1
					AND POO.IS_STOCK_FIS = 1
				),0) ROW_RESULT_AMOUNT,
      	P_ORDER_ID, 
        PO_RELATED_ID, 
        LOT_NO, 
        P_ORDER_NO, 
        PRODUCTION_LEVEL, 
        IS_STAGE, 
        START_DATE, 
        STOCK_CODE, 
        SPEC_MAIN_ID, 
        STOCK_ID, 
        PRODUCT_ID, 
        PRODUCT_NAME, 
        SPECT_VAR_NAME, 
       	QUANTITY, 
        P_OPERATION_ID, 
        OPERATION_TYPE_ID, 
        OPERATION_CODE, 
        OPERATION_TYPE, 
        AMOUNT, 
        REAL_AMOUNT,
        REAL_TIME,
        ACTION_EMPLOYEE_ID,
        ACTION_START_DATE,
        STAGE,
        (SELECT EZGI_VTS_NUMBER FROM PRODUCTION_ORDERS WHERE P_ORDER_ID = EZGI_OPERATION_M.P_ORDER_ID) AS EZGI_VTS_NUMBER
	FROM            
    	EZGI_OPERATION_M
	WHERE        
    	LOT_NO = (SELECT LOT_NO FROM PRODUCTION_ORDERS WHERE P_ORDER_ID = #attributes.p_order_id#)
</cfquery>

<cfquery name="get_level_0" dbtype="query">
	SELECT 
    	  P_ORDER_ID, 
          LOT_NO, 
          P_ORDER_NO, 
          IS_STAGE, 
          STOCK_CODE, 
          SPEC_MAIN_ID, 
          STOCK_ID, 
          PRODUCT_ID, 
          PRODUCT_NAME, 
          SPECT_VAR_NAME, 
          QUANTITY,
          EZGI_VTS_NUMBER,
          ROW_RESULT_AMOUNT
    FROM 
    	  GET_MAIN 
    WHERE 
    	  PRODUCTION_LEVEL = 0 
  	GROUP BY 
		  P_ORDER_ID, 
          LOT_NO, 
          P_ORDER_NO, 
          IS_STAGE, 
          STOCK_CODE, 
          SPEC_MAIN_ID, 
          STOCK_ID, 
          PRODUCT_ID, 
          PRODUCT_NAME, 
          SPECT_VAR_NAME, 
          QUANTITY,
          EZGI_VTS_NUMBER,
          ROW_RESULT_AMOUNT
    ORDER BY 
    	PRODUCT_NAME
</cfquery>
<cfset cnt_id_list = ''>
<cfset qual_id_list = ''>
<cfif get_qualite_control.recordcount and len(get_qualite_control.EZGI_VTS_QUALITY_CONTROL_OPERATION_ID) and get_level_0.recordcount>
	<cfloop query="get_level_0">
        <cfquery name="get_sub_piece" datasource="#dsn3#">
            SELECT 
                PO_1.P_ORDER_ID AS P_ORDER_ID_1, 
                PO_2.P_ORDER_ID AS P_ORDER_ID_2, 
                PO_3.P_ORDER_ID AS P_ORDER_ID_3, 
                PO_4.P_ORDER_ID AS P_ORDER_ID_4
            FROM     
                PRODUCTION_ORDERS AS PO_4 RIGHT OUTER JOIN
                PRODUCTION_ORDERS AS PO_3 ON PO_4.PO_RELATED_ID = PO_3.P_ORDER_ID RIGHT OUTER JOIN
                PRODUCTION_ORDERS AS PO_2 ON PO_3.PO_RELATED_ID = PO_2.P_ORDER_ID RIGHT OUTER JOIN
                PRODUCTION_ORDERS AS PO_1 ON PO_2.PO_RELATED_ID = PO_1.P_ORDER_ID RIGHT OUTER JOIN
                PRODUCTION_ORDERS AS PO_0 ON PO_1.PO_RELATED_ID = PO_0.P_ORDER_ID
            WHERE  
                PO_0.P_ORDER_ID = #get_level_0.p_order_id#
        </cfquery>
        <cfif get_sub_piece.recordcount>
            <cfset piece_p_order_id_list = ''>
            <cfloop query="get_sub_piece">
                <cfloop from="1" to="4" index="i"><!---Bulunan AltEmirler List Oluşturuluyor--->
                    <cfif len(Evaluate('get_sub_piece.P_ORDER_ID_#i#'))>
                        <cfset piece_p_order_id_list = ListAppend(piece_p_order_id_list,Evaluate('get_sub_piece.P_ORDER_ID_#i#'))>
                    </cfif>
                </cfloop>
            </cfloop>
            <cfif ListLen(piece_p_order_id_list)>
            	<cfquery name="get_sub_all_piece" datasource="#dsn3#"><!---Bulunan Alt Emir Listesi kalite Kontrol hariç Operasyonlar Kontrol ediliyor..--->
                	SELECT 
                    	PPO.P_ORDER_ID,
                        POR.OPERATION_TYPE_ID
					FROM     
                   		PRODUCTION_ORDERS AS PPO INNER JOIN
                  		PRODUCTION_OPERATION AS POR ON PPO.P_ORDER_ID = POR.P_ORDER_ID
					WHERE  
                    	PPO.P_ORDER_ID IN (#piece_p_order_id_list#) AND 
                        NOT (POR.STAGE IN (1, 3))
          		</cfquery>
           		<cfif not get_sub_all_piece.recordcount><!---Eğer Kontrolde Bulunamadıysa Değişkene atanıyor..--->
                  	<cfset cnt_id_list = ListAppend(cnt_id_list,get_level_0.p_order_id)>
           		<cfelse>
                	<cfquery name="get_qual" dbtype="query">
                    	SELECT
                        	P_ORDER_ID
                      	FROM
                        	get_sub_all_piece
                     	WHERE
                        	OPERATION_TYPE_ID <> #get_qualite_control.EZGI_VTS_QUALITY_CONTROL_OPERATION_ID#		
                    </cfquery>
                    <cfif not get_qual.recordcount><!---Eğer Kontrolde Bulunamadıysa Değişkene atanıyor..--->
                    	<cfset qual_id_list = ListAppend(qual_id_list,get_level_0.p_order_id)>
                  	</cfif>
                </cfif>
         	</cfif>
 		</cfif>
 	</cfloop>
</cfif>

<cfsavecontent variable="right_menu">
    	<input type="button" name="bslamadi" value="Başlamadı" style="width:100px; font-size:10px; height:30px; background-color:orange">
        <input type="button" name="bsladi" value="Çalışıyor" style="width:100px; font-size:10px; height:30px; background-color:blue">
        <input type="button" name="eksik" value="Eksik Kapama" style="width:100px; font-size:10px; height:30px; background-color:green">
        <input type="button" name="bitti" value="Bitti" style="width:100px; font-size:10px; height:30px; background-color:red">&nbsp;&nbsp;
</cfsavecontent>	
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box scroll="0">
     	<cfsavecontent variable="uret_takip"><cf_get_lang dictionary_id='38033.Üretim Takibi'></cfsavecontent>
      	<cf_box title="#uret_takip#"  uidrop="1" hide_table_column="1" scroll="1" right_images="#right_menu#">
         	<cf_form_list>
                    <thead>
                        <tr height="20px">
                         	<th style="width:40px;text-align:left;"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                            <th style="width:40px"></th>
                          	<th style="width:300px;text-align:left;"><cf_get_lang dictionary_id='44019.Ürün'></th>
                            <th style="width:70px;text-align:left;"><cf_get_lang dictionary_id='29474.Emir No'></th>
                          	<th style="width:70px;text-align:right;"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            <th style="width:70px;text-align:right;"><cf_get_lang dictionary_id='36608.Üretilen'></th>
                            <th style="width:40px"></th>
                            <th style="width:40px" nowrap="nowrap">Takip No</th>
                            <th style="width:40px"></th>
                            <th style="text-align:center;"><cf_get_lang dictionary_id='54365.Operasyonlar'></th>
                        </tr>
                    </thead>
                    <tbody>
                    	<cfif get_level_0.recordcount>
                        	<cfoutput query="get_level_0">
                            	<cfset 'p_order_id_list_#get_level_0.P_ORDER_ID#' = ''>
                            	<cfquery name="get_level_1" dbtype="query">
                                    SELECT 
                                        P_ORDER_ID, 
                                        LOT_NO, 
                                        P_ORDER_NO, 
                                        IS_STAGE, 
                                        STOCK_CODE, 
                                        SPEC_MAIN_ID, 
                                        STOCK_ID, 
                                        PRODUCT_ID, 
                                        PRODUCT_NAME, 
                                        SPECT_VAR_NAME, 
                                        QUANTITY,
                                        ROW_RESULT_AMOUNT,
                                        EZGI_VTS_NUMBER
                                    FROM 
                                        GET_MAIN 
                                    WHERE 
                                        PO_RELATED_ID = #get_level_0.P_ORDER_ID#
                                    GROUP BY 
                                        P_ORDER_ID, 
                                        P_ORDER_ID, 
                                        LOT_NO, 
                                        P_ORDER_NO, 
                                        IS_STAGE, 
                                        STOCK_CODE, 
                                        SPEC_MAIN_ID, 
                                        STOCK_ID, 
                                        PRODUCT_ID, 
                                        PRODUCT_NAME, 
                                        SPECT_VAR_NAME, 
                                        QUANTITY,
                                        ROW_RESULT_AMOUNT,
                                        EZGI_VTS_NUMBER
                                </cfquery>
                                <cfloop query="get_level_1">
                                	<cfquery name="get_level_2" dbtype="query">
                                        SELECT 
                                            P_ORDER_ID, 
                                            LOT_NO, 
                                            P_ORDER_NO, 
                                            IS_STAGE, 
                                            STOCK_CODE, 
                                            SPEC_MAIN_ID, 
                                            STOCK_ID, 
                                            PRODUCT_ID, 
                                            PRODUCT_NAME, 
                                            SPECT_VAR_NAME, 
                                            QUANTITY,
                                            ROW_RESULT_AMOUNT,
                                            EZGI_VTS_NUMBER
                                        FROM 
                                            GET_MAIN 
                                        WHERE 
                                            PO_RELATED_ID = #get_level_1.P_ORDER_ID#
                                        GROUP BY 
                                            P_ORDER_ID, 
                                            P_ORDER_ID, 
                                            LOT_NO, 
                                            P_ORDER_NO, 
                                            IS_STAGE, 
                                            STOCK_CODE, 
                                            SPEC_MAIN_ID, 
                                            STOCK_ID, 
                                            PRODUCT_ID, 
                                            PRODUCT_NAME, 
                                            SPECT_VAR_NAME, 
                                            QUANTITY,
                                            ROW_RESULT_AMOUNT,
                                            EZGI_VTS_NUMBER
                                    </cfquery>
                                    <cfset 'p_order_id_list_#get_level_0.P_ORDER_ID#' = ListAppend(Evaluate('p_order_id_list_#get_level_0.P_ORDER_ID#'),get_level_1.P_ORDER_ID)>
                                    <cfloop query="get_level_2">
                                    	<cfquery name="get_level_3" dbtype="query">
                                            SELECT 
                                                P_ORDER_ID, 
                                                LOT_NO, 
                                                P_ORDER_NO, 
                                                IS_STAGE, 
                                                STOCK_CODE, 
                                                SPEC_MAIN_ID, 
                                                STOCK_ID, 
                                                PRODUCT_ID, 
                                                PRODUCT_NAME, 
                                                SPECT_VAR_NAME, 
                                                QUANTITY,
                                                ROW_RESULT_AMOUNT,
                                                EZGI_VTS_NUMBER
                                            FROM 
                                                GET_MAIN 
                                            WHERE 
                                                PO_RELATED_ID = #get_level_2.P_ORDER_ID#
                                            GROUP BY 
                                                P_ORDER_ID, 
                                                P_ORDER_ID, 
                                                LOT_NO, 
                                                P_ORDER_NO, 
                                                IS_STAGE, 
                                                STOCK_CODE, 
                                                SPEC_MAIN_ID, 
                                                STOCK_ID, 
                                                PRODUCT_ID, 
                                                PRODUCT_NAME, 
                                                SPECT_VAR_NAME, 
                                                QUANTITY,
                                                ROW_RESULT_AMOUNT,
                                                EZGI_VTS_NUMBER
                                        </cfquery>
                                       	<cfset 'p_order_id_list_#get_level_0.P_ORDER_ID#' = ListAppend(Evaluate('p_order_id_list_#get_level_0.P_ORDER_ID#'),get_level_2.P_ORDER_ID)>
                                        <cfloop query="get_level_3">
                                        	 <cfset 'p_order_id_list_#get_level_0.P_ORDER_ID#' = ListAppend(Evaluate('p_order_id_list_#get_level_0.P_ORDER_ID#'),get_level_3.P_ORDER_ID)>
                                        </cfloop>
                                    </cfloop>

                                </cfloop>
                          	</cfoutput>
							<cfoutput query="get_level_0">
                            	<cfquery name="get_contain" datasource="#dsn3#">
                                	SELECT 
                                    	P_ORDER_ID_1, 
                                        P_ORDER_ID_2, 
                                        P_ORDER_ID_3
									FROM     
                                    	(
                                       	SELECT 
                                            PO_1.P_ORDER_ID AS P_ORDER_ID_1, 
                                            PO_2.P_ORDER_ID AS P_ORDER_ID_2, 
                                            PO_3.P_ORDER_ID AS P_ORDER_ID_3
                  						FROM      
                                        	PRODUCTION_ORDERS AS PO_2 LEFT OUTER JOIN
                                    		PRODUCTION_ORDERS AS PO_3 ON PO_2.P_ORDER_ID = PO_3.PO_RELATED_ID RIGHT OUTER JOIN
                                    		PRODUCTION_ORDERS AS PO_1 ON PO_2.PO_RELATED_ID = PO_1.P_ORDER_ID RIGHT OUTER JOIN
                                    		PRODUCTION_ORDERS AS PO_0 ON PO_1.PO_RELATED_ID = PO_0.P_ORDER_ID
                  						WHERE   
                                        	PO_0.P_ORDER_ID = #get_level_0.P_ORDER_ID#
                                    	) AS TBL
									WHERE  
                                    	P_ORDER_ID_1 = #attributes.p_order_id# OR
                  						P_ORDER_ID_2 = #attributes.p_order_id# OR
                  						P_ORDER_ID_3 = #attributes.p_order_id#
                                </cfquery>
                            	<cfquery name="get_level_1" dbtype="query">
                                    SELECT 
                                        P_ORDER_ID, 
                                        LOT_NO, 
                                        P_ORDER_NO, 
                                        IS_STAGE, 
                                        STOCK_CODE, 
                                        SPEC_MAIN_ID, 
                                        STOCK_ID, 
                                        PRODUCT_ID, 
                                        PRODUCT_NAME, 
                                        SPECT_VAR_NAME, 
                                        QUANTITY,
                                        ROW_RESULT_AMOUNT,
                                        EZGI_VTS_NUMBER
                                    FROM 
                                        GET_MAIN 
                                    WHERE 
                                        PO_RELATED_ID = #get_level_0.P_ORDER_ID#
                                    GROUP BY 
                                        P_ORDER_ID, 
                                        P_ORDER_ID, 
                                        LOT_NO, 
                                        P_ORDER_NO, 
                                        IS_STAGE, 
                                        STOCK_CODE, 
                                        SPEC_MAIN_ID, 
                                        STOCK_ID, 
                                        PRODUCT_ID, 
                                        PRODUCT_NAME, 
                                        SPECT_VAR_NAME, 
                                        QUANTITY,
                                        ROW_RESULT_AMOUNT,
                                        EZGI_VTS_NUMBER
                                </cfquery>
                   				<tr  style="height:40px; font-weight:bold">
                                    <td style="background-color:FFFFCC;text-align:left;" nowrap>
                                       	<img src="images/production/list_bottom.gif" id="level0_#get_level_0.P_ORDER_ID#" onclick="seviyelendir(#get_level_0.P_ORDER_ID#)" />
                                        <input type="hidden" id="p_order_id_list_#get_level_0.P_ORDER_ID#" value="#Evaluate('p_order_id_list_#get_level_0.P_ORDER_ID#')#">
                                        <input type="hidden" id="p_order_id_control_#get_level_0.P_ORDER_ID#" value="0">
                                   	</td>
                                   	<td></td>	 
                                    <td style="background-color:FFFFCC;text-align:left;" nowrap>&nbsp;#PRODUCT_NAME#</td>
                                    <td style="background-color:FFFFCC;text-align:center;" nowrap>&nbsp;#P_ORDER_NO#</td>
                                    <td style="background-color:FFFFCC;text-align:right;" nowrap>#TlFormat(QUANTITY,0)#&nbsp;</td>
                                    <td style="background-color:FFFFCC;text-align:right;" nowrap>#TlFormat(ROW_RESULT_AMOUNT,0)#&nbsp;</td>
                                    <td></td>
                                    <td style="text-align:center; <cfif Listfind(cnt_id_list, get_level_0.P_ORDER_ID)>background-color:turquoise<cfelseif Listfind(qual_id_list, get_level_0.P_ORDER_ID)>background-color:gray</cfif>">#get_level_0.EZGI_VTS_NUMBER#</td>
                                    <td style="text-align:center;" nowrap>
										<cfif get_level_0.IS_STAGE eq 4>
                                            <img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id='475.Onaylanmadı'>">
                                        <cfelseif get_level_0.IS_STAGE eq 0>
                                            <img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
                                        <cfelseif get_level_0.IS_STAGE eq 1>
                                            <img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='398.Başladı'>">
                                        <cfelseif get_level_0.IS_STAGE eq 2>
                                            <img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='305.Bitti'>">
                                        <cfelseif get_level_0.IS_STAGE eq 3>
                                            <img src="/images/grey_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
                                        </cfif>
                                    </td>	
                                    <td nowrap><cfif get_contain.recordcount><img src="images\production\true.png" height="20px" title="<cf_get_lang dictionary_id='38484.İlişkili Ürün'>"></cfif></td>
                    			</tr>
                                <cfloop query="get_level_1">
                                	<cfquery name="get_level_2" dbtype="query">
                                        SELECT 
                                            P_ORDER_ID, 
                                            LOT_NO, 
                                            P_ORDER_NO, 
                                            IS_STAGE, 
                                            STOCK_CODE, 
                                            SPEC_MAIN_ID, 
                                            STOCK_ID, 
                                            PRODUCT_ID, 
                                            PRODUCT_NAME, 
                                            SPECT_VAR_NAME, 
                                            QUANTITY,
                                            ROW_RESULT_AMOUNT,
                                            EZGI_VTS_NUMBER
                                        FROM 
                                            GET_MAIN 
                                        WHERE 
                                            PO_RELATED_ID = #get_level_1.P_ORDER_ID#
                                        GROUP BY 
                                            P_ORDER_ID, 
                                            P_ORDER_ID, 
                                            LOT_NO, 
                                            P_ORDER_NO, 
                                            IS_STAGE, 
                                            STOCK_CODE, 
                                            SPEC_MAIN_ID, 
                                            STOCK_ID, 
                                            PRODUCT_ID, 
                                            PRODUCT_NAME, 
                                            SPECT_VAR_NAME, 
                                            QUANTITY,
                                            ROW_RESULT_AMOUNT,
                                            EZGI_VTS_NUMBER
                                    </cfquery>
                                    <cfquery name="GET_TYPE" datasource="#DSN3#">
                                        SELECT        
                                            0 AS PIECE_TYPE
                                        FROM           
                                        	EZGI_DESIGN_MAIN_ROW
                                        WHERE        
                                        	DESIGN_MAIN_RELATED_ID = #get_level_1.STOCK_ID#
                                        UNION ALL
                                        SELECT        
                                        	PIECE_TYPE
                                        FROM         
                                        	EZGI_DESIGN_PIECE_ROWS
                                        WHERE        
                                        	PIECE_RELATED_ID = #get_level_1.STOCK_ID#
                                        UNION ALL
                                        SELECT        
                                        	0 AS PIECE_TYPE
                                        FROM           
                                        	EZGI_DESIGN_PACKAGE_ROW
                                        WHERE        
                                        	PACKAGE_RELATED_ID = #get_level_1.STOCK_ID#
                                    </cfquery>
                                    <cfquery name="get_operations" dbtype="query">
                                        	SELECT 
                                            	SUM(REAL_AMOUNT) AS REAL_AMOUNT,
                                                P_OPERATION_ID, 
                                                OPERATION_TYPE_ID, 
                                                OPERATION_CODE, 
                                                OPERATION_TYPE, 
                                                AMOUNT, 
                                                STAGE
                                            FROM 
                                                GET_MAIN 
                                            WHERE 
                                                P_ORDER_ID = #get_level_1.P_ORDER_ID#
                                            GROUP BY 
                                                P_OPERATION_ID, 
                                                OPERATION_TYPE_ID, 
                                                OPERATION_CODE, 
                                                OPERATION_TYPE, 
                                                AMOUNT, 
                                                STAGE
                                          	ORDER BY
                                            	OPERATION_CODE
                                  	</cfquery>
                                	<tr id="tr_#get_level_1.P_ORDER_ID#" style="height:30px; display:none">
                                        <td style="background-color:FFFFCC;text-align:left; vertical-align:middle" nowrap>&nbsp;&nbsp;&nbsp;<input type="button" value="2" style="width:35px; height:25px; background-color:blue; font-size:14px; vertical-align:middle" /></td>
                                        <td style="text-align:center" nowrap>
                                        	<cfif get_type.PIECE_TYPE eq 1>
                                                <img src="/images/butcegider.gif" title="<cf_get_lang dictionary_id='62.Yonga Levha'>"><span style="display:none">1</span>
                                            <cfelseif get_type.PIECE_TYPE eq 2>
                                                <img src="/images/arrow_up.png" title="<cf_get_lang dictionary_id='402.Genel Reçete'>"><span style="display:none">2</span>
                                            <cfelseif get_type.PIECE_TYPE eq 3>
                                                <img src="/images/elements.gif" title="<cf_get_lang dictionary_id='403.Montaj Ürünü'>"><span style="display:none">3</span>
                                            <cfelseif get_type.PIECE_TYPE eq 4>
                                                <img src="/images/promo_multi.gif" title="<cf_get_lang dictionary_id='404.Hammadde'>"><span style="display:none">4</span>
                                            <cfelseif get_type.PIECE_TYPE eq 0>
                                                <img src="/images/package.gif" title="<cf_get_lang dictionary_id='100.Paket'>"><span style="display:none">0</span>
                                            </cfif>
                                        </td>
                                        <td style="background-color:FFFFCC;text-align:left;" nowrap>&nbsp;#get_level_1.PRODUCT_NAME#</td>
                                        <td style="background-color:FFFFCC;text-align:center;" nowrap>&nbsp;#get_level_1.P_ORDER_NO#</td>
                                        <td style="background-color:FFFFCC;text-align:right;" nowrap>#TlFormat(get_level_1.QUANTITY,0)#&nbsp;</td>
                                        <td style="background-color:FFFFCC;text-align:right;" nowrap>#TlFormat(get_level_1.ROW_RESULT_AMOUNT,0)#&nbsp;</td>
                                        <td style="background-color:FFFFCC;text-align:center;" nowrap>
                                        	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=production.popup_dsp_ezgi_prod_teknik_resim&p_order_id=#get_level_1.p_order_id#&p_operation_id=#get_operations.p_operation_id#','wwide');">
                                        		<img src="/images/photo.gif" width="20px" />
                                          	</a>
                                        </td>
                                        
                                        <td style="text-align:center;" nowrap>#get_level_1.EZGI_VTS_NUMBER#</td>
                                        <td style="text-align:center;" nowrap>
											<cfif get_level_1.IS_STAGE eq 4>
                                                <img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id='475.Onaylanmadı'>">
                                            <cfelseif get_level_1.IS_STAGE eq 0>
                                                <img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
                                            <cfelseif get_level_1.IS_STAGE eq 1>
                                                <img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='398.Başladı'>">
                                            <cfelseif get_level_1.IS_STAGE eq 2>
                                                <img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='305.Bitti'>">
                                            <cfelseif get_level_1.IS_STAGE eq 3>
                                                <img src="/images/grey_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
                                            </cfif>
                                        </td>
                                        	
                                        <td nowrap>
                                        	<cfif len(get_operations.P_OPERATION_ID)>
                                             	<cfloop query="get_operations">
                                                 	<cfquery name="get_this_operations" dbtype="query">
                                                            SELECT        
                                                                ACTION_EMPLOYEE_ID,
                                                                ACTION_START_DATE
                                                            FROM 
                                                                GET_MAIN 
                                                            WHERE 
                                                                P_OPERATION_ID = #get_operations.P_OPERATION_ID# AND
                                                                REAL_AMOUNT = 0 and
                                                                ACTION_EMPLOYEE_ID > 0
                                                	</cfquery>
                                                    <input type="button" name="operation_#get_operations.P_OPERATION_ID#"  id="operation_#get_operations.P_OPERATION_ID#" title="<cfif get_this_operations.recordcount><cfloop query='get_this_operations'>Biten : #get_operations.REAL_AMOUNT# - #get_emp_info(ACTION_EMPLOYEE_ID,0,0)# - </cfloop><cfelse>Biten : #get_operations.REAL_AMOUNT#</cfif>" value="#OPERATION_TYPE#" id="operation_#P_OPERATION_ID#" onclick="operation(#P_OPERATION_ID#);" style=" text-align:center;width:100px; font-size:11px; height:30px; background-color:<cfif get_this_operations.recordcount>blue<cfelse><cfif get_operations.STAGE eq 0>orange<cfelseif get_operations.STAGE eq 1>green<cfelse>red</cfif></cfif>">
                                           		</cfloop>
                                       		<cfelse> 
                                            	<input type="button" name="operation#get_operations.currentrow#" id="operation#get_operations.currentrow#" style="width:100px; height:30px; background-color:gray">Tanımsız</button>
                                        	</cfif>
                                        </td>
                                    </tr>
                                    <cfloop query="get_level_2">
                                    	<cfquery name="get_level_3" dbtype="query">
                                            SELECT 
                                                P_ORDER_ID, 
                                                LOT_NO, 
                                                P_ORDER_NO, 
                                                IS_STAGE, 
                                                STOCK_CODE, 
                                                SPEC_MAIN_ID, 
                                                STOCK_ID, 
                                                PRODUCT_ID, 
                                                PRODUCT_NAME, 
                                                SPECT_VAR_NAME, 
                                                QUANTITY,
                                                ROW_RESULT_AMOUNT,
                                                EZGI_VTS_NUMBER
                                            FROM 
                                                GET_MAIN 
                                            WHERE 
                                                PO_RELATED_ID = #get_level_2.P_ORDER_ID#
                                            GROUP BY 
                                                P_ORDER_ID, 
                                                P_ORDER_ID, 
                                                LOT_NO, 
                                                P_ORDER_NO, 
                                                IS_STAGE, 
                                                STOCK_CODE, 
                                                SPEC_MAIN_ID, 
                                                STOCK_ID, 
                                                PRODUCT_ID, 
                                                PRODUCT_NAME, 
                                                SPECT_VAR_NAME, 
                                                QUANTITY,
                                                ROW_RESULT_AMOUNT,
                                                EZGI_VTS_NUMBER
                                        </cfquery>
                                   		<cfquery name="GET_TYPE" datasource="#DSN3#">
                                            SELECT        
                                                0 AS PIECE_TYPE
                                            FROM           
                                                EZGI_DESIGN_MAIN_ROW
                                            WHERE        
                                                DESIGN_MAIN_RELATED_ID = #get_level_2.STOCK_ID#
                                            UNION ALL
                                            SELECT        
                                                PIECE_TYPE
                                            FROM         
                                                EZGI_DESIGN_PIECE_ROWS
                                            WHERE        
                                                PIECE_RELATED_ID = #get_level_2.STOCK_ID#
                                            UNION ALL
                                            SELECT        
                                                0 AS PIECE_TYPE
                                            FROM           
                                                EZGI_DESIGN_PACKAGE_ROW
                                            WHERE        
                                                PACKAGE_RELATED_ID = #get_level_2.STOCK_ID#
                                        </cfquery>
                                        <cfquery name="get_operations" dbtype="query">
                                        	SELECT 
                                            	SUM(REAL_AMOUNT) AS REAL_AMOUNT,
                                                P_OPERATION_ID, 
                                                OPERATION_TYPE_ID, 
                                                OPERATION_CODE, 
                                                OPERATION_TYPE, 
                                                AMOUNT, 
                                                STAGE
                                            FROM 
                                                GET_MAIN 
                                            WHERE 
                                                P_ORDER_ID = #get_level_2.P_ORDER_ID#
                                            GROUP BY 
                                                P_OPERATION_ID, 
                                                OPERATION_TYPE_ID, 
                                                OPERATION_CODE, 
                                                OPERATION_TYPE, 
                                                AMOUNT, 
                                                STAGE
                                          	ORDER BY
                                            	OPERATION_CODE
                                  		</cfquery>
                                        <tr id="tr_#get_level_2.P_ORDER_ID#" style="height:30px; display:none" nowrap>
                                            <td style="background-color:FFFFCC;text-align:left;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" value="3" style="width:35px; height:25px; background-color:green; font-size:14px" /></td>
                                            <td style="text-align:center">
												<cfif get_type.PIECE_TYPE eq 1>
                                                    <img src="/images/butcegider.gif" title="<cf_get_lang dictionary_id='62.Yonga Levha'>"><span style="display:none">1</span>
                                                <cfelseif get_type.PIECE_TYPE eq 2>
                                                    <img src="/images/arrow_up.png" title="<cf_get_lang dictionary_id='402.Genel Reçete'>"><span style="display:none">2</span>
                                                <cfelseif get_type.PIECE_TYPE eq 3>
                                                    <img src="/images/elements.gif" title="<cf_get_lang dictionary_id='403.Montaj Ürünü'>"><span style="display:none">3</span>
                                                <cfelseif get_type.PIECE_TYPE eq 4>
                                                    <img src="/images/promo_multi.gif" title="<cf_get_lang dictionary_id='404.Hammadde'>"><span style="display:none">4</span>
                                                <cfelseif get_type.PIECE_TYPE eq 0>
                                                    <img src="/images/package.gif" title="<cf_get_lang dictionary_id='100.Paket'>"><span style="display:none">0</span>
                                                </cfif>
                                            </td>
                                            <td style="background-color:FFFFCC;text-align:left;">&nbsp;#get_level_2.PRODUCT_NAME#</td>
                                            <td style="background-color:FFFFCC;text-align:center;">&nbsp;#get_level_2.P_ORDER_NO#</td>
                                            <td style="background-color:FFFFCC;text-align:right;">#TlFormat(get_level_2.QUANTITY,0)#&nbsp;</td>
                                            <td style="background-color:FFFFCC;text-align:right;">#TlFormat(get_level_2.ROW_RESULT_AMOUNT,0)#&nbsp;</td>
                                            <td style="text-align:center">
                                            	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=production.popup_dsp_ezgi_prod_teknik_resim&p_order_id=#get_level_2.p_order_id#&p_operation_id=#get_operations.p_operation_id#','wwide');">
                                        			<img src="/images/photo.gif" width="20px" />
                                          		</a>
                                            </td>
                                            <td style="text-align:center;" nowrap>#get_level_2.EZGI_VTS_NUMBER#</td>
                                            <td style="text-align:center;">
												<cfif get_level_2.IS_STAGE eq 4>
                                                    <img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id='475.Onaylanmadı'>">
                                                <cfelseif get_level_2.IS_STAGE eq 0>
                                                    <img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
                                                <cfelseif get_level_2.IS_STAGE eq 1>
                                                    <img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='398.Başladı'>">
                                                <cfelseif get_level_2.IS_STAGE eq 2>
                                                    <img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='305.Bitti'>">
                                                <cfelseif get_level_2.IS_STAGE eq 3>
                                                    <img src="/images/grey_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
                                                </cfif>
                                            </td>	
                                            <td>
                                            	<cfif len(get_operations.P_OPERATION_ID)>
                                                    <cfloop query="get_operations">
                                                        <cfquery name="get_this_operations" dbtype="query">
                                                                SELECT        
                                                                    ACTION_EMPLOYEE_ID,
                                                                    ACTION_START_DATE
                                                                FROM 
                                                                    GET_MAIN 
                                                                WHERE 
                                                                    P_OPERATION_ID = #get_operations.P_OPERATION_ID# AND
                                                                    REAL_AMOUNT = 0 and
                                                                    ACTION_EMPLOYEE_ID > 0
                                                        </cfquery>
                                                        <input type="button" name="operation_#get_operations.P_OPERATION_ID#"  id="operation_#get_operations.P_OPERATION_ID#" title="<cfif get_this_operations.recordcount><cfloop query='get_this_operations'>Biten : #get_operations.REAL_AMOUNT# - #get_emp_info(ACTION_EMPLOYEE_ID,0,0)# - </cfloop><cfelse>Biten : #get_operations.REAL_AMOUNT#</cfif>" value="#OPERATION_TYPE#" id="operation_#P_OPERATION_ID#" onclick="operation(#P_OPERATION_ID#);" style=" text-align:center;width:100px; font-size:11px; height:30px; background-color:<cfif get_this_operations.recordcount>blue<cfelse><cfif get_operations.STAGE eq 0>orange<cfelseif get_operations.STAGE eq 1>green<cfelse>red</cfif></cfif>">
                                                    </cfloop>
                                                <cfelse> 
                                                    <input type="button" name="operation#get_operations.currentrow#" id="operation#get_operations.currentrow#" style="width:100px; height:30px; background-color:gray">Tanımsız</button>
                                                </cfif>
                                            </td>
                                        </tr>
                                        <cfloop query="get_level_3">
                                        	<cfquery name="GET_TYPE" datasource="#DSN3#">
                                                SELECT        
                                                    0 AS PIECE_TYPE
                                                FROM           
                                                    EZGI_DESIGN_MAIN_ROW
                                                WHERE        
                                                    DESIGN_MAIN_RELATED_ID = #get_level_3.STOCK_ID#
                                                UNION ALL
                                                SELECT        
                                                    PIECE_TYPE
                                                FROM         
                                                    EZGI_DESIGN_PIECE_ROWS
                                                WHERE        
                                                    PIECE_RELATED_ID = #get_level_3.STOCK_ID#
                                                UNION ALL
                                                SELECT        
                                                    0 AS PIECE_TYPE
                                                FROM           
                                                    EZGI_DESIGN_PACKAGE_ROW
                                                WHERE        
                                                    PACKAGE_RELATED_ID = #get_level_3.STOCK_ID#
                                            </cfquery>
                                            <cfquery name="get_operations" dbtype="query">
                                        	SELECT 
                                            	SUM(REAL_AMOUNT) AS REAL_AMOUNT,
                                                P_OPERATION_ID, 
                                                OPERATION_TYPE_ID, 
                                                OPERATION_CODE, 
                                                OPERATION_TYPE, 

                                                AMOUNT, 
                                                STAGE
                                            FROM 
                                                GET_MAIN 
                                            WHERE 
                                                P_ORDER_ID = #get_level_3.P_ORDER_ID#
                                            GROUP BY 
                                                P_OPERATION_ID, 
                                                OPERATION_TYPE_ID, 
                                                OPERATION_CODE, 
                                                OPERATION_TYPE, 
                                                AMOUNT, 
                                                STAGE
                                          	ORDER BY
                                            	OPERATION_CODE
                                  		</cfquery>
                                            <tr id="tr_#get_level_3.P_ORDER_ID#" style="height:30px; display:none" nowrap>
                                                <td style="background-color:FFFFCC;text-align:left;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" value="4" style="width:35px; height:25px; background-color:orange; font-size:14px" /></td>
                                                <td style="text-align:center">
													<cfif get_type.PIECE_TYPE eq 1>
                                                        <img src="/images/butcegider.gif" title="<cf_get_lang dictionary_id='62.Yonga Levha'>"><span style="display:none">1</span>
                                                    <cfelseif get_type.PIECE_TYPE eq 2>
                                                        <img src="/images/arrow_up.png" title="<cf_get_lang dictionary_id='402.Genel Reçete'>"><span style="display:none">2</span>
                                                    <cfelseif get_type.PIECE_TYPE eq 3>
                                                        <img src="/images/elements.gif" title="<cf_get_lang dictionary_id='403.Montaj Ürünü'>"><span style="display:none">3</span>
                                                    <cfelseif get_type.PIECE_TYPE eq 4>
                                                        <img src="/images/promo_multi.gif" title="<cf_get_lang dictionary_id='404.Hammadde'>"><span style="display:none">4</span>
                                                    <cfelseif get_type.PIECE_TYPE eq 0>
                                                        <img src="/images/package.gif" title="<cf_get_lang dictionary_id='100.Paket'>"><span style="display:none">0</span>
                                                    </cfif>
                                                </td>
                                                <td style="background-color:FFFFCC;text-align:left;">&nbsp;#get_level_3.PRODUCT_NAME#</td>
                                                <td style="background-color:FFFFCC;text-align:center;">&nbsp;#get_level_3.P_ORDER_NO#</td>
                                                <td style="background-color:FFFFCC;text-align:right;">#TlFormat(get_level_3.QUANTITY,0)#&nbsp;</td>
                                                <td style="background-color:FFFFCC;text-align:right;">#TlFormat(get_level_3.ROW_RESULT_AMOUNT,0)#&nbsp;</td>
                                                <td style="text-align:center">
                                                	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=production.popup_dsp_ezgi_prod_teknik_resim&p_order_id=#get_level_3.p_order_id#&p_operation_id=#get_operations.p_operation_id#','wwide');">
                                        			<img src="/images/photo.gif" width="20px" />
                                          		</a>
                                                </td>
                                                <td style="text-align:center;" nowrap>#get_level_3.EZGI_VTS_NUMBER#</td>
                                                <td style="text-align:center;">
													<cfif get_level_3.IS_STAGE eq 4>
                                                        <img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id='475.Onaylanmadı'>">
                                                    <cfelseif get_level_3.IS_STAGE eq 0>
                                                        <img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
                                                    <cfelseif get_level_3.IS_STAGE eq 1>
                                                        <img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='398.Başladı'>">
                                                    <cfelseif get_level_3.IS_STAGE eq 2>
                                                        <img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='305.Bitti'>">
                                                    <cfelseif get_level_3.IS_STAGE eq 3>
                                                        <img src="/images/grey_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
                                                    </cfif>
                                                </td>	
                                                <td>
                                                	<cfif len(get_operations.P_OPERATION_ID)>
                                                        <cfloop query="get_operations">
                                                            <cfquery name="get_this_operations" dbtype="query">
                                                                    SELECT        
                                                                        ACTION_EMPLOYEE_ID,
                                                                        ACTION_START_DATE
                                                                    FROM 
                                                                        GET_MAIN 
                                                                    WHERE 
                                                                        P_OPERATION_ID = #get_operations.P_OPERATION_ID# AND
                                                                        REAL_AMOUNT = 0 and
                                                                        ACTION_EMPLOYEE_ID > 0
                                                            </cfquery>
                                                            <input type="button" name="operation_#get_operations.P_OPERATION_ID#"  id="operation_#get_operations.P_OPERATION_ID#" title="<cfif get_this_operations.recordcount><cfloop query='get_this_operations'>Biten : #get_operations.REAL_AMOUNT# - #get_emp_info(ACTION_EMPLOYEE_ID,0,0)# - </cfloop><cfelse>Biten : #get_operations.REAL_AMOUNT#</cfif>" value="#OPERATION_TYPE#" id="operation_#P_OPERATION_ID#" onclick="operation(#P_OPERATION_ID#);" style=" text-align:center;width:100px; font-size:11px; height:30px; background-color:<cfif get_this_operations.recordcount>blue<cfelse><cfif get_operations.STAGE eq 0>orange<cfelseif get_operations.STAGE eq 1>green<cfelse>red</cfif></cfif>">
                                                        </cfloop>
                                                    <cfelse> 
                                                        <input type="button" name="operation#get_operations.currentrow#" id="operation#get_operations.currentrow#" style="width:100px; height:30px; background-color:gray">Tanımsız</button>
                                                    </cfif>
                                                </td>
                                            </tr>
                                        </cfloop>
                                    </cfloop>
                                </cfloop>
                          	</cfoutput>
                      	</cfif>
                    </tbody>
            </cf_form_list>
       	</cf_box>
	</cf_box>
</div>

<script language="javascript">
	function seviyelendir(p_order_id)
	{
		p_order_id_list = document.getElementById('p_order_id_list_'+p_order_id).value;
		list_uzunluk = list_len(p_order_id_list,',');
		if(document.getElementById('p_order_id_control_'+p_order_id).value == 0)
		{
			for(i=1;i<=list_uzunluk;i++)
			{
				p_order_id_ = list_getat(p_order_id_list,i,',');
				document.getElementById('tr_'+p_order_id_).style.display = '';
			}
			document.getElementById('p_order_id_control_'+p_order_id).value = 1;
			document.getElementById('level0_'+p_order_id).src = "images/production/list_up.gif";
		}
		else
		{
			for(i=1;i<=list_uzunluk;i++)
			{
				p_order_id_ = list_getat(p_order_id_list,i,',');
				document.getElementById('tr_'+p_order_id_).style.display = 'none';
			}
			document.getElementById('p_order_id_control_'+p_order_id).value = 0;
			document.getElementById('level0_'+p_order_id).src = "images/production/list_bottom.gif";
		}
	}
</script>