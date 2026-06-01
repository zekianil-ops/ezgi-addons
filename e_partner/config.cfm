<!---
    File: config.cfm
    Folder: AddOns/ezgi/e_partner
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Manuel Konfigürasyon Dosyası
    
    Bu dosyada COMP_ID'yi manuel olarak ayarlayabilirsiniz.
    Eğer bu dosyada COMP_ID tanımlıysa, setup sayfasındaki değer yerine bu değer kullanılır.
    
    Kullanım:
    1. COMP_ID değerini aşağıdaki satırda değiştirin
    2. Dosyayı kaydedin
    3. Uygulama otomatik olarak bu değeri kullanacaktır
--->

<!--- Manuel COMP_ID ayarı --->
<!--- Bu değer varsa, setup sayfasındaki değer yerine bu kullanılır --->
<cfset config.COMP_ID = "">
<!--- Örnek: <cfset config.COMP_ID = "1"> --->

<!--- Manuel PERIOD_YEAR ayarı (opsiyonel) --->
<!--- Eğer boş bırakılırsa, SETUP_PERIOD tablosundan otomatik alınır --->
<cfset config.PERIOD_YEAR = "">
<!--- Örnek: <cfset config.PERIOD_YEAR = "2025"> --->

