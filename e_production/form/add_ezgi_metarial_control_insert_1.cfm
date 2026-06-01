<cfquery name="get_orders_info" datasource="#dsn3#">
	SELECT        
    	O.ORDER_NUMBER,
        ISNULL(O.ORDER_ID,0) AS ORDER_ID,
        PO.QUANTITY,
        (SELECT TOP (1) PRODUCT_NAME FROM STOCKS WHERE STOCK_ID = PO.STOCK_ID) AS PRODUCT_NAME,
        (
        	SELECT TOP (1)
            	PRODUCT_UNIT.MAIN_UNIT
			FROM     
            	STOCKS INNER JOIN
             	PRODUCT_UNIT ON STOCKS.PRODUCT_UNIT_ID = PRODUCT_UNIT.PRODUCT_UNIT_ID
			WHERE  
            	STOCKS.STOCK_ID = PO.STOCK_ID
        ) AS MAIN_UNIT
	FROM            
    	PRODUCTION_ORDERS_ROW AS POR INNER JOIN
      	ORDERS AS O ON POR.ORDER_ID = O.ORDER_ID RIGHT OUTER JOIN
     	PRODUCTION_ORDERS AS PO ON POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
	WHERE        
    	PO.LOT_NO = '#attributes.lot_no#'
	GROUP BY 
    	O.ORDER_NUMBER,
        O.ORDER_ID,
        PO.QUANTITY,
        PO.STOCK_ID
</cfquery>
<!---Lot a Bağlı Kumaş ihtiyaç Bilgileri Toplanıyor--->
<cfquery name="get_malzeme" datasource="#dsn3#">
	SELECT     
    	<cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
       		PO.LOT_NO,
  		<cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
        	#get_orders_info.ORDER_ID# AS ORDER_ID,
    	</cfif> 
        POS.POR_STOCK_ID, 
        PU.MAIN_UNIT, 
        S.PRODUCT_NAME, 
        S.PRODUCT_CODE,
        S.STOCK_ID, 
        POS.AMOUNT, 
        SAQ.QUESTION_NAME,
        (SELECT PRODUCT_NAME FROM STOCKS WHERE STOCK_ID = PO.STOCK_ID) AS URUN_ADI
	FROM         
    	PRODUCTION_ORDERS_STOCKS AS POS INNER JOIN
       	PRODUCTION_ORDERS AS PO ON POS.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
        PRODUCT_UNIT AS PU ON POS.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN
        STOCKS AS S ON POS.STOCK_ID = S.STOCK_ID INNER JOIN
        SPECT_MAIN AS SM ON PO.SPEC_MAIN_ID = SM.SPECT_MAIN_ID INNER JOIN
        SPECT_MAIN_ROW AS SMR ON POS.SPECT_MAIN_ROW_ID = SMR.SPECT_MAIN_ROW_ID AND SM.SPECT_MAIN_ID = SMR.SPECT_MAIN_ID INNER JOIN
        #dsn_alias#.SETUP_ALTERNATIVE_QUESTIONS AS SAQ ON SMR.QUESTION_ID = SAQ.QUESTION_ID
	WHERE     
   		POS.TYPE = 2 AND 
        S.PRODUCT_CODE LIKE N'#get_default.FABRIC_CAT#%' AND
        <cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
        	PO.LOT_NO =#attributes.lot_no#
		<cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
        	PO.LOT_NO IN 	
            			(
            				SELECT        
                            	PO1.LOT_NO
							FROM            
                            	ORDER_ROW AS ORR INNER JOIN
                             	PRODUCTION_ORDERS AS PO INNER JOIN
                             	PRODUCTION_ORDERS_ROW AS PORR ON PO.P_ORDER_ID = PORR.PRODUCTION_ORDER_ID ON ORR.ORDER_ID = PORR.ORDER_ID INNER JOIN
                             	PRODUCTION_ORDERS_ROW AS PORR1 ON ORR.ORDER_ROW_ID = PORR1.ORDER_ROW_ID INNER JOIN
                             	EZGI_MASTER_ALT_PLAN AS EMAP INNER JOIN
                            	EZGI_MASTER_PLAN_RELATIONS AS EMAR ON EMAP.MASTER_ALT_PLAN_ID = EMAR.MASTER_ALT_PLAN_ID ON PORR1.PRODUCTION_ORDER_ID = EMAR.P_ORDER_ID INNER JOIN
                         		PRODUCTION_ORDERS AS PO1 ON PORR1.PRODUCTION_ORDER_ID = PO1.P_ORDER_ID
							WHERE        
                            	PO.LOT_NO = N'#attributes.lot_no#' AND 
                                EMAP.MASTER_PLAN_ID = #attributes.master_plan_id#
            				
            
            			)
        </cfif>
  	ORDER BY
    	S.PRODUCT_CODE
