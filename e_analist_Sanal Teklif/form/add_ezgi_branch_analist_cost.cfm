
<cfform name="add_ezgi_branch_analist_cost" id="add_ezgi_branch_analist_cost" method="post" action="#request.self#?fuseaction=report.emptypopup_add_ezgi_branch_analist_cost">
	<div class="row">
    	<div class="col col-12 uniqueRow">
        	<div class="row formContent">
            	<div class="row" type="row">
                	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                        <div class="form-group" id="item-expense_item_name">
                        	<label class="col col-4 col-xs-12"><cfoutput>#getLang('main',822)#</cfoutput> *</label>
                            <div class="col col-8 col-xs-12">
                            	<input type="text" name="expense_item_name" id="expense_item_name" maxlength="50">
                            </div>
                        </div>
                        <div class="form-group" id="item-expense_item_code">
                        	<label class="col col-4 col-xs-12"><cfoutput>#getLang('main',1173)#</cfoutput></label>
                            <div class="col col-8 col-xs-12">
                            	<input type="text" name="expense_item_code" id="expense_item_code">
                            </div>
                        </div>
                        <div class="form-group" id="item-account_code">
                        	<label class="col col-4 col-xs-12"><cfoutput>#getLang('main',1399)#</cfoutput> *</label>
                            <div class="col col-8 col-xs-12">
                            	<div class="input-group">
									<input type="hidden" name="account_id" id="account_id">
                    				<input type="text" name="account_code" id="account_code" readonly>
                                    <span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_account_plan&field_name=add_ezgi_branch_analist_cost.account_code&field_id=add_ezgi_branch_analist_cost.account_id','list')" title="<cfoutput>#getLang('main',1399)#</cfoutput>"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-expense_item_detail">
                        	<label class="col col-4 col-xs-12"><cfoutput>#getLang('main',217)#</cfoutput></label>
                            <div class="col col-8 col-xs-12">
                            	<textarea name="expense_item_detail" id="expense_item_detail"></textarea>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="formContentFooter">
                	<div class="col col-12">
                    	<cf_workcube_buttons type_format='1' is_upd='0' add_function='kontrol()'>
                    </div>
                </div>
            </div>
        </div>
    </div>
</cfform>
<script type="text/javascript">
	function kontrol()
	{
		if(document.getElementById("expense_cat").value == '')
		{
			alert("<cf_get_lang no='41.Bütçe Kategorisi Seçmediniz'> !");
			return false;
		}

		if(document.getElementById("expense_item_name").value == '')
		{
			alert("<cf_get_lang no='26.Gider Kalemi Girmelisiniz'>!");
			return false;
		}
		if(document.getElementById("account_code").value == '')
		{
			alert("<cf_get_lang no='61.Muhasebe Kodu girmelisiniz'>!");
			return false;
		}
		if(document.getElementById("income_expense").checked == false && document.getElementById("is_expense").checked == false)
		{
			alert("<cf_get_lang no='64.Gelir yada Gider Seçmelisiniz'> !");
			return false;
		}	
		return true;
	}
</script>
