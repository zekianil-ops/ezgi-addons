<!---
    File: list_ezgi_iflow_production_order_result.cfm
    Folder: Add_Ons\ezgi\e_production\display
    Author: Ezgi Yazılım
    Date: 01/04/2026
    Description:
--->

<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.is_submitted" default="1">
<cfif isdefined("attributes.start_date") and isdate(attributes.start_date)>
	<cf_date tarih="attributes.start_date">
<cfelse>
	<cfset attributes.start_date = ''>
</cfif>
<cfif isdefined("attributes.finish_date") and isdate(attributes.finish_date)>
	<cf_date tarih="attributes.finish_date">
<cfelse>
	<cfset attributes.finish_date = ''>
</cfif>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
    <cfquery name="get_station" datasource="#dsn3#">
        SELECT        
            W.STATION_ID, 
            W.STATION_NAME
        FROM            
            WORKSTATIONS W WITH (NOLOCK)
        WHERE        
            W.UP_STATION IS NULL
        ORDER BY 
            W.STATION_NAME
    </cfquery>
    <cfoutput query="get_station">
        <cfset 'STATION_NAME_#STATION_ID#' = STATION_NAME>
    </cfoutput>
<cfif isdefined("attributes.is_submitted")>
	<cfquery name="get_general_info" datasource="#dsn#">
        SELECT ISNULL(IS_SERIAL_CONTROL_LOCATION,0) AS IS_SERIAL_CONTROL_LOCATION FROM OUR_COMPANY_INFO WHERE COMP_ID = #session.ep.company_id#
    </cfquery>
	<cfquery name="get_production_orders_result" datasource="#dsn3#">
    	SELECT 
        	PR.PRODUCTION_DEP_ID,
            PR.PRODUCTION_LOC_ID,
        	PR.PR_ORDER_ID, 
            PR.STATION_ID, 
            PR.RESULT_NO, 
            PR.IS_STOCK_FIS, 
            PR.RECORD_EMP, 
            PR.RECORD_DATE, 
            PRR.AMOUNT, 
            PRR.SPEC_MAIN_ID, 
            ISNULL(TBL.PRODUCT_STOCK,0) AS PRODUCT_STOCK, 
            ISNULL(S.IS_SERIAL_NO,0) AS IS_SERIAL_NO
		FROM     
        	PRODUCTION_ORDER_RESULTS AS PR INNER JOIN
            PRODUCTION_ORDER_RESULTS_ROW AS PRR ON PR.PR_ORDER_ID = PRR.PR_ORDER_ID INNER JOIN
            STOCKS AS S ON PRR.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
            (
            	SELECT 
                	PRODUCT_STOCK, 
                    STOCK_ID, 
                    SPECT_VAR_ID, 
                    STORE, 
                    STORE_LOCATION
             	FROM      
                	#dsn2_alias#.GET_STOCK_LOCATION_SPECT_TOTAL
           		WHERE   
                	NOT (SPECT_VAR_ID IS NULL) AND 
                    PRODUCT_STOCK > 0
          	) AS TBL ON PR.PRODUCTION_LOC_ID = TBL.STORE_LOCATION AND PR.PRODUCTION_DEP_ID = TBL.STORE AND PRR.STOCK_ID = TBL.STOCK_ID AND PRR.SPEC_MAIN_ID = TBL.SPECT_VAR_ID
		WHERE  
        	PR.P_ORDER_ID = #attributes.p_order_id# AND 
            PRR.TYPE = 1
            <cfif len(attributes.keyword)>
            	AND PR.RESULT_NO LIKE '%#attributes.keyword#%'
            </cfif>
            <cfif len(attributes.start_date)>
            	AND PR.RECORD_DATE >= #attributes.start_date#
            </cfif>
            <cfif len(attributes.finish_date)>
            	AND PR.RECORD_DATE < #DateAdd('d',1,attributes.finish_date)#
            </cfif>
	</cfquery>
	<cfset arama_yapilmali = 0>    
<cfelse>
	<cfset get_production_orders_result.recordcount = 0>
    <cfset arama_yapilmali = 1>
