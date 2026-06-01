<!---
    File: add_ezgi_metarial_control.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---Ezgi Bilgisayar - Üretim Kumas Kontrol Penceresi ZAG - 25/02/2014--->
<style>
.thb {
	font-size: 11px;
	font-weight: bold;
	background-color: silver;
	text-align:center
}
.stil1 {
	font-size: 12px;
	font-weight: bold;

}
</style>
<cfquery name="get_default" datasource="#dsn3#">
	SELECT       
    	EMAD.DEFAULT_RAW_STORE_ID, 
        EMAD.DEFAULT_RAW_LOC_ID, 
        EMAD.DEFAULT_PRODUCTION_STORE_ID, 
        EMAD.DEFAULT_PRODUCTION_LOC_ID, 
        EMAD.POINT_METHOD, 
        EMAD.CONTROL_METHOD,
        EMAD.FABRIC_CAT
	FROM            
    	EZGI_MASTER_PLAN_DEFAULTS AS EMAD INNER JOIN
     	EZGI_MASTER_PLAN AS EMAP ON EMAD.SHIFT_ID = EMAP.MASTER_PLAN_CAT_ID
	WHERE        
    	EMAP.MASTER_PLAN_ID = #attributes.master_plan_id#
</cfquery>
<cfparam name="attributes.total_control" default="0">
<cfset control_department = get_default.DEFAULT_RAW_STORE_ID>
<cfset control_location = get_default.DEFAULT_RAW_LOC_ID>

<!---Lot a Bağlı Siparişin Açıklaması Alınıyor--->

