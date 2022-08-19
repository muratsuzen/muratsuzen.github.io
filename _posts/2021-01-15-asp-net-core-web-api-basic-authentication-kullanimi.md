---
title: ASP.NET Core Web API - Basic Authentication Kullanımı
author: Murat Süzen
date: 2021-01-15 11:33:00 -500
categories: [ASP.NET CORE]
tags: [asp.net core,web api,basic authentication]
math: true
mermaid: true
---
Merhabalar bu makalede .Net Core 3.1 versiyonu ile bir Web API örnek projede Basic kimlik doğrulama yapısını inceleyeceğim. Bir önceki [**ASP.NET Core 3.1 Web API – JWT Authentication Kullanımı**](../asp-net-core-web-api-jwt-authentication-kullanimi/) makalesini inceleyebilirsiniz. Uygulama dosyalarını [**aspnetcore-3-1-web-api-basic**](https://github.com/muratsuzen/dotnetcore-samples/tree/main/aspnetcore-3-1-web-api-basic/WebApi) Github adresinde bulabilirsiniz.

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
    services.AddAuthentication("BasicAuthentication")
        .AddScheme<AuthenticationSchemeOptions, BasicAuthHandler>("BasicAuthentication", null);
    services.AddScoped<IUserService, UserService>();
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
public interface IUserService { User Authenticate(string userName, string password); List<User> GetAll(); }

public class UserService : IUserService
{
    private List<User> _users = new List<User>
        {new User {Id = 1, FirstName = "Murat", LastName = "Suzen", UserName = "murat", Password = "1234"}};

    public User Authenticate(string userName, string password)
    {
        var user = _users.FirstOrDefault(x => x.UserName == userName && x.Password == password);
        return user;
    }

    public List<User> GetAll()
    {
        return _users;
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
## ASP.NET Core Web API – ItemController
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
## ASP.NET Core Web API – BasicAuthHandler

Oluşturmuş olduğumuz BasicAuthHandler sınıfı ile AuthenticationSchemeOptions özelliğini kullanarak HandleAuthenticate yapısı ile kimlik doğrulama işlemlerini yapacağız. Aşağıdaki kod bloğunda görebileceğiniz üzere Request.Headers içerisinde Authorization keyini yakalamaya çalışıp değerini AuthenticationHeaderValue.Parse metodu ile parametre değerine ulaşıyorum. Kullanıcı adı ve şifreyi “:” karakteri ile birleştirdiğim için örn:(murat:1234) split ile ayrıştırp kullanıcı adı ve şifreyi alıyorum. Kullanıcı bilgileri ile bir claim oluşturup `AuthenticationTicket` ile yeni bir Ticket oluşturuyorum ve AuthenticateResult.Success(ticket) ile döndürüyorum.

```csharp
public class BasicAuthHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    private readonly IUserService _userService;

    public BasicAuthHandler(IOptionsMonitor<AuthenticationSchemeOptions> options, ILoggerFactory logger,
        UrlEncoder encoder, ISystemClock clock, IUserService userService) : base(options, logger, encoder, clock)
    {
        _userService = userService;
    }

    protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        User user = null;
        StringValues values;
        if (!Request.Headers.TryGetValue("Authorization", out values))
        {
            return AuthenticateResult.Fail("Authorization Header Bulunmamaktadır");
        }

        try
        {
            var authHeader = AuthenticationHeaderValue.Parse(values.First());
            var tokenBytes = Convert.FromBase64String(authHeader.Parameter);
            var tokenSplit = Encoding.UTF8.GetString(tokenBytes).Split(new[] {':'}, 2);
            var username = tokenSplit[0];
            var password = tokenSplit[1];
            user = _userService.Authenticate(username, password);
        }
        catch
        {
            return AuthenticateResult.Fail("Geçersiz Authorization Header");
        }

        if (user == null) return AuthenticateResult.Fail("Kullanıcı adı yada şifre geçersiz");
        var claims = new[]
            {new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()), new Claim(ClaimTypes.Name, user.UserName),};
        var identity = new ClaimsIdentity(claims, Scheme.Name);
        var principal = new ClaimsPrincipal(identity);
        var ticket = new AuthenticationTicket(principal, Scheme.Name);
        return AuthenticateResult.Success(ticket);
    }
}
```

Kaynak :

<https://jasonwatmore.com/post/2019/10/21/aspnet-core-3-basic-authentication-tutorial-with-example-api/>

<https://codeburst.io/adding-basic-authentication-to-an-asp-net-core-web-api-project-5439c4cf78ee?gi=f08f27a55a69/>