<cfset module_name="prod">
<cfquery name="get_p_order_control" datasource="#dsn3#"> <!---Üretimi Tamamlanmış Emirler Listeden Çıkartılıyor--->
	SELECT     
     	P_ORDER_ID
	FROM            
    	PRODUCTION_ORDERS
	WHERE        
   		IS_STAGE IN (0, 4) AND
      	P_ORDER_ID IN (#attributes.p_order_id_list#)
</cfquery>
<cfif get_p_order_control.recordcount>
	<cfset attributes.p_order_id_list = ValueList(get_p_order_control.P_ORDER_ID)>
<cfelse>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='38113.Üretimler Sonuçlandırılmış'> - <cf_get_lang dictionary_id='766.İşlem Yapılamaz'>!");
		window.close()
	</script>
    <cfabort>
</cfif>
<cfquery name="get_production_orders" datasource="#dsn3#">
	SELECT        
    	PO.OPERATION_TYPE_ID, 
        COUNT(*) AS SAY, 
        OT.OPERATION_TYPE, 
        SUM(ISNULL(TBL.SON, 0)) AS SON
	FROM            
    	PRODUCTION_OPERATION AS PO WITH (NOLOCK) INNER JOIN
       	OPERATION_TYPES AS OT WITH (NOLOCK) ON PO.OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID LEFT OUTER JOIN
      	(
        	SELECT        
            	POO.OPERATION_TYPE_ID, 
                POO.P_OPERATION_ID, 
                1 AS SON
          	FROM            
            	PRODUCTION_OPERATION AS POO WITH (NOLOCK) INNER JOIN
           		PRODUCTION_OPERATION_RESULT AS POR WITH (NOLOCK) ON POO.P_OPERATION_ID = POR.OPERATION_ID
           	GROUP BY
            	POO.OPERATION_TYPE_ID, 
                POO.P_OPERATION_ID
      	) AS TBL ON PO.P_OPERATION_ID = TBL.P_OPERATION_ID
	WHERE        
    	PO.P_ORDER_ID IN 
                      	(
                         	SELECT     
                            	P_ORDER_ID
							FROM            
                             	PRODUCTION_ORDERS WITH (NOLOCK)
							WHERE        
                            	IS_STAGE IN (0, 4) AND
                              	P_ORDER_ID IN (#attributes.p_order_id_list#)
                  		)
	GROUP BY 
    	PO.OPERATION_TYPE_ID, 
        OT.OPERATION_TYPE
	ORDER BY 
    	OT.OPERATION_TYPE
</cfquery>
<cfsavecontent variable="title"><cf_get_lang dictionary_id='29419.Operasyon'> <cf_get_lang dictionary_id='47870.Revizyon'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfform name="upd_operation" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_iflow_product_operation_revision">
        <cf_box title="#title#">
            <div class="col col-5">
                <cfsavecontent variable="title1"><cf_get_lang dictionary_id='1029.Mevcut Operasyon'></cfsavecontent>
                <cf_box title="#title1#">
                    <cfinput type="hidden" name="p_order_id_list" value="#attributes.p_order_id_list#">
                    <cfinput type="hidden" name="operation_id_list" id="operation_id_list" value="">
                    <cf_grid_list>
                        <cfset colspan_ = 10>
                        <cfset colspan_info = 8>
                        <thead>
                            <tr>
                                <th style="text-align:center; width:65%"><cf_get_lang dictionary_id='437.Operasyon Adı'></th>
                                <th style="text-align:center; width:15%"><cf_get_lang dictionary_id='57492.Toplam'></th>
                                <th style="text-align:center; width:15%"><cf_get_lang dictionary_id='58135.Sonuçlar'></th>
                                <th style="text-align:center; width:20px"><input type="checkbox" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="grupla(-1);"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="get_production_orders">
                                <tr  height="20px">
                                    <td>&nbsp;#OPERATION_TYPE#</td>
                                    <td style="text-align:right">#SAY#&nbsp;</td>
                                    <td style="text-align:right">#SON#&nbsp;</td>
                                    <td style="text-align:center;">
                                        <cfif say gt son>
                                            <input type="checkbox" name="select_production" value="#OPERATION_TYPE_ID#">
                                        <cfelse>
                                            <img src="/images/c_ok.gif" border="0" title="" />
                                        </cfif>
                                    </td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </cf_grid_list>
                
                </cf_box>
            </div>
            <div class="col col-3">
                <cfsavecontent variable="title2"><cf_get_lang dictionary_id='37546.Ekle veya Değiştir'></cfsavecontent>
                <cf_box title="#title2#">
                    <cf_box_search>
                        <div class="col col-12">
                            <label class="col col-10"><cf_get_lang dictionary_id='57582.Ekle'></label>
                            <div class="col col-2">
                                <div class="form-group">
                                    <input type="radio" name="ekle_radio" id="ekle_radio0" value="0"/>
                                </div>
                            </div>
                        </div>
                        <div class="col col-12">
                            <label class="col col-10"><cf_get_lang dictionary_id='357.Çıkar'></label>
                            <div class="col col-2">
                                <div class="form-group">
                                    <input type="radio" name="ekle_radio" id="ekle_radio1" value="1"/>
                                </div>
                            </div>
                        </div>
                        <div class="col col-12">
                            <label class="col col-10"><cf_get_lang dictionary_id='47334.Değiştir'></label>
                            <div class="col col-2">
                                <div class="form-group">
                                    <input type="radio" name="ekle_radio" id="ekle_radio2" checked="checked" value="2"/>
                                </div>
                            </div>
                        </div>
                    </cf_box_search>
                </cf_box>
            </div>
            <div class="col col-4">
                <cfsavecontent variable="title3"><cf_get_lang dictionary_id='36380.Operasyon Ekle'></cfsavecontent>
                <cf_box title="#title3#">
                    <cfinput type="hidden" name="operation_id_list" id="operation_id_list" value="">
                    <cf_grid_list>
                        <cfset colspan_ = 10>
                        <cfset colspan_info = 8>
                        <thead>
                            <tr>
                                <th style="text-align:center; width:20px">
                                    <input type="hidden" name="record_num" id="record_num" value="">
                                    <input type="button" class="eklebuton" title="<cf_get_lang dictionary_id='57582.Ekle'>" onclick="openOperatios();">
                                </th>
                                <th style="text-align:center; width:220px"><cf_get_lang dictionary_id='437.Operasyon Adı'></th>
                                <th style="text-align:center; width:40px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            </tr>
                        </thead>
                        <tbody name="new_row" id="new_row">
                            <tr name="frm_row#currentrow#" id="frm_row#currentrow#">
                            </tr>
                        </tbody>
                    </cf_grid_list>
                </cf_box>
            </div>
        </cf_box>
        <cf_box>
        	<div class="col col-12">
            	<cf_workcube_buttons 
                         	is_upd='0' 
                       		is_delete = '0' 
                        	add_function='kontrol()'>
            </div>
        </cf_box>
 	</cfform>
</div>
<script type="text/javascript">
	function grupla(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
		operation_id_list = '';
		chck_leng = document.getElementsByName('select_production').length;
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
					operation_id_list +=my_objets.value+',';
			}
		}
		operation_id_list = operation_id_list.substr(0,operation_id_list.length-1);//sondaki virgülden kurtarıyoruz.
		return true;
	}
	var row_count=document.upd_operation.record_num.value;
	function openOperatios()
	{
		window.open("<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_operations</cfoutput>","_blank","width=300,height=600,left=700,top=300");
	}
	function add_row(operation_type_id,operation_type)
	{
		row_count++;
		var newRow;
		var newCell;
		newRow = document.getElementById("new_row").insertRow(document.getElementById("new_row").rows.length);
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);
		newRow.setAttribute("NAME","frm_row" + row_count);
		newRow.setAttribute("ID","frm_row" + row_count);
		document.upd_operation.record_num.value = row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a>';
			
			
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol'+row_count+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" id="operation_type_id'+row_count+'" name="operation_type_id'+row_count+'" value="'+operation_type_id+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="text" name="operation_type' + row_count + '" style="width:100%;" value="'+operation_type+'">';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="quantity' + row_count +'" name="quantity' + row_count +'" value="<cfoutput>#TlFormat(1,2)#</cfoutput>" style="width:100%; text-align:right;">';
	}
	function sil(sy)
	{
		var element=eval("upd_operation.row_kontrol"+sy);
		element.value=0;
		var element=eval("frm_row"+sy); 
		element.style.display="none";
	} 
	function kontrol()
	{
		grupla();
		document.getElementById('operation_id_list').value = operation_id_list;
		if(document.upd_operation.ekle_radio[0].checked==true)//ekleme islemi
		{

		}
		else if(document.upd_operation.ekle_radio[1].checked==true)//çıkarma islemi
		{
			operation_say = list_len(operation_id_list);
			if(operation_say<1)
			{
				alert("<cf_get_lang dictionary_id='38085.Lütfen Operasyon Seçiniz'>");
				return false;
			}
		}
		else if(document.upd_operation.ekle_radio[2].checked==true)//değiştir islemi
		{
			 operation_say = list_len(operation_id_list);
			if(operation_say<1)
			{
				alert("<cf_get_lang dictionary_id='38085.Lütfen Operasyon Seçiniz'>");
				return false;
			}
			if(document.getElementById('record_num').value<1)
			{
				alert("<cf_get_lang dictionary_id='38085.Lütfen operasyon kodu giriniz.'>");
				return false;
			}
		}
	}
</script>