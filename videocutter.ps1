function ConvertToSeconds {
    param (
        [string]$time
    )

    $parts = $time -split "[:]"
    switch ($parts.Length) {
        1 { return [int]$parts[0] }
        2 { return [int]$parts[0] * 60 + [int]$parts[1] }
        3 { return [int]$parts[0] * 3600 + [int]$parts[1] * 60 + [int]$parts[2] }
        default { throw "無効な時間形式です。" }
    }
}

param (
    [string[]]$args
)

if ($args.Length -eq 0) {
    Write-Host "使用方法：ファイルをスクリプトにドラッグ＆ドロップしてください。"
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

$file = $args[0]
$fileName = [System.IO.Path]::GetFileNameWithoutExtension($file)
$fileExtension = [System.IO.Path]::GetExtension($file)

Write-Host "ファイルが選択されました: $file"

$selection = Read-Host "1: 30秒間を切り抜く  2:指定した時間切り抜く"

if ($selection -eq "1") {
    $start = Read-Host "開始時間を入力してください (例: 1:23:10または秒数)"
    $startSeconds = ConvertToSeconds $start
    $cmd = "ffmpeg -i `"$file`" -ss $startSeconds -t 30 -c:v libx264 -c:a aac -vcodec hevc_nvenc `"$fileName`_cut$fileExtension`" -hide_banner"
    Invoke-Expression $cmd
    Write-Host "終了するには何かキーを押してください"
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
} elseif ($selection -eq "2") {
    $start = Read-Host "開始時間を入力してください (例: 1:23:10または秒数)"
    $end = Read-Host "終了時間を入力してください (例: 1:23:10または秒数)"
    $startSeconds = ConvertToSeconds $start
    $endSeconds = ConvertToSeconds $end
    # エンコードしなおさないと、キーフレームがずれる
    # -vcodec hevc_nvencを入れるとGPU使用
    $cmd = "ffmpeg -i `"$file`" -ss $startSeconds -to $endSeconds -c:v libx264 -c:a aac -vcodec hevc_nvenc `"$fileName`_cut$fileExtension`" -hide_banner"
    Invoke-Expression $cmd
    Write-Host "終了するには何かキーを押してください"
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
} else {
    Write-Host "正しい数字を入力してください"
}
