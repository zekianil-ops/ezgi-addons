<cfset arama_yapilmali = 0>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.sales_departments" default="#ListGetAt(session.ep.user_location,1,'-')#">
<cfparam name="attributes.date1" default="">
<cfparam name="attributes.branch_id" default="">
<cfset son_row = 0>
<cfif isdefined("attributes.date1") and isdate(attributes.date1)>
	<cf_date tarih="attributes.date1">
<cfelse>
	<cfset attributes.date1 = wrk_get_today()>
</cfif>
<cfquery name="SZ" datasource="#DSN#">
	SELECT * FROM SALES_ZONES WHERE IS_ACTIVE=1 ORDER BY SZ_NAME
</cfquery>
<cfquery name="get_locations" datasource="#dsn#">
	SELECT 
    	DEPARTMENT_ID
  	FROM 
    	EMPLOYEE_POSITION_BRANCHES 
  	WHERE  
    	POSITION_CODE = #session.ep.POSITION_CODE# AND 
        LOCATION_CODE IS NOT NULL AND
        BRANCH_ID IN
        			(
        				SELECT        
                        	BRANCH_ID
						FROM            
                        	BRANCH
						WHERE        
                        	BRANCH_STATUS = 1 AND 
                            COMPANY_ID = #session.ep.COMPANY_ID#
        			)
</cfquery>
<cfif not get_locations.recordcount>
	<script type="text/javascript">
     	alert("<cf_get_lang dictionary_id='712.Bu Şirket İçin Tanımlanmış Depo ve Lokasyon Bulunamamıştır!'>");
     	history.go(-1);
  	</script>
 	<cfabort>
<cfelse>
	<cfset condition_departments_list = ValueList(get_locations.DEPARTMENT_ID)>
    <cfset condition_departments_list = ListDeleteDuplicates(condition_departments_list,',')>