</cfquery>
<cfset por_stock_id_list = Valuelist(get_malzeme.POR_STOCK_ID)>
<cfif get_malzeme.recordcount>
	<cfquery name="get_malzeme_group" dbtype="query">
    	SELECT
        	STOCK_ID,
    		SUM(AMOUNT) TOTAL_AMOUNT
      	FROM
        	GET_MALZEME
       	GROUP BY
        	STOCK_ID      
    </cfquery>
    <cfif get_malzeme_group.recordcount>
    	<cfloop query="get_malzeme_group">
    		<cfset 'TOTAL_AMOUNT_#STOCK_ID#' = TOTAL_AMOUNT>
    	</cfloop>
    </cfif>
    <cfset stock_id_list = ValueList(get_malzeme.STOCK_ID)>
    <!---Optimizasyon Giriş Kontrolü Yapılıyor--->
    <cfquery name="get_ezgi_metarial_control" datasource="#dsn3#">
    	SELECT     
            POR_STOCK_ID, 
            AMOUNT, 
            RECORD_EMP, 
            RECORD_DATE, 
            UPDATE_EMP, 
            UPDATE_DATE,
            PASTAL_CODE
		FROM         
        	EZGI_METARIAL_CONTROL
		WHERE     
        	<cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
            	LOT_NO =#attributes.lot_no#
            <cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
        		ORDER_ID = #get_orders_info.ORDER_ID# AND
                POR_STOCK_ID IN (#por_stock_id_list#)
        	</cfif>
    </cfquery>
    <cfif get_ezgi_metarial_control.recordcount >
    	<cfset 'upd_#lot_row#' = 1>
        <cfset record_emp =get_ezgi_metarial_control.RECORD_EMP>
        <cfset record_date =get_ezgi_metarial_control.RECORD_DATE>
        <cfset update_emp =get_ezgi_metarial_control.UPDATE_EMP>
        <cfset update_date =get_ezgi_metarial_control.UPDATE_DATE>
        <cfoutput query="get_ezgi_metarial_control">
        	<cfset 'AMOUNT_#POR_STOCK_ID#' = AMOUNT>
            <cfset 'PASTAL_CODE_#POR_STOCK_ID#' = PASTAL_CODE>
        </cfoutput>
    </cfif>
    <cfinput type="hidden" name="upd_#lot_row#" value="#Evaluate('upd_#lot_row#')#">
    <cfset ic_talep = 0>
 	<cfquery name="get_kontrol" datasource="#dsn3#">
     	SELECT 
        	ISNULL(STATUS,0) STATUS 
       	FROM 
        	EZGI_METARIAL_CONTROL 
      	WHERE 
            <cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
            	LOT_NO =#attributes.lot_no#
            <cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
        		ORDER_ID = #get_orders_info.ORDER_ID#	
        	</cfif>
  	</cfquery>
  	<cfif get_kontrol.recordcount>
     	<cfquery name="get_kontrol_1" dbtype="query">
        	SELECT STATUS FROM get_kontrol WHERE STATUS = 0
     	</cfquery>
     	<cfif not get_kontrol_1.recordcount and not isdefined('attributes.p_order_id_list')>
          	<cfset ic_talep = 1>     
    	</cfif>
   	</cfif>
    <cfif ic_talep eq 1>
        <cfquery name="_PRODUCT_TOTAL_STOCK_" datasource="#DSN2#"><!--- Ürünlerin stock durumlarını liste yöntemi ile alıyoruz. --->
            SELECT 
                    ISNULL(SUM(PRODUCT_STOCK),0) AS PRODUCT_STOCK,
                    STOCK_ID
                FROM 
                    (
                        SELECT
                            SUM(SR.STOCK_IN - SR.STOCK_OUT) AS PRODUCT_STOCK, 
                            ISNULL(SR.SPECT_VAR_ID,0) SPECT_VAR_ID,
                            S.PRODUCT_ID, 
                            S.STOCK_ID, 
                            S.STOCK_CODE, 
                            S.PROPERTY,
                            S.STOCK_STATUS, 
                            S.BARCOD
                        FROM
                            #dsn1_alias#.STOCKS S,
                            STOCKS_ROW SR
                        WHERE
                            S.STOCK_ID = SR.STOCK_ID AND 
                            SR.STORE = #control_department# AND 
                            SR.STORE_LOCATION = #control_location#
                        GROUP BY
                            SR.SPECT_VAR_ID,
                            S.PRODUCT_ID,
                            S.STOCK_ID,
                            S.STOCK_CODE,
                            S.PROPERTY,
                            S.STOCK_STATUS, 
                            S.BARCOD
                    ) AS GET_STOCK
                WHERE
                    STOCK_ID IN (#stock_id_list#)
                GROUP BY 
                    STOCK_ID
            </cfquery>
            <cfoutput query="_PRODUCT_TOTAL_STOCK_">
                <cfset 'PRODUCT_STOCK_#STOCK_ID#'= PRODUCT_STOCK>
            </cfoutput>
            <cfquery name="getStockStrategy" datasource="#dsn3#"><!--- Ürünün stok stratejilerini çekiyoruz. --->
                SELECT
                    DISTINCT
                    SS.STOCK_ID,
                    ISNULL(SS.MAXIMUM_STOCK,0) AS MAXIMUM_STOCK,
                    ISNULL(SS.PROVISION_TIME,0) AS PROVISION_TIME ,
                    ISNULL(SS.REPEAT_STOCK_VALUE,0) AS REPEAT_STOCK_VALUE,
                    ISNULL(SS.MINIMUM_STOCK,0) AS MINIMUM_STOCK,
                    ISNULL(SS.MINIMUM_ORDER_STOCK_VALUE,0) AS MINIMUM_ORDER_STOCK_VALUE
                FROM
                    STOCK_STRATEGY SS
                WHERE
                    SS.STOCK_ID IN(#stock_id_list#) AND
                    ISNULL(SS.DEPARTMENT_ID,0)=0
            </cfquery>
            <cfoutput query="getStockStrategy">
                <cfset 'MAXIMUM_STOCK_#STOCK_ID#'= MAXIMUM_STOCK>
                <cfset 'PROVISION_TIME_#STOCK_ID#'= PROVISION_TIME>
                <cfset 'REPEAT_STOCK_VALUE_#STOCK_ID#'= REPEAT_STOCK_VALUE>
                <cfset 'MINIMUM_STOCK_#STOCK_ID#'= MINIMUM_STOCK>
                <cfset 'MINIMUM_ORDER_STOCK_VALUE_#STOCK_ID#'= MINIMUM_ORDER_STOCK_VALUE>
            </cfoutput>
            <cfquery name="_GET_STOCK_RESERVED_" datasource="#DSN3#"><!--- Ürünün rezerve durumlarını liste yöntemi ile çekiyoruz. --->
                SELECT
                    ISNULL(SUM(STOCK_ARTIR),0) AS ARTAN,
                    ISNULL(SUM(STOCK_AZALT),0) AS AZALAN,
                    STOCK_ID
                FROM
                    GET_STOCK_RESERVED_SPECT
                WHERE
                    STOCK_ID IN (#stock_id_list#)
                GROUP BY 
                    STOCK_ID
            </cfquery>
            <cfoutput query="_GET_STOCK_RESERVED_">
                <cfset 'ARTAN_STOCK_#STOCK_ID#'= ARTAN>
                <cfset 'AZALAN_STOCK_#STOCK_ID#'= AZALAN>
            </cfoutput>
            <cfquery name="_location_based_total_stock_" datasource="#dsn2#">
                SELECT
                    STOCK_ID,
                    SUM(STOCK_IN - SR.STOCK_OUT) AS TOTAL_LOCATION_STOCK
                FROM
                    STOCKS_ROW SR,
                    #dsn_alias#.STOCKS_LOCATION SL 
                WHERE
                    STOCK_ID IN (#stock_id_list#) AND
                    SR.STORE = SL.DEPARTMENT_ID AND
                    SR.STORE_LOCATION = SL.LOCATION_ID AND
                    NO_SALE = 1
               GROUP BY STOCK_ID
        </cfquery>
   	</cfif>
    <!---Lot a Bağlı İhtiyaçların Stok Grup Toplamları Bulunuyor--->
    <cfquery name="get_malzeme_group" dbtype="query">
		SELECT     
            <cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
            	LOT_NO,
            <cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
        		ORDER_ID,
        	</cfif>
            MAIN_UNIT, 
            PRODUCT_NAME, 
            PRODUCT_CODE,
            STOCK_ID, 
            sum(AMOUNT) AMOUNT
        FROM
        	get_malzeme     
		GROUP BY
        	<cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
            	LOT_NO,
            <cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
        		ORDER_ID,
        	</cfif>
            MAIN_UNIT, 
            PRODUCT_NAME, 
            PRODUCT_CODE,
            STOCK_ID
        ORDER BY
            PRODUCT_CODE
    </cfquery>
    <cfsavecontent variable="title_">
    	<cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
        	Kumaş Stok Kontrol - Lot No : <cfoutput>#get_malzeme.lot_no#</cfoutput>
    	<cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
        	Kumaş Stok Kontrol - Sipariş No : <cfoutput>#get_orders_info.order_number#</cfoutput>
   		</cfif>
   		- <cfoutput>#get_orders_info.PRODUCT_NAME# - (#get_orders_info.QUANTITY# - #get_orders_info.MAIN_UNIT#)</cfoutput>
    </cfsavecontent>
    <div class="col col-12 col-xs-12">
        <cf_box title="#title_#">
        	<cf_grid_list>
           		<thead>
               		<tr height="20">
                        <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                        <th><cf_get_lang dictionary_id='36625.Alternatif Soru'></th>
                        <th><cf_get_lang dictionary_id='1074.Kumaş Adı'></th>
                        <cfif Evaluate('upd_#lot_row#') eq 1>
                            <th width="40" align="right"><cf_get_lang dictionary_id='57635.Miktar'></th>
                        </cfif>
                        <th width="100"><cf_get_lang dictionary_id='1075.Pastal Kodu'></th>
                        <th width="40" align="right"><cf_get_lang dictionary_id='583.Optimization'></th>  
                        <th width="40" align="center" ><cf_get_lang dictionary_id='57636.Birim'></th>
                        <cfif Evaluate('upd_#lot_row#') eq 1  and not isdefined('attributes.p_order_id_list')>
                            <th width="70" align="center" ><cf_get_lang dictionary_id='1084.M.Kontrol'></th>
                        </cfif>      
                    </tr>
					<cfif get_malzeme.recordcount>
                    	<cfif Evaluate('upd_#lot_row#') eq 1 and not isdefined('attributes.p_order_id_list')>
                        	<tr height="20">
                            	<th colspan="7"></th>
                            	<th>
                                	<select name="total_control" style="width:82;text-align:center; height:20px" onchange="secenek(this.value)">
                                    	<option value="0" <cfif attributes.total_control eq 0>selected</cfif>><cf_get_lang dictionary_id='50936.Yapılmadı'></option>
                                    	<option value="1" <cfif attributes.total_control eq 1>selected</cfif>><cf_get_lang dictionary_id='58564.Var'></option>
                                    	<option value="2" <cfif attributes.total_control eq 2>selected</cfif>><cf_get_lang dictionary_id='58546.Yok'></option>
                                	</select>
                            	</th>
                        	</tr>
                    	</cfif>
                    </cfif>
          		</thead>
                <tbody>          
                    <cfif get_malzeme.recordcount>
                    	<cfset stock_ = get_malzeme.stock_id>
                    	<cfoutput query="get_malzeme">
                            <cfquery name="METARIAL_KONTROL" datasource="#dsn3#">
                                SELECT      
                                    ISNULL(STATUS,0) STATUS,
                                    AMOUNT OLD_AMOUNT
                                FROM         
                                    EZGI_METARIAL_CONTROL
                                WHERE     
                                    POR_STOCK_ID = #POR_STOCK_ID#
                            </cfquery>
							<cfif stock_ neq stock_id>
                                <tr height="20">
                                    <td colspan="<cfif Evaluate('upd_#lot_row#') eq 1 and not isdefined('attributes.p_order_id_list')>5<cfelse>4</cfif>" style="text-align:right; font-weight:bold"> Toplam</td>
                                    <td style="text-align:right">
                                        <input type="text" name="t_amount_#lot_row#_#stock_#" style="text-align:right; font-weight:bold; width:95%" value="<cfif isdefined('TOTAL_AMOUNT_#stock_#')>#Tlformat(Evaluate('TOTAL_AMOUNT_#stock_#'))#<cfelse>0</cfif>">
                                    </td>
                                    <td align="center" valign="middle">
                                        <!---<a href="#request.self#?fuseaction=objects.popup_list_ezgi_material_lot_search&stock_id=#stock_#&amount=#Evaluate('TOTAL_AMOUNT_#stock_#')#&lot_no=#get_malzeme.lot_no#" ><img src="/images/plus_list.gif" title="Rezervasyon <cf_get_lang_main no='170.Ekle'>"></a>--->
                                    </td>
                                    <cfif Evaluate('upd_#lot_row#') eq 1 and not isdefined('attributes.p_order_id_list')>
                                        <td></td>
                                    </cfif>
                                </tr>
                            	<cfset stock_ = get_malzeme.stock_id>
                        	</cfif>
                            <tr> 
                                <input type="hidden" name="por_stock_id_#lot_row#" value="#POR_STOCK_ID#" />
                                
                                <input type="hidden" name="old_amount_#lot_row#_#POR_STOCK_ID#" value="#AMOUNT#" />
                                <td style="font-weight:bold; height:25px">#URUN_ADI#</td>
                                <td>#QUESTION_NAME#</td>
                                <td>#PRODUCT_NAME#</td>
                                <cfif Evaluate('upd_#lot_row#') eq 1>
                                    <td style="text-align:right"><cfif isdefined('AMOUNT_#POR_STOCK_ID#')>#TlFormat(Evaluate('AMOUNT_#POR_STOCK_ID#'))#</cfif></td>
                                </cfif>
                                <td>
                                    <input type="text" name="pastal_code_#lot_row#_#POR_STOCK_ID#" maxlength="99"  style="width:95%; text-align:left; " value="<cfif isdefined('PASTAL_CODE_#POR_STOCK_ID#')>#Evaluate('PASTAL_CODE_#POR_STOCK_ID#')#</cfif>">
                                </td>
                                
                                <td style="text-align:right">
                                    <input type="hidden" name="metarial_control_amount_#lot_row#_#POR_STOCK_ID#" readonly="readonly" style="width:60px; text-align:right" value="#Tlformat(AMOUNT)#">
                                    #Tlformat(AMOUNT)#
                                </td>
                                <td align="center">#MAIN_UNIT#</td>
                                <cfif Evaluate('upd_#lot_row#') eq 1 and not isdefined('attributes.p_order_id_list')>
                                    <td align="center">
                                        <select id="var_yok_#lot_row#_#POR_STOCK_ID#" name="var_yok_#lot_row#_#POR_STOCK_ID#" style="width:82; text-align:center; height:20px">
                                            <option value="0" <cfif METARIAL_KONTROL.STATUS eq 0>selected</cfif>><cf_get_lang dictionary_id='50936.Yapılmadı'></option>
                                            <option value="1" <cfif METARIAL_KONTROL.STATUS eq 1>selected</cfif>><cf_get_lang dictionary_id='58564.Var'></option>
                                            <option value="2" <cfif METARIAL_KONTROL.STATUS eq 2>selected</cfif>><cf_get_lang dictionary_id='58546.Yok'></option>
                                        </select>
                                    </td>
                                </cfif>
                            </tr>
                    	</cfoutput>
                  	</cfif>
              	</tbody>
                <tfoot>
                    <tr height="20">
                        <cfoutput>
                        <td colspan="<cfif Evaluate('upd_#lot_row#') eq 1 and not isdefined('attributes.p_order_id_list')>5<cfelse>4</cfif>" style="text-align:right; font-weight:bold"> <cf_get_lang dictionary_id='57492.Toplam'></td>
                        <td style="text-align:right"><input type="text" name="t_amount_#lot_row#_#stock_#" style=" width:95%;text-align:right; font-weight:bold" value="<cfif isdefined('TOTAL_AMOUNT_#stock_#')>#Tlformat(Evaluate('TOTAL_AMOUNT_#stock_#'))#<cfelse>0</cfif>"></td>
                        <td align="center" valign="middle">&nbsp;
                            <!---<a href="#request.self#?fuseaction=objects.popup_list_ezgi_material_lot_search&stock_id=#stock_#&amount=#Evaluate('TOTAL_AMOUNT_#stock_#')#&lot_no=#get_malzeme.lot_no#" ><img src="/images/plus_list.gif" title="Rezervasyon <cf_get_lang_main no='170.Ekle'>"></a>--->
                        </td>
                        <cfif Evaluate('upd_#lot_row#') eq 1>
                            <td>&nbsp;</td>
                        </cfif>
                        </cfoutput>
                    </tr>
            	</tfoot>
          	</cf_grid_list>
       	</cf_box>
  	</div>
</cfif>
