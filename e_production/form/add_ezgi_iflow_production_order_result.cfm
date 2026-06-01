<!---
    File: add_ezgi_iflow_production_order_result.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset module_name="prod">
<cfset station_type = 1>
<cfquery name="get_production_orders" datasource="#dsn3#">
	SELECT        
    	ISNULL(PO.PRINT_COUNT, 0) AS PRINT_COUNT, 
        S.PRODUCT_ID, 
        S.PRODUCT_NAME, 
        S.PRODUCT_CODE, 
        PO.STOCK_ID, 
        PO.PO_RELATED_ID, 
        PO.QUANTITY, 
        PO.LOT_NO, 
        P.MAIN_UNIT AS UNIT, 
     	PO.P_ORDER_ID, 
        PO.P_ORDER_NO, 
        ISNULL(PO.IS_GROUP_LOT, 0) AS IS_GROUP_LOT, 
        PO.GROUP_LOT_NO, 
        PO.IS_STAGE, 
        PO.STATION_ID, 
        ISNULL(TBL.AMOUNT, 0) AS AMOUNT
	FROM            
    	PRODUCTION_ORDERS AS PO INNER JOIN
      	PRODUCT_UNIT AS P INNER JOIN
      	STOCKS AS S ON P.PRODUCT_ID = S.PRODUCT_ID ON PO.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
    	(
        	SELECT        
            	POR.P_ORDER_ID, SUM(PORR.AMOUNT) AS AMOUNT
         	FROM            
            	PRODUCTION_ORDER_RESULTS AS POR INNER JOIN
             	PRODUCTION_ORDER_RESULTS_ROW AS PORR ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
          	WHERE        
            	PORR.TYPE = 1 AND 
                POR.IS_STOCK_FIS = 1
         	GROUP BY 
            	POR.P_ORDER_ID
    	) AS TBL ON PO.P_ORDER_ID = TBL.P_ORDER_ID
	WHERE     
    	PO.P_ORDER_ID = #attributes.p_order_id#
