var x = WScript.Arguments(0)
var y = ""
for (var i=x.length-1;i>=0;--i){
    y+=String.fromCharCode(x.charCodeAt(i)^4)
}
WScript.Echo(y)