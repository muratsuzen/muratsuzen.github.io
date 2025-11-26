---
title: İnternet Nedir? Ne İşe Yarar? İnternet Nasıl Çalışır?
author: Murat Süzen
date: 2021-10-27 11:33:00 -500
categories: [Other]
tags: [dns, tcp]
math: true
mermaid: true
---

Küresel bir ağ olan internete bağlı her bir bilgisayarın 0-255 arasında xxx.xxx.xxx.xxx şeklinde benzersiz bir ağ kimliğine sahip olması gerekmektedir. Bu benzersiz kimliğe IP (Internet Protocol) denilmektedir. IP ile bilgisayarlar internette birbirini tanıyabilmektedir. Internet Servis Sağlayıcılar (ISS) aracılığı ile internete bağlanabilmekteyiz. İnternet Servis Sağlayıcılar, internete uydu bağlantısı ya da kablolar üzerinden bağlanır. İnternetteki her bilgisayar yada internet erişimi olan cihazın yukarıda bassettiğimiz gibi benzersiz bir IP (Internet Protocol) numarası bulunmaktadır. Bu IP adresleri sayesinde internet üzerinde bilgisayarların birbirini bulması sağlanıyor.

- `DNS (Domain Name Service):` Bu benzersiz IP numaralarını kolay şekilde adreslememize imkan sağlayan DNS (Domain Name System) protokolü ile bir IP adresini www.google.com gibi domaine yönlendirebiliriz. Bu şekilde internetten bu domaine giriş yaptığımızda DNS protokolü ilgili IP adresine yönlenecektir.

> Ulaşmak istediğiniz bir IP yada domain adresinin ulaşılabilir olup olmadığını test etmek için çok kullanışlı bir program bunmaktadır. Windows yada Unix işletim sistemlerinde komut istemi uygulaması ile internet üzerindeki IP yada domain adresine ping atabilirsiniz. Girilen adrese ping isteği gönderdiğimizde cevap gelene kadar geçen süreyi bize geri döndürmektedir. Örnek; ping 8.8.8.8

- `TCP (Transmission Control Protocol) :` Küresel internet ağında bilgisayarların yada internet erişimi olan cihazların birbirleri arasında iletişimi paketler şeklinde sağlamaktadır. İki cihaz arasındaki kimlik doğrulamasını ve veri boyutu ne olursa olsun ağ üzerinden gönderilen verilerin bütünlüğünü bozmadan iletimini yapmaktadır.

Günümüzde birçok TCP protokolü kullanılmaktadır. HTTP web erişim protokolü, POP3 eposta alım protoklü,SMTP eposta gönderim protokolü, SSH uzaktan oturum açma uygulaması en bilinen Güvenli Kabuk ağ güvenlik protokolü, FTP internet üzerinde dosya transferi sağlayan protokol.

İki bilgisayar arasında bir mesaj gönderim örneğini inceleyelim. `A-PC (1.2.3.4)` ve `B-PC (9.8.7.6)` isminde ve IP adresinde iki bilgisayarımızın internet ile "Merhaba Dünya" mesajını birbirine iletimi aşağıdaki şekilde olmaktadır.

- A-PC "Merhaba Dünya" mesajını B-PC bilgisiayarına gönderdiğinde en üst katmandaki protokol yığınından mesaj işlenmeye başlar
- Gönderilecek mesaj boyutu büyük ise mesajın geçtiği her yığın katmanı mesajı küçük paketler haline getirebilir. Bunun yapılmasındaki amaç yönetilebilir daha küçük paketlerin oluşturulmak istenmesidir.
- Paketler Application Katmanından geçer ve TCP katmanına devam eder. Her pakete bir bağlantı noktası numarası atanır.
- TCP katmanından geçtikten sonra, paketler IP katmanına ilerler. Burası, her paketin hedef adresini aldığı yerdir, (9.8.7.6)
- Mesaj paketlerimizin bir bağlantı noktası numarası ve bir IP adresi olduğu için, İnternet üzerinden gönderilmeye hazırdır. Hardware katmanı, mesajımızın alfabetik metnini içeren paketleri elektronik sinyallere dönüştürüp telefon hattı üzerinden iletmeye başlar.
- Telefon hattının diğer ucunda ISS'nizin İnternet'e doğrudan bağlantısı vardır. Yönlendiriciler her paketteki hedef adresini inceler ve nereye gönderileceğini belirler.
- Paketler (9.8.7.6) bilgisayarına ulaşır. Burada paketler, hedef bilgisayarın TCP / IP yığınının altından başlar.
- Paketler yığın içinde yukarı doğru ilerlerken (Hardware => IP => TCP = Application), gönderen bilgisayarın yığınının eklediği tüm yönlendirme verileri paketlerden çıkarılır.
- Veriler yığının en üstüne ulaştığında (Application), paketler "Merhaba Dünya" adlı orijinal formlarına yeniden birleştirilir.

Bir sonraki makalede görüşmek üzere.
