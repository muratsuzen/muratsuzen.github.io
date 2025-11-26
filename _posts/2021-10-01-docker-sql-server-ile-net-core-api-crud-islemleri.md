---
title: Docker üzerinde SQL Server ile .Net Core Web API CRUD İşlemleri
author: Murat Süzen
date: 2021-10-01 11:33:00 -500
categories: [ASP.NET Core]
tags: [asp.net core, web api, crud, docker]
math: true
mermaid: true
---

Hepimiz için sıkıntılı ve yıkıcı geçen bir yılın ardından yeni yıla yeni bir makale ile başlamak istedim. 2021 yılının herkes için sevdikleriyle sağlıklı, mutlu ve huzurlu bir yıl olmasını dilerim. Docker dünyasıyla ilgilenmekte geç kaldığımın farkında olarak hızlıca bir giriş yapmak istedim. Docker üzerinde MS SQL Server kurulumunu ve .Net Core Web API ile CRUD işlemlerini yapmayı planlıyorum. Docker kurulumunu buradan indirip tamamlıyorum. Daha sonra terminali açıp `docker pull microsoft/mssql-server-linux` kodu ile mssql imajını indiriyorum.

![Docker MSSQL Image](/assets/img/posts/docker-mssql-image-download.png)
_Docker MSSQL Image_

İmaj dosyası indirildikten sonra docker container yapısını aşağıdaki kod bloğu ile ayağa kaldırıyorum. Bu şekilde MS SQL Server kurulumunu tamamlamış olacağım.

```shell
docker run -d --name sqlserver -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=r00t.R00T' -p 1433:1433 microsoft/mssql-server-linux
```

Docker container yapısının çalışıp çalışmadığını docker desktop üzerinden inceleyebiliriz.

![Docker MSSQL Server Container](/assets/img/posts/docker-sqlserver-container.png)
_Docker MSSQL Server Container_

Kurmuş olduğumuz SQL Server'a bağlanmamız için ben Azure Data Studio uygulamasını indirip kuruyorum. Bu uygulamayı da buradan indirebilirsiniz. Studio uygulamasının da kurulumunu tamamladıktan sonra `dotnet new webapi -o docker-web-api` komutuyla yeni bir .Net Core Web API uygulaması oluşturuyorum.

![dotnet new web api](/assets/img/posts/docker-dotnet-new-web-api.png)
_dotnet new web api_

Uygulamayı oluşturduğumuzda Swagger konfigürasyon yapısı hazır halde gelmektedir. Bu arada 5.0.100 .Net versiyonunu kullanmaktayım.

![web api startup](/assets/img/posts/docker-web-api-startup.png)
_web api startup_

EntityFramework 5.0 paketlerini `dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 5.0.1` ve `dotnet add package Microsoft.EntityFrameworkCore.Design` komutlarıyla projeye ekliyorum. Daha sonra bir Entity klasörü oluşturup tabloları içeren Entity sınıflarını oluşturacağım. Post tablosunu oluşturmak için sınıfı hazırlıyorum.

```csharp
using System.Collections.Generic;

public class Post
{
    public int Id { get; set; }
    public string Name { get; set; }
}
```

DbContext sınıfını BlogContext adıyla oluşturup veritabanı bağlantısını ve sınıfı DbSet ile tanımlıyorum.

```csharp
using Microsoft.EntityFrameworkCore;

public class BlogContext : DbContext
{
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseSqlServer("Server=localhost;Database=myBlog;User Id=sa;Password=r00t.R00T;");

        base.OnConfiguring(optionsBuilder);
    }

    public DbSet Posts{get;set;}
}
```

Tabloların oluşturulması için migration yapmamız gerekiyor. Migration işlemlerini yapmak için `dotnet tool install --global dotnet-ef` kod bloğunu kullanarak .NET Core CLI aracını kuruyorum. Migration yapısını oluşturmak için `dotnet ef migrations add InitialCreate` kod bloğunu çalıştırdığımda aşağıdaki gibi migration dosyaları oluşturuluyor.

![migration](/assets/img/posts/docker-web-api-migration.png)
_migration_

Veritabanı ve tabloların oluşturulması için `dotnet ef database update` komutunu çalıştırıyorum. Başarıyla sonuçlandıktan sonra aşağıdaki gibi veritabanına ulaşıyorum.

![databases](/assets/img/posts/docker-web-api-databases.png)

Projede controller klasöründe Post adında bir controller oluşturuyorum. GET-POST-PUT-DELETE metodlarını hazırlıyorum.

```csharp
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace docker_web_api.Controllers
{
    [ApiController]
    [Route("post")]
    public class PostController : ControllerBase
    {
        [HttpGet]
        public IEnumerable Get(){
            using (var context = new BlogContext())
            {
                var postList = context.Posts.ToList();
                return postList;
            }
        }

        [HttpPost]
        public IActionResult Post([FromBody] Post entity){
            using (var context = new BlogContext())
            {
                var addedEntity = context.Entry(entity);
                addedEntity.State = EntityState.Added;
                context.SaveChanges();
                return Ok(entity);
            }
        }

        [HttpPut]
        public IActionResult Put([FromBody] Post entity){
            using(var context = new BlogContext()){
                var updatedEntity = context.Entry(entity);
                updatedEntity.State = EntityState.Modified;
                context.SaveChanges();
                return Ok(entity);
            }
        }

        [HttpDelete]
        public IActionResult Delete(int Id){
            using(var context = new BlogContext()){
                var findEntity = context.Posts.FirstOrDefault(x=>x.Id == Id);
                var deletedEntity = context.Entry(findEntity);
                deletedEntity.State = EntityState.Deleted;
                context.SaveChanges();
                return Ok();
            }
        }

    }
}
```

Projeyi çalıştırıp <https://localhost:5001/swagger/index.html/> adresinden swagger yardımıyla veri işlemlerini test edebilirsiniz. Projeyi [**buradan**](https://github.com/muratsuzen/dotnetcore-samples/tree/main/docker-web-api) indirebilirsiniz. Bir sonraki makalede görüşmek üzere.
