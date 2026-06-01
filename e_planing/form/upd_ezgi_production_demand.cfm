<cfquery name="get_deamand" datasource="#dsn3#">
	SELECT * FROM EZGI_PRODUCTION_DEMAND WHERE EZGI_DEMAND_ID = #attributes.upd_id#
</cfquery>
<cfset paper_project_id = get_deamand.PROJECT_ID>
<cfquery name="get_deamand_row" datasource="#dsn3#">
	SELECT  
    	EDPR.EZGI_DEMAND_ROW_ID,      
    	EDPR.STOCK_ID, 
        EDPR.QUANTITY, 
        EDPR.EZGI_ID, 
        EDPR.PRODUCT_TYPE, 
        S.PRODUCT_NAME, 
        S.PRODUCT_CODE, 
        PU.MAIN_UNIT, 
        ISNULL(SUM(EPO.QUANTITY), 0) AS PROD_QUANTITY
	FROM           
    	EZGI_PRODUCTION_DEMAND_ROW AS EDPR INNER JOIN
      	STOCKS AS S ON EDPR.STOCK_ID = S.STOCK_ID INNER JOIN
      	PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID LEFT OUTER JOIN
     	EZGI_IFLOW_PRODUCTION_ORDERS AS EPO ON EDPR.EZGI_DEMAND_ROW_ID = EPO.ACTION_ID
	WHERE        
    	EDPR.EZGI_DEMAND_ID = #attributes.upd_id#
	GROUP BY 
    	EDPR.EZGI_DEMAND_ROW_ID,
    	EDPR.STOCK_ID, 
        EDPR.QUANTITY, 
        EDPR.EZGI_ID, 
        EDPR.PRODUCT_TYPE, 
        S.PRODUCT_NAME, 
        S.PRODUCT_CODE, 
        PU.MAIN_UNIT 
   ORDER BY EDPR.EZGI_DEMAND_ROW_ID
