<cfquery name="GET_PERIOD_DIS_SHIP" datasource="#DSN#">
	SELECT 
    	PERIOD_YEAR, 
        OUR_COMPANY_ID, 
        PERIOD_ID 
  	FROM 
    	SETUP_PERIOD 
   	WHERE 
    	OUR_COMPANY_ID = #session.ep.company_id# AND 
        PERIOD_YEAR >2013 
  	ORDER BY 
    	PERIOD_YEAR
</cfquery>
<cfquery name="get_basket" datasource="#dsn3#">
	SELECT AMOUNT_ROUND FROM SETUP_BASKET WHERE B_TYPE = 1 AND BASKET_ID = 4 ORDER BY BASKET_ID
</cfquery>
<cfset amount_round = get_basket.amount_round>
<cfquery name="get_orders_ship" datasource="#dsn3#">
	SELECT
		PERIOD_ID AS SHIP_PERIOD_ID
	FROM
		EZGI_ORDERS_SHIP_INTERNAL
	WHERE
		ORDER_ID = #attributes.order_id#
</cfquery>
<cfset ship_list="">
<cfset period_list_ship = "">
<cfif get_orders_ship.recordcount>
	<cfif isdefined('attributes.order_id') and len(attributes.order_id)>
		<cfset period_list_ship = listsort(valuelist(get_orders_ship.SHIP_PERIOD_ID),"numeric","asc",",")>
        <cfquery name="get_period_ship_dsns" datasource="#dsn3#">
            SELECT PERIOD_YEAR,OUR_COMPANY_ID,PERIOD_ID FROM #dsn_alias#.SETUP_PERIOD WHERE PERIOD_ID IN (#period_list_ship#)
        </cfquery>
	</cfif>
</cfif>
<cfquery name="get_order_det" datasource="#DSN3#">
		SELECT
			ORR.STOCK_ID,
            ORR.QUANTITY,
            ORR.ORDER_ROW_ID,
            ORD.ORDER_ID,
            ORD.ORDER_HEAD, 
            ORD.ORDER_NUMBER,
            ORR.SPECT_VAR_ID,
            ORR.SPECT_VAR_NAME,
            ORR.ORDER_ROW_CURRENCY,
            S.PRODUCT_NAME,
            S.STOCK_CODE,
            S.STOCK_CODE_2
		FROM
			ORDER_ROW ORR,
			ORDERS ORD,
			STOCKS S
		WHERE
			ORD.ORDER_ID = ORR.ORDER_ID AND
			ORR.STOCK_ID = S.STOCK_ID AND 
            ORD.ORDER_ID = #attributes.order_id#
