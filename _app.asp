<%'/*
'**********************************************
'      /\      | (_)
'     /  \   __| |_  __ _ _ __  ___
'    / /\ \ / _` | |/ _` | '_ \/ __|
'   / ____ \ (_| | | (_| | | | \__ \
'  /_/    \_\__,_| |\__,_|_| |_|___/
'               _/ | Digital Agency
'              |__/
'**********************************************
'* Project  : RabbitCMS
'* Developer: <Anthony Burak DURSUN>
'* E-Mail   : badursun@adjans.com.tr
'* Corp     : https://adjans.com.tr
'**********************************************
' LAST UPDATE: 28.10.2022 15:33 @badursun
'**********************************************
'*/
Const YesOverWrite 	= 2
Const NoOverWrite 	= 1

Class TinyJPG_Plugin
	'/*
	'---------------------------------------------------------------
	' REQUIRED: Plugin Variables
	'---------------------------------------------------------------
	'*/
	Private PLUGIN_CODE, PLUGIN_DB_NAME, PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_CREDITS, PLUGIN_GIT, PLUGIN_DEV_URL, PLUGIN_FILES_ROOT, PLUGIN_ICON, PLUGIN_REMOVABLE, PLUGIN_ROOT, PLUGIN_FOLDER_NAME, PLUGIN_AUTOLOAD
	'/*
	'---------------------------------------------------------------
	' REQUIRED: Plugin Variables
	'---------------------------------------------------------------
	'*/
	Private FULL_SITE_URL, API_ENCRYPTED, TinifySaveWith, API_COMPRESS_LIMIT, MODULE_ID
	Private TinifySecret, TinifyStatus, FailReason, ProtectOriginalFile, APISuccessRatio
	Private FileSize, FilePath, FileName, FileExtension
	Private AllowedExtensionList, FileURLAddress, APIMonthlyCounter
	Private APIResponse, APIStatus, APISuccessFileURL, APISuccessFileSize
	'/*
	'---------------------------------------------------------------
	' REQUIRED: Register Class
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	' REQUIRED: Register Class
	'---------------------------------------------------------------
	'*/
	Public Property Get class_register()
		DebugTimer ""& PLUGIN_CODE &" class_register() Start"
		'/*
		'---------------------------------------------------------------
		' Check Register
		'---------------------------------------------------------------
		'*/
		If CheckSettings("PLUGIN:"& PLUGIN_CODE &"") = True Then 
			DebugTimer ""& PLUGIN_CODE &" class_registered"
			Exit Property
		End If
		'/*
		'---------------------------------------------------------------
		' Plugin Database
		'---------------------------------------------------------------
		'*/
		Dim PluginTableName
			PluginTableName = "tbl_plugin_" & PLUGIN_DB_NAME
    	
    	If TableExist(PluginTableName) = False Then
			DebugTimer ""& PLUGIN_CODE &" table creating"
    		
    		Conn.Execute("SET NAMES utf8mb4;") 
    		Conn.Execute("SET FOREIGN_KEY_CHECKS = 0;") 
    		
    		Conn.Execute("DROP TABLE IF EXISTS `"& PluginTableName &"`")

    		q="CREATE TABLE `"& PluginTableName &"` ( "
    		q=q+"  `ID` int(11) NOT NULL AUTO_INCREMENT, "
    		q=q+"  `FILENAME` varchar(255) DEFAULT NULL, "
    		q=q+"  `FULL_PATH` varchar(255) DEFAULT NULL, "
    		q=q+"  `COMPRESS_DATE` datetime DEFAULT NULL, "
    		q=q+"  `COMPRESS_RATIO` double(255,0) DEFAULT NULL, "
    		q=q+"  `ORIGINAL_FILE_SIZE` bigint(20) DEFAULT 0, "
    		q=q+"  `COMPRESSED_FILE_SIZE` bigint(20) DEFAULT 0, "
    		q=q+"  `EARNED_SIZE` bigint(20) DEFAULT 0, "
    		q=q+"  `ORIGINAL_PROTECTED` int(1) DEFAULT 0, "
    		q=q+"  PRIMARY KEY (`ID`), "
    		q=q+"  KEY `IND1` (`FILENAME`) "
    		q=q+") ENGINE=MyISAM DEFAULT CHARSET=utf8; "
			Conn.Execute(q)

    		Conn.Execute("SET FOREIGN_KEY_CHECKS = 1;") 

			' Create Log
			'------------------------------
    		Call PanelLog(""& PLUGIN_CODE &" için database tablosu oluşturuldu", 0, ""& PLUGIN_CODE &"", 0)

			' Register Settings
			'------------------------------
			DebugTimer ""& PLUGIN_CODE &" class_register() End"
    	End If
		'/*
		'---------------------------------------------------------------
		' Plugin Settings
		'---------------------------------------------------------------
		'*/
		a=GetSettings("PLUGIN:"& PLUGIN_CODE &"", PLUGIN_CODE&"_")
		a=GetSettings(""&PLUGIN_CODE&"_PLUGIN_NAME", PLUGIN_NAME)
		a=GetSettings(""&PLUGIN_CODE&"_CLASS", "TinyJPG-Plugin")
		a=GetSettings(""&PLUGIN_CODE&"_REGISTERED", ""& Now() &"")
		a=GetSettings(""&PLUGIN_CODE&"_CODENO", "0")
		a=GetSettings(""&PLUGIN_CODE&"_FOLDER", PLUGIN_FOLDER_NAME)
		'/*
		'---------------------------------------------------------------
		' Register Settings
		'---------------------------------------------------------------
		'*/
		a=GetSettings(""&PLUGIN_CODE&"_SECRET", "")
		a=GetSettings(""&PLUGIN_CODE&"_ACTIVE", "0")
		a=GetSettings(""&PLUGIN_CODE&"_SAVEWITH", "ADODB")
		a=GetSettings(""&PLUGIN_CODE&"_PROTECTORIGINAL", "1")
		a=GetSettings(""&PLUGIN_CODE&"_ALLOWEDEXTENSION", "jpg,jpeg,png")
		a=GetSettings(""&PLUGIN_CODE&"_PLAN_LIMIT", "500")
		a=GetSettings(""&PLUGIN_CODE&"_ACTIVE_LIMIT", "0")
		a=GetSettings(""&PLUGIN_CODE&"_APITYPE", "0")
		a=GetSettings("IMG_PROCESS_THUMBNAIL_TINIFY", "0")
		a=GetSettings("IMG_PROCESS_MEDIUM_TINIFY", "0")
		a=GetSettings("IMG_PROCESS_FULL_TINIFY", "0")

		DebugTimer ""& PLUGIN_CODE &" class_register() End"
	End Property
	'/*
	'---------------------------------------------------------------
	' REQUIRED: Register Class End
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	' REQUIRED: Plugin Settings Panel
	'---------------------------------------------------------------
	'*/
	Public sub LoadPanel()
		'/*
		'--------------------------------------------------------
		' Sub Page
		'--------------------------------------------------------
		'*/
		If Query.Data("Page") = "SHOW:DemoCompress" Then 
			Call PluginPage("Header")
			
			Dim TestFileURL
				TestFileURL = PLUGIN_ROOT & "dist/test-images/a2fe21da9ce7d1698f5b48cdb506c853.jpg"
			
			Dim Sonuc
				Sonuc = Compress(TestFileURL)

			With Response 
				.Write "<style>dt, dd {word-break: break-all !important;}</style>"
				.Write "<div class=""row"">"
				.Write "	<div class=""col-lg-6 col-6"">"
				.Write "		<h6>Orjinal Görsel ("& BoyutHesapla( OriginalFileSize() ) &")</h6>"
				.Write "		<img src="""& TestFileURL &""" class=""img-fluid"" />"
				.Write "	</div>"
				.Write "	<div class=""col-lg-6 col-6"">"
				.Write "		<h6>Sıkıştırılmış Görsel ("& BoyutHesapla( CompressedFileSize() ) &")</h6>"
				.Write "		<img src="""& CompressedFileLocalURL() &""" class=""img-fluid"" />"
				.Write "	</div>"
				.Write "</div>"
				.Write "<div class=""row"">"
				.Write "	<div class=""col-lg-6 col-6"">"
				.Write "		<dl class=""row"">"
				.Write "			<dt class=""col-lg-4 col-4"">Local URL (String):</dt> <dd class=""col-lg-8 col-8"">"& CompressedFileLocalURL() &"</dd>"
				' .Write "			<dt class=""col-lg-4 col-4"">File URL (String):</dt> <dd class=""col-lg-8 col-8"">"& OriginalFileURL() &"</dd>"
				.Write "			<dt class=""col-lg-4 col-4"">File Extension (String):</dt> <dd class=""col-lg-8 col-8"">"& OriginalFileExtension() &"</dd>"
				.Write "			<dt class=""col-lg-4 col-4"">File Path (String):</dt> <dd class=""col-lg-8 col-8"">"& OriginalFilePath() &"</dd>"
				.Write "			<dt class=""col-lg-4 col-4"">File Size (String):</dt> <dd class=""col-lg-8 col-8"">"& OriginalFileSize() &" byte - "& BoyutHesapla( OriginalFileSize() ) &"</dd>"
				.Write "		</dl>"
				.Write "	</div>"
				.Write "	<div class=""col-lg-6 col-6"">"
				.Write "		<dl class=""row"">"
				.Write "			<dt class=""col-lg-4 col-4"">Remote URL (String):</dt> <dd class=""col-lg-8 col-8"">"& CompressedFileRemoteURL() &"</dd>"
				.Write "			<dt class=""col-lg-4 col-4"">File Size (Byte):</dt> <dd class=""col-lg-8 col-8"">"& CompressedFileSize() &"</dd>"
				.Write "			<dt class=""col-lg-4 col-4"">File Size (Byte):</dt> <dd class=""col-lg-8 col-8"">"& BoyutHesapla( CompressedFileSize() ) &"</dd>"
				.Write "			<dt class=""col-lg-4 col-4"">Ratio (Double):</dt> <dd class=""col-lg-8 col-8"">"& CompressRatio() &"</dd>"
				.Write "			<dt class=""col-lg-4 col-4"">Earned Size:</dt> <dd class=""col-lg-8 col-8"">"& EarnedSize() &" byte - "& BoyutHesapla( EarnedSize() ) &"</dd>"
				.Write "		</dl>"
				.Write "	</div>"
				.Write "	<div class=""col-lg-12 col-12"">"
				.Write "		<h3>Sonuç: "& Sonuc &"</h3>"
				.Write "		<strong>Process Status (String):</strong> "& Sonuc &"<br/>"
				.Write "		<strong>Allowed Extensions (Array):</strong> "& Join(AllowedExtensions(), ",") &"<br/>"
				.Write "		<strong>Protect Original File (Boolean):</strong> "& ProtectOriginal() &"<br/>"
				.Write "		<strong>This Month Total Compress (String):</strong> "& TotalMonthCompress() &"<br/>"
				.Write "		<strong>Debug (String):</strong> "& Debug() &"<br/>"
				.Write "	</div>"
				.Write "</div>"
			End With
			
			Call PluginPage("Footer")
			Call SystemTeardown("destroy")
		End If
		'/*
		'--------------------------------------------------------
		' Sub Page
		'--------------------------------------------------------
		'*/
		If Query.Data("Page") = "SHOW:ResetStats" Then
			Conn.Execute("TRUNCATE tbl_plugin_tinify")
			' SetSettings "TINIFY_PLUGIN_APITYPE", "0"
			SetSettings "TINIFY_PLUGIN_PLAN_LIMIT", "500"
			SetSettings "TINIFY_PLUGIN_ACTIVE_LIMIT", "0"

			Call PluginPage("Header")

			With Response 
				.Write "<div class=""alert alert-success cms-style"">"
				.Write "	<strong>İşlem Başarılı</strong>"
				.Write "	<p>İstatistikler ve Kayıtlar Sıfırlandı</p>"
				.Write "</div>"
			End With

			Call PluginPage("Footer")
			Call SystemTeardown("destroy")
		End If
		'/*
		'--------------------------------------------------------
		' Sub Page
		'--------------------------------------------------------
		'*/
		If Query.Data("Page") = "SHOW:ListAllTinified" Then
			Call PluginPage("Header")

			With Response 
				.Write "<div class=""table-responsive"">"
				.Write "	<table class=""table table-striped table-bordered"">"
				.Write "		<thead>"
				.Write "			<tr>"
				.Write "				<th>Fotograf</th>"
				.Write "				<th>İşlem Tarihi</th>"
				.Write "				<th>Orjinal Boyut</th>"
				.Write "				<th>Yeni Boyut</th>"
				.Write "				<th>Tasarruf</th>"
				.Write "				<th>Sıkıştırma Oranı</th>"
				.Write "				<th>Orjinali Korunuyor</th>"
				.Write "			</tr>"
				.Write "		</thead>"
				.Write "		<tbody>"
				Set Siteler = Conn.Execute("SELECT * FROM tbl_plugin_tinify ORDER BY ID DESC")
				If Siteler.Eof Then 
					.Write "	<tr>"
					.Write "		<td colspan=""8"" align=""center""><p>İşlem Geçmişi Bulunamadı</p></td>"
					.Write "	</tr>"
				End If
				Do While Not Siteler.Eof
				.Write "			<tr>"
				.Write "				<td>"& Siteler("FILENAME") &"</td>"
				.Write "				<td>"& Siteler("COMPRESS_DATE") &"</td>"
				.Write "				<td align=""right"">"& BoyutHesapla( CLng(Siteler("ORIGINAL_FILE_SIZE")) ) &"</td>"
				.Write "				<td align=""right"">"& BoyutHesapla( CLng(Siteler("COMPRESSED_FILE_SIZE")) ) &"</td>"
				.Write "				<td align=""right"">"& BoyutHesapla( CLng(Siteler("EARNED_SIZE")) ) &"</td>"
				.Write "				<td align=""center"">1:"& Siteler("COMPRESS_RATIO") &"</td>"
				.Write "				<td>"& EvetHayir( Siteler("ORIGINAL_PROTECTED") ) &"</td>"
				.Write "				<td align=""right"">"
				.Write "					<div class=""btn-group btn-group-sm"">"
				.Write "						<a href="""& Siteler("FULL_PATH") &""" download class=""btn btn-sm btn-warning"">İndir</a>"
				.Write "						<a href="""& Siteler("FULL_PATH") &""" target=""_blank"" class=""btn btn-sm btn-success"">Göster</a>"
				.Write "					</div>"
				.Write "				</td>"
				.Write "			</tr>"
				Siteler.MoveNext : Loop
				Siteler.Close : Set Siteler = Nothing
				.Write "		</tbody>"
				.Write "	</table>"
				.Write "</div>"
			End With

			Call PluginPage("Footer")
			Call SystemTeardown("destroy")
		End If
		'/*
		'--------------------------------------------------------
		' Main Page
		'--------------------------------------------------------
		'*/
		With Response
			'------------------------------------------------------------------------------------------
				PLUGIN_PANEL_MASTER_HEADER This()
			'------------------------------------------------------------------------------------------
			.Write "<div class=""row"">"
			.Write "    <div class=""col-lg-4 col-sm-12"">"
			.Write 			QuickSettings("checkbox", ""& PLUGIN_CODE &"_PROTECTORIGINAL", "Orjinal Dosyayı Sakla", "", TO_DB)
			.Write "    </div>"
			.Write "    <div class=""col-lg-4 col-12"">"
			.Write 			QuickSettings("select", ""& PLUGIN_CODE &"_APITYPE", "Üyelik Türü", "0#Ücretsiz|1#Ücretli", TO_DB)
			.Write "    </div>"
			.Write "    <div class=""col-lg-4 col-12"">"
			.Write 			QuickSettings("input", ""& PLUGIN_CODE &"_SECRET", "API Anahtarı", "", TO_DB)
			.Write "    </div>"
			.Write "    <div class=""col-lg-3 col-12"">"
			.Write 			QuickSettings("input", ""& PLUGIN_CODE &"_PLAN_LIMIT", "Aylık Limit (Free 500 Adettir)", "", TO_DB)
			.Write "    </div>"
			.Write "    <div class=""col-lg-3 col-12"">"
			.Write 			QuickSettings("select", ""& PLUGIN_CODE &"_SAVEWITH", "Fiziksel Dosya Kayıt İstemcisi", "ADODB#ADODB|ASPJPEG#ASPJPEG", TO_DB)
			.Write "    </div>"
			.Write "    <div class=""col-lg-6 col-sm-12"">"
			.Write 			QuickSettings("tag", ""& PLUGIN_CODE &"_ALLOWEDEXTENSION", "Kullanılabilir Uzantılar", "", TO_DB)
			.Write "    </div>"
			.Write "</div>"

			.Write "<div class=""row"">"
			.Write "        <div class=""col-lg-12 col-12""><h5>Tinify Uygulanacak Boyutlar</h5></div>"
			.Write "        <div class=""col-lg-4 col-sm-12 col-12"">"
			.Write "            <div class=""row"">"
			.Write "                <div class=""col-lg-12 col-12"">Thumbnail</div>"
			.Write "                <div class=""col-lg-12 col-12"" "& popover("Aktif edilirse Sıkıştırma oranı geçersiz sayılır, Plugin tarafından maksimum sıkıştırma varsayılandır.") &">"
			.Write 						QuickSettings("checkbox", "IMG_PROCESS_THUMBNAIL_TINIFY", "Tinify Sıkıştırması Aktif", "", TO_DB)
			.Write "                </div>"
			.Write "            </div>"
			.Write "        </div>"
			.Write "        <div class=""col-lg-4 col-sm-12 col-12"">"
			.Write "            <div class=""row"">"
			.Write "                <div class=""col-lg-12 col-12"">Medium</div>"
			.Write "                <div class=""col-lg-12 col-12"" "& popover("Aktif edilirse Sıkıştırma oranı geçersiz sayılır, Plugin tarafından maksimum sıkıştırma varsayılandır.") &">"
			.Write  					QuickSettings("checkbox", "IMG_PROCESS_MEDIUM_TINIFY", "Tinify Sıkıştırması Aktif", "", TO_DB)
			.Write "                </div>"
			.Write "            </div>"
			.Write "        </div>"
			.Write "        <div class=""col-lg-4 col-sm-12 col-12"">"
			.Write "            <div class=""row"">"
			.Write "                <div class=""col-lg-12 col-12"">Full</div>"
			.Write "                <div class=""col-lg-12 col-12"" "& popover("Aktif edilirse Sıkıştırma oranı geçersiz sayılır, Plugin tarafından maksimum sıkıştırma varsayılandır.") &">"
			.Write 						QuickSettings("checkbox", "IMG_PROCESS_FULL_TINIFY", "Tinify Sıkıştırması Aktif", "", TO_DB)
			.Write "                </div>"
			.Write "            </div>"
			.Write "        </div>"
			.Write "    </div>"

			Set TinifyRS = Conn.Execute("SELECT IFNULL(COUNT(ID), 0) AS TOPLAM_GORSEL, IFNULL(SUM(ORIGINAL_FILE_SIZE),0) AS ORJINAL_TOPLAM_BOYUT, IFNULL(SUM(COMPRESSED_FILE_SIZE),0) AS SIKISTIRILAN_TOPLAM_BOYUT, IFNULL(SUM(EARNED_SIZE),0) AS TASARRUF FROM tbl_plugin_tinify")

				' tmp_toplam_gorsel   = TinifyRS("TOPLAM_GORSEL").value
				tmp_toplam_yukleme  = CLng( TinifyRS("ORJINAL_TOPLAM_BOYUT").value )
				tmp_degisen_alan 	= CLng( TinifyRS("SIKISTIRILAN_TOPLAM_BOYUT").value )
				tmp_toplam_tasarruf = CLng( TinifyRS("TASARRUF").value )
			TinifyRS.Close : Set TinifyRS = Nothing

			Set KacKredi = Conn.Execute("SELECT COUNT(ID) FROM tbl_plugin_tinify WHERE MONTH(COMPRESS_DATE) = MONTH(CURRENT_DATE()) AND YEAR(COMPRESS_DATE) = YEAR(CURRENT_DATE())")
				AylikKredi 		= Cint( GetSettings("TINIFY_PLUGIN_PLAN_LIMIT", "500") )
				CreditCount 	= Cint( GetSettings("TINIFY_PLUGIN_ACTIVE_LIMIT", "0") ) 
				BuAyKullanilan 	= Cint( KacKredi(0).value )
			KacKredi.Close : Set KacKredi = Nothing

			.Write "<div class=""col-lg-12 col-12"">"
			.Write "	<table class=""table table-striped table-bordered"">"
			.Write "		<tr>"
			.Write "			<td width=""30%""><strong>Kredi Kullanımı</strong></td>"
			.Write "			<td>"& ReturnMonth( Month(Now()) ) &"&nbsp;"& Year(Now()) &" İçin "& AylikKredi &" Krediden "& BuAyKullanilan &" Adet Kullanıldı</td>"
			.Write "		</tr>"
			.Write "		<tr>"
			.Write "			<td><strong>API Credit-Count</strong></td>"
			.Write "			<td>"& CreditCount &" Compression This Month</td>"
			.Write "		</tr>"
			.Write "		<tr>"
			.Write "			<td colspan=""2"" align=""center"">"
			.Write "				<strong>Toplam Yüklenen Boyut</strong> "& BoyutHesapla( tmp_toplam_yukleme ) &", "
			.Write "				<strong>Toplam Tasarruf</strong> "& BoyutHesapla( tmp_degisen_alan ) &", "
			.Write "				<strong>Toplam Kazanılan Tasarruf</strong> "& BoyutHesapla( tmp_toplam_tasarruf ) &""
			.Write "			</td>"
			.Write "		</tr>"
			.Write "	</table>"
			.Write "</div>"

			.Write "<div class=""row"">"
			.Write "    <div class=""col-lg-12 col-12"">"
			.Write "        <a href=""https://tinypng.com/developers"" target=""_blank"" class=""btn btn-sm btn-primary"">"
			.Write "        	API Al &amp; Hakkında"
			.Write "        </a>"
			.Write "        <a href=""https://tinypng.com/developers/reference"" target=""_blank"" class=""btn btn-sm btn-primary"">"
			.Write "        	API Referans"
			.Write "        </a>"
			.Write "        <a open-iframe href=""ajax.asp?Cmd=PluginSettings&PluginName="& PLUGIN_CODE &"&Page=SHOW:ListAllTinified"" class=""btn btn-sm btn-primary"">"
			.Write "        	Tüm Dosyaları Göster"
			.Write "        </a>"
			.Write "        <a open-iframe href=""ajax.asp?Cmd=PluginSettings&PluginName="& PLUGIN_CODE &"&Page=SHOW:ResetStats"" class=""btn btn-sm btn-danger"">"
			.Write "        	İstatistikleri Sıfırla"
			.Write "        </a>"
			.Write "        <a open-iframe href=""ajax.asp?Cmd=PluginSettings&PluginName="& PLUGIN_CODE &"&Page=SHOW:DemoCompress"" class=""btn btn-sm btn-warning"">"
			.Write "        	Demo Çalıştır"
			.Write "        </a>"
			.Write "    </div>"
			.Write "</div>"
		End With
	End Sub
	'/*
	'---------------------------------------------------------------
	' REQUIRED: Plugin Settings Panel
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	' REQUIRED: Plugin Class Initialize
	'---------------------------------------------------------------
	'*/
	Private Sub class_initialize()
		'/*
		'-----------------------------------------------------------------------------------
		' REQUIRED: PluginTemplate Main Variables
		'-----------------------------------------------------------------------------------
		'*/
    	PLUGIN_CODE  			= "TINIFY_PLUGIN"
    	PLUGIN_NAME 			= "TinyJPG Plugin"
    	PLUGIN_VERSION 			= "1.0.0"
    	PLUGIN_GIT 				= "https://github.com/RabbitCMS-Hub/TinyJPG-Plugin"
    	PLUGIN_DEV_URL 			= "https://adjans.com.tr"
    	PLUGIN_ICON 			= "zmdi-wallpaper"
    	PLUGIN_CREDITS 			= "@badursun Anthony Burak DURSUN"
    	PLUGIN_FOLDER_NAME 		= "TinyJPG-Plugin"
    	PLUGIN_DB_NAME 			= "tinify"
    	PLUGIN_REMOVABLE 		= True
    	PLUGIN_AUTOLOAD 		= True
    	PLUGIN_ROOT 			= PLUGIN_DIST_FOLDER_PATH(This)
    	PLUGIN_FILES_ROOT 		= PLUGIN_VIRTUAL_FOLDER(This)
		'/*
    	'-------------------------------------------------------------------------------------
    	' Plugin Main Variables
    	'-------------------------------------------------------------------------------------
		'*/
		MODULE_ID 			= GetSettings(""& PLUGIN_CODE &"_CODENO", "666")
		TinifySecret 		= GetSettings(""& PLUGIN_CODE &"_SECRET", "")
		TinifyStatus 		= GetSettings(""& PLUGIN_CODE &"_ACTIVE", "0")
		TinifySaveWith 		= GetSettings(""& PLUGIN_CODE &"_SAVEWITH", "ADODB")
		API_COMPRESS_LIMIT  = GetSettings(""& PLUGIN_CODE &"_PLAN_LIMIT", "500")
		API_ENCRYPTED  		= base64_encode("api:"& TinifySecret &"")
		FULL_SITE_URL 		= DOMAIN_URL
		FailReason 			= "No Error"
		ProtectOriginalFile = Cint( GetSettings(""& PLUGIN_CODE &"_PROTECTORIGINAL", "1") )
		FileSize			= 0
		FilePath			= ""
		FileName 			= ""
		FileExtension 		= ""
		AllowedExtensionList= Split(GetSettings(""& PLUGIN_CODE &"_ALLOWEDEXTENSION", "jpg, jpeg, png"), ",")
		FileURLAddress 		= ""
		APISuccessFileURL 	= ""
		APIResponse 		= ""
		APIStatus 			= ""
		APISuccessFileSize 	= 0
		APIMonthlyCounter 	= 0
		APISuccessRatio 	= 0
		'/*
		'-----------------------------------------------------------------------------------
		' REQUIRED: Register Plugin to CMS
		'-----------------------------------------------------------------------------------
		'*/
		class_register()
		'/*
		'-----------------------------------------------------------------------------------
		' REQUIRED: Hook Plugin to CMS Auto Load Location WEB|API|PANEL
		'-----------------------------------------------------------------------------------
		'*/
		If PLUGIN_AUTOLOAD_AT("WEB") = True Then 
			Cms.FooterData = WhatsappWidgetData()
		End If
	End Sub
	'/*
	'---------------------------------------------------------------
	' REQUIRED: Plugin Class Initialize
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	' REQUIRED: Plugin Class Terminate
	'---------------------------------------------------------------
	'*/
	Private sub class_terminate()

	End Sub
	'/*
	'---------------------------------------------------------------
	' REQUIRED: Plugin Class Terminate
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	' REQUIRED: Plugin Manager Exports
	'---------------------------------------------------------------
	'*/
	Public Property Get PluginCode() 		: PluginCode = PLUGIN_CODE 					: End Property
	Public Property Get PluginName() 		: PluginName = PLUGIN_NAME 					: End Property
	Public Property Get PluginVersion() 	: PluginVersion = PLUGIN_VERSION 			: End Property
	Public Property Get PluginGit() 		: PluginGit = PLUGIN_GIT 					: End Property
	Public Property Get PluginDevURL() 		: PluginDevURL = PLUGIN_DEV_URL 			: End Property
	Public Property Get PluginFolder() 		: PluginFolder = PLUGIN_FILES_ROOT 			: End Property
	Public Property Get PluginIcon() 		: PluginIcon = PLUGIN_ICON 					: End Property
	Public Property Get PluginRemovable() 	: PluginRemovable = PLUGIN_REMOVABLE 		: End Property
	Public Property Get PluginCredits() 	: PluginCredits = PLUGIN_CREDITS 			: End Property
	Public Property Get PluginRoot() 		: PluginRoot = PLUGIN_ROOT 					: End Property
	Public Property Get PluginFolderName() 	: PluginFolderName = PLUGIN_FOLDER_NAME 	: End Property
	Public Property Get PluginDBTable() 	: PluginDBTable = IIf(Len(PLUGIN_DB_NAME)>2, "tbl_plugin_"&PLUGIN_DB_NAME, "") 	: End Property
	Public Property Get PluginAutoload() 	: PluginAutoload = PLUGIN_AUTOLOAD 			: End Property

	Private Property Get This()
		This = Array(PluginCode, PluginName, PluginVersion, PluginGit, PluginDevURL, PluginFolder, PluginIcon, PluginRemovable, PluginCredits, PluginRoot, PluginFolderName, PluginDBTable, PluginAutoload)
	End Property
	'/*
	'---------------------------------------------------------------
	' REQUIRED: Plugin Manager Exports
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Property Get Debug()
		Debug = FailReason
	End Property
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Property Get OriginalFileSize()
		OriginalFileSize = FileSize
	End Property
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Property Get OriginalFilePath()
		OriginalFilePath = FilePath
	End Property
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Property Get OriginalFileName()
		OriginalFileName = FileName
	End Property
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Property Get OriginalFileExtension()
		OriginalFileExtension = FileExtension
	End Property
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Property Get ProtectOriginal()
		ProtectOriginal = IIf(ProtectOriginalFile=1, True, False)
	End Property
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Property Get AllowedExtensions()
		AllowedExtensions = AllowedExtensionList
	End Property
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Property Get OriginalFileURL()
		OriginalFileURL = FileURLAddress
	End Property
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Property Get CompressedFileLocalURL()
		CompressedFileLocalURL = FileURLAddress
	End Property
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Property Get CompressedFileRemoteURL()
		CompressedFileRemoteURL = APISuccessFileURL
	End Property
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Property Get CompressedFileSize()
		CompressedFileSize = APISuccessFileSize
	End Property
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Property Get EarnedSize()
		EarnedSize = FileSize - APISuccessFileSize
	End Property
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Property Get TotalMonthCompress()
		TotalMonthCompress = APIMonthlyCounter
	End Property
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Property Get CompressRatio()
		CompressRatio = APISuccessRatio
	End Property
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Function LogToSystem(pRequest, pResponse, pFailText)
		Conn.Execute("INSERT INTO tbl_pos_log(ODEME_YONTEMI, PREQ, PRES, ORDER_ID, TARIH, POSTMETHOD, METHODNAME) VALUES('"& MODULE_ID &"', '"& LoginKontrol(jsEncode(pRequest)) &"', '"& LoginKontrol(jsEncode(pResponse)) &"', '10000001', NOW(), '"& pFailText &"', 'TinifyClass')")
	End Function
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	'/*
	'---------------------------------------------------------------
	'
	'---------------------------------------------------------------
	'*/
	Public Property Get Compress(fullPath)
		FilePath 		= Server.MapPath(fullPath)
		FileName 		= ExtractFileName(fullPath)
		FileExtension 	= ExtractFileExtension(fullPath)
		FileURLAddress 	= FULL_SITE_URL & fullPath

		If Len(fullPath) < 2 Then 
			FailReason = "File Path Hatası"
			Compress = Null 
			LogToSystem "NoRequest", "NoResponse", FailReason
			Exit Property
		End If

		If TinifyStatus = "0" Then 
			FailReason = "Tinify Durumu Pasif"
			Compress = Null 
			LogToSystem "NoRequest", "NoResponse", FailReason
			Exit Property
		End If

		If Not Len(TinifySecret) = 32 Then 
			FailReason = "Api Anahtarı 32 Karakter İçermeli"
			Compress = Null 
			LogToSystem "NoRequest", "NoResponse", FailReason
			Exit Property
		End If

		If IsFileExist(FilePath) = False Then 
			FailReason = "Belirtilen dosya bulunamadı. Dosya: "& FilePath &""
			Compress = Null 
			LogToSystem "NoRequest", "NoResponse", FailReason
			Exit Property
		End If

		Set Fs = Server.CreateObject("Scripting.FileSystemObject")
			Set F = Fs.GetFile(FilePath)
				FileSize = F.Size
			Set F = Nothing

			If ProtectOriginalFile = 1 Then 
				Fs.CopyFile FilePath, (FilePath & "NONTINIFIED_"&str_file_name), True
			End If
		Set Fs = Nothing

		Dim tinfyRequest
			tinfyRequest = "{""source"":{""url"":"""& FileURLAddress &"""}}"
		
		Set tinfyHTTP = Server.CreateObject("Msxml2.ServerXMLHTTP.6.0")
			tinfyHTTP.open "POST", "https://api.tinify.com/shrink", false
			tinfyHTTP.setOption(2) = SXH_SERVER_CERT_IGNORE_ALL_SERVER_ERRORS
			tinfyHTTP.setRequestHeader "Content-type", "application/json"
			tinfyHTTP.setRequestHeader "Authorization", "Basic "& API_ENCRYPTED &""
			tinfyHTTP.setTimeouts 5000, 5000, 10000, 10000 'ms
			tinfyHTTP.send tinfyRequest
			
			APIResponse 		= tinfyHTTP.responseText
			APIStatus 			= tinfyHTTP.Status
			APIMonthlyCounter 	= tinfyHTTP.getResponseHeader("Compression-Count")

			a=UpdateSettings("TINIFY_PLUGIN_ACTIVE_LIMIT", APIMonthlyCounter)
		Set tinfyHTTP = Nothing

		If APIStatus = 201 Then
			Set Data = JSON.parse(join(array( APIResponse )))

			If Err <> 0 Then
				FailReason = "API Geçersiz Cevap Döndü."
				Compress = Null 
				LogToSystem tinfyRequest, APIResponse, FailReason
				Exit Property
			End If

			APISuccessFileURL 	= Data.output.url
			APISuccessFileSize 	= Data.output.size
			APISuccessRatio  	= Data.output.ratio

			Set objHTTP = Server.CreateObject("MSXML2.ServerXMLHTTP")
				objHTTP.Open "GET", APISuccessFileURL
				objHTTP.Send
				Select Case TinifySaveWith
					Case "ASPJPEG"
						Set Jpeg = Server.CreateObject("Persits.Jpeg")
							Jpeg.OpenBinary( objHTTP.responseBody )
							Jpeg.Save FilePath
						Set Jpeg = Nothing
					Case "ADODB"
						Set objADOStream = CreateObject("ADODB.Stream")
							objADOStream.Open
							objADOStream.Type = 1
							objADOStream.Write objHTTP.responseBody
							objADOStream.Position = 0
							' Set objFSORemote = CreateObject("Scripting.FileSystemObject")
							' If objFSORemote.FileExists(strHDLocation) Then 
							' 	objFSORemote.DeleteFile strHDLocation
							' End If
							' Set objFSORemote = Nothing
							objADOStream.SaveToFile FilePath, YesOverWrite
							objADOStream.Close
						Set objADOStream = Nothing
					Case Else 
						FailReason = "Kayıt İstemcisi Hatası ("& TinifySaveWith &")"
						Compress = Null 
						LogToSystem tinfyRequest, APIResponse, FailReason
						Exit Property
				End Select
			Set objHTTP = nothing

			Set Data = Nothing

			Compress = True
			LogToSystem tinfyRequest, APIResponse, "Success"

			Conn.Execute("INSERT INTO tbl_plugin_tinify(FILENAME, FULL_PATH, COMPRESS_DATE, COMPRESS_RATIO, ORIGINAL_FILE_SIZE, COMPRESSED_FILE_SIZE, EARNED_SIZE, ORIGINAL_PROTECTED) VALUES('"& OriginalFileName() &"', '"& fullPath &"', NOW() , '"& Replace(CompressRatio(), ",", ".") &"', '"& OriginalFileSize() &"', '"& CompressedFileSize() &"', '"& EarnedSize() &"', '"& ProtectOriginal() &"')")
		Else 
			FailReason = "API Status Olumsuz (Status: "& APIStatus &")"
			Compress = Null 
			LogToSystem tinfyRequest, APIResponse, FailReason
			Exit Property
		End If

		FailReason = FilePath
	End Property
End Class 
%>
