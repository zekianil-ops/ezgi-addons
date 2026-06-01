<!---
    File: list_ezgi_shipping_portal.cfm
    Folder: Add_Ons\ezgi\e-pda\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<style type="text/css">
<!--
.emp {
	font-family: Georgia, "Times New Roman", Times, serif;
	font-style: italic; 
	font-weight:bold 
}
-->
</style>
<cfparam name="attributes.keyword" default="">
<!--- Kullanıcı Default Departman ve Location tanımlı olması ve Seviyat depo lokasyon olması gerklidir.--->
 <cfsetting showdebugoutput="yes">
 <cfset ezgi_department_id = 1> <!---Çalışan Listesi Gelmesi İçin Firmaya Göre Değişir--->
<cfquery name="get_emp" datasource="#dsn#">
	SELECT        
    	EMPLOYEE_ID, EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ADI
	FROM            
    	EMPLOYEE_POSITIONS
	WHERE        
        DEPARTMENT_ID = #ezgi_department_id# AND
        POSITION_STATUS = 1
</cfquery>
<cfquery name="get_default_department" datasource="#dsn#">
	SELECT DEPARTMENT_ID, LOCATION_ID FROM EMPLOYEE_POSITION_DEPARTMENTS WHERE POSITION_CODE = #session.ep.POSITION_CODE# AND OUR_COMPANY_ID = #session.ep.COMPANY_ID#
</cfquery>
<cfif get_default_department.recordcount and len(get_default_department.DEPARTMENT_ID) and len(get_default_department.LOCATION_ID)>
	<cfparam name="attributes.sales_departments" default="#get_default_department.DEPARTMENT_ID#-#get_default_department.LOCATION_ID#">
<cfelse>
	<cfparam name="attributes.sales_departments" default="">
    <script type="text/javascript">
     	alert("<cf_get_lang dictionary_id='326.Kullanıcı İçin Default Depo Tanımlayınız'>!");
     	history.go(-1);
  	</script>
 	<cfabort>
</cfif>
<cfquery name="get_period_id" datasource="#dsn#">
    	SELECT        
        	PERIOD_YEAR
		FROM            
        	SETUP_PERIOD
		WHERE        
        	OUR_COMPANY_ID = #session.ep.company_id# AND 
            PERIOD_YEAR < #session.ep.period_year#
</cfquery>
<cfset last_year = session.ep.period_year -1>
<cfset lnk_str = ''><cfif isdefined("attributes.start_date") and isdate(attributes.start_date)>
	<cf_date tarih="attributes.start_date">
<cfelse>
	<cfset attributes.start_date = DateAdd('d',-20,wrk_get_today())>
</cfif>
<cfif isdefined("attributes.finish_date") and isdate(attributes.finish_date)>
	<cf_date tarih="attributes.finish_date">
<cfelse>
	<cfset attributes.finish_date = wrk_get_today()>
