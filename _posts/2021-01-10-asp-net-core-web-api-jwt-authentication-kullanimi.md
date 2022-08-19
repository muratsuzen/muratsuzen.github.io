---
title: ASP.NET Core Web API - JWT Authentication Kullanımı
author: Murat Süzen
date: 2021-01-10 11:33:00 -500
categories: [ASP.NET CORE]
tags: [asp.net core,web api,jwt authentication]
math: true
mermaid: true
---
Merhabalar bu makalede .Net Core 3.1 versiyonu ile bir Web API örnek projede JWT (JSON Web Token) kimlik doğrulama yapısını inceleyeceğim. Daha önceki Web API makalelerine buradan ulaşabilirsiniz. Uygulama dosyalarını aspnetcore-3-1-web-api-jwt Github adresinde bulabilirsiniz.

## ASP.NET Core Web API – User Entity

Kullanıcı bilgilerini taşıdığımız user sınıfını oluşturuyorum. Entity yapıları uygulamanın farklı bölümlerinde veri iletimi için kullanılır. Ayrıca controller yardımıyla http yanıtlarını döndürmek içinde kullanılabilmektedir. Bu sınıfı veritabanındaki User tablosu olarak düşünebilirsiniz. Entities sınfıları Entityframework ile Code First yaklaşımında veritabanı tablolarını oluşturmak için kullandığımız sınıflarıdır. Not: Entities yapılarında kısıtlı veri döndürmek istendiğinde Models klasöründe ihtiyaca yönelik sınıflar kullanılmalıdır.

```csharp
namespace WebApi.Entities
{
    public class User
    {
        public int Id { get; set; }
        public string UserName { get; set; }
        public string Password { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Token { get; set; }
    }
}
```

## ASP.NET Core Web API – Item Entity

Ürün bilgilerini tuttuğumuz Item sınıfını veritabanında Item tablosu olarak düşünebilirsiniz.

```csharp
namespace WebApi.Entities
{
    public class Item
    {
        public int Id { get; set; }
        public string Code { get; set; }
        public string Name { get; set; }
        public float Price { get; set; }
        public int Amount { get; set; }
    }
}
```
## ASP.NET Core Web API – AuthModel

`AuthModel` token bilgisi almak için istemcinin göndermiş olduğu istekte User sınıfının sadece username ve password bilgisini parametre olarak göndermesi için kısıtlı bir sınıftır.

```csharp
public class AuthModel
{
    public string UserName { get; set; }
    public string Password { get; set; }
}
```
## ASP.NET Core Web API – Startup

Startup ​​sınıfı, uygulamanın tüm isteklerin nasıl işleneceğini yapılandırdığımız sınıftır.

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddControllers();
    var appSettingSection = Configuration.GetSection("AppSettings");
    services.Configure<AppSettings>(appSettingSection);
    var appSettings = appSettingSection.Get<AppSettings>();
    var key = Encoding.ASCII.GetBytes(appSettings.Secret);
    services.AddAuthentication(x =>
    {
        x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    }).AddJwtBearer(x =>
    {
        x.RequireHttpsMetadata = false;
        x.SaveToken = true;
        x.TokenValidationParameters = new TokenValidationParameters()
        {
            ValidateIssuerSigningKey = true, IssuerSigningKey = new SymmetricSecurityKey(key), ValidateIssuer = false,
            ValidateAudience = false
        };
    });
    services.AddScoped<IUserService, UserService>();
    services.AddScoped<IItemService, ItemService>();
}
```

```csharp
public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    app.UseAuthentication();
    app.UseAuthorization();
}
```
## ASP.NET Core Web API – UserService

UserService sınıfında IUserService interface dosyasından implement ettikten sonra statik olarak bir User listesi dolduruyorum. Bu User verisi ile Authenticate metodunda UserName ve Password kontrolü ile user nesnesi geriye döndürüyorum.

```csharp
namespace WebApi.Services
{
    public interface IUserService
    {
        User Authenticate(string userName, string password);
        List<User> GetAll();
    }

    public class UserService : IUserService
    {
        readonly AppSettings _appSettings;

        private List<User> _users = new List<User>
            {new User {Id = 1, FirstName = "Murat", LastName = "Suzen", UserName = "murat", Password = "1234"}};

        public UserService(IOptions<AppSettings> appSettings)
        {
            _appSettings = appSettings.Value;
        }

