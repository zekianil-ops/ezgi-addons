<!---
    File: dsp_ezgi_connect_campaign_product.cfm
    Folder: Add_Ons\ezgi\e_connect\display
    Author: Ezgi Yazılım
    Date: 01/01/2023
    Description:
--->
<cf_xml_page_edit>
<cfif attributes.campaign_type eq 2 or attributes.campaign_type eq 3> <!---Kampanya Tipi Hediye Ürün ve Kediye Ürün+İskonto ise--->
    
    <cfquery name="GET_PRODUCT" datasource="#DSN3#">
        SELECT 
            PDC.PRODUCT_ID, 
            S.STOCK_ID, 
            PU.MAIN_UNIT, 
            S.PRODUCT_CODE, 
            S.PRODUCT_NAME
        FROM     
            PROJECT_DISCOUNTS AS PD INNER JOIN
            PROJECT_DISCOUNT_CONDITIONS AS PDC ON PD.PRO_DISCOUNT_ID = PDC.PRO_DISCOUNT_ID INNER JOIN
            STOCKS AS S ON PDC.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
            PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
        WHERE  
            PD.PROJECT_ID = #attributes.project_id#
        ORDER BY
            PRODUCT_NAME     
    </cfquery>
    <cfif x_product_amount eq 1>
        <cfquery name="get_connect" datasource="#dsn3#">
            SELECT 
                DISCOUNTTOTAL, 
                GROSSTOTAL, 
                TAX, 
                NETTOTAL, 
                TAXTOTAL, 
                OTHER_MONEY, 
                OTHER_MONEY_VALUE
            FROM     
                EZGI_CONNECT
            WHERE  
                CONNECT_ID = #attributes.connect_id#
        </cfquery>
        <cfquery name="get_connect_money" datasource="#dsn3#">
            SELECT 
                MONEY_TYPE, 
                RATE2, 
                IS_SELECTED
            FROM     
                EZGI_CONNECT_MONEY
            WHERE  
                ACTION_ID = #attributes.connect_id#
        </cfquery>
        <cfif attributes.campaign_min_limit gt 0 and get_connect.NETTOTAL gt 0>
            <cfset hed_ur_amount = floor(get_connect.NETTOTAL/attributes.campaign_min_limit)>
        <cfelse>
            <cfset hed_ur_amount = 1>
        </cfif>
    </cfif>
    <div id="basket_main_div">
        <div class="row">
            <div id="first_area" class="col col-<cfif x_product_amount eq 1>8<cfelse>12</cfif> uniqueRow">
                <cf_box title="Hediye Ürünler">
                    <cf_grid_list>
                        <thead>
                            <tr>
                                <th width="80"></th>
                                <th><cf_get_lang dictionary_id='57564.Ürünler'></th>
                                <th width="70"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                <th width="70"><cf_get_lang dictionary_id='57636.Birim'></th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="GET_PRODUCT">
                                <cfquery name="get_images" datasource="#dsn1#">
                                    SELECT * FROM PRODUCT_IMAGES WHERE PRODUCT_ID = #product_id#
                                </cfquery>
                                <tr height="60" title="#PRODUCT_NAME#">
                                    <td style="text-align:center;">
                                        <cfif len(get_images.path)>
                                            <img  alt="product" src="/documents/product/#get_images.path#" style="height:60px;"/>
                                        <cfelse>
                                            <img  alt="product" src="/images/production/no-image.png" style="height:40px;"/>
                                        </cfif>
                                    </td>
                                    <td style="text-align:left;">
                                        <cfif x_product_amount eq 1>
                                            <a style="cursor:pointer" onclick="add_rows(#STOCK_ID#,'#PRODUCT_NAME#');">#PRODUCT_NAME#</a>
                                        <cfelse>
                                            <a style="cursor:pointer" onclick="add_product(#STOCK_ID#);">#PRODUCT_NAME#</a>
                                        </cfif>
                                    </td>
                                    <td style="text-align:right;">#TlFormat(1,2)#</td>
                                    <td style="text-align:left;">#MAIN_UNIT#</td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </cf_grid_list>         
                </cf_box>
            </div>
            <cfif x_product_amount eq 1>
                <cfform name="add_product" method="post" action="">
                    <input type="hidden" name="record_num" id="record_num" value="0">
                    <div id="second_area" class="col col-4 uniqueRow">
                        <cf_box title="<cfoutput>#hed_ur_amount#</cfoutput> Adet Hediye Ürün Seçiniz">
                            <cf_grid_list>
                                <thead>
                                    <tr>
                                        <th width="20"></th>
                                        <th>Seçilen Hediye Ürün</th>
                                    </tr>
                                </thead>
                                <tbody name="new_row" id="new_row">
        
                                </tbody>
                                <tfoot id="second_foot" style="display:none">
                                    <tr>
                                        <td colspan="2" style="text-align:right;">
                                            <button id="second_buton" name="second_buton" style="width:60px; height:30px; background-color:orange; border:none" onclick="kaydet();" >Kaydet</button>
                                        </td>
                                    </tr>
                                </tfoot>
                            </cf_grid_list>         
                        </cf_box>
                    </div>
                </cfform>
            </cfif>
        </div>
    </div>
    <script type="text/javascript">
        function add_product(stock_id)
        {
            price=0;
            window.location ="<cfoutput>#request.self#?fuseaction=sales.emptypopup_add_ezgi_connect_row&type=3&stockid="+stock_id+"&popup=1&connect_id=#attributes.connect_id#&price_cat_id=0&id_list=0&product_id=0&amount_info_list=1&product_info_list=0</cfoutput>"
        }
        <cfif x_product_amount eq 1>
            var row_count=document.getElementById('record_num').value;
            function add_rows(stock_id,product_name)
            {
                row_count++;
                var newRow;
                var newCell;
                newRow = document.getElementById("new_row").insertRow(document.getElementById("new_row").rows.length);
                newRow.setAttribute("name","frm_row" + row_count);
                newRow.setAttribute("id","frm_row" + row_count);
                newRow.setAttribute("NAME","frm_row" + row_count);
                newRow.setAttribute("ID","frm_row" + row_count);
                
                document.getElementById('record_num').value = row_count;
                
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a>';	
                    
                newCell=newRow.insertCell(newRow.cells.length);
                newCell.setAttribute('nowrap','nowrap');
                newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol'+row_count+'" id="row_kontrol'+row_count+'">';
                newCell.innerHTML = newCell.innerHTML + '<input type="hidden" id="stock_id'+row_count+'" name="stock_id'+row_count+'" value="'+stock_id+'">';
                newCell.innerHTML = newCell.innerHTML + '<input type="text" name="product_name' + row_count + '" style="width:200px;" value="'+product_name+'">';
                amount_control();
            }
            function sil(sy)
            {
                document.getElementById("row_kontrol"+sy).value =0;
                document.getElementById("frm_row"+sy).style.display="none";
                amount_control();
            } 
            function amount_control()
            {
                sayi = document.getElementById("record_num").value;
                hed_amount = 0;
                <cfoutput>
                    hed_ur_amount = #hed_ur_amount#;
                </cfoutput>
                for (i = 1; i <= sayi; i++)
                {
                    if(document.getElementById("row_kontrol"+i).value == 1)
                    {
                        hed_amount = hed_amount + 1;
                    }
                }
                if(hed_amount == hed_ur_amount)
                {
                    document.getElementById('first_area').style.display="none";
                    document.getElementById('second_area').className='col col-12';
                    document.getElementById('second_foot').style.display="";
                }
                else
                {
                    document.getElementById('first_area').style.display="";
                    document.getElementById('second_area').className='col col-4';
                    document.getElementById('second_foot').style.display="none";
                }
            }
            function kaydet()
            {
                sayi = document.getElementById("record_num").value;
                stock_id_list = '';
                for (i = 1; i <= sayi; i++)
                {
                    if(document.getElementById("row_kontrol"+i).value == 1)
                    {
                        if(list_len(stock_id_list))
                            stock_id_list = stock_id_list + ',';
                        stock_id_list = stock_id_list + document.getElementById('stock_id'+i).value;
                    }
                }
                price=0;
                window.location ="<cfoutput>#request.self#?fuseaction=sales.emptypopup_add_ezgi_connect_row&type=3&stockid="+stock_id_list+"&popup=1&connect_id=#attributes.connect_id#&price_cat_id=0&id_list=0&product_id=0&amount_info_list=1&product_info_list=0</cfoutput>";
                alert('İşlem Tamamlanmıştır.');
                wrk_opener_reload();
                window.close();
            }
        </cfif>
    </script>
