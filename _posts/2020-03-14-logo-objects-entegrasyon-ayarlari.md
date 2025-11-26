---
title: Logo Objects Entegrasyon Ayarları
author: Murat Süzen
date: 2020-03-14 11:33:00 -500
categories: [Other]
tags: [logo objects]
math: true
mermaid: true
---

Merhabalar bu makalede Logo Yazılım firmasının ERP (Tiger vb.) ürünlerine dışarıdan veri gönderip / almabilmek için geliştiridiği, entegrasyon aracının (UnityObject, Logo.dll, Lobject.dll) nasıl kullanılması gerektiği ile ilgili hem kendime hemde sizlere notlar yazmak istedim. Normal şartlarda bu ürün ile ilgili geliştirmelerin çözüm ortağı serfitikasına sahip yetkin kişilerce yapılması gerekmektedir. Şimdi LOBJECTS.exe uygulamasının register ve web kullanımı için IIS yetkilendirmesini inceleyelim.

## LOBJECTS.exe Register Nasıl Yapılır?

Logo ürününün kurulu olduğu dizinde REGISTER.bat dosyası ile ERP uygulamasının kullanımı için gerekli olan dll dosyalarını hazır DOS komutları ile sisteme register yapılmasını sağlıyoruz. Dosyayı sağ tuş – Yönetici olarak çalıştırıp tüm register işlemlerinin yapılmasını bekliyoruz. Eğer manual olarak register işlemi yapmak isterseniz aşağıdaki yöntemleri deneyebilirsiniz.

- başlat-> çalıştır -> cmd yazıp konsole ekranına geçiyoruz
- REGISTER-DLL : regsvr32 erpPath\LOBJECTS.dll
- UNREGISTER-DLL : regsvr32 -u erpPath\LOBJECTS.dll
- REGISTER-EXE : erpPath\LOBJECTS.exe -REGSERVER
- UNREGISTER-EXE : erpPath\LOBJECTS.exe -UNREGSERVER

> Not: Eğer ERP ürün Active Directory üzerinde bir sunucuda ise resgister yapmak istediğiniz makineyi ve kullanıcıyı Active Directory yapısına eklemeniz gerekmektedir. Yönetici izinleri olmadan yada Active Directory yapısında olmayan bir kullanıcı/makine ile register işlemleri COM hataları almanıza sebep olacaktır.

REGISTER.bat dosyasındaki tüm register işlemlerinin başarıyla tamamlanması sonrasında LOBJECTS.exe kullanıma uygun hale gelecektir.

## Uygulamalarda LOBJECTS Ürünü Referance Eklemesi Nasıl Yapılır?

Projenize Lobjects ürününü referans olarak eklemek istediğinizde hemen hemen birçok kişinin yaptığı bir hatayı paylaşayım. Projenin referance ekleme bölümüne girip Browse üzerinden Logo ürününün bulunduğu dosya yolundaki LOBJECTS.dll dosyasını referance olarak ekleniyor. Bu Logo tarafından asla önerilmeyen bir yöntemdir. Biz zaten LOBJECTS.exe dosyasını REGISTER.bat ile sisteme register yaptık. Bu referans bilgisine artık `COM` kaynaklarından erişebilmekteyiz.

![COM kayıtları](/assets/img/posts/logo-obejct-1.jpg)
_COM kayıtları_

## Windows Service Uygulamalarında LOBJECTS Ürünü Yetkilendirmesi Nasıl Yapılır?

Windows Service uygulamlarımızda ERP entegrasyon aracını kullanmak istersek servisi sistemimize kurduğumuzda belirli yetkilendirme ayarları yapmamız gerekmektedir. Servisin ayarlarına girdiğimizde `LOG On` sekmesinde servisin başlatma kullanıcısını, sunucu eğer bir Active Directory yapısında değilse sunucunun Administrator hesabı ile, eğer bir Active Directory yapısında ise Active Directory Adminisitrator hesabı ile çalışmasını sağlamalıyız.

## Web Projelerinde Kullanabilmek için IIS Yetkilendirmesi Nasıl Yapılır?

Lobject.exe ürününü web projelerinde kullanabilmek IIS üzerinde ve DOM portlarında birkaç yetkilendirme ayarı yapmamız gerekmektedir. Öncelikle web projemizi IIS sistemine yükledikten sonra Application-Pool ayarlarını yapalım.

> Not:Logo Web uyuglamalarında LOBJETS.dll dosyası yerine LOBJECTS.exe dosyasının kullanılması gerektiğini söylemektedir.

![logo-objects-2.jpg](/assets/img/posts/logo-objects-2.jpg)

Resimde görüldüğü gibi ilk olarak `Enable 32-Bit Applications` değerini `True` olarak değiştiriyorum. Daha sonra `Identity` bölümünde `NetworkService` kullanıcısı ile yetkilendiriyorum. Ayrıca `.Net Framework Version` değerini `v4.0` olarak değiştiriniz. IIS üzerindeki ayarların yapılmasından sonra şimdi `DOM` anahtarlarında nasıl bir yetkilendirme işlemi yapacağımza bakalım. Öncelikle run/çalıştır yardımıyla `comexp.msc /32` Component Servicesleri açalım. Burada `Component Services => Computers => My Computer => DCOM Config` yolunu izleyerek DCOM uygulama anahtarlarına erişiyorum. Register yaptığım LOBJECTS.exe anahtarını listeden buluyorum ve Properties bölümünü açıyorum.

![COM kayıtları](/assets/img/posts/logo-obejct-1.jpg)
_COM kayıtları_

General bölümünde Authentication Level alaını None olarak değiştiriyorum . Daha sonra Identity sekmesini açıyorum,

![COM kayıtları](/assets/img/posts/logo-objects-3.jpg)

Identity sekmesinde regsiter yaptığımız exe’nin hangi kullanıcı ile çalıştırılacağını ayarlamamız gerekiyor. `This User` seçeneğinden server Administrator kullanıcısını yada server Active Directory altında ise Active Directory Administrator hesabını girip onaylıyorum.

![COM kayıtları](/assets/img/posts/logo-objects-4.jpg)

Bu şekilde LOBJECT.exe ürününü nasıl register ve yetkilendirme yapabileceğimiz konusundaki makalemizi tamamlamış oluyoruz. Aklınıza takılan sorular yada karşılaştığınız problemleri yorum olarak yada iletişim sayfasından gönderebilirsiniz. Bir sonraki makalede görüşmek üzere.
