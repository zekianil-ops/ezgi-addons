<!---
    File: add_ezgi_metarial_ambar_fisi.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfquery name="get_default" datasource="#dsn3#">
	SELECT       
    	EMAD.DEFAULT_RAW_STORE_ID, 
        EMAD.DEFAULT_RAW_LOC_ID, 
        EMAD.DEFAULT_PRODUCTION_STORE_ID, 
        EMAD.DEFAULT_PRODUCTION_LOC_ID, 
        EMAD.POINT_METHOD, 
        EMAD.CONTROL_METHOD,
        EMAD.FABRIC_CAT
	FROM            
    	EZGI_MASTER_PLAN_DEFAULTS AS EMAD INNER JOIN
     	EZGI_MASTER_PLAN AS EMAP ON EMAD.SHIFT_ID = EMAP.MASTER_PLAN_CAT_ID
	WHERE        
    	EMAP.MASTER_PLAN_ID = #attributes.master_plan_id#
</cfquery>
<cfset upd = 0>
<cfset control_department = get_default.DEFAULT_RAW_STORE_ID>
<cfset control_location = get_default.DEFAULT_RAW_LOC_ID>
<cfset in_department = get_default.DEFAULT_PRODUCTION_STORE_ID>
<cfset in_location = get_default.DEFAULT_PRODUCTION_LOC_ID>
<!---Lot a Bağlı Siparişin Açıklaması Alınıyor--->
<cfquery name="get_orders_info" datasource="#dsn3#">
	SELECT        
    	O.ORDER_NUMBER,
        ISNULL(O.ORDER_ID,0) AS ORDER_ID
	FROM            
    	PRODUCTION_ORDERS_ROW AS POR INNER JOIN
      	ORDERS AS O ON POR.ORDER_ID = O.ORDER_ID RIGHT OUTER JOIN
     	PRODUCTION_ORDERS AS PO ON POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
	WHERE        
    	PO.LOT_NO = '#attributes.lot_no#'
	GROUP BY 
    	O.ORDER_NUMBER,
        O.ORDER_ID
</cfquery>

