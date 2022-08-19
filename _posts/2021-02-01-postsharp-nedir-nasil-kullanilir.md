---
title: PostSharp Nedir? Nasıl Kullanılır?
author: Murat Süzen
date: 2021-02-01 11:33:00 -500
categories: [ASP.NET CORE]
tags: [asp.net core,postsharp]
math: true
mermaid: true
---

Merhabalar, sizlere bu makalede benimde projelerimde kullandığım PostSharp Framework içerisindeki Aspect yapısını örneklerle anlatmaya çalışacağım. Bu yapı sayesinde bir metot yada sınıfa attribute ekleyerek işlem aşamalarında yada alınabilecek hata durumlarında farklı aksiyonlar alabiliriz. Ben kendi projemde Logging ve Authorization yapıları için kullanıyorum.

## PostSharp Kurulumu

Nuget üzerinden aşağıdaki kod bloğu ile kurulumu yapıyorum.

```shell
Install-Package PostSharp -Version 6.7.10
```

Paket kurulumundan sonra Visual Studio eklentisini kurmalıyız. Buradaki adresten eklentiyi indirip kurulumunu yaptığımızda lisans bilgilerini girmem gerekiyor. PostSharp ücretli bir kütüphanedir. Ancak 1000 satırlık kod limiti ile yada öğrenci, öğretmen, freelancer, MVP gibi ayrıcalıklı olarak ücretsiz kullanabilirsiniz.

## OnMethodBoundaryAspect

Attribute olarak tanımladığımız bir metodun işlem adımlarını takip edebileceğimiz sınıftır. Aşağıda görüldüğü gibi OnEntry, OnSuccess, OnExit, OnException override metodları ile istediğimiz metodun özelliklerine erişebilmekteyiz.

```csharp
[PSerializable]
public class LoggingAspect : OnMethodBoundaryAspect
{
    public override void OnEntry(MethodExecutionArgs args)
    {
        Console.WriteLine("{0} : OnEntry", args.Method.Name);
    }

    public override void OnSuccess(MethodExecutionArgs args)
    {
        Console.WriteLine("{0} OnSuccess", args.Method.Name);
    }

    public override void OnExit(MethodExecutionArgs args)
    {
        Console.WriteLine("{0} OnExit", args.Method.Name);
    }

    public override void OnException(MethodExecutionArgs args)
    {
        Console.WriteLine("{0} OnException", args.Method.Name);
    }

    public override void OnResume(MethodExecutionArgs args)
    {
        Console.WriteLine("{0} OnResume", args.Method.Name);
    }
}

class Program
{
    [LoggingAspect]
    static void Main(string[] args)
    {
        Console.WriteLine("Hello World!");
    }
}
```

Yukarıdaki `OnMethodBoundaryAspect` sınıfına ilişkin kendi projelerimde kullanmış olduğum SecuredOperation örneğini inceleyelim. *Not: Kullanmış olduğum versiyon : v4.2.17.0*


```csharp
[Serializable]
public class SecuredOperation : OnMethodBoundaryAspect
{
    public string Roles { get; set; }

    public override void OnEntry(MethodExecutionArgs args)
    {
        string[] roles = Roles.Split(',');
        bool isAuthorized = false;
        for (int i = 0; i < roles.Length; i++)
        {
            if (System.Threading.Thread.CurrentPrincipal.IsInRole(roles[i]))
            {
                isAuthorized = true;
            }
        }

        if (!isAuthorized)
        {
            throw new SecurityException("You aren't authorized!");
        }
    }
}
```

UserManager sınıında aşağıdaki gibi tanımlamış olduğum sınıflardaki metodlara OnEntry ile girip CurrentPrincipal içerisinde belirli rollerin tanımlı olup olmadığını kontrol ediyorum.

```csharp
public class UserManager : IUserService
{
    private readonly IUserDal _userDal;

    [SecuredOperation(Roles = "Admin,User")]
    public List<User> GetAll()
    {
        var users = _mapper.Map<List<User>>(_userDal.GetAll());
        return users;
    }
}
```
Metod bazında yapıldığı gibi ayrıca sınıfın geneli için de tanımlama yapılabilir.

```csharp
[SecuredOperation(Roles = "Admin,User")]
public class UserManager : IUserService
{
    private readonly IUserDal _userDal;

    public List<User> GetAll()
    {
        var users = _mapper.Map<List<User>>(_userDal.GetAll());
        return users;
    }
}
```

Principal tanımlamasını aşağıdaki şekilde yapabiliriz.

```csharp
IPrincipal principal = new GenericPrincipal(new GenericIdentity("Admin"), new string[] { "Admin" }); 
Thread.CurrentPrincipal = principal;
```

Bir sonraki makalede görüşmek üzere.