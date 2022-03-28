$files = "libsneedio.dll", "SDL2.dll", "SDL2_mixer.dll"
$output = "return (function() local dlls = {"
foreach ($f in $files) {
	$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes(".\x64\Release\" + $f))
	$output = $output + "[`"" + $f + "`"]" + "=" + "`""+ $base64string +"`","
}
$output = $output + "}; return dlls; end);"
echo $output