<cfquery name="GET_PRICE_CAT" datasource="#DSN3#">
	SELECT PRICE_CAT,PRICE_CAT_ID FROM EZGI_VIRTUAL_OFFER_PRICE_LIST WHERE STATUS = 1
</cfquery>
<cfquery name="GET_COMPANY_CAT" datasource="#DSN#">
	SELECT COMPANYCAT_ID,COMPANYCAT FROM COMPANY_CAT ORDER BY COMPANYCAT
</cfquery>
<cfquery name="GET_CONSUMER_CAT" datasource="#DSN#">
	SELECT CONSCAT_ID as CONSUMERCAT_ID,CONSCAT as CONSUMERCAT FROM CONSUMER_CAT ORDER BY CONSUMERCAT
</cfquery>
<cfform name="form_add_pricecat" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_virtual_offer_price_cat">
	<div class="row">
    	<div class="col col-12 uniqueRow">
        	<div class="row formContent">
            	<div class="row" type="row">
                	<div class="col col-2 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="false">                    	
                        <label class="col col-12 bold font-blue"><cf_get_lang dictionary_id='37140.Yayın Alanı'></label>                        
                        <div class="row">
                            <ul>
                                <li >
                                    <label class="bold"><cf_get_lang dictionary_id='29408.Kurumsal Üyeler'></label>
                                    <div >
                                        <div>
                                            <cfoutput query="get_company_cat">
                                                <input type="checkbox" name="company_cat" id="company_cat" value="#companycat_id#">#companycat#<br/>
                                            </cfoutput>
                                        </div>
                                        <label class="bold"><input type="checkbox" name="all_company_cat" id="all_company_cat" value="1" onclick="wrk_select_all('all_company_cat','company_cat')"><cf_get_lang dictionary_id='37814.Hepsini Seç'></label>
                                    </div>
                                </li>
                            </ul> 
                            <ul>
                                <li >
                                    <label class="bold"><cf_get_lang dictionary_id='29406.Bireysel Üyeler'></label>
                                    <div >
                                        <div>
                                            <cfoutput query="get_consumer_cat">
                                                <input type="checkbox" name="consumer_cat" id="consumer_cat" value="#consumercat_id#">#consumercat#<br/>
                                            </cfoutput>
                                        </div>
                                        <label class="bold"><input type="checkbox" name="all_consumer_cat" id="all_consumer_cat" value="1" onclick="wrk_select_all('all_consumer_cat','consumer_cat')"><cf_get_lang dictionary_id='37814.Hepsini Seç'></label>
                                    </div>
                                </li>
                            </ul>                       
                        </div>                                           
                    </div>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                    	<div class="row">
                            <div class="col col-12">
                                <div class="form-group" id="item-price_cat">
                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='37144.Liste Adı'></label>
                                    <div class="col col-8 col-xs-12">
                                        <cfinput name="price_cat" type="text" value="" maxlength="100">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col col-12">
                                <div class="form-group" id="item-start_date">
                                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></label>
                                    <div class="col col-8 col-xs-12">
                                    	<div class="input-group">
                                            <cfinput type="text" name="startdate" value="#dateformat(now(),dateformat_style)#" validate="#validate_style#" style="width:65px;">
											<span class="input-group-addon btnPointer">
                                            	<cf_wrk_date_image date_field="startdate">
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row formContentFooter">
                	<cf_workcube_buttons is_upd='0' add_function='kontrol()'>
                </div>
            </div>
        </div>
    </div>
</cfform>
<script type="text/javascript">		
	function kontrol()
	{
		if(!$("#price_cat").val().length)
		{
			alert("<cfoutput><cf_get_lang dictionary_id='37405.Liste Adı girmelisiniz'> !</cfoutput>")    
			return false;
		}
		if(!$("#startdate").val().length)
		{
			alert("<cfoutput><cf_get_lang dictionary_id='57738.Başlangıç Tarihi girmelisiniz'> !</cfoutput>")    
			return false;
		}
		return true;
	}
</script>
