<cfsetting showdebugoutput="yes">
<cfset x_round_number = 2>
<cf_get_lang_set module_name="stock">
<cfparam name="attributes.department_id_" default="">
<cfparam name="attributes.location_id" default="">
<cfparam name="attributes.location_name" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.stock_id" default="">
<cfparam name="attributes.modal_id" default="">
<cfif isdefined("department_id")>
	<cfset attributes.department_id_=attributes.department_id>
</cfif>
<cfset attributes.department_id=attributes.department_id_> 
<cfif isDefined("attributes.startdate") and isdate(attributes.startdate)>
    <cf_date tarih="attributes.startdate">
<cfelse>
	<cfset attributes.startdate="">
</cfif>
<cfif isDefined("attributes.finishdate")  and isdate(attributes.finishdate)>
	<cf_date tarih="attributes.finishdate">
<cfelse>    
	<cfset attributes.finishdate="">
</cfif>
<cfinclude template="../../../../V16/stock/query/get_stores.cfm">
<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT 
		D.DEPARTMENT_HEAD,
		SL.DEPARTMENT_ID,
		SL.LOCATION_ID,
		SL.STATUS,
		SL.COMMENT
	FROM 
		STOCKS_LOCATION SL WITH (NOLOCK),
		DEPARTMENT D WITH (NOLOCK),
		BRANCH B WITH (NOLOCK)
	WHERE
		D.IS_STORE <>2 AND
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND
		D.DEPARTMENT_STATUS = 1 AND
		D.BRANCH_ID = B.BRANCH_ID AND
		B.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
	ORDER BY
		D.DEPARTMENT_HEAD,
		COMMENT
</cfquery>
<cfoutput query="GET_ALL_LOCATION">
	<cfset 'depo_#DEPARTMENT_ID#_#LOCATION_ID#'= DEPARTMENT_HEAD>
