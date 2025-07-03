import os
with open("./resources.qrc","w",encoding="utf-8") as f:
    f.write("""<RCC>
    <qresource prefix='/'>
        <file>main/main.qml</file>\n""")
    for i,j,k in os.walk("media"):
        if j==[]:
            for p in k:
                f.write("        <file>"+i.replace("\\","/")+"/"+p+"</file>\n")
    f.write("""    </qresource>
</RCC>""")
        
os.system("pyside6-rcc resources.qrc -o main/res.py")
