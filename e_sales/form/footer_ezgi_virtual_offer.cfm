<!---
    File: footer_ezgi_virtual_offer.cfm
    Folder: Add_Ons\ezgi\e_sales\form
    Author: Ezgi Yazılım
    Date: 01/01/2022
    Description:
--->
<cfif isdefined('attributes.virtual_offer_id') or isdefined('attributes.upd_id')>
	<cfset grosstotal = get_virtual_offer.GROSSTOTAL>
    <cfset nettotal = get_virtual_offer.NETTOTAL>
    <cfset discounttotal = get_virtual_offer.DISCOUNTTOTAL>
    <cfset sub_discounttotal = get_virtual_offer.SUB_DISCOUNTTOTAL>
    <cfset tax = get_virtual_offer.TAX>
<cfelse>
	<cfset grosstotal = 0>
    <cfset nettotal = 0>
    <cfset discounttotal = 0>
    <cfset sub_discounttotal = 0>
    <cfset tax = 0>
</cfif>
<cf_box closable="0">
	<cf_box_elements>
		<div class="col col-3 col-md-4 col-sm-12" type="column" index="1" sort="true">
        	<div class="form-group require" id="item-order_head">
				<div class="col col-12 col-sm-12">
					<table cellspacing="1" cellpadding="1" border="0" style="height:100%; width:100%">
                        <tr >
                            <td style="text-align:center; height:25px; font-weight:bold" colspan="2">Döviz</td>
                        </tr>
                        <cfif isdefined('attributes.virtual_offer_id')>
                            <cfinput type="hidden" name="money_recordcount" value="#get_money.recordcount#">
                            <cfoutput query="get_virtual_offer_money">
                                <tr >
                                    <td style="width:30%"><input type="radio" name="basket" value="#money_type#" onchange="doviz_change(#currentrow#)" <cfif IS_SELECTED>checked</cfif>> #money_type#</td>
                                    <td style="text-align:right; width:70%; height:20px">
                                        <input type="text" name="money_#currentrow#" id="money_#currentrow#" value="#TlFormat(rate2,4)#" onchange="doviz_change(#currentrow#)" class="box" <cfif session.ep.money eq money_type>readonly="readonly"</cfif>/>
                                        <input type="hidden" name="money_type_#currentrow#" id="money_type_#currentrow#" value="#money_type#"  />
                                    </td>
                                </tr>
                            </cfoutput>
                        <cfelse>
                            <cfinput type="hidden" name="money_recordcount" value="#get_money.recordcount#">
                            <cfoutput query="get_money">
                                <tr >
                                    <td style="width:30%"><input type="radio" name="basket" value="#money#" onchange="doviz_change(#currentrow#)" <cfif session.ep.money eq money>checked</cfif>> #money#</td>
                                    <td style="text-align:right; width:70%; height:20px">
                                        <input type="text" name="money_#currentrow#" id="money_#currentrow#" value="#TlFormat(rate2,4)#" onchange="doviz_change(#currentrow#)" class="box" <cfif session.ep.money eq money>readonly="readonly"</cfif>/>
                                        <input type="hidden" name="money_type_#currentrow#" id="money_type_#currentrow#" value="#money#"  />
                                    </td>
                                </tr>
                            </cfoutput>
                        </cfif>
                    </table>
				</div>                
			</div>
        </div>
        <div class="col col-3 col-md-4 col-sm-12" type="column" index="2" sort="true">
        	<div class="form-group require" id="item-order_orta1">
				<div class="col col-12 col-sm-12">
           		</div>
          	</div>
        </div>
        <div class="col col-3 col-md-4 col-sm-12" type="column" index="3" sort="true">
        	<div class="form-group require" id="item-order_orta2">
				<div class="col col-12 col-sm-12">
           		</div>
           	</div>
        </div>
        <div class="col col-3 col-md-4 col-sm-12" type="column" index="4" sort="true">
        	<div class="form-group require" id="item-order_head">
				<div class="col col-12 col-sm-12">
                    <table cellspacing="1" cellpadding="1" border="0" width="100%" height="100%">
                        <cfoutput>
                        <tr height="20" >
                            <td width="205" class="txtbold" style="text-align:right; height:25px"><cf_get_lang_main no='80.Toplam'>&nbsp;</td>
                            <td style="text-align:right; width:75px" name="total_default">
                                <input type="text" name="sub_total_brut_other" id="sub_total_brut_other" style="width:75px;text-align:right; font-weight:bold" class="box" value="#TlFormat(GROSSTOTAL,4)#" readonly>
                                <input type="hidden" name="sub_total_net_other" id="sub_total_net_other" value="#TlFormat(GROSSTOTAL-DISCOUNTTOTAL,4)#">
                            </td>
                            <td style="text-align:right; width:75px" name="total_default">
                                <input type="text" name="sub_total_brut" id="sub_total_brut" style="width:75px;text-align:right; font-weight:bold" class="box" value="#TlFormat(GROSSTOTAL,4)#" readonly>
                                <input type="hidden" name="sub_total_net" id="sub_total_net" value="#TlFormat(GROSSTOTAL-DISCOUNTTOTAL,4)#">
                            </td>
                        </tr>	
                        <tr >
                            <td style="text-align:right;height:25px"><cf_get_lang_main no='237.Toplam İndirim'>&nbsp;</td>
                            <td style="text-align:right;" name="total_discount_default">
                                <input type="text" name="sub_total_discount_other" id="sub_total_discount_other" style="width:75px;text-align:right; font-weight:bold" class="box" value="#TlFormat(DISCOUNTTOTAL,4)#" readonly>
                            </td>
                            <td style="text-align:right;" name="total_discount_default">
                                <input type="text" name="sub_total_discount" id="sub_total_discount" style="width:75px;text-align:right; font-weight:bold" class="box" value="#TlFormat(DISCOUNTTOTAL,4)#" readonly>
                            </td>
                        </tr>
                        <tr height="20" >
                            <td style="text-align:right;"><cf_get_lang_main no='227.KDV'>&nbsp;</td>
                            <td style="text-align:right;" name="total_discount_default">
                                <input type="text" name="sub_total_tax_other" id="sub_total_tax_other" style="width:75px;text-align:right; font-weight:bold" class="box" value="#TlFormat(TAX,4)#" readonly>
                            </td>
                            <td style="text-align:right;" name="total_discount_default">
                                <input type="text" name="sub_total_tax" id="sub_total_tax" style="width:75px;text-align:right; font-weight:bold" class="box" value="#TlFormat(TAX,4)#" readonly>
                            </td>
                        </tr>
                        <tr >
                            <td style="text-align:right;height:25px"><cf_get_lang_main no='266.Fatura Altı İndirim'>&nbsp;</td>
                            <td style="text-align:right;" name="total_tax_default">
                                <input type="text" name="sub_total_discount_ext_other" id="sub_total_discount_ext_other" style="width:75px;text-align:right; font-weight:bold" readonly class="box" onChange="sub_total();" value="#TlFormat(SUB_DISCOUNTTOTAL,4)#">
                            </td>
                            <td style="text-align:right;" name="total_tax_default">
                                <input type="text" name="sub_total_discount_ext" id="sub_total_discount_ext" style="width:75px;text-align:right; font-weight:bold" readonly class="box" onChange="sub_total();" value="#TlFormat(SUB_DISCOUNTTOTAL,4)#">
                            </td>
                        </tr>
                        <tr >
                            <td style="text-align:right;height:25px">Genel Toplam&nbsp;</td>
                            <td style="text-align:right;" name="net_total_default">
                                <input type="text" name="sub_total_end_other" id="sub_total_end_other" style="width:75px;text-align:right; font-weight:bold" class="box" value="#TlFormat(NETTOTAL,4)#" readonly>
                            </td>
                            <td style="text-align:right;" name="net_total_default">
                                <input type="text" name="sub_total_end" id="sub_total_end" style="width:75px;text-align:right; font-weight:bold" class="box" value="#TlFormat(NETTOTAL,4)#" readonly>
                            </td>
                        </tr>
        				<tr >
                            <td style="text-align:right;height:25px"><cf_get_lang dictionary_id="57642.Net Toplam">&nbsp;</td>
                            <td style="text-align:right;" name="net_total_other_end">
                              <input type="text" name="net_total_other_end" id="net_total_other_end" style="width:100px;text-align:right; font-weight:bold" class="box" value="#TlFormat(0,4)#" onchange="change_total_other_end()">
                            </td>
                            <td style="text-align:right;" name="net_total_end">
                                <input type="text" name="net_total_end" id="net_total_end" style="width:100px;text-align:right; font-weight:bold" class="box" value="#TlFormat(0,4)#" onchange="change_total_end()">
                            </td>
                        </tr>
                        <tr id="ind_or">
                            <td style="text-align:right;height:25px"><cf_get_lang dictionary_id="63934.İndirim Oranı">&nbsp;</td>
                            <td style="text-align:right;" name="son_oran" colspan="2">
                               <input type="text" name="son_oran" id="son_oran" style="width:100%;text-align:center; font-weight:bold; background-color:gainsboro;" class="box" value="#TlFormat(0,4)#" readonly="readonly">
                            </td>
                        </tr>
                        </cfoutput>
                    </table>
              	</div>                
			</div>
        </div>
  	</cf_box_elements>