<cfelseif attributes.campaign_type eq 4><!--- Ürün Bazında Hediye Ürün mü--->
	<cfquery name="GET_PRODUCT" datasource="#DSN3#">
		SELECT 
        	E.CON_PRODUCT_ID AS SEPET_PRODUCT_ID,
            ECR.QUANTITY AS SEPET_QUANTITY,
            ECR.PRODUCT_NAME AS SEPET_PRODUCT_NAME, 
            S.PRODUCT_ID, 
            S.STOCK_ID, 
            S.STOCK_CODE, 
            S.PRODUCT_NAME AS HEDIYE_PRODUCT_NAME, 
            E.QUANTITY AS HEDIYE_QUANTITY
		FROM     
        	EZGI_CONNECT_PROJECT_DISCOUNT_SUB_CONDITIONS AS E INNER JOIN
            EZGI_CONNECT_ROW AS ECR ON E.CON_PRODUCT_ID = ECR.PRODUCT_ID INNER JOIN
            STOCKS AS S ON E.PRODUCT_ID = S.PRODUCT_ID
		WHERE  
        	E.PROJECT_ID = #attributes.project_id# AND 
            ECR.CONNECT_ID = #attributes.connect_id# AND 
            S.PRODUCT_STATUS = 1
  	</cfquery>
   	<cfquery name="GET_PRODUCT_GROUP" dbtype="query">
    	SELECT 
        	SEPET_PRODUCT_ID,
         	SEPET_QUANTITY,
         	SEPET_PRODUCT_NAME
      	FROM
        	GET_PRODUCT
     	GROUP BY
        	SEPET_PRODUCT_ID,
         	SEPET_QUANTITY,
         	SEPET_PRODUCT_NAME      
    </cfquery> 
	<cfquery name="get_hed_ur_amount" dbtype="query">
     	SELECT SUM(SEPET_QUANTITY) AS HED_UR_AMOUNT FROM GET_PRODUCT_GROUP
 	</cfquery>
 	<cfset sepet_ur_amount = get_hed_ur_amount.HED_UR_AMOUNT>
    <div id="basket_main_div">
        <div class="row">
            <div id="first_area" class="col col-8 uniqueRow">
                <cf_box title="Hediye Hakeden Ürünler">
                    <cf_grid_list>
                        <thead>
                            <tr>
                                <th width="80"></th>
                                <th><cf_get_lang dictionary_id='57564.Ürünler'></th>
                                <th width="70"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="GET_PRODUCT_GROUP">
                                <cfquery name="get_images" datasource="#dsn1#">
                                    SELECT * FROM PRODUCT_IMAGES WHERE PRODUCT_ID = #sepet_product_id#
                                </cfquery>
                                <input type="hidden" id="sepet_amount_#sepet_product_id#" name="sepet_amount_#sepet_product_id#" value="#GET_PRODUCT_GROUP.SEPET_QUANTITY#" />
                                <tr title="#GET_PRODUCT_GROUP.SEPET_PRODUCT_NAME#" style="height:40px; font-weight:bold" id="frm_#GET_PRODUCT_GROUP.sepet_product_id#_1">
                                    <td style="text-align:center;">
                                        <cfif len(get_images.path)>
                                            <img  alt="product" src="/documents/product/#get_images.path#" style="height:40px;"/>
                                        <cfelse>
                                            <img  alt="product" src="/images/production/no-image.png" style="height:40px;"/>
                                        </cfif>
                                    </td>
                                    <td style="text-align:left;">#GET_PRODUCT_GROUP.SEPET_PRODUCT_NAME#</td>
                                    <td style="text-align:right;">#TlFormat(GET_PRODUCT_GROUP.SEPET_QUANTITY,2)#</td>
                                </tr>
                                <cfquery name="GET_PRODUCT_HEDIYE" dbtype="query">
                                	SELECT 
                                        PRODUCT_ID, 
                                        STOCK_ID, 
                                        STOCK_CODE, 
                                        HEDIYE_PRODUCT_NAME, 
                                        HEDIYE_QUANTITY
                                 	FROM
                                    	GET_PRODUCT
                                  	WHERE
                                   		SEPET_PRODUCT_ID = #GET_PRODUCT_group.SEPET_PRODUCT_ID# 	
                                </cfquery>
                                <tr id="frm_#sepet_product_id#_2">
                                	<td colspan="3">
                                    	<table cellpadding="0" cellspacing="0" border="1" style="width:100%">
                                        	<cfif GET_PRODUCT_HEDIYE.recordcount>
                                            	<cfloop query="GET_PRODUCT_HEDIYE">
                                                    <tr>
                                                        <td style="height:15px; width:20px; text-align:right">#GET_PRODUCT_HEDIYE.currentrow#</td>
                                                        <td style="text-align:left;">
                                                        	<a style="cursor:pointer" onclick="add_rows(#GET_PRODUCT_group.SEPET_PRODUCT_ID#,#GET_PRODUCT_HEDIYE.STOCK_ID#,'#GET_PRODUCT_HEDIYE.HEDIYE_PRODUCT_NAME#',#GET_PRODUCT_HEDIYE.HEDIYE_QUANTITY#);">
                                                            	#GET_PRODUCT_HEDIYE.HEDIYE_PRODUCT_NAME#
                                                          	</a>
                                                       	</td>
                                                        <td style="width:50px; text-align:right">#TlFormat(GET_PRODUCT_HEDIYE.HEDIYE_QUANTITY,2)#</td>
                                                    </tr>
                                            	</cfloop>
                                            </cfif>
                                        </table>
                                    </td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </cf_grid_list>         
                </cf_box>
            </div>
       		<cfform name="add_product" method="post" action="">
             	<input type="hidden" name="record_num" id="record_num" value="0">
            	<div id="second_area" class="col col-4 uniqueRow">
                	<cf_box title="Seçilen Hediye Ürünler">
                   	 	<cf_grid_list>
                        	<thead>
                            	<tr>
                                	<th width="20"></th>
                                 	<th><cf_get_lang dictionary_id='57564.Ürünler'></th>
                                    <th width="40"><cf_get_lang dictionary_id='57635.Miktar'></th>
                             	</tr>
                       		</thead>
                         	<tbody name="new_row" id="new_row">
        
                         	</tbody>
                         	<tfoot id="second_foot" style="display:none">
                             	<tr>
                               		<td colspan="3" style="text-align:right;">
                                    	<button id="second_buton" name="second_buton" style="width:60px; height:30px; background-color:orange; border:none" onclick="kaydet();" >Kaydet</button>
                              		</td>
                            	</tr>
                       		</tfoot>
                    	</cf_grid_list>         
                  	</cf_box>
             	</div>
          	</cfform>
        </div>
    </div>
 	<script type="text/javascript">
        function add_product(stock_id)
        {
            price=0;
            window.location ="<cfoutput>#request.self#?fuseaction=sales.emptypopup_add_ezgi_connect_row&type=3&stockid="+stock_id+"&popup=1&connect_id=#attributes.connect_id#&price_cat_id=0&id_list=0&product_id=0&amount_info_list=1&product_info_list=0</cfoutput>"
        }

     	var row_count=document.getElementById('record_num').value;
    	function add_rows(sepet_product_id,stock_id,product_name,quantity)
      	{
                row_count++;
                var newRow;
                var newCell;
                newRow = document.getElementById("new_row").insertRow(document.getElementById("new_row").rows.length);
                newRow.setAttribute("name","frm_row" + row_count);
                newRow.setAttribute("id","frm_row" + row_count);
                newRow.setAttribute("NAME","frm_row" + row_count);
                newRow.setAttribute("ID","frm_row" + row_count);
                
                document.getElementById('record_num').value = row_count;
                
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = row_count;	
                    
                newCell=newRow.insertCell(newRow.cells.length);
                newCell.setAttribute('nowrap','nowrap');
                newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol'+row_count+'" id="row_kontrol'+row_count+'">';
                newCell.innerHTML = newCell.innerHTML + '<input type="hidden" id="stock_id'+row_count+'" name="stock_id'+row_count+'" value="'+stock_id+'">';
                newCell.innerHTML = newCell.innerHTML + '<input type="text" name="product_name' + row_count + '" style="width:150px;" value="'+product_name+'">';
				
				newCell=newRow.insertCell(newRow.cells.length);
				newCell.innerHTML = '<input type="text" id="quantity' + row_count +'" name="quantity' + row_count +'" value="'+quantity+'" style="width:40px; text-align:right;border-style:none">';
				
                amount_control(sepet_product_id);
   		}

    	function amount_control(sepet_product_id)
    	{
            hed_urun_amount = document.getElementById('sepet_amount_'+sepet_product_id).value;
			document.getElementById('sepet_amount_'+sepet_product_id).value = hed_urun_amount*1 - 1;	
       		if(document.getElementById('sepet_amount_'+sepet_product_id).value == 0)
       		{
            	document.getElementById('frm_'+sepet_product_id+'_2').style.display="none";
       		}
           	<cfoutput>
             	sepet_ur_amount = #sepet_ur_amount#;
           	</cfoutput>
          	if(sepet_ur_amount == document.getElementById("record_num").value)
        	{
              	document.getElementById('first_area').style.display="none";
              	document.getElementById('second_area').className='col col-12';
              	document.getElementById('second_foot').style.display="";
        	}
    	}
    	function kaydet()
     	{
                sayi = document.getElementById("record_num").value;
                stock_id_list = '';
                for (i = 1; i <= sayi; i++)
                {
                    if(document.getElementById("row_kontrol"+i).value == 1)
                    {
                        if(list_len(stock_id_list))
                            stock_id_list = stock_id_list + ',';
                        stock_id_list = stock_id_list + document.getElementById('stock_id'+i).value + '*'+document.getElementById('quantity'+i).value;
                    }
                }
                price=0;
                window.location ="<cfoutput>#request.self#?fuseaction=sales.emptypopup_add_ezgi_connect_row&type=3&stockid="+stock_id_list+"&popup=1&connect_id=#attributes.connect_id#&price_cat_id=0&id_list=0&product_id=0&amount_info_list=1&product_info_list=0</cfoutput>";
                alert('İşlem Tamamlanmıştır.');
                wrk_opener_reload();
                window.close();
    	}
    </script>
</cfif>
