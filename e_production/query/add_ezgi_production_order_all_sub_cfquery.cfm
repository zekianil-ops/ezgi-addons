<!---
    File: add_ezgi_production_order_all_sub.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---Ezgi Bilgisayar Özelleştirme ZAG - 08/01/2019--->
<!---<cfdump var = "#attributes#"><cfabort>--->
<cfset attributes.IS_SELECT_SUB_PRODUCT = 1>
<cfif not isdefined("is_import_prod")>
    <table border="1">
    <tr>
        <td><cfif attributes.is_demand eq 1><cf_get_lang dictionary_id='57527.Talepler'> <cfelse><cf_get_lang dictionary_id='649.Üretim Emirleri'></cfif><cf_get_lang dictionary_id='650.Oluşturuluyor..Lütfen Bekleyiniz...'></td>
    </tr>
    <cfflush interval="1000">
</cfif>
<cfset new_keyword_ = "">
<cfif isdefined("attributes.is_manuel")>
    <cfquery name="GET_W" datasource="#dsn3#">
        SELECT 
            STATION_ID,
            STATION_NAME,
            ISNULL(EXIT_DEP_ID,0) AS EXIT_DEP_ID,
            ISNULL(EXIT_LOC_ID,0) AS EXIT_LOC_ID,
            ISNULL(PRODUCTION_DEP_ID,0) AS PRODUCTION_DEP_ID,
            ISNULL(PRODUCTION_LOC_ID,0) AS PRODUCTION_LOC_ID
        FROM 
            WORKSTATIONS 
        ORDER BY 
            STATION_NAME ASC
    </cfquery>
    <cfloop query="GET_W">
		<cfset 'EXIT_DEP_ID_#STATION_ID#' = EXIT_DEP_ID>
		<cfset 'EXIT_LOC_ID_#STATION_ID#' = EXIT_LOC_ID>
		<cfset 'PRODUCTION_DEP_ID_#STATION_ID#' = PRODUCTION_DEP_ID>
		<cfset 'PRODUCTION_LOC_ID_#STATION_ID#' = PRODUCTION_LOC_ID>
    </cfloop>
    <cfscript>
		GET_AMOUNT = QueryNew("ORDER_NUMBER,ORDER_DETAIL,SPEC_MAIN_ID,SPECT_VAR_ID,DELIVER_DATE,STOCK_ID,PRODUCT_NAME,IS_PROTOTYPE,ORDER_ROW_ID,ORDER_ID,PROJECT_ID,KONTROL_ORDER,ROW_NO,WRK_ROW_RELATION_ID","VarChar,VarChar,integer,integer,Date,integer,VarChar,integer,integer,integer,integer,integer,integer,VarChar");
		row_of_query = 0;
		attributes.ORDER_ROW_ID = '';
		attributes.ORDER_ROW_ID_LIST = '';
		attributes.STATION_ID_LIST = '';
		attributes.production_amount_list = '';
		attributes.WORKS_PROG_ID_LIST = '';
		attributes.PRODUCTION_START_DATE_LIST = '';
		attributes.PRODUCTION_START_H_LIST = '';
		attributes.PRODUCTION_START_M_LIST = '';
		attributes.PRODUCTION_FINISH_DATE_LIST = '';
		attributes.PRODUCTION_FINISH_H_LIST = '';
		attributes.PRODUCTION_FINISH_M_LIST = '';
		attributes.DEMAND_NO_LIST = '';
		attributes.WRK_ROW_RELATION_ID_LIST = '';
    </cfscript>
	<cfloop from="1" to="#attributes.record_num#" index="kk">
    	<cfif evaluate("attributes.row_kontrol#kk#")>
             <cfscript>
			 	if(not isdefined("attributes.demand_no#kk#")) "attributes.demand_no#kk#" = '';
			 	if(not isdefined("attributes.wrk_row_relation_id#kk#")) "attributes.wrk_row_relation_id#kk#" = '';
			 	if(len(evaluate("attributes.order_row_id#kk#")))
				{
					row_order_id = evaluate("attributes.order_row_id#kk#");
					order_id = evaluate("attributes.order_id#kk#");
					kontrol_order = 1;
				}
				else
				{
					row_order_id = 1;
					order_id = 1;
					kontrol_order = 0;
				}
			 	row_of_query = row_of_query + 1;
			 	attributes.ORDER_ROW_ID = ListAppend(attributes.ORDER_ROW_ID,row_order_id,',');
			 	attributes.ORDER_ROW_ID_LIST = ListAppend(attributes.ORDER_ROW_ID_LIST,"#row_order_id##kk#",',');
				if(not (isdefined("attributes.station_id_#kk#_0") and len(evaluate("attributes.station_id_#kk#_0"))))
				{
					"attributes.station_id_#kk#_0" = 0;
				}
				if(evaluate("attributes.station_id_#kk#_0") neq 0)
				{
					exit_dep_id = Evaluate('EXIT_DEP_ID_#evaluate("attributes.station_id_#kk#_0")#');
					exit_loc_id = Evaluate('EXIT_LOC_ID_#evaluate("attributes.station_id_#kk#_0")#');
					production_dep_id = Evaluate('PRODUCTION_DEP_ID_#evaluate("attributes.station_id_#kk#_0")#');
					production_loc_id = Evaluate('PRODUCTION_LOC_ID_#evaluate("attributes.station_id_#kk#_0")#');
				}
				else
				{
					exit_dep_id = 0;
					exit_loc_id = 0;
					production_dep_id = 0;
					production_loc_id = 0;
				}	
				attributes.STATION_ID_LIST = ListAppend(attributes.STATION_ID_LIST,"#evaluate("attributes.station_id_#kk#_0")#,0,0,0,-1,#exit_dep_id#,#exit_loc_id#,#production_dep_id#,#production_loc_id#",'@');
				attributes.production_amount_list = ListAppend(attributes.production_amount_list,evaluate("attributes.quantity#kk#"),',');
				attributes.WORKS_PROG_ID_LIST = ListAppend(attributes.WORKS_PROG_ID_LIST,0,',');
				attributes.PRODUCTION_START_DATE_LIST = ListAppend(attributes.PRODUCTION_START_DATE_LIST,evaluate("attributes.start_date#kk#"),',');
				attributes.PRODUCTION_START_H_LIST = ListAppend(attributes.PRODUCTION_START_H_LIST,evaluate("attributes.start_h#kk#"),',');
				attributes.PRODUCTION_START_M_LIST = ListAppend(attributes.PRODUCTION_START_M_LIST,evaluate("attributes.start_m#kk#"),',');
				attributes.PRODUCTION_FINISH_DATE_LIST = ListAppend(attributes.PRODUCTION_FINISH_DATE_LIST,evaluate("attributes.finish_date#kk#"),',');
				attributes.PRODUCTION_FINISH_H_LIST = ListAppend(attributes.PRODUCTION_FINISH_H_LIST,evaluate("attributes.finish_h#kk#"),',');
				attributes.PRODUCTION_FINISH_M_LIST = ListAppend(attributes.PRODUCTION_FINISH_M_LIST,evaluate("attributes.finish_m#kk#"),',');
				attributes.DEMAND_NO_LIST = ListAppend(attributes.DEMAND_NO_LIST,evaluate("attributes.demand_no#kk#"),',');
				attributes.WRK_ROW_RELATION_ID_LIST = ListAppend(attributes.WRK_ROW_RELATION_ID_LIST,evaluate("attributes.wrk_row_relation_id#kk#"),',');
				QueryAddRow(GET_AMOUNT,1);
				QuerySetCell(GET_AMOUNT,"ORDER_NUMBER","",row_of_query);
				QuerySetCell(GET_AMOUNT,"ORDER_DETAIL","",row_of_query);
				QuerySetCell(GET_AMOUNT,"SPEC_MAIN_ID","#evaluate("attributes.spect_main_id#kk#")#",row_of_query);
				QuerySetCell(GET_AMOUNT,"SPECT_VAR_ID","#evaluate("attributes.spect_var_id#kk#")#",row_of_query);
				QuerySetCell(GET_AMOUNT,"DELIVER_DATE","#evaluate("attributes.finish_date#kk#")#",row_of_query);
				QuerySetCell(GET_AMOUNT,"STOCK_ID","#evaluate("attributes.stock_id#kk#")#",row_of_query);
				QuerySetCell(GET_AMOUNT,"PRODUCT_NAME","#evaluate("attributes.product_name#kk#")#",row_of_query);
				QuerySetCell(GET_AMOUNT,"IS_PROTOTYPE","",row_of_query);
				QuerySetCell(GET_AMOUNT,"ORDER_ROW_ID",row_order_id,row_of_query);
				QuerySetCell(GET_AMOUNT,"ORDER_ID",order_id,row_of_query);
				QuerySetCell(GET_AMOUNT,"PROJECT_ID",attributes.project_id,row_of_query);
				QuerySetCell(GET_AMOUNT,"KONTROL_ORDER",kontrol_order,row_of_query);
				QuerySetCell(GET_AMOUNT,"ROW_NO",kk,row_of_query);
				QuerySetCell(GET_AMOUNT,"WRK_ROW_RELATION_ID","#evaluate("attributes.wrk_row_relation_id#kk#")#",row_of_query);
			</cfscript>
		</cfif>
    </cfloop>
<cfelse>
	<cfquery name="GET_AMOUNT" datasource="#DSN3#">
        SELECT
            ORDERS.ORDER_NUMBER,
            ORDERS.ORDER_DETAIL,
            (SELECT SPECT_MAIN_ID FROM SPECTS WHERE SPECTS.SPECT_VAR_ID = ORDER_ROW.SPECT_VAR_ID) AS SPEC_MAIN_ID,
            ORDER_ROW.SPECT_VAR_ID,
            ORDERS.DELIVERDATE AS DELIVER_DATE,
            ORDER_ROW.STOCK_ID,
            STOCKS.PRODUCT_NAME,
            STOCKS.IS_PROTOTYPE,
            ORDER_ROW.ORDER_ROW_ID,
            ORDER_ROW.ORDER_ID,
            ORDERS.PROJECT_ID,
			1 AS KONTROL_ORDER,
			WRK_ROW_ID WRK_ROW_RELATION_ID
        FROM
            ORDER_ROW,
            ORDERS,
            STOCKS
        WHERE 
            ORDER_ROW.ORDER_ROW_ID IN(#attributes.order_row_id#)AND
            ORDER_ROW.ORDER_ID = ORDERS.ORDER_ID AND
            STOCKS.STOCK_ID = ORDER_ROW.STOCK_ID AND 
            ORDER_ROW.SPECT_VAR_ID IS NOT NULL
    </cfquery>
</cfif>
<cfscript>
    deep_level = 0;
    deep_level_p = 0;
    function get_subs(spect_main_id,production_tree_id,type)
    {
		SQLStr = "
		SELECT * FROM
		(
			SELECT
					S.STOCK_CODE,
					ISNULL(S.IS_PURCHASE,0) IS_PURCHASE,
					ISNULL(S.IS_PRODUCTION,0)IS_PRODUCTION,
					ISNULL(SMR.RELATED_MAIN_SPECT_ID,0)AS RELATED_ID,
					SMR.STOCK_ID,
					SMR.AMOUNT,
					S.PRODUCT_NAME,
					ISNULL(SMR.IS_PHANTOM,0) AS IS_PHANTOM,
					ISNULL(SMR.LINE_NUMBER,0) AS LINE_NUMBER,
					0 AS OPERATION_TYPE_ID,
					ISNULL(RELATED_TREE_ID,0) AS RELATED_TREE_ID
				FROM 
					SPECT_MAIN_ROW SMR,
					STOCKS S
				WHERE 
					S.STOCK_ID = SMR.STOCK_ID AND
					SPECT_MAIN_ID = #spect_main_id# AND 
					SMR.STOCK_ID IS NOT NULL AND
					ISNULL(S.IS_ADD_XML,0) = 0 AND --SADECE üretim emri oluşturulacaklar gelsin - Ezgi Bilgisayar Özelleştirme Satırı
					IS_PROPERTY IN (0,4) --SADECE SARFLAR GELSİN
			UNION ALL
				SELECT 
					'&nbsp;' AS STOCK_CODE,
					0 AS IS_PURCHASE,
					0 AS IS_PRODUCTION,
					0 AS RELATED_ID,
					0 AS STOCK_ID,
					1 AS AMOUNT,
					'<font color=purple>'+OP.OPERATION_TYPE+'</font>'  AS PRODUCT_NAME,
					ISNULL(SMR.IS_PHANTOM,0) AS IS_PHANTOM,
					ISNULL(SMR.LINE_NUMBER,0) AS LINE_NUMBER,
					ISNULL(OP.OPERATION_TYPE_ID,0) AS OPERATION_TYPE_ID,
					ISNULL(SMR.RELATED_TREE_ID,0) AS RELATED_TREE_ID
				FROM 
					OPERATION_TYPES OP,
					SPECT_MAIN_ROW SMR
				WHERE
					OP.OPERATION_TYPE_ID = SMR.OPERATION_TYPE_ID AND 
					SPECT_MAIN_ID = #spect_main_id# AND 
					OP.OPERATION_TYPE_ID IS NOT NULL AND
					IS_PROPERTY IN(3,4) -- OPERASYONLAR GELSİN
		) TABLE_1
		ORDER BY
			LINE_NUMBER,
			STOCK_ID DESC,
			PRODUCT_NAME
		";
        query1 = cfquery(SQLString : SQLStr, Datasource : dsn3);
        stock_id_ary='';
        for (str_i=1; str_i lte query1.recordcount; str_i = str_i+1)
        {
            stock_id_ary=listappend(stock_id_ary,query1.RELATED_ID[str_i],'█');
            stock_id_ary=listappend(stock_id_ary,query1.STOCK_ID[str_i],'§');
            stock_id_ary=listappend(stock_id_ary,query1.AMOUNT[str_i],'§');
            stock_id_ary=listappend(stock_id_ary,query1.IS_PRODUCTION[str_i],'§');
            stock_id_ary=listappend(stock_id_ary,query1.IS_PHANTOM[str_i],'§');
            stock_id_ary=listappend(stock_id_ary,query1.RELATED_TREE_ID[str_i],'§');
            stock_id_ary=listappend(stock_id_ary,query1.OPERATION_TYPE_ID[str_i],'§');
            stock_id_ary=listappend(stock_id_ary,query1.PRODUCT_NAME[str_i],'§');
        }
        return stock_id_ary;
    }
    function writeTree(next_spect_main_id,production_tree_id,type,is_phantom)
    {
        var i = 1;
        var sub_products = get_subs(next_spect_main_id,production_tree_id,type);
        deep_level = deep_level + 1;
		if(is_phantom neq 1)
        	deep_level_p = deep_level_p + 1;
		if(deep_level gt 50) abort("Sipariş : [#_ORDER_NUMBER_#] Spec : [#next_spect_main_id#] 50 Kırılımdan Fazla Bir Ürün Ağacı Varmış Gibi Görünüyor...");
        for (i=1; i lte listlen(sub_products,'█'); i = i+1)
        {
            _next_spect_main_id_ = ListGetAt(ListGetAt(sub_products,i,'█'),1,'§');//alt+987 = █ --//alt+789 = §
            _next_stock_id_ = ListGetAt(ListGetAt(sub_products,i,'█'),2,'§');
            _next_stock_amount_ = ListGetAt(ListGetAt(sub_products,i,'█'),3,'§');
            _next_is_production_ = ListGetAt(ListGetAt(sub_products,i,'█'),4,'§');
            _next_is_phantom_ = ListGetAt(ListGetAt(sub_products,i,'█'),5,'§');
            _next_related_tree_id_ = ListGetAt(ListGetAt(sub_products,i,'█'),6,'§');
            _next_operation_type_id_ = ListGetAt(ListGetAt(sub_products,i,'█'),7,'§');	
            //nnnnn = ListGetAt(ListGetAt(sub_products,i,'█'),8,'§');	
			//writeoutput("#deep_level_p#___#nnnnn#<br>");
            //tanımlamalar
                if(deep_level eq 1)
                    'product_amount_#prod_ind#_#deep_level#' = '#attributes.order_amount#*#_next_stock_amount_#';// satır bazında malzeme ihtiyaçları
                else
                    'product_amount_#prod_ind#_#deep_level#' = '#Evaluate('product_amount_#prod_ind#_#deep_level-1#')#*#_next_stock_amount_#';
                if(_next_is_production_ eq 1 and _next_is_phantom_ eq 0)//eğer ürünümüz üretilen bir ürün ise bağlı bulunduğu istasyonu bu ürünün ağacından alıyoruz
                {
                    production_row_count = production_row_count+1;
                    "attributes.product_values_#prod_ind#_#production_row_count#" = "#_next_stock_id_#,#_next_spect_main_id_#,#deep_level#,#production_row_count#";
                    "attributes.product_amount_#prod_ind#_#production_row_count#"  = Evaluate(Evaluate("product_amount_#prod_ind#_#deep_level#"));
					SQL_PRODUCT_STATION_ID ='SELECT WS_P_ID,STATION_ID,STATION_NAME,PRODUCTION_TYPE,MIN_PRODUCT_AMOUNT,SETUP_TIME,ISNULL(WS.EXIT_DEP_ID,0) AS EXIT_DEP_ID,ISNULL(WS.EXIT_LOC_ID,0) AS EXIT_LOC_ID,ISNULL(WS.PRODUCTION_DEP_ID,0) AS PRODUCTION_DEP_ID,ISNULL(WS.PRODUCTION_LOC_ID,0) AS PRODUCTION_LOC_ID FROM WORKSTATIONS_PRODUCTS WSP,WORKSTATIONS WS WHERE WS.STATION_ID = WSP.WS_ID AND WSP.STOCK_ID = #_next_stock_id_#';
					GET_PRODUCT_STATION_ID = cfquery(SQLString : SQL_PRODUCT_STATION_ID, Datasource : dsn3);
					if(GET_PRODUCT_STATION_ID.recordcount)
	                    "attributes.station_id_#prod_ind#_#production_row_count#" = "#GET_PRODUCT_STATION_ID.STATION_ID#,0,1,1,0,#GET_PRODUCT_STATION_ID.EXIT_DEP_ID#,#GET_PRODUCT_STATION_ID.EXIT_LOC_ID#,#GET_PRODUCT_STATION_ID.PRODUCTION_DEP_ID#,#GET_PRODUCT_STATION_ID.PRODUCTION_LOC_ID#";//elle verildi düzeltilecek..
					else
						"attributes.station_id_#prod_ind#_#production_row_count#" = "0,0,1,1,0,0,0,0,0";//elle verildi düzeltilecek..
					if(isdefined("attributes.is_select_sub_product") and attributes.is_select_sub_product == 1)
                    "attributes.product_is_production_#prod_ind#_#production_row_count#" = 1;
                }
            //tanımlamalar bitti
			if((isdefined("attributes.stage_info") and len(attributes.stage_info) and attributes.stage_info gt 0 and deep_level lt attributes.stage_info) or not (isdefined("attributes.stage_info") and len(attributes.stage_info)))
			{
				if(_next_spect_main_id_ gt 0 and _next_is_production_ eq 1 and _next_stock_id_ gt 0)
				{
					writeTree(_next_spect_main_id_,0,0,_next_is_phantom_);
				}	
				else if	(_next_related_tree_id_ gt 0 and _next_operation_type_id_ gt 0){
					writeTree(_next_spect_main_id_,_next_related_tree_id_,3,_next_is_phantom_);
				}
			}
         }
        deep_level = deep_level-1;
        deep_level_p = deep_level_p-1;
    }
</cfscript>
<cf_papers paper_type="production_lot">
<cfscript>
	if(attributes.is_demand eq 1){
		attributes.stock_reserved = 0;
		attributes.is_stage = -1;
	}	
	else{
		attributes.stock_reserved = 1;
		attributes.is_stage = '4';
	}
	attributes.is_demontaj = 0;
	attributes.lot_no = paper_number;
	attributes.total_production_product = 0;
	if(isdefined("attributes.is_add_multi_demand") and attributes.is_add_multi_demand eq 1)
		attributes.total_production_product_all = 2;
	else
		attributes.total_production_product_all = GET_AMOUNT.recordcount;
</cfscript>
<cfif GET_AMOUNT.recordcount>
	<cfset prod_ind = 0>
    <cfloop query="GET_AMOUNT">
		<cfif len(SPECT_VAR_ID)>
			<cfset _spec_var_id_ = SPECT_VAR_ID>
		<cfelse>
			<cfset _spec_var_id_ = 0>	
		</cfif>
        <cfset _spec_main_id_ = SPEC_MAIN_ID>
        <cfset  _stock_id_ = STOCK_ID>
        <cfset _ORDER_NUMBER_ = ORDER_NUMBER>
        <cfif not len(_spec_main_id_)>
            <cfquery name="get_product_main_spec_default" datasource="#dsn3#"><!--- Ürün Ağacından En Son Varyasyonlanan yani kaydedilen SPECT_MAIN_ID'yi getiriyor. --->
                SELECT TOP 1 SPECT_MAIN_ID FROM SPECT_MAIN SM WHERE SM.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#_stock_id_#"> AND SM.IS_TREE = 1 ORDER BY SM.RECORD_DATE DESC,SM.UPDATE_DATE DESC
            </cfquery>
            <cfif get_product_main_spec_default.recordcount>
                <cfset _spec_main_id_ = get_product_main_spec_default.SPECT_MAIN_ID>
                <cfset _spec_var_id_ = 0>
            </cfif>
        </cfif>
		<cfscript>
			if(isdefined("GET_AMOUNT.row_no"))
				prod_ind2 = row_no;
			else
				prod_ind2 = currentrow;
				
			_project_id_ = PROJECT_ID;
			_order_id_ = GET_AMOUNT.ORDER_ID;
			_order_row_id_ = GET_AMOUNT.ORDER_ROW_ID;
			if(isdefined("attributes.ORDER_ROW_ID_LIST"))
				list_line  = ListFind(attributes.ORDER_ROW_ID_LIST,"#_order_row_id_##prod_ind2#",',');
			else
				list_line  = ListFind(attributes.ORDER_ROW_ID,"#_order_row_id_#",',');

		   // list_line  = ListFind(attributes.ORDER_ROW_ID,_order_row_id_,',');//listeden gelen değerlere göre sıralama yapıcaz...
			if(ListLen(attributes.station_id_list,'@') and len(ListGetAt(attributes.station_id_list,list_line,'@')))
				station_info =ListGetAt(attributes.station_id_list,list_line,'@');
			else
				station_info ='0,0,0,0,0,0,0,0,0';
			if(isdefined("attributes.is_add_multi_demand") and attributes.is_add_multi_demand eq 1)
			{
				control_link = 1;
				loop_count = ListGetAt(attributes.production_amount_list,list_line,',');
				row_amount = 1;
			}
			else
			{
				loop_count = 1;
				row_amount = ListGetAt(attributes.production_amount_list,list_line,',');
			}
		</cfscript>
        <cfif isdefined("_spec_main_id_") and len(_spec_main_id_)>
			<cfloop from="1" to="#loop_count#" index="ii_indx">
				<cfscript>
					attributes.total_production_product = attributes.total_production_product + 1;
					prod_ind = prod_ind + 1;
					'attributes.station_id_#prod_ind#_0' = "#ListGetAt(station_info,1,',')#,0,0,0,-1,#ListGetAt(station_info,6,',')#,#ListGetAt(station_info,7,',')#,#ListGetAt(station_info,8,',')#,#ListGetAt(station_info,9,',')#";
					"attributes.product_amount_#prod_ind#_0" = row_amount;
					"attributes.product_values_#prod_ind#_0" = "#STOCK_ID#,#_spec_var_id_#,0,0,#_spec_main_id_#";
					attributes.order_amount = row_amount;
					production_row_count = 0;
					if((isdefined("attributes.stage_info") and len(attributes.stage_info) and attributes.stage_info gt 0) or not (isdefined("attributes.stage_info") and len(attributes.stage_info)))
						writeTree(_spec_main_id_,0,0,0);
					if(listlen(attributes.WORKS_PROG_ID_LIST) gte list_line)
						"attributes.works_prog_#prod_ind#" = ListGetAt(attributes.WORKS_PROG_ID_LIST,list_line,',');
					else
						"attributes.works_prog_#prod_ind#" = 1;
					"attributes.order_row_id_#prod_ind#" =_order_row_id_;
					"attributes.order_id_#prod_ind#" =_order_id_;
					"attributes.kontrol_order_#prod_ind#" =kontrol_order;
					"attributes.production_type_#prod_ind#" =0;
					if(len(ListGetAt(attributes.production_start_date_list,list_line,',')))
						"attributes.start_date_#prod_ind#" = ListGetAt(attributes.production_start_date_list,list_line,',');
					else
						"attributes.start_date_#prod_ind#" ="";
					"attributes.start_h_#prod_ind#" = ListGetAt(attributes.production_start_h_list,list_line,',');
					"attributes.start_m_#prod_ind#" = ListGetAt(attributes.production_start_m_list,list_line,',');
					
					if(isdefined("attributes.production_finish_date_list"))
					{
						if(len(ListGetAt(attributes.production_finish_date_list,list_line,',')))
							"attributes.deliver_date_#prod_ind#" =  ListGetAt(attributes.production_finish_date_list,list_line,',');
						else
							"attributes.deliver_date_#prod_ind#" =  "";
						"attributes.finish_h_#prod_ind#" =ListGetAt(attributes.production_finish_h_list,list_line,',');
						"attributes.finish_m_#prod_ind#" = ListGetAt(attributes.production_finish_m_list,list_line,',');
					}
					else
					{
						if(len(ListGetAt(attributes.production_start_date_list,list_line,',')))
							"attributes.deliver_date_#prod_ind#" =  ListGetAt(attributes.production_start_date_list,list_line,',');
						else
							"attributes.deliver_date_#prod_ind#" =  "";
						"attributes.finish_h_#prod_ind#" =ListGetAt(attributes.production_start_h_list,list_line,',');
						"attributes.finish_m_#prod_ind#" = ListGetAt(attributes.production_start_m_list,list_line,',');
					}
					
					if(isdefined("attributes.demand_no_list") and len(attributes.demand_no_list))
					{
						if(len(ListGetAt(attributes.demand_no_list,list_line,',')))
							"attributes.demand_no_#prod_ind#" = ListGetAt(attributes.demand_no_list,list_line,',');
						else
							"attributes.demand_no_#prod_ind#" = "";
					}
					if(isdefined("attributes.WRK_ROW_RELATION_ID_LIST") and len(attributes.WRK_ROW_RELATION_ID_LIST))
					{
						if(len(ListGetAt(attributes.WRK_ROW_RELATION_ID_LIST,list_line,',')))
							"attributes.wrk_row_relation_id_#prod_ind#" = ListGetAt(attributes.WRK_ROW_RELATION_ID_LIST,list_line,',');
						else
							"attributes.wrk_row_relation_id_#prod_ind#" = "";
					}
					"attributes.project_id_#prod_ind#" =_project_id_;
					if(isdefined("attributes.is_time_calculation"))
						"attributes.is_time_calculation_#prod_ind#" = attributes.is_time_calculation;
					else
						"attributes.is_time_calculation_#prod_ind#" = 0 ;
					"attributes.is_operator_display_#prod_ind#" = 0 ;

					"attributes.production_row_count_#prod_ind#" = production_row_count ;
					"attributes.xml_is_order_row_deliver_date_update_#prod_ind#" = 1;
					if(isdefined("attributes.is_line_number"))
						"attributes.is_line_number_#prod_ind#" = attributes.is_line_number;
					else
						"attributes.is_line_number_#prod_ind#" = 0 ;
				</cfscript>
				<!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
				<cfinclude template="add_ezgi_production_ordel_all.cfm">
                <!---Ezgi Bilgisayar Özelleştirme Bitişi--->
			</cfloop>
        </cfif>
    </cfloop>
<cfelse>
	<script type="text/javascript">
    	alert('<cf_get_lang dictionary_id='651.Sipariş Satırlarında Spec Seçilmemiş Kayıtlar Mevcut'>, <cf_get_lang dictionary_id='652.Lütfen Siparişi Kontrol Ediniz'> !');
		history.go(-1);
    </script>
</cfif>
<cfif not isdefined("is_import_prod")>
</table>
</cfif>
