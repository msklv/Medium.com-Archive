#  Поиск всех файлов html в папке и подкаталогах
$targetFolder = "/Users/mihailsokolov/git/Medium.com-Archive/posts"
$searchPattern = "*.html"
$imgFolder = "/Users/mihailsokolov/git/Medium.com-Archive/posts/images"
$files = Get-ChildItem -Path $targetFolder -Recurse -Filter $searchPattern 

# Создаем папку для изображений, если она не существует
if (-not (Test-Path -Path $imgFolder -PathType Container)) {
    New-Item -ItemType Directory -Path $imgFolder
}


# Перебираем все найденные файлы
foreach ($filePath in $files.FullName) {

    # Read the file content
    $fileContent = Get-Content -Path $filePath -Raw

    # Define the regular expression to match image URLs
    $imageRegex = '"https:\/\/cdn-images-\d\.medium\.com\/max\/\d+\/[^\s\)]+(?=\")"'

    # Find all matches
    $imageLinks = [regex]::Matches($fileContent, $imageRegex) | ForEach-Object { $_.Value.Trim('"') }

    # Output the results
    $imageLinks | ForEach-Object { 
        Write-Output $_
        
        # Сохраняем в файл в папке images
        $fileName = [System.IO.Path]::GetFileName($_)
        $destinationPath = Join-Path -Path $imgFolder -ChildPath $fileName
        if (-not (Test-Path -Path $destinationPath -PathType Leaf)) {
            Invoke-WebRequest -Uri $_ -OutFile $destinationPath
            Write-Output "Saved: $destinationPath"
        } else {
            Write-Output "Already exists: $destinationPath" -ForegroundColor Yellow
        }
    
    }
}


