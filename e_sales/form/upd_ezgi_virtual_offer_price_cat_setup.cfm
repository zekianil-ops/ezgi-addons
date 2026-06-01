<cfquery name="GET_PRICE_CATS" datasource="#DSN3#">
	SELECT PRICE_CAT,PRICE_CAT_ID FROM EZGI_VIRTUAL_OFFER_PRICE_LIST WHERE STATUS = 1 AND PRICE_CAT_ID <> <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.price_cat_id#">
</cfquery>
<cfquery name="GET_COMPANY_CAT" datasource="#DSN#">
	SELECT COMPANYCAT_ID,COMPANYCAT FROM COMPANY_CAT ORDER BY COMPANYCAT
</cfquery>
<cfquery name="GET_CONSUMER_CAT" datasource="#DSN#">
	SELECT CONSCAT_ID,CONSCAT FROM CONSUMER_CAT ORDER BY CONSCAT
</cfquery>
<cfquery name="GET_PRICE_CAT" datasource="#DSN3#">
	SELECT 
    	PRICE_CAT_ID, 
        PRICE_CAT, 
        STATUS, 
        VALIDATE, 
        COMPANY_CATS, 
        CONSUMER_CATS, 
        PRICE_CAT_CODE
	FROM     
    	EZGI_VIRTUAL_OFFER_PRICE_LIST
	WHERE  
    	PRICE_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.price_cat_id#"> 
    ORDER BY 
    	PRICE_CAT
