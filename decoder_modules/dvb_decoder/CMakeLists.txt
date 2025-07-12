cmake_minimum_required(VERSION 3.13)
project(dvb_decoder)

file(GLOB_RECURSE SRC "src/*.cpp" "src/*.c")

include(${SDRPP_MODULE_CMAKE})

target_include_directories(dvb_decoder PRIVATE "src/")

if (MSVC)
    # Windows-specific includes and libraries if needed
    # Add any Windows-specific DVB libraries here
elseif (ANDROID)
    # Android-specific libraries if needed
else ()
    # Linux/Unix libraries
    find_package(PkgConfig)
    
    # Add any required packages here
    # pkg_check_modules(LIBDVB REQUIRED libdvb)
endif ()

# Add any additional linking or compilation flags specific to DVB processing
