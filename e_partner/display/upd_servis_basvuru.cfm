<!---
    File: upd_servis_basvuru.cfm
    Folder: AddOns/ezgi/e_partner/display
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Servis Başvuru Detay Sayfası
--->
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>B2B Partner Portal - Servis Başvuru Detay</title>
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
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 24px;
        }
        .page-header {
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
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
        .detail-section {
            margin-bottom: 32px;
        }
        .detail-section h3 {
            color: #1e3a8a;
            margin-bottom: 16px;
            padding-bottom: 12px;
            border-bottom: 2px solid #e5e7eb;
            font-size: 18px;
        }
        .detail-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        .detail-item {
            margin-bottom: 16px;
        }
        .detail-item label {
            display: block;
            margin-bottom: 6px;
            color: #6b7280;
            font-weight: 600;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .detail-item .value {
            color: #1f2937;
            font-size: 15px;
            padding: 8px 0;
        }
        .detail-item .value.text-area {
            background: #f9fafb;
            padding: 12px;
            border-radius: 6px;
            border: 1px solid #e5e7eb;
            white-space: pre-wrap;
            line-height: 1.6;
        }
        .status-badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 600;
        }
        .status-pending {
            background: #fef3c7;
            color: #92400e;
        }
        .status-progress {
            background: #dbeafe;
            color: #1e40af;
        }
        .status-completed {
            background: #d1fae5;
            color: #065f46;
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
        .files-gallery {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 16px;
            margin-top: 16px;
        }
        .file-gallery-item {
            position: relative;
            border-radius: 8px;
            overflow: hidden;
            border: 1px solid #e5e7eb;
            background: #f9fafb;
            transition: all 0.2s ease;
        }
        .file-gallery-item:hover {
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transform: translateY(-2px);
        }
        .file-gallery-item img {
            width: 100%;
            height: 200px;
            object-fit: cover;
            display: block;
            cursor: pointer;
        }
        .file-gallery-item video {
            width: 100%;
            height: 200px;
            object-fit: cover;
            display: block;
            cursor: pointer;
        }
        .file-gallery-item .file-info {
            padding: 8px;
            background: #ffffff;
            border-top: 1px solid #e5e7eb;
        }
        .file-gallery-item .file-name {
            font-size: 12px;
            color: #374151;
            font-weight: 500;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            margin-bottom: 4px;
        }
        .file-gallery-item .file-size {
            font-size: 11px;
            color: #6b7280;
        }
        .file-modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.9);
            overflow: auto;
        }
        .file-modal.active {
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .file-modal-content {
            position: relative;
            max-width: 90%;
            max-height: 90%;
            margin: auto;
        }
        .file-modal-content img,
        .file-modal-content video {
            max-width: 100%;
            max-height: 90vh;
            display: block;
            margin: 0 auto;
        }
        .file-modal-close {
            position: absolute;
            top: 20px;
            right: 30px;
            color: #ffffff;
            font-size: 40px;
            font-weight: bold;
            cursor: pointer;
            background: rgba(0, 0, 0, 0.5);
            border-radius: 50%;
            width: 50px;
            height: 50px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s ease;
        }
        .file-modal-close:hover {
            background: rgba(0, 0, 0, 0.8);
        }
        @media (max-width: 768px) {
            .navbar-menu {
                flex-wrap: wrap;
            }
            .navbar-menu a {
                padding: 12px 16px;
                font-size: 13px;
            }
            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 16px;
            }
            .detail-row {
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
        <!--- Başvuru detaylarını getir --->
        <cfinclude template="../query/get_servis_basvuru_detail.cfm">
        
        <div class="page-header">
            <div>
                <h2>🔧 Servis Başvuru Detay</h2>
                <p>Başvuru No: <cfoutput>#HTMLEditFormat(get_basvuru_detail.BASVURU_NO)#</cfoutput></p>
            </div>
            <a href="index.cfm?fuseaction=partner.servis_islemleri" class="btn btn-secondary">← Geri Dön</a>
        </div>
        
        <!--- Hata/Başarı Mesajları --->
        <cfif isDefined("url.error") and len(url.error)>
            <div class="error-message">
                <cfoutput>#HTMLEditFormat(url.error)#</cfoutput>
            </div>
        </cfif>
        <cfif isDefined("url.success") and len(url.success)>
            <div class="success-message" style="background: #d1fae5; color: #065f46; padding: 12px; border-radius: 6px; margin-bottom: 20px; border-left: 4px solid #10b981;">
                <cfoutput>#HTMLEditFormat(url.success)#</cfoutput>
            </div>
        </cfif>
        
        <div class="content-card">
            <cfoutput query="get_basvuru_detail">
                <!--- Başvuru Bilgileri --->
                <div class="detail-section">
                    <h3>Başvuru Bilgileri</h3>
                    <div class="detail-row">
                        <div class="detail-item">
                            <label>Başvuru No</label>
                            <div class="value">#HTMLEditFormat(BASVURU_NO)#</div>
                        </div>
                        <div class="detail-item">
                            <label>Başvuru Tarihi</label>
                            <div class="value">#dateformat(BASVURU_TARIHI, 'dd.mm.yyyy')#</div>
                        </div>
                        <div class="detail-item">
                            <label>Kategori</label>
                            <div class="value">#HTMLEditFormat(KATEGORI_ADI)#</div>
                        </div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-item">
                            <label>Öncelik</label>
                            <div class="value">#HTMLEditFormat(oncelik_adi)#</div>
                        </div>
                        <div class="detail-item">
                            <label>İletişim Şekli</label>
                            <div class="value">#HTMLEditFormat(iletisim_sekli_adi)#</div>
                        </div>
                        <div class="detail-item">
                            <label>Durum</label>
                            <div class="value">
                                <cfif durum eq "Beklemede">
                                    <span class="status-badge status-pending">#durum#</span>
                                <cfelseif durum eq "Devam Ediyor">
                                    <span class="status-badge status-progress">#durum#</span>
                                <cfelseif durum eq "Tamamlandı">
                                    <span class="status-badge status-completed">#durum#</span>
                                <cfelse>
                                    <span class="status-badge status-pending">#durum#</span>
                                </cfif>
                            </div>
                        </div>
                    </div>
                    <div class="detail-item">
                        <label>Konu</label>
                        <div class="value">#HTMLEditFormat(KONU)#</div>
                    </div>
                    <div class="detail-item">
                        <label>Açıklama</label>
                        <div class="value text-area">#HTMLEditFormat(ACIKLAMA)#</div>
                    </div>
                </div>
                
                <!--- Yüklenen Dosyalar --->
                <div class="detail-section">
                    <h3>Yüklenen Dosyalar</h3>
                    <cfif isDefined("get_service_files") and get_service_files.recordcount gt 0>
                        <div class="files-gallery">
                            <cfoutput query="get_service_files">
                                <div class="file-gallery-item">
                                    <cfif IS_IMAGE eq 1>
                                        <img src="/#FILE_PATH#" alt="#HTMLEditFormat(FILE_NAME)#" onclick="openFileModal('/#FILE_PATH#', '#HTMLEditFormat(FILE_NAME)#', 'image')">
                                    <cfelseif IS_VIDEO eq 1>
                                        <video controls onclick="openFileModal('/#FILE_PATH#', '#HTMLEditFormat(FILE_NAME)#', 'video')">
                                            <source src="/#FILE_PATH#" type="#FILE_TYPE#">
                                            Tarayıcınız video oynatmayı desteklemiyor.
                                        </video>
                                    </cfif>
                                    <div class="file-info">
                                        <div class="file-name" title="#HTMLEditFormat(FILE_NAME)#">#HTMLEditFormat(FILE_NAME)#</div>
                                        <div class="file-size">
                                            <cfif FILE_SIZE lt 1024>
                                                #FILE_SIZE# B
                                            <cfelseif FILE_SIZE lt 1048576>
                                                #numberFormat(FILE_SIZE / 1024, "0.00")# KB
                                            <cfelse>
                                                #numberFormat(FILE_SIZE / 1048576, "0.00")# MB
                                            </cfif>
                                        </div>
                                    </div>
                                </div>
                            </cfoutput>
                        </div>
                    <cfelse>
                        <div style="padding: 20px; text-align: center; color: ##6b7280; background: ##f9fafb; border-radius: 6px; border: 1px dashed ##d1d5db;">
                            <p>Bu başvuru için henüz dosya yüklenmemiş.</p>
                        </div>
                    </cfif>
                </div>
                
                <!--- Başvuru Yapan Bilgileri --->
                <div class="detail-section">
                    <h3>Başvuru Yapan Bilgileri</h3>
                    <div class="detail-row">
                        <div class="detail-item">
                            <label>Adı Soyadı</label>
                            <div class="value">#HTMLEditFormat(ADI_SOYADI)#</div>
                        </div>
                        <div class="detail-item">
                            <label>Cep Telefonu</label>
                            <div class="value">#HTMLEditFormat(CEP_TELEFONU)#</div>
                        </div>
                        <div class="detail-item">
                            <label>Mail Adresi</label>
                            <div class="value">#HTMLEditFormat(MAIL_ADRESI)#</div>
                        </div>
                    </div>
                </div>
            </cfoutput>
            
            <!--- Dosya Ekleme Bölümü --->
            <div class="detail-section">
                <h3>Yeni Dosya Ekle</h3>
                <cfform name="add_file_form" method="post" action="index.cfm?fuseaction=partner.add_servis_basvuru_file" enctype="multipart/form-data">
                    <input type="hidden" name="basvuru_id" value="<cfoutput>#get_basvuru_detail.BASVURU_ID#</cfoutput>">
                    <input type="hidden" name="is_submitted" value="1">
                    
                    <div class="file-upload-area" id="fileUploadArea" style="margin-bottom: 16px;">
                        <input type="file" name="dosya" id="dosya" accept="image/*,video/*" style="display: none;">
                        <div style="cursor: pointer;" onclick="document.getElementById('dosya').click();">
                            <p style="color: ##6b7280; margin-bottom: 8px;">📎 Dosya seçmek için tıklayın veya sürükleyip bırakın</p>
                            <p style="color: ##9ca3af; font-size: 12px;">Resim (JPG, PNG, GIF) veya Video (MP4, AVI, MOV) formatları desteklenir</p>
                            <p style="color: ##9ca3af; font-size: 12px; margin-top: 4px;">Maksimum dosya boyutu: 10 MB</p>
                        </div>
                    </div>
                    <div class="file-list" id="fileList"></div>
                    <div class="file-preview" id="filePreview"></div>
                    
                    <div style="margin-top: 16px;">
                        <button type="submit" class="btn btn-primary">Dosyayı Yükle</button>
                    </div>
                </cfform>
            </div>
        </div>
    </div>
    
    <!--- Dosya Modal (Büyük Görüntüleme) --->
    <div id="fileModal" class="file-modal">
        <span class="file-modal-close" onclick="closeFileModal()">&times;</span>
        <div class="file-modal-content" id="fileModalContent"></div>
    </div>
    
    <script>
        function openFileModal(filePath, fileName, fileType) {
            var modal = document.getElementById('fileModal');
            var modalContent = document.getElementById('fileModalContent');
            
            modalContent.innerHTML = '';
            
            if (fileType === 'image') {
                var img = document.createElement('img');
                img.src = filePath;
                img.alt = fileName;
                modalContent.appendChild(img);
            } else if (fileType === 'video') {
                var video = document.createElement('video');
                video.controls = true;
                video.autoplay = true;
                var source = document.createElement('source');
                source.src = filePath;
                source.type = 'video/mp4';
                video.appendChild(source);
                modalContent.appendChild(video);
            }
            
            modal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        
        function closeFileModal() {
            var modal = document.getElementById('fileModal');
            var modalContent = document.getElementById('fileModalContent');
            
            modal.classList.remove('active');
            modalContent.innerHTML = '';
            document.body.style.overflow = 'auto';
        }
        
        // ESC tuşu ile modal'ı kapat
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeFileModal();
            }
        });
        
        // Modal dışına tıklanınca kapat
        document.getElementById('fileModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeFileModal();
            }
        });
        
        // Dosya yükleme işlemleri (Yeni Dosya Ekle bölümü için)
        var fileInputAdd = document.getElementById('dosya');
        var fileListAdd = document.getElementById('fileList');
        var filePreviewAdd = document.getElementById('filePreview');
        var fileUploadAreaAdd = document.getElementById('fileUploadArea');
        var selectedFileAdd = null;
        
        if (fileInputAdd && fileUploadAreaAdd) {
            // Drag and drop
            fileUploadAreaAdd.addEventListener('dragover', function(e) {
                e.preventDefault();
                fileUploadAreaAdd.classList.add('dragover');
            });
            
            fileUploadAreaAdd.addEventListener('dragleave', function(e) {
                e.preventDefault();
                fileUploadAreaAdd.classList.remove('dragover');
            });
            
            fileUploadAreaAdd.addEventListener('drop', function(e) {
                e.preventDefault();
                fileUploadAreaAdd.classList.remove('dragover');
                var files = e.dataTransfer.files;
                if (files.length > 0) {
                    handleFileAdd(files[0]);
                }
            });
            
            fileInputAdd.addEventListener('change', function(e) {
                if (e.target.files.length > 0) {
                    handleFileAdd(e.target.files[0]);
                }
            });
            
            function handleFileAdd(file) {
                // Dosya boyutu kontrolü (10 MB)
                if (file.size > 10 * 1024 * 1024) {
                    alert('Dosya boyutu çok büyük: ' + file.name + ' (Maksimum 10 MB)');
                    return;
                }
                
                // Dosya tipi kontrolü
                var fileType = file.type;
                var isImage = fileType.startsWith('image/');
                var isVideo = fileType.startsWith('video/');
                
                if (!isImage && !isVideo) {
                    alert('Desteklenmeyen dosya formatı: ' + file.name + ' (Sadece resim ve video dosyaları kabul edilir)');
                    return;
                }
                
                selectedFileAdd = file;
                addFileToListAdd(file);
                addFilePreviewAdd(file);
            }
            
            function addFileToListAdd(file) {
                fileListAdd.innerHTML = '';
                var fileItem = document.createElement('div');
                fileItem.className = 'file-item';
                
                var fileName = document.createElement('span');
                fileName.className = 'file-name';
                fileName.textContent = file.name;
                
                var fileSize = document.createElement('span');
                fileSize.className = 'file-size';
                fileSize.textContent = formatFileSizeAdd(file.size);
                
                var fileRemove = document.createElement('span');
                fileRemove.className = 'file-remove';
                fileRemove.textContent = '✕';
                fileRemove.onclick = function() {
                    removeFileAdd();
                };
                
                fileItem.appendChild(fileName);
                fileItem.appendChild(fileSize);
                fileItem.appendChild(fileRemove);
                fileListAdd.appendChild(fileItem);
            }
            
            function addFilePreviewAdd(file) {
                filePreviewAdd.innerHTML = '';
                var previewItem = document.createElement('div');
                previewItem.className = 'file-preview-item';
                
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
                    removeFileAdd();
                };
                previewItem.appendChild(removeBtn);
                
                filePreviewAdd.appendChild(previewItem);
            }
            
            function removeFileAdd() {
                selectedFileAdd = null;
                fileListAdd.innerHTML = '';
                filePreviewAdd.innerHTML = '';
                fileInputAdd.value = '';
            }
            
            function formatFileSizeAdd(bytes) {
                if (bytes === 0) return '0 Bytes';
                var k = 1024;
                var sizes = ['Bytes', 'KB', 'MB', 'GB'];
                var i = Math.floor(Math.log(bytes) / Math.log(k));
                return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
            }
            
            // Form submit kontrolü
            var addFileForm = document.querySelector('form[name="add_file_form"]');
            if (addFileForm) {
                addFileForm.addEventListener('submit', function(e) {
                    if (!selectedFileAdd && (!fileInputAdd.files || fileInputAdd.files.length === 0)) {
                        e.preventDefault();
                        alert('Lütfen bir dosya seçin.');
                        return false;
                    }
                });
            }
        }
    </script>
</body>
</html>