</cfif>
<cfquery name="get_department_name" datasource="#DSN#">
	SELECT 
		D.DEPARTMENT_ID,
		D.DEPARTMENT_HEAD,
		D.BRANCH_ID
	FROM
		DEPARTMENT D
	WHERE 
		D.BRANCH_ID IN (SELECT BRANCH_ID FROM BRANCH WHERE COMPANY_ID = #session.ep.company_id#)
        AND D.DEPARTMENT_ID IN (#condition_departments_list#)
	ORDER BY
		D.DEPARTMENT_HEAD
</cfquery>
<cfquery name="GET_DEPARTMENT" datasource="#DSN#">
	SELECT
		DEPARTMENT_ID,
		DEPARTMENT_HEAD
	FROM
		BRANCH B,
		DEPARTMENT D 
	WHERE
		B.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		B.BRANCH_ID = D.BRANCH_ID AND
		D.IS_STORE <> 2
		AND D.DEPARTMENT_STATUS = 1 

	ORDER BY
		DEPARTMENT_HEAD
</cfquery>
<cfoutput query="GET_DEPARTMENT">
	<cfset 'DEPARTMENT_HEAD_#DEPARTMENT_ID#' = DEPARTMENT_HEAD>
</cfoutput>
<cfquery name="get_money" datasource="#dsn#"><!--- Onceki Donemlerin Para Birimleri De Gerektiginden Dsnden Cekiliyor FBS --->
	SELECT MONEY FROM SETUP_MONEY GROUP BY MONEY
</cfquery>
<cfoutput query="get_money">
	<cfset 'total_grosstotal_doviz_#money#' = 0>
</cfoutput>
<cfset branch_dep_list=valuelist(get_department.department_id,',')>
<cfif isdefined("attributes.form_submitted")>
	<cfquery name="get_total_purchase_e" datasource="#DSN2#">
        SELECT     
            COLLECT_ID, 
            DEPARTMENT_IN,
            SHIP_METHOD,
            DEPARTMENT_OUT,
            SUM(PAKET_SAYISI) AS PAKET_SAYISI, 
            ISNULL(
            (
            SELECT     
            	SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
           	FROM         
            	#dsn3_alias#.EZGI_SHIPPING_PACKAGE_LIST_COLLECT_STORE
          	WHERE     
            	COLLECT_ID = TBL2.COLLECT_ID
           	), 0) AS CONTROL_AMOUNT,
            SUM(CONTROL_AMOUNT1) AS CONTROL_AMOUNT1,
            (
            SELECT     
            	SHIP_METHOD
			FROM         
            	#dsn_alias#.SHIP_METHOD
			WHERE     
            	SHIP_METHOD_ID = TBL2.SHIP_METHOD
            ) as SHIP_METHOD_A
        FROM         
            (
            SELECT     
                DISPATCH_SHIP_ID, 
                PAKET_ID, 
                COLLECT_ID, 
                DEPARTMENT_IN,
                SHIP_METHOD,
                DEPARTMENT_OUT,
                PAKET_SAYISI,
               	ISNULL((
				SELECT     
                	SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
              	FROM          
               		#dsn3_alias#.EZGI_SHIPPING_PACKAGE_LIST
               	WHERE      
                 	TYPE = 2 AND 
              	STOCK_ID = TBL.PAKET_ID AND 
                 	SHIPPING_ID = TBL.DISPATCH_SHIP_ID
            	),0) AS CONTROL_AMOUNT1
            FROM          
                (
                    SELECT     
                        EC.DISPATCH_SHIP_ID, 
                        EPS.PAKET_ID, 
                        EC.COLLECT_ID, 
                        EC.DEPARTMENT_IN,
                        EC.SHIP_METHOD,
                        EC.DEPARTMENT_OUT,
                        SUM(EPS.PAKET_SAYISI * SIR.AMOUNT) AS PAKET_SAYISI
                    FROM          
                        EZGI_SHIP_INTERNAL_COLLECT AS EC INNER JOIN
                        SHIP_INTERNAL_ROW AS SIR ON EC.DISPATCH_SHIP_ID = SIR.DISPATCH_SHIP_ID INNER JOIN
                        #dsn3_alias#.EZGI_PAKET_SAYISI AS EPS ON SIR.STOCK_ID = EPS.MODUL_ID
                    WHERE   
                    	1=1
                       	<cfif isdefined("attributes.sales_departments") and len(attributes.sales_departments)>
                        	AND EC.DEPARTMENT_OUT = #attributes.sales_departments#
                       	</cfif>
                        <cfif len(attributes.ship_method_id)>
                        	AND EC.SHIP_METHOD = #attributes.ship_method_id#
                        </cfif>
                        <cfif len(attributes.branch_id)>
                        	AND EC.DEPARTMENT_IN IN
                            				(
                                            SELECT     
                                            	DEPARTMENT_ID
											FROM         
                                            	#dsn_alias#.DEPARTMENT
											WHERE     
                                            	DEPARTMENT_STATUS = 1 AND 
                                                BRANCH_ID = #attributes.branch_id#
                                            )
                            
                            
                            
                        </cfif>
                        <cfif len(attributes.date1)>
                        	AND SUBSTRING(EC.COLLECT_ID,5,2)+'/'+SUBSTRING(EC.COLLECT_ID,3,2)+'/20'+left(EC.COLLECT_ID,2) = '#DateFormat(attributes.date1,'DD/MM/YYYY')#'
                        </cfif> 
                    GROUP BY 
                        EC.DISPATCH_SHIP_ID, 
                        EPS.PAKET_ID, 
                        EC.COLLECT_ID,
                        EC.DEPARTMENT_IN,
                        EC.SHIP_METHOD,
                        EC.DEPARTMENT_OUT
                ) AS TBL
            ) AS TBL2
        GROUP BY 
            COLLECT_ID,
            DEPARTMENT_IN,
            SHIP_METHOD,
            DEPARTMENT_OUT
      	ORDER BY
        	DEPARTMENT_OUT,
        	DEPARTMENT_IN,
            SHIP_METHOD
 	</cfquery>
<cfelse>
	<cfset get_total_purchase_e.recordcount = 0>
    <cfset arama_yapilmali = 1>
</cfif>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.totalrecords" default="#get_total_purchase_e.recordcount#">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfif isdefined('attributes.is_excel') and  attributes.is_excel eq 1>
	<cfset attributes.startrow=1>
	<cfset attributes.maxrows=get_total_purchase.recordcount>
</cfif>
<cfquery name="get_branch_" datasource="#dsn#">
	SELECT 
		BRANCH_NAME,BRANCH_ID
	FROM
		BRANCH
	WHERE
		COMPANY_ID = #session.ep.company_id#
		AND BRANCH_STATUS = 1
</cfquery>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="order_form" method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
        	<input type="hidden" name="form_submitted" id="form_submitted" value="">
            <cf_box_search>
                <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group">
                	<div class="input-group">
                		<input type="hidden" name="ship_method_id" id="ship_method_id" value="<cfif isdefined('attributes.ship_method_id') and len(attributes.ship_method_name)><cfoutput>#attributes.ship_method_id#</cfoutput></cfif>">
                        <input type="text" name="ship_method_name" id="ship_method_name" style="width:160px;" value="<cfif isdefined("attributes.ship_method_name") and len(attributes.ship_method_name)><cfoutput>#attributes.ship_method_name#</cfoutput></cfif>"  placeholder="<cf_get_lang dictionary_id='29500.Sevk Yöntemi'>" onfocus="AutoComplete_Create('ship_method_name','SHIP_METHOD','SHIP_METHOD','get_ship_method','','SHIP_METHOD_ID','ship_method_id','','3','125');" autocomplete="off">
                  		<span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_ship_methods&field_name=order_form.ship_method_name&field_id=order_form.ship_method_id','list');"></span>
					</div>
               	</div>
                <div class="form-group">
                	<select name="branch_id" id="branch_id" style="width:100px;">
                    	<option value=""><cf_get_lang dictionary_id='29495.Tüm Şubeler'></option>
                    	<cfoutput query="get_branch_">
                        	<option value="#branch_id#"<cfif attributes.branch_id eq branch_id>selected</cfif>>#branch_name#</option>
                      	</cfoutput>
               		</select>
                </div>
                <div class="form-group">
                	<select name="sales_departments" id="sales_departments" style="width:130px;height:20px">
                    	<option value=""><cf_get_lang dictionary_id="29428.Çıkış Depo"></option>
                      	<cfoutput query="get_department_name">
                       		<option value="#department_id#" <cfif len(attributes.sales_departments) and attributes.sales_departments eq department_id>selected</cfif>>#department_head#</option>
                     	</cfoutput>
                	</select>
                </div>
                <div class="form-group">
                	<div class="input-group">
                      	<cfsavecontent variable="message"><cf_get_lang dictionary_id='30123.Bitiş Tarihini Kontrol Ediniz'></cfsavecontent>
                    	<cfinput type="text" name="date1" value="#dateformat(attributes.date1, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#">
                     	<span class="input-group-addon"><cf_wrk_date_image date_field="date1"></span>
                 	</div>
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
    <cfsavecontent variable="message"><cf_get_lang dictionary_id='58857.Sevkiyat İşlemleri'></cfsavecontent>
    <cf_box title="#message#" uidrop="1" hide_table_column="1">
    	<cf_grid_list sort="1">
        	<thead>
                <tr>
                    <th width="25" style="text-align:center;"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th><cf_get_lang dictionary_id='29428.Çıkış Depo'></th>
                    <th><cf_get_lang dictionary_id='36506.Giriş Depo'></th>
                    <th width="150"><cf_get_lang dictionary_id='29500.Sevk Yöntemi'></th>
                    <th width="85" style="text-align:right;"><cf_get_lang dictionary_id='1096.Toplam Paket Sayısı'></th>
                    <th width="85" style="text-align:right;"><cf_get_lang dictionary_id='1097.Çıkış Depo Paket Kontrol'></th>
                    <th width="85" style="text-align:right;"><cf_get_lang dictionary_id='1098.Giriş Depo Paket Kontrol'></th>
                </tr>
            </thead>
            <tbody>
                <cfif get_total_purchase_e.recordcount>
                    <cfoutput query="get_total_purchase_e">
                         <tr>
                            <td>#currentrow#</td>
                            <td>#Evaluate('DEPARTMENT_HEAD_#DEPARTMENT_OUT#')#</td>
                            <td>#Evaluate('DEPARTMENT_HEAD_#DEPARTMENT_IN#')#</td>
                            <td>#SHIP_METHOD_A#</td>
                            <td style="text-align:right;">
                                <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_term_control_store&collect_id=#COLLECT_ID#','page');" class="tableyazi" title="<cf_get_lang_main no='3537.Detay Göster'>">
                                    #PAKET_SAYISI#
                                </a>
                            </td>
                            <td style="text-align:right;">#CONTROL_AMOUNT1#</td>
                            <td style="text-align:right;">#CONTROL_AMOUNT#</td>
                        </tr>
                    </cfoutput>
                <cfelse>
                    <tr>
                        <td colspan="7"><cfif arama_yapilmali neq 1><cf_get_lang dictionary_id='57484.Kayit Yok'>!<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz '>!</cfif></td>
                    </tr>
                </cfif>
            </tbody>
		</cf_grid_list>
        <cfset url_str = 'sales.popup_list_ezgi_shipping_control'>
        <cfif isdefined("attributes.form_varmi") and attributes.totalrecords gt attributes.maxrows>
			<cfif isdefined("attributes.totalrecords") and len(attributes.totalrecords)>
                <cfset url_str = url_str & "&totalrecords=#attributes.totalrecords#">
            </cfif>
            <cfif isdefined("attributes.keyword") and len(attributes.keyword)>
                <cfset url_str = url_str & "&keyword=#attributes.keyword#">
            </cfif>
            <cfif isdefined("attributes.branch_id") and len(attributes.branch_id)>
                <cfset url_str = url_str & "&branch_id=#attributes.branch_id#">
            </cfif>
            <cfif isdefined("attributes.ship_method_id") and len(attributes.ship_method_id)>
                <cfset url_str = url_str & "&ship_method_id=#attributes.ship_method_id#">
            </cfif>
            <cfif isdefined("attributes.sales_departments") and len(attributes.sales_departments)>
                <cfset url_str = url_str & "&sales_departments=#attributes.sales_departments#">
            </cfif>
            <cfif isdate(attributes.date1) and len(attributes.date1)>
                <cfset url_str = url_str & "&date1=#dateformat(attributes.date1,'dd/mm/yyyy')#">
            </cfif>
            <cf_paging 
                    page="#attributes.page#"
                    maxrows="#attributes.maxrows#"
                    totalrecords="#attributes.totalrecords#"
                    startrow="#attributes.startrow#"
                    adres="#attributes.fuseaction#&#url_str#&form_varmi=1">
        </cfif>
 	</cf_box>
</div>
<script language="javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true
	}
</script>