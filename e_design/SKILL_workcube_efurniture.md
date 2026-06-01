---
name: workcube-efurniture
description: Workcube ERP ve E-Furniture / e_design add-on'u için ColdFusion (CFM) yazım kalıplarını, klasör yapısını ve isimlendirme kurallarını uygular. Bu skill'i HER ZAMAN kullan; kullanıcı Workcube, E-Furniture, e_design, EZGI_ tablolar, .cfm dosyası, cf_box / cf_get_lang / cf_grid_list / cf_workcube_buttons gibi custom tag'lar, list_/add_/upd_/del_/get_/dsp_ önekli dosyalar, "yeni modül", "yeni listeleme sayfası", "form ekle", "INSERT/UPDATE sorgusu yaz", AddOns klasörü, ColdFusion, ya da CFML konularından birini bahsettiğinde — kullanıcı skill'in adını söylemese bile. ERP/Workcube bağlamında olduğunu sezdiğin her durumda bu skill'i çağır; kalıpları ezbere yazma, buradan oku.
---

# Workcube E-Furniture (e_design) Yazım Rehberi

Bu skill, Workcube ERP'nin Ezgi e_design add-on'unda görülen tekrarlayan kalıpları kodlar. Amaç: yeni bir dosya yazarken (listeleme sayfası, form, INSERT/UPDATE/SELECT sorgusu) ya da mevcut bir dosyayı düzeltirken Claude'un bu kalıpları "ezbere" yazmaması — buradan okuyup uygulaması.

Workcube ColdFusion (CFML) tabanlıdır. Sayfalar üç tip dizine ayrılır: `display/` (kullanıcı arayüzü), `form/` (giriş formları), `query/` (DB işlemleri). Her tip için isim öneki, dosya başlığı, datasource kullanımı, dil etiketi ve butonlar konusunda sabit bir kalıp vardır. Bu kalıplara uymak Workcube'da yeterli — yenilik yapmaya çalışma; varsa eldeki örneği kopyalayıp uyarla.

## 1. Klasör yapısı ve isim önekleri

Bir add-on klasörü tipik olarak şu üç dizinden oluşur:

```
AddOns\<vendor>\<module>\
├── display\   listeleme + görüntüleme + export
├── form\      ekleme + güncelleme formları
└── query\     DB işlemleri (insert/update/delete/select)
```

Dosya adları önekle başlar — önek **her zaman** dosyanın ne yaptığını söyler. Yeni bir dosya yazarken doğru öneki seç:

| Önek | Anlam | Tipik klasör |
|---|---|---|
| `list_` | Filtreli liste sayfası | display/ |
| `dsp_` | Detay / satır görüntüleme parçası | display/ |
| `frm_` | Çıktıya yönelik form (yazdırılabilir fiş vb.) | display/ |
| `exp_` | Excel/CSV export | display/ |
| `detailed_` | Detaylı arama sayfası | display/ |
| `add_` | Ekleme formu **veya** INSERT sorgusu | form/ veya query/ |
| `upd_` | Güncelleme formu **veya** UPDATE sorgusu | form/ veya query/ |
| `del_` | DELETE sorgusu | query/ |
| `get_` | SELECT (veri çekme) | query/ |
| `cnt_` | COUNT sorgusu | query/ |
| `hsp_` | Hesaplama sorgusu | query/ |
| `cpy_` | Kopyalama (kayıt çoğaltma) | form/ veya query/ |
| `ajax_` | AJAX endpoint | form/ |

Tablo adı kısmı **modül önekiyle** başlar: `add_ezgi_default_main.cfm`, `upd_ezgi_product_tree_creative.cfm`. Bu önek (`ezgi_`) hem dosya adında hem DB tablosunda (`EZGI_DESIGN_MAIN_ROW_SETUP`) aynı kelimedir — add-on'un namespace'i gibi düşün.

**Neden bu kadar katı?** Workcube'da fuseaction routing bu önekleri okuyarak iş yapar; ayrıca yetki ve menü sistemleri de prefix bazlı çalışır. Konvansiyondan sapmak işlevsel hata üretebilir, sadece estetik bir tercih değil.

## 2. Dosya başlık yorumu

Her CFM dosyası şu bloğla başlar — yeni dosya oluşturuyorsan **muhakkak ekle**:

```cfm
<!---
    File: <dosya_adı>.cfm
    Folder: AddOns\<vendor>\<modul>\<klasor>
    Author: <Yazılım/Geliştirici>
    Date: DD/MM/YYYY
    Description: <bir cümle açıklama, boş bırakılabilir>
--->
```

CFML yorumu `<!--- --->` (üç tire) ile yapılır; HTML yorumu `<!-- -->` ile. Her ikisi de görülür, ama CFML yorumları sunucuya gönderilmediği için tercih et.

## 3. Datasource ve standart değişkenler

Tüm sorgularda datasource belirtilir; **string interpolation içinde** yazılır:

```cfm
<cfquery name="get_x" datasource="#dsn3#">
```

Yaygın datasource değişkenleri:

- `#dsn#` — ana veritabanı (genel)
- `#dsn1#`, `#dsn3#` — modüle göre değişen ikinci/üçüncü veritabanı (e_design genelde `dsn3` kullanır)
- `#dsn1_alias#`, `#dsn3_alias#` — cross-database JOIN'ler için linked server alias'ı (`#dsn1_alias#.PRODUCT_CAT` gibi)

Standart server/session değişkenleri (kalıplara gömülü, her zaman aynı):

| Değişken | Ne için |
|---|---|
| `session.ep.userid` | Mevcut kullanıcı ID — RECORD_EMP / UPDATE_EMP'e yazılır |
| `session.ep.maxrows` | Listeleme default kayıt sayısı |
| `cgi.remote_addr` | Kullanıcının IP'si — RECORD_IP / UPDATE_IP'e yazılır |
| `request.self` | Mevcut sayfanın base URL'i; tüm linklerde başa konur |
| `dateformat_style` | Sistem geneli tarih formatı |
| `now()` | Şimdiki zaman, INSERT/UPDATE'lerde direkt kullanılır |

## 4. Listeleme sayfası kalıbı (`list_*.cfm`)

Bu sayfa filtreli bir grid üretir. İskelet:

```cfm
<!--- başlık yorumu --->

<cfparam name="attributes.status"  default="2">
<cfparam name="attributes.oby"     default="0">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.page"    default=1>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
    <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow = ((attributes.page-1) * attributes.maxrows) + 1>

<cfscript>
    get_main.recordcount = 0;
    get_main.query_count = 0;
    if (isdefined("attributes.is_submitted")) {
        get_main_list_action = createObject("component", "addOns.<vendor>.cfc.get_main");
        get_main_list_action.dsn3 = dsn3;
        get_main = get_main_list_action.get_main_(
            status   : '#iif(isdefined("attributes.status"),"attributes.status",DE(""))#',
            oby      : '#iif(isdefined("attributes.oby"),"attributes.oby",DE(""))#',
            keyword  : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
            startrow : '#iif(isdefined("attributes.startrow"),"attributes.startrow",DE(""))#',
            maxrows  : '#iif(isdefined("attributes.maxrows"),"attributes.maxrows",DE(""))#'
        );
        arama_yapilmali = 0;
    } else {
        arama_yapilmali = 1;
    }
</cfscript>

<cfparam name="attributes.totalrecords" default='#get_main.query_count#'>
```

**Neden `is_submitted` kontrolü var?** Sayfa ilk açıldığında sorgu çalışmasın — kullanıcı filtre seçip Ara'ya basmadan ekran "Filtre Ediniz!" mesajı gösterir. Bu Workcube'un performans kalıbıdır; büyük tablolarda kullanıcı filtresiz veri çekmesin.

**Görsel iskelet** (her listeleme sayfası bu kalıpta):

