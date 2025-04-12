# FormatProgramCs - A PowerShell Script for Reformatting Program.cs
 FormatProgramCs is a PowerShell script that reformats Program.cs in .NET projects, organizing builder. and app. chained calls into a clean, readable format with proper indentation. It preserves semicolons, lambda blocks, and removes consecutive blank lines, but has a quirk where app. may be stripped from some chained calls. 

## Features
- Indents `builder.` and `app.` calls 4 spaces under their respective `var builder =` and `var app =` declarations.
- Places each `builder.` and `app.` call on a new line.
- Preserves semicolons exactly as they are in the input.
- Keeps lambda blocks (e.g., `options => { ... }`) intact with their original spacing, adding a 4-space indent.
- Removes consecutive blank lines while preserving intentional ones.
- Logs processing steps to the VS2022 Output Window for debugging.

## Known Quirk
- For chained calls like `app.MapRazorPages() .WithStaticAssets();`, the script may not preserve the `app.` prefix correctly, resulting in `.MapRazorPages()` instead of `app.MapRazorPages()`. This is a known limitation due to the regex-based parsing.

## Prerequisites
- **PowerShell**: Ensure PowerShell is installed (it comes with Windows by default).
- **Visual Studio 2022**: The script is designed to be run as an external tool in VS2022.
- **.NET Project**: The script targets `Program.cs` in a .NET project (tested with .NET 8).

## Installation and Setup

### 1. Download the Script
Clone this repository or download `FormatProgramCs.ps1` to a local directory, e.g., `C:\Users\<YourUsername>\Documents\WindowsPowerShell\Scripts\FormatProgramCs.ps1`.

### 2. Add the Script to Visual Studio 2022 as an External Tool
Follow these steps to integrate the script into VS2022:

1. Open Visual Studio 2022.
2. Go to `Tools` > `External Tools...`.
3. Click `Add` to create a new tool.
4. Fill in the details:
   - **Title**: `Format Program.cs` (this will appear in the Tools menu)
   - **Command**: `powershell.exe`
   - **Arguments**: `-File "C:\Users\<YourUsername>\Documents\WindowsPowerShell\Scripts\FormatProgramCs.ps1" "$(ProjectDir)"`
     - Replace `C:\Users\<YourUsername>\Documents\WindowsPowerShell\Scripts\FormatProgramCs.ps1` with the full path to your script.
     - `$(ProjectDir)` passes the project directory to the script.
   - **Initial directory**: Leave blank or set to `$(ProjectDir)`.
5. Check the box for `Use Output Window` to see the script's logs in VS2022.
6. Click `OK` to save the tool.

## Usage
- Open a .NET project in VS2022.
- Open or select `Program.cs` in the Solution Explorer.
- Go to `Tools` > `Format Program.cs` to run the script.
- Check the Output Window in VS2022 for logs and confirm that `Program.cs` has been reformatted.

## Example
### Input (`Program.cs` Before)
```csharp
using FutaMeetWeb.Hubs;
using FutaMeetWeb.Services;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddRazorPages();
builder.Services.AddSingleton<SessionService>();
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(4);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});
builder.Services.AddSignalR();

var app = builder.Build();
app.UseHttpsRedirection(); app.UseRouting();
app.UseAuthorization();
app.MapStaticAssets();
app.UseSession();
app.MapHub<SessionHub>("/SessionHub");
app.MapRazorPages()
  .WithStaticAssets();
app.Run();
```

### Output (`Program.cs` After)
```csharp
using FutaMeetWeb.Hubs;
using FutaMeetWeb.Services;

var builder = WebApplication.CreateBuilder(args);
    builder.Services.AddRazorPages();
	builder.Services.AddSingleton<SessionService>();
	builder.Services.AddDistributedMemoryCache();
	builder.Services.AddSession(options =>
	{
	    options.IdleTimeout = TimeSpan.FromMinutes(4);
	    options.Cookie.HttpOnly = true;
	    options.Cookie.IsEssential = true;
	});
	builder.Services.AddSignalR();

var app = builder.Build();
	app.UseHttpsRedirection();
	app.UseRouting();
	app.UseAuthorization();
	app.MapStaticAssets();
	app.UseSession();
	app.MapHub<SessionHub>("/SessionHub");
	app.MapRazorPages();
		.WithStaticAssets();
app.Run();
```
-- as you can see all calls fall exacly below their respective declarations, this is more readable for me,well one man's food is another Man's Poison, try this out 

## Contributing
Feel free to fork this repository, make improvements, and submit pull requests. If you encounter issues or have suggestions, please open an issue on GitHub.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