</cfquery>
<cfquery name="get_department" datasource="#dsn#">
	SELECT        
    	DEPARTMENT_HEAD, 
        DEPARTMENT_ID,
        DEPARTMENT_STATUS
	FROM            
    	DEPARTMENT
	WHERE        
    	IS_PRODUCTION = 1 AND 
        BRANCH_ID IN (SELECT BRANCH_ID FROM BRANCH WHERE COMPANY_ID = #session.ep.company_id#) and
        DEPARTMENT_STATUS = 1
</cfquery>
<cfif not get_deamand_row.recordcount>
	<cfset get_deamand_row.recordcount = 0>
</cfif>
<cfquery name="get_delete_control" dbtype="query">
    SELECT SUM(PROD_QUANTITY) AS CONTROL_ FROM get_deamand_row
</cfquery>
<cfparam name="attributes.order_employee_id" default="#get_deamand.DEMAND_EMP#">
<cfparam name="attributes.order_employee" default="#get_emp_info(get_deamand.DEMAND_EMP,0,0)#">
<cfparam name="attributes.demand_employee_id" default="#get_deamand.DEMAND_TO_EMP#">
<cfparam name="attributes.demand_employee" default="#get_emp_info(get_deamand.DEMAND_TO_EMP,0,0)#">
<cfparam name="attributes.department_id" default="#get_deamand.DEMAND_DEPARTMENT_ID#">
<cfparam name="attributes.date" default="#get_deamand.DEMAND_DATE#">
<cfparam name="attributes.termin" default="#get_deamand.DEMAND_DELIVER_DATE#">
<cfparam name="attributes.date" default="">
<cfparam name="attributes.termin" default="">
<cfset var_="upd_purchase_basket">
<cfsavecontent variable="right_menu">
	<a style="cursor:pointer" onclick="add_demand_row();"><img src="images/carier.gif"  title="<cf_get_lang dictionary_id='272.Üretim Plan Hesaplama'>" border="0"></a>&nbsp;&nbsp;
  	<a style="cursor:pointer" onclick="add_demonte_row();"><img src="images/package.gif"  title="<cf_get_lang dictionary_id='273.Demonte Ürün Hesaplama'>" border="0"></a>&nbsp;&nbsp;
</cfsavecontent>
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
   	<cf_box >
   		<cfform name="form_basket" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_production_demand">
        	<cfinput type="hidden" name="upd_id" value="#attributes.upd_id#">
            <cf_basket_form id="upd_design">
                <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
								<cf_box_elements>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                                    	<div class="form-group" id="item-demand_head">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58820.Başlık'></label>
                                            <div class="col col-8 col-xs-12">
                                            	<cfinput type="text" name="demand_head" value="#get_deamand.demand_head#" maxlength="50">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-demand_no">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36446.Talep No'></label>
                                            <div class="col col-8 col-xs-12">
                                            	<cfinput type="text" name="demand_no" readonly="yes" value="#get_deamand.demand_number#" style="text-align:right">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-demand_order_employee">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='33360.Talep Eden'></label>
                                            <div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                	<input type="hidden" name="order_employee_id" id="order_employee_id" value="<cfif isdefined('attributes.order_employee_id') and len(attributes.order_employee_id) and isdefined('attributes.order_employee') and len(attributes.order_employee)><cfoutput>#attributes.order_employee_id#</cfoutput></cfif>">
                 									<input name="order_employee" type="text" id="order_employee" style="width:160px;vertical-align:top" onfocus="AutoComplete_Create('order_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','order_employee_id','','3','125');" value="<cfif isdefined('attributes.order_employee_id') and len(attributes.order_employee_id) and isdefined('attributes.order_employee') and len(attributes.order_employee)><cfoutput>#attributes.order_employee#</cfoutput></cfif>" autocomplete="off">	
                                                    <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=form_basket.order_employee_id&field_name=form_basket.order_employee&is_form_submitted=1&select_list=1','list');"></span>
                                            	</div>
                                            </div>
                                        </div>
                                   	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                                    	<div class="form-group" id="item-demand_process">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç"> *</label>
                                            <div class="col col-8 col-xs-12">
                                                <cf_workcube_process is_upd='0' select_value='#get_deamand.process_stage#' process_cat_width='125' is_detail='1'>
                                            </div>
                                       	</div>
                                        <div class="form-group" id="item-department">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57572.Departman'> *</label>
                                            <div class="col col-8 col-xs-12">
                                            	<select name="department_id"  id="department_id"style="width:160px; height:20px">
                                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                    <cfoutput query="get_department">
                                                        <option value="#department_id#" <cfif department_id eq attributes.department_id>selected</cfif>>#DEPARTMENT_HEAD#</option>
                                                    </cfoutput>
                                                </select>
                                            </div>
                                       	</div>
                                        <div class="form-group" id="item-demand_employee">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57924.Kime'></label>
                                            <div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                	<input type="hidden" name="demand_employee_id" id="demand_employee_id" value="<cfif isdefined('attributes.demand_employee_id') and len(attributes.demand_employee_id) and isdefined('attributes.demand_employee') and len(attributes.demand_employee)><cfoutput>#attributes.demand_employee_id#</cfoutput></cfif>">
                 									<input name="demand_employee" type="text" id="demand_employee" style="width:160px;vertical-align:top" onfocus="AutoComplete_Create('order_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','demand_employee_id','','3','125');" value="<cfif isdefined('attributes.demand_employee_id') and len(attributes.demand_employee_id) and isdefined('attributes.demand_employee') and len(attributes.demand_employee)><cfoutput>#attributes.demand_employee#</cfoutput></cfif>" autocomplete="off">	
                                                    <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=form_basket.demand_employee_id&field_name=form_basket.demand_employee&is_form_submitted=1&select_list=1','list');"></span>
                                            	</div>
                                            </div>
                                        </div>
                                   	</div>
                                  	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                                    	<div class="form-group" id="item-demand_date">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57692.İşlem'>*</label>
                                            <div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57906.İşlem Tarihi Girmelisiniz'></cfsavecontent>
                                					<cfinput required="Yes" message="#message#" type="text" name="date" id="date" validate="eurodate" style="width:65px;" value="#dateformat(attributes.date,'dd/mm/yyyy')#">
                                					<span class="input-group-addon"><cf_wrk_date_image date_field="date"></span>
                            					</div>
                                            </div>
                                       	</div>
                                        <div class="form-group" id="item-demand_termin">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36798.Termin'> *</label>
                                            <div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                					<cfsavecontent variable="message"><cf_get_lang dictionary_id='275.Termin Tarihi Girmelisiniz'></cfsavecontent>
                                					<cfinput required="Yes" message="#message#" type="text" name="termin" id="termin" validate="eurodate" style="width:65px;" value="#dateformat(attributes.termin,'dd/mm/yyyy')#">
                                					<span class="input-group-addon"><cf_wrk_date_image date_field="termin"></span>
                            					</div>
                                            </div>
                                       	</div>
                                        <div class="form-group" id="item-shift_project_id">
                  							<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                     						<div class="col col-8 col-xs-12">
                       							<div class="input-group">
                                                	<cfoutput>
                                                    <input type="hidden" name="project_id" id="project_id" value="#paper_project_id#">
                                					<input type="text" name="project_head" id="project_head" value="<cfif len(paper_project_id)>#GET_PROJECT_NAME(paper_project_id)#</cfif>" style="width:200px;"onFocus="AutoComplete_Create('project_head','PROJECT_ID,PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','','3','135')"autocomplete="off">
                                					<span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_head=list_works.project_head&project_id=list_works.project_id');"></span>
                                                    </cfoutput>
                                                </div>
                                            </div>
                                        </div>
                                  	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                                    	<div class="form-group" id="item-demand_detail">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36199.Açıklama'></label>
                                            <div class="col col-8 col-xs-12">
                                            	<textarea name="detail" id="detail" style="height:90px; width:190px"><CFOUTPUT>#get_deamand.DEMAND_DETAIL#</CFOUTPUT></textarea>
                                            </div>
                                       	</div>
                                   	</div>
                               	</cf_box_elements>
                                <cf_box_footer>
                                    <div class="col col-12">
                                    	<cfif get_delete_control.CONTROL_ eq 0 or not get_deamand_row.recordcount>
                                        	<cf_workcube_buttons is_upd='1' add_function='kontrol()' 
                                                is_delete='1'
                                                del_function='sil_kontrol()' 
                                            >
                                        <cfelse>
                                            <cf_workcube_buttons is_delete='0' is_upd='1' add_function='kontrol()'>
                                        </cfif>
                                    </div>
                                </cf_box_footer>
                          	</div>
                     	</div>
          		</div>   
          	</cf_basket_form>
            <cf_basket id="upd_default_color_bask">
            	<cf_grid_list sort="0">
                    <thead>
                        <tr>
                            <th width="30px" style="text-align:center">
                                <a href="javascript://" onClick="openProducts();">
                                    <img src="/images/plus_list.gif" border="0" id="basket_header_add" title="<cfoutput><cf_get_lang dictionary_id='29413.Lütfen Muhasebe Fiş Numaralarını Düzenleyiniz'></cfoutput>">
                                </a>
                            </th>
                            <th width="30px"><cf_get_lang dictionary_id='58577.Sıra'></th>
							<th width="90px" nowrap="nowrap"><cf_get_lang dictionary_id='537.Ürün Tipi'></th>
							<th width="180px" nowrap="nowrap"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
							<th width="100%" nowrap="nowrap"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
							<th width="95px"><cf_get_lang dictionary_id='57635.Miktar'></th>
							<th width="50px"><cf_get_lang dictionary_id='57636.Birim'></th>
                            <th width="70px"><cf_get_lang dictionary_id='49884.Üretim Emri'></th>
                        </tr>
                    </thead>
                    <tbody name="new_row" id="new_row">
                    	<input type="hidden" name="record_num" id="record_num" value="<cfoutput>#get_deamand_row.recordcount#</cfoutput>">
						<cfif get_deamand_row.recordcount gt 0>
                            <cfoutput query="get_deamand_row">
                                <input type="Hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                                <input type="Hidden" name="demand_row_list" id="demand_row_list" value="#EZGI_DEMAND_ROW_ID#">
                                <tr id="frm_row#currentrow#">
                                    <td style="text-align:center; height:30px">
                                        <cfif prod_quantity eq 0>
                                            <a href="javascript://" onClick="sil(#currentrow#);">
                                                <img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0">
                                            </a>
                                        </cfif>
                                    </td>
                                    <td style="text-align:center">#currentrow#&nbsp;</td>
                                    <td class="boxtext">&nbsp;
                                        <cfif PRODUCT_TYPE eq 1><cf_get_lang dictionary_id='58511.Takım'>
                                        <cfelseif PRODUCT_TYPE eq 2><cf_get_lang dictionary_id='141.Modül'>
                                        <cfelseif PRODUCT_TYPE eq 3><cf_get_lang dictionary_id='100.Paket'>
                                        <cfelseif PRODUCT_TYPE eq 4><cf_get_lang dictionary_id='45.Parça'>
                                        </cfif>
                                        <input type="hidden" name="type#currentrow#" id="type#currentrow#" value="#PRODUCT_TYPE#">
                                    </td>
                                    <td>&nbsp;
                                        <input type="text" id="stock_code#currentrow#" name="stock_code#currentrow#" style="width:140px;" class="boxtext" value="#PRODUCT_CODE#" readonly=yes>
                                    </td>
                                    <td nowrap="nowrap">&nbsp;
                                        <input type="Hidden" name="stock_id#currentrow#" value="#stock_id#">
                                        <input type="text" name="product_name#currentrow#" style="width:300px;" class="boxtext" value="#product_name#">
                                    </td>
                                    <td style="text-align:right">
                                        <input type="text" name="quantity#currentrow#" id="quantity#currentrow#"  value="#TlFormat(quantity,2)#" onkeyup="isNumber(this);" style="width:65px; text-align:right;">
    
                                    </td>
                                    <td nowrap="nowrap">&nbsp;
                                        <input type="text" name="main_unit#currentrow#" style="width:50px;" class="boxtext" value="#MAIN_UNIT#">
                                    </td>
                                    <td style="text-align:right">
                                        <input type="text" name="prod_quantity#currentrow#" readonly="readonly" id="prod_quantity#currentrow#"  value="#TlFormat(prod_quantity,2)#" onkeyup="isNumber(this);" style="width:65px; text-align:right;">
                                    </td>
                                </tr>
                            </cfoutput>
                        </cfif>
                  	</tbody>
            	</cf_grid_list>
            </cf_basket>
 		</cfform>
   	</cf_box>
</div>
<script type="text/javascript">
	var row_count = document.form_basket.record_num.value;
	function kontrol()
	{
		if (form_basket.termin.value.length == '')
		{
			alert("<cf_get_lang dictionary_id='292.Planlama Tarihi Girmelisiniz'> !");
			return false;
		}
		if (form_basket.date.value.length == '')
		{
			alert("<cf_get_lang dictionary_id='292.Planlama Tarihi Girmelisiniz'> !");
			return false;
		}
		if(process_cat_control())
			return true;
		else
			return false;
	}
	function sil_kontrol()
	{
		if(process_cat_control())
			window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_production_demand&upd_id=#attributes.upd_id#</cfoutput>";
		else
			return false;
	}
	function add_demand_row()
	{
		windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_production_need&upd_id=#attributes.upd_id#'</cfoutput>,'longpage');
	}
	function add_demonte_row()
	{
		windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_production_demonte_need&upd_id=#attributes.upd_id#'</cfoutput>,'longpage');
	}
	function openProducts()
	{
		windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_ezgi_stocks&price_cat=-2&ezgi_production=1&add_product_cost=1&module_name=product&var_=#var_#&is_action=1&startdate=&price_lists='</cfoutput>,'page');
	}
	function sil(sy)
	{
		var element=eval("form_basket.row_kontrol"+sy);
		element.value=0;
		var element=eval("frm_row"+sy); 
		element.style.display="none";		
	}
	function add_row(stockid,stockprop,sirano,product_id,product_name,stock_code,type,type_detail,main_unit)
	{
		row_count++;
		var newRow;
		var newCell;
		newRow = document.getElementById("new_row").insertRow(document.getElementById("new_row").rows.length);
		newRow.className = 'color-row';
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);
		newRow.setAttribute("NAME","frm_row" + row_count);
		newRow.setAttribute("ID","frm_row" + row_count);
		document.form_basket.record_num.value = row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.setAttribute("style", "text-align:right;");
		newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a>&nbsp;';	
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.setAttribute("style", "text-align:center;");
		newCell.innerHTML = row_count+'&nbsp;';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" name="type' + row_count + '" value="'+type+'">';
		newCell.innerHTML = newCell.innerHTML + '&nbsp;<input type="text" name="type_detail' + row_count + '" style="width:70px; height:30px" class="boxtext" value="'+type_detail+'"><input type="Hidden" name="ezgi_id' + row_count + '" id="ezgi_id' + row_count + '" value="">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '&nbsp;<input type="text" name="stock_code' + row_count + '" style="width:140px;" class="boxtext" value="'+stock_code+'">';
		
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol'+row_count+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="stock_id'+row_count+'" value="' + stockid + '">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="product_id'+row_count+'" value="'+product_id+'">';
		newCell.innerHTML = newCell.innerHTML + '&nbsp;<input type="text" name="product_name' + row_count + '" style="width:300px;" class="boxtext" value="'+product_name+'">';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.setAttribute("style", "text-align:right;");
		newCell.innerHTML = '<input type="text" id="quantity' + row_count +'" name="quantity' + row_count +'" value="<cfoutput>#TlFormat(1,2)#</cfoutput>" style="width:65px; text-align:right;">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '&nbsp;<input type="text" name="main_unit' + row_count + '" style="width:50px;" class="boxtext" value="'+main_unit+'">';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.setAttribute("style", "text-align:right;");
		newCell.innerHTML = '<input type="text" id="prod_quantity' + row_count +'" name="prod_quantity' + row_count +'" value="<cfoutput>#TlFormat(0,2)#</cfoutput>" style="width:65px; text-align:right;">';
	}
</script>