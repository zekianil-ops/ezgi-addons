<cfquery name="GET_MONEY" datasource="#DSN#">
	SELECT * FROM SETUP_MONEY WHERE PERIOD_ID = #SESSION.EP.PERIOD_ID#
</cfquery>
<cfif isdefined("attributes.operation_type_id") and len(attributes.operation_type_id)>
	<cfquery name="get_op_type" datasource="#dsn3#">
		SELECT
			O.*
		FROM
			OPERATION_TYPES O
		WHERE
			O.OPERATION_TYPE_ID = #attributes.operation_type_id#
	</cfquery>
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfform name="operation_type" enctype="multipart/form-data" method="post" action="#request.self#?fuseaction=prod.add_operation_type">
		<cf_catalystHeader>
		<cf_box>	 
			<cf_box_elements>
				<div class="col col-4 col-md-4 col-sm-4 col-xs-12" type="column" index="1" sort="true">
					<div class="form-group" id="item-status">
					<label class="col col-3 col-md-3 col-sm-3 col-xs-12"><cf_get_lang dictionary_id ='57493.Aktif'></label>
					<div class="col col-9 col-md-9 col-sm-9 col-xs-12"> 
							<cfif isdefined('get_op_type')>
								<input type="checkbox" name="status" id="status" value="1" <cfif get_op_type.operation_status eq 1>checked</cfif>>
							<cfelse>
								<input type="checkbox" name="status" id="status" value="1">
							</cfif>
						</div>
					</div>
					<div class="form-group" id="item-op_name">
					<label class="col col-3 col-md-3 col-sm-3 col-xs-12"><cf_get_lang dictionary_id='57800.İşlem Tipi'> *</label>
					<div class="col col-9 col-md-9 col-sm-9 col-xs-12"> 
							<cfsavecontent variable="message"><cf_get_lang dictionary_id='36740.İşlem Tipi girmelisiniz'></cfsavecontent>
							<cfif isdefined('get_op_type')>
							<cfinput type="text" name="op_name" required="yes" message="#message#" value="#get_op_type.OPERATION_TYPE#">
							<cfelse>
							<cfinput type="text" name="op_name" required="yes" message="#message#">
							</cfif> 
						</div>
					</div>
					<div class="form-group" id="item-operation_code">
					<label class="col col-3 col-md-3 col-sm-3 col-xs-12"><cf_get_lang dictionary_id="36377.Operasyon Kodu"> *</label>
					<div class="col col-9 col-md-9 col-sm-9 col-xs-12"> 
							<cfif isdefined('get_op_type')>
							<cfinput type="text" name="operation_code" id="operation_code" value="#get_op_type.OPERATION_CODE#" maxlength="5">
							<cfelse>
							<cfinput type="text" name="operation_code" id="operation_code" maxlength="5">
							</cfif>
						</div>
					</div>
					<div class="form-group" id="item-operation_cost">
						<label class="col col-3 col-md-3 col-sm-3 col-xs-12"><cf_get_lang dictionary_id='36345.İşlem Maliyeti'> *</label>
						<div class="col col-9 col-md-9 col-sm-9 col-xs-12"> 
							<div class="input-group">
								<cfsavecontent variable="message1"><cf_get_lang dictionary_id='36344.İşlem Maliyeti Girmelisiniz !'></cfsavecontent>
								<cfif isdefined('get_op_type')>
									<cfinput type="text" name="operation_cost" validate="float" class="moneybox" message="#message#" value="#TLFormat(get_op_type.operation_cost)#" onkeyup="return(FormatCurrency(this,event));">
										<span class="input-group-addon width">
										<select name="money" id="money">
												<cfloop query="get_money">
													<option value="<cfoutput>#money#</cfoutput>" <cfif get_op_type.money eq money>selected</cfif>><cfoutput>#money#</cfoutput></option>
												</cfloop>
										</select>
										</span>
								<cfelse>
									<cfinput type="text" name="operation_cost" validate="float" class="moneybox" required="yes" message="#message1#" onkeyup="return(FormatCurrency(this,event));">
										<span class="input-group-addon width">
											<select name="money" id="money">
												<cfoutput query="get_money">
													<option value="#money#" >#money#</option>
												</cfoutput>
											</select>
										</span>
								</cfif>
							</div>
						</div>
					</div>
					<div class="form-group" id="item-minutes">
					<label class="col col-3 col-md-3 col-sm-3 col-xs-12"><cf_get_lang dictionary_id='58827.Dakika'></label>
					<div class="col col-9 col-md-9 col-sm-9 col-xs-12"> 
							<cfif isdefined('get_op_type')>
							<cfinput type="text" name="minutes" maxlength="3" validate="integer" onkeyup="isNumber(this);" onblur="isNumber(this);" value="#get_op_type.O_MINUTE#">
							<cfelse>
							<cfinput type="text" name="minutes" maxlength="3" onkeyup="isNumber(this);" onblur="isNumber(this);"  validate="integer">
							</cfif>
						</div>
					</div>
					<div class="form-group" id="item-stock">
						<label class="col col-3 col-md-3 col-xs-12">
							<cf_get_lang dictionary_id='57452.Stok'>
						</label>
					<div class="col col-9 col-md-9 col-xs-12">
						<div class="input-group">
						<input type="hidden" name="stock_id_" id="stock_id_" >
						<input type="text"   name="product_name_" id="product_name_"  onFocus="AutoComplete_Create('product_name_','PRODUCT_NAME','PRODUCT_NAME,STOCK_CODE','get_product_autocomplete','0','STOCK_ID','stock_id_','','3','225');" autocomplete="off">
						<span href="javascript://" class="input-group-addon icon-ellipsis btnPointer" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=operation_type.stock_id_&field_name=operation_type.product_name_<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>');"></span>
						</div>
					</div>
					</div>
					<div class="form-group" id="item-comment_2">
					<label class="col col-3 col-md-3 col-sm-3 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'> 2</label>
					<div class="col col-9 col-md-9 col-sm-9 col-xs-12"> 
							<cfif isdefined('get_op_type')>
							<cfinput type="text" name="comment_2" maxlength="100" value="#get_op_type.comment2#"/>
							<cfelse>
							<cfinput type="text" name="comment_2" maxlength="100"/>
							</cfif>
						</div>
					</div>
					<div class="form-group" id="item-comment">
					<label class="col col-3 col-md-3 col-sm-3 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
					<div class="col col-9 col-md-9 col-sm-9 col-xs-12"> 
							<cfif isdefined('get_op_type')>
							<textarea name="comment"><cfoutput>#get_op_type.comment#</cfoutput></textarea>
							<cfelse>
							<textarea name="comment"></textarea>
							</cfif>
						</div>
					</div>
					<div class="form-group" id="item-asset">
					<label class="col col-3 col-md-3 col-sm-3 col-xs-12"><cf_get_lang dictionary_id='57468.Belge'></label>
					<div class="col col-9 col-md-9 col-sm-9 col-xs-12"> 
						<input type="file" name="asset" id="asset">
						</div>
					</div>
				</div>
			</cf_box_elements>
			<cf_box_footer>
				<input type="hidden" name="record_date" id="record_date"> 
				<input type="hidden" name="record_emp" id="record_emp"> 
				<cf_workcube_buttons is_upd='0' add_function='unformat_fields()'>
			</cf_box_footer>
		</cf_box>
	</cfform>
</div>
<script type="text/javascript">
	function unformat_fields()
	{
		if ((document.operation_type.comment_2.value.length) > 100 || (document.operation_type.comment.value.length) > 100 )
		{
			alert('<cf_get_lang dictionary_id="36779.En Fazla 100 Karakter Açıklama Girebilirsiniz">.');	
			return false;
		}
		if(document.getElementById('operation_code').value != '')
		{
			operation_code_control=wrk_safe_query("prdp_op_code","dsn3",0,document.getElementById('operation_code').value);
			if(operation_code_control.recordcount > 0)
			{
				alert("<cf_get_lang dictionary_id='36788.Girdiginiz Operasyon Kodu Kullanılıyor'>!");
				return false;
			}
		}
		else
		{
			alert("<cf_get_lang dictionary_id='36791.Lütfen Operasyon Kodu Giriniz'>");
			return false;
		}
		
		operation_type.operation_cost.value = filterNum(operation_type.operation_cost.value);
		return true;
	}
</script>
