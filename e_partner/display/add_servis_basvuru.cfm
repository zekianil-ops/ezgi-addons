<!---
    File: add_servis_basvuru.cfm
    Folder: AddOns/ezgi/e_partner/display
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Servis Başvuru Kayıt Sayfası
--->
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>B2B Partner Portal - Servis Başvuru</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: #f3f4f6;
            color: #1f2937;
        }
        .header {
            background: #ffffff;
            border-bottom: 1px solid #e5e7eb;
            padding: 16px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        .header h1 {
            color: #1e3a8a;
            font-size: 24px;
            font-weight: 700;
        }
        .user-info {
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .user-name {
            color: #374151;
            font-weight: 600;
        }
        .btn-logout {
            padding: 8px 16px;
            background: #ef4444;
            color: #ffffff;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s ease;
        }
        .btn-logout:hover {
            background: #dc2626;
        }
        .navbar {
            background: #ffffff;
            border-bottom: 1px solid #e5e7eb;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        .navbar-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .navbar-menu {
            display: flex;
            list-style: none;
            margin: 0;
            padding: 0;
            gap: 0;
        }
        .navbar-menu li {
            margin: 0;
        }
        .navbar-menu a {
            display: block;
            padding: 16px 20px;
            color: #374151;
            text-decoration: none;
            font-weight: 500;
            font-size: 14px;
            transition: all 0.2s ease;
            border-bottom: 3px solid transparent;
        }
        .navbar-menu a:hover {
            color: #667eea;
            background: #f9fafb;
        }
        .navbar-menu a.active {
            color: #667eea;
            border-bottom-color: #667eea;
            background: #f9fafb;
        }
        .navbar-menu a i {
            margin-right: 8px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 24px;
        }
        .page-header {
            margin-bottom: 24px;
        }
        .page-header h2 {
            color: #1e3a8a;
            font-size: 28px;
            margin-bottom: 8px;
        }
        .page-header p {
            color: #6b7280;
            font-size: 16px;
        }
        .content-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #374151;
            font-weight: 600;
            font-size: 14px;
        }
        .form-group label .required {
            color: #ef4444;
            margin-left: 4px;
        }
        .form-group input[type="text"],
        .form-group input[type="email"],
        .form-group input[type="tel"],
        .form-group input[type="date"],
        .form-group input[type="file"],
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            font-size: 14px;
            font-family: inherit;
            transition: all 0.2s ease;
        }
        .form-group input[type="file"] {
            padding: 8px;
            cursor: pointer;
        }
        .file-upload-area {
            border: 2px dashed #d1d5db;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            background: #f9fafb;
            transition: all 0.2s ease;
        }
        .file-upload-area:hover {
            border-color: #667eea;
            background: #f0f4ff;
        }
        .file-upload-area.dragover {
            border-color: #667eea;
            background: #e0e7ff;
        }
        .file-list {
            margin-top: 12px;
        }
        .file-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 8px 12px;
            background: #f9fafb;
            border-radius: 6px;
            margin-bottom: 8px;
            font-size: 13px;
        }
        .file-item .file-name {
            flex: 1;
            color: #374151;
        }
        .file-item .file-size {
            color: #6b7280;
            margin: 0 12px;
        }
        .file-item .file-remove {
            color: #ef4444;
            cursor: pointer;
            font-weight: 600;
            padding: 4px 8px;
            border-radius: 4px;
            transition: all 0.2s ease;
        }
        .file-item .file-remove:hover {
            background: #fee2e2;
        }
        .file-preview {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            gap: 12px;
            margin-top: 12px;
        }
        .file-preview-item {
            position: relative;
            border-radius: 6px;
            overflow: hidden;
            border: 1px solid #e5e7eb;
        }
        .file-preview-item img,
        .file-preview-item video {
            width: 100%;
            height: 120px;
            object-fit: cover;
            display: block;
        }
        .file-preview-item .preview-remove {
            position: absolute;
            top: 4px;
            right: 4px;
            background: rgba(239, 68, 68, 0.9);
            color: white;
            border: none;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            cursor: pointer;
            font-size: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .file-preview-item .preview-remove:hover {
            background: rgba(220, 38, 38, 1);
        }
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        .form-group textarea {
            resize: vertical;
            min-height: 120px;
        }
        .form-group .char-count {
            font-size: 12px;
            color: #6b7280;
            margin-top: 4px;
        }
        .form-group .char-count.warning {
            color: #f59e0b;
        }
        .form-group .char-count.error {
            color: #ef4444;
        }
        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }
        .form-actions {
            display: flex;
            gap: 12px;
            margin-top: 24px;
            padding-top: 24px;
            border-top: 1px solid #e5e7eb;
        }
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s ease;
        }
        .btn-primary {
            background: #667eea;
            color: #ffffff;
        }
        .btn-primary:hover {
            background: #5568d3;
        }
        .btn-secondary {
            background: #6b7280;
            color: #ffffff;
        }
        .btn-secondary:hover {
            background: #4b5563;
        }
        .error-message {
            background: #fee2e2;
            color: #991b1b;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 20px;
            border-left: 4px solid #ef4444;
        }
        .success-message {
            background: #d1fae5;
            color: #065f46;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 20px;
            border-left: 4px solid #10b981;
        }
        @media (max-width: 768px) {
            .navbar-menu {
                flex-wrap: wrap;
            }
            .navbar-menu a {
                padding: 12px 16px;
                font-size: 13px;
            }
            .form-row {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>B2B Partner Portal</h1>
        <div class="user-info">
            <span class="user-name">
                <cfoutput>
                    <cfif len(session.b2b.partnerName) or len(session.b2b.partnerSurname)>
                        Hoş geldiniz, #session.b2b.partnerName# #session.b2b.partnerSurname#
                    <cfelse>
                        Hoş geldiniz, #session.b2b.username#
                    </cfif>
                </cfoutput>
            </span>
            <a href="index.cfm?fuseaction=partner.logout" class="btn-logout">Çıkış Yap</a>
        </div>
    </div>
    
    <!--- Menü Çubuğu --->
    <nav class="navbar">
        <div class="navbar-container">
            <ul class="navbar-menu">
                <li>
                    <a href="index.cfm?fuseaction=partner.dashboard">
                        <i>🏠</i> Ana Sayfa
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.products">
                        <i>📦</i> Ürünler
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.orders">
                        <i>🛒</i> Siparişler
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.invoices">
                        <i>📄</i> Faturalar
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.cari_ekstre">
                        <i>📋</i> Cari Ekstre
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.servis_islemleri" class="active">
                        <i>🔧</i> Servis İşlemleri
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.profile">
                        <i>👤</i> Profil
                    </a>
                </li>
            </ul>
        </div>
    </nav>
    
    <div class="container">
        <div class="page-header">
            <h2>🔧 Servis Başvuru</h2>
            <p>Yeni bir servis başvurusu oluşturun</p>
        </div>
        
        <!--- Hata/Başarı Mesajları --->
        <cfif isDefined("url.error") and len(url.error)>
            <div class="error-message">
                <cfoutput>#HTMLEditFormat(url.error)#</cfoutput>
            </div>
        </cfif>
        <cfif isDefined("url.success") and len(url.success)>
            <div class="success-message">
                <cfoutput>#HTMLEditFormat(url.success)#</cfoutput>
            </div>
        </cfif>
        
        <!--- Selectbox seçeneklerini getir --->
        <cfinclude template="../query/get_servis_basvuru_options.cfm">
        
        <div class="content-card">
            <cfform name="servis_basvuru_form" method="post" action="index.cfm?fuseaction=partner.add_servis_basvuru_process" enctype="multipart/form-data">
                <input type="hidden" name="is_submitted" value="1">
                
                <!--- Başvuru Bilgileri --->
                <h3 style="color: #1e3a8a; margin-bottom: 16px; padding-bottom: 12px; border-bottom: 2px solid #e5e7eb;">Başvuru Bilgileri</h3>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="kategori_id">Servis Başvuru Kategorisi <span class="required">*</span></label>
                        <select name="kategori_id" id="kategori_id" required>
                            <option value="">Seçiniz...</option>
                            <cfoutput query="get_kategoriler">
                                <option value="#kategori_id#">#HTMLEditFormat(kategori_adi)#</option>
                            </cfoutput>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="iletisim_sekli_id">İletişim Şekli <span class="required">*</span></label>
                        <select name="iletisim_sekli_id" id="iletisim_sekli_id" required>
                            <option value="">Seçiniz...</option>
                            <cfoutput query="get_iletisim_sekilleri">
                                <option value="#iletisim_sekli_id#">#HTMLEditFormat(iletisim_sekli_adi)#</option>
                            </cfoutput>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="oncelik_id">Öncelik <span class="required">*</span></label>
                        <select name="oncelik_id" id="oncelik_id" required>
                            <option value="">Seçiniz...</option>
                            <cfoutput query="get_oncelikler">
                                <option value="#oncelik_id#">#HTMLEditFormat(oncelik_adi)#</option>
                            </cfoutput>
                        </select>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="konu">Konu <span class="required">*</span></label>
                    <input type="text" name="konu" id="konu" maxlength="250" required placeholder="Başvuru konusunu giriniz">
                    <div class="char-count" id="konu_count">0 / 250 karakter</div>
                </div>
                
                <div class="form-group">
                    <label for="aciklama">Açıklama <span class="required">*</span></label>
                    <textarea name="aciklama" id="aciklama" maxlength="1000" required placeholder="Başvuru açıklamasını detaylı olarak giriniz"></textarea>
                    <div class="char-count" id="aciklama_count">0 / 1000 karakter</div>
                </div>
                
                <div class="form-group">
                    <label for="basvuru_tarihi">Başvuru Tarihi <span class="required">*</span></label>
                    <input type="date" name="basvuru_tarihi" id="basvuru_tarihi" required>
                </div>
                
                <!--- Dosya Yükleme Alanı --->
                <div class="form-group">
                    <label>Resim ve Video Ekle</label>
                    <div class="file-upload-area" id="fileUploadArea">
                        <input type="file" name="dosyalar" id="dosyalar" multiple accept="image/*,video/*" style="display: none;">
                        <div style="cursor: pointer;" onclick="document.getElementById('dosyalar').click();">
                            <p style="color: #6b7280; margin-bottom: 8px;">📎 Dosya seçmek için tıklayın veya sürükleyip bırakın</p>
                            <p style="color: #9ca3af; font-size: 12px;">Resim (JPG, PNG, GIF) veya Video (MP4, AVI, MOV) formatları desteklenir</p>
                            <p style="color: #9ca3af; font-size: 12px; margin-top: 4px;">Maksimum dosya boyutu: 10 MB</p>
                        </div>
                    </div>
                    <div class="file-list" id="fileList"></div>
                    <div class="file-preview" id="filePreview"></div>
                </div>
                
                <!--- Başvuru Yapan Bilgileri --->
                <h3 style="color: #1e3a8a; margin-top: 32px; margin-bottom: 16px; padding-bottom: 12px; border-bottom: 2px solid #e5e7eb;">Başvuru Yapan Bilgileri</h3>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="adi_soyadi">Adı Soyadı <span class="required">*</span></label>
                        <cfoutput>
                            <input type="text" name="adi_soyadi" id="adi_soyadi" required value="#HTMLEditFormat(session.b2b.partnerName & ' ' & session.b2b.partnerSurname)#">
                        </cfoutput>
                    </div>
                    
                    <div class="form-group">
                        <label for="cep_telefonu">Cep Telefonu <span class="required">*</span></label>
                        <cfoutput>
                            <input type="tel" name="cep_telefonu" id="cep_telefonu" required value="#HTMLEditFormat(session.b2b.partnerMobile)#">
                        </cfoutput>
                    </div>
                    
                    <div class="form-group">
                        <label for="mail_adresi">Mail Adresi <span class="required">*</span></label>
                        <cfoutput>
                            <input type="email" name="mail_adresi" id="mail_adresi" required value="#HTMLEditFormat(session.b2b.partnerEmail)#">
                        </cfoutput>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Başvuruyu Gönder</button>
                    <a href="index.cfm?fuseaction=partner.servis_islemleri" class="btn btn-secondary">İptal</a>
                </div>
            </cfform>
        </div>
    </div>
    
    <script>
        <!--- Karakter sayacı --->
        <cfoutput>
        var konuInput = document.getElementById('konu');
        var konuCount = document.getElementById('konu_count');
        var aciklamaInput = document.getElementById('aciklama');
        var aciklamaCount = document.getElementById('aciklama_count');
        
        // Başvuru tarihi default bugün
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var yyyy = today.getFullYear();
        document.getElementById('basvuru_tarihi').value = yyyy + '-' + mm + '-' + dd;
        
        function updateCharCount(input, countElement, maxLength) {
            var length = input.value.length;
            countElement.textContent = length + ' / ' + maxLength + ' karakter';
            
            if (length > maxLength * 0.9) {
                countElement.className = 'char-count error';
            } else if (length > maxLength * 0.7) {
                countElement.className = 'char-count warning';
            } else {
                countElement.className = 'char-count';
            }
        }
        
        konuInput.addEventListener('input', function() {
            updateCharCount(konuInput, konuCount, 250);
        });
        
        aciklamaInput.addEventListener('input', function() {
            updateCharCount(aciklamaInput, aciklamaCount, 1000);
        });
        
        // İlk yüklemede karakter sayısını göster
        updateCharCount(konuInput, konuCount, 250);
        updateCharCount(aciklamaInput, aciklamaCount, 1000);
        
        // Dosya yükleme işlemleri
        var fileInput = document.getElementById('dosyalar');
        var fileList = document.getElementById('fileList');
        var filePreview = document.getElementById('filePreview');
        var fileUploadArea = document.getElementById('fileUploadArea');
        var selectedFiles = [];
        
        // Drag and drop
        fileUploadArea.addEventListener('dragover', function(e) {
            e.preventDefault();
            fileUploadArea.classList.add('dragover');
        });
        
        fileUploadArea.addEventListener('dragleave', function(e) {
            e.preventDefault();
            fileUploadArea.classList.remove('dragover');
        });
        
        fileUploadArea.addEventListener('drop', function(e) {
            e.preventDefault();
            fileUploadArea.classList.remove('dragover');
            var files = e.dataTransfer.files;
            handleFiles(files);
        });
        
        fileInput.addEventListener('change', function(e) {
            handleFiles(e.target.files);
        });
        
        function handleFiles(files) {
            for (var i = 0; i < files.length; i++) {
                var file = files[i];
                
                // Dosya boyutu kontrolü (10 MB)
                if (file.size > 10 * 1024 * 1024) {
                    alert('Dosya boyutu çok büyük: ' + file.name + ' (Maksimum 10 MB)');
                    continue;
                }
                
                // Dosya tipi kontrolü
                var fileType = file.type;
                var isImage = fileType.startsWith('image/');
                var isVideo = fileType.startsWith('video/');
                
                if (!isImage && !isVideo) {
                    alert('Desteklenmeyen dosya formatı: ' + file.name + ' (Sadece resim ve video dosyaları kabul edilir)');
                    continue;
                }
                
                selectedFiles.push(file);
                addFileToList(file);
                addFilePreview(file);
            }
            
            // File input'u temizle (aynı dosyayı tekrar seçebilmek için)
            fileInput.value = '';
        }
        
        function addFileToList(file) {
            var fileItem = document.createElement('div');
            fileItem.className = 'file-item';
            fileItem.id = 'file-item-' + file.name;
            
            var fileName = document.createElement('span');
            fileName.className = 'file-name';
            fileName.textContent = file.name;
            
            var fileSize = document.createElement('span');
            fileSize.className = 'file-size';
            fileSize.textContent = formatFileSize(file.size);
            
            var fileRemove = document.createElement('span');
            fileRemove.className = 'file-remove';
            fileRemove.textContent = '✕';
            fileRemove.onclick = function() {
                removeFile(file);
            };
            
            fileItem.appendChild(fileName);
            fileItem.appendChild(fileSize);
            fileItem.appendChild(fileRemove);
            fileList.appendChild(fileItem);
        }
        
        function addFilePreview(file) {
            var previewItem = document.createElement('div');
            previewItem.className = 'file-preview-item';
            previewItem.id = 'preview-' + file.name;
            
            var isImage = file.type.startsWith('image/');
            var isVideo = file.type.startsWith('video/');
            
            if (isImage) {
                var img = document.createElement('img');
                img.src = URL.createObjectURL(file);
                previewItem.appendChild(img);
            } else if (isVideo) {
                var video = document.createElement('video');
                video.src = URL.createObjectURL(file);
                video.controls = true;
                previewItem.appendChild(video);
            }
            
            var removeBtn = document.createElement('button');
            removeBtn.className = 'preview-remove';
            removeBtn.textContent = '✕';
            removeBtn.onclick = function() {
                removeFile(file);
            };
            previewItem.appendChild(removeBtn);
            
            filePreview.appendChild(previewItem);
        }
        
        function removeFile(file) {
            // Array'den kaldır
            selectedFiles = selectedFiles.filter(function(f) {
                return f.name !== file.name;
            });
            
            // Listeden kaldır
            var fileItem = document.getElementById('file-item-' + file.name);
            if (fileItem) {
                fileItem.remove();
            }
            
            // Preview'dan kaldır
            var previewItem = document.getElementById('preview-' + file.name);
            if (previewItem) {
                previewItem.remove();
            }
        }
        
        function formatFileSize(bytes) {
            if (bytes === 0) return '0 Bytes';
            var k = 1024;
            var sizes = ['Bytes', 'KB', 'MB', 'GB'];
            var i = Math.floor(Math.log(bytes) / Math.log(k));
            return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
        }
        
        // Form submit edilirken dosyaları ekle
        var form = document.querySelector('form[name="servis_basvuru_form"]');
        form.addEventListener('submit', function(e) {
            // Dosyalar zaten file input'a eklenmiş olacak
            // Eğer selectedFiles array'i kullanılıyorsa, DataTransfer ile eklenebilir
            // Ancak ColdFusion için normal file input yeterli
        });
        </cfoutput>
    </script>
</body>
</html>

