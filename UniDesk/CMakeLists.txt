qt_standard_project_setup()

# Create Qt6 library target
qt_add_library(${TARGET} SHARED)

# 使用 JSON 文件代替 components-list
# file(STRINGS Components/components-list COMPONENT_LIST)

set(UNIDESK_ROOT ${CMAKE_CURRENT_SOURCE_DIR})
# set(component_lib_list "")
# set(component_dir_list "")
# foreach(line IN LISTS COMPONENT_LIST)
#     # list(APPEND component_lib_list ${TARGET}${line})
#     list(APPEND component_dir_list ${CMAKE_CURRENT_SOURCE_DIR}/Components/${line})
# endforeach()

target_link_libraries(${TARGET}
        PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::DBus
        Qt6::Widgets
        PRIVATE
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::GuiPrivate
        Qt6::Core5Compat
        Qt6::LabsPlatform
        QHotkey::QHotkey
        )
target_include_directories(${TARGET} 
        PRIVATE 
        ${QHOTKEY_INCLUDE_DIR} 
        ${CMAKE_CURRENT_SOURCE_DIR}/CppExt 
        # ${component_dir_list}
        ${EXPRTK_INCLUDE}
        )

if (UNIX)
    if (NOT APPLE)
        target_link_libraries(${TARGET} PRIVATE Qt6::Gui Qt6::GuiPrivate)
        if (KF6WindowSystem_FOUND)
            target_link_libraries(${TARGET} PRIVATE KF6::WindowSystem)
        endif ()
    endif ()
endif ()

# Clear the list of source files
set(sources_files "")
set(qml_files "")
set(resource_files "")



#遍历所有Cpp文件
file(GLOB CPP_FILES CppExt/*.cpp Components/*/*.cpp)
foreach (filepath ${CPP_FILES})
    string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" filename ${filepath})
    list(APPEND sources_files ${filename})
endforeach (filepath)

#遍历所有h文件
file(GLOB H_FILES CppExt/*.h Components/*/*.h)
foreach (filepath ${H_FILES})
    string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" filename ${filepath})
    list(APPEND sources_files ${filename})
endforeach (filepath)

file(GLOB SINGLETON_PATHS Singletons/*.qml)
set(SINGLETON_FILES "")
foreach(filepath ${SINGLETON_PATHS})
    string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" singleton_name ${filepath})
    list(APPEND SINGLETON_FILES ${singleton_name})
endforeach()

#遍历所有qml文件
file(GLOB_RECURSE QML_PATHS Controls/*.qml Singletons/*.qml qmldir Components/*/*.qml Components/*/qmldir)
foreach (filepath ${QML_PATHS})
    string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" filename ${filepath})
    if (${filename} MATCHES "qmldir")
        list(APPEND resource_files ${filename})
    else ()
        list(APPEND qml_files ${filename})
        # Check for singleton
        foreach (singleton_name ${SINGLETON_FILES})
            if (${filename} MATCHES ${singleton_name})
                set_source_files_properties(${filename} PROPERTIES QT_QML_SINGLETON_TYPE true)
            endif ()
        endforeach (singleton_name)
    endif ()
endforeach (filepath)

#遍历所有资源文件
set(RES_SUFFIX "")
set(RES_PATHS "")
list(APPEND RES_SUFFIX *.png *.jpg *.svg *.ico *.ttf *.webp *.js *.qm *.qsb)
list(APPEND RES_PATHS ../media/font ../media/img ../media/logo)
foreach (respath ${RES_PATHS})
    foreach (filesuffix ${RES_SUFFIX})
        file(GLOB_RECURSE RES_FOUND ${respath}/${filesuffix})
        foreach (filepath ${RES_FOUND})
            string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" filename ${filepath})
            list(APPEND resource_files ${filename})
        endforeach()
    endforeach ()
endforeach (respath)


# list(APPEND sources_files "${EXPRTK_INCLUDE}")
# set_source_files_properties(${TS_FILES}
#     PROPERTIES OUTPUT_LOCATION "${CMAKE_CURRENT_BINARY_DIR}/translations")
# 生成翻译文件
qt_add_translations(${TARGET}
    TS_FILES ${TS_FILES}
    SOURCES ${sources_files} ${qml_files}
    RESOURCE_PREFIX "/uniquenium/i18n"
)

list(APPEND resource_files )
# 将QM文件添加到资源文件
# 为每个QM文件设置QT_RESOURCE_ALIAS属性，使用相对路径以便资源系统正确访问
foreach(qm_file ${QM_FILES})
    # 获取文件名（不含路径）
    get_filename_component(qm_filename ${qm_file} NAME)
    # 设置资源别名，使QM文件在资源系统中可通过相对路径访问
    set_source_files_properties(${qm_file} PROPERTIES
        QT_RESOURCE_ALIAS "translations/${qm_filename}"
    )
    list(APPEND ${qm_file})
endforeach()

# 在CMake配置阶段自动运行lupdate，确保TS文件被填充
# 这样在Qt Creator中配置项目时，翻译字符串会自动提取
get_target_property(_lupdate_exe Qt6::lupdate LOCATION)
if(_lupdate_exe)
    # 将相对路径转换为绝对路径（sources_files和qml_files是相对于UniDesk/目录的）
    set(_all_sources "")
    foreach(_file ${sources_files} ${qml_files})
        list(APPEND _all_sources "${CMAKE_CURRENT_SOURCE_DIR}/${_file}")
    endforeach()
    # 添加根目录的main.qml
    list(APPEND _all_sources "${CMAKE_CURRENT_SOURCE_DIR}/../main.qml")
    list(APPEND _all_sources "${CMAKE_CURRENT_SOURCE_DIR}/../launcher.cpp")
    
    # 运行lupdate提取翻译字符串
    execute_process(
        COMMAND ${_lupdate_exe} ${_all_sources} -ts ${TS_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        RESULT_VARIABLE _lupdate_result
        OUTPUT_VARIABLE _lupdate_output
        ERROR_VARIABLE _lupdate_error
    )
    
    if(_lupdate_result EQUAL 0)
        message(STATUS "lupdate completed successfully.")
    else()
        message(WARNING "lupdate failed with exit code ${_lupdate_result}.\nError: ${_lupdate_error}")
    endif()
else()
    message(WARNING "Qt6::lupdate not found, translation files will not be updated.")
endif()

# Set Qt6 QMl Plugins
qt_add_qml_module(${TARGET}
    PLUGIN_TARGET ${TARGET}
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/temp/UniDesk
    VERSION ${MODULE_VERSION_MAJOR}.${MODULE_VERSION_MINOR}
    URI UniDesk
    TYPEINFO "plugins.qmltypes"
    SOURCES ${sources_files}
    QML_FILES ${qml_files}
    RESOURCES ${resource_files}
    RESOURCE_PREFIX "/uniquenium/kit"
)

set_target_properties(${TARGET}
    PROPERTIES  VERSION ${MODULE_VERSION} SOVERSION ${MODULE_VERSION_MAJOR})

# add_subdirectory(GraphicalEffects)

# install(DIRECTORY ${CMAKE_BINARY_DIR}/temp/${PROJECT_NAME} DESTINATION ${INSTALL_QMLDIR})
# generate_export_header(${TARGET} BASE_NAME ${TARGET})

# install(TARGETS ${TARGET} EXPORT ${TARGET}Targets DESTINATION ${INSTALL_QMLDIR}/${PROJECT_NAME})

# # Install Header
# install(FILES ${H_FILES} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${TARGET})
