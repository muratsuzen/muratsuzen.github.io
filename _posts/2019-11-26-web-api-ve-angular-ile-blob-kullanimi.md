---
title: Web API ve Angular 8 ile Blob Veri Tipi Kullanımı
author: Murat Süzen
date: 2021-01-10 11:33:00 -500
categories: [Angular, Blob]
tags: [asp.net core, web api, angular, blob]
math: true
mermaid: true
---

Yaptığım bir Angular projesinde Web API ile FTP server dan dosya indirme işlem yapmam gerekiyordu. Haliyle blob veri tipleriyle ilgilenmem gerekti. FTP den dosyaları indirme işlemi çok zamanımı almadı fakat öngöremediğim bir MIME type tanımı epey uğraştırdı. Tüm tarayıcılardan indirme işlemini yapabilirken CriOS (IOS Chrome) tarayıcısında indirme işlemi başarısız oluyordu. Web API den her dosya formatına `application/octet-stream` MediaTypeHeaderValue tipini gönderiyordum. CriOS hariç tüm tarayıcılar gönderilen byte[] tipini olması gereken dosya formatına çevirip indiriyordu. Çözmem gereken CriOS tarayıcısı olduğu için bu konuya yöneldim. Araştırmalar sonucunda Apple’ın mobil Chrome tarayıcısında bir `blob` tipinde bir dosya indirme işlemini yeni sekmede açılarak yapılması gerektiğini öğrendim.

Bu arada Angular için Angular File Saver paketini kullanıyordum. MediaTypeHeaderValue tipini `application/octet-stream` olarak sabit gönderdiğimden Angular File Saver CriOS tarayıcısında hata veriyordu. Bende sorunun paket ile alakalı olabileceği düşüncesiyle dosya indirme işlemini bir a elementi oluşturup click eventi ile indirme işlemi yapıyorum. Siz MediaTypeHeaderValue tipini güncelleyerek Angular File Saver kullanabilirsiniz.

```typescript
this.httpClient
  .get(url, { headers: headers, responseType: "blob" })
  .subscribe((data) => {
    const file = new Blob([data], { type: data.type });
    const fileURL = (window.URL || window["webkitURL"]).createObjectURL(file);
    const downloadLink = document.createElement("a");
    downloadLink.href = fileURL;
    downloadLink.download = fileName;
    downloadLink.target = "_blank";
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
  });
```

Wep API tararfındaki kod bloğunda MIME tipini indirilecek dosya formatına göre gönderdiğimde sorun çözüldü.

```csharp
[HttpGet][Route("FileDownload/{id:int}")] public HttpResponseMessage FileDownload(int id)
{
  var ftpUser = _ftpSettingsService.Get().FirstOrDefault();
  var fileInfo = _ftpFilesService.GetById(id);
  string fileAddr = $ "{ftpUser.Address}{fileInfo.FilePath}";
  WebClient request = new WebClient();
  request.Credentials = new NetworkCredential(ftpUser.UserName, ftpUser.Password);
  byte[] newFileData = request.DownloadData(fileAddr);
  MemoryStream memoryStream = new MemoryStream(newFileData);
  string newFileName = fileInfo.NewFileName;
  string content = MimeExtensions.GetMimeType(fileInfo.FileType);
  HttpResponseMessage httpResponseMessage = Request.CreateResponse(HttpStatusCode.OK);
  httpResponseMessage.Content = new StreamContent(memoryStream);
  httpResponseMessage.Content.Headers.ContentDisposition = new System.Net.Http.Headers.ContentDispositionHeaderValue("attachment");
  httpResponseMessage.Content.Headers.ContentDisposition.FileName = newFileName;
  httpResponseMessage.Content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue(content);
  return httpResponseMessage;
}
```
