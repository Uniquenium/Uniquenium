import os
import glob
import json
with open("./resources.qrc","w",encoding="utf-8") as f:
    f.write("""<RCC>
    <qresource prefix='/'>
            """)
    for i,j,k in os.walk("media"):
        if j==[]:
            for p in k:
                f.write("        <file>"+i.replace("\\","/")+"/"+p+"</file>\n")
    f.write("""    </qresource>
</RCC>""")
with open("./UniDesk/Controls/qmldir","w",encoding="utf-8") as f:
    f.write("""module UniDesk.Controls\n""")
    for file in glob.glob(os.path.join("./UniDesk/Controls","*.qml")):
        f.write(os.path.basename(file).replace(".qml","")+" 1.0 "+os.path.basename(file)+"\n")
with open("./UniDesk/Singletons/qmldir","w",encoding="utf-8") as f:
    f.write("""module UniDesk.Singletons\n""")
    for file in glob.glob(os.path.join("./UniDesk/Singletons","*.qml")):
        f.write("singleton "+os.path.basename(file).replace(".qml","")+" 1.0 "+os.path.basename(file)+"\n")
with open(".pyproject","w",encoding="utf-8") as f:
    a={"files":[]}
    for root, dirs, files in os.walk("./"):
        for file in files:
            if file.endswith(".py") or file.endswith(".qml") or file.endswith(".qrc"):
                a["files"].append(os.path.join(root, file).replace("\\","/"))
    json.dump(a, f, indent=4)
