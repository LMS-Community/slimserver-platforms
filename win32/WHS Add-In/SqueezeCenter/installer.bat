"..\..\WiX\candle.exe" "installer.wxs" -out "bin\Release\install.wixobj"
"..\..\WiX\light.exe" "bin\Release\install.wixobj" -out "bin\Release\SqueezePanel-7.3.3-125.msi"