</cfif>
<cfparam name="attributes.totalrecords" default='#get_production_orders_result.recordcount#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search" method="post" action="#request.self#?fuseaction=#url.fuseaction#">
			<input name="is_submitted" id="is_submitted" type="hidden" value="1">
            <cfinput type="hidden" name="p_order_id" id="p_order_id" value="#attributes.p_order_id#"> 
            <cf_box_search>
                <div class="form-group">
                    <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                	 <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group" id="form_ul_date">
                	<div class="col col-12">
                     	<div class="col col-6 pl-0">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='30122.Başlangıç Tarihini Kontrol Ediniz'></cfsavecontent>
                                <cfinput type="text" name="start_date" value="#dateformat(attributes.start_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                            </div>
                       	</div>
                        <div class="col col-6 pl-0">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='30123.Bitiş Tarihini Kontrol Ediniz'></cfsavecontent>
                                <cfinput type="text" name="finish_date" value="#dateformat(attributes.finish_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                            </div>
                       	</div>
                   	</div>
                </div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                </div>
          		<div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="1">
                </div>
          	</cf_box_search>
    	</cfform>
  	</cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='38092.Üretim Sonuçları'></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
      	<cf_grid_list>
        	<thead>
                <tr valign="middle">
                    <th style="width:25px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <!-- sil -->
                    <th style="width:25px; text-align:center; vertical-align:middle" ></th>
                    <!-- sil -->
                    <th style="width:65px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='40730.Sonuç Tarihi'></th>
                    <th style="width:65px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57880.Belge No'></th>
                    <th style="width:40px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57635.Miktar'></th>
                    <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57899.Kaydeden'></th>
                    <!-- sil -->
                    <th style="width:20px; text-align:center; vertical-align:middle" class="header_icn_none" >
                       	<input type="checkbox" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="gecim(-1);">
                    </th>
                    <!-- sil -->
                </tr>
            </thead>
            <tbody>
				<cfif get_production_orders_result.recordcount>
               		<cfset depo_stok = get_production_orders_result.PRODUCT_STOCK>	
                    <cfoutput query="get_production_orders_result" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                    	<cfset depo_stok = depo_stok - AMOUNT>
                        <cfset serial_no_ok = ''>
                        <cfif get_general_info.IS_SERIAL_CONTROL_LOCATION>
							<cfif IS_SERIAL_NO eq 1>
                              	<cfquery name="get_serial" datasource="#dsn3#">
                              		SELECT 	
                                    	SERIAL_NO
									FROM     
                                    	SERVICE_GUARANTY_NEW
									WHERE  
                                    	PROCESS_ID = #PR_ORDER_ID# AND 
                                        PROCESS_CAT = 171 AND 
                                        NOT (SERIAL_NO IS NULL)
                          		</cfquery>  
                                <cfif get_serial.recordcount>
                                	<cfloop query="get_serial">
                                        <cfquery name="get_serial_ok" datasource="#dsn3#">
                                            SELECT 
                                                SERIAL_NO
                                            FROM     
                                                EZGI_WM_SERIAL_NO_LAST_STATUS
                                            WHERE  
                                                SERIAL_NO = '#get_serial.SERIAL_NO#' AND 
                                                DEPARTMENT_ID = #get_production_orders_result.PRODUCTION_DEP_ID# AND 
                                                LOCATION_ID = #get_production_orders_result.PRODUCTION_LOC_ID#
                                        </cfquery>
                                        <cfif not get_serial_ok.recordcount>
                                        	<cfset serial_no_ok = ListAppend(serial_no_ok,get_serial.SERIAL_NO)>
                                        </cfif>
                                 	</cfloop>
                                </cfif>
                            </cfif>
                       	</cfif>
                        <!---<cfdump var="#get_serial#">
                        <cfdump var="#get_serial_ok#">
                        <cfdump var="#serial_no_ok#">--->
                        <tr>
                            <td style="text-align:right;">#currentrow#</td>
                            <!-- sil -->
                            <td style="text-align:center;">
                            	<cfif depo_stok lt 0 or ListLen(serial_no_ok)>
                                    <cfif depo_stok lt 0>
                                		<img src="images/delete_list_beyaz.gif" title="Yetersiz Stok" border="0">
                                  	<cfelseif ListLen(serial_no_ok)>
                                    	<img src="images/delete_list_beyaz.gif" title="#serial_no_ok# Sorunlu Seri Nolar" border="0">
                                    </cfif>
                                <cfelse>
                                	<a style="cursor:pointer" onclick="del_product_result(#PR_ORDER_ID#);"><img src="images/delete_list.gif"  title="Sil" border="0"></a>
                                </cfif>
                            </td>
                            <!-- sil -->
                            <td style="text-align:center;" nowrap>#DateFormat(RECORD_DATE, dateformat_style)#</td>
                            <td style="text-align:center;">#RESULT_NO#</td>
                            <td style="text-align:right;">#AmountFormat(AMOUNT)#</td>
                            <td style="text-align:left;">#get_emp_info(RECORD_EMP,0,0)#</td>
                            <!-- sil -->
                        	<td style="text-align:center;">
                            	<cfif depo_stok lt 0 or ListLen(serial_no_ok)>
                                
                                <cfelse>
                        			<input type="checkbox" name="select_sub_plan" value="#PR_ORDER_ID#">
                                </cfif>
                        	</td> 
                            <!-- sil -->
                        </tr>
                    </cfoutput>
                    <tfoot>
                        <tr>
                            <td colspan="7" style="height:35px; text-align:right">
                           		<button type="button" name="delete_button" id="delete_button" onclick="gecim(-2);" style="width:200px; height:30px; text-align:center; font-weight:bold; background-color:red; color:white">
                                <cf_get_lang dictionary_id='57463.Sil'>
                     			</button>
                            </td>
                        </tr>
                    </tfoot>
              	<cfelse>
                    <tr> 
                        <td colspan="6" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
                    </tr>
                </cfif>
            </tbody>
       	</cf_grid_list>
        <cfset adres = url.fuseaction>
        <cfif len(attributes.keyword)>
          <cfset adres = '#adres#&keyword=#URLEncodedFormat(attributes.keyword)#'>
        </cfif>
         <cfif len(attributes.start_date)>
          <cfset adres = '#adres#&start_date=#attributes.start_date#'>
        </cfif>
         <cfif len(attributes.finish_date)>
          <cfset adres = '#adres#&finish_date=#attributes.finish_date#'>
        </cfif>
        <cf_paging 
            page="#attributes.page#"
            maxrows="#attributes.maxrows#"
            totalrecords="#attributes.totalrecords#"
            startrow="#attributes.startrow#"
            adres="#adres#&is_submitted=1">
  	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;	
	}
	function gecim(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
		pr_order_id_list = '';
		chck_leng = document.getElementsByName('select_sub_plan').length;
		for(ci=0;ci<chck_leng;ci++)
		{
			var my_objets = document.all.select_sub_plan[ci];
			if(chck_leng == 1)
				var my_objets =document.all.select_sub_plan;
			if(type == -1){//hepsini seç denilmişse	
				if(my_objets.checked == true)
					my_objets.checked = false;
				else
					my_objets.checked = true;
			}
			else
			{
				if(my_objets.checked == true)
					pr_order_id_list +=my_objets.value+',';
			}
		}
		pr_order_id_list = pr_order_id_list.substr(0,pr_order_id_list.length-1);//sondaki virgülden kurtarıyoruz.
		if(list_len(pr_order_id_list,','))
		{
			if(type == -2)
				window.location='<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_iflow_production_order_result&p_order_id=#attributes.p_order_id#</cfoutput>&pr_order_id_list='+pr_order_id_list;
			else
				return false;
		}
	}
	function del_product_result(pr_order_id_list)
	{
		window.location='<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_iflow_production_order_result&p_order_id=#attributes.p_order_id#</cfoutput>&pr_order_id_list='+pr_order_id_list;
	}
</script>