</cfif>
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'> 
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1 >
<cfquery name="GET_SHIPPING" datasource="#dsn3#"><!---Sevk Planları ve Sevk Talepleri Listeleniyor--->
	SELECT TOP (40)
	    *
	FROM
  		(
       		SELECT   
       		    ESR.SEVK_EMIR_DATE,
       		    ISNULL(ESR.IS_SEVK_EMIR,0) AS IS_SEVK_EMIR,
       		    ISNULL(ESR.SEVK_EMP,0) SEVK_EMP,
       		    ESR.SHIP_RESULT_ID,
       		    ESR.NOTE, 
       		    ESR.SHIP_FIS_NO, 
       		    ESR.DELIVER_PAPER_NO, 
       		    ESR.REFERENCE_NO, 
       		    ESR.DELIVERY_DATE, 
                ESR.DELIVER_EMP,
       		    ESR.DEPARTMENT_ID, 
       		    ESR.OUT_DATE, 
       		    ESR.IS_TYPE, 
       		    ESR.LOCATION_ID, 
       		    ESR.SHIP_METHOD_TYPE, 
       		    SM.SHIP_METHOD, 
       		    D.DEPARTMENT_HEAD,
       		    (
       		    SELECT     
       		        SUM(DURUM) AS DURUM
       		    FROM         
       		        (
       		        SELECT     
       		            DURUM
       		        FROM          
       		            (
       		            SELECT     
       		                CASE 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 1 THEN 1 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 2 THEN 1 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 3 THEN 2 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 4 THEN 1 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 5 THEN 1 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 6 THEN 1 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 7 THEN 1 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 8 THEN 2 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 9 THEN 2 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 10 THEN 2 
       		                    WHEN O.RESERVED = 0 THEN 0 
       		                END AS DURUM
       		            FROM          
       		                EZGI_SHIP_RESULT_ROW AS ESRR INNER JOIN
       		                ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
       		                ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID
       		            WHERE      
       		                ESRR.SHIP_RESULT_ID = ESR.SHIP_RESULT_ID
       		            ) AS TBL2
       		        GROUP BY DURUM
       		        ) AS TBL3
       		    ) AS DURUM
       		FROM       	
       		    EZGI_SHIP_RESULT AS ESR INNER JOIN
       		    #dsn_alias#.SHIP_METHOD AS SM ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID INNER JOIN
       		    #dsn_alias#.DEPARTMENT AS D ON ESR.DEPARTMENT_ID = D.DEPARTMENT_ID
       		WHERE 
       		    IS_TYPE = 1
       		    AND ISNULL(ESR.IS_SEVK_EMIR,0) = 1
       		   	AND ESR.DEPARTMENT_ID = #listgetat(attributes.SALES_DEPARTMENTS,1,'-')# 
       			AND ESR.LOCATION_ID = #listgetat(attributes.SALES_DEPARTMENTS,2,'-')#
              	<cfif isdefined('attributes.start_date') and len(attributes.start_date)>
                	AND ESR.OUT_DATE >= #attributes.start_date#
             	</cfif>
              	<cfif isdefined('attributes.finish_date') and len(attributes.finish_date)>
                 	AND ESR.OUT_DATE <= #attributes.finish_date#
              	</cfif>
       		    <cfif isdefined('attributes.keyword')>
       		        AND  ESR.DELIVER_PAPER_NO LIKE '%#attributes.keyword#%'
       		    </cfif>
       		UNION ALL
      		SELECT   
       		    ESR.SEVK_EMIR_DATE,
       		    ISNULL(ESR.IS_SEVK_EMIR,0) AS IS_SEVK_EMIR,
       		    ISNULL(ESR.SEVK_EMP,0) SEVK_EMP,
       		    ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID,
       		    ESR.NOTE, 
       		    ESR.SHIP_FIS_NO, 
       		    CAST(ESR.SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) AS DELIVER_PAPER_NO, 
       		    ESR.REFERENCE_NO, 
       		    ESR.DELIVERY_DATE, 
                ESR.DELIVER_EMP,
       		    ESR.DEPARTMENT_ID, 
       		    ESR.OUT_DATE, 
       		    ESR.IS_TYPE, 
       		    ESR.LOCATION_ID, 
       		    ESR.SHIP_METHOD_TYPE, 
       		    SM.SHIP_METHOD, 
       		    D.DEPARTMENT_HEAD,
       		    (
       		    SELECT     
       		        SUM(DURUM) AS DURUM
       		    FROM         
       		        (
       		        SELECT     
       		            DURUM
       		        FROM          
       		            (
       		            SELECT     
       		                CASE 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 1 THEN 1 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 2 THEN 1 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 3 THEN 2 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 4 THEN 1 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 5 THEN 1 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 6 THEN 1 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 7 THEN 1 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 8 THEN 2 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 9 THEN 2 
       		                    WHEN ORR.ORDER_ROW_CURRENCY = - 10 THEN 2 
       		                    WHEN O.RESERVED = 0 THEN 0 
       		                END AS DURUM
       		            FROM          
       		                EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR INNER JOIN
       		                ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
       		                ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID
       		            WHERE      
       		                ESRR.SHIP_RESULT_INTERNALDEMAND_ID = ESR.SHIP_RESULT_INTERNALDEMAND_ID
       		            ) AS TBL2
       		        GROUP BY DURUM
       		        ) AS TBL3
       		    ) AS DURUM
       		FROM       	
       		    EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
       		    #dsn_alias#.SHIP_METHOD AS SM ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID INNER JOIN
       		    #dsn_alias#.DEPARTMENT AS D ON ESR.DEPARTMENT_IN_ID = D.DEPARTMENT_ID
       		WHERE 
       		    IS_TYPE = 2
       		    AND ISNULL(ESR.IS_SEVK_EMIR,0) = 1
       		   	AND ESR.DEPARTMENT_ID = #listgetat(attributes.SALES_DEPARTMENTS,1,'-')# 
       			AND ESR.LOCATION_ID = #listgetat(attributes.SALES_DEPARTMENTS,2,'-')#
               	<cfif isdefined('attributes.start_date') and len(attributes.start_date)>
                	AND ESR.OUT_DATE >= #attributes.start_date#
             	</cfif>
              	<cfif isdefined('attributes.finish_date') and len(attributes.finish_date)>
                 	AND ESR.OUT_DATE <= #attributes.finish_date#
              	</cfif>
       		    <cfif isdefined('attributes.keyword')>
       		        AND  CAST(ESR.SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) LIKE '%#attributes.keyword#%'
       		    </cfif>
     	) AS TBL
	WHERE
     	DURUM = 1
	ORDER BY
      	SEVK_EMP,
     	SEVK_EMIR_DATE	
