<cfset fuseaction_ = ListGetAt(attributes.fuseaction,2,'.')>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.collect_type" default="">
<cfif isdefined("attributes.date2") and isdate(attributes.date2)>
  <cf_date tarih="attributes.date2">
  <cfelse>
  <cfset attributes.date2 = wrk_get_today()>
</cfif>
<cfif isdefined("attributes.date1") and isdate(attributes.date1)>
  <cf_date tarih="attributes.date1">
  <cfelse>
  <cfset attributes.date1 = wrk_get_today()>
</cfif>
<cfquery name="get_default_departments" datasource="#dsn3#">
	SELECT 
    	INTERMEDIATE_WAREHOUSE, 
        PRODUCTION_WAREHOUSE,
        SHELF_WAREHOUSE,
        FIRST_SHELF_ID,
        SHIPMENT_WAREHOUSE
	FROM     
    	EZGI_WM_SETUP_ROW
	WHERE  
    	EMPLOYEE_POSITION_ID = #session.ep.POSITION_CODE#
</cfquery>
<cfif not get_default_departments.recordcount or not len(get_default_departments.SHELF_WAREHOUSE) or not len(get_default_departments.SHIPMENT_WAREHOUSE)>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
</cfif>
<cfparam name="attributes.depo" default="#Replace(get_default_departments.SHIPMENT_WAREHOUSE,',','-')#">

<cfparam name="attributes.page" default=1>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
	  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfscript>
	get_shipment.recordcount=0;
	get_shipment.query_count=0;
	if (isdefined("attributes.is_submitted"))
	{
		get_pallet_list_action = createObject("component", "addOns.ezgi.cfc.get_ezgi_pallets_to_shipment_warehouse");
		get_pallet_list_action.dsn3 = dsn3;
		get_pallet_list_action.dsn_alias = dsn_alias;
		get_shipment = get_pallet_list_action.get_shipment_
		(
		 	dsn_alias : '#dsn_alias#',
			dsn2_alias : '#dsn2_alias#',
			collect_type : '#iif(isdefined("attributes.collect_type"),"attributes.collect_type",DE(""))#',
			keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
			depo : '#IIf(IsDefined("attributes.depo"),"attributes.depo",DE(""))#',
			date1 : '#IIf(IsDefined("attributes.date1"),"attributes.date1",DE(""))#',
			date2 : '#IIf(IsDefined("attributes.date2"),"attributes.date2",DE(""))#',
		 	startrow : '#iif(isdefined("attributes.startrow"),"attributes.startrow",DE(""))#',
			maxrows : '#iif(isdefined("attributes.maxrows"),"attributes.maxrows",DE(""))#'
		);
		arama_yapilmali=0;
		}
	else
	{
		arama_yapilmali=1;
	}
