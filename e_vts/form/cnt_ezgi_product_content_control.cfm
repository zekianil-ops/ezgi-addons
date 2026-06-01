<!---
    File: cnt_ezgi_product_content_control.cfm
    Folder: Add_Ons\ezgi\e-vts\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
	<script language="javascript" type="text/javascript">
      var row_count_content = 0;
    </script>
    <cfparam name="attributes.add_other_amount" default="1">
    <cfparam name="attributes.del_other_amount" default="1">
    <cfquery name="get_defaults" datasource="#dsn3#">
        SELECT * FROM EZGI_SHIPPING_DEFAULTS
    </cfquery>
    <cfset attributes.sonraki_tur = 0>
    <!---Bölünmeden Önceki Paketleri Yaklamak İçin--->
    <cfquery name="get_min_p_order_id" datasource="#dsn3#">
        SELECT 
            P_ORDER_ID
        FROM     
            PRODUCTION_ORDERS
        WHERE  
            PO_RELATED_ID =
                          (
                            SELECT 
                                P_ORDER_ID
                            FROM      
                                PRODUCTION_ORDERS AS PRODUCTION_ORDERS_2
                            WHERE   
                                P_ORDER_ID =
                                            (
                                                SELECT 
                                                    PO_RELATED_ID
                                                FROM      
                                                    PRODUCTION_ORDERS AS PRODUCTION_ORDERS_1
                                                WHERE   
                                                    P_ORDER_ID = #attributes.upd#
                                            )
                        ) AND
            WRK_ROW_RELATION_ID IS NULL
        
    </cfquery>
    <cfset min_p_order_list = ValueList(get_min_p_order_id.P_ORDER_ID)> <!---Bölünmeden Önceki paketlerin IDleri--->
    <cfif not ListFind(min_p_order_list,attributes.upd)>
        <cfset attributes.sonraki_tur = 1>
    </cfif>
    <!---Bölünmeden Önceki Paketi Yaklamak İçin--->
    
    <!---BÖLÜNME KONTROLÜ BAŞLANGIÇ--->
    <!---Bu üretimin Paket Üretimleri bulunuyor--->
    <cfquery name="GET_PACKAGE" datasource="#DSN3#">
        SELECT 
            PO.P_ORDER_ID, 
            PO.LOT_NO, 
            PO.PRODUCTION_LEVEL, 
            PO.SPEC_MAIN_ID, 
            PO.WRK_ROW_RELATION_ID, 
            EP.PACKAGE_NAME
        FROM     
            PRODUCTION_ORDERS AS PO INNER JOIN
            EZGI_DESIGN_PACKAGE_ROW AS EP ON PO.SPEC_MAIN_ID = EP.PACKAGE_SPECT_RELATED_ID
        WHERE  
            PO.LOT_NO = '#get_order.LOT_NO#'
    </cfquery>
    <cfquery name="GET_SPECT_MODUL" datasource="#DSN3#">
        SELECT 
         	SPEC_MAIN_ID,
       		LOT_NO
        FROM     
            PRODUCTION_ORDERS
        WHERE  
       		LOT_NO = '#get_order.LOT_NO#' AND
         	PRODUCTION_LEVEL = '0'
    </cfquery>
    <!---Bu üretiminin speğinden başka bir lot ile üretim var mı --->
    <cfquery name="GET_OTHER_PACKAGE_LOT" datasource="#DSN3#">
    	SELECT 
         	LOT_NO
        FROM     
            PRODUCTION_ORDERS
        WHERE  
          	LOT_NO <> '#GET_SPECT_MODUL.LOT_NO#' AND 
        	SPEC_MAIN_ID = #GET_SPECT_MODUL.SPEC_MAIN_ID# AND
         	PRODUCTION_LEVEL = '0'
    </cfquery>
    <cfset lotlist = valueList(GET_OTHER_PACKAGE_LOT.LOT_NO)>
    <cfif listLen(lotlist)> <!---Eğer Başka Bir Üretim Planı Bulunduysa--->
        <cfset hata = 0>
        <cfloop list="#lotlist#" index="lotno">
        <!--- Aynı spectten Bitmiş üretim emri var mı --->
            <cfquery name="GET_OTHER_PACKAGE_LOT_INNER_SUB" datasource="#dsn3#">
                SELECT 
                    PO.IS_STAGE
                FROM     
                    PRODUCTION_ORDERS AS PO INNER JOIN
                    EZGI_DESIGN_PACKAGE_ROW AS EP ON PO.SPEC_MAIN_ID = EP.PACKAGE_SPECT_RELATED_ID
                WHERE  
                    PO.LOT_NO = '#lotno#'
                GROUP BY 
                    PO.IS_STAGE
            </cfquery>
            <cfif GET_OTHER_PACKAGE_LOT_INNER_SUB.recordcount gt 1>
                <cfset hata = 1><!--- Birden Fazla Üretim Sonuç Tipi Var (Başlamış, Bitmiş, Başlamamış gibi)--->
            <cfelse>
                <cfif GET_OTHER_PACKAGE_LOT_INNER_SUB.IS_STAGE eq 2>
                    <!--- Paketlerin Hepsi Bitmiş ise Aslında bir Şablon Bulundu Şimdi Buna bakarak Benim Üretimim Eşitleme Yapılmış mı--->
                    <cfquery name="get_this_lot_amount" datasource="#dsn3#">
                        SELECT 
                            PO.P_ORDER_ID, 
                            PO.LOT_NO, 
                            PO.PRODUCTION_LEVEL, 
                            PO.SPEC_MAIN_ID, 
                            PO.WRK_ROW_RELATION_ID, 
                            EP.PACKAGE_NAME
                        FROM     
                            PRODUCTION_ORDERS AS PO INNER JOIN
                            EZGI_DESIGN_PACKAGE_ROW AS EP ON PO.SPEC_MAIN_ID = EP.PACKAGE_SPECT_RELATED_ID
                        WHERE  
                            PO.LOT_NO = '#lotno#'
                    </cfquery>
                    <cfif GET_PACKAGE.recordcount neq get_this_lot_amount.recordcount>
                        <cfset hata = 2><!--- Paket Sayıları Eşit Değil Git Eşitle--->
                    <cfelse>
                        <cfset hata = 3><!--- Paket Sayıları Eşit Bölme İşlemi Kapalı--->	
                    </cfif>
                    <cfbreak>
                <cfelseif GET_OTHER_PACKAGE_LOT_INNER_SUB.IS_STAGE eq 1>
                    <cfset hata = 1><!--- Paketlerin Hepsi Başlamış ise--->
                </cfif>
            </cfif>
        </cfloop>
    </cfif>
    <cfif hata eq 1>
        <script type="text/javascript">
            alert("<cfoutput>#lotno# ile Başlayan Üretimin Sonlanması Gerekiyor. Bu Yüzden Devam Edemezsiniz</cfoutput> !");
        </script>
    <cfelseif hata eq 2>
        <script type="text/javascript">
            alert("Dikkat Sizden Önce Bitirilen Üretimin Bölünmüş Pakteleri Vardır. Sistem Yöneticinize Eşitle Yaptırın.!");
        </script>
    <cfelse>

    </cfif>
    <!---BÖLÜNME KONTROLÜ BİTİŞ--->
    <cfquery name="GET_CONTENT" datasource="#DSN3#">
        SELECT 
            POS.STOCK_ID, 
            CASE 
                WHEN 
                    ISNULL(S.IS_PROTOTYPE,0) = 1
                THEN
                    ISNULL(POS.SPECT_MAIN_ID,0) 
                ELSE
                    ''
            END      
               AS SPECT_MAIN_ID, 
            CASE 
                WHEN 
                    ISNULL(S.IS_PROTOTYPE,0) = 0
                THEN 
                    S.PRODUCT_NAME
                ELSE
                (
                    SELECT        
                        TOP (1) DESIGN_MAIN_NAME
                    FROM            
                        EZGI_DESIGN_MAIN_ROW
                    WHERE        
                        MAIN_SPECT_RELATED_ID = POS.SPECT_MAIN_ID
                    ORDER BY 
                        DESIGN_MAIN_ROW_ID DESC
                    UNION ALL
                    SELECT        
                        TOP (1) PACKAGE_NAME
                    FROM        
                        EZGI_DESIGN_PACKAGE_ROW
                    WHERE        
                        PACKAGE_SPECT_RELATED_ID = POS.SPECT_MAIN_ID
                    ORDER BY 
                        PACKAGE_ROW_ID DESC
                    UNION ALL
                    SELECT        
                        TOP (1) PIECE_NAME
                    FROM            
                        EZGI_DESIGN_PIECE_ROWS
                    WHERE        
                        PIECE_SPECT_RELATED_ID = POS.SPECT_MAIN_ID
                    ORDER BY 
                        PIECE_ROW_ID DESC
                )
            END	AS PRODUCT_NAME,
            FLOOR((POS.AMOUNT/PO.QUANTITY)) AS AMOUNT, 
            PU.MAIN_UNIT, 
            S.PRODUCT_CODE,
            S.PRODUCT_NAME AS NAME_PRODUCT, 
            S.BARCOD, 
            S.PROPERTY,
            0 AS CONTROL_AMOUNT,
            PO.IS_STAGE,
            ISNULL(TBL.P_ORDER_NO,0) AS P_ORDER_NO
        FROM     
            PRODUCTION_ORDERS_STOCKS AS POS INNER JOIN
            STOCKS AS S ON POS.STOCK_ID = S.STOCK_ID INNER JOIN
            PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN
            PRODUCTION_ORDERS AS PO ON POS.P_ORDER_ID = PO.P_ORDER_ID LEFT OUTER JOIN
            (
                SELECT 
                    STOCK_ID, 
                    SPEC_MAIN_ID, 
                    MAX(P_ORDER_NO) AS P_ORDER_NO, 
                    PO_RELATED_ID
                FROM      
                    PRODUCTION_ORDERS
                GROUP BY 
                    STOCK_ID, 
                    SPEC_MAIN_ID, 
                    PO_RELATED_ID
            ) AS TBL ON POS.P_ORDER_ID = TBL.PO_RELATED_ID AND POS.STOCK_ID = TBL.STOCK_ID AND POS.SPECT_MAIN_ID = TBL.SPEC_MAIN_ID
        WHERE  
            POS.P_ORDER_ID = #attributes.upd# AND 
            POS.TYPE = 2 AND 
            ISNULL(S.PACKAGE_CONTROL_TYPE, 1) = 1 
            AND FLOOR(POS.AMOUNT/PO.QUANTITY) > 0 
    </cfquery>
    <!---<cfdump var="#GET_CONTENT#">--->
    <cfset spect_main_id_list = ValueList(GET_CONTENT.SPECT_MAIN_ID)>
    <cfset product_barcode_list = ValueList(GET_CONTENT.BARCOD)>
    <cfset p_order_no_list = ValueList(GET_CONTENT.P_ORDER_NO)>
    <cfset stock_id_list = ''>
    <cfoutput query="GET_CONTENT">
        <cfset 'control_amount#STOCK_ID#_#SPECT_MAIN_ID#' = CONTROL_AMOUNT>
        <cfset stock_id_list = ListAppend(stock_id_list,'#STOCK_ID#_#SPECT_MAIN_ID#')>
    </cfoutput>
    <cfquery name="get_total_control" dbtype="query">
        SELECT sum(CONTROL_AMOUNT) as CONTROL_AMOUNT, sum(AMOUNT) AMOUNT FROM GET_CONTENT
    </cfquery>
    <td style="width:70%">
        <table style="width:100%; height:100%; vertical-align:top">
            <tr>
                <td style="height:100%; vertical-align:top">
                    <cf_box>
                        <cf_box_search>
                            <div class="form-group medium">
                                 <input name="add_other_amount" type="text" value="<cfoutput>#attributes.add_other_amount#</cfoutput>" onKeyup="return(FormatCurrency(this,event,0));" class="moneybox" style="width:35px; height:25px" >
                            </div>&nbsp;
                            <div class="form-group">
                                <input name="add_other_barcod" id="add_other_barcod" type="text" value="" onKeyDown="if(event.keyCode == 13) {return add_product_to_barkod(this.value,add_other_amount.value,1);}" style="width:120px; height:25px" <cfif hata eq 1 or hata eq 2>disabled="disabled"</cfif>>
                            </div>
                            
                        </cf_box_search>
                    </cf_box>
                    <cf_box>
                        <cf_flat_list>
                            <thead>
                                <tr>
                                    <th style="width:40px;text-align:center; height:30px; font-size:18px">Sıra</th>
                                    <th style="width:170px;text-align:center">Emir No</th>
                                    <th style="width:170px;text-align:center">Barcode</th>
                                    <th style="text-align:center">Ürün Adı</th>
                                    <th style="width:80px;text-align:center">Miktar</th>
                                    <th style="width:80px;text-align:center">Kontrol</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfif GET_CONTENT.recordcount>
                                    <input type="hidden" name="stock_id_list" value="<cfoutput>#stock_id_list#</cfoutput>">
                                    <cfoutput query="GET_CONTENT">
                                        <cfif len(GET_CONTENT.PRODUCT_NAME)>
                                            <cfset p_name = GET_CONTENT.PRODUCT_NAME>
                                        <cfelse>
                                            <cfset p_name = GET_CONTENT.NAME_PRODUCT>
                                        </cfif>
                                        <input type="hidden" id="PRODUCT_NAME#STOCK_ID#_#SPECT_MAIN_ID#" name="PRODUCT_NAME#STOCK_ID#_#SPECT_MAIN_ID#" value="#p_name#">
                                        <tr id="row#STOCK_ID#_#SPECT_MAIN_ID#" height="30">
                                            <td style="text-align:right">#currentrow#</td>
                                            <td style="text-align:center">#P_ORDER_NO#</td>
                                            <td style="text-align:center">#barcod#<cfif SPECT_MAIN_ID gt 0><font color="red">#SPECT_MAIN_ID#</font></cfif></td>
                                            <td>#p_name#</td> 
                                            <td style="text-align:right">
                                                <input type="text" name="amount#STOCK_ID#_#SPECT_MAIN_ID#" id="amount#STOCK_ID#_#SPECT_MAIN_ID#" value="#Amount#" readonly="yes" class="box" style="width:30px;text-align:right;">
                                            </td>
                                            <td style="text-align:right">
                                                <input type="text" id="control_amount#STOCK_ID#_#SPECT_MAIN_ID#" name="control_amount#STOCK_ID#_#SPECT_MAIN_ID#" readonly="yes" value="<cfif isdefined('control_amount#STOCK_ID#_#SPECT_MAIN_ID#')>#Evaluate('control_amount#STOCK_ID#_#SPECT_MAIN_ID#')#</cfif>" class="box"  style="width:30px;text-align:right;color:FF0000; font-weight:bold">
                                            </td>
                                        </tr>
                                    </cfoutput>
                                    <input type="hidden" name="changed_stock_id" value=""><!--- Bu hidden alan kontrol yapıldıkça kontrol yapılan satırı renklendirmek için kullanılıyor. --->
                                </cfif>
                            </tbody>
                        </cf_flat_list>
                    </cf_box>
                </td>
            </tr>
        </table>
    </td>
    <td style="width:30%; height:420px" valign="top">
        <cf_box>
            <table width="100%" height="100%" border="1" cellspacing="0" cellpadding="5">
                <tr>
                    <td style="font-size:16px; text-align:center; background-color:Lightgray"><cf_get_lang dictionary_id='225.Parça Miktarı'></td>
                    <td style="font-size:16px; text-align:center; background-color:Lightgray"><cf_get_lang dictionary_id='45692.Kontrol Edilen'></td>
                </tr>
                <tr>
                    <td style="height:180px; width:50%">
                        <input type="text" name="total_amount" id="total_amount" readonly="readonly" style="text-align:center;font-weight:bold;color:FF0000; font-size:92px; width:100%; border:none" value="<cfoutput>#get_total_control.AMOUNT#</cfoutput>" />
                    </td>
                    <td>
                        <input type="text" name="total_control_amount" id="total_control_amount" readonly="readonly" style="text-align:center;font-weight:bold;color:FF0000; font-size:92px; width:100%; border:none" value="<cfoutput>#get_total_control.CONTROL_AMOUNT#</cfoutput>" />
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <!---İstasyon Paket Bölme ise ve Ürün Özelleştirilebilir ise--->
                        <cfif ispackagecontrol eq 2 and get_order.IS_PROTOTYPE eq 1>
                            <a href="javascript://" onclick="pr_stop();">
                                <button type="button" name="bt_stop" id="bt_stop" style="background-color:red;font-size:32px; font-weight:bold;height:110px; <cfif ListFind(min_p_order_list,attributes.upd)and GET_CONTENT.IS_STAGE neq 1>width:49%<cfelse>width:100%</cfif>">Dur</button>
                            </a>
                            <cfif ListFind(min_p_order_list,attributes.upd) and GET_CONTENT.IS_STAGE neq 1> <!---Üretim Emri Master Paket İse (İlave Edilen Paket Değilse) ve Üretim Başla Değilse (Üretim Başlamamışsa)--->
                                &nbsp;
                                <a href="javascript://" onclick="pr_dublicate_package();">
                                    <button type="button" name="bt_dublicate_package" id="bt_dublicate_package" style="background-color:orange;font-size:32px; font-weight:bold;height:110px; width:49%" <cfif hata gt 0>disabled="disabled"</cfif>>Paket Böl</button>
                                </a>
                            </cfif>
                        <cfelse>
                            <a href="javascript://" onclick="pr_stop();">
                                <button type="button" name="bt_stop" id="bt_stop" style="background-color:red;font-size:32px; font-weight:bold;height:110px; width:100%">Dur</button>
                            </a>
                        </cfif>
                    </td>
                </tr>
            </table>
        </cf_box>
        <cfsavecontent variable="title">Seçilmiş Ürünler</cfsavecontent>
        <cf_box>
            <div id="icerik" class="content row">
                <cf_box title="#title#">
                    <cf_grid_list>
                        <thead>
                            <tr>
                                <th style="width:20px"></th>
                                <th style="width:20px">Sıra</th>
                                <th style="width:90px">Barkod</th>
                                <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                <th style="width:40px">Miktar</th>
                            </tr>
                        </thead>
                        <cfinput type="hidden" id="row_count_content" name="row_count_content" value="0">
                        <cfinput type="hidden" id="row_info_content_id" name="row_info_content_id" value="" />
                        <tbody name="table2" id="table2">
                                                    
                        </tbody>
                    </cf_grid_list>
                </cf_box>
            </div>
        </cf_box>
    </td>
    <script type="text/javascript">
        document.getElementById('add_other_barcod').focus();
        setTimeout("document.getElementById('add_other_barcod').select();",1000);	
        function add_product_to_barkod(barcode,amount,type)
        {	
            if(list_find('<cfoutput>#p_order_no_list#</cfoutput>',barcode,','))
            {
                /*var product_sql = "SELECT TOP (1) PO.STOCK_ID, ISNULL(PO.SPEC_MAIN_ID, 0) AS SPEC_MAIN_ID, S.BARCOD FROM PRODUCTION_ORDERS AS PO INNER JOIN STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID WHERE PO.P_ORDER_NO = '"+barcode+"'";*/
                /*var get_product_no = wrk_query(product_sql,'dsn3');*/
                
                var listParam = barcode;
                var get_product_no = wrk_safe_query('get_p_order_info_porderno_ezgi','dsn3',0,listParam);
                    
                if(get_product_no.STOCK_ID == undefined)
                {
                }
                else
                {
                    if(get_product_no.SPEC_MAIN_ID >0)
                        barcode = get_product_no.BARCOD+get_product_no.SPEC_MAIN_ID;
                    else
                        barcode = get_product_no.BARCOD;
                }
            }
            uzunluk = barcode.length;
            spect = 0;
            ean = <cfoutput>#get_defaults.EAN#</cfoutput>;
            if (uzunluk ==0)
            {
                alert("<cf_get_lang dictionary_id='62746.Barkod Giriniz'>");
                document.getElementById('add_other_barcod').value = '';
                document.getElementById('add_other_barcod').focus();
                return false;
            }
            if(uzunluk > ean)
            {
                spect = barcode.substring(ean,uzunluk);
                barcode = barcode.substring(0,ean);
            }
            var amount = filterNum(amount,0)
            
            if(spect > 0)
            {
                if(list_find('<cfoutput>#spect_main_id_list#</cfoutput>',spect,','))
                {
                }
                else
                {
                    alert(spect+' Spect No Bu Üretimin Parçası Değildir!');
                    document.getElementById('add_other_barcod').value = '';
                    document.getElementById('add_other_barcod').focus();
                    return false;	
                }
            }
            if(list_find('<cfoutput>#product_barcode_list#</cfoutput>',barcode,','))
            {
                /*var new_sql = "SELECT TOP 1 STOCK_ID FROM STOCKS_BARCODES WHERE BARCODE = '"+barcode+"'";*/
                /*var get_product = wrk_query(new_sql,'dsn1');*/
                
                var listParam = barcode;
                var get_product = wrk_safe_query('get_product_ezgi','dsn3',0,listParam);
                
                if(document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect)==undefined)
                {
                    alert('<cf_get_lang dictionary_id='347.Ürün Barkodu Hatalı'>')	
                    document.getElementById('add_other_barcod').value = '';
                    document.getElementById('add_other_barcod').focus();
                    return false;
                }
                else
                {
                        if((document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect).value*1)-(amount*-1) > (document.getElementById('amount'+get_product.STOCK_ID+'_'+spect).value*1))
                        {
                            alert(document.getElementById('PRODUCT_NAME'+get_product.STOCK_ID+'_'+spect).value+' <cf_get_lang dictionary_id='379.Fazla Çıkış'>');
                            document.getElementById('add_other_barcod').value = '';
                            document.getElementById('add_other_barcod').focus();
                            return false;
                        }
                        else
                        {
                            document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect).value = (document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect).value*1)+(amount*1);
                            document.all.total_control_amount.value=(document.all.total_control_amount.value*1)+(amount*1);
                            
                            productname=document.getElementById('PRODUCT_NAME'+get_product.STOCK_ID+'_'+spect).value;
                            stockid=get_product.STOCK_ID;
                            add_row_content(barcode,stockid,productname,spect,1)
                        }
                        if(document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect).value == document.getElementById('amount'+get_product.STOCK_ID+'_'+spect).value)
                            document.getElementById('row'+get_product.STOCK_ID+'_'+spect).style.display='none';
                        if(document.getElementById('total_amount').value == document.getElementById('total_control_amount').value)
                        {
                            var operation_gurup_id = document.getElementById('operation_gurup_id').value;
                            var process_stage= document.getElementById('process_stage').value;
                            var process_cat = document.getElementById('process_cat').options[1].value;
                            window.open('<cfoutput>#request.self#?fuseaction=production.addoperationresult_ezgi&ezgi_package_control_type=1&upd_id=#attributes.upd#&operation_id_=#attributes.p_operation_id#&station_id_=#attributes.station_id#&realized_amount_= 1&employee_id_=#attributes.employee_id#</cfoutput>&operation_gurup_id='+operation_gurup_id+'&process_stage='+process_stage+'&process_cat='+process_cat);
                            window.opener.location.reload();
                        }
                    }			
                    
                    document.all.add_other_barcod.value='';
                    document.all.changed_stock_id.value = get_product.STOCK_ID;
                    eval('row'+get_product.STOCK_ID+'_'+spect).style.background='FFCCCC';
            }
            else
            {
                alert('<cf_get_lang dictionary_id='381.Kayıtlı Barkod Yok!'>');
                document.getElementById('add_other_barcod').value = '';
                document.getElementById('add_other_barcod').focus();
                return false;
            }
        }
        function pr_stop()
        {
            sor = confirm("<cf_get_lang dictionary_id='417.Üretim İçin Sonuç Girmeden Çıkmak İstediğinizden Emin misiniz'>?");
            if(sor==true)
            window.location.href='<cfoutput>#request.self#?fuseaction=production.upd_ezgi_station_employee_exit&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&p_operation_id=#attributes.p_operation_id#&lot_number=#get_order.LOT_NO#</cfoutput>';
        }
        function pr_dublicate_package()
        {
            var operation_gurup_id = document.getElementById('operation_gurup_id').value;
            var process_stage= document.getElementById('process_stage').value;
            var process_cat = document.getElementById('process_cat').options[1].value;
            if(document.all.total_control_amount.value >0) /*BÖLÜNMESİ İÇİN PARÇA OKUTULMUŞSA*/
            {
                action_doldur();
                document.getElementById('bt_dublicate_package').disabled = true;
                sor = confirm("<cf_get_lang dictionary_id='57536.Güncellemek İstediğinizden Emin misiniz?'>");
                if(sor==true)
                {
                    window.location="<cfoutput>#request.self#?fuseaction=production.emptypopup_add_ezgi_package_dublicate_package&upd=#attributes.upd#&operation_id=#attributes.p_operation_id#&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&sonraki_tur=#attributes.sonraki_tur#</cfoutput>&operation_gurup_id="+operation_gurup_id+"&process_stage="+process_stage+"&process_cat="+process_cat+"&row_info_content="+document.getElementById('row_info_content_id').value;
                }
                else
                    document.all.add_other_barcod.value='';
            }
            else
            {
                alert('Paket Bölmek için Hiç Ürün Seçilmemiş');
                document.all.add_other_barcod.value='';
                return false;
            }
        }
        function add_row_content(barcode,stockid,productname,spect,amount)
        {
            hata=0;
            if(hata==0)
            {
                if(spect>0)
                    barcode=barcode+spect;
                row_count_content++;
                document.getElementById('row_count_content').value = row_count_content;
                
                var newRow;
                var newCell;	
                newRow = document.getElementById("table2").insertRow(document.getElementById("table2").rows.length);
                newRow.setAttribute("name","frm_row" + row_count_content);
                newRow.setAttribute("id","frm_row" + row_count_content);		
                newRow.setAttribute("NAME","frm_row" + row_count_content);
                newRow.setAttribute("ID","frm_row" + row_count_content);		
                
                newCell = newRow.insertCell();
                newCell.innerHTML = '<a onclick="sil(' + row_count_content + ');"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id='57463.Sil'>" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>';
                        
                newCell = newRow.insertCell();
                newCell.innerHTML = '<input type="hidden" name="row_kontrol_content'+row_count_content+'" id="row_kontrol_content'+row_count_content+'" value="1"><input name="STOCK_ID'+row_count_content+'" id="STOCK_ID'+row_count_content+'" type="hidden" value="'+stockid+'"><input name="SPECT_MAIN_ID'+row_count_content+'" id="SPECT_MAIN_ID'+row_count_content+'" type="hidden" value="'+spect+'"><input name="row_number'+row_count_content+'" type="text" value="'+row_count_content+'" style="text-align:right;width:20px">';
                
                newCell = newRow.insertCell();
                newCell.innerHTML = '<input name="BARCODE'+row_count_content+'" id="BARCODE'+row_count_content+'" type="text" value="'+barcode+'" style="text-align:right;width:90px">';
                
                newCell = newRow.insertCell();
                newCell.innerHTML = '<input name="PRODUCT_NAME'+row_count_content+'" id="PRODUCT_NAME'+row_count_content+'" type="text" value="'+productname+'" style="text-align:left;">';
                
                newCell = newRow.insertCell();
                newCell.innerHTML = '<input name="AMOUNT_CONTENT'+row_count_content+'" id="AMOUNT_CONTENT'+row_count_content+'" type="text" value="'+amount+'" style="text-align:right;width:40px">';
            }
        }
        function sil(sy)
        {
            stockid=document.getElementById('STOCK_ID'+sy).value;
            spect=document.getElementById('SPECT_MAIN_ID'+sy).value;
            amount=document.getElementById('AMOUNT_CONTENT'+sy).value;
            
            document.getElementById('row_kontrol_content'+sy).value=0;
            document.getElementById('SPECT_MAIN_ID'+sy).value='';
            document.getElementById('STOCK_ID'+sy).value='';
            document.getElementById('BARCODE'+sy).value='';
            document.getElementById('AMOUNT_CONTENT'+sy).value=0;
            document.getElementById('frm_row'+sy).style.display="none";
            
            document.getElementById('row'+stockid+'_'+spect).style.display='';
            document.getElementById('control_amount'+stockid+'_'+spect).value = (document.getElementById('control_amount'+stockid+'_'+spect).value*1)-(amount*1);
            document.all.total_control_amount.value=(document.all.total_control_amount.value*1)-(amount*1);
        }
        function action_doldur()
        {
            var j = 1;
            for(i=1;i<=row_count_content;i++)
            {
                if(document.getElementById('row_kontrol_content'+i).value == 1)
                {
                    if (j > 1)
                        document.getElementById('row_info_content_id').value = document.getElementById('row_info_content_id').value + ',';
                    document.getElementById('row_info_content_id').value = document.getElementById('row_info_content_id').value + j + '-';
                    document.getElementById('row_info_content_id').value = document.getElementById('row_info_content_id').value + document.getElementById('SPECT_MAIN_ID'+i).value + '-';
                    document.getElementById('row_info_content_id').value = document.getElementById('row_info_content_id').value + document.getElementById('STOCK_ID'+i).value + '-';
                    document.getElementById('row_info_content_id').value = document.getElementById('row_info_content_id').value + document.getElementById('AMOUNT_CONTENT'+i).value;
                    j++;
                }
            }
        }
    </script>
