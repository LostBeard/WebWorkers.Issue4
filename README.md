# WebWorkers.Issue4

This issue started as a report about an [issue (#4)](https://github.com/LostBeard/SpawnDev.BlazorJS.WebWorkers/issues/4) with [SpawnDev.BlazorJS.WebWorkers](https://github.com/LostBeard/SpawnDev.BlazorJS.WebWorkers) but the issue may actually lie in a .Net 9 SDK build task.

Repo: [WebWorkers.Issue4](https://github.com/LostBeard/WebWorkers.Issue4)

## Issue 
The .Net 9 Blazor WASM compression build task, `ApplyCompressionNegotiation`, fails due to an unknown issue handling Razor Class Library Nuget packages that use `<StaticWebAssetBasePath>/</StaticWebAssetBasePath>` when referenced by another Razor Class Library

## 3 Ways To Reproduce This Issue
- [Quick Start](#quick-start) - fastest way to see the issue and a possible workaround
- [Steps To Reproduce From Scratch](#steps-to-reproduce-from-scratch) - create projects from scratch
- [Repo Demo Projects](#repo-demo-projects) - uses this repo and demo Nuget project

### Quick Start
How to demo the issue with this repo [WebWorkers.Issue4](https://github.com/LostBeard/WebWorkers.Issue4):
To see the issue:  
- Clone repo
- Run `_publish.bat` in `WebWorkers.Issue4` folder to do a Release `publish` build
- `The "ApplyCompressionNegotiation" task failed unexpectedly ...`

Test workaround 1:
- Uncomment `<CompressionEnabled>false</CompressionEnabled>` in `RazorClassLibrary1.csproj`
- Run `_publish.bat` in `WebWorkers.Issue4` folder to do a Release `publish` build
- `Build succeeded`

Test workaround 2:
- Remove `net9.0` from `<TargetFrameworks>net8.0;net9.0</TargetFrameworks>` in `RazorClassLibrary1.csproj`
- Run `_publish.bat` in `WebWorkers.Issue4` folder to do a Release `publish` build
- `Build succeeded`

### Steps To Reproduce From Scratch
1. Create a solution with a .Net 9 Razor Class Library (RCL) and set `<StaticWebAssetBasePath>/</StaticWebAssetBasePath>` in its `.csproj`.
2. Publish the RCL as a Nuget package (publishing locally is fine)
3. Create a new solution with an .Net 9 Razor Class Library and a .Net 9 Blazor WASM
4. In the RCL, PackageReference to the Nuget package from step 2 (a ProjectReference does not trigger the bug)
5. In the Blazor WASM app add a ProjectReference to the RCL project in the same solution
6. Run `dotnet publish --nologo --configuration Release --output bin\Publish` in the Blazor WASM app folder to see the error. 

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

7. Workaround: Disable compression (`<CompressionEnabled>false</CompressionEnabled>`) in the 2nd solution's Razor Class Library's `.csproj` and the publish will succeed and all static web assets will compress normally.

### Repo Demo Projects
The projects in this repo demonstrate this bug. 

#### WebWorkers.Issue4 - Blazor WASM App
The .Net 9 Blazor WASM project `WebWorkers.Issue4` references the RCL project `RazorClassLibrary1` and has compression enabled with `<CompressionEnabled>true</CompressionEnabled>` (default if omitted.)

#### RazorClassLibrary1 - RCL
`RazorClassLibrary1` is a Razor Class Library that references any Nuget package RCL that uses `<StaticWebAssetBasePath>/</StaticWebAssetBasePath>`.  
This can be a Nuget packaged `RazorClassLibrary2`, but it must be a `PackageReference` not a `ProjectReference`. Alternatively it can be `SpawnDev.BlazorJS.WebWorkers` version `2.5.22`.

#### RazorClassLibrary2 - RCL Nuget Package
`RazorClassLibrary2` is a minimal Razor Class Library to demonstrate the issue. It is a bare RCL that uses `<StaticWebAssetBasePath>/</StaticWebAssetBasePath>`. It needs to be packaged as a Nuget package and that package (not the project) must be referenced by `RazorClassLibrary1`. 

#### RazorClassLibrary2 Alternative
To demonstrate the bug without requiring creating a Nuget package using `RazorClassLibrary2`, the package `<PackageReference Include="SpawnDev.BlazorJS.WebWorkers" Version="2.5.22" />` (which uses `<StaticWebAssetBasePath>/</StaticWebAssetBasePath>`) can be referenced by `RazorClassLibrary1`.

#### Publish to see bug
Run `dotnet publish --nologo --configuration Release --output bin\Publish` in the `WebWorkers.Issue4` folder to see the error. 

#### Workaround
Disable compression (`<CompressionEnabled>false</CompressionEnabled>`) in `RazorClassLibrary1.csproj` and the publish will succeed and all static web assets will compress normally.

#### TL;DR
If you get the error `Endpoints not found for compressed asset` during a Blazor `publish` build, a possible fix is to modify your Razor Class Library's `.csproj`:  
```xml
<PropertyGroup>
  <CompressionEnabled>false</CompressionEnabled>
</PropertyGroup>
```
It does not affect, or disable compression of any part of the Blazor app, but it does prevent the `Endpoints not found for compressed asset` error.

This issue does not exist in .Net 8 or earlier.