</cfscript>
<cfif get_shipment.recordcount>
    <cfquery name="get_plan_id" dbtype="query">
        SELECT SHIP_RESULT_ID FROM get_shipment WHERE IS_TYPE =1
    </cfquery>
    <cfset sevk_plan_id_list = ValueList(get_plan_id.SHIP_RESULT_ID)>
    <cfquery name="get_plan_id" dbtype="query">
        SELECT SHIP_RESULT_ID FROM get_shipment WHERE IS_TYPE =2
    </cfquery>
    <cfset sevk_talep_id_list = ValueList(get_plan_id.SHIP_RESULT_ID)>
    <cfif Listlen(sevk_plan_id_list)>
		<cfquery name="GET_PLAN_SEVK" datasource="#DSN3#">
       		SELECT     
          		ISNULL(SUM(PAKETSAYISI), 0) AS PAKET_SAYISI, 
          		ISNULL(SUM(CONTROL_AMOUNT), 0) AS CONTROL_AMOUNT,
          		SHIP_RESULT_ID
    		FROM         
          		(
          		SELECT     
          		    PAKET_SAYISI AS PAKETSAYISI, 
          		    PAKET_ID AS STOCK_ID, 
          		    BARCOD, 
          		    STOCK_CODE, 
          		    PRODUCT_NAME,
          		    SHIP_RESULT_ID,
          		    (
                	SELECT     
                   		SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                   	FROM          
                   		EZGI_SHIPPING_PACKAGE_LIST WITH (NOLOCK)
                   	WHERE      
                   		TYPE = 1 AND 
                   		STOCK_ID = TBL.PAKET_ID AND 
                   		SHIPPING_ID = TBL.SHIP_RESULT_ID
              		) AS CONTROL_AMOUNT
          		FROM         
          		    (
          		    SELECT
          		        SUM(PAKET_SAYISI) AS PAKET_SAYISI,
          		        PAKET_ID, 
          		        BARCOD, 
          		        STOCK_CODE, 
          		        PRODUCT_NAME, 
          		        SHIP_RESULT_ID
          		    FROM
          		        (     
          		        SELECT     
          		            round(SUM(ORR.QUANTITY * EPS.PAKET_SAYISI),2) AS PAKET_SAYISI, 
          		            EPS.PAKET_ID, 
          		            S.BARCOD, 
          		            S.STOCK_CODE, 
          		            S.PRODUCT_NAME, 
          		            ESR.SHIP_RESULT_ID,
          		            ESRR.ORDER_ROW_ID
          		        FROM 
          		            SPECTS AS SP WITH (NOLOCK) INNER JOIN
          		            EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
          		            EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
          		            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
          		            STOCKS AS S WITH (NOLOCK) INNER JOIN
          		            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID INNER JOIN
          		            STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID   
          		        WHERE      
          		            ESR.SHIP_RESULT_ID IN (#sevk_plan_id_list#) AND
          		            ISNULL(S1.IS_PROTOTYPE,0) = 1
          		        GROUP BY 
          		            EPS.PAKET_ID, 
          		            S.BARCOD, 
          		            S.STOCK_CODE, 
          		            S.PRODUCT_NAME, 
          		            ESR.SHIP_RESULT_ID,
          		            ESRR.ORDER_ROW_ID
          		        UNION ALL
          		        SELECT     
          		            round(SUM(ORR.QUANTITY * EPS.PAKET_SAYISI),2) AS PAKET_SAYISI, 
          		            EPS.PAKET_ID, 
          		            S.BARCOD, 
          		            S.STOCK_CODE, 
          		            S.PRODUCT_NAME, 
          		            ESR.SHIP_RESULT_ID,
          		            ESRR.ORDER_ROW_ID
          		        FROM          
          		            EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
          		            EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
          		            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
          		            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
          		            STOCKS AS S WITH (NOLOCK) ON EPS.PAKET_ID = S.STOCK_ID INNER JOIN
          		            STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID
          		        WHERE      
          		            ESR.SHIP_RESULT_ID IN (#sevk_plan_id_list#) AND
          		            ISNULL(S1.IS_PROTOTYPE,0) = 0
          		        GROUP BY 
          		            EPS.PAKET_ID, 
          		            S.BARCOD, 
          		            S.STOCK_CODE, 
          		            S.PRODUCT_NAME, 
          		            ESR.SHIP_RESULT_ID,
          		            ESRR.ORDER_ROW_ID
          		        ) AS TBL1
          		    GROUP BY
          		        PAKET_ID, 
          		        BARCOD, 
          		        STOCK_CODE, 
          		        PRODUCT_NAME,
          		        SHIP_RESULT_ID
          		    ) AS TBL
          		) AS TBL2
        	GROUP BY
            	SHIP_RESULT_ID
        </cfquery>
	<cfelse>
    	<cfset GET_PLAN_SEVK.recordcount =0>
    </cfif>
    <cfif Listlen(sevk_talep_id_list)>
    	<cfquery name="GET_TALEP_SEVK" datasource="#DSN3#">
        	SELECT     
          		ISNULL(SUM(PAKETSAYISI), 0) AS PAKET_SAYISI, 
          		ISNULL(SUM(CONTROL_AMOUNT), 0) AS CONTROL_AMOUNT,
          		SHIP_RESULT_ID
    		FROM         
          		(
          		SELECT     
          		    PAKET_SAYISI AS PAKETSAYISI, 
          		    PAKET_ID AS STOCK_ID, 
          		    BARCOD, 
          		    STOCK_CODE, 
          		    PRODUCT_NAME,
          		    SHIP_RESULT_ID,
          		    (
                	SELECT     
                   		SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                   	FROM          
                   		EZGI_SHIPPING_PACKAGE_LIST WITH (NOLOCK)
                   	WHERE      
                   		TYPE = 2 AND 
                   		STOCK_ID = TBL.PAKET_ID AND 
                   		SHIPPING_ID = TBL.SHIP_RESULT_ID
              		) AS CONTROL_AMOUNT
          		FROM         
          		    (
          		    SELECT
          		        SUM(PAKET_SAYISI) AS PAKET_SAYISI,
          		        PAKET_ID, 
          		        BARCOD, 
          		        STOCK_CODE, 
          		        PRODUCT_NAME, 
          		        SHIP_RESULT_ID
          		    FROM
          		        (     
          		        SELECT     
          		            round(SUM(ORR.QUANTITY * EPS.PAKET_SAYISI),2) AS PAKET_SAYISI, 
          		            EPS.PAKET_ID, 
          		            S.BARCOD, 
          		            S.STOCK_CODE, 
          		            S.PRODUCT_NAME, 
          		            ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID,
          		            ESRR.ORDER_ROW_ID
          		        FROM 
          		            SPECTS AS SP WITH (NOLOCK) INNER JOIN
          		            EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN
          		            EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
          		            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
          		            STOCKS AS S WITH (NOLOCK) INNER JOIN
          		            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID INNER JOIN
          		            STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID   
          		        WHERE      
          		            ESR.SHIP_RESULT_INTERNALDEMAND_ID IN (#sevk_talep_id_list#) AND
          		            ISNULL(S1.IS_PROTOTYPE,0) = 1
          		        GROUP BY 
          		            EPS.PAKET_ID, 
          		            S.BARCOD, 
          		            S.STOCK_CODE, 
          		            S.PRODUCT_NAME, 
          		            ESR.SHIP_RESULT_INTERNALDEMAND_ID,
          		            ESRR.ORDER_ROW_ID
          		        UNION ALL
          		        SELECT     
          		            round(SUM(ORR.QUANTITY * EPS.PAKET_SAYISI),2) AS PAKET_SAYISI, 
          		            EPS.PAKET_ID, 
          		            S.BARCOD, 
          		            S.STOCK_CODE, 
          		            S.PRODUCT_NAME, 
          		            ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID,
          		            ESRR.ORDER_ROW_ID
          		        FROM          
          		            EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN
          		            EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
          		            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
          		            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
          		            STOCKS AS S WITH (NOLOCK) ON EPS.PAKET_ID = S.STOCK_ID INNER JOIN
          		            STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID
          		        WHERE      
          		            ESR.SHIP_RESULT_INTERNALDEMAND_ID IN (#sevk_talep_id_list#) AND
          		            ISNULL(S1.IS_PROTOTYPE,0) = 0
          		        GROUP BY 
          		            EPS.PAKET_ID, 
          		            S.BARCOD, 
          		            S.STOCK_CODE, 
          		            S.PRODUCT_NAME, 
          		            ESR.SHIP_RESULT_INTERNALDEMAND_ID,
          		            ESRR.ORDER_ROW_ID
          		        ) AS TBL1
          		    GROUP BY
          		        PAKET_ID, 
          		        BARCOD, 
          		        STOCK_CODE, 
          		        PRODUCT_NAME,
          		        SHIP_RESULT_ID
          		    ) AS TBL
          		) AS TBL2
        	GROUP BY
            	SHIP_RESULT_ID
  		</cfquery>
    <cfelse>
    	<cfset GET_TALEP_SEVK.recordcount =0>
    </cfif>
</cfif>
<cfparam name="attributes.totalrecords" default='#get_shipment.query_count#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search_list" action="#request.self#?fuseaction=#attributes.fuseaction#" method="post">
        	<input type="hidden" name="is_submitted" id="is_submitted" value="1">
            <cf_box_search>
				<cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group">
                 	<div class="input-group">
                     	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                      	<cfinput type="text" maxlength="10" name="date1" value="#dateformat(attributes.date1,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                      	<span class="input-group-addon"><cf_wrk_date_image date_field="date1"></span>
                  	</div>
                  	<div class="input-group">
                     	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                     	<cfinput type="text" maxlength="10" name="date2" value="#dateformat(attributes.date2,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                    	<span class="input-group-addon"><cf_wrk_date_image date_field="date2"></span>
               		</div>
               	</div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="3">
                </div>
          	</cf_box_search>
      	</cfform>
    </cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='1315.Sevkiyata Transfer İşlemi'></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
     	<cf_grid_list>
        	<thead>
            	<tr>
                	<th style="width:25px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th><cf_get_lang dictionary_id='57880.Belge No'></th>
                    <th><cf_get_lang dictionary_id='58061.Cari'></th>
                    <th><cf_get_lang dictionary_id='1316.Sevkiyat Alanı'></th>
                    <!-- sil -->
                    <th style="width:25px;" class="header_icn_none"></th>
                   	<!-- sil -->
              	</tr>
         	</thead>
          	<tbody>
            	<cfif get_shipment.recordcount>
                    <cfoutput query="get_shipment">
                        <cfset url_param = "#request.self#?fuseaction=stock.list_ezgi_pallets_to_shipment_warehouse&event=add&depo=#attributes.depo#&keyword=#attributes.keyword#&date1=#dateformat(attributes.date1,dateformat_style)#&date2=#dateformat(attributes.date2,dateformat_style)#&DELIVER_PAPER_NO=#DELIVER_PAPER_NO#&is_type=#IS_TYPE#&ship_id=#SHIP_RESULT_ID#">
                        <tr height="30px">
                        	<td style="text-align:right">#currentrow#</td>
                           <cfquery name="get_url" datasource="#dsn#">
                                SELECT     
                                    E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS ADI,
                                    E.EMPLOYEE_ID
                                FROM         
                                    WRK_SESSION AS W INNER JOIN
                                    EMPLOYEES AS E ON W.USERID = E.EMPLOYEE_ID
                                WHERE   
                                    W.PERIOD_ID = #session.ep.period_id# AND
                                    W.ACTION_PAGE LIKE '#fuseaction#%' AND 
                                    W.ACTION_PAGE LIKE N'%ship_id=#SHIP_RESULT_ID#%'
                            </cfquery>
                            <cfif get_url.recordcount>
                                <td>#DELIVER_PAPER_NO#</td>
                                <td>
                                    <cfif IS_TYPE eq 1> 
                                        #left(unvan,25)#<cfif len(unvan) gt 25>...</cfif>
                                    <cfelse>
                                    	#left(DEPARTMENT_HEAD,25)#<cfif len(DEPARTMENT_HEAD) gt 25>...</cfif>
                                    </cfif>     
                                </td>
                                <td>#SHELF_CODE#</td>
                            <cfelse>
                                <td>
                                	<a href="#url_param#&is_reserve=0"class="tableyazi">#DELIVER_PAPER_NO#</a>
                                </td>
                                <td>
                                    <cfif IS_TYPE eq 1> 
                                        #left(unvan,25)#<cfif len(unvan) gt 25>...</cfif>
                                    <cfelse>
                                    	#left(DEPARTMENT_HEAD,25)#<cfif len(DEPARTMENT_HEAD) gt 25>...</cfif>
                                    </cfif>      
                                </td>
                                <td>#SHELF_CODE#</td>
                                <!-- sil -->
                                <cfif IS_TYPE eq 1>    
                                    <cfquery name="PACKEGE_CONTROL" dbtype="query"><!---Sevk Kontrol Indicator için Kalan Bul---> 
                                        SELECT
                                            PAKET_SAYISI,
                                            CONTROL_AMOUNT
                                        FROM
                                            GET_PLAN_SEVK
                                        WHERE     
                                            SHIP_RESULT_ID = #SHIP_RESULT_ID#
                                    </cfquery>
                                <cfelse>
                                   	<cfquery name="PACKEGE_CONTROL" dbtype="query"><!---Sevk Kontrol Indicator için Kalan Bul---> 
                                        SELECT
                                            PAKET_SAYISI,
                                            CONTROL_AMOUNT
                                        FROM
                                            GET_TALEP_SEVK
                                        WHERE     
                                            SHIP_RESULT_ID = #SHIP_RESULT_ID#
                                    </cfquery> 
                                </cfif>
                          		<td align="center">
								 <cfif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI eq 0 and PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
                                    <img src="/images/plus_ques.gif" border="0" title="<cf_get_lang dictionary_id='29975.Barkod Yok'>">
                                 <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI - PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
                                    <img src="/images/c_ok.gif" border="0" title="<cf_get_lang dictionary_id='334.Sevk Edildi'>.">
                                 <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
                                    <img src="/images/caution_small.gif" border="0" title="<cf_get_lang dictionary_id='335.Sevk Edilmedi'>.">
                                 <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI gt PACKEGE_CONTROL.CONTROL_AMOUNT>
                                    <img src="/images/warning.gif" border="0" title="<cf_get_lang dictionary_id='336.Eksik Sevkiyat'>.">
                                 <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI lt PACKEGE_CONTROL.CONTROL_AMOUNT>
                                    <img src="/images/control.gif" border="0" title="<cf_get_lang dictionary_id='337.Fazla Sevkiyat'>">  
                                 </cfif>
                        		</td>
                            <!-- sil -->
                            </cfif>
                        </tr>
                    </cfoutput>
            	<cfelse>
               		<tr> 
                    	<td colspan="10" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
                 	</tr>
             	</cfif>
         	</tbody>
      	</cf_grid_list>
        <cfset adres = url.fuseaction>
        <cfif isDefined('attributes.depo') and len(attributes.depo)>
        	<cfset adres = adres & '&depo=' & attributes.depo>
      	</cfif>
        <cfif isDefined('attributes.department_out_id') and len(attributes.department_out_id)>
        	<cfset adres = adres & '&department_out_id=' & attributes.department_out_id>
      	</cfif>
   		<cfif isdate(attributes.date1)>
        	<cfset adres = "#adres#&date1=#dateformat(attributes.date1,dateformat_style)#">
      	</cfif>
    	<cfif isdate(attributes.date2)>
        	<cfset adres = "#adres#&date2=#dateformat(attributes.date2,dateformat_style)#">
     	</cfif>
       	<cfif isDefined('attributes.keyword') and len(attributes.keyword) >
        	<cfset adres = "#adres#&keyword=#attributes.keyword#" >
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
</script>