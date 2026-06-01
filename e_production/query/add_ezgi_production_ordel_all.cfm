<!---
    File: add_ezgi_production_ordel_all.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---Ezgi Bilgisayar Özelleştirme ZAG - 18/01/2019--->

<!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
<cfif isdefined('attributes.master_alt_plan_id')>
	<cfif attributes.islem_id eq -1> <!---IFLOW Üretim Programından Geliyorsa--->
    
    <cfelse> <!---Master Plandan Geliyorsa--->
        <cfquery name="get_sub_master_plan_id" datasource="#dsn3#">
            SELECT  
                EMAP.MASTER_PLAN_ID,
                EMAP.PROCESS_ID,   
                EMAP.MASTER_ALT_PLAN_ID, 
                ISNULL(EMAP.IS_RESERVED,1) AS IS_RESERVED,
                EMPS.WORKSTATION_ID
            FROM         
                EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) INNER JOIN
                EZGI_MASTER_PLAN_SABLON AS EMPS WITH (NOLOCK) ON EMAP.PROCESS_ID = EMPS.PROCESS_ID
            WHERE     
                EMAP.MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id# OR
                EMAP.RELATED_MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#
        </cfquery>
        <cfoutput query="get_sub_master_plan_id">
            <cfset 'MASTER_ALT_PLAN_ID_#WORKSTATION_ID#'= MASTER_ALT_PLAN_ID>
            <cfset 'MASTER_PLAN_ID_#WORKSTATION_ID#'= MASTER_PLAN_ID>
            <cfset 'PROCESS_ID_#WORKSTATION_ID#'= PROCESS_ID>
            <cfset 'IS_RESERVED_#WORKSTATION_ID#'= IS_RESERVED>
            <cfset attributes.master_plan_id= MASTER_PLAN_ID>
        </cfoutput>
    </cfif>
</cfif>
<!---Ezgi Bilgisayar Özelleştirme Bitişi--->

<cfif not isdefined("new_keyword_")>
	<cfset new_keyword_ = "">
</cfif>
<cfparam name="prod_ind" default="1">
<cfif not isdefined('is_ok')><!--- Çoklu sayfadan da gelse sadece 1 kere include edilsin.. --->
	<!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
	<cfinclude template="../../../../v16/workdata/get_main_spect_id.cfm">
    <!---Ezgi Bilgisayar Özelleştirme Bitiş--->
	<cfset is_ok = 1>    
</cfif>
<cfparam name="attributes.total_production_product" default="1">
<cfparam name="attributes.total_production_product_all" default="1">
<cfif not isdefined("is_op")>
	<cfparam name="attributes.deep_level_op" default="0">
	<cfset is_op = 1>    
</cfif>
<cfparam name="prod_ind" default="1"><!--- normal üretim emri ekleme sayfasından geliyorsa 1 tane ürün olacağından 1 atıyoruz direkt olarak... --->
<cfscript>
    attributes.production_row_count = Evaluate("attributes.production_row_count_#prod_ind#");
    attributes.is_time_calculation =  Evaluate("attributes.is_time_calculation_#prod_ind#");
	attributes.is_line_number =  Evaluate("attributes.is_line_number_#prod_ind#");
	if(isdefined("attributes.is_operator_display_#prod_ind#"))
    	attributes.is_operator_display = Evaluate("attributes.is_operator_display_#prod_ind#");//talep üretim ayrımını burdan yapıcaz..
    else
		attributes.is_operator_display = 0;
	attributes.start_date = Evaluate("attributes.start_date_#prod_ind#");
    attributes.start_m = Evaluate("attributes.start_m_#prod_ind#");
    attributes.start_h = Evaluate("attributes.start_h_#prod_ind#");
    attributes.finish_m = Evaluate("attributes.finish_m_#prod_ind#");
    attributes.finish_h = Evaluate("attributes.finish_h_#prod_ind#");
    attributes.deliver_date= Evaluate("attributes.deliver_date_#prod_ind#");
	if(isdefined("attributes.works_prog_#prod_ind#"))
   		attributes.works_prog = Evaluate("attributes.works_prog_#prod_ind#");
    else
		attributes.works_prog = 1;
	attributes.production_type = 1; //Evaluate("attributes.production_type_#prod_ind#");
    attributes.project_id = Evaluate("attributes.project_id_#prod_ind#");
	if(isdefined("attributes.demand_no_#prod_ind#"))
		attributes.demand_no = Evaluate("attributes.demand_no_#prod_ind#");
	if(isdefined('attributes.demand_no') and len(attributes.demand_no))	
		attributes.demand_no = attributes.demand_no;
	else
		attributes.demand_no = '';
	if(isdefined("attributes.wrk_row_relation_id_#prod_ind#"))
		attributes.wrk_row_relation_id = Evaluate("attributes.wrk_row_relation_id_#prod_ind#");
	else
		attributes.wrk_row_relation_id = '';
	if(isdefined("attributes.work_id_#prod_ind#"))
		attributes.work_id = Evaluate("attributes.work_id_#prod_ind#");
	if(isdefined('attributes.work_id') and len(attributes.work_id))	
		attributes.work_id = attributes.work_id;
	else
		attributes.work_id = '';
	if(isdefined("attributes.work_head_#prod_ind#"))
		attributes.work_head = Evaluate("attributes.work_head_#prod_ind#");
	if(isdefined('attributes.work_head') and len(attributes.work_head))	
		attributes.work_head = attributes.work_head;
	else
		attributes.work_head = '';
</cfscript>
<cfif isdefined('attributes.is_time_calculation') and attributes.is_time_calculation eq 0><!--- Zaman Hesaplaması Yapılmamış denmiş ise her üretim için başlangıç ve bitiş saatini atıycaz. --->
    <cfif isdefined('attributes.start_date') and isdate(attributes.start_date) and len(attributes.start_m) and len(attributes.start_h)>
        <cf_date tarih = "attributes.start_date">
        <cfset attributes.start_date = date_add("n",attributes.start_m,date_add("h",attributes.start_h ,attributes.start_date))><!--- - session.ep.time_zone --->
    <cfelse>
        <cfset attributes.start_date =''>
    </cfif>
    <cfif isdefined('attributes.deliver_date') and isdate(attributes.deliver_date) and len(attributes.finish_h) and len(attributes.finish_m)>
        <cf_date tarih = "attributes.deliver_date">
        <cfset attributes.deliver_date = date_add("n",attributes.finish_m,date_add("h",attributes.finish_h ,attributes.deliver_date))><!--- - session.ep.time_zone --->
    <cfelse>
        <cfset attributes.deliver_date = '' >
    </cfif>
