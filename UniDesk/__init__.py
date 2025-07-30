import os

qml_module_path = os.path.dirname(os.path.abspath(__file__))
current_path = os.environ.get('QML_IMPORT_PATH', '')
if current_path:
    paths = current_path.split(os.pathsep)
    if qml_module_path not in paths:
        updated_path = current_path + os.pathsep + qml_module_path
    else:
        updated_path = current_path
else:
    updated_path = qml_module_path
os.environ['QML_IMPORT_PATH'] = updated_path