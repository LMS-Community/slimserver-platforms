"..\..\WiX\candle.exe" "installer.wxs" -out "bin\Release\install.wixobj"
"..\..\WiX\light.exe" "bin\Release\install.wixobj" -out "bin\Release\SqueezePanel-7.4-142.msi"