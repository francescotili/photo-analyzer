# Photo Analyzer

A Powershell module for photo & video metadata manipulation, renaming and conversion.

## Functions

PhotoAnalyzer is a complex script for analyzing your photos and videos and organize them in a coherent way.

### Metadata analysis

The script utilizes `exiftool` for analyzing the file Metadatas and `HandBrake` for convertion purpouse.

Basically, the script searches the Original DateTime of the file (normally the date/time where the image or video was taken) in the following ways:

1. First it controls file container and file type. It will make conversions if needed (read below)
2. Then it checks EXIF metadata and searches for standard Date/Time metatag
3. If standard EXIF metadata is not found, it tries to parse DateTime from filename
4. If the name of the file is not parsable, then it looks for File Modification date and alternative EXIF tags. In this case, the user must choose which date/time to use or insert manually one.

### Metadata saving and file renaming

Once the script has the date, it proceeds to save this information on the standard EXIF Metadata and rename the file in a coherent way. The format used for renaming is the following: `YYYYMMDD hhmmss+xxx`.

`+xxx` is an incremental number needed for avoid replacing existing files. Sometime, usually with burst-shot photos, the seconds are the same. Thus the incremental number. It can accomodates 999 photos with exactly the same Date/Time information.

### Extension mismatch

The script check also if the extension of the file matches the real file type.

During the development of the script, I've noticed that some Apple devices sometime produce `.heic` files that are basically only `JPEG` internally. Or `.mov` video that are only `MP4` internally.

Thus, the script rename and choose the right extension.

Moreover, I hate uppercase extensions, so they will lowercased ☺

### Video conversion

The writing of `AVI`, `FLV` and `VMW` video files metadata is not supported by `exiftool` (and I suppose it will never be). Though it is an outdated video container, the script will use `HandBrakeCLI` to convert `.avi`, `.flv` and `.wmv` video files to MP4.

The conversion happen with the best settings and also deinterlace detection and decomb, using the following command:

```powershell
HandBrakeCLI -i $inputFile -o $outputFile -d bob -e x264 -q 22 -B 192 2> $null
```

## File supported

The script will search and analyze this type of files:

```powershell
$SupportedExtensions = @("jpg", "JPG", "jpeg", "JPEG", "heic", "HEIC", "png", "PNG", "gif", "GIF", "mp4", "MP4", "m4v", "M4V", "mov", "MOV", "gif", "GIF", "avi", "AVI", "flv", "FLV")
```

## Requirements

- `exiftool.exe` copied in one of PATH folder of Windows • [ExifTool Official Site](https://exiftool.org/)
- `HandBrakeCLI.exe` copied in one of PATH folder of Windows • [HandBrake Official Site](https://handbrake.fr/)
- `magick.exe` copied in one of PATH folder of Windows • [Image Magick Official Site](https://imagemagick.org/index.php)

## Installation

1. Clone the repository or download the lastest `.zip` release
2. Find the Powershell Module folder on your PC
   - The **PSModulePath** powershell environment variable (`$Env:PSModulePath`) contains the locations of Windows PowerShell modules. Cmdlets rely on the value of this einvornment variable to find modules.
   - By default, the _PSModulePath_ environment variable value contains three folder locations:
     1. `$PSHome\Modules` (`%Windir%\System32\WindowsPowerShell\v1.0\Modules`) -> this folder should remain reserved for Powershell modules that ships with Windows
     2. `$Home\Documents\WindowsPowerShell\Modules` (`%UserProfile%\Documents\WindowsPowerShell\Modules`) -> I've used this folder
     3. `$Env:ProgramFiles\WindowsPowerShell\Modules` (`%ProgramFiles%\WindowsPowerShell\Modules`)
3. Copy the module folder into the choosen Powershell Module folder. i.E. `%UserProfile%\Documents\WindowsPowerShell\Modules\ps-photoutils\2.0.0`
4. Download `exiftool(-k).exe` ([⬇ Download here](https://exiftool.org/)), extract and copy its `.exe` onto one of the `PATH` folder of Windows. Then rename it to `exiftool.exe` to enable usage from command line.
5. Download **HandBrake CommandLine** ([⬇ Download here](https://handbrake.fr/downloads2.php)), extract and copy its `HandBrackeCLI.exe` onto one of the `PATH` folder of Windows.
6. You will need to reopen a Cmdlet to let it find the newly installed module.

For additional informations on how to install Powershell Modules, refer to the [official guide](https://docs.microsoft.com/en-us/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7.1).

## Usage

The script exposes a couple of functions for you to use in the Terminal.

### PhotoAnalyzer

The `PhotoAnalyzer` command is the main function of the scrip. Use that to execute the analysis of a folder of your choice (it will ask for the complete path).

There are (not yet) any parameters to specify. Simply type `PhotoAnalyzer`, press ENTER and follow on-screen instructions.

### CleanBackups

The script will not modify the original foto and video files. The original files will be only renamed, changing the extension. i.E. the `.jpg` files will be renamed in `.jpg_original`.

The main `PhotoAnalyzer` function will ask the user, at the end, if it wants to clean the backups file (i.E. deleting them). However, it can come handy to have a function specific for only doing these "Clean up".

Simply type `CleanBackups`, press ENTER and follow on-screen instruction to delete all the `*.*_original` files from a specific path.

### RestoreBackups

If something goes wrong or you simply want to restore these `*.*_original` files, you can do that using the `RestoreBackups` function. The function will rename all the files back to the original extensions.

Simply type `RestoreBackups`, press ENTER and follow on-screen instruction to restore all the `*.*_original` files from a specific path. It works best with folders that only contain the files to be restored, to avoid possible conflicts with filenames when the script restores the original files.

## TODO

- ~~Integrate conversion of `.heic` files into `.jpg` files for better compatibility~~ _done_
- ~~Study if it is possible to make a logic based on `Maker` of the photo/video files for better metatag handling~~ _done_
- ~~Integrate conversion of 4K video files from `H264` to `H265` for future proof compatibily and space saving~~ _discarded for compatibility reasons_
- Implement additional checks on video file to prevent corruption, metatag mismatch (useful for Plex)
- Implement a function for offsetting date/times
- Restore a partially and a fully manual mode
- Publish the script on Powershell Gallery