```cfm
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
        <cfform name="search_list" action="#request.self#?fuseaction=<modul>.list_<dosya>" method="post">
            <input type="hidden" name="is_submitted" id="is_submitted" value="1">
            <cf_box_search>
                <!--- keyword, oby, status, maxrows filtreleri --->
                <div class="form-group">
                    <cfinput type="text" placeholder="..." name="keyword" value="#attributes.keyword#">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
            </cf_box_search>
        </cfform>
    </cf_box>

    <cfsavecontent variable="title">
        <cfoutput><cf_get_lang dictionary_id="847.Default Modül Listesi"></cfoutput>
    </cfsavecontent>

    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
        <cf_grid_list>
            <thead>
                <tr>
                    <th width="20"><cf_get_lang dictionary_id="58577.Sıra"></th>
                    <!--- diğer kolonlar --->
                    <th width="20" class="header_icn_none">
                        <a href="<cfoutput>#request.self#?fuseaction=...&event=add</cfoutput>">
                            <i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i>
                        </a>
                    </th>
                </tr>
            </thead>
            <tbody>
                <cfif get_main.recordcount>
                    <cfoutput query="get_main">
                        <tr oncontextmenu="javascript:wrk_right_menu('MAIN_ROW_SETUP_ID',#MAIN_ROW_SETUP_ID#);return false;">
                            <td>#rownum#</td>
                            <!--- veri kolonları --->
                            <td>#get_emp_info(RECORD_EMP,0,0)#</td>
                            <td>#DateFormat(RECORD_DATE, dateformat_style)#</td>
                        </tr>
                    </cfoutput>
                <cfelse>
                    <tr><td colspan="7">
                        <cfif arama_yapilmali eq 1>
                            <cf_get_lang dictionary_id='57701.Filtre Ediniz'> !
                        <cfelse>
                            <cf_get_lang dictionary_id='57484.Kayıt Yok'>!
                        </cfif>
                    </td></tr>
                </cfif>
            </tbody>
        </cf_grid_list>

        <cf_paging
            page="#attributes.page#"
            maxrows="#attributes.maxrows#"
            totalrecords="#attributes.totalrecords#"
            startrow="#attributes.startrow#"
            adres="#adres#&is_submitted=1">
    </cf_box>
</div>

<script type="text/javascript">
    document.getElementById('keyword').focus();
    function input_control() { return true; }
</script>
```

**Önemli detaylar:**
- `<cf_box>`, `<cf_box_search>`, `<cf_grid_list>`, `<cf_paging>` Workcube'un custom tag'leridir — `<div>` ile değiştirme.
- Bootstrap-12 grid sınıfları (`col col-12 col-md-12 col-sm-12 col-xs-12`) tüm sayfalarda aynı sırada yazılır.
- Tarih kolonları her zaman `DateFormat(X, dateformat_style)` ile basılır.
- Kullanıcı isimleri her zaman `get_emp_info(EMP_ID, 0, 0)` helper'ı ile çözülür.
- `<!-- sil --> ... <!-- sil -->` yorumları yetki sistemi tarafından okunur — buralar yetkisiz kullanıcılarda otomatik silinir. Düzenleme/silme/ekleme butonlarını **muhakkak** bu yorum bloğunun içine al.
- Sağ tık menüsü için `oncontextmenu="javascript:wrk_right_menu('FIELD_NAME', #ID#); return false;"`.

## 5. Form sayfası kalıbı (`form/add_*.cfm`, `form/upd_*.cfm`)

```cfm
<!--- başlık yorumu --->

<!--- (sadece add formunda) sıra no üretimi --->
<cfquery name="get_max" datasource="#dsn3#">
    SELECT MAX(MAIN_ROW_SETUP_ID) AS MAX_ID FROM EZGI_DESIGN_MAIN_ROW_SETUP WITH (NOLOCK)
</cfquery>
<cfif not len(get_max.max_id)>
    <cfset sira = '001'>
<cfelseif len(get_max.max_id) eq 1>
    <cfset sira = '00#get_max.max_id+1#'>
<cfelseif len(get_max.max_id) eq 2>
    <cfset sira = '0#get_max.max_id+1#'>
<cfelse>
    <cfset sira = '#get_max.max_id+1#'>
</cfif>

<cf_catalystHeader>
<div class="col col-12 col-xs-12">
    <cf_box>
        <cfform name="add_default_main" method="post"
                action="#request.self#?fuseaction=<modul>.emptypopup_add_<dosya>">
            <cf_box_elements>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">

                    <div class="form-group" id="item-status">
                        <label class="col col-4 col-xs-12">
                            <cf_get_lang dictionary_id='57493.Aktif'>
                        </label>
                        <div class="col col-8 col-xs-12">
                            <cfinput type="checkbox" id="status" name="status" value="1" checked="yes">
                        </div>
                    </div>

                    <div class="form-group" id="item-name">
                        <label class="col col-4 col-xs-12">
                            <cf_get_lang dictionary_id="110.Modül Adı"> *
                        </label>
                        <div class="col col-8 col-xs-12">
                            <cfinput type="text" name="default_type" id="default_type"
                                     value="" maxlength="50" style="width:150px;">
                        </div>
                    </div>

                </div>
            </cf_box_elements>

            <cf_box_footer>
                <div class="col col-12">
                    <cf_workcube_buttons type_format="1" is_upd='0' add_function='kontrol()'>
                </div>
            </cf_box_footer>
        </cfform>
    </cf_box>
</div>

<script type="text/javascript">
    document.getElementById('default_type').focus();
    function kontrol() {
        if (document.getElementById("default_type").value == "") {
            alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='110.Modül Adı'> !");
            document.getElementById('default_type').focus();
            return false;
        }
    }
</script>
```

**Update formunda** `is_upd='1'` ve `action=` UPDATE query'sini hedef alır. `get_max` bloğu kaldırılır, mevcut kayıt `<cfquery>` ile çekilip alanlara basılır.

`<cf_workcube_buttons>` standart kaydet/iptal butonlarını basar — kendin button yazma. `add_function` parametresi `onsubmit` davranışını hooklar.

Zorunlu alan göstergesi: etiket sonuna ` *`. Validation `kontrol()` JS fonksiyonunda yapılır, sunucu tarafı validasyon ise INSERT/UPDATE query'sinin başında.

## 6. INSERT query kalıbı (`query/add_*.cfm`)

```cfm
<!--- başlık yorumu --->

<!--- 1. Duplicate kontrolü --->
<cfquery name="get_name_control" datasource="#dsn3#">
    SELECT * FROM EZGI_DESIGN_MAIN_ROW_SETUP WITH (NOLOCK)
    WHERE MAIN_ROW_SETUP_NAME = '#attributes.default_type#'
</cfquery>
<cfif get_name_control.recordcount>
    <script type="text/javascript">
        alert("<cf_get_lang dictionary_id='256.Aynı İsimde Modül Mevcut. Lütfen Düzeltiniz'>!");
        window.history.go(-1);
    </script>
    <cfabort>
</cfif>

<!--- 2. Transaction içinde INSERT --->
<cftransaction>
    <cfquery name="ins_main" datasource="#dsn3#">
        INSERT INTO EZGI_DESIGN_MAIN_ROW_SETUP
        (
            MAIN_ROW_SETUP_NAME,
            MAIN_ROW_SETUP_CODE,
            STATUS,
            RECORD_EMP,
            RECORD_IP,
            RECORD_DATE
        )
        VALUES
        (
            '#attributes.default_type#',
            '#attributes.default_code#',
            <cfif isdefined('attributes.status')>1<cfelse>0</cfif>,
            #session.ep.userid#,
            '#cgi.remote_addr#',
            #now()#
        )
    </cfquery>
    <cfquery name="getmax" datasource="#dsn3#">
        SELECT MAX(MAIN_ROW_SETUP_ID) MAXID FROM EZGI_DESIGN_MAIN_ROW_SETUP WITH (NOLOCK)
    </cfquery>
</cftransaction>

<!--- 3. Düzenleme sayfasına yönlendir --->
<cflocation url="#request.self#?fuseaction=<modul>.list_<dosya>&event=upd&main_id=#getmax.maxid#"
            addtoken="No">
```

**Sabitler:**
- Her INSERT'te `RECORD_EMP / RECORD_IP / RECORD_DATE` üçlüsü yazılır.
- `STATUS` checkbox kalıbı: `<cfif isdefined('attributes.status')>1<cfelse>0</cfif>`. Checkbox işaretliyse field submit edilir, değilse hiç gelmez — bu yüzden `isdefined` kontrolü yapılır, value değil.
- `<cftransaction>` çoklu sorgu varsa şart; tek sorguda da konvansiyon gereği yazılır.
- `<cflocation addtoken="No">` ile yeni kaydın upd sayfasına atlanır — kullanıcı kayıt sonrası direkt düzenleme ekranını görür.