</cfquery>
<cfset order_row_id_list = Valuelist(get_order_det.ORDER_ROW_ID)>
<cfquery name="get_teshir" datasource="#dsn3#">
    	SELECT ORDER_ROW_ID FROM EZGI_ORDER_TESHIR WHERE ORDER_ROW_ID IN (#order_row_id_list#)
</cfquery>
<cfoutput query="get_teshir">
    	<cfset 'teshir_#ORDER_ROW_ID#'= ORDER_ROW_ID>
</cfoutput>
<cfif listlen(period_list_ship) and period_list_ship neq 0>
	<cfquery name="get_ship_det" datasource="#DSN3#">
     	SELECT
         	SHIP_YEAR,
          	SHIP_ID,
         	DELIVER_DATE,
         	STOCK_ID,
          	SPECT_VAR_ID,
        	IRS_AMOUNT,
       		SHIP_NUMBER,
          	WRK_ROW_RELATION_ID,
          	ROW_ORDER_ID
      	FROM	
          	(
                <cfloop query="get_period_DIS_SHIP">
                    SELECT     
                        #get_period_DIS_SHIP.PERIOD_YEAR# AS SHIP_YEAR, 
                        S.DISPATCH_SHIP_ID SHIP_ID,
                        S.DELIVER_DATE,
                        SR.STOCK_ID,
                        SR.SPECT_VAR_ID, 
                        AMOUNT AS IRS_AMOUNT,
                        '' AS SHIP_NUMBER,
                        ISNULL(WRK_ROW_RELATION_ID,0) AS WRK_ROW_RELATION_ID,
                        ROW_ORDER_ID
                    FROM          
                        #dsn#_#get_period_DIS_SHIP.PERIOD_YEAR#_#get_period_DIS_SHIP.OUR_COMPANY_ID#.SHIP_INTERNAL S,
                        #dsn#_#get_period_DIS_SHIP.PERIOD_YEAR#_#get_period_DIS_SHIP.OUR_COMPANY_ID#.SHIP_INTERNAL_ROW SR
                    WHERE
                        SR.DISPATCH_SHIP_ID=S.DISPATCH_SHIP_ID AND
                        SR.ROW_ORDER_ID IN (#order_row_id_list#) 
                    <cfif currentrow neq get_period_DIS_SHIP.recordcount> UNION ALL </cfif>					
				</cfloop>
      		) AS TBL
	</cfquery>
	<cfquery name="get_ship_det_group" dbtype="query">
  		SELECT
        	SHIP_YEAR,
         	SHIP_ID,
         	DELIVER_DATE
     	FROM
        	get_ship_det
     	GROUP BY
         	SHIP_YEAR,
         	SHIP_ID,
         	DELIVER_DATE
     	ORDER BY
        	SHIP_YEAR 	     

	</cfquery>
	<cfset ship_list_2=listsort(valuelist(get_ship_det.SHIP_ID),"numeric","asc",",")>
	<cfset ship_list=listsort(ListDeleteDuplicates(valuelist(get_ship_det.SHIP_ID)),"numeric","asc",",")>
</cfif>
<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id='754.Sipariş Talep Formu'><cfif get_orders_ship.recordcount>: <cfoutput>#get_order_det.ORDER_NUMBER# - #get_order_det.ORDER_HEAD#</cfoutput></cfif></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#ezgi_header#" right_images="">
    	<cf_basket id="upd_default_measure_bask">
        	<cfform name="ship_internal" action="#request.self#?fuseaction=prod.add_ezgi_metarial_control" method="post">
             	<input type="hidden" name="order_id" id="order_id" value="<cfoutput>#attributes.order_id#</cfoutput>">
                <cf_grid_list sort="0">
                    <thead>
                        <tr height="20px">
                        	<th><cf_get_lang dictionary_id='57657.Ürün'></th>
							<th><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
							<th><cf_get_lang dictionary_id='57789.Özel Kod'></th>
							<th><cf_get_lang dictionary_id='57647.Spec'></th>
							<th width="50" style="text-align:right;"><cf_get_lang dictionary_id='57611.Sipariş'></th>
                            
							<cfoutput>
							<cfif get_orders_ship.recordcount>
                            	<cfif len(ship_list)>
                                    <cfloop query="get_ship_det_group">
                                        <th width="70"style="text-align:right;">
                                            <cf_get_lang dictionary_id='45959.Sevk Talebi'><br/>
                                            	<cfif get_ship_det_group.ship_year eq session.ep.period_year>
                                                	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=stock.add_dispatch_internaldemand&event=upd&ship_id=#get_ship_det_group.ship_id#</cfoutput>','longpage');" style="color:##FF0000">
                                                	(#dateformat(get_ship_det_group.DELIVER_DATE,'dd/mm/yyyy')#)
                                                	</a>
                                                <cfelse>
                                                	(#dateformat(get_ship_det_group.DELIVER_DATE,'dd/mm/yyyy')#)
                                                </cfif>
                                        </th>
                                    </cfloop>
								</cfif>
                            
							</cfif>
							</cfoutput>
                            </th>
                            <th width="20" style="text-align:center;"> </th>
							<th width="50" style="text-align:right;"><cf_get_lang dictionary_id='58444.Kalan'></th>
                            <th width="10" style="text-align:center;">&nbsp;<input type="checkbox" style="text-align:center;" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="grupla(-1);"></th>
						</tr>
					</thead>
					<tbody>
                    	<cfif get_order_det.recordcount>
                        	<cfinput type="hidden" name="order_id" value="#attributes.order_id#">
                            <cfoutput query="get_order_det">
                                <cfset irs_top=0>
                                <cfset stock_id=get_order_det.STOCK_ID>
                                <tr height="30">
                                    <td>#get_order_det.PRODUCT_NAME#</td>
                                    <td>#get_order_det.STOCK_CODE#</td>
                                    <td>#get_order_det.STOCK_CODE_2#</td>
                                    <td><cfif len(get_order_det.SPECT_VAR_ID)>#get_order_det.SPECT_VAR_NAME#-#get_order_det.SPECT_VAR_ID#</cfif></td>
                                    <td style="text-align:right;">#AmountFormat(get_order_det.QUANTITY)#</td>
                                        <cfif len(ship_list)>
                                            <cfloop list="#ship_list#" index="z">
                                                <cfquery name="get_amount_shp" dbtype="query">
                                                    SELECT IRS_AMOUNT,SHIP_ID FROM get_ship_det WHERE SHIP_ID=#z# AND STOCK_ID=#stock_id# AND ROW_ORDER_ID = #ORDER_ROW_ID# 
                                                </cfquery>

                                                <td style="text-align:right;">
                                                    <cfif get_amount_shp.recordcount neq 0 and len(get_amount_shp.IRS_AMOUNT)>
                                                        #AmountFormat(get_amount_shp.IRS_AMOUNT)#
                                                        <cfset irs_top=irs_top+get_amount_shp.IRS_AMOUNT>
                                                    <cfelse>
                                                        -
                                                    </cfif>
                                                </td>
                                            </cfloop>
                                        </cfif>
                                  	<td style="text-align:center;">
                                    	<cfif isdefined('teshir_#ORDER_ROW_ID#')>
                                    		<a href="javascript://" onClick="sil(#ORDER_ROW_ID#,#ORDER_ID#);"><img src="/images/delete_list.gif" align="absmiddle" border="0"></a>
                                      	<cfelse>
                                        	<cfif irs_top eq 0>
                                        		<a href="javascript://" onClick="ekle(#ORDER_ROW_ID#,#ORDER_ID#);"><img src="/images/plus_list.gif" align="absmiddle" border="0"></a>
                                            </cfif>
                                        </cfif>
                                    </td>
                                    <td style="text-align:right;">#AmountFormat(get_order_det.QUANTITY-irs_top)#</td>
                                    <td style="text-align:center;">
                                    	<cfif ORDER_ROW_CURRENCY eq -3 or ORDER_ROW_CURRENCY eq -9 or ORDER_ROW_CURRENCY eq -8 or ORDER_ROW_CURRENCY eq -10><!--- Satır Sevk Yapılmışsa  VE (İptal, Kapatalıdı, Manuel Kapatıldı, Fazla Teslimat)--->
                                         	<img src="/images/d_ok.gif" border="0" title="
												<cfif order_row_currency eq -8><cf_get_lang_main no ='1952.Fazla Teslimat'>
												<cfelseif order_row_currency eq -7><cf_get_lang_main no ='1951.Eksik Teslimat'>
                                                <cfelseif order_row_currency eq -6><cf_get_lang_main no='1349.Sevk'>
                                                <cfelseif order_row_currency eq -5><cf_get_lang_main no ='44.Üretim'>
                                                <cfelseif order_row_currency eq -4><cf_get_lang_main no ='1950.Kismi Üretim'>
                                                <cfelseif order_row_currency eq -3><cf_get_lang_main no ='1949.Kapatildi'>
                                                <cfelseif order_row_currency eq -2><cf_get_lang_main no ='1948.Tedarik'>
                                                <cfelseif order_row_currency eq -1><cf_get_lang_main no='1305.Açık'>
                                                <cfelseif order_row_currency eq -9><cf_get_lang_main no ='1094.İptal'>
                                                <cfelseif order_row_currency eq -10>Kapatıldı(Manuel)</cfif>
                                        		">
                                       	<cfelse>
											<cfif get_order_det.QUANTITY-irs_top gt 0 and not isdefined('teshir_#ORDER_ROW_ID#')>
                                                <input type="checkbox" name="select_production" value="#ORDER_ROW_ID#">
                                            <cfelse>
                                                &nbsp;
                                            </cfif>
                                      	</cfif>	
                                   	</td>
                                </tr>
                            </cfoutput>
                      	</cfif>
					</tbody>
                    
               	</cf_grid_list>
         	</cfform>
            <table>
             	<tr class="color-list" height="35">
                  	<td colspan="20" style="text-align:right">
                    	<button  value="" name="sevk" onClick="grupla();" style="width:160px; height:25px;"><cf_get_lang dictionary_id='755.Sevk Talebi Oluştur'></button>
                    </td>
               	</tr>
            </table>
       	</cf_basket>
  	</cf_box>
</div>
<script language="javascript">
	function ekle(order_row_id,order_id)
	{	
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_add_ezgi_teshir&order_row_id='+order_row_id+'&order_id='+order_id;	
	}
	function sil(order_row_id,order_id)
	{	
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_del_ezgi_teshir&order_row_id='+order_row_id+'&order_id='+order_id;
	}
	function grupla(type)
		{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
			order_row_id_list = '';
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
						order_row_id_list +=my_objets.value+',';
				}
			}
			order_id = document.getElementById('order_id').value;
			order_row_id_list = order_row_id_list.substr(0,order_row_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(order_row_id_list!='')
			{
			window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=sales.add_ezgi_ship_internal&order_row_id_list='+order_row_id_list+'&order_id='+order_id);
			window.location.reload()
			}
		}
</script>
