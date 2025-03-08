#!/bin/bash
#2025.3.8 
#Uranium_hnrmyfsx
#ver1.0

#!/bin/bash

# 查找所有 Java 安装路径（包含需要 sudo 权限的路径）
find_java_installations() {
    local search_paths=(
        "/usr/lib/jvm"
        "/opt"
        "/usr/java"
        "$HOME/.sdkman/candidates/java"
        "/Library/Java/JavaVirtualMachines"
    )

    local javas=()
    for path in "${search_paths[@]}"; do
        if [ -d "$path" ] || sudo [ -d "$path" ]; then
            while IFS= read -r -d '' java_exec; do
                java_home=$(dirname "$(dirname "$java_exec")")
                javas+=("$java_home")
            done < <(sudo find "$path" -type f -name "java" -executable -print 2>/dev/null | grep -E 'bin/java$' | tr '\n' '\0')
        fi
    done

    # 去重处理
    local unique_javas=()
    while IFS= read -r -d '' path; do
        unique_javas+=("$path")
    done < <(printf "%s\n" "${javas[@]}" | sort -u | tr '\n' '\0')

    echo "${unique_javas[@]}"
}

# 交互式选择版本
select_java() {
    local javas=("$@")
    while true; do
        clear
        echo "检测到以下 Java 版本:"
        for i in "${!javas[@]}"; do
            version=$("${javas[$i]}/bin/java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
            echo "[$((i+1))] ${javas[$i]} (Java $version)"
        done

        read -p "请输入要切换的版本编号 (1-${#javas[@]}) 或输入 q 退出: " choice
        if [[ "$choice" == "q" ]]; then
            echo "退出"
            exit 0
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#javas[@]}" ]; then
            selected_home="${javas[$((choice-1))]}"
            echo "正在切换到: $selected_home"
            export JAVA_HOME="$selected_home"
            export PATH="$JAVA_HOME/bin:$PATH"
            echo "当前 JAVA_HOME: $JAVA_HOME"
            echo "Java 版本信息:"
            java -version
            return 0
        else
            echo -e "无效输入，请重新输入"
            sleep 1
        fi
    done
}

# 主程序
java_installations=($(find_java_installations))
if [ ${#java_installations[@]} -eq 0 ]; then
    echo "未找到任何 Java 安装!"
    exit 1
fi

select_java "${java_installations[@]}"