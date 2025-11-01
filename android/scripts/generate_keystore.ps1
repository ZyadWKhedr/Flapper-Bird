$pw=(New-Guid).Guid.Replace('-','')
$alias='key0'
$dname='CN=Flappy Bird, OU=Dev, O=YourOrg, L=City, S=State, C=US'
Write-Host "Generating keystore at android/key.jks with alias $alias"
keytool -genkeypair -v -keystore android/key.jks -storepass $pw -keypass $pw -alias $alias -keyalg RSA -keysize 2048 -validity 10000 -dname "$dname"
$content = "storePassword=$pw`nkeyPassword=$pw`nkeyAlias=$alias`nstoreFile=key.jks"
Set-Content -Path android/key.properties -Value $content -Encoding ascii
Write-Host "Wrote android/key.properties (keep this file secret)"
Write-Host "Done."