<!---Lot a Bağlı Kumaş ihtiyaç Bilgileri Toplanıyor--->
<cfquery name="get_malzeme" datasource="#dsn3#">
	SELECT     
    	<cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
       		PO.LOT_NO,
  		<cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
        	#get_orders_info.ORDER_ID# AS LOT_NO,
    	</cfif>         
        POS.POR_STOCK_ID, 
        PU.MAIN_UNIT, 
        S.PRODUCT_NAME, 
        S.PRODUCT_CODE,
        S.STOCK_ID, 
        POS.AMOUNT, 
        SAQ.QUESTION_NAME
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
        S.PRODUCT_CODE LIKE '#get_default.FABRIC_CAT#%' AND
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
    <cfset stock_id_list = ValueList(get_malzeme.STOCK_ID)>
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
        <cfquery name="get_ic_talep" datasource="#dsn3#">
        	SELECT 
            	I.INTERNAL_NUMBER, 
                I.INTERNAL_ID,
                EMR.ACTION_ID, 
                IR.STOCK_ID, 
                ORR.DELIVER_DATE, 
                O.ORDER_NUMBER, 
                O.DELIVERDATE,
                O.ORDER_ID
			FROM     
            	ORDERS AS O INNER JOIN
                ORDER_ROW AS ORR ON O.ORDER_ID = ORR.ORDER_ID RIGHT OUTER JOIN
                EZGI_METARIAL_RELATIONS AS EMR INNER JOIN
                INTERNALDEMAND AS I ON EMR.ACTION_ID = I.INTERNAL_ID INNER JOIN
                INTERNALDEMAND_ROW AS IR ON I.INTERNAL_ID = IR.I_ID ON ORR.WRK_ROW_RELATION_ID = IR.WRK_ROW_ID
			WHERE  
                EMR.TYPE = 1 AND 
              	<cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
                	EMR.LOT_NO = '#attributes.lot_no#'
              	<cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
                	EMR.LOT_NO = '#get_orders_info.ORDER_number#'
             	</cfif>
       	</cfquery>
        <cfif get_ic_talep.recordcount>
        	<cfoutput query="get_ic_talep">
            	<cfset 'ACTION_ID_#STOCK_ID#' = ACTION_ID>
                <cfset 'INTERNAL_NUMBER_#STOCK_ID#' = INTERNAL_NUMBER>
                <cfset 'INTERNAL_ID_#STOCK_ID#' = INTERNAL_ID>
                <cfset 'ORDER_NUMBER_#STOCK_ID#' = ORDER_NUMBER>
                <cfset 'ORDER_ID_#STOCK_ID#' = ORDER_ID>
                <cfif len(DELIVER_DATE)><!---Satır Doluysa--->
                	<cfset 'DELIVER_DATE_#STOCK_ID#' = DELIVER_DATE>
              	<cfelse>
                	<cfset 'DELIVER_DATE_#STOCK_ID#' = DELIVERDATE>
                </cfif>
          	</cfoutput>
     	</cfif>
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
    <!---Lot a Bağlı İhtiyaçların Stok Grup Toplamları Bulunuyor--->
    <cfquery name="get_malzeme_group" dbtype="query">
		SELECT  
        	<cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
                LOT_NO,
            <cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
                #get_orders_info.ORDER_ID# AS ORDER_ID,
            </cfif>    

            MAIN_UNIT, 
            PRODUCT_NAME, 
            PRODUCT_CODE,
            STOCK_ID, 
            sum(AMOUNT) AMOUNT
        FROM
        	get_malzeme     
		GROUP BY
        	LOT_NO, 
            MAIN_UNIT, 
            PRODUCT_NAME, 
            PRODUCT_CODE,
            STOCK_ID
        ORDER BY
            PRODUCT_CODE
    </cfquery>
    <cfquery name="get_period" datasource="#dsn3#">
        SELECT     
            PERIOD_ID
        FROM         
            EZGI_METARIAL_RELATIONS
        WHERE     
            TYPE = 2 AND 
            <cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
             	LOT_NO = '#attributes.lot_no#'
         	<cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
            	ORDER_ID = #get_orders_info.ORDER_ID#
         	</cfif> 
    </cfquery>
    <cfif get_period.recordcount>
    	<cfset period_list = ValueList(get_period.PERIOD_ID)>
      	<cfquery name="get_period_ship_dsns" datasource="#dsn3#">
          	SELECT PERIOD_YEAR,OUR_COMPANY_ID,PERIOD_ID FROM #dsn_alias#.SETUP_PERIOD WHERE PERIOD_ID IN (#period_list#)
       	</cfquery>
    </cfif>
    <cfif isdefined('period_list') and listlen(period_list) and period_list neq 0>
		<cfquery name="get_control_ambar_fis" datasource="#DSN3#">
			SELECT 
            	STOCK_ID,
              	SUM(AMOUNT) AMOUNT
           	FROM
          		(
                <cfloop query="get_period_ship_dsns">
                    SELECT     
                        SFR.STOCK_ID, 
                        SFR.AMOUNT
                    FROM         
                        EZGI_METARIAL_RELATIONS INNER JOIN
                        #dsn#_#get_period_ship_dsns.PERIOD_YEAR#_#get_period_ship_dsns.OUR_COMPANY_ID#.STOCK_FIS_ROW AS SFR ON EZGI_METARIAL_RELATIONS.ACTION_ID = SFR.FIS_ID
                    WHERE     
                        EZGI_METARIAL_RELATIONS.TYPE = 2 AND 
                        EZGI_METARIAL_RELATIONS.PERIOD_ID = #get_period_ship_dsns.period_id# AND 
                        <cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
                            EZGI_METARIAL_RELATIONS.LOT_NO = '#attributes.lot_no#'
                        <cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
                            EZGI_METARIAL_RELATIONS.ORDER_ID = #get_orders_info.ORDER_ID#
                        </cfif> 
                    	<cfif currentrow neq get_period_ship_dsns.recordcount> UNION ALL </cfif> 
                </cfloop>
                ) TBL
           	GROUP BY
            	STOCK_ID 			
		</cfquery>
        <cfoutput query="get_control_ambar_fis">
        	<cfset 'AMOUNT_#STOCK_ID#'= AMOUNT>
        </cfoutput>
	</cfif>
    <div class="col col-12 col-xs-12">
        <cf_box title="Ambar Fişi Kontrol">
        	<cfform name="kumaskontrol" action="#request.self#?fuseaction=prod.add_ezgi_metarial_ambar_fisi" method="post">
                <cfinput type="hidden" name="lot_no" value="#get_malzeme.lot_no#">
                <cfinput type="hidden" name="dept_in" value="#in_department#">
                <cfinput type="hidden" name="dept_out" value="#control_department#">
                <cfinput type="hidden" name="loc_in" value="#in_location#">
                <cfinput type="hidden" name="loc_out" value="#control_location#">
                <cf_grid_list>
                	<thead>
                        <tr height="35mm">
                            <th>Stok Kodu</th>
                            <th>Ürün</th>
                            <th width="60" style="text-align:center;"><cf_get_lang dictionary_id='57452.Stok'></th>
                            <th width="60" style="text-align:center;"><cf_get_lang dictionary_id='36601.Min Stok'></th>
                            <th width="60" style="text-align:center;" title="<cf_get_lang dictionary_id='30008.Satınalma Siparişleri.'>"><cf_get_lang dictionary_id='57611.Sipariş'></th>
                            <th width="60" style="text-align:center;"><cf_get_lang dictionary_id='1071.Tedarik (Gün)'></th>
                            <th width="60" style="text-align:center;"><cf_get_lang dictionary_id='1072.Sevk Miktarı'></th>
                            <th width="60" style="text-align:center;"><cf_get_lang dictionary_id='1073.Sevk Edilen'></th>
                            <th width="25" style="text-align:center;"></th>
                        </tr>
                   	</thead>
                    <tbody>
                    	<cfquery name="get_kontrol_1" datasource="#dsn3#">
                            SELECT
                                POS.STOCK_ID, 
                                POS.AMOUNT
                            FROM         
                                EZGI_METARIAL_CONTROL AS EMC INNER JOIN
                                PRODUCTION_ORDERS_STOCKS AS POS ON EMC.POR_STOCK_ID = POS.POR_STOCK_ID
                            WHERE     
                                <cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
                                    EMC.LOT_NO = N'#attributes.lot_no#'
                                <cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
                                    EMC.ORDER_ID = #get_orders_info.ORDER_ID# AND
                                    EMC.POR_STOCK_ID IN (#por_stock_id_list#)
                                </cfif>
                        </cfquery>
                        
                        <cfquery name="METARIAL_KONTROL" dbtype="query">
                            SELECT
                                STOCK_ID, 
                                SUM(AMOUNT) AS AMOUNT
                            FROM         
                                get_kontrol_1
                            GROUP BY 
                                STOCK_ID
                        </cfquery>
                        <cfoutput query="METARIAL_KONTROL">
                            <cfset 'm_kontrol_#STOCK_ID#' = AMOUNT>
                        </cfoutput>
                        <cfoutput query="get_malzeme_group">
                            <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row"> 
                                <td>#PRODUCT_CODE#</td>
                        		<td>#PRODUCT_NAME#</td>
                                <td style="text-align:right;"><cfif isdefined('PRODUCT_STOCK_#STOCK_ID#')>#evaluate('PRODUCT_STOCK_#STOCK_ID#')#<cfelse>0</cfif></td>
                                <td style="text-align:right;"><cfif isdefined('MINIMUM_STOCK_#STOCK_ID#')>#evaluate('MINIMUM_STOCK_#STOCK_ID#')#<cfelse>0</cfif></td>
                                <td style="text-align:right;">
                                    <cfif isdefined('ARTAN_STOCK_#STOCK_ID#')>
                                            #evaluate('ARTAN_STOCK_#STOCK_ID#')#
                                    <cfelse>
                                        0
                                    </cfif>
                                </td>
                                <td style="text-align:right;"><cfif isdefined('PROVISION_TIME_#STOCK_ID#')>#evaluate('PROVISION_TIME_#STOCK_ID#')#<cfelse>0</cfif></td>
                                <td style="text-align:right;">
                                    <cfif isdefined('m_kontrol_#STOCK_ID#')>
                                        #TlFormat(Evaluate('m_kontrol_#STOCK_ID#'))#
                                    <cfelse>
                                        0
                                    </cfif>
                                </td>
                                <td style="text-align:right;">
                                    <cfif isdefined('AMOUNT_#STOCK_ID#')>
                                        #Tlformat(Evaluate('AMOUNT_#STOCK_ID#'))#
                                    <cfelse>
                                        0
                                    </cfif>
                                </td>
                                <td style="text-align:center;" valign="middle">
                                    <cfif isdefined('AMOUNT_#STOCK_ID#') and isdefined('m_kontrol_#STOCK_ID#')>
                                        <img src="/images/c_ok.gif" title="Ambar Fişi Düzenlendi" border="0">
                                    <cfelse>
                                        <cfif isdefined('m_kontrol_#STOCK_ID#') and isdefined('PRODUCT_STOCK_#STOCK_ID#') and Evaluate('m_kontrol_#STOCK_ID#') lte Evaluate('PRODUCT_STOCK_#STOCK_ID#')>
                                            <input type="checkbox" name="select_production" value="#STOCK_ID#_#Evaluate('m_kontrol_#STOCK_ID#')#">
                                        <cfelse>
                                            
                                        </cfif>
                                    </cfif>
                                </td>
                            </tr>
                        </cfoutput>
                  	</tbody>
                    <tfoot>
                    	<tr class="color-list" height="35">
                            <td align="right" valign="middle" colspan="9">
                            	<!---<input type="button" value="Ambar Fişi Düzenle" onClick="grupla();" style="background-color:darkturquoise; height:35px">--->
                                <button name="button" style="background-color:darkturquoise; height:35px" onClick="grupla();">Ambar Fişi Düzenle</button>
                           	</td>
                        </tr> 
                    </tfoot>
              	</cf_grid_list>
           	</cfform>
      	</cf_box>
  	</div>
    <div class="col col-12 col-xs-12">
        <cf_box title="İç Talep ve Sipariş Kontrol">
        	<cf_grid_list>
            	<thead>
                	<tr height="35mm">
                     	<th>Stok Kodu</th>
                     	<th>Ürün</th>
                      	<th width="60" style="text-align:center;">İhtiyaç</th>
                        <th width="80" style="text-align:center;">İç Talep No</th>
                        <th width="80" style="text-align:center;">Sipariş No</th>
                        <th width="80" style="text-align:center;">Teslim Tarihi</th>
                 	</tr>
             	</thead>
                <tbody>
                	<cfoutput query="get_malzeme_group">
                     	<tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row"> 
                         	<td>#PRODUCT_CODE#</td>
                        	<td>#PRODUCT_NAME#</td>
                            <td style="text-align:right">#TlFormat(AMOUNT,2)#</td>
                            <td style="text-align:center">
                            	<cfif isdefined('INTERNAL_NUMBER_#STOCK_ID#')>
                            		<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=purchase.list_internaldemand&event=upd&id=#Evaluate('INTERNAL_ID_#STOCK_ID#')#','longpage');">
                            			#Evaluate('INTERNAL_NUMBER_#STOCK_ID#')#
                                  	</a>
                              	</cfif>
                            </td>
                            <td style="text-align:center">
                            	<cfif isdefined('ORDER_NUMBER_#STOCK_ID#')>
                            		<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=purchase.list_order&event=upd&order_id=#Evaluate('ORDER_ID_#STOCK_ID#')#','longpage');">
                            			#Evaluate('ORDER_NUMBER_#STOCK_ID#')#
                                  	</a>
                              	</cfif>
                            </td>
                            <td style="text-align:center">
                            	<cfif isdefined('DELIVER_DATE_#STOCK_ID#')>#DateFormat(Evaluate('DELIVER_DATE_#STOCK_ID#'),dateformat_style)#</cfif>
                            </td>
                    	</tr>
                   	</cfoutput>
                </tbody>
        	</cf_grid_list>
        </cf_box>
  	</div>
</cfif>
<script language="javascript">
	function grupla(type)
		{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
			p_order_id_list = '';
			chck_leng = document.getElementsByName('select_production').length;
			for(ci=0;ci<chck_leng;ci++)
			{
				var my_objets = document.all.select_production[ci];
				if(chck_leng == 1)
					var my_objets =document.all.select_production;
				if(type == -1)
				{//hepsini seç denilmişse	
					if(my_objets.checked == true)
						my_objets.checked = false;
					else
						my_objets.checked = true;
				}
				else
				{
					if(my_objets.checked == true)
						p_order_id_list +=my_objets.value+',';
				}
			}
			var lot_no = document.all.lot_no.value;
			var dept_out = document.all.dept_out.value;
			var dept_in = document.all.dept_in.value;
			var loc_out = document.all.loc_out.value;
			var loc_in = document.all.loc_in.value;
			p_order_id_list = p_order_id_list.substr(0,p_order_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(p_order_id_list=='')
			{
			alert('<cf_get_lang dictionary_id='1077.İç Talep İçin Seçim Yapınız !!!'>');
			}
			else
			{
				document.getElementById("kumaskontrol").action = '<cfoutput>#request.self#?fuseaction=prod.emptypopup_add_ezgi_metarial_ambar_fisi&control_method=#get_default.CONTROL_METHOD#&order_id=#get_orders_info.order_id#</cfoutput>&p_order_id_list='+p_order_id_list+'&lot_no='+lot_no+'&dept_out='+dept_out+'&dept_in='+dept_in+'&loc_out='+loc_out+'&loc_in='+loc_in
				document.getElementById("kumaskontrol").submit();
			}
		}
</script>
                    	