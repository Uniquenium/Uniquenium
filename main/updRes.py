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
with open("./UniDesk/qmldir","w",encoding="utf-8") as f:
    f.write("""module UniDesk\n""")
    for file in glob.glob(os.path.join("./UniDesk","*.qml")):
        f.write(os.path.basename(file).replace(".qml","")+" 1.0 "+os.path.basename(file)+"\n")
print("Regenerate main/res.py started")
# os.system("pyside6-rcc resources.qrc -o main/res.py")
print("Regenerate main/res.py finished")
