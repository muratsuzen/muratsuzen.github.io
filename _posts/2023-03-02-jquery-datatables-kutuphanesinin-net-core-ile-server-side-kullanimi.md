---
title: JQuery Datatables Kütüphanesinin .NET Core ile Server Side Kullanımı
author: Murat Süzen
date: 2023-03-02 08:00:00 -500
categories: [ASP.NET Core, Web Development]
tags: [asp.net core, net 7.0, jquery datatables]
math: true
mermaid: true
image:
  path: /assets/img/stocks/axp-photography.jpg
  width: 800
  height: 500
  alt: Photo by AXP Photography on Unsplash
---

Web projelerinde en çok kullanılan Jquery veri tablo kütüphanelerinden biri olan [**Datatables**](https://datatables.net/) kütüphanesinin .NET Core üzerinde sunucu taraflı kullanımını inceleyeceğim. Datatables herhangi bir HTML tablosuna arama, sayfa geçişleri ve sıralama işlemlerini içeren gelişmiş kontroller ekler. Bu kontroller sayesinde verilerin daha performanslı kullanılması sağlanır. Öncelikle aşağıdaki gibi bir ASP.NET Core Web App (Model-View-Controller) projesi oluşturacağız.

![Create MVC](/assets/img/posts/jstables2.png)
_Create MVC_

Veritabanı işlemlerini bu makalede yapmadan örneğe geçmek için EntityFrameworkCore.InMemory kütüphanesini kullanacağız.

![Nuget Package](/assets/img/posts/jstables3.png)
_Nuget Package_

EntityFramework.Core kütüphanelerini ekledikten sonra `ApplciationDbContext` isminde bir sınıf ekleyeceğiz.

```csharp
using JSDatatables.DataAccess.Entity;
using Microsoft.EntityFrameworkCore;

namespace JSDatatables.DataAccess.Context
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions options):base(options)
        {

        }

        public DbSet<Product> Products { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
        }
    }
}
```

Daha sonra `Product` isminde bir entity sınıfı ekleyeceğiz.

```csharp
namespace JSDatatables.DataAccess.Entity
{
    public class Product
    {
        public int Id { get; set; }
        public string Description { get; set; }
        public double Price { get; set; }
    }
}
```

EntityFramework ile ilgili son işlem olarak `Program.cs` dosyasında DbContext yapılandırmasını tamamlayacağız.

```csharp
builder.Services.AddDbContext<ApplicationDbContext>(options =>
options.UseInMemoryDatabase("memorydb"));
```

HomeController içerisinde `ApplicationDbContext` sınıfımızı Constructor ile ekleyelim.

```csharp
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        ApplicationDbContext context;

        public HomeController(ILogger<HomeController> logger, ApplicationDbContext context)
        {
            _logger = logger;
            this.context = context;
        }
    }
```

Bu işlemden sonra sahte bir veri elde etmek için for döngüsü ile Product ekleme işlemi yapacak olan bir metot oluşturup Index ismindeki Action da çağıracağız.

```csharp
    public IActionResult Index()
    {
        LoadTestData();
        return View();
    }
    void LoadTestData()
    {
        var number = new Random();
        for (int i = 1; i <= 200; i++)
        {
            context.Products.Add(new Product()
            {
                Description = $"Product {Guid.NewGuid().ToString("N")}",
                Price = number.NextDouble(),
            });
        }

        context.SaveChanges();
    }
```

Verileri elde edecek metotu yazdıktan sonra Index ismindeki ActionResult için aynı isimle bir View ekleyeceğiz. Daha sonra `myTable` isminde bir table ekleyip (document).ready fonksiyonu ile Datatables kütüphanesini sayfaya ekleme işlemini yapacağız. Burada `processing: true,        serverSide: true` değerlerine dikkat etmemiz gerekmektedir. Bu şekilde sunucu taraflı işlemler için yapılandırmamızı tamamlayacağız.

```html
@{ ViewData["Title"] = "Datatables"; }

<link
  href="//cdn.datatables.net/1.11.5/css/jquery.dataTables.min.css"
  rel="stylesheet"
/>

<div class="container">
  <div class="table-responsive">
    <table id="myTable" class="table table-bordered">
      <thead>
        <tr>
          <th>Id</th>
          <th>Description"</th>
          <th>Price"</th>
        </tr>
      </thead>
    </table>
  </div>
</div>

@section Scripts{
<script src="//cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
<script>
  $(document).ready(function () {
    $("#myTable").DataTable({
      ajax: {
        url: "Home/GetProducts",
        type: "POST",
      },
      processing: true,
      serverSide: true,
      filter: true,
      columns: [
        { data: "id", name: "Id" },
        { data: "description", name: "Description" },
        { data: "price", name: "Price" },
      ],
    });
  });
</script>

}
```

Daha sonra Datatables için `GetProducts` isminde kayıt listeleyecek ve JsonResult tipinde Post metotu oluşturacağız.

```csharp
[HttpPost]
public JsonResult GetProducts()
{
    var data = context.Set<Product>().AsQueryable();

    var draw = Request.Form["draw"].FirstOrDefault();
    var length = Convert.ToInt32(Request.Form["length"].FirstOrDefault());
    var start = Convert.ToInt32(Request.Form["start"].FirstOrDefault());
    var orderColumnIndex = Request.Form["order[0][column]"].FirstOrDefault();
    var orderDir = Request.Form["order[0][dir]"].FirstOrDefault();
    var orderColumnName = Request.Form[$"columns[{orderColumnIndex}][name]"].FirstOrDefault();
    var searchValue = Request.Form["search[value]"].FirstOrDefault();
    int recordTotal = data.Count();
    int recordsFiltered = data.Count();

    if (!string.IsNullOrEmpty(searchValue))
    {
        data = data.Where(x => x.Description.ToLower().Contains(searchValue.ToLower()));
    }

    if (!string.IsNullOrEmpty(orderColumnName) && !string.IsNullOrEmpty(orderDir))
    {
        data = OrderByField(data, orderColumnName, orderDir == "asc");
    }

    var products = data.Skip(start).Take(length).ToList();

    var result = new
    {
        draw = draw,
        recordsTotal = recordTotal,
        recordsFiltered = recordsFiltered,
        data = products
    };

    return Json(result);
}
```

GetProducts metotunu incelemeden önce `Request.Form` ile aldığımız değerlerin ne anlama geldiğine bakalım.

![Request.Form](/assets/img/posts/jstables4.png){: .left }
![Request.Form](/assets/img/posts/jstables5.png)

Projeyi çalıştırıp `GetProduct` metotuna breakpoint eklediğimizde debuging sırasında Request.Form içeriği resimlerde görüldüğü gibi gelmektedir. Datatables [**dökümanında**](https://datatables.net/examples/data_sources/server_side) yazıldığı üzere draw, recordsTotal, recordsFiltered, data alanlarını içeren bir Json nesnesi beklemektedir.

> Not:Seçili olan sayfa numarasını almak için `start/length` işlemini kullanabiliriz.

IQueryable türündeki entity üzerinde sıralama işlemi yapmak için `OrderByField` fonksiyonunu yazacağız.

```csharp
public IQueryable<T> OrderByField<T>(IQueryable<T> q, string SortField, bool Ascending)
{
    var param = Expression.Parameter(typeof(T), "p");
    var prop = Expression.Property(param, SortField);
    var exp = Expression.Lambda(prop, param);
    string method = Ascending ? "OrderBy" : "OrderByDescending";
    Type[] types = new Type[] { q.ElementType, exp.Body.Type };
    var mce = Expression.Call(typeof(Queryable), method, types, q.Expression, exp);
    return q.Provider.CreateQuery<T>(mce);
}
```

Uygulamayı çalıştırdığımızda Datatables ile verileri görüntüleyebiliriz. Örnek projeyi [**buradan**](https://github.com/muratsuzen/dotnetcore-samples/tree/main/JSDatatables) indirebilirsiniz.

![Datatables](/assets/img/posts/jstables6.png)

Referanslar :

[**https://ronniediaz.com/2011/05/24/orderby-string-in-linq-c-net-dynamic-sorting-of-anonymous-types/**](https://ronniediaz.com/2011/05/24/orderby-string-in-linq-c-net-dynamic-sorting-of-anonymous-types/)
[**https://www.c-sharpcorner.com/article/server-side-rendering-of-datatables-js-in-asp-net-core/**](https://www.c-sharpcorner.com/article/server-side-rendering-of-datatables-js-in-asp-net-core/)
