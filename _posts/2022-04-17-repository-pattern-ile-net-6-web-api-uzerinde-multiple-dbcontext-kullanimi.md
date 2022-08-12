---
title: Repository Pattern İle .NET 6 Web API Üzerinde Multiple DbContext Kullanımı
author: Murat Süzen
date: 2022-04-17 11:33:00 -500
categories: [ASP.NET CORE]
tags: [asp.net core,net 6.0,web api,api key,repository pattern]
math: true
mermaid: true
image:
  path: /assets/img/stocks/caravaggio-supper_at_emmaus-1602.jpg
  width: 800
  height: 500
  alt: Caravaggio, Supper at Emmaus (1602)
---

Merhabalar bu makalede bir Asp .Net Web API projesinde multiple DbContext kullanımına değineceğim. Senaryoda 2 farklı veritabanına Repository Pattern yardımıyla DbContext değiştirerek bağlantı yapacağım. Öncelikle bir Asp .Net Web API (6.0) projesi oluşturuyorum. İlk iş olarak `EntityFrameWork` paketlerini yüklüyorum.

```bash
Install-Package Microsoft.EntityFrameworkCore -Version 6.0.4
Install-Package Microsoft.EntityFrameworkCore.SqlServer -Version 6.0.4
Install-Package Microsoft.EntityFrameworkCore.Tools -Version 6.0.4
```

Paket yüklemesi tamamlandığında DbContext sınıflarını oluşturuyorum. Proje dizinine Data isminde klasör ekliyorum. Data klasörüne `DbOneContext`, `DbTwoContext` ve `BaseContext` isminde üç class ekliyorum. BaseContext clasını DbContext sınıfından türetip constructor ile `DbContextOptions` parametresini alıyorum.

```csharp
using Microsoft.EntityFrameworkCore;

namespace MultipleDbContext.Data;

public class BaseContext : DbContext
{
    public BaseContext(DbContextOptions options): base(options)
    {
        
    }
}
```
DbOneContext ve DbTwoContext sınıfları BaseContext den türetip aşağıdaki şekilde implemente ediyorum.

```csharp
using Microsoft.EntityFrameworkCore;

namespace MultipleDbContext.Data;

public class DbOneContext : BaseContext
{
    public DbOneContext(DbContextOptions<DbOneContext> options) : base(options)
    {

    }
}
```

```csharp
using Microsoft.EntityFrameworkCore;

namespace MultipleDbContext.Data;

public class DbTwoContext : BaseContext
{
    public DbTwoContext(DbContextOptions<DbTwoContext> options) : base(options)
    {
    }
}
```

DbConext sınıflarını oluşturduktan sonra appsettings.json dosyasına girip ConnectionString tanımlarını yapıyorum.

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DbOneContext": "Data Source=.;Initial Catalog=DBONE;User ID=sa;Password=Pw123456",
    "DbTwoContext": "Data Source=.;Initial Catalog=DBTWO;User ID=sa;Password=Pw123456"
  }
}
```

Daha sonra Program.cs dosyasının içerisinde projeye contextleri tanıtıyorum.

```csharp
builder.Services.AddDbContext<DbOneContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DbOneContext")));

builder.Services.AddDbContext<DbTwoContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DbTwoContext")));
```

Projeye `Models` isminde bir klasör ekliyorum. İçerisine veritabanı tablosunu oluşturacağım entity için bir `Book` isminde class ekliyorum.

```csharp
namespace MultipleDbContext.Models
{
    public class Book
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Anchor { get; set; }
    }
}
```

Daha sonra `BaseContext` içerisinde DbSet ile Book entity sınıfını tanıtıyorum.

```csharp
using Microsoft.EntityFrameworkCore;
using MultipleDbContext.Models;

namespace MultipleDbContext.Data;

public class BaseContext : DbContext
{
    public BaseContext(DbContextOptions options): base(options)
    {
        
    }

    public DbSett<Book> Books { get; set; }
}
```
Data klasörüne `DbContextFactory` isminde bir sınıf oluşturuyorum. Bu sınıfta bir IDictionary içersinde contextName değeri ile ilgili BaseContext nesnesini geri alıyoruz.

```csharp
namespace MultipleDbContext.Data
{
    public class DbContextFactory
    {
        private readonly IDictionary<string, BaseContext> _context;

        public DbContextFactory(IDictionary<string, BaseContext> context)
        {
            _context = context;
        }

        public BaseContext GetContext(string contextName)
        {
            return _context[contextName];
        }
    }
}
```
Artık Repository yapısını oluşturabilirim. Öncelikle proejeye Repository isminde bir klasör oluşturup içerisine `IBookReposiory` adında bir interface ve `BookRepository` adında bir class ekliyorum.

```csharp
using MultipleDbContext.Models;

namespace MultipleDbContext.Repository;

public interface IBookRepository
{
    void Add(Book entity,string contextName);
    void Update(Book entity, string contextName);
    List<Book> Get(string contextName);
}
```
ContextName bilgisini parametre ile gönderiyorum. Bu şekilde DbContext ayrımını yapacağım.

```csharp
using Microsoft.EntityFrameworkCore;
using MultipleDbContext.Data;
using MultipleDbContext.Models;

namespace MultipleDbContext.Repository
{
    public class BookRepository : IBookRepository
    {
        DbContextFactory _contexts;

