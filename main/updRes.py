import os
import glob
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
with open("./unidesk_qml/qmldir","w",encoding="utf-8") as f:
    f.write("""module unidesk_qml\n""")
    for file in glob.glob(os.path.join("./unidesk_qml","*.qml")):
        f.write(os.path.basename(file).replace(".qml","")+" 1.0 "+os.path.basename(file)+"\n")
os.system("pyside6-rcc resources.qrc -o main/res.py")
