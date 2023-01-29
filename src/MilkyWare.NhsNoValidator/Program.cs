using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using MilkyWare.NhsNoValidator.Core.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddTransient<INhsService, NhsService>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.MapGet("/api/nhsno/validate/{number}", (HttpRequest request, INhsService nhsService, string number) =>
{
    app.Logger.LogInformation("Executing {path}", request.Path);
    var result = nhsService.ValidateNhsNo(number);
    app.Logger.LogInformation("Executed {path}", request.Path);
    return Results.Ok(result);
})
.WithTags("NhsNo");

app.Run();