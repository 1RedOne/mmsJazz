using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using WebApplication4.Models;

namespace WebApplication4
{
    public class Program
    {
        public static void Main(string[] args)
        {
            //using (var ctx = new SchoolContext())
            //{
            //    var stud = new Student() { StudentName = "Bill" };

            //    ctx.Students.Add(stud);
            //    ctx.SaveChanges();
            //}
            CreateWebHostBuilder(args).Build().Run();
        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>();
    }
}
