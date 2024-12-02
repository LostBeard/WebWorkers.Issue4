# WebWorkers.Issue4

### Bug: 
.Net 9 Blazor WASM compression build task fails due to issue handling of Razor Class Library Nuget packages that use `<StaticWebAssetBasePath>/</StaticWebAssetBasePath>` when referenced by another Razor Class Library

### Steps to reproduce
1. Create a solution with a .Net 9 Razor Class Library (RCL) and set `<StaticWebAssetBasePath>/</StaticWebAssetBasePath>` in its `.csproj`.
2. Publish the RCL as a Nuget package (publishing locally is fine)
3. Create a new solution with an .Net 9 Razor Class Library and a .Net 9 Blazor WASM
4. In the RCL, reference the Nuget package from step 2
5. In the Blazor WASM app reference the RCL project in the same solution
6. Publish the Blazor WASM

You get an exception similar to:  
```
D:\users\tj\Projects\Issue4\WebWorkers.Issue4\WebWorkers.Issue4>dotnet publish --nologo --configuration Release --output "D:\users\tj\Projects\Issue4\WebWorkers.Issue4\WebWorkers.Issue4\bin\Publish\"
Restore complete (0.5s)
  RazorClassLibrary1 net9.0 succeeded (3.3s) → D:\users\tj\Projects\Issue4\WebWorkers.Issue4\RazorClassLibrary1\bin\Release\net9.0\RazorClassLibrary1.dll
  RazorClassLibrary1 net9.0 succeeded (0.1s) → D:\users\tj\Projects\Issue4\WebWorkers.Issue4\RazorClassLibrary1\bin\Release\net9.0\RazorClassLibrary1.dll
  WebWorkers.Issue4 failed with 1 error(s) and 1 warning(s) (0.6s)
    C:\Program Files\dotnet\sdk\9.0.100\Sdks\Microsoft.NET.Sdk.StaticWebAssets\targets\Microsoft.NET.Sdk.StaticWebAssets.Compression.targets(323,5): warning : Endpoints not found for compressed asset: example.JsInterop.faux.js.gz D:\users\tj\Projects\Issue4\WebWorkers.Issue4\WebWorkers.Issue4\obj\Release\net9.0\compressed\87ntuufp02-gq62o8712c.gz
    C:\Program Files\dotnet\sdk\9.0.100\Sdks\Microsoft.NET.Sdk.StaticWebAssets\targets\Microsoft.NET.Sdk.StaticWebAssets.Compression.targets(323,5): error MSB4018:
      The "ApplyCompressionNegotiation" task failed unexpectedly.
      System.InvalidOperationException: Endpoints not found for compressed asset: D:\users\tj\Projects\Issue4\WebWorkers
      .Issue4\WebWorkers.Issue4\obj\Release\net9.0\compressed\87ntuufp02-gq62o8712c.gz
         at Microsoft.AspNetCore.StaticWebAssets.Tasks.ApplyCompressionNegotiation.Execute()
         at Microsoft.Build.BackEnd.TaskExecutionHost.Execute()
         at Microsoft.Build.BackEnd.TaskBuilder.ExecuteInstantiatedTask(TaskExecutionHost taskExecutionHost, TaskLogging
      Context taskLoggingContext, TaskHost taskHost, ItemBucket bucket, TaskExecutionMode howToExecuteTask)
  WebWorkers.Issue4 failed (9.7s) → bin\Release\net9.0\wwwroot

Build failed with 1 error(s) and 1 warning(s) in 15.4s
```

A workaround that will enable a publish build is to modify the `.csproj` of the Nuget package project.  

Changing:  
`<StaticWebAssetBasePath>/</StaticWebAssetBasePath>`  

To:  
`<StaticWebAssetBasePath>/./</StaticWebAssetBasePath>`  

!! IMPORTANT
The above workaround breaks debugging. Assets from the Nuget package will be correctly added to publish builds but will fail to load in debug builds.

## Demo projects
The projects in this repo demonstrate this bug. 

RazorClassLibrary2 is the project that needs to be packaged as a Nuget package and that package (not the project) referenced by RazorClassLibrary1. 

If `<StaticWebAssetBasePath>` is set to `/` in the referenced RazorClassLibrary2 Nuget package, the `publish` of `WebWorkers.Issue4` will fail. 

Using a RazorClassLibrary2 Nuget package with  `<StaticWebAssetBasePath>/./</StaticWebAssetBasePath>` and the publish succeeds. But debugging will fail (404 for the Nuget web assets).

