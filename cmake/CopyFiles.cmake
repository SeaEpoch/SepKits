# CopyFiles.cmake
# 提供两个宏：
#   auto_copy_files   - 智能选择配置期或构建期复制
#   copy_files_now    - 强制配置期复制（仅在确定单配置时使用）

# ==================== 辅助函数：替换 <CONFIG> 占位符 ====================
function(_resolve_config_path input_path config_value output_var)
    string(REPLACE "<CONFIG>" "${config_value}" resolved "${input_path}")
    set(${output_var} "${resolved}" PARENT_SCOPE)
endfunction()

# ==================== 配置期复制（单配置用） ====================
function(_copy_at_configure_time sources dest_dir build_type)
    foreach(src IN LISTS sources)
        _resolve_config_path("${src}" "${build_type}" resolved_src)
        get_filename_component(filename "${resolved_src}" NAME)
        # 目标文件路径（如果 dest_dir 不以 / 结尾自动加上）
        if(dest_dir MATCHES "/$")
            set(dest_file "${dest_dir}${filename}")
        else()
            set(dest_file "${dest_dir}/${filename}")
        endif()
        file(COPY "${resolved_src}" DESTINATION "${dest_dir}")
        message(STATUS "Config-time copy: ${resolved_src} -> ${dest_dir}")
    endforeach()
endfunction()

# ==================== 构建期复制（多配置/通用用） ====================
function(_copy_at_build_time sources dest_dir)
    # 创建一个总目标，所有复制作为其依赖
    set(copy_targets "")
    set(target_name "CopyThirdPartyFiles")

    foreach(src IN LISTS sources)
        # 源路径中可能仍含有 <CONFIG>，在生成器表达式中用 $<CONFIG> 替换
        string(REPLACE "<CONFIG>" "$<CONFIG>" gen_src "${src}")
        get_filename_component(filename "${src}" NAME)  # 文件名不变
        # 输出文件位置（同样使用生成器表达式）
        set(out_file "${dest_dir}/$<CONFIG>/${filename}")  # 放在 dest_dir/<Config>/ 下，避免不同配置覆盖
        # 或者直接放在 dest_dir 下（如果你不介意多个配置共享一个目录，但可能混乱）
        # 这里按最常见做法：每个配置独立子目录
        add_custom_command(
            OUTPUT "${out_file}"
            COMMAND ${CMAKE_COMMAND} -E make_directory "${dest_dir}/$<CONFIG>"
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${gen_src}"
                "${out_file}"
            DEPENDS "${gen_src}"
            COMMENT "Build-time copy: ${gen_src} -> ${out_file}"
        )
        list(APPEND copy_targets "${out_file}")
    endforeach()

    if(NOT TARGET ${target_name})
        add_custom_target(${target_name} ALL DEPENDS ${copy_targets})
    endif()
endfunction()

# ==================== 顶层入口：自动选择机制 ====================
macro(auto_copy_files)
    # 解析参数
    set(options)
    set(oneValueArgs DESTINATION)
    set(multiValueArgs SOURCES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ARG_SOURCES)
        message(FATAL_ERROR "auto_copy_files: 必须提供 SOURCES 参数")
    endif()
    if(NOT ARG_DESTINATION)
        message(FATAL_ERROR "auto_copy_files: 必须提供 DESTINATION 参数")
    endif()

    # 判断是否多配置生成器（Visual Studio / Xcode）或未指定构建类型
    if(CMAKE_CONFIGURATION_TYPES OR NOT CMAKE_BUILD_TYPE)
        # 多配置场景 —— 使用构建期复制
        message(STATUS "多配置生成器或未指定构建类型，将在构建期自动复制文件")
        _copy_at_build_time("${ARG_SOURCES}" "${ARG_DESTINATION}")
    else()
        # 单配置场景 —— 配置期直接复制
        message(STATUS "单配置生成器 (${CMAKE_BUILD_TYPE})，配置期复制文件")
        _copy_at_configure_time("${ARG_SOURCES}" "${ARG_DESTINATION}" "${CMAKE_BUILD_TYPE}")
    endif()
endmacro()