<cfelse><!--- Zaman Hesaplaması Yapılsın Denilmiş ise --->
    <cfparam name="n_now_#prod_ind#" default="">
    <cfset xxx_list = ''><!--- Bu liste iç içe kırılımı olan ürünlerde alttaki ürünlerin daha önce üretilmesi için kullanılıyor. --->
    <cfset new_production_row_count_list = ''><!--- Bu değişken ise ürünlerin hangi sırada üretileceğini tutar --->
    <cfloop  to="#attributes.production_row_count#" from="1" index="indexx">
        <cfif isdefined('attributes.product_is_production_#prod_ind#_#indexx#')><!--- Üretilsin diye seçilmiş ise! --->
           <cfif (ListGetAt(Evaluate('attributes.product_values_#prod_ind#_#indexx#'),3,',') eq 1  and len(xxx_list))><!--- 1.ci kırılımdaki ürünler ise --->
                <cfif ListLen(xxx_list,'-')>
                    <cfloop  from="#ListLen(xxx_list,'-')#" to="1" index="real_index" step="-1"><!--- burdaki loop'u listeyi tersine çevirmek için kullanıyoruz. --->
                        <cfset new_production_row_count_list = ListAppend(new_production_row_count_list,ListGetAt(xxx_list,real_index,'-'),',')>
                    </cfloop>
                </cfif>
                <cfset xxx_list =''><!--- 1.ci kırılımdaki ürüne denk geldiğinde bu listeyi sıfırlıyoruz,sonraki 1.ci kırılım ürünleride kendi içinde gruplasın diye! --->
            </cfif>
            <cfset xxx_list = ListAppend(xxx_list,'#ListGetAt(Evaluate('attributes.product_values_#prod_ind#_#indexx#'),4,',')#','-')>
             <cfif indexx eq attributes.production_row_count and listlen(xxx_list) and not ListFind(new_production_row_count_list,xxx_list,',')>
                <cfoutput>
                    <cfloop  from="#ListLen(xxx_list,'-')#" to="1" index="real_index_" step="-1">
                        <cfset new_production_row_count_list = ListAppend(new_production_row_count_list,ListGetAt(xxx_list,real_index_,'-'),',')>
                    </cfloop>
                </cfoutput>
            </cfif>
        </cfif>
    </cfloop>    
    <cfset new_production_row_count_list = ListAppend(new_production_row_count_list,0,',')><!--- Son olarak ana ürün üretileceği için onun numarası olan 0'ı ekliyoruz. --->
    <cfloop list="#new_production_row_count_list#" index="indexx">
        <cfif listlen(Evaluate('attributes.station_id_#prod_ind#_#indexx#'),',') eq 4><!--- bu kontrol sonrada kalkacak! --->
            <cfset setup_time = ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#indexx#'),4,',')>

        <cfelse>
            <cfset setup_time = 0 >
        </cfif>
       <!--- <cfscript> 
            'production_times#indexx#'=get_production_times(
                station_id : ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#indexx#'),1,','),
                shift_id : attributes.works_prog,
                stock_id : ListGetAt(Evaluate('attributes.product_values_#prod_ind#_#indexx#'),1,','),
                amount : Evaluate('attributes.product_amount_#prod_ind#_#indexx#'),
                production_type : attributes.production_type,
                setup_time_min : setup_time,
                _now_ : Evaluate("n_now_#prod_ind#")
                
            );
        </cfscript>--->
        <cfscript> 
		if(attributes.works_prog is '')
		works_program = 1;
		else
		works_program = attributes.works_prog;	
            'production_times#indexx#'=get_production_times(
                station_id : ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#indexx#'),1,','),
                shift_id : works_program,
                stock_id : ListGetAt(Evaluate('attributes.product_values_#prod_ind#_#indexx#'),1,','),
                amount : Evaluate('attributes.product_amount_#prod_ind#_#indexx#'),
                production_type : attributes.production_type,
                setup_time_min : setup_time,
                _now_ : Evaluate("n_now_#prod_ind#")
                
            );
        </cfscript>
        <cfset x_now_ = date_add('h',session.ep.TIME_ZONE,now())>
        <cfif not isdefined('production_times#indexx#')><!--- Olası bir hata olduğunda zamanı ayarlasın --->
            <cfset 'production_times#indexx#' = "#DateFormat(x_now_,'YYYYMMDD')#,#TimeFormat(x_now_,timeformat_style)#,#DateFormat(date_add('h',1,x_now_),'YYYYMMDD')#,#TimeFormat(date_add('h',1,x_now_),timeformat_style)#">
        </cfif>
        <cfset s_yil = Left(ListGetAt(Evaluate('production_times#indexx#'),1,','),4)>
        <cfset s_ay =  mid(ListGetAt(Evaluate('production_times#indexx#'),1,','),5,2)>
        <cfset s_gun = mid(ListGetAt(Evaluate('production_times#indexx#'),1,','),7,2)>
        <cfset s_saat =ListFirst(ListGetAt(Evaluate('production_times#indexx#'),2,','),':')>
        <cfset s_dakika =ListLast(ListGetAt(Evaluate('production_times#indexx#'),2,','),':')>
        
        <cfset f_yil = Left(ListGetAt(Evaluate('production_times#indexx#'),3,','),4)>
        <cfset f_ay =  mid(ListGetAt(Evaluate('production_times#indexx#'),3,','),5,2)>
        <cfset f_gun = mid(ListGetAt(Evaluate('production_times#indexx#'),3,','),7,2)>
        <cfset f_saat =ListFirst(ListGetAt(Evaluate('production_times#indexx#'),4,','),':')>
        <cfset f_dakika =ListLast(ListGetAt(Evaluate('production_times#indexx#'),4,','),':')>
        <cfset 'startdate_fn_#prod_ind#_#indexx#' = CreateDateTime(s_yil,s_ay,s_gun,s_saat,s_dakika,0)>
        <cfset 'finishdate_fn_#prod_ind#_#indexx#' = CreateDateTime(f_yil,f_ay,f_gun,f_saat,f_dakika,0)>
        <cfset XYZ = ListGetAt(Evaluate('attributes.product_values_#prod_ind#_#indexx#'),3,',')>
	    <cfif isdefined("last_start_#XYZ#")>
			<cfif isdefined('attributes.station_id_#prod_ind#_#indexx#')>
				<cfif indexx neq 0 and ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#indexx#'),1,',') neq evaluate('last_station_#XYZ#')>
					<cfset 'startdate_fn_#prod_ind#_#indexx#' = evaluate('last_start_#XYZ#')>
					<cfset 'finishdate_fn_#prod_ind#_#indexx#' = evaluate('last_finish_#XYZ#')>
				</cfif>
			<cfelse>
				<cfif indexx neq 0 and ListGetAt(Evaluate('attributes.product_values_#prod_ind#_#indexx#'),3,',') eq ListGetAt(Evaluate('attributes.product_values_#prod_ind#_#indexx+1#'),3,',')>
					<cfset 'startdate_fn_#prod_ind#_#indexx#' = evaluate('last_start_#XYZ#')>
					<cfset 'finishdate_fn_#prod_ind#_#indexx#' = evaluate('last_finish_#XYZ#')>
				</cfif>
			</cfif>
	    </cfif>
        <cfif isdefined('XYZ') and XYZ gt ListGetAt(Evaluate('attributes.product_values_#prod_ind#_#indexx#'),3,',') and ListGetAt(Evaluate('attributes.product_values_#prod_ind#_#indexx#'),3,',') neq 1>
           <cfset "n_now_#prod_ind#" = '' >
        <cfelse>
           <cfset "n_now_#prod_ind#" = Evaluate('finishdate_fn_#prod_ind#_#indexx#') >
        </cfif>
	    <cfset "last_start_#XYZ#" = Evaluate('startdate_fn_#prod_ind#_#indexx#')>
	    <cfset "last_station_#XYZ#" = ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#indexx#'),1,',')>
	    <cfset "last_finish_#XYZ#" = Evaluate('finishdate_fn_#prod_ind#_#indexx#')>
        <cfstoredproc procedure="ADD_PRODUCTION_ORDER_CASH" datasource="#DSN3#">
            <cfprocparam cfsqltype="cf_sql_timestamp" value="#Evaluate('startdate_fn_#prod_ind#_#indexx#')#">
            <cfprocparam cfsqltype="cf_sql_timestamp" value="#Evaluate('finishdate_fn_#prod_ind#_#indexx#')#">
            <cfprocparam cfsqltype="cf_sql_integer" value="#ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#indexx#'),1,',')#">
        </cfstoredproc>
    </cfloop>
</cfif>
<!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
<cfif isdefined('attributes.master_alt_plan_id') and attributes.islem_id eq -1> <!---IFLOW Üretim Programından Geliyorsa Sanal Üretim Planındaki Lot Kullanılacak--->
  
<cfelse>    
    <cf_papers paper_type="production_lot"><!--- Lotnumarası sadece 1 kere alınacak --->
    <cfscript>
        lot_system_paper_no=paper_code & '-' & paper_number;
        lot_system_paper_no_add=paper_number;
    </cfscript>
    <cfif not len(lot_system_paper_no_add)>
        <script type="text/javascript">
            alert("<cf_get_lang dictionary_id ='36936.Lütfen Lot Belge Numaralarınızı Tanımlayınız'> !");
            history.go(-1);
        </script>
        <cfabort>
    </cfif>
    <cfstoredproc procedure="UPD_GENERAL_PAPERS_LOT_NUMBER" datasource="#dsn3#">
        <cfprocparam cfsqltype="cf_sql_integer" value="#lot_system_paper_no_add#">
    </cfstoredproc>
</cfif>
<!---Ezgi Bilgisayar Özelleştirme Bitişi--->
<cfloop from="0" to="#attributes.production_row_count#" index="sayac">
    <cfif isdefined('attributes.product_is_production_#prod_ind#_#sayac#') or sayac eq 0><!--- Eğer Üret Seçeneği Seçilmiş ise  yada sadece ana ürün ise bu bloğa girer --->
        <cf_papers paper_type="prod_order"><!--- Belge Numarası her üretim için tek tek alınıyor! --->
        <cfscript>
            system_paper_no=paper_code & '-' & paper_number;
            system_paper_no_add=paper_number;
        </cfscript>
		<cfif len(new_keyword_)>
			<cfset new_keyword_ = "#new_keyword_#,#system_paper_no#">
		<cfelse>
			<cfset new_keyword_ = "#system_paper_no#">	
		</cfif>
        <cfif not len(system_paper_no_add)>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='29687.Lütfen Belge Numaralarınızı Tanımlayınız'> !");
                history.go(-1);
            </script>
            <cfabort>
        </cfif>
        
                <cfset production_stock_id = ListGetAt(Evaluate('attributes.product_values_#prod_ind#_#sayac#'),1,',')>
                <cfif sayac eq 0><!--- Sadece Ana Ürünün spect_id'si spect_var_id'yi tutuyor diğerleri ise spect_main_id'yi tutuyor bu sebeble diğerlerinde spect_id'ler yeniden oluşturulucak specer fonksiyonu ile --->
                    <cfset spect_id = ListGetAt(Evaluate('attributes.product_values_#prod_ind#_#sayac#'),2,',')>
                    <cfset spect_main_id___ = ListGetAt(Evaluate('attributes.product_values_#prod_ind#_#sayac#'),5,',')>
                     <cfquery name="GET_SPECT" datasource="#DSN3#">
                        <cfif len(spect_id) and spect_id gt 0>
                             SELECT SPECT_VAR_NAME FROM SPECTS WHERE SPECT_VAR_ID = #spect_id#
                        <cfelse>
                            SELECT SPECT_MAIN_NAME AS SPECT_VAR_NAME  FROM SPECT_MAIN WHERE SPECT_MAIN_ID = #spect_main_id___#
                        </cfif>
                      </cfquery>
                      <cfset spec_var_name=GET_SPECT.SPECT_VAR_NAME>
                      <cfset production_level = 0><!--- Ana ürün 0.cı kırılım. --->
                      <cfset production_step = 0><!--- Üretim adımı --->
                <cfelse><!--- Ana Ürün değilse main_spect'id'yi kullanarak yeni bir spect oluşturuyoruz! --->
                    <cfset spect_main_id___ = ListGetAt(Evaluate('attributes.product_values_#prod_ind#_#sayac#'),2,',')>
                    <cfif  spect_main_id___ eq 0><!--- SpectMainID değeri 0dan büyüksa,yani ürün üretilen bir ürün olduğu halde eğerki ağaçta spect seçilmemiş ise burda o ürün için ağacındaki varsayılan MAIN spect değerini alıcaz. --->
                        <cfscript>
                            create_spect_from_product_tree = get_main_spect_id(production_stock_id);
                            if(len(create_spect_from_product_tree.SPECT_MAIN_ID))
                                spect_main_id___ = create_spect_from_product_tree.SPECT_MAIN_ID;
                        </cfscript> 
                    </cfif>
                    <cfif spect_main_id___ gt 0><!--- Bir üst satırda yapılan eşleştirmeye rağmen  spect_main_id hala 0 ise bu şu anlama geliyor;ÜrünDetayında üretiliyor seçilmiş fakat,ürünün bir ağacı yok yada var ancak ağacı varyasyonlanmamış --->
                        <cfquery name="get_spec_main_name" datasource="#dsn3#">
                            SELECT SPECT_MAIN_NAME FROM SPECT_MAIN WHERE SPECT_MAIN_ID = #spect_main_id___#
                        </cfquery>
                        <cfset spec_var_name = get_spec_main_name.SPECT_MAIN_NAME> 
                        <cfset production_level = ListGetAt(Evaluate('attributes.product_values_#prod_ind#_#sayac#'),3,',')><!--- Diğer ürünlerin ağaçta kaçıncı kırılım olduğu --->
                        <cfset production_step = ListGetAt(Evaluate('attributes.product_values_#prod_ind#_#sayac#'),4,',')><!--- Üretimin kaçıncı adımda olduğunu alıyoruz,bu değişken silinmesin,verilen üretim emirlerini kontrol ederken kullanlılıyor. --->
                    </cfif>            
                </cfif>
                <cfif sayac eq 0 or spect_main_id___ gt 0><!--- Ana Ürünse veya sarf ürünlerde spect seçilmiş ürünler ise --->
                    <cfif Evaluate('attributes.product_amount_#prod_ind#_#sayac#') contains ','>
						<cfset quantity = filterNum(Evaluate('attributes.product_amount_#prod_ind#_#sayac#'),8)>
                    <cfelse>
                    	<cfset quantity = Evaluate('attributes.product_amount_#prod_ind#_#sayac#')>
                    </cfif>
                    <cfset ____po_related_id____ =''>
                    <!--- bu if manuel olarak en fazla 10 kırılım olabileceği düşünelerak yazıldı muhtemelen bundan fazlasıda olmaz,bunun için bir fonksiyon yerine manuel yazmak daha kolay olduğu için böle yazıldı..İlerde fonksiyon ilede halledilebilir. Ayrıca yukarıda üretim emirlerinin zamanlarını hesaplama kısmıda düzenlenmeli buraya göre......--->
                    <cfif production_level gt 0>
                        <cfif production_level gte 1 and isdefined('po_related_id_#prod_ind#_#production_level-1#') and len(Evaluate('po_related_id_#prod_ind#_#production_level-1#'))>
                            <cfset ____po_related_id____ = Evaluate('po_related_id_#prod_ind#_#production_level-1#')>
                        <cfelseif production_level gte 2 and isdefined('po_related_id_#prod_ind#_#production_level-2#') and len(Evaluate('po_related_id_#prod_ind#_#production_level-2#'))>
                            <cfset ____po_related_id____ = Evaluate('po_related_id_#prod_ind#_#production_level-2#')>
                        <cfelseif production_level gte 3 and isdefined('po_related_id_#prod_ind#_#production_level-3#') and len(Evaluate('po_related_id_#prod_ind#_#production_level-3#'))>
                            <cfset ____po_related_id____ = Evaluate('po_related_id_#prod_ind#_#production_level-3#')>
                        <cfelseif production_level gte 4 and isdefined('po_related_id_#prod_ind#_#production_level-4#') and len(Evaluate('po_related_id_#prod_ind#_#production_level-4#'))>
                            <cfset ____po_related_id____ = Evaluate('po_related_id_#prod_ind#_#production_level-4#')>
                        <cfelseif production_level gte 5 and isdefined('po_related_id_#prod_ind#_#production_level-5#') and len(Evaluate('po_related_id_#prod_ind#_#production_level-5#'))>
                            <cfset ____po_related_id____ = Evaluate('po_related_id_#prod_ind#_#production_level-5#')>
                        <cfelseif production_level gte 6 and isdefined('po_related_id_#prod_ind#_#production_level-6#') and len(Evaluate('po_related_id_#prod_ind#_#production_level-6#'))>
                            <cfset ____po_related_id____ = Evaluate('po_related_id_#prod_ind#_#production_level-6#')>
                        <cfelseif production_level gte 7 and isdefined('po_related_id_#prod_ind#_#production_level-7#') and len(Evaluate('po_related_id_#prod_ind#_#production_level-7#'))>
                            <cfset ____po_related_id____ = Evaluate('po_related_id_#prod_ind#_#production_level-7#')>
                        <cfelseif production_level gte 8 and isdefined('po_related_id_#prod_ind#_#production_level-8#') and len(Evaluate('po_related_id_#prod_ind#_#production_level-8#'))>
                            <cfset ____po_related_id____ = Evaluate('po_related_id_#prod_ind#_#production_level-8#')>
                        <cfelseif production_level gte 9 and isdefined('po_related_id_#prod_ind#_#production_level-9#') and len(Evaluate('po_related_id_#prod_ind#_#production_level-9#'))>
                            <cfset ____po_related_id____ = Evaluate('po_related_id_#prod_ind#_#production_level-9#')>
                        <cfelseif production_level gte 10 and isdefined('po_related_id_#prod_ind#_#production_level-10#') and len(Evaluate('po_related_id_#prod_ind#_#production_level-10#'))>
                            <cfset ____po_related_id____ = Evaluate('po_related_id_#prod_ind#_#production_level-10#')>
                        <cfelseif production_level gte 11 and isdefined('po_related_id_#prod_ind#_#production_level-11#') and len(Evaluate('po_related_id_#prod_ind#_#production_level-11#'))>
                            <cfset ____po_related_id____ = Evaluate('po_related_id_#prod_ind#_#production_level-11#')>
                        <cfelseif production_level gte 12 and isdefined('po_related_id_#prod_ind#_#production_level-12#') and len(Evaluate('po_related_id_#prod_ind#_#production_level-12#'))>
                            <cfset ____po_related_id____ = Evaluate('po_related_id_#prod_ind#_#production_level-12#')>
                        <cfelseif production_level gte 13 and isdefined('po_related_id_#prod_ind#_#production_level-13#') and len(Evaluate('po_related_id_#prod_ind#_#production_level-13#'))>
                            <cfset ____po_related_id____ = Evaluate('po_related_id_#prod_ind#_#production_level-13#')>
                        <cfelseif production_level gte 14 and isdefined('po_related_id_#prod_ind#_#production_level-14#') and len(Evaluate('po_related_id_#prod_ind#_#production_level-14#'))>
                            <cfset ____po_related_id____ = Evaluate('po_related_id_#prod_ind#_#production_level-14#')>
                        <cfelseif production_level gte 15 and isdefined('po_related_id_#prod_ind#_#production_level-15#') and len(Evaluate('po_related_id_#prod_ind#_#production_level-15#'))>
                            <cfset ____po_related_id____ = Evaluate('po_related_id_#prod_ind#_#production_level-15#')>
                        </cfif>
                    </cfif>
					<cfif len(spect_main_id___)>
                        <cfquery name="get_tree_operations" datasource="#dsn3#">
                            SELECT 
                            	STOCK_ID,
                                OPERATION_TYPE_ID,
                                IS_PROPERTY,
                                AMOUNT 
                          	FROM 
                            	SPECT_MAIN_ROW WITH (NOLOCK)
                           	WHERE 
                            	STOCK_ID IS NULL AND 
                                SPECT_MAIN_ID = #spect_main_id___# AND 
                                IS_PROPERTY IN (0,3,4)
                                <!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
                                <!---Operasyon Tanımlarında Sanal Operasyonlar Operasyon emri verilmesin--->
                                AND OPERATION_TYPE_ID NOT IN
                      										(
                                                            	SELECT 
                                                                	OPERATION_TYPE_ID
                       											FROM      
                                                                	OPERATION_TYPES WITH (NOLOCK)
                       											WHERE   
                                                                	ISNULL(IS_VIRTUAL, 0) = 1
                                                         	)
                                <!---Ezgi Bilgisayar Özelleştirme Bitişi--->
                        </cfquery>
                    </cfif>
                    <cfif isdefined('attributes.station_id_#prod_ind#_#sayac#') and ListLen(Evaluate('attributes.station_id_#prod_ind#_#sayac#'),',') gt 5>
						<cfset  _EXIT_DEP_ID=ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#sayac#'),6,',')>
                        <cfset  _EXIT_LOC_ID=ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#sayac#'),7,',')>
                        <cfset  _PRODUCTION_DEP_ID=ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#sayac#'),8,',')>
                        <cfset  _PRODUCTION_LOC_ID=  ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#sayac#'),9,',')>
					<cfelse>
						<cfset  _EXIT_DEP_ID=''>
                        <cfset  _EXIT_LOC_ID=''>
                        <cfset  _PRODUCTION_DEP_ID=''>
                        <cfset  _PRODUCTION_LOC_ID= ''>
                    </cfif>
					<cfset wrk_id_new = 'WRK#round(rand()*65)##dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmssL')##session.ep.userid##round(rand()*100)#'>
                    <!--- ÜRETİM EMRİ EKLENİYOR --->
                    <cfstoredproc procedure="ADD_PRODUCTION_ORDER" datasource="#dsn3#">
						<cfif production_level eq 0 and isdefined('attributes.po_related_id_main') and len(attributes.po_related_id_main)><!--- Bir üretimin detayından ilişkili bir üretim ekleniyorsa --->
                        	<cfprocparam cfsqltype="cf_sql_integer" value="#attributes.po_related_id_main#">
                        <cfelseif len(____po_related_id____)><!--- Verilen Üretim emrinde seçilen ürünün ağacında bulunan üretilen ürünler için siparişi verilen ürün ile ilgili bağlantıları kuruyoruz. --->
                        	<cfprocparam cfsqltype="cf_sql_integer" value="#____po_related_id____#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="NULL" null="yes">
                        </cfif>
                        <cfprocparam cfsqltype="cf_sql_integer" value="#production_stock_id#">
                        <cfprocparam cfsqltype="cf_sql_float" value="#quantity#">
                        <cfif isDefined("attributes.product_amount_2")>
							<cfprocparam cfsqltype="cf_sql_integer" value="#attributes.product_amount_2#">
						<cfelse>
							<cfprocparam cfsqltype="cf_sql_integer" value="NULL" null="yes">
						</cfif>
						<cfif isDefined("attributes.product_unit_2")>
							<cfprocparam cfsqltype="cf_sql_varchar" value="#attributes.product_unit_2#">
						<cfelse>
							<cfprocparam cfsqltype="cf_sql_varchar" value="NULL" null="yes">
						</cfif>
                        <cfif isdefined('attributes.is_time_calculation') and attributes.is_time_calculation eq 0 and isdate(attributes.start_date)>
                        	<cfprocparam cfsqltype="cf_sql_timestamp" value="#attributes.start_date#">
                        <cfelseif isdefined('startdate_fn_#prod_ind#_#sayac#')>    
                        	<cfprocparam cfsqltype="cf_sql_timestamp" value="#Evaluate('startdate_fn_#prod_ind#_#sayac#')#">
                        <cfelseif isdefined('startdate_fn_1_0')>    
                        	<cfprocparam cfsqltype="cf_sql_timestamp" value="#Evaluate('startdate_fn_1_0')#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_timestamp" value="NULL" null="yes">    
                        </cfif>
                        <cfif isdefined('attributes.is_time_calculation') and attributes.is_time_calculation eq 0 and isdate(attributes.deliver_date)>
                        	<cfprocparam cfsqltype="cf_sql_timestamp" value="#attributes.deliver_date#">
                        <cfelseif isdefined('finishdate_fn_#prod_ind#_#sayac#')>    
                        	<cfprocparam cfsqltype="cf_sql_timestamp" value="#Evaluate('finishdate_fn_#prod_ind#_#sayac#')#">
                        <cfelseif isdefined('finishdate_fn_1_0')>    
                        	<cfprocparam cfsqltype="cf_sql_timestamp" value="#Evaluate('finishdate_fn_1_0')#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_timestamp" value="NULL" null="yes">
                        </cfif>
                        <cfprocparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
                        <cfprocparam cfsqltype="cf_sql_timestamp" value="#now()#">
                        <cfprocparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">
                        <cfprocparam cfsqltype="cf_sql_integer" value="1">
                        <cfif isdefined('attributes.project_id') and len(attributes.project_id)>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="#attributes.project_id#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="NULL" null="yes">
                        </cfif>
                        <cfprocparam cfsqltype="cf_sql_varchar" value="#system_paper_no#">
                        <!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
                        <cfif isdefined('attributes.demand_no') and len(attributes.demand_no)>
                        	<cfif isdefined('attributes.detail')>
                            	<cfset attributes.detail = '#attributes.demand_no# - #attributes.detail#'>
                                <cfprocparam cfsqltype="cf_sql_varchar" value="#attributes.detail#">
                            <cfelse>
                            	<cfprocparam cfsqltype="cf_sql_varchar" value="#attributes.demand_no#">
                            </cfif>
                        <cfelse>
                        	<cfif isdefined('attributes.detail')>
                                <cfprocparam cfsqltype="cf_sql_varchar" value="#attributes.detail#">
                            <cfelse>
                                <cfprocparam cfsqltype="cf_sql_varchar" value="NULL" null="yes">
                            </cfif>
                        </cfif>
                        
                        <!---<cfif isdefined('attributes.detail')>
                        	<cfprocparam cfsqltype="cf_sql_varchar" value="#attributes.detail#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_varchar" value="NULL" null="yes">
                        </cfif>--->
                        
                        <!---Ezgi Bilgisayar Özelleştirme Bitişi--->
                        
                        <cfif isdefined("attributes.process_stage")>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="#attributes.process_stage#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="NULL" null="yes">
                        </cfif>
                        <cfif isdefined('attributes.station_id_#prod_ind#_#sayac#') and len(ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#sayac#'),1,',')) and ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#sayac#'),1,',') gt 0>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="#ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#sayac#'),1,',')#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="NULL" null="yes">
                        </cfif>
                        <cfif len(spect_id) and spect_id gt 0 and sayac eq 0>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="#spect_id#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="NULL" null="yes">
                        </cfif><!--- Sadece Ana Ürün için spect_var_id oluşturuyoruz. --->
                        <cfif isdefined("spec_var_name") and len(spec_var_name)>
                        	<cfprocparam cfsqltype="cf_sql_varchar" value="#spec_var_name#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_varchar" value="NULL" null="yes">
                        </cfif>
                        <cfif isdefined('attributes.stock_reserved')>
                        	<cfprocparam cfsqltype="cf_sql_bit" value="#attributes.stock_reserved#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_bit" value="0">
                        </cfif>
                        <cfif isdefined('attributes.is_demontaj') and attributes.is_demontaj eq 1>
                        	<cfprocparam cfsqltype="cf_sql_bit" value="#attributes.is_demontaj#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_bit" value="0">
                        </cfif>
                        <!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
						<cfif isdefined('attributes.master_alt_plan_id') and attributes.islem_id eq -1> <!---IFLOW Üretim Programından Geliyorsa Sanal Üretim Planındaki Lot Kullanılacak--->
                        	<cfprocparam cfsqltype="cf_sql_varchar" value="#Evaluate('lot_no#prod_ind#')#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_varchar" value="#lot_system_paper_no#">
                        </cfif>
                        <!---Ezgi Bilgisayar Özelleştirme Bitişi--->
                        
                        <cfprocparam cfsqltype="cf_sql_varchar" value="#production_step#">
                        <cfprocparam cfsqltype="cf_sql_integer" value="#spect_main_id___#">
                        <cfif attributes.is_operator_display eq 1 and attributes.is_stage eq 4>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="0">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="#attributes.is_stage#">
                        </cfif>
                        <cfprocparam cfsqltype="cf_sql_varchar" value="#wrk_id_new#">
                        <cfif isdefined('attributes.demand_no') and len(attributes.demand_no)>
                        	<cfprocparam cfsqltype="cf_sql_varchar" value="#attributes.demand_no#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_varchar" value="NULL" null="yes">
                        </cfif>
                        <cfif len(_EXIT_DEP_ID) and _EXIT_DEP_ID gt 0>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="#_EXIT_DEP_ID#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="NULL" null="yes">
                        </cfif>
                        <cfif len(_EXIT_LOC_ID) and _EXIT_LOC_ID gt 0>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="#_EXIT_LOC_ID#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="NULL" null="yes">
                        </cfif>
                        <cfif len(_PRODUCTION_DEP_ID) and _PRODUCTION_DEP_ID gt 0>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="#_PRODUCTION_DEP_ID#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="NULL" null="yes">
                        </cfif>
                        <cfif len(_PRODUCTION_LOC_ID) and _PRODUCTION_LOC_ID gt 0>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="#_PRODUCTION_LOC_ID#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="NULL" null="yes">
                        </cfif>
                        <cfif isdefined('attributes.work_id') and len(attributes.work_id) and len(attributes.work_head)>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_integer" value="NULL" null="yes">
                        </cfif>
                        <cfif isdefined('attributes.wrk_row_relation_id') and len(attributes.wrk_row_relation_id)>
                        	<cfprocparam cfsqltype="cf_sql_varchar" value="#attributes.wrk_row_relation_id#">
                        <cfelse>
                        	<cfprocparam cfsqltype="cf_sql_varchar" value="NULL" null="yes">
                        </cfif>
                    </cfstoredproc>
                    
                    <cfstoredproc procedure="UPD_GENERAL_PAPERS_PROD_ORDER_NUMBER" datasource="#dsn3#">
                    	<cfprocparam cfsqltype="cf_sql_integer" value="#system_paper_no_add#">
                    </cfstoredproc>

                    <cfstoredproc procedure="GET_PRODUCTION_ORDER_MAX" datasource="#dsn3#">
                    	<cfprocparam cfsqltype="cf_sql_varchar" value="#wrk_id_new#">
                        <cfprocresult name="GET_MAX">
                    </cfstoredproc>
                    
					<cfif production_level gte 0>
						<cfset 'po_related_id_#prod_ind#_#production_level#' = GET_MAX.PID >
					</cfif>
					<cfset product_tree_id_list = ''>
					<cfset operation_type_id_list = ''>
					<cfset amount_list = ''>
					<cfset deep_level_list = ''>
					<cfscript>
						//writeoutput("deep_level_op:#attributes.deep_level_op#<br>");
						writeTree_operation(production_stock_id,0,0,0);
					</cfscript>
					<cfif len(product_tree_id_list)>
						<cfloop query="get_tree_operations">
							<cfset _OPERATION_TYPE_ID_ = get_tree_operations.OPERATION_TYPE_ID>
							<cfset _AMOUNT_ = get_tree_operations.AMOUNT>
                            <cfstoredproc procedure="GET_WORKSTATIONS_PRODUCTS" datasource="#dsn3#">
                            	<cfprocparam cfsqltype="cf_sql_integer" value="#_OPERATION_TYPE_ID_#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#production_stock_id#">
                                <cfprocresult name="GET_OPERATIONS_STATIONS">
                            </cfstoredproc>
                            <!--- OPERASYON EKLENİYOR --->
							<cfstoredproc procedure="ADD_PRODUCTION_OPERATION" datasource="#dsn3#">	
                                <cfprocparam cfsqltype="cf_sql_integer" value="#GET_MAX.PID#">	
                                <cfif GET_OPERATIONS_STATIONS.recordcount>
                                    <cfprocparam cfsqltype="cf_sql_integer" value="#GET_OPERATIONS_STATIONS.STATION_ID#">
                                <cfelse>
                                    <cfprocparam cfsqltype="cf_sql_integer" value="NULL" null="yes">
                                </cfif>
                                <cfif GET_OPERATIONS_STATIONS.recordcount>
                                    <cfprocparam cfsqltype="cf_sql_float" value="#GET_OPERATIONS_STATIONS.PRODUCTION_TIME#">
                                <cfelse>
                                    <cfprocparam cfsqltype="cf_sql_float" value="NULL" null="yes">
                                </cfif>
                                <cfprocparam cfsqltype="cf_sql_integer" value="#_OPERATION_TYPE_ID_#">
                                <cfprocparam cfsqltype="cf_sql_float" value="#_AMOUNT_*quantity#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
                                <cfprocparam cfsqltype="cf_sql_timestamp" value="#now()#">
                                <cfprocparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="0">
							</cfstoredproc>
                        </cfloop>
                    </cfif>
                    <!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
                    <cfif isdefined('attributes.master_alt_plan_id')>
                    	<cfif attributes.islem_id eq -1> <!---IFLOW Üretim Programından Geliyorsa--->
    					
                        <cfelse> <!---Master Plandan Geliyorsa--->
							<cfif isdefined('attributes.station_id_#prod_ind#_#sayac#') and len(ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#sayac#'),1,',')) and ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#sayac#'),1,',') gt 0>
                                <cfset e_station_id = #ListGetAt(Evaluate('attributes.station_id_#prod_ind#_#sayac#'),1,',')#>
                                <cfquery name="ADD_MASTER_PLAN_RELATION" datasource="#dsn3#">
                                    INSERT INTO   
                                        EZGI_MASTER_PLAN_RELATIONS
                                        (
                                        MASTER_ALT_PLAN_ID, 
                                        PROCESS, 
                                        P_ORDER_ID, 
                                        PROCESS_ID, 
                                        MASTER_PLAN_ID,
                                        STATION_ID
                                        )
                                    VALUES
                                        (
                                        <cfif isdefined('MASTER_ALT_PLAN_ID_#e_station_id#')>#Evaluate('MASTER_ALT_PLAN_ID_#e_station_id#')#<cfelse>NULL</cfif>,
                                        'Üretim Planı',
                                        #GET_MAX.PID#,
                                        <cfif isdefined('PROCESS_ID_#e_station_id#')>#Evaluate('PROCESS_ID_#e_station_id#')#<cfelse>NULL</cfif>,
                                        <cfif isdefined('MASTER_PLAN_ID_#e_station_id#')>#Evaluate('MASTER_PLAN_ID_#e_station_id#')#<cfelse>NULL</cfif>,
                                        #e_station_id#
                                        )       
                                </cfquery>
                                <cfif isdefined('IS_RESERVED_#e_station_id#') and Evaluate('IS_RESERVED_#e_station_id#') eq 0><!--- Eğer Master Alt Plan Stok Rezervasyon Değilse Yeni Açılan Emirler de Rezerve edilmemeli--->
                                    <cfquery name="UPD_P_ORDERS_STOCK_RESERVED" datasource="#DSN3#">
                                       	UPDATE    
                                            PRODUCTION_ORDERS
                                        SET                
                                            IS_STOCK_RESERVED = 0
                                        WHERE        
                                            P_ORDER_ID = #GET_MAX.PID# 
                                    </cfquery>
                                </cfif>
                            </cfif>
                            <cfif len(Evaluate('attributes.order_row_id_#prod_ind#')) and Evaluate('attributes.order_row_id_#prod_ind#') gt 0>
                            	<cfquery name="UPD_ORDERS" datasource="#DSN3#">
                                	UPDATE    
                                    	PRODUCTION_ORDERS
									SET                
                                    	ORDER_ROW_ID =#Evaluate('attributes.order_row_id_#prod_ind#')#
									WHERE        
                                    	P_ORDER_ID = #GET_MAX.PID#
                                </cfquery>
                            </cfif>
                        </cfif>
                    </cfif>
                    <!---Ezgi Bilgisayar Özelleştirme Bitişi--->
					<cfif not isdefined("attributes.kontrol_order_#prod_ind#")><cfset "attributes.kontrol_order_#prod_ind#" = 1></cfif>
					<cfloop from="1" to="#listlen(Evaluate('attributes.order_row_id_#prod_ind#'),',')#" index="i">
						<!--- URETIM EMRI SIPARIS ILISKISI ILGILI TABLOYA EKLENIYOR. --->
						<cfif len(Evaluate('attributes.order_row_id_#prod_ind#')) and Evaluate('attributes.order_row_id_#prod_ind#') gt 0 and evaluate("attributes.kontrol_order_#prod_ind#") eq 1>
                             <cfstoredproc procedure="ADD_PRODUCTION_ORDERS_ROW" datasource="#DSN3#">
                             	<cfprocparam cfsqltype="cf_sql_integer" value="#get_max.pid#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#listgetat(Evaluate('attributes.order_id_#prod_ind#'),i,',')#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#listgetat(Evaluate('attributes.order_row_id_#prod_ind#'),i,',')#">
                                <cfif attributes.is_stage eq -1>
                                	<cfprocparam cfsqltype="cf_sql_integer" value="0">
								<cfelse>
                                	<cfprocparam cfsqltype="cf_sql_integer" value="1">
								</cfif>    
                             </cfstoredproc>
						</cfif>
					</cfloop>
					<!--- üretim emrine sarf ekleniyor --->
					<cfparam name="phantom_stock_id_list" default="0">
					<cfparam name="phantom_spec_main_id_list" default="0">
					<cfparam name="phantom_line_number_list" default="0">
					<cfset phantom_stock_id_list = ''>
					<cfset phantom_spec_main_id_list = ''>
					<cfset phantom_line_number_list = ''>
					<cfset main_product_spec_main_id = spect_main_id___>
					<cfif isdefined("main_product_spec_main_id") and main_product_spec_main_id gt 0>
						<cfscript>
							writeTree_order(main_product_spec_main_id,1);
						</cfscript>
					</cfif>
					<cfquery name="get_sub_product" datasource="#dsn3#">
						SELECT
							SPECT_MAIN_ROW.RELATED_MAIN_SPECT_ID,
							SPECT_MAIN_ROW.AMOUNT AS AMOUNT, 
							ISNULL(SPECT_MAIN_ROW.IS_FREE_AMOUNT,0) AS IS_FREE_AMOUNT,
							STOCKS.PRODUCT_ID,
							STOCKS.STOCK_ID,
							PRODUCT_UNIT.PRODUCT_UNIT_ID,
							0 IS_PHANTOM,
							SPECT_MAIN_ROW.IS_SEVK,
							SPECT_MAIN_ROW.IS_PROPERTY,
							ISNULL(SPECT_MAIN_ROW.FIRE_AMOUNT,0) FIRE_AMOUNT,
							ISNULL(SPECT_MAIN_ROW.FIRE_RATE,0) FIRE_RATE,
							0 AS SUB_SPEC_MAIN_ID,
							SPECT_MAIN_ROW.SPECT_MAIN_ROW_ID,
                            ISNULL(SPECT_MAIN_ROW.LINE_NUMBER,0) LINE_NUMBER,
                            ISNULL(SPECT_MAIN_ROW.LINE_NUMBER,0) MAIN_LINE_NUMBER
						FROM
							SPECT_MAIN WITH (NOLOCK),
							SPECT_MAIN_ROW WITH (NOLOCK),
							STOCKS WITH (NOLOCK),
							PRODUCT_UNIT WITH (NOLOCK),
							PRICE_STANDART WITH (NOLOCK)
						WHERE
							PRICE_STANDART.PRICESTANDART_STATUS = 1 AND
							PRICE_STANDART.PURCHASESALES = 1 AND
							PRICE_STANDART.PRODUCT_ID = STOCKS.PRODUCT_ID AND
							STOCKS.STOCK_STATUS = 1	AND
							SPECT_MAIN.SPECT_MAIN_ID = #spect_main_id___# AND
							SPECT_MAIN.SPECT_MAIN_ID = SPECT_MAIN_ROW.SPECT_MAIN_ID AND
							SPECT_MAIN_ROW.STOCK_ID = STOCKS.STOCK_ID AND
							SPECT_MAIN_ROW.IS_PROPERTY IN(0,4) AND
							ISNULL(SPECT_MAIN_ROW.IS_PHANTOM,0)=0 AND
							PRODUCT_UNIT.PRODUCT_UNIT_ID = STOCKS.PRODUCT_UNIT_ID AND
							STOCKS.PRODUCT_UNIT_ID=PRICE_STANDART.UNIT_ID AND
							STOCKS.STOCK_ID NOT IN (0)
							<cfif len(phantom_stock_id_list)><!--- FANTOM ÜRÜNLERİ SARF LİSTESİNDEN ÇIKARIYORUZ.AŞAĞIDA FHANTOMLARIN SPECLERİNDEN FAYDALANARAK BU ÇIKARTTIĞIMIZ ÜRÜNÜN BİLEŞENLERİNİ DAHİL EDİCEZ.. --->
								AND STOCKS.STOCK_ID NOT IN (#phantom_stock_id_list#)
							</cfif>
						<cfif phantom_spec_main_id_list gt 0><!--- eğer phantom ürün var ise... --->
                        	<cfif isdefined('phantom_line_number_list') and len(phantom_line_number_list)><!---**** sira numarasina gore sarflar listelenmek istendiginde fantom urunlerin siralari karisikliga yol aciyordu. Sıra numaralarına gore loop yaparak bir ust sira numarasini tutmak icin yapıldı.  --->
                            	<cfloop from="1" to="#listlen(phantom_line_number_list)#" index="ln">
                                    UNION ALL
                                        SELECT
                                            SPECT_MAIN_ROW.RELATED_MAIN_SPECT_ID,
                                            SPECT_MAIN_ROW.AMOUNT AS AMOUNT, 
                                            ISNULL(SPECT_MAIN_ROW.IS_FREE_AMOUNT,0) AS IS_FREE_AMOUNT,
                                            STOCKS.PRODUCT_ID,
                                            STOCKS.STOCK_ID,
                                            PRODUCT_UNIT.PRODUCT_UNIT_ID,
                                            1 IS_PHANTOM,
                                            SPECT_MAIN_ROW.IS_SEVK,
                                            SPECT_MAIN_ROW.IS_PROPERTY,
                                            ISNULL(SPECT_MAIN_ROW.FIRE_AMOUNT,0) FIRE_AMOUNT,
                                            ISNULL(SPECT_MAIN_ROW.FIRE_RATE,0) FIRE_RATE,
                                            SPECT_MAIN.SPECT_MAIN_ID AS SUB_SPEC_MAIN_ID,<!--- BU ALAN SARF SATIRINA GELEN ÜRÜNÜN HANGİ SPEC'E BAĞLI OLDUĞUNU GÖSTERMEK İÇİN KONULDU.. --->
                                            SPECT_MAIN_ROW.SPECT_MAIN_ROW_ID,
                                            ISNULL(SPECT_MAIN_ROW.LINE_NUMBER,0) LINE_NUMBER,
                            				#listgetat(phantom_line_number_list,ln)# MAIN_LINE_NUMBER<!--- SARFIN BAGLI OLDUGU URUNUN SIRA NUMARASINI GETIRIYORUZ. FANTOM URUNLERIN SIRAYI BOZMAMASI ICIN GEREKIYOR. --->
                                        FROM
                                            SPECT_MAIN WITH (NOLOCK),
                                            SPECT_MAIN_ROW WITH (NOLOCK),
                                            STOCKS WITH (NOLOCK),
                                            PRODUCT_UNIT WITH (NOLOCK),
                                            PRICE_STANDART WITH (NOLOCK)
                                        WHERE
                                            PRICE_STANDART.PRICESTANDART_STATUS = 1 AND
                                            PRICE_STANDART.PURCHASESALES = 1 AND
                                            PRICE_STANDART.PRODUCT_ID = STOCKS.PRODUCT_ID AND
                                            STOCKS.STOCK_STATUS = 1	AND
                                            SPECT_MAIN.SPECT_MAIN_ID IN (#listgetat(phantom_spec_main_id_list,ln)#) AND
                                            SPECT_MAIN.SPECT_MAIN_ID = SPECT_MAIN_ROW.SPECT_MAIN_ID AND
                                            SPECT_MAIN_ROW.STOCK_ID = STOCKS.STOCK_ID AND
                                            SPECT_MAIN_ROW.IS_PROPERTY IN(0,4) AND
                                            ISNULL(SPECT_MAIN_ROW.IS_PHANTOM,0)=0 AND
                                            <cfif get_max.is_demontaj eq 1> SPECT_MAIN_ROW.IS_SEVK = 0 AND</cfif> <!--- IS_PROPERTY = 0 YANI SADE CE SARFLAR GELSİN. --->
                                            PRODUCT_UNIT.PRODUCT_UNIT_ID = STOCKS.PRODUCT_UNIT_ID AND
                                            STOCKS.PRODUCT_UNIT_ID=PRICE_STANDART.UNIT_ID
                                </cfloop>
                            <cfelse>
                                UNION ALL
                                    SELECT
                                        SPECT_MAIN_ROW.RELATED_MAIN_SPECT_ID,
                                        SPECT_MAIN_ROW.AMOUNT AS AMOUNT, 
                                        ISNULL(SPECT_MAIN_ROW.IS_FREE_AMOUNT,0) AS IS_FREE_AMOUNT,
                                        STOCKS.PRODUCT_ID,
                                        STOCKS.STOCK_ID,
                                        PRODUCT_UNIT.PRODUCT_UNIT_ID,
                                        1 IS_PHANTOM,
                                        SPECT_MAIN_ROW.IS_SEVK,
                                        SPECT_MAIN_ROW.IS_PROPERTY,
                                        ISNULL(SPECT_MAIN_ROW.FIRE_AMOUNT,0) FIRE_AMOUNT,
                                        ISNULL(SPECT_MAIN_ROW.FIRE_RATE,0) FIRE_RATE,
                                        SPECT_MAIN.SPECT_MAIN_ID AS SUB_SPEC_MAIN_ID,<!--- BU ALAN SARF SATIRINA GELEN ÜRÜNÜN HANGİ SPEC'E BAĞLI OLDUĞUNU GÖSTERMEK İÇİN KONULDU.. --->
                                        SPECT_MAIN_ROW.SPECT_MAIN_ROW_ID,
                                        ISNULL(SPECT_MAIN_ROW.LINE_NUMBER,0) LINE_NUMBER,
                                        ISNULL(SPECT_MAIN_ROW.LINE_NUMBER,0) MAIN_LINE_NUMBER
                                    FROM
                                        SPECT_MAIN WITH (NOLOCK),
                                        SPECT_MAIN_ROW WITH (NOLOCK),
                                        STOCKS WITH (NOLOCK),
                                        PRODUCT_UNIT WITH (NOLOCK),
                                        PRICE_STANDART WITH (NOLOCK)
                                    WHERE
                                        PRICE_STANDART.PRICESTANDART_STATUS = 1 AND
                                        PRICE_STANDART.PURCHASESALES = 1 AND
                                        PRICE_STANDART.PRODUCT_ID = STOCKS.PRODUCT_ID AND
                                        STOCKS.STOCK_STATUS = 1	AND
                                        SPECT_MAIN.SPECT_MAIN_ID IN (#phantom_spec_main_id_list#) AND
                                        SPECT_MAIN.SPECT_MAIN_ID = SPECT_MAIN_ROW.SPECT_MAIN_ID AND
                                        SPECT_MAIN_ROW.STOCK_ID = STOCKS.STOCK_ID AND
                                        SPECT_MAIN_ROW.IS_PROPERTY IN(0,4) AND
                                        ISNULL(SPECT_MAIN_ROW.IS_PHANTOM,0)=0 AND
                                        <cfif get_max.is_demontaj eq 1> SPECT_MAIN_ROW.IS_SEVK = 0 AND</cfif> <!--- IS_PROPERTY = 0 YANI SADE CE SARFLAR GELSİN. --->
                                        PRODUCT_UNIT.PRODUCT_UNIT_ID = STOCKS.PRODUCT_UNIT_ID AND
                                        STOCKS.PRODUCT_UNIT_ID=PRICE_STANDART.UNIT_ID
                            </cfif>
						</cfif>
                        <cfif isdefined('attributes.is_line_number') and attributes.is_line_number eq 1>
                            ORDER BY
                            	MAIN_LINE_NUMBER,
                                LINE_NUMBER
                        </cfif>
					</cfquery>
					<cfif get_sub_product.recordcount>
						<cfoutput query="get_sub_product">
							<cfset _AMOUNT_ = AMOUNT>
							<cfif isdefined('multipler_#SUB_SPEC_MAIN_ID#')>
								<cfset _AMOUNT_ =  Evaluate('multipler_#SUB_SPEC_MAIN_ID#')*AMOUNT>
							</cfif>
							<cfif is_free_amount eq 1>
                                <cfset amount_ = _AMOUNT_>
                            <cfelse>
                                <cfset amount_ = _AMOUNT_ * get_max.AMOUNT>
                            </cfif>
							<cfset wrk_id_new_sarf = 'WRK#round(rand()*65)##dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmssL')##session.ep.userid##round(rand()*100)#U#get_max.pid#S#STOCK_ID#'>
                            <cfstoredproc procedure="ADD_PRODUCTION_ORDERS_STOCKS" datasource="#dsn3#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#get_max.pid#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#PRODUCT_ID#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#STOCK_ID#">
                                <cfif len(RELATED_MAIN_SPECT_ID)>
                                    <cfprocparam cfsqltype="cf_sql_integer" value="#RELATED_MAIN_SPECT_ID#">
                                <cfelse>
                                    <cfprocparam cfsqltype="cf_sql_integer" value="NULL" null="yes">
                                </cfif>
                                <cfprocparam cfsqltype="cf_sql_float" value="#amount_#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="2">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#PRODUCT_UNIT_ID#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
                                <cfprocparam cfsqltype="cf_sql_timestamp" value="#now()#">
                                <cfprocparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">
                                <cfprocparam cfsqltype="cf_sql_bit" value="#IS_PHANTOM#">
                                <cfprocparam cfsqltype="cf_sql_bit" value="#IS_SEVK#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#IS_PROPERTY#">
                                <cfprocparam cfsqltype="cf_sql_bit" value="#IS_FREE_AMOUNT#">
                                <cfprocparam cfsqltype="cf_sql_float" value="#FIRE_AMOUNT#">
                                <cfprocparam cfsqltype="cf_sql_float" value="#FIRE_RATE#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#SPECT_MAIN_ROW_ID#">
                                <cfprocparam cfsqltype="cf_sql_bit" value="1">
                                <cfprocparam cfsqltype="cf_sql_varchar" value="#wrk_id_new_sarf#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#MAIN_LINE_NUMBER#">
                            </cfstoredproc>
						</cfoutput>
					</cfif>
                    <!--- URETIM EMRINE FIRE EKLENIYOR. --->
                  <!---  <cfstoredproc procedure="GET_SUB_PRODUCT_FIRE" datasource="#dsn3#">
                    	<cfprocparam cfsqltype="cf_sql_integer" value="#spect_main_id___#">
                        <cfprocresult name="GET_SUB_PRODUCT_FIRE">
                    </cfstoredproc>--->
                    <cfquery name="GET_SUB_PRODUCT_FIRE" datasource="#dsn3#">
                    	SELECT
                                SPECT_MAIN_ROW.RELATED_MAIN_SPECT_ID,
                                CASE WHEN (ISNULL(SPECT_MAIN_ROW.FIRE_AMOUNT,0) <> 0)
                                THEN
                                    SPECT_MAIN_ROW.FIRE_AMOUNT
                                ELSE
                                    CASE WHEN (ISNULL(SPECT_MAIN_ROW.FIRE_RATE,0) <> 0)
                                    THEN
                                    SPECT_MAIN_ROW.AMOUNT*SPECT_MAIN_ROW.FIRE_RATE/100
                                    ELSE
                                    SPECT_MAIN_ROW.AMOUNT
                                    END
                                END AS AMOUNT ,
                                ISNULL(SPECT_MAIN_ROW.IS_FREE_AMOUNT,0) AS IS_FREE_AMOUNT,
                                STOCKS.PRODUCT_ID,
                                STOCKS.STOCK_ID,
                                PRODUCT_UNIT.PRODUCT_UNIT_ID,
                                0 AS IS_PHANTOM,
                                SPECT_MAIN_ROW.IS_SEVK,
                                SPECT_MAIN_ROW.IS_PROPERTY,
                                ISNULL(SPECT_MAIN_ROW.FIRE_AMOUNT,0) FIRE_AMOUNT,
                                ISNULL(SPECT_MAIN_ROW.FIRE_RATE,0) FIRE_RATE,
                                SPECT_MAIN.SPECT_MAIN_ID AS SUB_SPEC_MAIN_ID,
                                SPECT_MAIN_ROW.SPECT_MAIN_ROW_ID,
                                SPECT_MAIN_ROW.LINE_NUMBER,
                                ISNULL(SPECT_MAIN_ROW.LINE_NUMBER,0) MAIN_LINE_NUMBER
                            FROM
                                SPECT_MAIN WITH (NOLOCK),
                                SPECT_MAIN_ROW WITH (NOLOCK),
                                STOCKS WITH (NOLOCK),
                                PRODUCT_UNIT WITH (NOLOCK),
                                PRICE_STANDART WITH (NOLOCK)
                            WHERE
                                PRICE_STANDART.PRICESTANDART_STATUS = 1 AND
                                PRICE_STANDART.PURCHASESALES = 1 AND
                                PRICE_STANDART.PRODUCT_ID = STOCKS.PRODUCT_ID AND
                                STOCKS.STOCK_STATUS = 1	AND
                                ISNULL(IS_PHANTOM,0) = 0 AND
                                SPECT_MAIN.SPECT_MAIN_ID = #spect_main_id___# AND
                                SPECT_MAIN.SPECT_MAIN_ID = SPECT_MAIN_ROW.SPECT_MAIN_ID AND
                                SPECT_MAIN_ROW.STOCK_ID = STOCKS.STOCK_ID AND
                                (ISNULL(SPECT_MAIN_ROW.FIRE_AMOUNT,0)<>0 OR ISNULL(SPECT_MAIN_ROW.FIRE_RATE,0)<>0)  AND
                                PRODUCT_UNIT.PRODUCT_UNIT_ID = STOCKS.PRODUCT_UNIT_ID AND
                                STOCKS.PRODUCT_UNIT_ID=PRICE_STANDART.UNIT_ID
                                <cfif len(phantom_stock_id_list)><!--- FANTOM ÜRÜNLERİ SARF LİSTESİNDEN ÇIKARIYORUZ.AŞAĞIDA FHANTOMLARIN SPECLERİNDEN FAYDALANARAK BU ÇIKARTTIĞIMIZ ÜRÜNÜN BİLEŞENLERİNİ DAHİL EDİCEZ.. --->
								AND STOCKS.STOCK_ID NOT IN (#phantom_stock_id_list#)
							</cfif>
                                <cfif phantom_spec_main_id_list gt 0><!--- eğer phantom ürün var ise... --->
                        	<cfif isdefined('phantom_line_number_list') and len(phantom_line_number_list)><!---**** sira numarasina gore sarflar listelenmek istendiginde fantom urunlerin siralari karisikliga yol aciyordu. Sıra numaralarına gore loop yaparak bir ust sira numarasini tutmak icin yapıldı.  --->
                            	<cfloop from="1" to="#listlen(phantom_line_number_list)#" index="ln">
                                    UNION ALL
                                        SELECT
                                            SPECT_MAIN_ROW.RELATED_MAIN_SPECT_ID,
                                             CASE WHEN (ISNULL(SPECT_MAIN_ROW.FIRE_AMOUNT,0) <> 0)
                                            THEN
                                                SPECT_MAIN_ROW.FIRE_AMOUNT
                                            ELSE
                                                CASE WHEN (ISNULL(SPECT_MAIN_ROW.FIRE_RATE,0) <> 0)
                                                THEN
                                                SPECT_MAIN_ROW.AMOUNT*SPECT_MAIN_ROW.FIRE_RATE/100
                                                ELSE
                                                SPECT_MAIN_ROW.AMOUNT
                                                END
                                            END AS AMOUNT ,
                                            ISNULL(SPECT_MAIN_ROW.IS_FREE_AMOUNT,0) AS IS_FREE_AMOUNT,
                                            STOCKS.PRODUCT_ID,
                                            STOCKS.STOCK_ID,
                                            PRODUCT_UNIT.PRODUCT_UNIT_ID,
                                            1 IS_PHANTOM,
                                            SPECT_MAIN_ROW.IS_SEVK,
                                            SPECT_MAIN_ROW.IS_PROPERTY,
                                            ISNULL(SPECT_MAIN_ROW.FIRE_AMOUNT,0) FIRE_AMOUNT,
                                            ISNULL(SPECT_MAIN_ROW.FIRE_RATE,0) FIRE_RATE,
                                            SPECT_MAIN.SPECT_MAIN_ID AS SUB_SPEC_MAIN_ID,<!--- BU ALAN SARF SATIRINA GELEN ÜRÜNÜN HANGİ SPEC'E BAĞLI OLDUĞUNU GÖSTERMEK İÇİN KONULDU.. --->
                                            SPECT_MAIN_ROW.SPECT_MAIN_ROW_ID,
                                            ISNULL(SPECT_MAIN_ROW.LINE_NUMBER,0) LINE_NUMBER,
                            				#listgetat(phantom_line_number_list,ln)# MAIN_LINE_NUMBER<!--- SARFIN BAGLI OLDUGU URUNUN SIRA NUMARASINI GETIRIYORUZ. FANTOM URUNLERIN SIRAYI BOZMAMASI ICIN GEREKIYOR. --->
                                        FROM
                                            SPECT_MAIN WITH (NOLOCK),
                                            SPECT_MAIN_ROW WITH (NOLOCK),
                                            STOCKS WITH (NOLOCK),
                                            PRODUCT_UNIT WITH (NOLOCK),
                                            PRICE_STANDART WITH (NOLOCK)
                                        WHERE
                                            PRICE_STANDART.PRICESTANDART_STATUS = 1 AND
                                            PRICE_STANDART.PURCHASESALES = 1 AND
                                            PRICE_STANDART.PRODUCT_ID = STOCKS.PRODUCT_ID AND
                                            STOCKS.STOCK_STATUS = 1	AND
                                            SPECT_MAIN.SPECT_MAIN_ID IN (#listgetat(phantom_spec_main_id_list,ln)#) AND
                                            SPECT_MAIN.SPECT_MAIN_ID = SPECT_MAIN_ROW.SPECT_MAIN_ID AND
                                            SPECT_MAIN_ROW.STOCK_ID = STOCKS.STOCK_ID AND
                                            SPECT_MAIN_ROW.IS_PROPERTY IN(0,4) AND

                                            (ISNULL(SPECT_MAIN_ROW.FIRE_AMOUNT,0)<>0 OR ISNULL(SPECT_MAIN_ROW.FIRE_RATE,0)<>0)  AND
                                            ISNULL(SPECT_MAIN_ROW.IS_PHANTOM,0)=0 AND
                                            <cfif get_max.is_demontaj eq 1> SPECT_MAIN_ROW.IS_SEVK = 0 AND</cfif> <!--- IS_PROPERTY = 0 YANI SADE CE SARFLAR GELSİN. --->
                                            PRODUCT_UNIT.PRODUCT_UNIT_ID = STOCKS.PRODUCT_UNIT_ID AND
                                            STOCKS.PRODUCT_UNIT_ID=PRICE_STANDART.UNIT_ID
                                </cfloop>
                            <cfelse>
                                UNION ALL
                                    SELECT
                                        SPECT_MAIN_ROW.RELATED_MAIN_SPECT_ID,
                                         CASE WHEN (ISNULL(SPECT_MAIN_ROW.FIRE_AMOUNT,0) <> 0)
                                        THEN
                                            SPECT_MAIN_ROW.FIRE_AMOUNT
                                        ELSE
                                            CASE WHEN (ISNULL(SPECT_MAIN_ROW.FIRE_RATE,0) <> 0)
                                            THEN
                                            SPECT_MAIN_ROW.AMOUNT*SPECT_MAIN_ROW.FIRE_RATE/100
                                            ELSE
                                            SPECT_MAIN_ROW.AMOUNT
                                            END
                                        END AS AMOUNT ,
                                        ISNULL(SPECT_MAIN_ROW.IS_FREE_AMOUNT,0) AS IS_FREE_AMOUNT,
                                        STOCKS.PRODUCT_ID,
                                        STOCKS.STOCK_ID,
                                        PRODUCT_UNIT.PRODUCT_UNIT_ID,
                                        1 IS_PHANTOM,
                                        SPECT_MAIN_ROW.IS_SEVK,
                                        SPECT_MAIN_ROW.IS_PROPERTY,
                                        ISNULL(SPECT_MAIN_ROW.FIRE_AMOUNT,0) FIRE_AMOUNT,
                                        ISNULL(SPECT_MAIN_ROW.FIRE_RATE,0) FIRE_RATE,
                                        SPECT_MAIN.SPECT_MAIN_ID AS SUB_SPEC_MAIN_ID,<!--- BU ALAN SARF SATIRINA GELEN ÜRÜNÜN HANGİ SPEC'E BAĞLI OLDUĞUNU GÖSTERMEK İÇİN KONULDU.. --->
                                        SPECT_MAIN_ROW.SPECT_MAIN_ROW_ID,
                                        ISNULL(SPECT_MAIN_ROW.LINE_NUMBER,0) LINE_NUMBER,
                                        ISNULL(SPECT_MAIN_ROW.LINE_NUMBER,0) MAIN_LINE_NUMBER
                                    FROM
                                        SPECT_MAIN WITH (NOLOCK),
                                        SPECT_MAIN_ROW WITH (NOLOCK),
                                        STOCKS WITH (NOLOCK),
                                        PRODUCT_UNIT WITH (NOLOCK),
                                        PRICE_STANDART WITH (NOLOCK)
                                    WHERE
                                        PRICE_STANDART.PRICESTANDART_STATUS = 1 AND
                                        PRICE_STANDART.PURCHASESALES = 1 AND
                                        PRICE_STANDART.PRODUCT_ID = STOCKS.PRODUCT_ID AND
                                        STOCKS.STOCK_STATUS = 1	AND
                                        SPECT_MAIN.SPECT_MAIN_ID IN (#phantom_spec_main_id_list#) AND
                                        SPECT_MAIN.SPECT_MAIN_ID = SPECT_MAIN_ROW.SPECT_MAIN_ID AND
                                        SPECT_MAIN_ROW.STOCK_ID = STOCKS.STOCK_ID AND
                                        (ISNULL(SPECT_MAIN_ROW.FIRE_AMOUNT,0)<>0 OR ISNULL(SPECT_MAIN_ROW.FIRE_RATE,0)<>0)  AND
                                        SPECT_MAIN_ROW.IS_PROPERTY IN(0,4) AND
                                        ISNULL(SPECT_MAIN_ROW.IS_PHANTOM,0)=0 AND
                                        <cfif get_max.is_demontaj eq 1> SPECT_MAIN_ROW.IS_SEVK = 0 AND</cfif> <!--- IS_PROPERTY = 0 YANI SADE CE SARFLAR GELSİN. --->
                                        PRODUCT_UNIT.PRODUCT_UNIT_ID = STOCKS.PRODUCT_UNIT_ID AND
                                        STOCKS.PRODUCT_UNIT_ID=PRICE_STANDART.UNIT_ID
                            </cfif>
						</cfif>
                    </cfquery>
					<cfif get_sub_product_fire.recordcount>
						<cfoutput query="get_sub_product_fire">
						<cfset amount_ = AMOUNT * get_max.AMOUNT>
							<cfset wrk_id_new_fire = 'WRK#round(rand()*65)##dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmssL')##session.ep.userid##round(rand()*100)#U#get_max.pid#F#STOCK_ID#'>
                            <cfstoredproc procedure="ADD_PRODUCTION_ORDERS_STOCKS" datasource="#dsn3#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#get_max.pid#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#PRODUCT_ID#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#STOCK_ID#">
                                <cfif len(RELATED_MAIN_SPECT_ID)>
                                    <cfprocparam cfsqltype="cf_sql_integer" value="#RELATED_MAIN_SPECT_ID#">
                                <cfelse>
                                    <cfprocparam cfsqltype="cf_sql_integer" value="NULL" null="yes">
                                </cfif>
                                <cfprocparam cfsqltype="cf_sql_float" value="#amount_#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="3">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#PRODUCT_UNIT_ID#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
                                <cfprocparam cfsqltype="cf_sql_timestamp" value="#now()#">
                                <cfprocparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">
                                <cfprocparam cfsqltype="cf_sql_bit" value="#0#">
                                <cfprocparam cfsqltype="cf_sql_bit" value="#IS_SEVK#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#IS_PROPERTY#">
                                <cfprocparam cfsqltype="cf_sql_bit" value="#IS_FREE_AMOUNT#">
                                <cfprocparam cfsqltype="cf_sql_float" value="#FIRE_AMOUNT#">
                                <cfprocparam cfsqltype="cf_sql_float" value="#FIRE_RATE#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#SPECT_MAIN_ROW_ID#">
                                <cfprocparam cfsqltype="cf_sql_bit" value="1">
                                <cfprocparam cfsqltype="cf_sql_varchar" value="#wrk_id_new_fire#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#LINE_NUMBER#">
                            </cfstoredproc>
						</cfoutput>
					</cfif>
                </cfif>

    </cfif>
</cfloop>
<cfquery name="GET_PAPER" datasource="#dsn3#">
	SELECT P_ORDER_NO, QUANTITY FROM PRODUCTION_ORDERS WHERE P_ORDER_ID = #Evaluate('po_related_id_#prod_ind#_0')#
</cfquery>
<!---Ezgi Yazılım Özelleştirme Bitiş--->
<!--- İsbak Üretim Emri Seri No Generate py  Silindi--->
<cfset my_stock_id = ListGetAt(Evaluate('attributes.product_values_#prod_ind#_0'),1,',')>
<cfquery name="get_product_guaranty" datasource="#dsn3#">
	SELECT 
     	STOCK_CODE,
     	ISNULL(IS_SERIAL_NO,0) AS IS_SERIAL_NO,
     	PRODUCT_ID
  	FROM 
   		STOCKS
 	WHERE 
    	STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#my_stock_id#">
</cfquery>
<cfif get_product_guaranty.IS_SERIAL_NO gt 0><!--- Üretilen Üründe Seri No varsa Ön Bağlama Kayıtları Atıyorum--->
	<cfif GET_PAPER.QUANTITY gt 0>
        <!---<cfif len(Evaluate('attributes.order_row_id_#prod_ind#')) and Evaluate('attributes.order_row_id_#prod_ind#') gt 1>
    	    <cfset ezgi_product_amount = GET_PAPER.QUANTITY -1> <!--- Siparişe Dayalı Üretim ise Açılmış Olan kendisini Çıkarıyorum ve Miktar kadar ek bağlama alanları açıyorum.--->
        <cfelse>
            <cfset ezgi_product_amount = GET_PAPER.QUANTITY> <!---Stoğa Dayalı Üretim ise Miktar kadar ek bağlama alanları açıyorum.--->
        </cfif>--->
        
        <cfset ezgi_product_amount = GET_PAPER.QUANTITY>
        
        <!---Önce Açılan Bağlantıları siliyorum--->
         <cfif len(Evaluate('attributes.order_row_id_#prod_ind#')) and len(Evaluate('po_related_id_#prod_ind#_0')) and Evaluate('attributes.order_row_id_#prod_ind#') gt 1>
            <cfquery name="del_pro_ord_row" datasource="#dsn3#">
                DELETE FROM PRODUCTION_ORDERS_ROW WHERE ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#prod_ind#')# AND PRODUCTION_ORDER_ID = #Evaluate('po_related_id_#prod_ind#_0')#
            </cfquery>
        </cfif>
        <!---Sonra İhtiyaç Kadar Açıyorum--->
        <cfloop from="1" to="#ezgi_product_amount#" index="j">
            <cfquery name="add_pre_rel" datasource="#dsn3#">
            	INSERT INTO 
                	PRODUCTION_ORDERS_ROW
                   	(
                    	PRODUCTION_ORDER_ID, 
                        LOT_NO, 
                        TYPE, 
                        ORDER_ROW_ID, 
                        ORDER_ID, 
                        RECORD_DATE, 
                        RECORD_IP,
                        RECORD_EMP 
                        
               		)
         		VALUES 
                    (
                        #Evaluate('po_related_id_#prod_ind#_0')#,
                        <cfif isdefined('attributes.master_alt_plan_id') and attributes.islem_id eq -1> <!---IFLOW Üretim Programından Geliyorsa Sanal Üretim Planındaki Lot Kullanılacak--->
                            '#Replace(Evaluate('lot_no#prod_ind#'),'-','')#'
                        <cfelse>
                            '#Replace(lot_system_paper_no,'-','')#'
                        </cfif>,
                        1,
                        <cfif len(Evaluate('attributes.order_row_id_#prod_ind#')) and Evaluate('attributes.order_row_id_#prod_ind#') gt 0>
                        	<cfif Evaluate('attributes.order_id_#prod_ind#') eq Evaluate('attributes.order_row_id_#prod_ind#')>
                            	0,
                            <cfelse>
                        		#Evaluate('attributes.order_row_id_#prod_ind#')#,
                            </cfif>
                        <cfelse>
                        	NULL,
                        </cfif>
                        <cfif len(Evaluate('attributes.order_id_#prod_ind#')) and Evaluate('attributes.order_id_#prod_ind#') gt 0>
                        	<cfif Evaluate('attributes.order_id_#prod_ind#') eq Evaluate('attributes.order_row_id_#prod_ind#')>
                            	0,
                            <cfelse>
                        		#Evaluate('attributes.order_id_#prod_ind#')#,
                            </cfif>
                        <cfelse>
                        	NULL,
                        </cfif>
                        #now()#,
                        '#cgi.remote_addr#',
                        #session.ep.userid#
                    )           
            </cfquery>
            <!---Daha Önce Açılan Kayıtlara Lot No ve Record Bildgilerini Update ediyorum.--->
            <cfquery name="upd_pre_rel" datasource="#dsn3#">
                UPDATE 
                    PRODUCTION_ORDERS_ROW
                SET 
                    LOT_NO= <cfif isdefined('attributes.master_alt_plan_id') and attributes.islem_id eq -1> <!---IFLOW Üretim Programından Geliyorsa Sanal Üretim Planındaki Lot Kullanılacak--->
                                '#Replace(Evaluate('lot_no#prod_ind#'),'-','')#'
                            <cfelse>
                                '#Replace(lot_system_paper_no,'-','')#'
                            </cfif>,
                    RECORD_DATE=#now()#, 
                    RECORD_IP='#cgi.remote_addr#',
                    RECORD_EMP=#session.ep.userid#
                WHERE 
                    PRODUCTION_ORDER_ID = #Evaluate('po_related_id_#prod_ind#_0')#
            </cfquery>
        </cfloop>
       
    </cfif>
</cfif>
<!---Ezgi Yazılım Özelleştirme Bitiş--->
<cfif not isdefined("is_import_prod")>
	<cfquery name="GET_PAPER" datasource="#dsn3#">
		SELECT P_ORDER_NO FROM PRODUCTION_ORDERS WHERE P_ORDER_ID = #Evaluate('po_related_id_#prod_ind#_0')#
	</cfquery>
	<cf_workcube_process
		is_upd='1' 
        data_source='#dsn3#'
		old_process_line='0' 
		process_stage='#attributes.process_stage#' 
		record_member='#session.ep.userid#' 
		record_date='#now()#' 
		action_id='#Evaluate('po_related_id_#prod_ind#_0')#'
		action_table='PRODUCTION_ORDERS'
		action_column='P_ORDER_ID'
		action_page='#request.self#?fuseaction=prod.order&event=upd&upd=#Evaluate('po_related_id_#prod_ind#_0')#' 
		warning_description = 'Üretim Emri : #get_paper.p_order_no#'>
        <cf_add_log  log_type="1" action_id="#Evaluate('po_related_id_#prod_ind#_0')#" action_name="#get_paper.p_order_no#" paper_no="#get_paper.p_order_no#" process_stage="#attributes.process_stage#" data_source="#dsn3#">
        <cfset attributes.actionId = Evaluate('po_related_id_#prod_ind#_0')>
        <cfquery name="DELETE_PRODUCTION_ORDER_CASH" datasource="#DSN3#">
            DELETE FROM PRODUCTION_ORDERS_CASH
        </cfquery>
        <cfoutput>
        <!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
        <cfif isdefined('attributes.master_alt_plan_id') and attributes.islem_id eq -1> <!---IFLOW Üretim Programından Geliyorsa--->
        
        
        <cfelse>
			<cfif attributes.total_production_product_all eq 1>
                <cflocation url="#request.self#?fuseaction=prod.upd_ezgi_master_sub_plan_manual&master_plan_id=#attributes.master_plan_id#&master_alt_plan_id=#attributes.master_alt_plan_id#&islem_id=#attributes.islem_id#" addtoken="No">
            <cfelse>
                    <a href="#request.self#?fuseaction=prod.upd_ezgi_master_sub_plan_manual&master_plan_id=#attributes.master_plan_id#&master_alt_plan_id=#attributes.master_alt_plan_id#&islem_id=#attributes.islem_id#"> Master Alt Plana Gitmek İçin Tıklayınız!</a>
            </cfif>
     	</cfif>
        <!---Ezgi Bilgisayar Özelleştirme Bitişi--->
        </cfoutput>
</cfif>
