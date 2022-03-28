#$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FileName))
$files = Get-ChildItem ".\x64\Release\*.dll" -exclude "libsneedio.dll","SDL2_mixer.dll","SDL2.dll"
$output = "return (function() local dlls = {"
foreach ($f in $files) {
	$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($f))
	$output = $output + "[`"" + $f.Name + "`"]" + "=" + "`""+ $base64string +"`","
}
$output = $output + "}; "

$files = Get-ChildItem ".\x64\Release\*.pdb"
$output = $output + "local pdb = {"
foreach ($f in $files) {
	$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($f))
	$output = $output + "[`"" + $f.Name + "`"]" + "=" + "`""+ $base64string +"`","
}
$output = $output + "}; "

$files = Get-ChildItem ".\x64\Release\*.bat"
$output = $output + "local bat = {"
foreach ($f in $files) {
	$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($f))
	$output = $output + "[`"" + $f.Name + "`"]" + "=" + "`""+ $base64string +"`","
}
$output = $output + "}; "

$files = Get-ChildItem ".\x64\Release\*.txt"
$output = $output + "local txt = {"
foreach ($f in $files) {
	$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($f))
	$output = $output + "[`"" + $f.Name + "`"]" + "=" + "`""+ $base64string +"`","
}
$output = $output + "}; return dlls, pdb, txt, bat; end);"


echo $output