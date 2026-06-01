<cfquery name="get_virtula_offer" datasource="#dsn3#">
	SELECT * FROM EZGI_VIRTUAL_OFFER WHERE VIRTUAL_OFFER_ID = #attributes.virtual_offer_id#
</cfquery>
<cfquery name="get_payments" datasource="#dsn3#">
	SELECT * FROM EZGI_VIRTUAL_OFFER_PAYMENT WHERE VIRTUAL_OFFER_ID = #attributes.virtual_offer_id# ORDER BY VIRTUAL_OFFER_ID
</cfquery>
<cfquery name="get_virtual_offer_money" datasource="#dsn3#">
	SELECT * FROM EZGI_VIRTUAL_OFFER_MONEY WHERE ACTION_ID = #attributes.virtual_offer_id#
</cfquery>
<cfoutput query="get_virtual_offer_money">
	<cfset 'RATE2_#MONEY_TYPE#' = RATE2>
</cfoutput>

<cfparam name="attributes.account" default="#get_payments.ACCOUNT_ID#">
<cfquery name="GET_ACCOUNTS" datasource="#dsn3#">
		SELECT
			ACCOUNT_ID,
		<cfif session.ep.period_year lt 2009>
			CASE WHEN(ACCOUNT_CURRENCY_ID = 'TL') THEN 'YTL' ELSE ACCOUNT_CURRENCY_ID END AS ACCOUNT_CURRENCY_ID,
		<cfelse>
			ACCOUNT_CURRENCY_ID,
		</cfif>
			ACCOUNT_NAME
		FROM
			#dsn3#.ACCOUNTS
		WHERE
			ACCOUNT_STATUS = 1
		<cfif session.ep.isBranchAuthorization>
			AND ACCOUNT_ID IN(SELECT AB.ACCOUNT_ID FROM ACCOUNTS_BRANCH AB WHERE AB.BRANCH_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ListGetAt(session.ep.user_location,2,"-")#">)
		</cfif>
		ORDER BY
			ACCOUNT_NAME
</cfquery>
<cfif get_virtual_offer_money.recordcount>
	<cfquery name="get_row_money" dbtype="query">
    	SELECT MONEY_TYPE, RATE2 FROM get_virtual_offer_money WHERE IS_SELECTED = 1
    </cfquery>
    <cfset row_money_rate2 = get_row_money.rate2>
<cfelse>
	<script type="text/javascript">
		alert("Sanal Teklifte Döviz Tanımları Eksdiktir.!");
		window.close()
	</script>
	<cfabort>
</cfif>
<cfset mtotal=0>
<cfsavecontent variable="message"><cfoutput>#getLang('objects',109)# - #get_virtula_offer.VIRTUAL_OFFER_NUMBER#</cfoutput></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#message#" right_images="">
    	<cfform name="upd_payment" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_payment_plan">
            <cfinput type="hidden" name="virtual_offer_id" value="#attributes.virtual_offer_id#">
            <cfinput type="hidden" name="total_money" value="#get_row_money.MONEY_TYPE#">
            <cf_box_search>
            	<div class="col col-6 col-md-6 col-sm-12 col-xs-12" type="column" index="1" sort="true">
                   	<div class="form-group" id="item-consumer_id">
                        <label class="col col-4 col-sm-12"><strong><cfoutput>#getLang('objects',450)#</cfoutput></strong></label>
                        <div class="col col-8 col-sm-12">
							<div class="input-group">
								<cfoutput>
                                    <cfif get_virtula_offer.NETTOTAL gt 0>
                                        #TlFormat(get_virtula_offer.NETTOTAL/row_money_rate2,2)# #get_row_money.MONEY_TYPE#
                                    <cfelse>
                                        #TlFormat(0,2)#
                                    </cfif>
                                </cfoutput>
                         	</div>
                      	</div>
                    </div>
                </div>
            	<div class="col col-6 col-md-6 col-sm-12 col-xs-12" type="column" index="2" sort="true">
                	<div class="form-group" id="item-ship_method_name">
                 		<label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='29449.Banka Hesabı'></label>
                        <div class="col col-8 col-sm-12">
                           	<div class="input-group">
								<select name="account" id="account">
                                    <option value=""><cf_get_lang dictionary_id='57652.Hesap'></option>
                                    <cfoutput query="get_accounts">
                                        <option value="#account_id#" <cfif isDefined("attributes.account") and attributes.account eq get_accounts.account_id>selected</cfif> >#account_name#-#account_currency_id#</option>
                                    </cfoutput>
                                </select>
						   	</div>
                        </div>
                    </div>
              	</div>
          	</cf_box_search>
            <cf_grid_list>
            		<thead>
                        <th style="text-align:center; width:20px" >
                                <a href="javascript:add_row();"><img src="/images/plus_list.gif"  border="0" title="<cf_get_lang_main no='170.Ekle'>"></a>
                                <input type="hidden" name="record_num" id="record_num" value="<cfoutput>#get_payments.recordcount#</cfoutput>">
                            </th>
                            <th style="text-align:center; width:30px" ><cf_get_lang_main no='1165.Sıra'></th>
                            <th style="text-align:center; width:150px"><cfoutput>#getLang('cheque',238)#</cfoutput></th>
                            <th style="text-align:center; width:70px" ><cf_get_lang_main no='228.Vade'></th>
                            <th style="text-align:center; width:70px" ><cf_get_lang_main no='261.Tutar'></th>
                            <th style="text-align:center; width:60px" ><cf_get_lang_main no='265.Döviz'></th>
                            <th style="text-align:center; width:70px" ><cf_get_lang_main no='261.Tutar'>&nbsp;<cfoutput>#get_row_money.MONEY_TYPE#</cfoutput></th>
                            <th><cf_get_lang_main no='217.Açıklama'></th>
                    	</tr>
                	</thead>
                	<tbody name="new_row" id="new_row">
                    	<cfif get_payments.recordcount>
                    		<cfoutput query="get_payments">
                               	<tr name="frm_row" id="frm_row#currentrow#">
                                 	<td style="height:20px; text-align:center">
                                        <a style="cursor:pointer" onclick="sil(#currentrow#);">
                                       	 	<img src="/images/delete_list.gif" alt="<cf_get_lang_main no='51.Sil'>">
                                       	</a>
                                     	<input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                                    </td>
                                    <td style="text-align:right">#currentrow#</td>
                                    <td style="text-align:center">
                                    	<select name="payment_type_id_#currentrow#" id="payment_type_id_#currentrow#" style="width:150px; height:20px">
                                        	<option value="1" <cfif get_payments.PAYMENT_TYPE_ID eq 1>selected</cfif>>Nakit</option>
                                            <option value="2" <cfif get_payments.PAYMENT_TYPE_ID eq 2>selected</cfif>>Kredi Kartı</option>
                                            <option value="3" <cfif get_payments.PAYMENT_TYPE_ID eq 3>selected</cfif>>Havale</option>
                                            <option value="4" <cfif get_payments.PAYMENT_TYPE_ID eq 4>selected</cfif>>Çek</option>
                                            <option value="5" <cfif get_payments.PAYMENT_TYPE_ID eq 5>selected</cfif>>Senet</option>
                                       </select> 
                                    </td>
                                    <td style="text-align:left" nowrap="nowrap">
										<cfsavecontent variable="message"><cfoutput>#getLang('call',102)#</cfoutput> !</cfsavecontent>
										<cfinput type="text" name="duedate_#currentrow#" id="duedate_#currentrow#" value="#dateformat(get_payments.DUEDATE,'dd/mm/yyyy')#" validate="eurodate" required="Yes" message="#message#" style="width:70px;">
                                    </td>
                                    <td style="text-align:left">
                                    	<input type="text" name="amount_#currentrow#" id="amount_#currentrow#" value="#Tlformat(get_payments.AMOUNT,2)#"  style="width:70px; text-align:right" onChange="hesapla(#currentrow#);">
                                    </td>
                                    <td>
                                        <select name="money#currentrow#" id="money#currentrow#" style="width:60px; height:20px" onchange="satir_doviz_hesapla(#currentrow#);">
                                            <cfloop query="get_virtual_offer_money">
                                                <option value="#MONEY_TYPE#" <cfif get_payments.MONEY eq get_virtual_offer_money.MONEY_TYPE>selected</cfif>>#MONEY_TYPE#</option>
                                            </cfloop>
                                        </select>
                                        <input type="hidden" value="#TlFormat(Evaluate('RATE2_#get_payments.MONEY#'),4)#" id="row_rate2_#currentrow#" name="row_rate2_#currentrow#">
                                    </td>
                                    <cfset row_total = get_payments.AMOUNT/row_money_rate2*Evaluate('RATE2_#get_payments.MONEY#')>
                                    <td><cfinput type="text" name="totalm#currentrow#" id="totalm#currentrow#" value="#TlFormat(row_total,2)#" style="width:70px; text-align:right" readonly="yes"></td>
                                  	<cfset mtotal = mtotal + row_total>
                                    <td><cfinput type="text" name="detail#currentrow#" id="detail#currentrow#" value="#get_payments.detail#" style="width:100%;"></td>
                              	</tr>
                         	</cfoutput>
                    	<cfelse>
                            <tr id="tr_son">
                                <td colspan="8">&nbsp; <cf_get_lang_main no='72.Kayıt Yok'></td>
                            </tr>
                        </cfif>
                 	</tbody>
                    <tfoot>
                    	<tr>
                        	<td colspan="6" style="font-weight:bold; text-align:center">Toplam Ödeme</td>
                            <td style="text-align:right">
                            	<input type="text" name="mtotal" id="mtotal" readonly="readonly" value="<cfoutput>#TlFormat(mtotal,2)#</cfoutput>" style="width:70px; text-align:right; font-weight:bold" />
                            </td>
                            <td></td>
                       	</tr> 
                    </tfoot>
            </cf_grid_list>
            <cf_box_footer>
				<cf_workcube_buttons is_upd='0' add_function='input_control()'> 
			</cf_box_footer>
       	</cfform> 
	</cf_box>
</div>
<script type="text/javascript">
	var row_count=document.upd_payment.record_num.value;
	function kontrol()
	{
		for (var r=1;r<=document.upd_payment.record_num.value;r++)
		{
			if(document.getElementById('row_kontrol'+r).value==1)
			{
				if(document.getElementById('payment_type_id_'+r).value == "")
				{
					alert("<cf_get_lang_main no='782.Girilmesi Zorunlu Alan'> <cfoutput>#getLang('cheque',238)#</cfoutput> !");
					document.getElementById('payment_type_id_'+r).focus();
					return false;
				}
				if(document.getElementById('duedate_'+r).value == "")
				{
					alert("<cf_get_lang_main no='782.Girilmesi Zorunlu Alan'> <cf_get_lang_main no='228.Vade'> !");
					document.getElementById('duedate_'+r).focus();
					return false;
				}
				if(parseFloat(filterNum(document.getElementById('amount_'+r).value,2))<=0)
				{
					alert("<cf_get_lang_main no='782.Girilmesi Zorunlu Alan'> <cf_get_lang_main no='261.Tutar'> !");
					document.getElementById('amount_'+r).focus();
					return false;
				}
				if(document.getElementById('money'+r).value == "")
				{
					alert("<cf_get_lang_main no='782.Girilmesi Zorunlu Alan'> <cf_get_lang_main no='265.Döviz'> !");
					document.getElementById('money'+r).focus();
					return false;
				}
			}
		}
		return true;
	}
	function add_row()
	{
		<cfif not get_payments.recordcount>
			document.getElementById('tr_son').style.display="none";
		</cfif>
		row_count++;
		var newRow;
		var newCell;
		newRow = document.getElementById("new_row").insertRow(document.getElementById("new_row").rows.length);
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);
		newRow.setAttribute("NAME","frm_row" + row_count);
		newRow.setAttribute("ID","frm_row" + row_count);
		
		document.upd_payment.record_num.value = row_count;
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="hidden" name="row_kontrol' + row_count +'" id="row_kontrol' + row_count +'" value="1"><a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang_main no='51.Sil'>" border="0"></a>';	
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.innerHTML = row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute("nowrap","nowrap");
		b = '<select name="payment_type_id_' + row_count +'" id="payment_type_id_' + row_count +'" style="width:150px; height:20px"><option value=""><cf_get_lang_main no='322.Seçiniz'></option>';
		newCell.setAttribute("nowrap","nowrap");
		b += '<option value="1">Nakit</option><option value="2">Kredi Kartı</option><option value="3">Havale</option><option value="4">Çek</option><option value="5">Senet</option>';
		newCell.innerHTML = b + '</select>';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="duedate_' + row_count +'" name="duedate_' + row_count +'" value="<cfoutput>#dateformat(now(),"dd/mm/yyyy")#</cfoutput>" validate="eurodate" required="Yes" style="width:70px;">';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="amount_' + row_count +'" name="amount_' + row_count +'" value="<cfoutput>#TlFormat(0,2)#</cfoutput>" style="width:70px; text-align:right;" onChange="hesapla('+ row_count +');">';
	
		newCell=newRow.insertCell(newRow.cells.length);
		b = '<select name="money' + row_count +'" id="money' + row_count +'" style="width:60px; height:20px" onchange="satir_doviz_hesapla(' + row_count +');"><option value=""><cf_get_lang_main no='322.Seçiniz'></option>';
		<cfoutput query="get_virtual_offer_money">
			b += '<option value="#MONEY_TYPE#" <cfif get_virtual_offer_money.MONEY_TYPE eq get_row_money.MONEY_TYPE>selected</cfif>>#get_virtual_offer_money.MONEY_TYPE#</option>';
		</cfoutput>
		newCell.innerHTML = b + '</select><input type="hidden" value="<cfoutput>#TlFormat(row_money_rate2,4)#</cfoutput>" id="row_rate2_' + row_count +'" name="row_rate2_' + row_count +'">';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="totalm' + row_count +'" name="totalm' + row_count +'" value="<cfoutput>#TlFormat(0,2)#</cfoutput>" style="width:70px; text-align:right;" readonly="readonly">';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="detail' + row_count +'" name="detail' + row_count +'" value="" style="width:100%;">';
	}
	function sil(sy)
	{
		
		var element=eval("upd_payment.row_kontrol"+sy);
		element.value=0;
		var element=eval("frm_row"+sy);
		element.style.display="none";	
		hesapla(sy);
	}
	function satir_doviz_hesapla(currentrow)
	{
		row_money = document.getElementById('money'+currentrow).value;
		<cfoutput query="get_virtual_offer_money">
			money_type = '#get_virtual_offer_money.money_type#';
			money_currentrow = #get_virtual_offer_money.currentrow#;
			rate2 = #get_virtual_offer_money.rate2#;
			if(row_money==money_type)
			{
				document.getElementById('row_rate2_'+currentrow).value= commaSplit(rate2,4);
			}
		</cfoutput>
		hesapla(currentrow);
	}
	function hesapla(row)
	{
		mtotal=0;
		row_money_rate2 = <cfoutput>#row_money_rate2#</cfoutput>;
		for (var r=1;r<=document.upd_payment.record_num.value;r++)
		{
			if(document.getElementById('row_kontrol'+r).value==1)
			{
				total = parseFloat(filterNum(document.getElementById('amount_'+r).value,2)) / row_money_rate2 * parseFloat(filterNum(document.getElementById('row_rate2_'+r).value,4));
				document.getElementById('totalm'+r).value = commaSplit(total,2);
				mtotal = mtotal + total;
			}
			document.getElementById('mtotal').value = commaSplit(mtotal,2);
		}
	}
</script>