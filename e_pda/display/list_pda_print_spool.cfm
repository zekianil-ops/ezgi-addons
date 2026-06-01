<!---
    File: list_pda_print_spool.cfm
    Folder: Add_Ons\ezgi\e-pda\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_spool" datasource="#dsn3#">
	SELECT        
    	S.BARCOD, 
        ESR.DELIVER_PAPER_NO, 
        S.PRODUCT_NAME, 
        E.EZGI_PRINT_ID, 
        E.STOCK_ID, 
        ISNULL(SUM(E.AMOUNT),0) AS AMOUNT
	FROM            
    	EZGI_PDA_PRINT_SPOOL AS E WITH (NOLOCK) INNER JOIN
    	STOCKS AS S WITH (NOLOCK) ON E.STOCK_ID = S.STOCK_ID INNER JOIN
    	EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) ON E.SHIP_ID = ESR.SHIP_RESULT_ID INNER JOIN
     	EZGI_SHIP_RESULT_ROW WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = EZGI_SHIP_RESULT_ROW.SHIP_RESULT_ID
	WHERE        
    	E.RECORD_EMP = #session.ep.userid# AND 
        E.STATUS = 0 AND 
        E.IS_TYPE = 1
	GROUP BY 
    	S.BARCOD, 
        ESR.DELIVER_PAPER_NO, 
        S.PRODUCT_NAME, 
        E.EZGI_PRINT_ID, 
        E.STOCK_ID
  	UNION ALL
    SELECT        
    	S.BARCOD, 
        CAST(ESR.SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) AS DELIVER_PAPER_NO, 
        S.PRODUCT_NAME, 
        E.EZGI_PRINT_ID, 
        E.STOCK_ID, 
        ISNULL(SUM(E.AMOUNT),0) AS AMOUNT
	FROM            
    	EZGI_PDA_PRINT_SPOOL AS E WITH (NOLOCK) INNER JOIN
    	STOCKS AS S WITH (NOLOCK) ON E.STOCK_ID = S.STOCK_ID INNER JOIN
    	EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) ON E.SHIP_ID = ESR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
     	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = EZGI_SHIP_RESULT_INTERNALDEMAND_ROW.SHIP_RESULT_INTERNALDEMAND_ID
	WHERE        
    	E.RECORD_EMP = #session.ep.userid# AND 
        E.STATUS = 0 AND 
        E.IS_TYPE = 2
	GROUP BY 
    	S.BARCOD, 
        ESR.SHIP_RESULT_INTERNALDEMAND_ID, 
        S.PRODUCT_NAME, 
        E.EZGI_PRINT_ID, 
        E.STOCK_ID
</cfquery>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default=20>
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows)+1>
<cfparam name="attributes.totalrecords" default='#get_spool.recordcount#'>
<cfform name="frm_search" method="post" action="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_pda_print_spool">
  	<input type="hidden" name="is_form_submitted" value="1">
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    	<cfsavecontent variable="title"><cf_get_lang dictionary_id="10.Etiket Havuzu"></cfsavecontent>
        <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
            <cf_form_list>
                <thead>
                    <tr>
                        <th style="width:25%"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        <th style="width:25%"><cf_get_lang dictionary_id='57633.Barkod'></th>
                        <th style="width:100%"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                        <th style="width:10%"><input type="checkbox" style="text-align:center;" alt="<cf_get_lang dictionary_id="206.Hepsini Seç">" onClick="grupla(-1);"></th>
                   	</tr>
               	</thead>  
                <tbody>
                	<cfif get_spool.recordcount>
    					<cfoutput query="get_spool" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                        	<tr>
                                <td style="text-align:center; height:20px">#DELIVER_PAPER_NO#</td>
                                <td style="text-align:center">#barcod#</td>
                                <td style="text-align:left"><cfinput value="#product_name#" name="pname" style="width:100%; border:none" type="text"></td>
                                <td style="text-align:center">
                                    <input type="checkbox" name="select_production" value="#EZGI_PRINT_ID#_#amount#">
                                </td>
                           	</tr>
                        </cfoutput>
					<cfelse>
                        <tr>
                            <td colspan="4" height="20">
                                <cfif not isdefined("attributes.is_form_submitted")>
                                    <cf_get_lang dictionary_id='57701.Filtre Ediniz'>
                                <cfelse>
                                    <cf_get_lang dictionary_id='57484.Kayıt Yok'>
                                </cfif>
                                !
                            </td>
                        </tr>
                    </cfif>
              	</tbody>
                <tfoot>
                	<tr>
                        <td colspan="4" align="right">
                            <input type="button" value="<cfoutput><cf_get_lang dictionary_id='57474.Yazdır'></cfoutput>" onClick="grupla(-2);">
                			<input type="button" value="<cfoutput><cfoutput><cf_get_lang dictionary_id='57463.Sil'></cfoutput>" onClick="grupla(-3);">
                        </td> 
                    </tr>
                </tfoot>
          	</cf_form_list>
        </cf_box>
    </div>
</cfform>
<script language="javascript">
	function grupla(type)
		{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
			order_row_id_list = '';
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
						order_row_id_list +=my_objets.value+',';
				}
			}
			order_row_id_list = order_row_id_list.substr(0,order_row_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(order_row_id_list!='')
			{
				if(type == -2)
				window.location.href='<cfoutput>#request.self#</cfoutput>?fuseaction=pda.popup_ezgi_print_files&print_type=79&action_id='+order_row_id_list;
				if(type == -3)
				window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=pda.emptypopup_del_ezgi_pda_print_spool&action_id='+order_row_id_list);
			}
		}
</script>