<cfif isdefined('attributes.p_order_id_list')>
	<cfquery name="get_p_order_lot" datasource="#dsn3#">
    	SELECT LOT_NO FROM PRODUCTION_ORDERS WHERE P_ORDER_ID IN (#attributes.p_order_id_list#)
    </cfquery>
	<cfif get_p_order_lot.recordcount>
        <cfform name="kumaskontrol" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_metarial_control" method="post">
        	<cfinput type="hidden" name="p_order_id_list" value="#attributes.p_order_id_list#">
            <cfinput type="hidden" name="total_lot_row" value="#get_p_order_lot.recordcount#">
            <cfset ic_talep = 0> 
       		<cfloop query="get_p_order_lot">
              	<cfset attributes.lot_no = LOT_NO>
                <cfset lot_row = get_p_order_lot.currentrow>
                <cfset 'upd_#lot_row#' = 0>
                <cfinput type="hidden" name="lot_no_#lot_row#" value="#LOT_NO#"> 
                <cfinclude template="add_ezgi_metarial_control_insert_1.cfm">
                <br />
            </cfloop>
            <table width="98%" border="0" cellspacing="0" cellpadding="0" align="center">
                <tr class="color-list" height="35">
                    <td valign="middle" class="thb" style="text-align:left; width:50%">
                        <cfif Evaluate('upd_#lot_row#') eq 1>
                            <cfoutput>
                            &nbsp;<b>Kayıt :</b> #get_emp_info(record_emp,0,0)# - #Dateformat(record_date, dateformat_style)# #Timeformat(record_date, 'HH:MM')#&nbsp;&nbsp;&nbsp;<b>Güncelleme : </b>#get_emp_info(update_emp,0,0)# - #Dateformat(update_date, dateformat_style)# #Timeformat(update_date, 'HH:MM')#
                          </cfoutput>
                        </cfif>
                    </td>
                    <td style="text-align:right; vertical-align:middle; width:50%" class="thb">
                        <cfif Evaluate('upd_#lot_row#') eq 1>
                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='57464.Güncelle'></cfsavecontent>
                            <cfsavecontent variable="message1"><cf_get_lang dictionary_id='57553.Kapat'></cfsavecontent>
                            <cf_workcube_buttons is_upd='1' insert_info="#message#" is_delete='0' is_cancel='1' cancel_info="#message1#" add_function='kontrol_row()'>
                        <cfelse>
                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='57461.Kaydet'></cfsavecontent>
                            <cfsavecontent variable="message1"><cf_get_lang dictionary_id='57553.Kapat'></cfsavecontent>
                            <cf_workcube_buttons is_upd='0' insert_info="#message#" is_cancel='1' cancel_info="#message1#" add_function='kontrol_row()'>
                        </cfif>
                    </td>
                </tr> 	
  			</table>
        </cfform>
    </cfif>
<cfelse>
	<cfform name="kumaskontrol" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_metarial_control" method="post">
    	<cfset lot_row = 1>
        <cfset 'upd_#lot_row#' = 0>
        <cfinput type="hidden" name="total_lot_row" value="1">
        <cfif isdefined('attributes.lot_no')>
        	<cfinput type="hidden" name="lot_no_1" value="#attributes.lot_no#">
        <cfelseif isdefined('attributes.order_id')>
        	<cfinput type="hidden" name="order_id_1" value="#attributes.order_id#">
        </cfif>
   		<cfinclude template="add_ezgi_metarial_control_insert_1.cfm">
     	<div class="col col-12 col-xs-12">
            <cf_box>
                <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
                    <tr height="35">
                        <td valign="middle" style="text-align:left">
                            <cfif Evaluate('upd_#lot_row#') eq 1>
                                <cfoutput>
                                &nbsp;<b>Kayıt :</b> #get_emp_info(record_emp,0,0)# - #Dateformat(record_date, dateformat_style)# #Timeformat(record_date, 'HH:MM')#&nbsp;&nbsp;&nbsp;&nbsp;<b>Güncelleme :</b> #get_emp_info(update_emp,0,0)# - #Dateformat(update_date, dateformat_style)# #Timeformat(update_date, 'HH:MM')#
                              </cfoutput>
                            </cfif>
                        </td>
                        <td align="right" valign="middle">
                            <cfif Evaluate('upd_#lot_row#') eq 1>
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='57464.Güncelle'></cfsavecontent>
                                <cfsavecontent variable="message1"><cf_get_lang dictionary_id='57553.Kapat'></cfsavecontent>
                                <cf_workcube_buttons is_upd='1' insert_info="#message#" is_delete='0' is_cancel='1' cancel_info="#message1#" add_function='kontrol_row()'>
                            <cfelse>
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='57461.Kaydet'></cfsavecontent>
                                <cfsavecontent variable="message1"><cf_get_lang dictionary_id='57553.Kapat'></cfsavecontent>
                                <cf_workcube_buttons is_upd='0' insert_info="#message#" is_cancel='1' cancel_info="#message1#" add_function='kontrol_row()'>
                            </cfif>
                        </td>
                    </tr> 	
                </table>
            </cf_box>
   		</div>
        <cfif isdefined('ic_talep')>
			<cfif ic_talep eq 1>
                <br>
                <cfinclude template="add_ezgi_metarial_control_insert_2.cfm">
            </cfif>
      	<cfelse>
        	<script type="text/javascript">
				alert("Guruplama Yapmalısınız!");
			</script>
			<cfabort>
        </cfif>
   	</cfform>
</cfif>
<script language="javascript">
	function kontrol_row()
	{
		return true;
	}
	function grupla(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
			p_order_id_list = '';
			<cfif isdefined('get_malzeme_group')>
				chck_leng = <cfoutput>#get_malzeme_group.recordcount#</cfoutput>
			<cfelse>
				chck_leng = 0;
			</cfif>
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
						p_order_id_list +=my_objets.value+',';
				}
			}
			<cfif get_default.CONTROL_METHOD eq 1 or get_orders_info.ORDER_ID eq 0>
				<cfif isdefined('attributes.lot_no')>
        			var lot_no = <cfoutput>#attributes.lot_no#</cfoutput>
				</cfif>
			<cfelseif get_default.CONTROL_METHOD eq 2 and get_orders_info.ORDER_ID gt 0>
				var lot_no = <cfoutput>'#get_orders_info.ORDER_NUMBER#'</cfoutput>;
			</cfif>
			p_order_id_list = p_order_id_list.substr(0,p_order_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(p_order_id_list=='')
			{
			alert('<cf_get_lang dictionary_id='1077.İç Talep İçin Seçim Yapınız !!!'>');
			}
			else
			{
				window.location ='<cfoutput>#request.self#?fuseaction=prod.emptypopup_add_ezgi_metarial_talep&master_plan_id=#attributes.master_plan_id#</cfoutput>&p_order_id_list='+p_order_id_list+'&lot_no='+lot_no;
				wrk_opener_reload();
			}
	}
	function secenek(secim)
	{
		<cfloop query="get_malzeme">
			<cfoutput>
				cii=#get_malzeme.POR_STOCK_ID#;
			</cfoutput>
			eval("document.getElementById('var_yok_1_'+cii)").value=secim;
		</cfloop>
	}
</script>