</cfoutput>
<cfquery name="GET_TOPLAM" datasource="#dsn2#">
	SELECT DISTINCT 
    	CASE WHEN SR.STOCK_IN = 0 THEN 'CIKIS' ELSE 'GIRIS' END AS TIP, 
        (SELECT PROCESS_CAT FROM #dsn3_alias#.SETUP_PROCESS_CAT WHERE PROCESS_CAT_ID = SF.PROCESS_CAT) AS DETAIL,
        SR.STOCK_ID, 
        S.STOCK_CODE, 
        S.PRODUCT_NAME, 
        SF.FIS_ID, 
        SF.FIS_NUMBER, 
        SF.FIS_DATE AS PROCESS_DATE, 
        SF.FIS_TYPE AS PROCESS_TYPE, 
        SF.PROCESS_CAT, 
     	SFR.STOCK_FIS_ROW_ID, 
        SFR.PRICE AS NET_PRICE, 
        SFR.UNIT, 
        SFR.AMOUNT,
        SR.STORE, 
        SR.STORE_LOCATION
	FROM            
    	STOCKS_ROW AS SR WITH (NOLOCK) INNER JOIN
      	#dsn3_alias#.STOCKS AS S WITH (NOLOCK) ON SR.STOCK_ID = S.STOCK_ID AND SR.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
    	STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SR.UPD_ID = SFR.FIS_ID AND SR.STOCK_ID = SFR.STOCK_ID INNER JOIN
   		STOCK_FIS AS SF WITH (NOLOCK) ON SFR.FIS_ID = SF.FIS_ID
	WHERE   
    	SR.PROCESS_TYPE IN (110, 111, 112, 113, 114, 115, 119, 1131)  
        <cfif isDefined('attributes.stock_id') and len(attributes.stock_id)>   
    		AND  SR.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#"> 
        </cfif>
	UNION ALL
	SELECT DISTINCT 
    	CASE WHEN SR.STOCK_IN = 0 THEN 'CIKIS' ELSE 'GIRIS' END AS TIP, 
        CASE
        	WHEN I.COMPANY_ID IS NOT NULL THEN
          	(
                    SELECT     
                      	NICKNAME
					FROM         
                    	#dsn_alias#.COMPANY WITH (NOLOCK)
					WHERE     
                   		COMPANY_ID = I.COMPANY_ID
          	)
         	WHEN I.CONSUMER_ID IS NOT NULL THEN      
          	(	
                  	SELECT     
                     	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
					FROM         
                      	#dsn_alias#.CONSUMER WITH (NOLOCK)
					WHERE     
                		CONSUMER_ID = I.CONSUMER_ID
          	)
            WHEN I.EMPLOYEE_ID IS NOT NULL THEN      
          	(	
            	SELECT        
                	EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
				FROM            
                	#dsn_alias#.EMPLOYEES WITH (NOLOCK)
				WHERE        
                	EMPLOYEE_ID = I.EMPLOYEE_ID
          	)
      	END AS DETAIL,
       	SR.STOCK_ID, 
        S.STOCK_CODE, 
        S.PRODUCT_NAME, 
        I.INVOICE_ID, 
        I.INVOICE_NUMBER, 
        I.INVOICE_DATE AS PROCESS_DATE, 
        I.INVOICE_CAT AS PROCESS_TYPE, 
        I.PROCESS_CAT, 
        IRR.INVOICE_ROW_ID, 
        IRR.NETTOTAL / IRR.AMOUNT AS NET_PRICE, 
        IRR.UNIT, 
        IRR.AMOUNT,
        SR.STORE, 
        SR.STORE_LOCATION
	FROM            
    	STOCKS_ROW AS SR WITH (NOLOCK) INNER JOIN
      	#dsn3_alias#.STOCKS AS S WITH (NOLOCK) ON SR.STOCK_ID = S.STOCK_ID AND SR.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
     	SHIP_ROW AS SRR WITH (NOLOCK) ON SR.UPD_ID = SRR.SHIP_ID AND SR.STOCK_ID = SRR.STOCK_ID INNER JOIN
      	INVOICE_ROW AS IRR WITH (NOLOCK) ON SRR.WRK_ROW_ID = IRR.WRK_ROW_RELATION_ID LEFT OUTER JOIN
      	INVOICE AS I WITH (NOLOCK) ON IRR.INVOICE_ID = I.INVOICE_ID
	WHERE 
    	SR.PROCESS_TYPE IN (70, 71, 72, 78, 85, 141, 73, 74, 75, 76, 77, 84, 86, 87, 88, 140, 81, 811)  
    	<cfif isDefined('attributes.stock_id') and len(attributes.stock_id)>     
    		AND SR.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#"> 
        </cfif>
   	UNION ALL
	SELECT DISTINCT 
    	CASE WHEN SR.STOCK_IN = 0 THEN 'CIKIS' ELSE 'GIRIS' END AS TIP, 
        CASE
        	WHEN I.COMPANY_ID IS NOT NULL THEN
          	(
                    SELECT     
                      	NICKNAME
					FROM         
                    	#dsn_alias#.COMPANY WITH (NOLOCK)
					WHERE     
                   		COMPANY_ID = I.COMPANY_ID
          	)
         	WHEN I.CONSUMER_ID IS NOT NULL THEN      
          	(	
                  	SELECT     
                     	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
					FROM         
                      	#dsn_alias#.CONSUMER WITH (NOLOCK)
					WHERE     
                		CONSUMER_ID = I.CONSUMER_ID
          	)
            WHEN I.EMPLOYEE_ID IS NOT NULL THEN      
          	(	
            	SELECT        
                	EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
				FROM            
                	#dsn_alias#.EMPLOYEES WITH (NOLOCK)
				WHERE        
                	EMPLOYEE_ID = I.EMPLOYEE_ID
          	)
      	END AS DETAIL,
       	SR.STOCK_ID, 
        S.STOCK_CODE, 
        S.PRODUCT_NAME, 
        I.INVOICE_ID, 
        I.INVOICE_NUMBER, 
        I.INVOICE_DATE AS PROCESS_DATE, 
        I.INVOICE_CAT AS PROCESS_TYPE, 
        I.PROCESS_CAT, 
        IRR.INVOICE_ROW_ID, 
        IRR.NETTOTAL / IRR.AMOUNT AS NET_PRICE, 
        IRR.UNIT, 
        IRR.AMOUNT,
        SR.STORE, 
        SR.STORE_LOCATION
	FROM            
    	STOCKS_ROW AS SR WITH (NOLOCK) INNER JOIN
      	#dsn3_alias#.STOCKS AS S WITH (NOLOCK) ON SR.STOCK_ID = S.STOCK_ID AND SR.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
     	SHIP_ROW AS SRR WITH (NOLOCK) ON SR.UPD_ID = SRR.SHIP_ID AND SR.STOCK_ID = SRR.STOCK_ID INNER JOIN
      	INVOICE_ROW AS IRR WITH (NOLOCK) ON IRR.WRK_ROW_ID = SRR.WRK_ROW_RELATION_ID LEFT OUTER JOIN
      	INVOICE AS I WITH (NOLOCK) ON IRR.INVOICE_ID = I.INVOICE_ID
	WHERE 
    	SR.PROCESS_TYPE IN (70, 71, 72, 78, 85, 141, 73, 74, 75, 76, 77, 84, 86, 87, 88, 140, 81, 811)  
    	<cfif isDefined('attributes.stock_id') and len(attributes.stock_id)>     
    		AND SR.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#"> 
        </cfif>
	UNION ALL
	SELECT DISTINCT 
   		CASE WHEN SR.STOCK_IN = 0 THEN 'CIKIS' ELSE 'GIRIS' END AS TIP, 
        '' AS DETAIL,
        SR.STOCK_ID, 
        S.STOCK_CODE, 
        S.PRODUCT_NAME, 
        SR.UPD_ID, '' AS FIS_NUMBER, 
        SR.PROCESS_DATE, 
        SR.PROCESS_TYPE, 
        0 AS PROCESS_CAT, 0 AS FIS_ROW_ID, 
        0 AS NET_PRICE, 
        PU.MAIN_UNIT AS UNIT, 
        CASE WHEN SR.STOCK_IN = 0 THEN SR.STOCK_OUT ELSE SR.STOCK_IN END AS AMOUNT,
        SR.STORE, 
        SR.STORE_LOCATION
	FROM            
    	STOCKS_ROW AS SR WITH (NOLOCK) INNER JOIN
        #dsn3_alias#.STOCKS AS S WITH (NOLOCK) ON SR.STOCK_ID = S.STOCK_ID AND SR.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
        #dsn3_alias#.PRODUCT_UNIT AS PU WITH (NOLOCK) ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
	WHERE  
    	SR.PROCESS_TYPE NOT IN (110, 111, 112, 113, 114, 115, 119, 1131, 70, 71, 72, 78, 85, 141, 73, 74, 75, 76, 77, 84, 86, 87, 88, 140, 81, 811)
    	<cfif isDefined('attributes.stock_id') and len(attributes.stock_id)>       
    		AND SR.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#">  
        </cfif>
	ORDER BY 
    	PROCESS_DATE
</cfquery>

<cfquery name="get_total" dbtype="query">
	SELECT
		*
	FROM
		GET_TOPLAM
    WHERE
        1=1
        <cfif len(attributes.startdate)>
        AND	PROCESS_DATE >= #attributes.startdate#
        </cfif>
        <cfif len(attributes.finishdate)>
        AND	PROCESS_DATE <= #attributes.finishdate#
        </cfif>
</cfquery>
<cfset toplam_stok = 0>
<cfset toplam_giren_stok = 0>
<cfset toplam_cikan_stok = 0>
<cfset toplam_giren_miktar = 0>
<cfset toplam_cikan_miktar = 0>

<cfif len(attributes.startdate)>
	<!--- 20051229 searchte girilen baslangic tarihi ileri bir tarih olunca ekrana gelmeyenlerin toplamini aliyoruz--->
	<cfquery name="get_total2" dbtype="query">
            SELECT 
                SUM(AMOUNT) AS STOCK_IN,
                0 AS STOCK_OUT
            FROM 
                GET_TOPLAM 
            WHERE 
                TIP = 'GIRIS' AND
                PROCESS_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#">
                <cfif not len(attributes.department_id)>
                    AND PROCESS_TYPE NOT IN (81,811)
                </cfif>
            UNION ALL
            SELECT 
                0 AS STOCK_IN,
                SUM(AMOUNT) AS STOCK_OUT
            FROM 
                GET_TOPLAM 
            WHERE 
                TIP = 'CIKIS' AND
                PROCESS_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#">
                <cfif not len(attributes.department_id)>
                    AND PROCESS_TYPE NOT IN (81,811)
                </cfif>
	</cfquery>
    <cfquery name="get_total2" dbtype="query">
    	SELECT
        	SUM(STOCK_IN - STOCK_OUT) AS TOTAL2 
      	FROM
        	get_total2
	</cfquery>
	<cfif get_total2.recordcount and get_total2.total2 neq 0><!--- negatif veya pozitif olabilir kosul tmamen dogru ellenmesin --->
		<cfset toplam_stok = get_total2.total2>
	</cfif>
</cfif>
<cfif len(attributes.startdate)>
	<cfset attributes.startdate = dateformat(attributes.startdate,dateformat_style)>
</cfif>
<cfif len(attributes.finishdate)>
	<cfset attributes.finishdate = dateformat(attributes.finishdate,dateformat_style)>
</cfif>			
<cfset adres="#fusebox.circuit#.popup_detail_ezgi_stock_list">
<cfif isDefined('attributes.pid') and len(attributes.pid)>

	<cfquery name="get_product_names" datasource="#dsn3#">
		SELECT
			PRODUCT_NAME,
			PROPERTY,
			STOCK_CODE,
			STOCK_ID
		FROM
			STOCKS WITH (NOLOCK)
		WHERE
		<cfif isDefined('attributes.stock_id') and len(attributes.stock_id)>
			STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#">
		</cfif>
	</cfquery>
	<cfset attributes.product_name = get_product_names.product_name>
</cfif>

<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_total.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfsavecontent variable="title">
	<cfoutput>
        <cf_get_lang dictionary_id='30064.Stok Hareketleri'>
        <cfif isDefined('attributes.pid') and len(attributes.pid)>: #get_product_names.STOCK_CODE#-#get_product_names.product_name#</cfif>
        <cfif isDefined('attributes.stock_id') and len(attributes.stock_id)>&nbsp;#get_product_names.property#</cfif>
    </cfoutput>
</cfsavecontent>
<cf_box title="#title#" uidrop="1" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
	<cfform name="search" action="#request.self#?fuseaction=#adres#" method="post">
		  <cf_box_search>
            <div class="form-group" id="item-date1">
            	<div class="input-group">             
								<cfsavecontent variable="message"><cf_get_lang dictionary_id ='58053.Başlangıç Tarihi'></cfsavecontent>
								<cfinput type="text" validate="#validate_style#" name="startdate" placeholder="#getLang('main',330)#" message="#message#" value="#attributes.startdate#">
								<span class="input-group-addon"><cf_wrk_date_image date_field="startdate"></span>
							</div>
            </div>
            <div class="form-group" id="item-date2">
            	<div class="input-group">        
								<cfsavecontent variable="message"><cf_get_lang dictionary_id ='57700.Bitiş Tarihi'></cfsavecontent>
								<cfinput type="text" name="finishdate"  message="#message#" placeholder="#getLang('main',330)#" validate="#validate_style#" value="#attributes.finishdate#">
								<span class="input-group-addon"><cf_wrk_date_image date_field="finishdate"></span>
							</div>
            </div>
			<div class="form-group small">
				<cfsavecontent variable="message"><cf_get_lang dictionary_id='45531.Listeleme Sayısı Hatalı'> !</cfsavecontent>
				<cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,250" required="yes" message="#message#">
			</div>
			<div class="form-group">
				<cf_wrk_search_button button_type="4" search_function="input_control()">
			</div>
		</cf_box_search>
		<cf_box_search_detail search_function="input_control()">
				<div class="ui-form-list ui-form-block">
						<div class="form-group col col-4 col-md-4 col-sm-6 col-xs-12" id="item-location_id">
							<cf_wrkdepartmentlocation 
									returninputvalue="location_id,location_name,department_id_"
									returnqueryvalue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID"
									fieldname="location_name"
									fieldid="location_id"
									status="0"
									is_department="1"
									line_info="2"
									department_fldid="department_id_"
									department_id="#attributes.department_id_#"
									location_id="#attributes.location_id#"
									location_name="#attributes.location_name#"
									user_level_control="0"
									user_location = "0"
									width="175"
								>
						</div>
  
                
						<div class="form-group col col-4 col-md-4 col-sm-6 col-xs-12" id="item-product_name">
							<div class="input-group">
								<input type="hidden" name="pid" id="pid" <cfif len(attributes.pid) and len(attributes.product_name)> value="<cfoutput>#attributes.pid#</cfoutput>"</cfif>>
								<input type="hidden" name="stock_id" id="stock_id" <cfif len(attributes.stock_id) and len(attributes.product_name)> value="<cfoutput>#attributes.stock_id#</cfoutput>"</cfif>>
								<input name="product_name" type="text" placeholder="<cf_get_lang dictionary_id='57452.Stok'>" id="product_name"  onFocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME','get_product','0','PRODUCT_ID,STOCK_ID','pid,stock_id','','3','130');" value="<cfif len(attributes.stock_id)><cfoutput>#get_product_name(product_id:attributes.pid,stock_id:attributes.stock_id,with_property:1)#</cfoutput><cfelse><cfoutput>#get_product_name(product_id:attributes.pid,with_property:1)#</cfoutput></cfif>" autocomplete="off">
								<span class="input-group-addon icon-ellipsis"  onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=search.stock_id&product_id=search.pid&field_name=search.product_name<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&keyword='+encodeURIComponent(document.search.product_name.value),'list');"></span>
							</div>
						</div>	
				</div>
			</cf_box_search_detail>
			<cf_grid_list>
				<thead>
					<tr>
                    	<th width="25"><cf_get_lang dictionary_id='58577.Sıra'></th>
						<th width="75"><cf_get_lang dictionary_id='57742.Tarih'></th>
						<th width="100"><cf_get_lang dictionary_id='57880.Belge No'></th>
						<th width="25"><cf_get_lang dictionary_id='57982.Tür'></th>
                        <th width="75" class="text-right"><cf_get_lang dictionary_id='58084.Fiyat'></th>
                        <th width="60" class="text-right"><cf_get_lang dictionary_id='57554.Giriş'></th>
                        <th width="60" class="text-right"><cf_get_lang dictionary_id='57431.Çıkış'></th>
                        <th width="60" class="text-right"><cf_get_lang dictionary_id='57589.Bakiye'></th>
                        <th width="40"><cf_get_lang dictionary_id='57636.Birim'></th>
                        <th><cf_get_lang dictionary_id='57629.Açıklama'></th>
                        <th width="150"><cf_get_lang dictionary_id='58578.Belge Türü'></th>
                        <th width="200"><cf_get_lang dictionary_id='58763.Depo'></th>
					</tr>
				</thead>
				<tbody>
					<cfif get_total.recordcount>
						<cfif attributes.totalrecords gt attributes.maxrows>
							<cfif attributes.page neq 1>
								<cfset max_ = (attributes.page-1)*attributes.maxrows>
								<cfoutput query="GET_TOTAL" startrow="1" maxrows="#max_#">
									<cfif TIP eq 'CIKIS'>
										<cfif (not listfind("81,811,113",PROCESS_TYPE,",")) or len(attributes.department_id)>
											<cfset toplam_stok = toplam_stok - AMOUNT>
                                            <cfset toplam_cikan_stok = toplam_cikan_stok + AMOUNT>
                                    		<cfset toplam_cikan_miktar = toplam_cikan_miktar + (NET_PRICE*AMOUNT)>
										</cfif>
									<cfelse>
										<cfif (not listfind("81,811,113",PROCESS_TYPE,",")) or len(attributes.department_id)>
											<cfset toplam_stok = toplam_stok + AMOUNT>
                                            <cfset toplam_giren_stok = toplam_giren_stok + AMOUNT>
                                    		<cfset toplam_giren_miktar = toplam_giren_miktar + (NET_PRICE*AMOUNT)>
										</cfif>
									</cfif>
								</cfoutput>
							</cfif>
						</cfif>		
						<tr>
							<td colspan="7" style="font-weight:bold"><cf_get_lang dictionary_id='58034.Devreden'></td>
							<cfoutput>
                                <td class="text-right" style="font-weight:bold">#TlFormat(toplam_stok,x_round_number)#</td>
                                <td style="font-weight:bold">#get_total.UNIT#</td>
							</cfoutput>
						</tr>
						<cfoutput query="get_total" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                        	<cfif TIP eq 'CIKIS'>
                            	<cfif (not listfind("81,811,113",process_type,",")) or len(attributes.department_id)>
                            		<cfset toplam_stok = toplam_stok - AMOUNT>
									<cfset toplam_cikan_stok = toplam_cikan_stok + AMOUNT>
                                    <cfset toplam_cikan_miktar = toplam_cikan_miktar + (NET_PRICE*AMOUNT)>
                              	</cfif>
                            <cfelse>
                            	<cfif (not listfind("81,811,113",process_type,",")) or len(attributes.department_id)>
                            		<cfset toplam_stok = toplam_stok + AMOUNT>
                                    <cfset toplam_giren_stok = toplam_giren_stok + AMOUNT>
                                    <cfset toplam_giren_miktar = toplam_giren_miktar + (NET_PRICE*AMOUNT)>
                                </cfif>
                            </cfif>
							<tr>
                            	<td height="20" align="right">#CURRENTROW#</td>
								<td>#dateformat(process_date,dateformat_style)#</td>
								<td>#FIS_NUMBER#</td>
                                <td align="center">#TIP#</td>
                                <td align="right">#TlFormat(NET_PRICE,2)#</td>
                                <td align="right"><cfif TIP eq 'GIRIS'>#TlFormat(AMOUNT,x_round_number)#<cfelse>#TlFormat(0,x_round_number)#</cfif></td>
                                <td align="right"><cfif TIP eq 'CIKIS'>#TlFormat(AMOUNT,x_round_number)#<cfelse>#TlFormat(0,x_round_number)#</cfif></td>
                                <td align="right" <cfif toplam_stok lt 0>style="color:red"</cfif>><strong>#TlFormat(toplam_stok,x_round_number)#</strong></td>
                                <td>#UNIT#</td>
                                <td>#DETAIL#</td>
								<td>#get_process_name(process_type)#</td>
                                <td>
                                	<cfif isdefined('depo_#STORE#_#STORE_LOCATION#')>
                                    	#Evaluate('depo_#STORE#_#STORE_LOCATION#')#
                                    </cfif>
                                </td>
							</tr>
						</cfoutput>
						</tbody>
                       	<tfoot>
                        	<tr>
                            	<td colspan="12">
                                	<table style="width:100%; height:100%; border-color:gainsboro" cellpadding="0" cellspacing="0" border="1">
										<cfoutput>
                                            <tr>
                                                <td style="width:15%; height:25px">&nbsp;Giriş Miktarı</td>
                                                <td style="width:16%; font-weight:bold; text-align:right">#TlFormat(toplam_giren_stok,x_round_number)#&nbsp;</td>
                                                <td style="width:15%; ">&nbsp;Çıkış Miktarı</td>
                                                <td style="width:16%; font-weight:bold; text-align:right">#TlFormat(toplam_cikan_stok,x_round_number)#&nbsp;</td>
                                                <td style="width:15%; ">&nbsp;Bakiye Miktarı</td>
                                                <td style="width:16%; font-weight:bold; text-align:right">#TlFormat(toplam_stok,x_round_number)# #get_total.UNIT#&nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td style="width:15%; height:25px">&nbsp;Giriş Tutarı</td>
                                                <td style="width:16%; font-weight:bold; text-align:right">#TlFormat(toplam_giren_miktar,2)#&nbsp;</td>
                                                <td style="width:15%; ">&nbsp;Çıkış Tutarı</td>
                                                <td style="width:16%; font-weight:bold; text-align:right">#TlFormat(toplam_cikan_miktar,2)#&nbsp;</td>
                                                <td style="width:15%; ">&nbsp;</td>
                                                <td style="width:16%; font-weight:bold; text-align:right">&nbsp;</td>
                                            </tr>
                                        </cfoutput>
                            		</table>
                              	</td>
                          	</tr>
                        </tfoot> 
					<cfelse>
						<tbody>
							<tr>
								<td colspan="15"><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</td>
							</tr>
						</tbody>
					</cfif>
			</cf_grid_list>
	</cfform>
	<cfif attributes.totalrecords gt attributes.maxrows>
		<cfif len(attributes.startdate)>
			<cfset adres = "#adres#&startdate=#attributes.startdate#">
		</cfif>
		<cfif len(attributes.finishdate)>
			<cfset adres = "#adres#&finishdate=#attributes.finishdate#">
		</cfif>
		<cfif len(attributes.department_id)>
			<cfset adres = "#adres#&department_id=#attributes.department_id#">
		</cfif>
		<cfif isdefined("attributes.location_id") and len(attributes.location_id)>
			<cfset adres = "#adres#&location_id=#attributes.location_id#">
		</cfif>
		<cfif isdefined("attributes.location_name") and len(attributes.location_name)>
			<cfset adres = "#adres#&location_name=#attributes.location_name#">
		</cfif>
		<cfif isdefined('attributes.pid') and len(attributes.product_name)>
			<cfset attributes.product_name = replace(attributes.product_name,'=','')>
			<cfset adres = "#adres#&product_name=#attributes.product_name#">
			<cfset adres = "#adres#&pid=#attributes.pid#">
			<cfset adres = "#adres#&stock_id=#attributes.stock_id#">
		</cfif>
		<cf_paging 
			page="#attributes.page#"
			maxrows="#attributes.maxrows#"
			totalrecords="#attributes.totalrecords#"
			startrow="#attributes.startrow#"
			adres="#adres#"
			isAjax="#iif(isdefined("attributes.draggable"),1,0)#">
	</cfif>
	<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
</cf_box>

<script type="text/javascript">
	function input_control()
	{
		return true;
	}
</script>
