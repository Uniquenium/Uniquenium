qt_standard_project_setup()

# find all subdirectories
file(GLOB SUBDIRS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/*)
file(WRITE ${QML_IMPORT_PATH}/UniDesk/Components/components-list "")
foreach(subdir ${SUBDIRS})
    if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${subdir})
        add_subdirectory(${subdir})
        file(APPEND ${QML_IMPORT_PATH}/UniDesk/Components/components-list "${subdir}\n")
    endif()
endforeach()