</cfquery>
<cfif GET_SHIPPING.recordcount>
	<cfquery name="get_plan_id" dbtype="query">
    	SELECT SHIP_RESULT_ID FROM GET_SHIPPING WHERE IS_TYPE =1
	</cfquery>
	<cfset sevk_plan_id_list = ValueList(get_plan_id.SHIP_RESULT_ID)>
 	<cfquery name="get_plan_id" dbtype="query">
  		SELECT SHIP_RESULT_ID FROM GET_SHIPPING WHERE IS_TYPE =2
	</cfquery>
	<cfset sevk_talep_id_list = ValueList(get_plan_id.SHIP_RESULT_ID)>
    <cfif Listlen(sevk_plan_id_list)>
        <cfquery name="get_info" datasource="#dsn3#">
            SELECT
            	CASE
                    WHEN O.COMPANY_ID IS NOT NULL THEN
                        (
                                SELECT     
                                    NICKNAME
                                    FROM         
                                        #dsn_alias#.COMPANY
                                    WHERE     
                                        COMPANY_ID = O.COMPANY_ID
                        )
                    WHEN O.CONSUMER_ID IS NOT NULL THEN      
                        (	
                                    SELECT     
                                        CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                                    FROM         
                                        #dsn_alias#.CONSUMER
                                    WHERE     
                                        CONSUMER_ID = O.CONSUMER_ID
                    	)
                END AS UNVAN,
                SC.CITY_NAME,
                SCO.COUNTY_NAME,
                ESRR.SHIP_RESULT_ID
            FROM  
           		EZGI_SHIP_RESULT AS ESR INNER JOIN     
                EZGI_SHIP_RESULT_ROW AS ESRR ON ESRR.SHIP_RESULT_ID = ESR.SHIP_RESULT_ID INNER JOIN
                ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID LEFT JOIN
                #dsn_alias#.SETUP_CITY AS SC ON O.CITY_ID = SC.CITY_ID LEFT JOIN
                #dsn_alias#.SETUP_COUNTY AS SCO ON O.COUNTY_ID = SCO.COUNTY_ID
            WHERE     
                ESR.SHIP_RESULT_ID IN (#sevk_plan_id_list#)
          	GROUP BY
            	SC.CITY_NAME,
                SCO.COUNTY_NAME,
                ESRR.SHIP_RESULT_ID,
                O.COMPANY_ID,
                O.CONSUMER_ID
        </cfquery>
        <cfoutput query="GET_INFO">
            <cfset 'CITY_NAME_1_#SHIP_RESULT_ID#' = CITY_NAME >
            <cfset 'COUNTY_NAME_1_#SHIP_RESULT_ID#' = COUNTY_NAME >
            <cfset 'UNVAN_1_#SHIP_RESULT_ID#' = UNVAN >
        </cfoutput>
    </cfif>
    <cfif Listlen(sevk_talep_id_list)>
        <cfquery name="get_info" datasource="#dsn3#">
        	SELECT 
            	ESR.SHIP_RESULT_INTERNALDEMAND_ID, 
                B.BRANCH_NAME, 
                B.BRANCH_CITY, 
                B.BRANCH_COUNTY
			FROM     
          		#dsn_alias#.DEPARTMENT AS D INNER JOIN
             	EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR ON D.DEPARTMENT_ID = ESR.DEPARTMENT_IN_ID INNER JOIN
           		#dsn_alias#.BRANCH AS B ON D.BRANCH_ID = B.BRANCH_ID
        </cfquery>
        <cfoutput query="GET_INFO">
            <cfset 'CITY_NAME_2_#SHIP_RESULT_INTERNALDEMAND_ID#' = BRANCH_CITY >
            <cfset 'COUNTY_NAME_2_#SHIP_RESULT_INTERNALDEMAND_ID#' = BRANCH_COUNTY >
            <cfset 'BRANCH_NAME_2_#SHIP_RESULT_INTERNALDEMAND_ID#' = BRANCH_NAME >
        </cfoutput>
    </cfif>
</cfif>
<cfquery name="get_shipping_new_sevk" dbtype="query">
	SELECT SHIP_RESULT_ID FROM GET_SHIPPING WHERE SEVK_EMP = 0
</cfquery>  
                            
<cfset attributes.totalrecords = GET_SHIPPING.recordcount>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
   	  <cfform name="order_form" method="post" action="#request.self#?fuseaction=sales.list_ezgi_shipping_portal">
    		<cf_box_search>
                <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                <div class="form-group">
               	  <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="">
               	</div>
                <div class="form-group small">
                 	<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Kayıt Sayısı Hatalı!'></cfsavecontent>
                 	<cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,1250" required="yes" message="#message#">
            	</div>
               	<div class="form-group">
                	<cf_wrk_search_button search_function='input_control()' button_type="4">
             	</div>
          	</cf_box_search>
      </cfform>
   	</cf_box>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id="808.Sevkiyat Bilgi Portalı"></cfsavecontent>
    <cf_box title="#message#">
    	<cf_grid_list sort="1">
        	<thead>
             	<tr>
             		<th rowspan="2" style="width:30px;text-align:center" class="header_icn_txt"><cf_get_lang dictionary_id='58577.Sira'></th>
                  	<th style="text-align:center"><cf_get_lang dictionary_id='39281.Sevk No'></th>
                  	<th style="text-align:center"><cf_get_lang dictionary_id='57742.tarih'></th>
                    <th style="text-align:center"><cf_get_lang dictionary_id='57574.şirket'></th>
                  	<th style="text-align:center"><cf_get_lang dictionary_id='57899.Kaydeden'></th>
                  	<th style="text-align:center"><cf_get_lang dictionary_id='29500.Sevk Yöntemi'></th>
                  	<th style="text-align:center"><cf_get_lang dictionary_id='57971.Şehir'></th> 
                  	<th style="text-align:center"><cf_get_lang dictionary_id='57629.Açıklama'></th>
                  	<th style="text-align:center"><cf_get_lang dictionary_id='29775.Hazırlayan'></th>
                	<!-- sil -->
                    <th style="width:20px" nowrap="nowrap"></th>
                	<!-- sil -->
              	</tr>
         	</thead>    
            <tbody>
				<cfif GET_SHIPPING.recordcount>
                    <cfoutput query="GET_SHIPPING">
                        <tr style="height:40px;" <cfif GET_SHIPPING.SEVK_EMP gt 0> class="emp"</cfif>>
                            <td style="text-align:right;">#currentrow#</td>
                            <td style="text-align:center;" >#DELIVER_PAPER_NO#</td>
                            <td style="text-align:center;" >#DateFormat(OUT_DATE,'DD/MM/YYYY')#</td>
                            <td>
                                <cfif IS_TYPE eq 1>
                                    <cfif isdefined('UNVAN_1_#SHIP_RESULT_ID#')>
                                        #Evaluate('UNVAN_1_#SHIP_RESULT_ID#')#  	
                                    </cfif>
                                <cfelse>
                                    <cfif isdefined('BRANCH_NAME_2_#SHIP_RESULT_ID#')>
                                        #Evaluate('BRANCH_NAME_2_#SHIP_RESULT_ID#')#  	
                                    </cfif>
                                </cfif>
                            </td>
                            <td>#get_emp_info(DELIVER_EMP,0,0)#</td>
                            <td>#SHIP_METHOD#</td>
                            <td style="text-align:left">
                                <cfif isdefined('CITY_NAME_#IS_TYPE#_#SHIP_RESULT_ID#')>
                                    #Evaluate('CITY_NAME_#IS_TYPE#_#SHIP_RESULT_ID#')#
                                    <cfif isdefined('COUNTY_NAME_#IS_TYPE#_#SHIP_RESULT_ID#')>
                                        - #Evaluate('COUNTY_NAME_#IS_TYPE#_#SHIP_RESULT_ID#')#
                                    </cfif>
                                </cfif>
                            </td>
                            <td title="#NOTE#">#left(NOTE,70)#<cfif len(NOTE) gt 70>...</cfif></td>
                            <td>
                                <select name="sevk_emp_id_#SHIP_RESULT_ID#" id="sevk_emp_id_#SHIP_RESULT_ID#" style="width:95%; height:20px" onChange="degisim(#is_type#,#SHIP_RESULT_ID#);">
                                    <option value="0" <cfif GET_SHIPPING.SEVK_EMP eq 0>selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfloop query="get_emp">
                                        <option value="#employee_id#" <cfif GET_SHIPPING.SEVK_EMP eq employee_id>selected</cfif>>#adi#</option>
                                    </cfloop>
                                </select>
                            </td>
                            <td style="text-align:center;<cfif DURUM neq 1>background-color:red</cfif>">
                                <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_print_files&print_type=32&action_id=#is_type#-#SHIP_RESULT_ID#','page');">
                                    <img src="/images/print2.gif" alt="<cf_get_lang dictionary_id='57474.Yazdır'>" border="0" title="<cf_get_lang dictionary_id='57474.Yazdır'>">
                                </a>
                            </td>
                        </tr>
                    </cfoutput>
                <cfelse>
                    <tr>
                        <td colspan="10"><cf_get_lang dictionary_id='57484.Kayit Yok'>!</td>
                    </tr>
                </cfif>
         	</tbody>
		</cf_grid_list>
   	</cf_box>
</div>
<audio id="dingdong" src="AddOns/ezgi/sounds/dingdong.mp3" preload="auto"></audio>
<script language="javascript">
	pn_kontrol();
	function playDingDong() {
        var audio = document.getElementById("dingdong");
        if (audio) {
            audio.play();
        }
    }

	function pn_kontrol()
	{
		<cfif get_shipping_new_sevk.recordcount>
		playDingDong();
		</cfif>
		geciktir1 = setTimeout("window.location.href='<cfoutput>#request.self#?fuseaction=sales.list_ezgi_shipping_portal</cfoutput>'", 100000);
	}
	
	function grupla(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
			shipping_id_list = '';
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
						shipping_id_list +=my_objets.value+',';
				}
			}
			shipping_id_list = shipping_id_list.substr(0,shipping_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(shipping_id_list!='')
			{
				if(type == -2)
				{
					window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_print_files&print_type=32&action_id='+shipping_id_list);		
				}
			}
	}
	function degisim(is_type,action_id)
	{
		sevk_emp_id = document.getElementById('sevk_emp_id_'+action_id).value;
		window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_upd_ezgi_sevk_emp&sevk_emp_id='+sevk_emp_id+'&is_type='+is_type+'&action_id='+action_id);
	}
</script>