## 7. UPDATE query kalıbı (`query/upd_*.cfm`)

```cfm
<!--- 1. Duplicate kontrolü (mevcut kayıt hariç) --->
<cfquery name="get_name_control" datasource="#dsn3#">
    SELECT * FROM EZGI_DESIGN_MAIN_ROW_SETUP
    WHERE MAIN_ROW_SETUP_NAME = '#attributes.default_type#'
      AND MAIN_ROW_SETUP_ID <> #attributes.main_id#
</cfquery>
<cfif get_name_control.recordcount>
    <script type="text/javascript">
        alert("<cf_get_lang dictionary_id='979.Aynı İsimde Default Modül Mevcut Lütfen Düzeltiniz!'>");
        window.history.go(-1);
    </script>
    <cfabort>
</cfif>

<cftransaction>
    <cfquery name="upd_main" datasource="#dsn3#">
        UPDATE EZGI_DESIGN_MAIN_ROW_SETUP
        SET
            MAIN_ROW_SETUP_CODE = '#attributes.default_code#',
            MAIN_ROW_SETUP_NAME = '#attributes.default_type#',
            STATUS              = <cfif isdefined('attributes.status')>1<cfelse>0</cfif>,
            UPDATE_EMP          = #session.ep.userid#,
            UPDATE_DATE         = #now()#,
            UPDATE_IP           = '#cgi.remote_addr#'
        WHERE
            MAIN_ROW_SETUP_ID = #attributes.main_id#
    </cfquery>
</cftransaction>

<cflocation url="#request.self#?fuseaction=<modul>.list_<dosya>&event=upd&main_id=#attributes.main_id#"
            addtoken="No">
```

**Audit alanları:** INSERT'te `RECORD_*`, UPDATE'te `UPDATE_*`. İkisini de yazan tablolar var; düzenleme yapan kayıt güncelleme alanlarını dolduruyor demektir.

## 8. SELECT query kalıbı (`query/get_*.cfm`)

```cfm
<cfquery name="PRODUCTS" datasource="#DSN3#">
    SELECT
        EDMR.DESIGN_MAIN_ROW_ID,
        EDMR.DESIGN_MAIN_NAME,
        PC.HIERARCHY,
        ISNULL((SELECT SP.SPECT_MAIN_ID FROM SPECT_MAIN SP
                WHERE SP.STOCK_ID = EDMR.DESIGN_MAIN_RELATED_ID), 0) AS SPECT_MAIN_ID
    FROM
        EZGI_DESIGN_MAIN_ROW AS EDMR WITH (NOLOCK)
        INNER JOIN EZGI_DESIGN AS ED WITH (NOLOCK)
            ON EDMR.DESIGN_ID = ED.DESIGN_ID
        INNER JOIN #dsn1_alias#.PRODUCT_CAT AS PC WITH (NOLOCK)
            ON ED.PRODUCT_CATID = PC.PRODUCT_CATID
    WHERE
        1=1
        AND ED.STATUS = 1
        <cfif isDefined("attributes.product_catid") and len(attributes.product_catid)>
            AND PC.PRODUCT_CATID = #attributes.product_catid#
        </cfif>
        <cfif isDefined("attributes.keyword") and len(attributes.keyword)>
            AND (
                <cfif len(attributes.keyword) eq 1>
                    PRODUCT_NAME LIKE '#attributes.keyword#%'
                <cfelseif listlen(attributes.keyword,"+") gt 1>
                    (
                        <cfloop from="1" to="#listlen(attributes.keyword,'+')#" index="pro_index">
                            PRODUCT_NAME LIKE '%#ListGetAt(attributes.keyword,pro_index,"+")#%'
                            <cfif pro_index neq listlen(attributes.keyword,'+')>AND</cfif>
                        </cfloop>
                    )
                <cfelse>
                    PRODUCT_NAME LIKE '%#attributes.keyword#%'
                    OR STOCK_CODE LIKE '%#attributes.keyword#%'
                </cfif>
            )
        </cfif>
    ORDER BY
        PRODUCT_NAME
</cfquery>
```

