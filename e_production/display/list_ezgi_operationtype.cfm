<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.is_active" default="">
<cfif isdefined("attributes.form_submitted")>
	<cfinclude template="../query/get_ezgi_operation_type.cfm">
<cfelse>
	<cfset get_operation_type.recordcount=0>
</cfif>
<cfif not len(attributes.is_active)><cfset attributes.is_active = 1></cfif>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default=#get_operation_type.recordcount#>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="form" action="#request.self#?fuseaction=prod.list_ezgi_operationtype" method="post">
            <input type="hidden" name="form_submitted" id="form_submitted" value="1">
            <cf_box_search>
                <div class="form-group">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                    <cfinput type="text" name="keyword" id="keyword" placeholder="#message#" value="#attributes.keyword#" maxlength="50">
                </div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" onKeyUp="isNumber(this)" validate="integer" range="1,999" message="#message#" maxlength="3" style="width:25px;">
                </div>
                <div class="form-group">
                    <select name="is_active" id="is_active" style="width:50px;">
                        <option value="2"><cf_get_lang dictionary_id='57708.Tümü'></option>
                        <option value="1" <cfif attributes.is_active eq 1>selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                        <option value="0" <cfif attributes.is_active eq 0>selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                    </select>
                </div>
                <div class="form-group">
                    <cf_wrk_search_button button_type="4">
                </div>
            </cf_box_search>
        </cfform>
    </cf_box>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id='36376.Operasyonlar'></cfsavecontent>
    <cf_box title="#message#" uidrop="1" hide_table_column="1">
        <cf_flat_list> 
            <thead>
                <tr>
                    <th width="20"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th><cf_get_lang dictionary_id='36377.Operasyon Kodu'></th>
                    <th><cf_get_lang dictionary_id='57800.İşlem Tipi'></th>
                    <th><cf_get_lang dictionary_id='36874.İşlem Süresi'>(<cf_get_lang dictionary_id="420.Sn">.)</th>
                    <th><cf_get_lang dictionary_id='552.Hazırlık Süresi'>(<cf_get_lang dictionary_id="420.Sn">.)</th>
                    <th><cf_get_lang dictionary_id='553.Zaman Formülü'></th>
                    <th><cf_get_lang dictionary_id ='57899.Kaydeden'></th>
                    <th><cf_get_lang dictionary_id='57483.Kayıt'></th>
                    <!-- sil --><th width="20" class="header_icn_none"> <a href="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_operationtype&event=add</cfoutput>"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='36331.İşlem Tipi Ekle'>"></i></a></th><!-- sil -->
                </tr>
            </thead>
            <tbody>
                <cfif get_OPERATION_TYPE.recordcount>
                <cfoutput query="get_OPERATION_TYPE" STARTROW="#attributes.startrow#" MAXROWS="#attributes.maxrows#">
                    <tr>
                        <td>#CURRENTROW#</td>
                        <td>#OPERATION_CODE#</td>
                        <td><a href="#request.self#?fuseaction=prod.list_ezgi_operationtype&event=upd&operation_type_id=#get_OPERATION_TYPE.operatIon_type_Id#" class="TABLEYAZI">#OPERATION_TYPE#</a></td>
                        <td>#O_MINUTE#</td>
                        <td>#EZGI_H_SURE#</td>
                        <td>#EZGI_FORMUL#</td>
                        <td>#EMPLOYEE_NAME# #EMPLOYEE_SURNAME#</td>
                        <td>#dateformat(RECORD_DATE,dateformat_style)#</td>
                        <!-- sil --><td width="20"><a href="#request.self#?fuseaction=prod.list_ezgi_operationtype&event=upd&operation_type_id=#get_OPERATION_TYPE.operatIon_type_Id#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='36532.İşlem Tipi Güncelle'>"></i></a></td><!-- sil -->
                    </tr>
                </cfoutput>
                <cfelse>
                    <tr>
                        <td colspan="8"><cfif isdefined("attributes.form_submitted")><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'><cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'></cfif>!</td>
                    </tr>
                </cfif>
            </tbody>
        </cf_flat_list> 
        <cfset url_str = "">
            <cfset url_str = "#url_str#&keyword=#attributes.keyword#">
            <cfif isdefined("attributes.form_submitted")>
                <cfset url_str = "#url_str#&form_submitted=#attributes.form_submitted#">
            </cfif>
            <cfif isdefined ("attributes.is_active") and len(attributes.is_active)>
                <cfset url_str = "#url_str#&is_active=#attributes.is_active#">
            </cfif>
            <cf_paging page="#attributes.page#"
                maxrows="#attributes.maxrows#"
                totalrecords="#get_operation_type.recordcount#"
                startrow="#attributes.startrow#"
                adres="prod.list_ezgi_operationtype#url_str#">
    </cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
</script>
