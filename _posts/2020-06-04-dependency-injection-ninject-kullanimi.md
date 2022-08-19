---
title: Dependency Injection — Ninject Kullanımı
author: Murat Süzen
date: 2020-06-04 11:33:00 -500
categories: [Dependency Injection]
tags: [dependency injection,ninject]
math: true
mermaid: true
---
Merhabalar, yaygın olarak kullanılan kütüphanelerden bir tanesi Ninject'tir. İncelemek için bir önceki Dependency Injection örneğinin aynısı üzerinden gideceğiz. Yaptığımız örnekle çok benzer olduğunu söyleyebilirim. Hatta standart Dependency Injection kullanımına göre birazdaha fazla kod yazdığımızı görebilirsiniz. Fakat kurumsal projelerde yaygın kullanımının arkasında yatan sebep sadece standart kullanımlarından ziyade, projelerimizde birden fazla `loosely coupled` yani `gevşek bağlı` yapıları kullanma gerekinimindeki karmaşıklığı en az seviyieye indirmektedir. Birden fazla gevşek bağlı yapı durumuna örneğimizde deyineceğiz. Öncelikle Nuget paketinden `Install-Package Ninject` şeklinde Ninject paketini projemize indirip kuruyoruz. Daha sonrasında interface ve implemente yapılacak class larımızı oluşturuyoruz.

```csharp
interface ILogger
{
    void WriteLog(string message);
}

class TextLogger : ILogger
{
    public void WriteLog(string message)
    {
        Console.WriteLine("TextLogger : {0}", message);
    }
}

class XmlLogger : ILogger
{
    public void WriteLog(string message)
    {
        Console.WriteLine("XmlLogger : {0}", message);
    }
}

class DatabaseLogger : ILogger
{
    public void WriteLog(string message)
    {
        Console.WriteLine("DatabaseLogger : {0}", message);
    }
}
```

Bu aşamaya kadar bir önceki örneğimizin aynısını yapıyoruz. Daha sonra yine bir önceki örneğimizdeki gibi sınıfları yönetebilmemiz için `LogManager` yapısını oluşturuyoruz.

```csharp
class LogManager  
    {  
        readonly ILogger logger;         
        [Inject]  
        public LogManager(ILogger logger)  
        {  
            this.logger = logger;  
        }        
        public void Handle(string message)  
        {  
            this.logger.WriteLog(message);  
        }  
    }
```

Bu sınıfımızdaki tek fark `[Inject]` tanımımlasıdır. LogManager yapısını kullanırken hangi sınıfı çağıracağımızı `Ninject.Modules.NinjectModule `sınıfınından ayarlayabilmekteyiz. Bu modül sınıfının en güzel yanı daha sonra ihtiyacımız olabilecek birden fazla `gevşek bağlı` yapılarımızın `Bind` işlemlerini yapabilmemizdir.

```csharp
class Bindings : NinjectModule
{
    public override void Load()
    {
        Bind<ILogger>().To<DatabaseLogger>();
    }
}
```

Bu tanımlamanın anlamı `ILogger` tipindeki sınıf istendiğinde otomatik olarak `DatabaseLogger` sınıfını döndürecektir. Daha sonra Main sınıfımızın içerisinde ilgili kodları aşağıdaki gibi oluşturuyoruz.

```csharp
class Program
{
    static void Main(string[] args)
    {
        IKernel kernel = new StandardKernel(new Bindings());
        LogManager logManager = kernel.Get<LogManager>();
        logManager.Handle("İşlem Tamamlandı.");
        Console.ReadLine();
    }
}
```

Bu kod parçasındaki dikkat edilmesi gereken nokta new `StandartKernel` içerisinde load metoduna Bindings sınıfımızı göndermektir. Bu şekilde yapılandırma sınıfını Ninject’e set etmiş oluyoruz. Birden fazla “gevşek bağlı” bir yapıyı aşağıdaki gibi yine NinjectModules yapsısındaki Bindings sınıfımız ile yapılandırabiliriz.


```csharp
interface IConnections
 {
     void GetConnectionString();
 }

 class MsSql : IConnections
 {
     public void GetConnectionString()
     {
         Console.WriteLine("Connection Type: MsSql");
     }
 }

 class EntityFramework : IConnections
 {
     public void GetConnectionString()
     {
         Console.WriteLine("Connection Type: EntityFramework");
     }
 }

 class MySql : IConnections
 {
     public void GetConnectionString()
     {
         Console.WriteLine("Connection Type: MySql");
     }
 }

 class ConnectionManager
 {
     readonly IConnections connections;

     [Inject]
     public ConnectionManager(IConnections connections)
     {
         this.connections = connections;
     }

     public void GetConnectionStr()
     {
         this.connections.GetConnectionString();
     }
 }   
```

Bindings sınıfımız içerisine aynı şekilde diğer `Dependency Injection` yapısının tanımını yapabiliriz.

```csharp
class Bindings : NinjectModule
{
    public override void Load()
    {
        Bind<ILogger>().To<DatabaseLogger>();
        Bind<IConnections>().To<EntityFramework>();
    }
}
```

Main sınıfının içerisinde aynı şekilde yeni eklediğimiz `IConnection` yapımızı işleme alabiliriz.

```csharp
class Program
{
    static void Main(string[] args)
    {
        IKernel kernel = new StandardKernel(new Bindings());
        LogManager logManager = kernel.Get<LogManager>();
        logManager.Handle("İşlem Tamamlandı.");
        ConnectionManager connectionManager = kernel.Get<ConnectionManager>();
        connectionManager.GetConnectionStr();
        Console.ReadLine();
    }
}
```
Bir sonraki makalede görüşmek üzere.