</cfquery>
<cfquery name="get_stations" datasource="#dsn3#">
	SELECT 
    	STATION_ID, UP_STATION, STATION_NAME 
  	FROM 
    	WORKSTATIONS 
  	WHERE 
    	(STATION_ID = #get_production_orders.STATION_ID# OR UP_STATION = #get_production_orders.STATION_ID#)
        <cfif station_type eq 1>
        	AND UP_STATION IS NULL
        </cfif>
  	ORDER BY
    	UP_STATION, STATION_NAME
</cfquery>
<cfsavecontent variable="right"></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="module"><cf_get_lang dictionary_id='539.Üretim Emir Sonucu Ekle'></cfsavecontent>
	<cf_box title="#module#" right_images="#right#">
    	<cfform name="upd_operation" id="upd_operation" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_iflow_production_order_result">
            <cfinput type="hidden" name="p_order_id" value="#attributes.p_order_id#">
            <cf_box_elements>
            	<div class="col col-6 col-md-6 col-sm-8 col-xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="kategori">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='42382.İşlem Kategorisi'></label>
                     	<div class="col col-8 col-xs-12">
                        	<cf_workcube_process_cat slct_width="140">	
                     	</div>
                	</div>
                    <div class="form-group" id="surec">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58859.Süreç'></label>
                     	<div class="col col-8 col-xs-12">
                        	<cf_workcube_process is_upd='0' process_cat_width='130' is_detail='0'>
                     	</div>
                	</div>
                	<div class="form-group" id="lot_no">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36698.Lot No'></label>
                     	<div class="col col-8 col-xs-12">
                        	<cfinput name="lot_no" readonly="yes" type="text" style="width:65px; text-align:center" value="#get_production_orders.LOT_NO#">
                     	</div>
                	</div>
                    <div class="form-group" id="emir_no">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29474.Emir No'></label>
                     	<div class="col col-8 col-xs-12">
                        	<cfinput name="P_ORDER_NO" readonly="yes" type="text" style="width:65px; text-align:center" value="#get_production_orders.P_ORDER_NO#">
                     	</div>
                	</div>
                    <div class="form-group" id="urun">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58221.Ürün Adı'></label>
                     	<div class="col col-8 col-xs-12">
                        	<cfinput name="product_name" readonly="yes" type="text" id="product_name" style="width:350px" value="#get_production_orders.PRODUCT_NAME#">
                     	</div>
                	</div>
                    <div class="form-group" id="emir">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='192.Emir Miktarı'>	 / <cf_get_lang dictionary_id='36608.Üretilen'></label>
                     	<div class="col col-4 col-xs-12">
                        	<cfinput name="order_amount" readonly="yes" type="text" style="width:85px; text-align:right" value="#TlFormat(get_production_orders.QUANTITY,8)#" class="box">
                     	</div>
                        <div class="col col-4 col-xs-12">
                        	<cfinput name="produced_amount" readonly="yes" type="text" style="width:85px; text-align:right" value="#TlFormat(get_production_orders.AMOUNT,8)#" class="box">
                     	</div>
                	</div>
					<div class="form-group" id="istasyon">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58834.İstasyon'></label>
                     	<div class="col col-8 col-xs-12">
                        	<select name="station_id" id="station_id" style="width:200px; height:20px">
								<cfoutput query="get_stations">
                               		<cfif station_type neq 1>
                                    	<option value="#STATION_ID#" <cfif not len(UP_STATION)>disabled="disabled"</cfif>>#STATION_NAME#</option>
                                 	<cfelse>
                                   		<option value="#STATION_ID#">#STATION_NAME#</option>
                                  	</cfif>
                             	</cfoutput>
                         	</select>
                     	</div>
                	</div>
                    <div class="form-group" id="tarih">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='493.Üretim Tarihi'></label>
                     	<div class="col col-8 col-xs-12">
                        	<div class="input-group x-14">
                        		<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
								<cfinput type="text" name="action_date" id="action_date" placeholder="#message#" value="#DateFormat(now(), dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10">
                            	<span class="input-group-addon"><cf_wrk_date_image date_field="action_date"></span>
                            </div>
                     	</div>
                	</div>
                    <div class="form-group" id="uretim">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57456.Üretim'></label>
                     	<div class="col col-8 col-xs-12">
                        	<cfinput name="amount" id="amount" type="text" style="width:85px; text-align:right" value="#TlFormat(get_production_orders.QUANTITY-get_production_orders.AMOUNT,8)#">
                     	</div>
                	</div>
             	</div>
           	</cf_box_elements>
      	</cfform>
		<cf_box_footer>
			<div class="col col-12" style="text-align:right">
				<!--- <cf_workcube_buttons 
						is_upd='0' 
						is_delete = '0' 
						add_function='kontrol()'> --->
				<br><button name="submitbtn" id="submitbtn" type="submit" onclick="kontrol()" style="width:100px;height:30px;background-color:green;color:white">Kaydet</button>
			</div>
		</cf_box_footer>
  	</cf_box>
</div>
<script type="text/javascript">
	function kontrol()
	{
		if(document.getElementById("amount").value <= 0)
		{
			alert("<cf_get_lang dictionary_id='540.Üretim 0 dan büyük olmalıdır.'> !");
			document.getElementById('amount').focus();
			return false;
		}
		if(document.getElementById("action_date").value <= 0)
		{
			alert("<cf_get_lang dictionary_id='541.Tarih Değerini Kontrol Ediniz.'> !");
			document.getElementById('action_date').focus();
			return false;
		}
		sor = confirm("Üretim Emri Sonucu Eklemek İstediğinize Emin Misiniz?");
		document.getElementById("submitbtn").disabled = true;
		if(sor === true)		{
			document.getElementById("upd_operation").submit();
			return true;
		}
		else
		{
			document.getElementById("submitbtn").disabled = false;
			return false;
		}
	}
</script>