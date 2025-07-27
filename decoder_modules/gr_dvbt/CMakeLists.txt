cmake_minimum_required(VERSION 3.13)
project(gr_dvbt)

file(GLOB_RECURSE SRC "src/*.cpp" "src/*.c")

include(${SDRPP_MODULE_CMAKE})

target_include_directories(gr_dvbt PRIVATE "src/")

# Find and link FFTW3 for DVB-T demodulation
if(WIN32)
    # Try to find FFTW3 on Windows
    find_library(FFTW3F_LIBRARIES NAMES fftw3f libfftw3f-3
        PATHS
        "C:/Program Files/PothosSDR/lib"
        "C:/vcpkg/installed/x64-windows/lib"
        "C:/vcpkg/installed/x86-windows/lib"
        PATH_SUFFIXES lib
    )
    if(FFTW3F_LIBRARIES)
        target_link_libraries(gr_dvbt PRIVATE ${FFTW3F_LIBRARIES})
        message("Found FFTW3F for gr_dvbt: ${FFTW3F_LIBRARIES}")
        
        # Add include directories
        find_path(FFTW3_INCLUDE_DIR fftw3.h
            PATHS
            "C:/Program Files/PothosSDR/include"
            "C:/vcpkg/installed/x64-windows/include"
            "C:/vcpkg/installed/x86-windows/include"
        )
        if(FFTW3_INCLUDE_DIR)
            target_include_directories(gr_dvbt PRIVATE ${FFTW3_INCLUDE_DIR})
        endif()
    else()
        message(WARNING "FFTW3F not found - gr_dvbt module may not work properly")
    endif()
else()
    # On Unix-like systems
    find_package(PkgConfig QUIET)
    if(PKG_CONFIG_FOUND)
        pkg_check_modules(FFTW3F QUIET fftw3f)
        if(FFTW3F_FOUND)
            target_include_directories(gr_dvbt PRIVATE ${FFTW3F_INCLUDE_DIRS})
            target_link_libraries(gr_dvbt PRIVATE ${FFTW3F_LIBRARIES})
            message("Found FFTW3F for gr_dvbt via pkg-config")
        endif()
    endif()
    
    if(NOT FFTW3F_FOUND)
        find_library(FFTW3F_LIBRARIES NAMES fftw3f)
        if(FFTW3F_LIBRARIES)
            target_link_libraries(gr_dvbt PRIVATE ${FFTW3F_LIBRARIES})
            message("Found FFTW3F for gr_dvbt: ${FFTW3F_LIBRARIES}")
        endif()
    endif()
endif()

# Add math library on Unix
if(UNIX AND NOT APPLE)
    target_link_libraries(gr_dvbt PRIVATE m)
endif()