        public BookRepository(DbContextFactory contexts)
        {
            _contexts = contexts;
        }
        public void Add(Book entity, string contextName)
        {
            var context = _contexts.GetContext(contextName);
            var addedEntity = context.Attach(entity);
            addedEntity.State = EntityState.Added;
            context.SaveChanges();
        }

        public void Update(Book entity, string contextName)
        {
            var context = _contexts.GetContext(contextName);
            var updatedEntity = context.Entry(entity);
            updatedEntity.State = EntityState.Modified;
            context.SaveChanges();
        }

        public List<Book> Get(string contextName)
        {
            var context = _contexts.GetContext(contextName);
            return context.Books.ToList();
        }
    }
}
```
Bu sınıfta constructor içerisinde DbContextFactory ile DbContext nesnelerini Repository içerisine taşıyorum. Parametre ile gönderilen DbContexti çalıştırıyorum. Bu yapılandırma için `AutoFac` IOC container'ını projeye ekliyorum.

```bash
Install-Package Autofac -Version 6.3.0
Install-Package Autofac.Extensions.DependencyInjection -Version 7.2.0
```
Paketi indirdikten sonra hemen Program.cs içerisinde AutoFac yapılandırmasını yapıyorum.

```csharp
builder.Host.UseServiceProviderFactory(new AutofacServiceProviderFactory());
builder.Host.ConfigureContainer<ContainerBuilder>(b => b.RegisterModule(new AutoFacModule()));
```
Burada registerModule ile kendi oluşturduğum AutoFacModule clasını tanımlıyorum.

```csharp
public class AutoFacModule : Module
{
    protected override void Load(ContainerBuilder builder)
    {
        builder.RegisterType<DbOneContext>().As<BaseContext>();
        builder.RegisterType<DbTwoContext>().As<BaseContext>();
        builder.Register(ctx =>
        {
            var allContext = new Dictionary<string, BaseContext>();
            allContext.Add("DbOneContext", ctx.Resolve<DbOneContext>());
            allContext.Add("DbTwoContext", ctx.Resolve<DbTwoContext>());
            return new DbContextFactory(allContext);

        });
        builder.RegisterType<BookRepository>().As<IBookRepository>();

    }
}
```
AutoFac IOC yapılandırması sonrasında controllers klasörüne BookController isminde bir web api controller ekliyorum.

```csharp
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using MultipleDbContext.Models;
using MultipleDbContext.Repository;

namespace MultipleDbContext.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BookController : ControllerBase
    {
        private IBookRepository _bookRepository;

        public BookController(IBookRepository bookRepository)
        {
            _bookRepository = bookRepository;
        }

        [HttpGet]
        [Route("{contextName}")]
        public List<Book> Get([FromRoute] string contextName)
        {
            var books = _bookRepository.Get(contextName);
            return books;
        }

        [HttpPost]
        [Route("{contextName}")]
        public IActionResult Post([FromRoute] string contextName,[FromBody] Book book)
        {
            try
            {
                _bookRepository.Add(book,contextName);
                return Ok();
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }
        }

        [HttpPut]
        [Route("{contextName}")]
        public IActionResult Put([FromRoute] string contextName, [FromBody] Book book)
        {
            try
            {
                _bookRepository.Update(book, contextName);
                return Ok();
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }
        }
    }
}
```
BookController'da görüldüğü üzere contextName parametresi ile hangi dbContext'e bağlanacağımı alıyorum. Daha sonra BookRepository yardımıyla CRUD işlemlerini yapacağım. Controller yapısını oluşturduktan sonra Migration yardımıyla `DbOne` ve `DbTwo` veritabanlarını oluşturuyorum. Birden fazla DbContext dosyası olduğu için migration işlemi yaparken hangisini oluşturacağını belirtmek gerekiyor.

```bash
Add-Migration -Context DbOneContext
Update-Database -Context DbOneContext
```
```bash
Add-Migration -Context DbTwoContext
Update-Database -Context DbTwoContext
```
Migration işlemleri sonrasında aşağıdaki gibi veritabanlarının oluşmuş olduğunu görebilirsiniz. 

![MultipleContext](/assets/img/posts/MultipleContext.jpg)

Artık projeyi çalıştırıp Swagger yardımı ile CRUD işlemlerini yapmaya başlıyorum. DbOneContext için Post ve Get isteklerini yapıyorum.

![MultipleContextPost](/assets/img/posts/MultipleContextPost.jpg)
_DbOneContext-Post_

![MultipleContextGet](/assets/img/posts/MultipleContextGet.jpg)
_DbOneContext-Get_

DbOneContext parametresi ile DbOne veritabanına Post ve Get aksiyonları ile CRUD işlemleri yaptım. Aynı Şeklide DbTwoContext parametresi ile DbTwo veritabanına CRUD işlemlerini yapıyorum.

![DbTwoContext-Post](/assets/img/posts/MultipleContextPost2.jpg)
_DbTwoContext-Post_

![DbTwoContext-Get](/assets/img/posts/MultipleContextGet2.jpg)
_DbTwoContext-Get_

![Veritabanı Verileri](/assets/img/posts/MultipleContextSQL.jpg)
_Veritabanı Verileri_

Bu şekilde birden fazla dbcontext yapısını nasıl çalıştırabileceğimiz ile ilgili bir örnek gerçekleştirdik. Proje dosyalarını [**buradan**](https://github.com/muratsuzen/MultipleDbContext.git) indirebilirsiniz. Bir sonraki makalede görüşmek üzere.
