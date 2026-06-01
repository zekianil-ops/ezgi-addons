<cfquery name="get_connect" datasource="#dsn3#">
	SELECT CONNECT_HEAD, CONNECT_TEL FROM EZGI_CONNECT WHERE CONNECT_ID = #attributes.iid#
</cfquery>
<cfif isdefined('attributes.company_id')>
    <cfquery name="GET_PHONE" datasource="#dsn#">
        SELECT CONCAT(COMPANY_TELCODE,COMPANY_TEL1) AS TEL_NUMBER,FULLNAME FROM COMPANY WHERE COMPANY_ID = #attributes.company_id#
    </cfquery>
<cfelseif isdefined('attributes.consumer_id')>
    <cfquery name="GET_PHONE" datasource="#dsn#">
        SELECT CONCAT(MOBIL_CODE,MOBILTEL) AS TEL_NUMBER,CONSUMER_NAME+' '+CONSUMER_SURNAME AS FULLNAME FROM CONSUMER WHERE CONSUMER_ID = #attributes.consumer_id#
    </cfquery>
</cfif>
<cf_box title="#getLang('','Whatsappda paylaş',65493)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
    <cfoutput>
        <form name="whatsapp-form" id="whatsapp-form" method="post" action="">
            <cf_box_elements>
                <div class="col col-12 col-xs-12">
                    <div class="form-group">
                        <label class="col col-3 col-xs-12">Telefon Numarası:</label>
                        <div class="col col-9 col-xs-12">
                            <input type="text" id="phone_number" name="phone" value="+90<cfif len(get_connect.CONNECT_TEL)>#Replace(Replace(get_connect.CONNECT_TEL,'-','','ALL'),' ','','ALL')#<cfelseif len(GET_PHONE.TEL_NUMBER)>#GET_PHONE.TEL_NUMBER#</cfif>" required maxlength="15">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col col-3 col-xs-12"></label>
                        <div class="col col-9 col-xs-12">
<textarea id="message" name="text" required style="height:100px;">Merhaba <cfif len(get_connect.CONNECT_HEAD)>#get_connect.CONNECT_HEAD#<cfelse>#GET_PHONE.FULLNAME#</cfif>,
Size özel hazırlanan teklifimize aşağıdaki linkten ulaşabilirsiniz.
Değerli dönüşlerinizi bekliyoruz.
#furnite_portal_url#/offer/#contentEncryptingandDecodingAES(isEncode:1,content:attributes.iid,accountKey:'wrk')#
</textarea>
                        </div>
                    </div>
                </div>
            </cf_box_elements>
            <cf_box_footer>
                <button type="submit" class="ui-wrk-btn ui-wrk-btn-success"><cf_get_lang dictionary_id='64585.Gönder'></button>
            </cf_box_footer>
        </form>
    </cfoutput>
</cf_box>
<script>
    const form = document.getElementById('whatsapp-form');
  
  form.addEventListener('submit', function(event) {
    event.preventDefault(); // sayfanın yenilenmesini engellemek için
    
    const phoneNumber = document.getElementById('phone_number').value;
    const message = document.getElementById('message').value;
    
    // URL'yi oluşturma
    const baseURL = 'https://api.whatsapp.com/send';
    const text = encodeURIComponent(message);
    const phone = encodeURIComponent(phoneNumber);
    const finalURL = `${baseURL}?phone=${phone}&text=${text}`;
    
    // URL'yi yeni sekmede açma
    window.open(finalURL);
  });
</script>