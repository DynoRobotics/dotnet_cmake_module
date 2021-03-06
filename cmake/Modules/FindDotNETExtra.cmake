# Copyright 2016-2018 Esteve Fernandez <esteve@apache.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

find_package(CSBuild REQUIRED)
include(${CSBUILD_USE_FILE})

function(add_dotnet_library _TARGET_NAME)
  cmake_parse_arguments(_add_dotnet_library
    ""
    ""
    "SOURCES;INCLUDE_DLLS;INCLUDE_NUPKGS;INCLUDE_REFERENCES"
    ${ARGN}
  )

  csharp_add_project(${_TARGET_NAME}
    SOURCES
    ${_add_dotnet_library_SOURCES}
    ${_add_dotnet_library_UNPARSED_ARGUMENTS}
    INCLUDE_DLLS
    ${_add_dotnet_library_INCLUDE_DLLS}
    INCLUDE_NUPKGS
    ${_add_dotnet_library_INCLUDE_NUPKGS}
    INCLUDE_REFERENCES
    ${_add_dotnet_library_INCLUDE_REFERENCES}
  )
endfunction()

function(add_dotnet_executable _TARGET_NAME)
  cmake_parse_arguments(_add_dotnet_executable
    ""
    ""
    "SOURCES;INCLUDE_DLLS;INCLUDE_NUPKGS;INCLUDE_REFERENCES"
    ${ARGN}
  )

  csharp_add_project(${_TARGET_NAME}
    EXECUTABLE
    SOURCES
    ${_add_dotnet_executable_SOURCES}
    ${_add_dotnet_executable_UNPARSED_ARGUMENTS}
    INCLUDE_DLLS
    ${_add_dotnet_executable_INCLUDE_DLLS}
    INCLUDE_NUPKGS
    ${_add_dotnet_executable_INCLUDE_NUPKGS}
    INCLUDE_REFERENCES
    ${_add_dotnet_executable_INCLUDE_REFERENCES}
  )
endfunction()

function(install_dotnet _TARGET_NAME)
    get_target_property(_target_executable ${_TARGET_NAME} EXECUTABLE)
    get_target_property(_target_path ${_TARGET_NAME} OUTPUT_PATH)
    get_target_property(_target_name ${_TARGET_NAME} OUTPUT_NAME)
    get_target_property(_target_dotnet_core ${_TARGET_NAME} DOTNET_CORE)

    if (ARGC EQUAL 2)
      set (_DESTINATION ${ARGV1})
    else()
      cmake_parse_arguments(_install_dotnet
        ""
        "DESTINATION"
        ""
        ${ARGN})
      if (_install_dotnet_DESTINATION)
        set (_DESTINATION ${_install_dotnet_DESTINATION})
      else()
        message(SEND_ERROR "install_dotnet: ${_TARGET_NAME}: DESTINATION must be specified.")
      endif()
    endif()
    install(DIRECTORY ${_target_path}/ DESTINATION ${_DESTINATION})

    if(_target_executable)
      set(DOTNET_DLL_PATH ${_target_name})
      if(WIN32)
        configure_file(${dotnet_cmake_module_DIR}/Modules/dotnet/entry_point.windows.in lib/${_TARGET_NAME}.bat @ONLY)
        install(FILES ${CMAKE_CURRENT_BINARY_DIR}/lib/${_TARGET_NAME}.bat
          DESTINATION
          lib/${PROJECT_NAME})
      else()
        configure_file(${dotnet_cmake_module_DIR}/Modules/dotnet/entry_point.unix.in lib/${_TARGET_NAME} @ONLY)
        install(FILES ${CMAKE_CURRENT_BINARY_DIR}/lib/${_TARGET_NAME}
          DESTINATION
          lib/${PROJECT_NAME}
          PERMISSIONS
          OWNER_READ
          OWNER_WRITE
          OWNER_EXECUTE
          GROUP_READ
          GROUP_EXECUTE
          WORLD_READ
          WORLD_EXECUTE
        )
      endif()
    endif()
endfunction()