        public User Authenticate(string userName, string password)
        {
            var user = _users.FirstOrDefault(x => x.UserName == userName && x.Password == password);
            if (user == null) return null;
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.UTF8.GetBytes(_appSettings.Secret);
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new Claim[] {new Claim(ClaimTypes.Name, user.Id.ToString())}),
                Expires = DateTime.UtcNow.AddDays(7),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key),
                    SecurityAlgorithms.HmacSha256Signature)
            };
            var token = tokenHandler.CreateToken(tokenDescriptor);
            user.Token = tokenHandler.WriteToken(token);
            user.Password = null;
            return user;
        }

        public List<User> GetAll()
        {
            return _users;
        }
    }
}
```

## ASP.NET Core Web API – ItemService

ItemService sınıfınıd IItemService interface dosyasından implemente ediyorum. Bu sınıfta ürünler listesini geri döndüreceğimiz metodu yazalım.


```csharp
namespace WebApi.Services
{
    public interface IItemService
    {
        List<Item> GetAll();
    }

    public class ItemService : IItemService
    {
        private List<Item> _items = new List<Item>
        {
            new Item {Id = 1, Code = "0001", Name = "Notebook", Amount = 22, Price = 6300},
            new Item {Id = 2, Code = "0002", Name = "Keyboard", Amount = 15, Price = 230},
            new Item {Id = 3, Code = "0003", Name = "Mouse", Amount = 9, Price = 150},
        };

        public List<Item> GetAll()
        {
            return _items.ToList();
        }
    }
}
```

##ASP.NET Core Web API – ItemController

ItemController sınıfı `[Authorize]` attribute ile yetkilendirildiği için UserName ve Password gönderilerek işlem yapılabilir.


```csharp
namespace WebApi.Controllers
{
    [Authorize]
    [Route("[controller]")]
    [ApiController]
    public class ItemController : ControllerBase
    {
        private IItemService _itemService;

        public ItemController(IItemService itemService)
        {
            _itemService = itemService;
        }

        [HttpGet]
        public ActionResult GetAll()
        {
            var users = _itemService.GetAll();
            return Ok(users);
        }
    }
}
```

## ASP.NET Core Web API – UserController

Not: Tüm controller sınıfının `[Authorize]` attribute ile yetkilendirilmesi yanlızca `[AllowAnonymous]` attribute içeren metotları kapsamamaktadır. Çünkü `[AllowAnonymous]` attribute içeren metotlar `[Authorize]` attribute yapısını ezmektedir.

```csharp
[Authorize]
[Route("[controller]")]
[ApiController]
public class UserController : ControllerBase
{
    private IUserService _userService;

    public UserController(IUserService userService)
    {
        _userService = userService;
    }

    [AllowAnonymous]
    [HttpPost("auth")]
    public ActionResult Authenticate([FromBody] AuthModel authModel)
    {
        var user = _userService.Authenticate(authModel.UserName, authModel.Password);
        if (user == null) return BadRequest(new {message = "Kullanıcı adı yada şifre yanlış"});
        return Ok(user);
    }

    [HttpGet]
    public ActionResult GetAll()
    {
        var users = _userService.GetAll();
        return Ok(users);
    }
}
```
## ASP.NET Core Web API – AppSettings

```csharp
public class AppSettings
{
    public string Secret { get; set; }
}
```

## ASP.NET Core Web API – appsettings.json

```json
  "AppSettings": {
    "Secret": "BU ALANA IMZA ICIN BIR ANAHTAR BILGISI GIRMEMIZ GEREKMEKTEDIR"
}
```

## Postman ile Kullanımı

Proje içeren dosyaları indirdiğimizde aspnetcore-3-1-web-api-jwt\WebApi klasöründeki WebApi.sln projesini açıp çalıştırıyoruz. 

![JWT Project Folder](/assets/img/posts/jwt-project-folder.jpg)
_JWT Project Folder_

Postman ile öncelikle user servisine username ve password gönderip bir post işlemi yapıyoruz. Bu şekilde token bilgisini elde etmiş oluyoruz.

![JWT Post Auth](/assets/img/posts/jwt-post-auth.jpg)
_JWT Post Auth_

Daha sonra elde ettiğimiz token bilgisi ile user servisine get işlemi yapıyoruz ve user listelerine erişebiliyoruz.

![JWT Get User](/assets/img/posts/jwt-get-user.jpg)
_JWT Get User_