**Sabit kurallar:**
- Her tablo `WITH (NOLOCK)` ile okunur (Workcube'da neredeyse istisnasız). Bu, raporlama yükünün OLTP'yi kilitlememesi için.
- `WHERE 1=1` deyimi her zaman ilk satır — sonraki tüm koşullar `AND` ile dinamik eklenir, böylece `<cfif>` blokları rahatça karışır.
- Cross-database JOIN'lerde `#dsn1_alias#.TABLE` ile linked server alias kullanılır.
- Tablo alias'ları büyük harf ve kısa: `EDMR`, `ED`, `PC`, `S`, `PU`, `SP`. Konvansiyon — uzun tablo adlarını her sorguda tekrar etme.
- Anahtar kelime araması üç moda ayrılır: tek karakter (prefix LIKE), `+` ile çoklu kelime (AND'li loop), ve tek kelime (`%kelime%` OR alternatif kolon).
- Çoklu UNION yerine `<cfif>...<cfelseif>` ile koşullu subquery kullanılır, sonra dış SELECT `... FROM (...) AS TBL WHERE`.

`ISNULL((subquery), 0)` kalıbı çok yaygın — null skalar dönen subquery'leri varsayılana çevirmek için.

## 9. Dil sistemi (lokalizasyon)

Tüm kullanıcıya görünen metinler `<cf_get_lang>` ile yazılır — asla düz string olarak değil:

```cfm
<cf_get_lang dictionary_id='57493.Aktif'>
```

Format: `<ID>.<varsayılan_Türkçe_metin>`. ID dictionary tablosundan gelir. Yeni bir metin gerekiyorsa:
1. Önce var olan bir dictionary_id var mı bak (genelde "Aktif", "Pasif", "Güncelle", "Ekle", "Sıra", "Kod", "Adı", "Sıralama", "Tümü", "Kayıt Yok", "Filtre Ediniz" gibi yaygın metinler için kesin vardır).
2. JS alert içinde de aynı tag kullanılır: `alert("<cf_get_lang dictionary_id='256.Mevcut'>!");`
3. Birden fazla yerde tekrar kullanılacaksa `<cfsavecontent variable="x">` ile bir kez üret, sonra `#x#` ile bas.

Yeni `dictionary_id` üretirken **rastgele numara verme** — geliştiriciye sor ya da mevcut olanı yeniden kullan.

## 10. Sık kullanılan custom tag'lar (Workcube'a özgü)

Yeni custom tag uydurma; yalnızca aşağıdakileri kullan. Her birinin Workcube tarafında render mantığı var.

| Tag | Görev |
|---|---|
| `<cf_box>` | İçerik kutusu (kart) çerçevesi |
| `<cf_box_search>` | Filtre satırı kutusu |
| `<cf_box_elements>` | Form elemanlarını gruplar |
| `<cf_box_footer>` | Form altı (submit butonları için) |
| `<cf_grid_list>` | Tablolu listeleme grid'i |
| `<cf_paging>` | Sayfa numarası bileşeni |
| `<cf_catalystHeader>` | Form sayfası header'ı |
| `<cf_workcube_buttons>` | Standart Kaydet/İptal butonu |
| `<cf_wrk_search_button>` | Arama butonu |
| `<cf_get_lang>` | Dil etiketi (yukarıda) |

## 11. URL ve fuseaction yapısı

Workcube fusebox tabanlıdır. Her link:

```
#request.self#?fuseaction=<modul>.<dosya>&event=<add|upd|...>&<id_param>=#ID#
```

Örnek: `#request.self#?fuseaction=prod.list_ezgi_default_main&event=upd&main_id=#MAIN_ROW_SETUP_ID#`

`event=add` → form/add_ açılır, `event=upd` → form/upd_ açılır. Bu routing fuseaction xml'ine bağlı; yeni event ekliyorsan o xml'i de güncellemen gerekir (genelde `circuits/` altında).

## 12. cfscript içinde sık kalıplar

```cfscript
// Component çağrısı:
get_x_action = createObject("component", "addOns.ezgi.cfc.x");
get_x_action.dsn3 = dsn3;
result = get_x_action.method(param1: 'val', param2: 'val');

// Attribute defaulting (eski kalıp, hâlâ kullanılıyor):
'#iif(isdefined("attributes.x"), "attributes.x", DE(""))#'
```

`iif(condition, "true_expression", DE("false_value"))` — `DE()` "Don't Evaluate"; ikinci argümanın değişken olarak değerlendirilmesini engeller.

## 13. Genel yazım kuralları (özet)

Yeni bir dosya yazarken bu sıralamayı izle:

1. Üstte CFML başlık yorumu.
2. `<cfparam>` ile tüm attribute'ların default'unu ayarla — `isDefined` ile başka yerde tekrar kontrol etme.
3. Sorguları **her zaman** datasource ile yaz; tablo adlarını UPPER_SNAKE_CASE, alias'ları kısa büyük harf.
4. Tüm SELECT'lerde `WITH (NOLOCK)` ve `WHERE 1=1` kullan.
5. INSERT'te `RECORD_EMP / RECORD_IP / RECORD_DATE`, UPDATE'te `UPDATE_EMP / UPDATE_DATE / UPDATE_IP` ekle.
6. Kullanıcıya görünen her metni `<cf_get_lang dictionary_id="...">` ile yaz.
7. Yetki bağlı satırları `<!-- sil --> ... <!-- sil -->` yorum bloğuna al.
8. Submit sonrası `<cflocation ... addtoken="No">` ile listeye veya upd sayfasına dön.
9. Yeni custom tag uydurma; mevcut `<cf_*>` tag'leri kullan.
10. Yeni `dictionary_id` numarası uydurma; var olanı yeniden kullan veya geliştiriciye sor.

## 14. Mevcut bir dosyayı düzenlerken

- Önce **aynı klasörde** benzer önekli bir dosyaya bak (örn. `add_*.cfm` yazıyorsan, başka bir `add_*.cfm` aç). O dosyanın iskeletini birebir kopyala, sadece tablo/kolon adlarını değiştir. Workcube'da "yenilik" yapmaya çalışma — kalıba uy.
- Tablo şemasını bilmiyorsan `query/get_*.cfm` ya da `query/add_*.cfm` dosyalarındaki SELECT/INSERT'lerden kolonları çıkar.
- Türkçe yorumlar ve değişken adları normaldir; korumaya çalış — kod tabanı bilinçli olarak iki dilli.

## 15. JavaScript helper fonksiyonları (`Y:\JS\js_functions.js`)

**Yeni JS yazmadan önce burayı kontrol et.** Workcube'un tüm yardımcı JS fonksiyonları `Y:\JS\js_functions.js` içinde toplanmıştır (~150 fonksiyon). Aynı işi yapan bir fonksiyon büyük ihtimalle zaten var; sıfırdan yazmak yerine buradan kullan. Sayfada inline `kontrol()` benzeri sayfaya özgü validasyonlar yazılır, ama "tarih farkı bul, IBAN doğrula, AJAX form gönder, listeyi parse et" gibi genel işleri **muhakkak** helper ile yap.

İmza/davranış hatırlamıyorsan `Y:\JS\js_functions.js` dosyasını **`Grep` ile** `^function\s+<adı>` arayarak aç — tüm fonksiyonun yorumunu birlikte yazıp dokümante etmişler.

### Kategoriler

**AJAX (sunucu çağrıları):**

```
AjaxFormSubmit(formName, messageBoxId, showError, waitingMessage, successMessage, load_url, load_div, load_script)
AjaxPageLoad(url, target, error_detail, loader_message, li_id, loadFunction, xml)
AjaxLoader(url, element)
AjaxLoaderWithData(url, data, element, afterFunction)
AjaxControlPostData(url, data, callback)
AjaxControlPostDataJson(url, data, callback, beforeSend)
AjaxControlGetDataJson(url, data, callback)
AjaxRequest(ajaxConnector, url, method, data, callback)
GetAjaxConnector()
GetFormData(form)
callAjax(url, callback, data, target, async)
ajax_request_script(html)   // dönen HTML içindeki <script>'leri çalıştırır
```

`AjaxFormSubmit` standart form gönderim helper'ıdır — `form.action` URL'ine `&isAjax=1` ekleyip POST eder, sonuca göre `messageBoxId`'deki div'i günceller. Başarı/hata/bekleme mesajları `language.kaydedildi`, `language.workcube_hata`, `language.kaydediliyor` global dil nesnesinden gelir.

`AjaxPageLoad` ise tüm sayfayı veya bir div'i yenilemek için — örneğin filtre değiştiğinde grid'i yeniden çekmek.

**Show/Hide UI:**

```
hide(id)          / show(id)          / show_hide(id)             // ID ile, display='none' / ''
gizle(el)         / goster(el)        / gizle_goster(el)          // element referansı ile (Türkçe)
gizle_goster_img(id, id2, txt)        // ikili görüntüleme + ikon
gizle_goster_nested(id, id2)
gizle_goster_basket(id) / basketDisplay() / resize_basket(id)
gizle_goster_ikili(id1, id2)
gizle_goster_workdev(id)
show_hide_box(box_id, box_page, box_drag, this_fuseact)
show_hide_big_list(box_id, this_fuseact)
show_hide_medium_list(box_id, this_fuseact)
refresh_box(box_id, box_page, box_drag)
```

**Türkçe ve İngilizce varyantlar birlikte var** (`hide`/`gizle`, `show`/`goster`) — eski kod İngilizce, yeni kod Türkçe kullanma eğiliminde. Bir dosyaya başladığın stili koru.

**Form/Input validasyon:**

```
isNumber(nesne, type)         // type=1 → rakam + virgül, yoksa sadece rakam
                              //   <cfinput ... onKeyUp="isNumber(this)">
isCharacter(nesne, type, chr_del)  // type=1 → alfanumerik + boşluk, yoksa sadece harf
                              //   chr_del ile yasaklı listeden bir char çıkar
isIBAN(nesne, length)         // TR için 26 karakter, IBAN checksum doğrular
isTCNUMBER(nesne)             // 11 hane + TC kimlik algoritması
NumberControl(olay)           // keypress eventinde sadece rakam
ismaxlength(obj)              // maxlength enforcement
allFilterNum()                // tüm filtreli sayıları filtrele
form_warning(field_id, warning_message, length)
isDefined(variable)
findObj(theObj, theDoc)
search_char_control(fld)
chk_process_cat(form_name, is_main)
wrk_form_set_js(form_name, form_object, form_object_value, form_object_type)
wrk_select_all(main_checkbox, row_checkbox)
```

**Önemli:** `isNumber(this)` kalıbı `<cfinput>` üzerinde `onKeyUp` ve `onBlur` event'lerinde standarttır. Custom validation yazmadan önce hep buradan başla.

**Tarih/zaman:**

```
fix_date_value(field)               // yazılan değeri DD/MM/YYYY'e normalize et
fix_date(field, name)
time_check(tarih1, saat1, dk1, tarih2, saat2, dk2, msg, is_equal)
date_check(tarih1, tarih2, msg, is_equal)
date_check_hiddens(tarih1, tarih2, msg)
isDate(y, m, d)
daysInMonth(month, year)
date_add(dpart, number, d, first_date, kontrol_month)   // dpart: 'd','m','y','h','n','s'
datediff(date1, date2, a)                                // a: birim
date_diff(tarih1, tarih2, fark, msg)
js_date(tarih, saat)                                     // 'DD/MM/YYYY HH:NN' → Date
date_format(gelen_tarih)
wrk_date_image(gelen_alan, gelen_function, gelen_mode)   // takvim ikonu açar
```

**Tarih girişleri Workcube'da text input'tur**, datepicker `wrk_date_image` ile çalışır. Date validasyonu sunucuya gitmeden mutlaka `date_check` / `time_check` ile yap.

**Liste işlemleri (CFML list parity):**

ColdFusion'ın list fonksiyonlarının JS karşılıkları — geliştiriciler CF'ten alışkın olduğu için bunlar üretildi. JS array yerine virgül-ayrılmış string ile çalışırlar.

```
list_len(gelen, delim)
list_find(listem, degerim, delim)
list_find_nocase(myList, myValue, delim)
list_getat(gelen, number, delim)
list_setat(listem, position, degerim, delim)
list_first(list, delim)
list_last(list, delim)
list_delete_duplicates(listem, delim, order)
list_delete_duplicates_nocase(listem, delim, order)
```

**String:**

```
trim(inputString)
ReplaceAll(Source, stringToFind, stringToReplace)
stripScripts(s, deleteDefinedArea)
js_mid(str, start, len)              // CFML Mid() karşılığı, 1-indexed
add_sequential_string(deger)         // '001' → '002' gibi padded artırım
```

**Window/popup:**

```
windowopen(theURL, winSize)         // standart yeni pencere
ajaxwindow(theURL, winSize)         // AJAX modal pencere
open_save_popup(asset_file)
gotoListModal(page)
```

**Workcube'a özel:**

```
wrk_safe_query(str_code, data_source, maxrows, ext_params)
                                    // JS'ten sunucuya kontrollü SQL çalıştır
workdata(qry, prmt, maxrows)        // sorgu kısa-yol helper'ı
workcube_showHideLayers()
wrk_call_function_js(call_function_name, call_function_parameters)
WrkAccountControl(control_value, mesaj, new_dsn)
workWarning()
paper_control(obj_name, paper_type, purchase_sales_, upd_id, paper_number,
              company_id, consumer_id, employee_id, dsn_type, is_only_number, obj_name_extra)
                                    // belge/evrak numarası tekrar/format kontrolü
wrkChart(chartName, chartType, chartLabel, chartData)
chan_css_design(css_id)
colorPicker_callBack(strColor)
TusOku(event_)                      // klavye olayı yakalama
```

**Adres (lokasyon kademe seçimi):**

```
LoadCity(id_residence, field_select_city, field_select_county, field_zone_control,
         field_select_district, field_tel_code)
LoadCounty(id_residence, field_select_county, field_telcode, is_name,
           field_select_district, telcod_type)
LoadDistrict(id_residence, field_select_district)
```

Ülke → şehir → ilçe → mahalle kaskat dropdown standart bu üç fonksiyonla yapılır. Yeniden yazma.

**Mesajlaşma (online):**

```
send_online_emp_message(employee_id)
send_online_partner_message(partner_id)
send_online_consumer_message(consumer_id)
send_online_emp_note(employee_id)
get_wrk_message_div(message_header, message_body, file)
```

**Barkod/yardımcı:**

```
get_barcode_no_EAN8(object_, type)
```

**Diğer (sık aranan):**

```
ReplaceAll, stripScripts, ismaxlength, form_warning, choosingControl,
licenceStatus, activeButtonLicence, kickPerson, MyupdateClass,
showPassword(inputid), showPasswordClass(inputid),
set_div_position(div_id), onScrollPassive(),
body_frame_main_height_control / _control2 / _popup_height_control
body_frame_main_width_control / _popup_width_control
spaPageLoad, changeHeader, changePages, changeTab,
openSearchForm, ajaxSearchFormSubmit
```

### Yazım kuralları (JS tarafı)

Bu helper'ları kullanırken birkaç Workcube konvansiyonu var:

1. **Inline event handler'lar tercih edilir** — `onclick`, `onkeyup`, `onblur` HTML attribute'una doğrudan fonksiyon adı yazılır. jQuery `.on()` ile binding yapan kod azdır; aynı stili koru.
2. **Türkçe değişken/fonksiyon adları normaldir** — `kontrol`, `gizle`, `goster`, `arama_yapilmali`, `sira`. Karışıma yenilik yapma; aynı dosyada Türkçe baskınsa Türkçe devam et.
3. **Element seçimi karışık** — bazı fonksiyonlar `document.getElementById(id)`, bazıları `$("#"+id)` (jQuery) kullanır. Bir fonksiyonun beklediği parametrenin **string ID mi yoksa element referansı mı** olduğuna dikkat et (`gizle_goster` her ikisini destekler ama `gizle` sadece element bekler).
4. **Dil mesajları için `language.xxx` global nesnesi var** — `language.kaydedildi`, `language.workcube_hata`, `language.kaydediliyor`. Hard-coded "Kaydedildi!" yazmadan önce bu nesneye bak.
5. **Form submit için `AjaxFormSubmit`** — tam sayfa yenileme yerine. `<form onsubmit="return AjaxFormSubmit(this, 'msg_div', true)">` kalıbı yaygın.

### Yeni helper eklerken

Eğer gerçekten yeni bir JS fonksiyonu gerekiyorsa (önce iki kez kontrol et — büyük ihtimalle var):
- Önce `Y:\JS\js_functions.js` içinde benzerini ara.
- Yeni fonksiyonu **bu dosyaya değil**, kullanıldığı sayfanın altındaki `<script>` bloğuna yaz, **eğer** birden fazla sayfada kullanılacaksa proje yöneticisine danış. `js_functions.js` "stabil" dosyadır.
- Yorumda imza + amaç + örnek kullanım + tarih + geliştirici adı bırak (mevcut fonksiyonların kalıbı: `Tolga Sutlu & Barbaros Kuz 20061124` gibi).

## 16. AJAX yapılandırması ve etkileşim kalıbı

Workcube'da AJAX, sayfa yenilemeden bir div'i (veya sekme içeriğini) sunucudan gelen HTML ile değiştirme üzerine kuruludur. Kütüphane `Y:\JS\js_functions.js` içindeki `AjaxPageLoad` (içerik çek + div'e bas) ve `AjaxFormSubmit` (form gönder) fonksiyonlarıdır. Referans örnek: `Y:\AddOns\ezgi\e_wm\form\add_ezgi_pallets_to_shipment_warehouse.cfm` — sevkiyat barkod okuma akışı.

### 16.1. AjaxPageLoad URL inşa kalıbı

Sunucudan render edilmiş bir parça çekip hedef div'e yazmak için kullanılır. URL `<cfoutput>` bloğu içinde inşa edilir; sunucu tarafı değişkenler (`#request.self#`, `#attributes.ship_id#`, `#get_control.DELIVER_PAPER_NO#`) interpolasyonla yerleşir, **dinamik kullanıcı girişleri** ise `+` ile JS tarafında eklenir:

```javascript
AjaxPageLoad(
    '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_to_shipment_warehouse'
    + '&type=2'
    + '&ship_id=#attributes.ship_id#'
    + '&is_type=#attributes.is_type#'
    + '&ship_number=#get_control.DELIVER_PAPER_NO#</cfoutput>'
    + '&serial_no=' + document.getElementById('add_other_barcod').value
    + '&to_shelf_id=' + document.getElementById('txt_shelf_in').value,
    'ship_result_list',  // hedef div'in ID'si
    1                    // error_detail = 1: sunucu hatası dönerse içeriğini ekrana bas (debug)
);
```

**Parametre sırası:** `(url, target, error_detail, loader_message, li_id, loadFunction, xml)`.

- **target** çok önemli: o ID'ye sahip bir `<div id="ship_result_list"></div>` sayfada **muhakkak** var olmalı, yoksa fonksiyon sessizce başarısız olur (`set_html` try/catch ile yutuyor).
- `error_detail = 1` geliştirme sırasında bırak — CFML hatası varsa stack trace direkt div'e basılır, yoksa sadece "İşlem Hatası!" görürsün.
- 3. parametreyi `1` vermek **hata göstermeyi açar**, `0` vermek ise üretim modu (sadece generic hata mesajı).

### 16.2. `emptypopup_` ön eki nedir?

`fuseaction=stock.emptypopup_ajax_ezgi_to_shipment_warehouse` URL'inde `emptypopup_` ön eki Workcube'a özgüdür ve **layout'suz (header/footer olmadan) sayfa render et** anlamına gelir. AJAX ile çekilen parçalar bu prefix'le çağrılır — yoksa cevap içinde tüm Workcube üst menüsü ve footer'ı da gelir ve hedef div'e basıldığında çift layout oluşur.

**Kural:** Bir CFM dosyasını AJAX ile çağıracaksan `fuseaction`'a `emptypopup_` ön ekiyle git. Form submit aksiyonlarında da aynı: `action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_..."`.

### 16.3. `type=` parametresiyle endpoint çoğullama (router kalıbı)

Aynı CFM endpoint'i `type` parametresinin değerine göre farklı içerik döner — bu Workcube'da çok yaygın bir kalıptır. Çağıran taraf tek URL'i bilir, hangi alt-eylem olacağını `type` ile söyler:

```
type=1 → ürün listesi    (ProductListAjax)
type=2 → seri no listesi (SerialNoListAjax, varsayılan)
type=3 → raf bilgisi     (shipment_area, dropdown ile seçilen değer)
```

Sunucu tarafında `ajax_ezgi_to_shipment_warehouse.cfm` muhtemelen şöyle bölümlere ayrılır:

```cfm
<cfif attributes.type eq 1>
    <!--- ürün listesi grid'i --->
<cfelseif attributes.type eq 2>
    <!--- seri no grid'i (sil parametresi varsa önce DELETE) --->
    <cfif isdefined('attributes.sil') and attributes.sil eq 1> ... </cfif>
<cfelseif attributes.type eq 3>
    <!--- seçilen rafın detayı --->
</cfif>
```

Yeni bir AJAX endpoint yazıyorsan **yeni dosyalar açmak yerine** bu kalıbı kullan — tek dosyada `type=N` ile alt-render'lar. Daha az dosya, daha az fuseaction kaydı.

### 16.4. Barkod / Enter okuma kalıbı

Bu çok yaygındır — depo/üretim ekranlarında kullanıcı barkod okuyucu ile veri girer, Enter'a basınca AJAX tetiklenir. İskelet:

```javascript
document.getElementById('add_other_barcod').focus();
setTimeout("document.getElementById('add_other_barcod').select();", 1000);

document.onkeydown = checkKeycode;
function checkKeycode(e) {
    var keycode;
    if (window.event) keycode = window.event.keyCode;
    else if (e) keycode = e.which;

    if (keycode == 13) {  // Enter
        var val = document.getElementById('add_other_barcod').value;
        if (val.length == '') {
            alert('<cf_get_lang dictionary_id="340.Önce Ürün Barkodu Okutunuz">');
            document.getElementById('add_other_barcod').focus();
            return;
        }
        AjaxPageLoad(<URL>+ '&serial_no=' + val, 'ship_result_list', 1);
        document.getElementById('add_other_barcod').value = '';   // temizle
        document.getElementById('add_other_barcod').focus();      // tekrar odakla
    }
}
```

**Kritik adımlar:**
- `setTimeout(..., 1000)` ile alanın seçili gelmesi — bazı barkod okuyucular hızlı yazıp ilk karakteri kaçırıyor, gecikmeli `select()` bunu önler.
- AJAX sonrası **temizle + odakla** — operatör sıradaki barkodu okuyabilsin diye.
- Boş Enter kontrolü — uyarı + odak geri al.

`document.onkeydown` global listener'dır; sayfada başka bir input'ta Enter'a basılırsa bu da tetiklenir. Bilinçli bir tercihtir (barkod okuyucu odaktan bağımsız olsun diye), ama yeni sayfada çakışma olursa `e.target.id` kontrolüyle filtrele.

### 16.5. Tab + AJAX yükleme kalıbı

Aynı veriyi farklı görünümlerde göstermek için (örn. "Ürünler" / "Seri No'lar" sekmeleri):

```html
<div id="tab-container" class="tabStandart">
    <div id="tab-head">
        <ul class="tabNav">
            <li class="active"><a href="#ship_result_list" onclick="SerialNoListAjax();">#sekme1#</a></li>
            <li><a href="#ship_result_list" onclick="ProductListAjax();">#sekme2#</a></li>
        </ul>
    </div>
    <div id="tab-content">
        <div id="ship_result_list" class="content row"><!-- AJAX buraya yükler --></div>
    </div>
</div>

<script>
    function SerialNoListAjax() {
        AjaxPageLoad('<cfoutput>#request.self#?fuseaction=...&type=2&...</cfoutput>',
                     'ship_result_list', 1);
    }
    function ProductListAjax() {
        AjaxPageLoad('<cfoutput>#request.self#?fuseaction=...&type=1&...</cfoutput>',
                     'ship_result_list', 1);
    }
    window.onload = function() {
        SerialNoListAjax();  // varsayılan sekmeyi yükle
    };
</script>
```

**Kurallar:**
- Tab `<a href="#ship_result_list">` — `href` aynı div'i işaret eder, ama gerçek değişim `onclick` ile yapılır.
- `class="tabStandart"`, `class="tabNav"`, `class="active"` Workcube CSS sınıfları — değiştirme.
- İlk açılışta `window.onload` (veya `$(document).ready`) ile varsayılan sekmeyi yükle, aksi takdirde div boş gelir.
- Aktif sekmeyi `active` sınıfıyla işaretle; AJAX fonksiyonu içinde sınıfları yöneten ekstra kod yazılmıyor — sayfa render edildiğinde server-side `<cfif attributes.anamenu eq 1>active</cfif>` koşullu basılır.

### 16.6. Onay/silme akışı

Listedeki bir satırı silmek için `confirm()` + AJAX kalıbı:

```javascript
function sil(serialno) {
    var soru = confirm(serialno + ' Seri Nolu Ürünü Rezervasyondan Çıkarıyorum ?');
    if (soru == true) {
        AjaxPageLoad(
            '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_...&type=2&sil=1&...</cfoutput>'
            + '&serial_no=' + serialno,
            'ship_result_list', 1
        );
        document.getElementById('add_other_barcod').value = '';
        document.getElementById('add_other_barcod').focus();
    } else {
        return false;
    }
}
```

`&sil=1` parametresi server tarafında `<cfif isdefined('attributes.sil') and attributes.sil eq 1>` ile yakalanır, DELETE yapılır, sonra güncel liste tekrar render edilir. Tek endpoint hem listeyi hem silme işlemini yönetir — kullanıcı arayüzü tutarlı kalır.

### 16.7. AJAX-merkezli sayfa yapısı (önemli detaylar)

Yukarıdaki örnekte sayfanın geneli AJAX'a göre tasarlanmıştır; izlemen gereken kalıp:

1. **Conditional render with `style="display:none"`** — başlangıçta gizli alanlar (`first_area`, `third_area`, `fourth_area`) sunucu tarafı koşula göre `display:none` ile basılır, sonra AJAX cevabıyla gösterilir:
   ```cfm
   <div id="first_area" <cfif get_control.SHIPMENT_PRODUCT_PLACE_ID eq 0>style="display:none"</cfif>>
   ```
2. **`<cf_basket_form>` özel tag** — basket/repeater contextli formlar için (her bir satır kendi başına submit edilebilir). Standart `<cfform>` yerine basket UI'larda bunu kullan.
3. **Hidden input'lar JS için "id_+name" çifti** — `txt_shelf_in_name` görünür text, `txt_shelf_in` gizli ID. AJAX URL'inde `.value` üzerinden ID'yi yollarsın, görünür alan kullanıcıya isim gösterir.
4. **Çoklu AJAX hedef div'leri** — `shelf_div`, `ship_result_list`, `serial_div` gibi farklı div'ler farklı endpoint'lerin cevabını bekler. Her birini sayfanın altına önceden koy (boş da olsa).
5. **Sunucu cevabı içinde `<script>` döndürmek** — `AjaxPageLoad`, `ajax_request_script` helper'ı ile gelen HTML içindeki `<script>`'leri ayrıştırıp çalıştırır. Yani server'dan dönen parça `<script>alert('x');</script>` içerirse bu çalışır — error/success bildirimlerini server tarafında script olarak basabilirsin.

### 16.8. Yeni bir AJAX akışı yazarken kontrol listesi

1. Hedef div sayfada var mı? (`<div id="X"></div>`)
2. URL `emptypopup_` ön ekli mi?
3. URL `<cfoutput>` bloğu içinde mi inşa ediliyor (sunucu değişkenleri için), JS değerleri `+` ile **dışarıdan** mı ekleniyor?
4. `error_detail` parametresi geliştirme aşamasında `1`, üretimde `0` (veya direkt 1 — Workcube'da çoğunlukla 1 bırakılmış).
5. AJAX sonrası **input'lar temizlendi mi, focus yerine konuldu mu**?
6. Birden fazla AJAX tetikleyici varsa, hepsi aynı veri çatısına render ediyorsa **aynı endpoint + farklı `type=`** ile çoğullamayı düşün.
7. Sayfa ilk açıldığında varsayılan içerik gelmeli mi? (`window.onload` veya `$(document).ready` ile ilk AJAX'ı tetikle.)

## 17. CFML/cfscript "include-as-function" helper'ları (`Y:\V16\objects\functions\`)

Workcube V16'nın yeniden kullanılabilir iş mantığı bu klasörde toplanmıştır. Her dosya bir veya birden fazla **User Defined Function (UDF)** tanımlar — `<cffunction>` veya `<cfscript>` bloğu içinde. Çağıran sayfa dosyayı `<cfinclude>` ile yükler, sonra fonksiyonu çağırır.

**Yeni iş mantığı yazmadan önce burayı tara.** Numara üretmek, belge dönüştürmek, seri no kaydetmek, fiyat hesaplamak, muhasebe fişi atmak — büyük ihtimalle hazır bir helper var.

### 17.1. Dosya organizasyonu (kategorize)

44 dosyalık bu klasörü iş alanına göre okumak gerekir:

**Numara/kod üreticileri (sayaç tabanlı):**
- `get_barcode_no.cfm` — EAN13/EAN8 barkod üretir, check digit ekler
- `get_cheque_no.cfm` — çek numarası
- `get_product_no.cfm` — ürün kodu

**Belge dönüşümleri (irsaliye → fatura, sipariş → irsaliye):**
- `add_invoice_from_order.cfm` — siparişten fatura oluştur
- `add_invoice_from_ship.cfm` — irsaliyeden fatura
- `add_invoice_from_ship_result.cfm` — sevkiyat sonucu → fatura
- `add_ship_from_order.cfm` — siparişten irsaliye

**Satır/ilişki ekleyiciler:**
- `add_internaldemand_relation.cfm` (+ `_pda.cfm` PDA varyantı)
- `add_paper_relation.cfm`
- `add_pre_order_rows.cfm`
- `add_relation_rows.cfm`
- `add_ship_row_relation.cfm`
- `add_stock_rows.cfm`

**Stok rezervasyon / seri no:**
- `add_order_row_reserved_stock.cfm` (+ `_pda.cfm`)
- `add_reserved_stock.cfm`
- `add_serial_no.cfm` — garanti/seri no kaydı toplu INSERT
- `del_serial_no.cfm`

**Konfigüratör:**
- `get_conf_components.cfm`
- `get_conf_components_property.cfm`

**Muhasebe/finans:**
- `get_carici.cfm` — cari işlem fişi
- `get_muhasebeci.cfm` — muhasebe fişi
- `get_butceci.cfm` — bütçe fişi
- `get_cost.cfm`, `cost_action.cfm`
- `get_process_money.cfm`
- `get_product_stock_cost.cfm`
- `get_basket_money_js.cfm`
- `get_user_accounts.cfm`

**Üretim:**
- `get_production_times.cfm`
- `get_prod_order_funcs.cfm`

**Fiyat / ürün:**
- `add_product_price.cfm`

**Tarihçe / aksiyon:**
- `add_company_related_action.cfm`
- `add_consumer_history.cfm`

**İletişim:**
- `workcube_sms.cfm`

**Misc / yardımcı:**
- `add_one.cfm` — string olarak verilmiş sayıyı 1 artırır (numara serisi için)
- `barcode.cfm` — barkod çizim helper
- `del_sessions.cfm`
- `export_stock_espos_functions.cfm`
- `sales_import_functions.cfm`
- `get_specer.cfm`
- `get_wrk_content_clear.cfm`
- `auto_complete_functions.js` — JS tarafı autocomplete helper

**`_pda.cfm` son eki:** PDA / mobil terminal varyantıdır. Form attribute'ları farklı, ana mantık aynı.

### 17.2. Dosya iskelet kalıbı

Her UDF dosyası bu şablonu izler:

```cfm
<cfsetting enablecfoutputonly="yes"><cfprocessingdirective suppresswhitespace="yes">

<cffunction name="<fonksiyon_adı>" returntype="any" output="false">
    <cfargument name="param1" type="numeric" required="true">
    <cfargument name="param2" type="string" default="">

    <!---
    by    : <Geliştirici> YYYYMMDD
    notes : <iş mantığının kısa açıklaması>
    usage : <fonksiyon_adı>(param1, param2)
            <cfset sonuc = <fonksiyon_adı>(123, 'abc')>
    revisions : YYYYMMDD <ne değişti>
    --->

    <!--- gövde --->
    <cfreturn <değer>>
</cffunction>

</cfprocessingdirective><cfsetting enablecfoutputonly="no">
```

**Neden başlık/kuyruk böyle?**
- `enablecfoutputonly="yes"` + `suppresswhitespace="yes"` — dosya `<cfinclude>` edildiğinde **hiç whitespace ya da accidental output üretmez**. UDF tanımının yan etkisi olmamalı; çağıran sayfanın HTML'i kirlenmesin diye sarılır.
- En altta `enablecfoutputonly="no"` ile normal moda geri dönülür — sonraki sayfa içeriği etkilenmesin.

Yeni dosya yazıyorsan bu sarmalı **muhakkak koy**. Boşluksuz bile olsa CFML satır sonları output'a sızar.

### 17.3. cfscript varyantı

Saf matematiksel/string helper'lar cfscript bloğunda yazılır:

```cfm
<cfscript>
    function add_one(gelen) {
        elde = 0;
        uz = len(gelen);
        for (i = uz; i gt 0; i = i - 1) {
            // ...
        }
        return gelen;
    }
</cfscript>
```

cfscript syntax CFML'in JavaScript benzeri yazımıdır. Karmaşık iş mantığı (transaction, sorgu, custom tag) için `<cffunction>` etiket sözdizimi tercih edilir. Saf hesaplamalar için cfscript daha kısa.

### 17.4. Çağırma kalıbı (use site)

```cfm
<!--- 1. Dosyayı include et (yalnızca bir kez sayfa başında) --->
<cfinclude template="/V16/objects/functions/get_barcode_no.cfm">

<!--- 2. Fonksiyonu çağır --->
<cfset yeni_barkod = get_barcode_no()>
<cfset ean8_barkod = get_barcode_no(barcode_for_ean8=1)>
```

İnclude path'i **mutlak** verilir (`/V16/objects/functions/...`), göreceli değil — sayfa Workcube içinde nereden çağrılırsa çağrılsın çalışsın diye.

**Aynı dosya birden fazla kez include edilirse "function already defined" hatası alırsın.** Aynı sayfada birden çok yer kullanacaksa en üstte bir kez include et.

### 17.5. Sayaç/numara üretici kalıbı

Bu klasördeki tüm `get_*_no` helper'ları aynı eşgüdüm desenini izler — yarış koşulu olmadan tek bir tablodaki sayaç alanını okuyup +1 yapıp geri yazmak:

```cfm
<cffunction name="get_barcode_no" returntype="any" output="false">
    <cfargument name="barcode_for_ean8" default="">

    <cflock name="#CreateUUID()#" timeout="20">
        <cftransaction>
            <cfquery name="GET_BARCODE_NO_" datasource="#DSN1#">
                SELECT BARCODE FROM PRODUCT_NO
            </cfquery>
            <cfif GET_BARCODE_NO_.recordcount>
                <cfset wrk_barcode = left(trim(GET_BARCODE_NO_.BARCODE), 12)>
                <cfquery name="UPDATE_BARCODE_NO_" datasource="#DSN1#">
                    UPDATE PRODUCT_NO SET BARCODE = '#wrk_barcode + 1#X'
                </cfquery>
            </cfif>
        </cftransaction>
    </cflock>

    <cfscript>
        if (len(wrk_barcode)) {
            wrk_barcode = wrk_barcode + 1;
            if (len(wrk_barcode) eq 12)
                return wrk_barcode & UPCEANCheck(wrk_barcode);
        }
        return '';
    </cfscript>
</cffunction>
```

**Kritik noktalar:**
- `<cflock name="#CreateUUID()#" timeout="20">` — kritik bölge. UUID her çağrıda yeni olduğu için **gerçek anlamda mutex değildir**; bu kalıp Workcube'un geleneksel yazım stilidir ama yarış riski olabilir. Yeni helper yazıyorsan sabit bir lock adı (örn. `name="barcode_counter"`) kullanmak daha güvenlidir.
- `<cftransaction>` — SELECT + UPDATE atomik olsun diye.
- Numaraya `X` ekleyip sonradan değiştirme — geçici dolgu; check digit hesaplandıktan sonra final numara döner.
- `PRODUCT_NO` tablosu tek satırlık global sayaç deposudur. Bu Workcube konvansiyonu — sequence ya da identity yerine tek-satır-update.

### 17.6. `<cfargument>` ve `arguments.X` kullanımı

```cfm
<cfargument name="process_type" type="numeric" required="true">
<cfargument name="is_sale"      type="boolean" default="false">
<cfargument name="dpt_id"       type="string"  required="true" default="">
<cfargument name="con_id"       type="string"  default="">
```

Tip aileleri: `numeric`, `string`, `boolean`, `any`, `array`, `struct`, `query`, `date`. `required="true"` verilse bile `default=""` koymak yaygındır — defansif tarz, fonksiyon çağrılırken parametre unutulursa runtime hatası vermesin.

Fonksiyon gövdesinde **her zaman `arguments.X` ile eriş** — `attributes.X` veya direkt `X` kullanma. `arguments` scope'u fonksiyona özeldir, dış scope'a sızmaz.

### 17.7. `process_type` numerik katalog (kritik konvansiyon)

`add_serial_no` ve diğer belge işleyici fonksiyonlarda **belge tipleri sayısal ID ile** temsil edilir. Bu ID'ler Workcube'da global anlamlıdır; ezberlemek yerine grup grup `listfindnocase` ile kontrol edilir:

```cfm
<cfif listfindnocase('73,74,75,76,77,80,82,84,86,87,110,115,140', arguments.process_type, ',')>
    <!--- Alış / giriş işlemleri --->
    <cfset my_is_purchase = 1>
    <cfset my_in_out = 1>
<cfelseif listfindnocase('70,71,72,78,79,88,83,141', arguments.process_type, ',')>
    <!--- Satış / çıkış işlemleri --->
    <cfset my_is_sale = 1>
    <cfset my_in_out = 0>
<cfelseif listfindnocase('81,811,113', arguments.process_type, ',')>
    <!--- Depolararası sevk — yön argümana göre --->
</cfif>
```

Tipik gruplar:
- **70-79** → satış belgeleri (sipariş, irsaliye, fatura türevleri)
- **73-75** → satış iadesi
- **80-88** → alış belgeleri
- **85** → RMA
- **110-119** → stok fişi
- **140-141** → sevkiyat sonucu
- **170-171** → üretim
- **111, 112** → sarf / fire
- **1131** → seri sonu

**Yeni bir belge türü ekliyorsan** mutlaka bu helper'lardaki `listfindnocase` listelerini gözden geçir — değilse satış/alış flag'leri yanlış set edilir, stok hareketleri kayıtsız kalır, audit log bozulur. ID listeleri bir nevi enum görevi görür ve gevşek değildir.

### 17.8. `evaluate()` ile dinamik attribute erişimi (basket/repeater)

Form basket'lerde aynı alan birden çok kez bulunur — `attributes.stock_id1`, `attributes.stock_id2`, ... numaralandırılır. UDF içinde dinamik isim üretip okumak için `evaluate()` kullanılır:

```cfm
<cfif isdefined("attributes.guaranty_cat#arguments.session_row#")
      and len(evaluate('attributes.guaranty_cat#arguments.session_row#'))>
    <cfset cat_id = evaluate('attributes.guaranty_cat#arguments.session_row#')>
</cfif>
```

**Önemli:** `evaluate()` modern CFML'de yavaş ve güvensiz sayılır ama Workcube kod tabanında baskındır — uyma. Yeni kod yazarken yerine `attributes["guaranty_cat" & arguments.session_row]` da kullanılabilir, ama dosyanın geri kalanı `evaluate` kullanıyorsa tutarlı olsun.

### 17.9. Çoklu kayıt INSERT (UNION ALL bloklama)

Yüzlerce satır basket göndereceksen tek tek INSERT atmak performans katili. Workcube kalıbı `INSERT INTO ... SELECT ... UNION ALL` ile 400'lük bloklarla yazar:

```cfm
<cfset baslangic_degeri = 1>
<cfset blok_sayisi = 400>
<cfloop from="1" to="#list_uzunluk#" index="aaa">
    <cfquery name="add_guaranty" datasource="#dsn3#">
        INSERT INTO SERVICE_GUARANTY_NEW
        (col1, col2, ...)
        <cfloop from="#baslangic_degeri#" to="#blok_sayisi#" index="j">
            SELECT
                <cfqueryparam value="#listgetat(...,j)#">,
                ...
            <cfif j neq blok_sayisi>
                UNION ALL
            </cfif>
        </cfloop>
    </cfquery>
    <cfset baslangic_degeri = baslangic_degeri + 400>
    <cfset blok_sayisi = blok_sayisi + 400>
</cfloop>
```

**Neden 400?** SQL Server'ın `INSERT ... VALUES (...)` çoklu satırda 1000 limit'i var; `INSERT ... SELECT ... UNION ALL` ise sınırsız ama 256 tablo expression sınırı pratikte 400-500 civarında güvenli. Workcube 400 seçmiş — sayıyı değiştirmeden bu kalıbı kopyala.

### 17.10. `<cfqueryparam>` kullanımı

Modern UDF'lerde `<cfqueryparam cfsqltype="cf_sql_varchar" value="#x#">` ile SQL injection koruması ve tip belirleme yapılır. Yaygın tip değerleri:

| cfsqltype | Ne için |
|---|---|
| `cf_sql_integer` | Tam sayı (ID'ler) |
| `cf_sql_varchar` | String |
| `cf_sql_decimal` / `cf_sql_numeric` | Ondalıklı sayı |
| `cf_sql_date` / `cf_sql_timestamp` | Tarih |
| `cf_sql_bit` | Boolean (0/1) |

Workcube kod tabanı karışıktır — eski sorgular `#x#` interpolation kullanır, yenileri `cfqueryparam`. **Yeni kod yazarken kullan**; user-supplied veriler (özellikle `attributes.X`) muhakkak `cfqueryparam` ile geçsin.

### 17.11. UDF yazarken kontrol listesi

Yeni bir helper fonksiyon ekliyorsan:

1. Aynı klasörde benzer adlı bir dosya var mı? (örn. `add_invoice_from_order.cfm` varken yenisini yazmadan oku.)
2. Dosya başında `<cfsetting enablecfoutputonly="yes"><cfprocessingdirective suppresswhitespace="yes">` ve sonunda kapanış var mı?
3. Her `<cffunction>` için doküman yorumu (`by`, `notes`, `usage`) ekledin mi?
4. `<cfargument>` ile tüm parametreler tipli ve default'lu mu?
5. Sayaç güncelliyorsan `<cflock>` + `<cftransaction>` sardın mı?
6. `process_type` ile çalışıyorsan, mevcut listeleri kontrol edip yeni belge tipini ekledin mi?
7. Kullanıcı girdileri `<cfqueryparam>` ile mi gidiyor?
8. Çoklu satır INSERT için 400'lük blok kalıbı mı?
9. `<cfreturn>` ile bir değer dönüyor mu (output sayfayı kirletmesin)?

---

Bu kalıpların **neden** önemli olduğunu hatırla: Workcube'da yetki sistemi, dil sistemi, routing, audit log ve menü hepsi konvansiyona bağlı. Konvansiyondan sapan dosya çalışsa bile yetkisiz kullanıcılarda buton görünür, çeviri eksik kalır, ya da rapora kayıt düşmez. Bu yüzden bu rehberdeki kalıpları gevşek değil, sıkı uygula.
