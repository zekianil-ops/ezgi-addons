<!---
    File: display_ezgi_personel_moduler.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.department_id" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.durum" default="1">
<cfparam name="attributes.is_form_submitted" default="">
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfquery name="get_department" datasource="#dsn#">
	SELECT     
    	DP.DEPARTMENT_ID, 
        DP.DEPARTMENT_HEAD
	FROM         
    	DEPARTMENT AS DP WITH (NOLOCK) INNER JOIN
        #dsn3_alias#.WORKSTATIONS AS D WITH (NOLOCK) ON DP.DEPARTMENT_ID = D.DEPARTMENT
	WHERE     
    	DP.DEPARTMENT_STATUS = 1 AND 
        DP.IS_PRODUCTION = 1
	GROUP BY 
    	DP.DEPARTMENT_ID, 
        DP.DEPARTMENT_HEAD
</cfquery>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfif len(attributes.is_form_submitted)>
	<cfif len(attributes.durum) and attributes.durum eq 1>
    	<cfquery name="get_employees" datasource="#dsn#">
        	SELECT     
            	E.EMPLOYEE_NO, 
            	EP.POSITION_ID, 
                EP.EMPLOYEE_ID, 
                EP.EMPLOYEE_NAME, 
                EP.EMPLOYEE_SURNAME, 
                ESE.START_DATE, 
                ESE.FINISH_DATE, 
            	W.STATION_NAME, 
                W.STATION_ID, 
                TBL.PROD_PAUSE_TYPE_ID, 
                DATEADD(hh,#session.ep.time_zone#,TBL.ACTION_DATE) ACTION_DATE,
                SP.PROD_PAUSE_TYPE,
                ISNULL((SELECT TOP (1) OPERATION_RESULT_ID FROM #dsn3_alias#.PRODUCTION_OPERATION_RESULT WITH (NOLOCK) WHERE ACTION_EMPLOYEE_ID = EP.EMPLOYEE_ID AND REAL_AMOUNT = 0 AND LOSS_AMOUNT = 0),0) AS AKTIF
			FROM         
            	(
                	SELECT     
                    	STATION_ID, 
                        PROD_PAUSE_TYPE_ID,
                        ACTION_DATE
                	FROM          
                    	#dsn3_alias#.SETUP_PROD_PAUSE WITH (NOLOCK)
                  	WHERE      
                    	PROD_DURATION IS NULL
               	) AS TBL INNER JOIN
         		#dsn3_alias#.SETUP_PROD_PAUSE_TYPE AS SP WITH (NOLOCK) ON TBL.PROD_PAUSE_TYPE_ID = SP.PROD_PAUSE_TYPE_ID RIGHT OUTER JOIN
            	#dsn3_alias#.EZGI_STATION_EMPLOYEE AS ESE WITH (NOLOCK) ON TBL.STATION_ID = ESE.STATION_ID LEFT OUTER JOIN
              	#dsn3_alias#.WORKSTATIONS AS W WITH (NOLOCK) ON ESE.STATION_ID = W.STATION_ID RIGHT OUTER JOIN
               	EMPLOYEE_POSITIONS AS EP WITH (NOLOCK) INNER JOIN
              	EMPLOYEES AS E WITH (NOLOCK) ON EP.EMPLOYEE_ID = E.EMPLOYEE_ID ON ESE.EMPLOYEE_ID = E.EMPLOYEE_ID
			WHERE     
            	<cfif len(attributes.department_id)>
                     W.DEPARTMENT = #attributes.department_id# AND
                </cfif> 
                EP.POSITION_STATUS = 1 AND 
                E.EMPLOYEE_STATUS = 1 AND 
                ESE.FINISH_DATE IS NULL AND 
                W.STATION_ID IS NOT NULL
			ORDER BY 
            	W.STATION_NAME, 
                AKTIF DESC,
                EP.EMPLOYEE_NAME, 
                EP.EMPLOYEE_SURNAME
        </cfquery>
    <cfelse>
        <cfquery name="get_employees1" datasource="#dsn#">
            SELECT DISTINCT
                E.EMPLOYEE_NO,   
                EP.POSITION_ID, 
                EP.EMPLOYEE_ID, 
                EP.EMPLOYEE_NAME, 
                EP.EMPLOYEE_SURNAME, 
                ESE.START_DATE, 
                ESE.FINISH_DATE, 
                W.STATION_NAME, 
                EOS.P_ORDER_ID, 
                EOS.LOT_NO, 
                EOS.P_ORDER_NO, 
                EOS.IS_STAGE, 
                EOS.STOCK_ID, 
                EOS.PRODUCT_NAME, 
                EOS.QUANTITY, 
                EOS.OPERATION_TYPE_ID, 
                EOS.OPERATION_CODE, 
                EOS.OPERATION_TYPE, 
                EOS.AMOUNT, 
                EOS.STAGE, 
                EOS.ACTION_START_DATE, 
                EOS.REAL_AMOUNT, 
                EOS.LOSS_AMOUNT, 
                EOS.O_START_DATE,
                EOS.O_FINISH_DATE, 
                EOS.STATION_ID, 
                EOS.O_TOTAL_PROCESS_TIME, 
                EOS.STATION_NAME AS O_STATION_NAME
            FROM         
                #dsn3_alias#.EZGI_OPERATION_M AS EOS WITH (NOLOCK) RIGHT OUTER JOIN
                #dsn3_alias#.EZGI_STATION_EMPLOYEE AS ESE WITH (NOLOCK) ON EOS.ACTION_EMPLOYEE_ID = ESE.EMPLOYEE_ID LEFT OUTER JOIN
                #dsn3_alias#.WORKSTATIONS AS W WITH (NOLOCK) ON ESE.STATION_ID = W.STATION_ID RIGHT OUTER JOIN
                EMPLOYEE_POSITIONS AS EP WITH (NOLOCK) INNER JOIN
                EMPLOYEES AS E WITH (NOLOCK) ON EP.EMPLOYEE_ID = E.EMPLOYEE_ID ON ESE.EMPLOYEE_ID = E.EMPLOYEE_ID
            WHERE 
                <cfif len(attributes.department_id)>
                    W.DEPARTMENT = #attributes.department_id# AND
                </cfif>                       
                EP.POSITION_STATUS = 1 AND 
                ISNULL(EOS.STAGE,1) <> 3 AND
                E.EMPLOYEE_STATUS = 1 AND
                ESE.FINISH_DATE IS NULL 
         	UNION ALL
            SELECT DISTINCT
                E.EMPLOYEE_NO,   
                EP.POSITION_ID, 
                EP.EMPLOYEE_ID, 
                EP.EMPLOYEE_NAME, 
                EP.EMPLOYEE_SURNAME, 
                ESE.START_DATE, 
                ESE.FINISH_DATE, 
                W.STATION_NAME, 
                EOS.P_ORDER_ID, 
                EOS.LOT_NO, 
                EOS.P_ORDER_NO, 
                EOS.IS_STAGE, 
                EOS.STOCK_ID, 
                EOS.PRODUCT_NAME, 
                EOS.QUANTITY, 
                EOS.OPERATION_TYPE_ID, 
                EOS.OPERATION_CODE, 
                EOS.OPERATION_TYPE, 
                EOS.AMOUNT, 
                EOS.STAGE, 
                EOS.ACTION_START_DATE, 
                EOS.REAL_AMOUNT, 
                EOS.LOSS_AMOUNT, 
                EOS.O_START_DATE,
                EOS.O_FINISH_DATE, 
                EOS.STATION_ID, 
                EOS.O_TOTAL_PROCESS_TIME, 
                EOS.STATION_NAME AS O_STATION_NAME
            FROM         
                #dsn3_alias#.EZGI_OPERATION_S AS EOS WITH (NOLOCK) RIGHT OUTER JOIN
                #dsn3_alias#.EZGI_STATION_EMPLOYEE AS ESE WITH (NOLOCK) ON EOS.ACTION_EMPLOYEE_ID = ESE.EMPLOYEE_ID LEFT OUTER JOIN
                #dsn3_alias#.WORKSTATIONS AS W WITH (NOLOCK) ON ESE.STATION_ID = W.STATION_ID RIGHT OUTER JOIN
                EMPLOYEE_POSITIONS AS EP WITH (NOLOCK) INNER JOIN
                EMPLOYEES AS E WITH (NOLOCK) ON EP.EMPLOYEE_ID = E.EMPLOYEE_ID ON ESE.EMPLOYEE_ID = E.EMPLOYEE_ID
            WHERE 
                <cfif len(attributes.department_id)>
                    W.DEPARTMENT = #attributes.department_id# AND
                </cfif>                       
                EP.POSITION_STATUS = 1 AND 
                ISNULL(EOS.STAGE,1) <> 3 AND
                E.EMPLOYEE_STATUS = 1 AND
                ESE.FINISH_DATE IS NULL
            ORDER BY 
                W.STATION_NAME,
                EP.EMPLOYEE_NAME, 
                EP.EMPLOYEE_SURNAME,
                EOS.ACTION_START_DATE
        </cfquery>
        <cfif get_employees1.recordcount>
        	<cfquery name="get_employee_bos" dbtype="query">
            	SELECT STATION_ID FROM get_employees1 WHERE STATION_ID > 0 GROUP BY STATION_ID 
            </cfquery>
        	<cfset station_id_list = ValueList(get_employee_bos.station_id)>
        	<cfquery name="get_employee_co" datasource="#dsn#">
                SELECT      
                    E.EMPLOYEE_NO, 
                    EP.POSITION_ID, 
                    EP.EMPLOYEE_ID, 
                    EP.EMPLOYEE_NAME, 
                    EP.EMPLOYEE_SURNAME, 
                    ESE.START_DATE, 
                    ESE.FINISH_DATE, 
                    W.STATION_NAME, 
                    W.STATION_ID 
                FROM         
                    #dsn3_alias#.EZGI_STATION_EMPLOYEE AS ESE WITH (NOLOCK) LEFT OUTER JOIN
                    #dsn3_alias#.WORKSTATIONS AS W WITH (NOLOCK) ON ESE.STATION_ID = W.STATION_ID RIGHT OUTER JOIN
                    EMPLOYEE_POSITIONS AS EP WITH (NOLOCK) INNER JOIN
                    EMPLOYEES AS E WITH (NOLOCK) ON EP.EMPLOYEE_ID = E.EMPLOYEE_ID ON ESE.EMPLOYEE_ID = E.EMPLOYEE_ID
                WHERE     
                    ISNULL((SELECT TOP (1) OPERATION_RESULT_ID FROM #dsn3_alias#.PRODUCTION_OPERATION_RESULT WHERE ACTION_EMPLOYEE_ID = EP.EMPLOYEE_ID AND REAL_AMOUNT = 0 AND LOSS_AMOUNT = 0),0) = 0 AND
                    <cfif ListLen(station_id_list)>
                    	ESE.STATION_ID IN (#station_id_list#) AND 
                    </cfif>
                    EP.POSITION_STATUS = 1 AND 
                    E.EMPLOYEE_STATUS = 1 AND 
                    ESE.FINISH_DATE IS NULL AND 
                    W.STATION_ID IS NOT NULL
                ORDER BY 
                    W.STATION_NAME, 
                    EP.EMPLOYEE_NAME, 
                    EP.EMPLOYEE_SURNAME
            </cfquery>
            <cfquery name="get_employees" dbtype="query">
                SELECT DISTINCT
                	1 AS AKTIF,
                    EMPLOYEE_NO,   
                    POSITION_ID, 
                    EMPLOYEE_ID, 
                    EMPLOYEE_NAME,
                    STATION_ID, 
                    EMPLOYEE_SURNAME
                    <cfif len(attributes.durum) and attributes.durum neq 0>
                        , 
                        START_DATE, 
                        FINISH_DATE, 
                        STATION_NAME
                        <cfif len(attributes.durum) and attributes.durum eq 2>        
                            , 
                            P_ORDER_ID, 
                            LOT_NO, 
                            PRODUCT_NAME, 
                            OPERATION_TYPE, 
                            O_STATION_NAME, 
                            ACTION_START_DATE,
                            AMOUNT,
                            P_ORDER_NO
                        </cfif>      
                    </cfif>
                FROM  
                    get_employees1
                WHERE
                    1=1
                    <cfif len(attributes.durum) and (attributes.durum eq 1 or attributes.durum eq 2)>
                         AND START_DATE IS NOT NULL AND FINISH_DATE IS NULL
                    </cfif>
                    <cfif len(attributes.durum) and attributes.durum eq 2>
                        AND (REAL_AMOUNT = 0) AND (LOSS_AMOUNT = 0)
                    </cfif>
                <cfif len(attributes.durum) and attributes.durum eq 0>
                    GROUP BY
                        EMPLOYEE_NO,   
                        POSITION_ID, 
                        EMPLOYEE_ID, 
                        EMPLOYEE_NAME,
                        STATION_ID, 
                        EMPLOYEE_SURNAME,
                        P_ORDER_NO
                </cfif> 
                <cfif get_employee_co.recordcount> 
                	UNION ALL
                    SELECT
                    	0 AS AKTIF,
                    	EMPLOYEE_NO,   
                        POSITION_ID, 
                        EMPLOYEE_ID, 
                        EMPLOYEE_NAME,
                        STATION_ID, 
                        EMPLOYEE_SURNAME
                        <cfif len(attributes.durum) and attributes.durum neq 0>
                            , 
                            START_DATE, 
                            FINISH_DATE, 
                            STATION_NAME
                            <cfif len(attributes.durum) and attributes.durum eq 2>        
                               , 
                                0 AS P_ORDER_ID, 
                                '' AS LOT_NO, 
                                '' AS PRODUCT_NAME, 
                                '' AS OPERATION_TYPE, 
                                '' AS O_STATION_NAME, 
                                START_DATE as ACTION_START_DATE,
                                0 AS AMOUNT,
                                '' AS P_ORDER_NO
                            </cfif>      

                        </cfif>
                    FROM
                    	get_employee_co  
              		ORDER BY 
                    	STATION_NAME,
                        AKTIF desc
              	</cfif> 
            </cfquery>
            
        <cfelse>
        	<cfset get_employees.recordcount = 0>
        </cfif>
        <cfset arama_yapilmali=0>
   	</cfif>
<cfelse>
	<cfset arama_yapilmali=1>
    <cfset get_employees.recordcount = 1>
</cfif>
<!---<cfdump var="#get_employees#">--->
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
        <cfform name="search_product" method="post" action="#request.self#?fuseaction=prod.popup_display_ezgi_prod_menu_moduler">
            <cfinput name="master_plan_id" type="hidden" value="#attributes.master_plan_id#">
            <input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            <input name="type" type="hidden" value="4">
            <cf_box_search>
            	<div class="form-group" id="item-keyword">
                	<select name="department_id" id="department_id" style="width:110px;">
                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            <cfoutput query="get_department">
                                <option value="#department_id#" <cfif attributes.department_id eq department_id>selected</cfif>>#department_head#</option>
                            </cfoutput>
                	</select>
                </div>
            	<div class="form-group" id="item-durum">
                	<select name="durum" style=" width:150px">
                            <option value="1" <cfif attributes.durum eq '1'>selected</cfif>><cf_get_lang dictionary_id='413.İstasyona Giriş Yapanlar'></option>
                          	<option value="2" <cfif attributes.durum eq '2'>selected</cfif>><cf_get_lang dictionary_id='414.İstasyonda İş Yapanlar'></option>  
                        </select>
                </div>
                <div class="form-group">
                	<div class="input-group x-3_5">
                     	<cfsavecontent variable="message"><cf_get_lang_main no='125.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    	<cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
               		</div>
          		</div>
            	<div class="form-group">
                  	<div class="input-group">
                     	<cf_wrk_search_button search_function='input_control()' button_type="4">
                 	</div>
              	</div>
       		</cf_box_search>
      	</cfform>
  	</cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id="412.Personel Takip"></cfsavecontent>
 	<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1" right_images="">
        <cf_grid_list>
            <thead>
                <tr>
                    <th style="text-align:center; width:25px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th style="text-align:center;"><cf_get_lang dictionary_id='53769.Adı-Soyadı'></th>
                    <th style="text-align:center; width:100px"><cf_get_lang dictionary_id='58834.İstasyon'></th>
                    <th style="text-align:center; width:100px"><cf_get_lang dictionary_id='415.Giriş Zamanı'></th>
                    <th style="text-align:center; width:80px"><cf_get_lang dictionary_id='39461.Toplam Süre'></th>
                    <th style="text-align:center; width:80px"><cf_get_lang dictionary_id='29474.Emir No'></th>
                    <th style="text-align:center;"><cfif len(attributes.durum) and attributes.durum eq 1><cf_get_lang dictionary_id='300.Duraklama'><cfelse><cf_get_lang dictionary_id='46787.Üretilen Ürünler'></cfif></th>
                    <th style="text-align:center; width:80px"><cf_get_lang dictionary_id='29419.Operasyon'></th>
                    <th style="text-align:center; width:50px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                    <th style="text-align:center; width:80px"><cf_get_lang dictionary_id='416.Başlama Zamanı'></th>
                    <th style="text-align:center; width:80px"><cf_get_lang dictionary_id='39461.Toplam Süre'></th>

                </tr>
            </thead>
            <tbody>
                <cfif len(attributes.is_form_submitted) and get_employees.recordcount gt 0>
                	<cfset station = 0>
                    <cfoutput query="get_employees">
                    	<cfif get_employees.station_id neq station>
                        	<cfset yaz = 1>
                        	<cfset station = get_employees.station_id>
                     	<cfelse>
                       		<cfset yaz = 0>
                        </cfif>
                    	<cfquery name="get_employee_station" dbtype="query">
                        	SELECT STATION_ID FROM get_employees WHERE STATION_ID = #STATION_ID#  
                        </cfquery>
                        <cfif isdefined('START_DATE')>
                            <cfset start_date_ = DateAdd('h',#session.ep.time_zone#,START_DATE)>
                            <cfset start_time_ = DateDiff('n',START_DATE,now())>
                            <cfset totaltime = "#start_time_\60#:#numberformat(start_time_ % 60, "00")#:00">
                        </cfif>
                        <cfif isdefined('ACTION_START_DATE')>
                            <cfset action_start_date_ = DateAdd('h',#session.ep.time_zone#,ACTION_START_DATE)><!---DateAdd('h',#session.ep.time_zone#,ACTION_START_DATE)--->
                            <cfset action_start_time_ = DateDiff('n',ACTION_START_DATE,now())>
                            <cfset action_totaltime = "#action_start_time_\60#:#numberformat(action_start_time_ % 60, "00")#:00">
                        </cfif>
                        <cfif attributes.durum gt 0>
                            <cfquery name="get_employee_durum" datasource="#dsn3#">
                                SELECT  
                                    P_OPERATION_ID
                                FROM        
                                    EZGI_OPERATION_M
                                WHERE     
                                    ACTION_EMPLOYEE_ID = #employee_id# AND 
                                    <cfif len(STATION_ID)>
                                    STATION_ID = #STATION_ID# AND
                                    </cfif>
                                    STAGE = 1 AND
                                    LOSS_AMOUNT=0 AND
                                    REAL_AMOUNT=0 
                            </cfquery>
                        </cfif>
                        <tr>
                            <td style="text-align:left;" nowrap="nowrap">
                                <strong>#currentrow#</strong>
                                <cfif attributes.durum eq 2><!---İş Yapanlar--->
                                    <cfif get_employee_durum.recordcount>
                                        <img src="images/delete_list.gif" border="0" onclick="delete_control(#employee_id#,#STATION_ID#,#get_employee_durum.P_OPERATION_ID#)"/>
                                    </cfif>
                               	<cfelseif attributes.durum eq 1><!---Giriş Yapanlar--->
                                 	<cfif get_employees.aktif eq 0> <!---İş Yapmıyorsa--->
                                      	<img src="images/delete_list.gif" border="0" onclick="exit_control(#employee_id#,#STATION_ID#)"/>
                                 	</cfif>
                               	</cfif>
                            </td>
                            <td style="text-align:left;" nowrap="nowrap">
                                <strong>
                                    <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_display_ezgi_personel_report_moduler&employee_id=#employee_id#','longpage');" class="tableyazi" >
                                        #EMPLOYEE_NAME# #EMPLOYEE_SURNAME#
                                    </a>
                                </strong>
                            </td>
                            <cfif yaz eq 1>
                            	<td style="text-align:left;" rowspan="#get_employee_station.recordcount#" nowrap="nowrap"><strong><cfif isdefined('STATION_NAME')>#STATION_NAME#</cfif></strong></td>
                            </cfif>
                            <td style="text-align:center;" nowrap="nowrap"><strong><cfif isdefined('start_date_')>#DateFormat(start_date_,dateformat_style)# #TimeFormat(start_date_,'HH:MM')#</cfif></strong></td>
                            <td style="text-align:right;" nowrap="nowrap"><cfif isdefined('start_date_')><strong>#totaltime#</strong></cfif></td>
                            <td style="text-align:CENTER;"  nowrap="nowrap">
								<cfif isdefined('P_ORDER_NO')>
                            		<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.order&event=upd&upd=#P_ORDER_ID#','longpage');">
                            			#P_ORDER_NO#
                            		</a>
                            	</cfif>
                            </td>
                            <td style="text-align:left;"  nowrap="nowrap">
                                    <cfif len(attributes.durum) and attributes.durum eq 1>
                                        <font color="RED">
                                            #PROD_PAUSE_TYPE#
                                        </font>
                                    <cfelse>
                                        <cfif isdefined('PRODUCT_NAME')>
                                            #PRODUCT_NAME#
                                        </cfif>
                                    </cfif>
                                </td>
                          	<cfif yaz eq 1>
                                <td style="text-align:left;" rowspan="#get_employee_station.recordcount#" nowrap="nowrap">
                                    <cfif isdefined('OPERATION_TYPE')>
                                        <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.form_upd_prod_order&upd=#p_order_id#','longpage');" class="tableyazi" >
                                            #OPERATION_TYPE#
                                        </a>
                                    </cfif>
                                </td>
                          	</cfif>
                         	<td style="text-align:right;"  nowrap="nowrap"><cfif isdefined('AMOUNT')>#AmountFormat(AMOUNT)#</cfif></td>
                          	<cfif yaz eq 1>
                                <td style="text-align:CENTER;" rowspan="#get_employee_station.recordcount#" nowrap="nowrap">
                                    <cfif len(attributes.durum) and attributes.durum eq 1>
                                        <font color="RED">
                                            #TimeFormat(action_date,'HH:MM')#
                                        </font>
                                    <cfelse>
        
                                        <cfif isdefined('action_start_time_')>#DateFormat(action_start_date_,dateformat_style)# #TimeFormat(action_start_date_,'HH:MM')#</cfif>
                                    </cfif>
                                </td>
                                
                            	<td style="text-align:right;" rowspan="#get_employee_station.recordcount#" nowrap="nowrap"><cfif isdefined('action_totaltime')><strong>#action_totaltime#</strong></cfif></td>
                        	</cfif>
                           	
                        </tr>
                    </cfoutput>      
                    <tfoot>
                        <tr>
                            <td height="20" colspan="10" style="text-align:right"></td>
                        </tr>
                    </tfoot>
                </cfif>
            </tbody>
        </cf_grid_list>
  	</cf_box>
</div>
<script language="javascript">
	<!---document.getElementById('keyword').focus();--->
	function input_control()
	{
		return true;
	}
	function delete_control(employee_id,station_id,operation_id)
	{
	sor = confirm('<cf_get_lang dictionary_id='417.Üretim İçin Sonuç Girmeden Çıkmak İstediğinizden Emin misiniz?'>');
	if(sor==true)
		window.location='<cfoutput>#request.self#?fuseaction=production.upd_ezgi_station_employee_exit&production=1&master_plan_id=#attributes.master_plan_id#&department_id=#attributes.department_id#&durum=#attributes.durum#</cfoutput>&station_id='+station_id+'&employee_id='+employee_id+'&p_operation_id='+operation_id;
	}
	function exit_control(employee_id,station_id)
	{
		window.location='<cfoutput>#request.self#?fuseaction=production.upd_ezgi_station_employee_exit&production=1&master_plan_id=#attributes.master_plan_id#&department_id=#attributes.department_id#&durum=#attributes.durum#</cfoutput>&employee_id='+employee_id+'&station_id='+station_id;
	}
</script>