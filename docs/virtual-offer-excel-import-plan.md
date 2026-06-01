# Sanal Teklif Excel Import Sistemi
## Teknik Mimari ve Faz Planı

## Amaç
Müşteriden gelen standart olmayan Excel verisini:
- ürünlere bağlayan
- ölçüleri yorumlayan
- resimleri işleyen
- sanal teklif satırına dönüştüren

bir import sistemi geliştirmek.

## Mevcut Sistem
- Sanal teklif header oluşturulabiliyor
- ürün satırı manuel eklenebiliyor
- spect popup ile konfigürasyon yapılabiliyor
- pre-import tablo ve liste ekranı mevcut
- excel upload ekranı mevcut
- resim extract helper fonksiyonları geliştirilmeye başlandı

## Mimari Katmanlar

### 1. Staging Katmanı
Tablo: EZGI_VIRTUAL_OFFER_ROW_PRE_IMPORT

Amaç:
Excel’den gelen ham veriyi tutmak.

Alanlar:
- PRODUCT_NAME
- DESCRIPTION
- DIM
- QUANTITY
- IMAGE_PATH
- IMAGE_NAME
- IMAGE_FILE
- IMAGE_URL
- MATCH_STATUS
- ERROR_MESSAGE

### 2. Normalizasyon Katmanı
Amaç:
Ham veriyi anlamlı veri yapısına dönüştürmek.

Helper fonksiyonlar:
- normalizeText()
- normalizeImportRow()
- parseDimensions()
- parseDescription()

Beklenen çıktı örneği:
- product_name
- quantity
- dimensions
- materials
- area

### 3. Ürün Eşleştirme Katmanı
Amaç:
Excel’den gelen ürün adını sistem ürünleri ile eşleştirmek.

Helper fonksiyon:
- matchImportProduct()

Eşleşme tipleri:
- exact
- normalized
- fuzzy
- none

### 4. Resim İşleme Katmanı
Helper fonksiyonlar:
- extractExcelImages()
- mapImagesToRows()
- saveImportImage()

Akış:
Excel içindeki embedded image veya URL verisi alınır, kalıcı klasöre taşınır ve pre-import kaydına bağlanır.

### 5. Uygulama Katmanı
Amaç:
Eşleşmiş ve doğrulanmış pre-import satırlarını sanal teklif satırına dönüştürmek ve sonrasında spect uygulamak.

---

## Tam Akış
1. Excel upload
2. Excel parse
3. Pre-import tabloya kayıt
4. Embedded image extract
5. Satır ve resim eşleştirme
6. Normalizasyon
7. Ürün eşleştirme
8. Liste ekranında gösterim
9. Kullanıcı kontrolü
10. Seçili satırları sanal teklif satırına dönüştürme
11. Spect uygulama

---

## Faz Planı

### FAZ 1
Amaç:
Pre-import akışını kurmak ve ham veriyi sisteme almak.

Kapsam:
- excel upload ekranı
- pre-import tabloya kayıt
- liste ekranında ham veriyi göstermek
- embedded image extract helper fonksiyonları
- image alanlarının tabloya eklenmesi

Bu faz kısmen yapılmış kabul edilir.

### FAZ 2
Amaç:
Pre-import verisini kullanıcı için anlamlı hale getirmek.

Kapsam:
1. Normalizasyon katmanı
   - normalizeText()
   - normalizeImportRow()
   - parseDimensions()
   - parseDescription()

2. Ürün eşleştirme katmanı
   - matchImportProduct()
   - exact / normalized / fuzzy / none
   - match_score üretimi

3. Liste ekranı geliştirmesi
   - Sistem Ürün Adı Bağlantısı kolonunda öneri göster
   - Teknik etiket yerine kullanıcı dostu metin kullan:
     - Tam eşleşti
     - Güçlü benzer eşleşme
     - Benzer eşleşme
     - Öneri bulunamadı
   - Mümkünse skor da göster
   - Manuel ürün seçme akışı bozulmayacak

4. Bu fazda YAPILMAYACAKLAR
   - otomatik sanal teklif satırı oluşturma
   - spect uygulama
   - toplu otomatik bağlama
   - canlı kayıtları değiştiren agresif otomasyon

FAZ 2 çıktısı:
Kullanıcı pre-import ekranında her satır için:
- normalize edilmiş ürün mantığını
- önerilen sistem ürününü
- eşleşme kalitesini
görebilmeli.

### FAZ 3
Amaç:
Seçilen ve doğrulanan satırları sanal teklif satırına dönüştürmek.

Kapsam:
- virtual_offer_row oluşturma
- pre-import kaydını gerçek satıra bağlama
- kontrollü toplu aktarım

### FAZ 4
Amaç:
Sanal teklif satırı oluştuktan sonra spect verilerini uygulamak.

Kapsam:
- ölçüleri spect alanlarına yazma
- soru/cevap eşleştirme
- ürün bileşenlerini hesaplatma
- fiyatı güncelleme

---

## Kurallar
- Mevcut ekran yapısı mümkün olduğunca korunacak
- Manuel ürün seçimi bozulmayacak
- Önce öneri, sonra kullanıcı kontrolü yaklaşımı izlenecek
- Faz 2’de yalnızca görüntüleme, normalizasyon ve öneri üretimi yapılacak
- Faz 2’de veritabanına agresif update yapılmayacak

## Faz 2 için etkilenecek dosyalar
Muhtemel dosyalar:
- addOns/ezgi/e_sales/display/list_ezgi_virtual_offer_row_import.cfm
- addOns/ezgi/e_sales/form/add_ezgi_virtual_offer_row_file_import.cfm
- varsa helper/include dosyaları

## Cursor’dan Beklenen Çıktı
- önce Faz 2 planı
- sonra hangi dosyada ne değişeceği
- sonra diff
- kısa test notu