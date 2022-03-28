$files = Get-ChildItem ".\yt-dlpbin\*.exe"
$output = "return (function() local exes = {"
foreach ($f in $files) {
	$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($f))
	$output = $output + "[`"" + $f.Name + "`"]" + "=" + "`""+ $base64string +"`","
}
$output = $output + "}; return exes; end);"

echo $output