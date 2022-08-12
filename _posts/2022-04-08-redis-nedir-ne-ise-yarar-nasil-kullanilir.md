---
title: Redis Nedir? Ne İşe Yarar? Nasıl Kullanılır?
author: Murat Süzen
date: 2022-04-08 11:33:00 -500
categories: [REDIS]
tags: [redis,cache]
math: true
mermaid: true
---

Uygulamalarımızda verileri servislerden yada veri tabanlarından listeleyip kullanıcılara göstermekteyiz. Veri yoğunluğu nedeniyle performans sorunları yaşamamak için verilerde değişiklik olmadığında, veri kopyasını sunucu (RAM) üzerinde tutarak istek geldiğinde veritabanına gitmeden RAM üzerinden okuyup gösterilmesi işlemlerine `In Memory Cache` denilmektedir. Bu cache işlemlerini anahtar-değer (key-value) NoSQL veritabanları sayesinde yapabiliyoruz.

## Redis (Remote Dictionary Service) Nedir?

Redis caching, message broker, session yönetimi amacıyla kullanılan C ile yazılmış key-value yapısında tasarlanmış bir NoSQL veritabanıdır. Redis, verileri RAM üzerinde saklamasının yanı sıra isteğimize göre verileri belirli zaman aralıklarıyla disk’e kaydedebiliriz. Bu şekilde veri tutarlılığını sağlayabiliriz.

## Redis Ne İşe Yarar?

Redis caching, message broker, session yönetimi amacıyla kullanılmaktadır.

## Caching

Veritabanı sorgularını ön belleğe (RAM) alarak performans sağlayabiliriz. Redis ile istenen veriler mili saniyler süresinde geri döndürülebilir. Bu nedenle sıklıkla caching işlemlerinde Redis kullanılmaktadır.

## Session Store

Uygulamalarımızda Redis ile kimlik bilgilerini, kullanıcı bilgilerini, vb. gibi session verilerini yüksek hızlarda okuyabilmenize olanak sağlar.

## Message Broker

Redis 2.0'dan sürümünden itibaren Pub/Sub işlevini destekleyen komutlara sahiptir.

## Redis Nasıl Kullanılır?

Redis paketlerinin kurulu olduğu dizinde `"redis-cli.exe"` uygulamasını çalıştırıyorum. Redis için bir şifre belirlediğimizde bağlantı için "auth" komutunu kullanmalıyız.

```bash
127.0.0.1:6379> set userName Murat
(error) NOAUTH Authentication required.
``` 
Şifre gönderilmeden herhangi bir komut çalıştırıldığında yukarıdaki gibi bağlantı hatası ile karşılaşırız.

```bash
127.0.0.1:6379> auth password123! 
OK
``` 

```bash
127.0.0.1:6379> set fullName Murat
OK
``` 

Şifreyi auth komutu ile set ettiğimizde "userName" anahtarına "Murat" değerini kayıt edebiliyoruz. Veriler `<key,value>` şeklinde string olarak tutulmaktadır.

```bash
127.0.0.1:6379> set fullName "Murat"
OK
127.0.0.1:6379> get fullName
"Murat"
``` 

Set komutuyla değer ataması yapılıyor, Get komutuyla gönderilen anahtar bilgisinin değeri alınıyor. Append komutu ile string bir değerin sonuna string veri ekleme işlemi yapılmaktadır.

```bash
127.0.0.1:6379> append fullName " Suzen"
(integer) 11
127.0.0.1:6379> get fullName
"Murat Suzen"
``` 
Keys * komutu ile bütün anahtarların (key) listelenmesini sağlayabiliriz.

```bash
127.0.0.1:6379> keys *
1) "fullName"
``` 
Del komutu ile verilen anahtar bilgisi silinir.

```bash
127.0.0.1:6379> del fullName
(integer) 1
127.0.0.1:6379> get fullName
(nil)
``` 
Flushall komutu ile tüm veriler silinir.

```bash
127.0.0.1:6379> flushall
OK
``` 
Exists komutu ile gönderilen anahtarın (key) olup olmadığını kontrol edebiliriz

```bash
127.0.0.1:6379> set key1 "Merhaba"
OK
127.0.0.1:6379> exists key1
(integer) 1
127.0.0.1:6379> exists key2
(integer) 0
```
Diğer Redis komutlarına [*buradan*](https://redis.io/commands) ulaşabilirsiniz. Ayrıca verileri görüntüleyip yönetebileceğiniz Another Redis Desktop Manager uygulamasını buradan indirebilirsiniz.