</cfquery>
<cfparam name="modal_id" default="">
<cf_box id="box_updprice" title="Sanal Teklif Fiyat Listesi Setup" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
    <cfform name="form_upd_pricecat" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_virtual_offer_price_cat_setup">
        <input type="hidden" name="price_cat_id" id="price_cat_id" value="<cfoutput>#attributes.price_cat_id#</cfoutput>" />
        <cf_box_elements>
            <div class="col col-4 col-md-4 col-sm-4 col-xs-12" type="column" index="1" sort="false">                    	
                <label class="col col-12 bold"><cf_get_lang dictionary_id='37140.Yayın Alanı'></label>    
                <ul class="ui-list">
                    <li>
                        <a href="javascript:void(0)">
                            <div class="ui-list-left">
                                <span class="ui-list-icon ctl-collaboration"></span>
                                <cf_get_lang dictionary_id='29408.Kurumsal Üyeler'>
                            </div>
                            <div class="ui-list-right">
                                <i class="fa fa-chevron-down"></i>
                            </div>
                        </a>
                        <ul>
                          	<li>
                            	<a href="javascript:void(0)">
                                   	<div class="ui-list-left">
                                    	<span class="ui-list-icon ctl-maps-and-flags-3"></span>
                                     	<cf_get_lang dictionary_id='37814.Hepsini Seç'>
                                	</div>
                                	<div class="ui-list-right">
                                     	<input type="checkbox" name="all_company_cat" id="all_company_cat" value="1" onclick="wrk_select_all('all_company_cat','COMPANY_CAT')">
                                   	</div>
                           		</a>
                        	</li>
                          	<li>
                            	<cfoutput query="get_company_cat">
                                    <a href="javascript:void(0)">
                                        <div class="ui-list-left">
                                            <span class="ui-list-icon ctl-collaboration"></span>
                                            #companycat#
                                        </div>
                                        <div class="ui-list-right">
                                            <input type="checkbox" name="COMPANY_CAT" id="COMPANY_CAT" value="#companycat_id#" <cfif listfind(get_price_cat.company_cats,companycat_id)> checked</cfif>>
                                        </div>
                                    </a>
                            	</cfoutput>
                        	</li> 
                   		</ul>
            		</li>
                    <li>
                        <a href="javascript:void(0)">
                            <div class="ui-list-left">
                                <span class="ui-list-icon ctl-network-1"></span>
                                <cf_get_lang dictionary_id='29406.Bireysel Üyeler'>
                            </div>
                            <div class="ui-list-right">
                                <i class="fa fa-chevron-down"></i>
                            </div>
                        </a>
                        <ul>
                            <li>
                                <a href="javascript:void(0)">
                                    <div class="ui-list-left">
                                        <span class="ui-list-icon ctl-maps-and-flags-3"></span>
                                        <cf_get_lang dictionary_id='37814.Hepsini Seç'>
                                    </div>
                                    <div class="ui-list-right">
                                        <input type="checkbox" name="all_consumer_cat" id="all_consumer_cat" value="1" onclick="wrk_select_all('all_consumer_cat','consumer_cat')">                                    </div>
                                </a>
                                </li>
                                <li>
                                <cfoutput query="get_consumer_cat">
                                    <a href="javascript:void(0)">
                                        <div class="ui-list-left">
                                            <span class="ui-list-icon ctl-network-1"></span>
                                            #conscat#
                                        </div>
                                        <div class="ui-list-right">
                                            <input type="checkbox" name="consumer_cat" id="consumer_cat" value="#conscat_id#" <cfif listfind(get_price_cat.CONSUMER_CATS,conscat_id)> checked</cfif>>
                                        </div>
                                    </a>
                                </cfoutput>
                          	</li>
                        </ul>
                    </li>
                </ul>
            </div>       
         	<div class="col col-8 col-md-8 col-sm-8 col-xs-12" type="column" index="2" sort="true">
             	<div class="row">
                  	<div class="col col-12">
                      	<div class="form-group" id="item-price_cat">
                         	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='37144.Liste Adı'></label>
                         	<div class="col col-8 col-xs-12">
                            	<div class="input-group">
                                 	<cfsavecontent variable="message"><cf_get_lang dictionary_id='37405.Liste Girmelisiniz'></cfsavecontent>
                                 	<cfinput type="text" name="price_cat" value="#get_price_cat.price_cat#" required="yes" message="#message#" style="width:215px;" maxlength="100">
                                  	<span class="input-group-addon">
                                     	<cf_language_info 
                                                        table_name="EZGI_VIRTUAL_OFFER_PRICE_LIST" 
                                                        column_name="PRICE_CAT" 
                                                        column_id_value="#attributes.price_cat_id#" 
                                                        maxlength="50" 
                                                        datasource="#dsn3#" 
                                                        column_id="PRICE_CAT_ID" 
                                                        control_type="0">
                                 	</span>
                             	</div>
                         	</div>
                      	</div>
                     	<div class="form-group" id="item-price_cat_status">
                        	<label class="col col-4">
                            	<cf_get_lang dictionary_id='57493.Aktif'>
                          	</label>
                            <label class="col col-8">
                            	<input type="checkbox" name="price_cat_status" id="price_cat_status" value="1" <cfif get_price_cat.status eq 1>checked</cfif>>
                           	</label>
                 		</div>
               		</div>
          		</div>
       		</div>
      		<div class="col col-9 col-xs-12" type="column" index="3" sort="false">
				<cfif len(listsort(get_price_cat.company_cats,'Numeric'))>
                  	<cfquery name="GET_COMPANY_RECORD" datasource="#DSN#">
                      	SELECT COMPANYCAT FROM COMPANY_CAT WHERE COMPANYCAT_ID IN (#listsort(get_price_cat.company_cats,'Numeric')#)
                	</cfquery>
           		<cfelse>
                	<cfset get_company_record.recordcount = 0>
         		</cfif>
              	<cfif len(listsort(get_price_cat.consumer_cats,'Numeric'))>
                 	<cfquery name="GET_CONSUMER_RECORD" datasource="#DSN#">
                    	SELECT CONSCAT FROM CONSUMER_CAT WHERE CONSCAT_ID IN (#listsort(get_price_cat.consumer_cats,'Numeric')#)
                	</cfquery>
              	<cfelse>
                  	<cfset get_consumer_record.recordcount = 0>
             	</cfif> 
             	<br/><br/>
               	<table>
                 	<tr>
                     	<td class="formbold"><cf_get_lang dictionary_id='37193.Bu Fiyat Kategorisinin Kullanıcıları'></td>
                 	</tr>
                 	<tr>
                     	<td><b><cf_get_lang dictionary_id='58039.Kurumsal Üye Kategorileri'> :</b>
                         	<cfif get_company_record.recordcount><cfoutput query="get_company_record">#companycat#,&nbsp;</cfoutput></cfif>
                     	</td>
                 	</tr>
                 	<tr>
                     	<td><b><cf_get_lang dictionary_id='58040.Bireysel Üye Kategorileri'> :</b>
                        	<cfif get_consumer_record.recordcount><cfoutput query="get_consumer_record">#conscat#,&nbsp;</cfoutput></cfif>
                      	</td>
               		</tr>													
             	</table>
          	</div>
       	</cf_box_elements>
     	<cf_box_footer>
         	<cf_record_info query_name='get_price_cat'>
          	<cfif session.ep.admin>
            	<cf_workcube_buttons  add_function="kontrol_(0)" is_upd='1' delete_page_url='#request.self#?fuseaction=prod.emptypopup_del_ezgi_virtual_offer_price_cat_setup&price_cat_id=#attributes.price_cat_id#'>
         	<cfelse>
           		<cf_workcube_buttons add_function="kontrol_(0)" is_upd='1' is_delete='0'>
        	</cfif>
    	</cf_box_footer>
	</cfform>
</cf_box>
<script type="text/javascript">		
	function kontrol_(type_)
	{
		return true;
	}
    $('.ui-list li a i.fa-chevron-down').click(function()
		{
                $(this).closest('.ui-list-right').toggleClass("ui-list-right-open");
                $(this).closest('li').find("> ul").fadeToggle();
      	}
	);
</script>
