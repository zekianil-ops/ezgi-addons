<!---
    File: add_ezgi_perioad_based_count_operations.cfm
    Folder: Add_Ons\ezgi\e-wm\form
    Author: Ezgi Yazılım
    Date: 01/02/2025
    Description:
--->
<cfquery name="get_count" datasource="#dsn3#">
	SELECT
    	ISNULL(IS_PALETTE_CONTENT_SAVE,0) IS_PALETTE_CONTENT_SAVE,
    	EZGI_WM_COUNT_ID,
  		PROCESS_DATE, 
     	PROCESS_NUMBER,
        RECORD_EMP,
    	RECORD_DATE,
        STATUS
	FROM     
     	EZGI_WM_COUNT WITH (NOLOCK)
  	WHERE
    	STATUS = 1
</cfquery>
<cfif get_count.recordcount>
	<script type="text/javascript">
		alert("Dönem Bazlı Sayım Fişi Aktif Olarak Vardır. Yeni Sayım Fişi Açmak İçin Aktif Sayım Fişini Kapatınız");
		window.location.reload()
	</script>
    <cfabort>
</cfif>
<cf_box title="#getLang('','Stok Sayımı',32905)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
    <cfform name="form_basket" enctype="multipart/form-data" method="post" action="#request.self#?fuseaction=stock.emptypopup_add_ezgi_period_based_count_operations">
       <cf_box_elements>
            <div class="col col-5 col-md-6 col-sm-12 col-xs-12">
                <div class="form-group" id="item-date">
                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57742.Tarih'> *</label>
                    <div class="col col-8 col-xs-12">
                        <div class="input-group">
                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lutfen Tarih Giriniz'> !</cfsavecontent>
                            <cfinput type="text" name="process_date" value="" validate="#validate_style#" required="yes" message="#message#" maxlength="10" style="width:65px;">
                            <span class="input-group-addon btnPointer"><cf_wrk_date_image date_field="process_date"></span>
                        </div>
                    </div>
                </div>
            </div>
        </cf_box_elements>
            
        <cf_box_footer>
            <div class="col col12 col-md-12 col-sm-12 col-xs-12">
                <cf_workcube_buttons type_format='1' is_upd='0' add_function="#iif(isdefined("attributes.draggable"),DE("loadPopupBox('form_basket' , #attributes.modal_id#)"),DE(""))#">
            </div>
        </cf_box_footer>
    </cfform>
</cf_box>