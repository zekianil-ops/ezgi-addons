<cfparam name="attributes.modal_id" default="">
<cf_box title="#getLang('','Veri Aktarım',60009)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
 	<cfform name="form_basket_ship" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_virtual_offer_price_row_download" method="post" enctype="multipart/form-data">
    	<cfinput type="hidden" name="price_cat_id" value="#attributes.price_cat_id#">
            <cf_box_elements>
                <div class="col col-6 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                	<div class="col col-12">
                        <div class="form-group" id="form_ul_uploaded_file">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57468.Belge'> *</label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="file" name="uploaded_file" required="yes" message="#getLang('','Belge Seçiniz',47469)#">
                            </div>
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="form-group" id="form_ul_upload_type">
                            <label class="col col-4 col-xs-12">Yükleme İşlevi *</label>
                            <div class="col col-8 col-xs-12">
                                <select name="upload_type" id="upload_type">
                                	<option value="1">Dosyayı Güncelle</option>
                                    <option value="2">Dosyayı Yeniden Oluştur</option>
                                    <option value="3">Dosyayı Güncelle ve Olmayan satırları Ekle</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col col-6 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                 	<b><cf_get_lang dictionary_id='58594.Format'></b><br/>
                    Dosyanın Uzantısı .xlsx olmalıdır. Dosyada 14 alan Bulunmalı Sırası ile;<br />
                    <b>1-Sıra No : </b> Zorunlu,<br />
                    <b>2-STOCK_ID : </b> Fiyat Tipi 2 ise Zorunlu,<br />
                    <b>3-PIECE_ROW_ID : </b> Fiyat Tipi 3 ise Zorunlu,<br />
                    <b>4-Ürün Kodu : </b> Zorunlu Benzersiz Olmalıdır,<br />
                    <b>5-Ürün Adı : </b> Zorunlu Benzersiz Olmalıdır,<br />
                    <b>6-Satış Fiyatı : </b> Zorunlu Numeric Küsuratlar (.) ile olmalıdır,<br />
                    <b>7-Satış Fiyatı Döviz : </b> Zorunlu Sistemde Belirtilen Döviz olmalıdır,<br />
                    <b>8-Bayi Alış Fiyatı : </b> Zorunlu Numeric Küsuratlar (.) ile olmalıdır,<br />
                    <b>9-Bayi Alış Fiyatı Döviz : </b> Zorunlu Sistemde Belirtilen Döviz olmalıdır,<br />
                    <b>10-Maliyet Fiyatı : </b> Zorunlu Numeric Küsuratlar (.) ile olmalıdır,<br />
                    <b>11-Maliyet Fiyatı Döviz : </b> Zorunlu Sistemde Belirtilen Döviz olmalıdır,<br />
                    <b>12-Montaj Tipi : </b> Zorunlu (0,1,2,3),<br />
                    <b>13-Fiyat Tipi : </b> Zorunlu (0,1,2),<br />
                    <b>14-IS_RATE : </b> Zorunlu (0,1),
                </div>
            </cf_box_elements>
            <cf_box_footer>
                <cf_workcube_buttons add_function="ekle_form_control()">
            </cf_box_footer>    
 	</cfform>
</cf_box>
<script type="text/javascript">
	function ekle_form_control()
	{
		if(document.getElementById('upload_type').value == 2)
		{
			sor = confirm('Devam Ederseniz Mevcut Liste Tümüyle Silinip Gönderdiğiniz Dosya Bilgileri Yerine Konulacaktır. Devam Etmek İster misiniz?')
			if(sor==true)
				return true;
			else
				return false;
		}
		else
			return true;
	}
</script>
    