</cf_box>
<script type="text/javascript">
	sub_total();
	function doviz_change(currentrow)
	{
		document.getElementById('virtual_offer_money').value = document.getElementById('money_type_'+currentrow).value;
		document.getElementById('virtual_offer_rate2').value = document.getElementById('money_'+currentrow).value;
		for (var ra=1;ra<=document.form_basket.record_num.value;ra++)
		{
			if(document.getElementById('money'+ra).value == document.getElementById('money_type_'+currentrow).value)
			{
				document.getElementById('row_rate2_'+ra).value = document.getElementById('virtual_offer_rate2').value;
			}
		 	hesapla(ra);
		}
		sub_total();
	}
	function change_total_other_end()
	{
		document.getElementById('net_total_end').value = commaSplit(parseFloat(filterNum(document.getElementById('net_total_other_end').value,4))*parseFloat(filterNum(document.getElementById('virtual_offer_rate2').value,4)),4);
		change_total_end();
	}
	function change_total_end()
	{
		for (var rc=1;rc<=document.form_basket.record_num.value;rc++)
		{
			document.getElementById('discount_tut'+rc).value = commaSplit(0,4);
			hesapla(rc);
		}
		son_oran_hesapla();
	}
	function son_oran_hesapla()
	{
		oran = parseFloat(filterNum(document.getElementById('net_total_end').value,4))/parseFloat(filterNum(document.getElementById('sub_total_end').value,4));
		if(oran == 0)
			document.getElementById('son_oran').value=commaSplit(0,4);
		toplam_kdv_dahil_mal_bedeli = 0;
		for (var rb=1;rb<=document.form_basket.record_num.value;rb++)
		{
			satir_indirimli_fiyat = oran * parseFloat(filterNum(document.getElementById('total_brut_other'+rb).value,4));
			satir_indirimli_birimfiyat = satir_indirimli_fiyat / parseFloat(filterNum(document.getElementById('quantity'+rb).value,4));
			satir_iskonto = parseFloat(filterNum(document.getElementById('sales_price'+rb).value,4)) + parseFloat(filterNum(document.getElementById('cost'+rb).value,4)) - satir_indirimli_birimfiyat;
			document.getElementById('discount_tut'+rb).value = commaSplit(satir_iskonto,4);
			hesapla(rb);
			toplam_kdv_dahil_mal_bedeli = toplam_kdv_dahil_mal_bedeli + (parseFloat(filterNum(document.getElementById('total_brut'+rb).value,4)) + (parseFloat(filterNum(document.getElementById('total_brut'+rb).value,4))*parseFloat(filterNum(document.getElementById('tax'+rb).value,4))/100));
		}
		document.getElementById('son_oran').value=commaSplit(((parseFloat(filterNum(document.getElementById('net_total_end').value,4))/toplam_kdv_dahil_mal_bedeli)-1)*-100,4);
	}
</script>
