# Mutagen zsh Management Functions
# ~/.oh-my-zsh/custom/mutagen.zsh 또는 ~/.zsh/functions/mutagen.zsh

# Mutagen 세션 목록을 보기 좋게 출력
function mlist() {
    echo "📋 Mutagen Sessions:"
    mutagen sync list 2>/dev/null || echo "No sync sessions found"
    echo ""
    echo "🔀 Forward Sessions:"
    mutagen forward list 2>/dev/null || echo "No forward sessions found"
}

# Mutagen 세션 상태 요약
function mstatus() {
    local sync_count=$(mutagen sync list 2>/dev/null | grep -c "Name:" 2>/dev/null || echo "0")
    local forward_count=$(mutagen forward list 2>/dev/null | grep -c "Name:" 2>/dev/null || echo "0")
    
    # 숫자 검증
    [[ ! "$sync_count" =~ ^[0-9]+$ ]] && sync_count=0
    [[ ! "$forward_count" =~ ^[0-9]+$ ]] && forward_count=0
    
    echo "📊 Mutagen Status Summary:"
    echo "   Sync sessions: $sync_count"
    echo "   Forward sessions: $forward_count"
    echo ""
    
    if [[ $sync_count -gt 0 ]]; then
        echo "🔄 Sync Sessions:"
        mutagen sync list 2>/dev/null | grep -E "(Name:|Status:)" | sed 's/^/  /'
    else
        echo "💡 No active sync sessions found"
    fi
    
    if [[ $forward_count -gt 0 ]]; then
        echo ""
        echo "🔀 Forward Sessions:"
        mutagen forward list 2>/dev/null | grep -E "(Name:|Status:)" | sed 's/^/  /'
    fi
}

# SSH 설정 파싱 함수
parse_ssh_config() {
    local ssh_config="$HOME/.ssh/config"
    if [[ ! -f "$ssh_config" ]]; then
        return 1
    fi
    
    # SSH config 파일에서 Host 정보 추출
    awk '
    /^Host / { 
        if (host != "" && hostname != "") {
            printf "%s|%s|%s|%s|%s\n", host, user, hostname, port, keyfile
        }
        host = $2; user = ""; hostname = ""; port = "22"; keyfile = ""
    }
    /^[ \t]*HostName/ { hostname = $2 }
    /^[ \t]*User/ { user = $2 }
    /^[ \t]*Port/ { port = $2 }
    /^[ \t]*IdentityFile/ { keyfile = $2 }
    END {
        if (host != "" && hostname != "") {
            printf "%s|%s|%s|%s|%s\n", host, user, hostname, port, keyfile
        }
    }' "$ssh_config"
}

# Mutagen SSH 동기화 설정 함수
function msync() {
    echo "🔄 Mutagen SSH 동기화 설정:"
    echo "----------------------------------------"
    
    local hosts=$(parse_ssh_config)
    if [[ -z "$hosts" ]]; then
        echo "등록된 SSH 서버가 없습니다. ~/.ssh/config 파일을 확인하세요."
        echo ""
        echo "SSH 설정 예시:"
        echo "Host myserver"
        echo "    HostName 192.168.1.100"
        echo "    User username"
        echo "    Port 22"
        echo "    IdentityFile ~/.ssh/id_rsa"
        return 1
    fi
    
    echo "등록된 SSH 서버:"
    local -a host_info
    local i=1
    echo "$hosts" | while IFS='|' read -r host user hostname port keyfile; do
        [[ -z "$host" ]] && continue
        printf "%d) %s (%s@%s:%s)\n" "$i" "$host" "$user" "$hostname" "$port"
        echo "$host|$user|$hostname|$port|$keyfile" >> /tmp/ssh_info_$
        ((i++))
    done
    
    # 배열 다시 읽기
    local -a info_array
    local j=1
    while IFS='|' read -r host user hostname port keyfile; do
        info_array[$j]="$host|$user|$hostname|$port|$keyfile"
        ((j++))
    done < /tmp/ssh_info_$
    rm -f /tmp/ssh_info_$
    
    echo "----------------------------------------"
    echo -n "동기화할 서버 번호를 선택하세요 (1-${#info_array[@]}): "
    read choice
    
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || [[ $choice -lt 1 ]] || [[ $choice -gt ${#info_array[@]} ]]; then
        echo "❌ 잘못된 선택입니다."
        return 1
    fi
    
    # 선택된 서버 정보 파싱
    local server_info="${info_array[$choice]}"
    local host=$(echo "$server_info" | cut -d'|' -f1)
    local user=$(echo "$server_info" | cut -d'|' -f2)
    local hostname=$(echo "$server_info" | cut -d'|' -f3)
    local port=$(echo "$server_info" | cut -d'|' -f4)
    local keyfile=$(echo "$server_info" | cut -d'|' -f5)
    
    echo "선택된 서버: $host ($user@$hostname:$port)"
    
    # 원격 경로 입력
    echo -n "원격 서버의 동기화할 경로를 입력하세요: "
    read remote_path
    if [[ -z "$remote_path" ]]; then
        echo "❌ 원격 경로는 필수입니다."
        return 1
    fi
    
    # 로컬 경로 (현재 디렉토리)
    local local_path=$(pwd)
    local project_name=$(basename "$local_path")
    echo "로컬 경로: $local_path"
    echo "프로젝트명: $project_name"
    
    # mutagen.yml 파일 생성
    local mutagen_config="mutagen.yml"
    
    cat > "$mutagen_config" << EOF
# Mutagen SSH 동기화 설정 for $project_name
# Generated on $(date)
# Server: $host ($user@$hostname:$port)

sync:
  defaults:
    mode: "two-way-resolved"
    ignore:
      vcs: true
      paths:
        # Python 관련
        - "*.pyc"
        - "__pycache__/"
        - ".pytest_cache/"
        - ".ipynb_checkpoints/"
        - "*.egg-info/"
        - ".venv/"
        - "venv/"
        - ".conda/"
        
        # PyTorch/ML 관련
        - "*.pth"
        - "*.ckpt" 
        - "*.safetensors"
        - "checkpoints/"
        - "runs/"
        - "logs/"
        - "wandb/"
        - "tensorboard/"
        - "mlruns/"
        
        # 데이터 관련 (큰 파일들)
        - "data/"
        - "datasets/"
        - "*.h5"
        - "*.hdf5"
        - "*.npy"
        - "*.npz"
        - "*.pkl"
        - "*.pickle"
        
        # Node.js 관련
        - "node_modules/"
        - "npm-debug.log*"
        - ".npm/"
        
        # 일반 개발 파일
        - ".git/"
        - ".vscode/"
        - ".idea/"
        - ".DS_Store"
        - "*.log"
        - ".env.local"
        - "vendor/"
        - "build/"
        - "dist/"
        - "*.tmp"
        - "*.temp"

  # SSH 동기화 세션
  ${host}-sync:
    alpha: "."
    beta: "$host:$remote_path"
    
    # 첫 생성시 전체 동기화 강제 실행
    flushOnCreate: true

# 커스텀 명령어
commands:
  ssh: "ssh $host"
  logs: "mutagen sync monitor ${host}-sync"
  status: "mutagen sync list ${host}-sync"
  flush: "mutagen sync flush ${host}-sync"
  reset: "mutagen sync reset ${host}-sync"

EOF
    
    echo "✅ mutagen.yml 파일이 생성되었습니다."
    echo ""
    echo "🔄 Mutagen 동기화를 시작하려면:"
    echo "  mstart"
    echo ""
    echo "📊 동기화 상태 확인:"
    echo "  mstatus"
    echo ""
    echo "📋 로그 모니터링:"
    echo "  mlogs"
    echo ""
    echo "🔗 SSH 직접 접속:"
    echo "  ssh $host"
    echo ""
    echo "⏹️  동기화 중지:"
    echo "  mstop"
    
    # 즉시 동기화 시작 여부 확인
    echo ""
    echo -n "지금 동기화를 시작하시겠습니까? (y/N): "
    read start_sync
    if [[ "$start_sync" =~ ^[Yy]$ ]]; then
        echo "🚀 동기화 시작 중..."
        if command -v mutagen >/dev/null 2>&1; then
            echo "🚀 Starting Mutagen sync: $project_name -> $host"
            mutagen project start
            if [[ $? -eq 0 ]]; then
                echo "✅ Mutagen sync started successfully"
                echo "🔗 SSH: ssh $host"
                echo "📊 Monitor: mlogs"
                echo ""
                mstatus
            else
                echo "❌ 동기화 시작에 실패했습니다."
            fi
        else
            echo "❌ Mutagen이 설치되어 있지 않습니다."
            echo "다음 명령어로 설치하세요:"
            echo "  brew install mutagen-io/mutagen/mutagen"
        fi
    fi
}

# Mutagen YML 파일 자동 생성 (기본 버전)
function mgen() {
    local project_name=${1:-$(basename $(pwd))}
    local beta_endpoint=$2
    
    if [[ -z "$beta_endpoint" ]]; then
        echo "❌ Usage: mgen [project_name] <beta_endpoint>"
        echo "   Example: mgen myproject user@server:/path/to/project"
        echo ""
        echo "💡 For SSH-based setup with ~/.ssh/config, use: msync"
        return 1
    fi
    
    cat > mutagen.yml << EOF
# Mutagen project configuration for $project_name
# Generated on $(date)

sync:
  defaults:
    mode: "two-way-resolved"
    ignore:
      vcs: true
      paths:
        - "node_modules/"
        - ".git/"
        - "vendor/"
        - ".DS_Store"
        - "*.log"
        - ".env.local"
    
  main:
    alpha: "."
    beta: "$beta_endpoint"

# 커스텀 명령어
commands:
  logs: "mutagen sync monitor main"
  status: "mutagen sync list main"
  flush: "mutagen sync flush main"
EOF

    echo "✅ Created mutagen.yml for project: $project_name"
    echo "📝 Edit the file to customize settings"
    echo "🚀 Run 'mstart' to begin synchronization"
}

# Mutagen 프로젝트 시작
function mstart() {
    if [[ ! -f "mutagen.yml" ]]; then
        echo "❌ No mutagen.yml found in current directory"
        echo "💡 Run 'msync' or 'mgen <beta_endpoint>' to create one"
        return 1
    fi
    
    echo "🚀 Starting Mutagen project..."
    
    mutagen project start
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Mutagen sync started successfully"
        echo "🔗 SSH access available"
        echo "📊 Monitor with: mutagen project run logs"
        echo ""
        mstatus
    else
        echo "❌ Failed to start Mutagen project"
    fi
}

# Mutagen 프로젝트 중지
function mstop() {
    if [[ ! -f "mutagen.yml" ]]; then
        echo "❌ No mutagen.yml found in current directory"
        return 1
    fi
    
    echo "🛑 Stopping Mutagen project..."
    
    mutagen project terminate
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Mutagen sync stopped"
        echo "💡 Restart with: mstart"
    else
        echo "❌ Failed to stop Mutagen project"
    fi
}

# Mutagen 프로젝트 일시정지
function mpause() {
    local session_name=$1
    
    # 세션 이름이 지정되지 않은 경우 자동 감지
    if [[ -z "$session_name" ]]; then
        if [[ -f "mutagen.yml" ]]; then
            # mutagen.yml에서 첫 번째 세션 이름 추출
            session_name=$(grep -E "^  [^#].*-sync:" mutagen.yml | head -1 | sed 's/:$//' | sed 's/^  //')
            if [[ -z "$session_name" ]]; then
                # 기본 세션 이름들 시도
                local default_sessions=("main" "default")
                for default_name in "${default_sessions[@]}"; do
                    if mutagen sync list "$default_name" >/dev/null 2>&1; then
                        session_name="$default_name"
                        break
                    fi
                done
                
                if [[ -z "$session_name" ]]; then
                    echo "❌ No session found in mutagen.yml"
                    echo "💡 Usage: mpause <session_name>"
                    return 1
                fi
            fi
            echo "📊 Auto-detected session: $session_name"
        else
            # 활성 세션 중 첫 번째 사용
            session_name=$(mutagen sync list 2>/dev/null | grep "Name:" | head -1 | awk '{print $2}')
            if [[ -z "$session_name" ]]; then
                echo "❌ No active sessions found"
                echo "💡 Usage: mpause <session_name>"
                echo "💡 Available sessions:"
                mutagen sync list 2>/dev/null | grep "Name:" | sed 's/Name: /  - /'
                return 1
            fi
            echo "📊 Using active session: $session_name"
        fi
    fi
    
    # 현재 상태 확인
    local current_status=$(mutagen sync list "$session_name" 2>/dev/null | grep "Status:" | awk '{print $2}')
    
    if [[ -z "$current_status" ]]; then
        echo "❌ Session '$session_name' not found"
        echo "💡 Available sessions:"
        mutagen sync list 2>/dev/null | grep "Name:" | sed 's/Name: /  - /'
        return 1
    fi
    
    if [[ "$current_status" == "Paused" ]]; then
        echo "⏸️  Session '$session_name' is already paused"
        echo "💡 Use 'mresume $session_name' to resume"
        return 0
    fi
    
    echo "⏸️  Pausing Mutagen session: $session_name"
    echo "📊 Current status: $current_status"
    
    mutagen sync pause "$session_name"
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Session paused successfully"
        echo "💡 Resume with: mresume $session_name"
        echo "📊 Check status: mstatus"
    else
        echo "❌ Failed to pause session"
        echo "💡 Check session status: mutagen sync list $session_name"
    fi
}

# Mutagen 프로젝트 재개
function mresume() {
    local session_name=$1
    
    # 세션 이름이 지정되지 않은 경우 자동 감지
    if [[ -z "$session_name" ]]; then
        if [[ -f "mutagen.yml" ]]; then
            # mutagen.yml에서 첫 번째 세션 이름 추출
            session_name=$(grep -E "^  [^#].*-sync:" mutagen.yml | head -1 | sed 's/:$//' | sed 's/^  //')
            if [[ -z "$session_name" ]]; then
                # 기본 세션 이름들 시도
                local default_sessions=("main" "default")
                for default_name in "${default_sessions[@]}"; do
                    if mutagen sync list "$default_name" >/dev/null 2>&1; then
                        session_name="$default_name"
                        break
                    fi
                done
                
                if [[ -z "$session_name" ]]; then
                    echo "❌ No session found in mutagen.yml"
                    echo "💡 Usage: mresume <session_name>"
                    return 1
                fi
            fi
            echo "📊 Auto-detected session: $session_name"
        else
            # 일시정지된 세션 찾기
            session_name=$(mutagen sync list 2>/dev/null | grep -B1 "Status: Paused" | grep "Name:" | head -1 | awk '{print $2}')
            if [[ -z "$session_name" ]]; then
                echo "❌ No paused sessions found"
                echo "💡 Usage: mresume <session_name>"
                echo "💡 Available sessions:"
                mutagen sync list 2>/dev/null | grep "Name:" | sed 's/Name: /  - /'
                return 1
            fi
            echo "📊 Found paused session: $session_name"
        fi
    fi
    
    # 현재 상태 확인
    local current_status=$(mutagen sync list "$session_name" 2>/dev/null | grep "Status:" | awk '{print $2}')
    
    if [[ -z "$current_status" ]]; then
        echo "❌ Session '$session_name' not found"
        echo "💡 Available sessions:"
        mutagen sync list 2>/dev/null | grep "Name:" | sed 's/Name: /  - /'
        return 1
    fi
    
    if [[ "$current_status" != "Paused" ]]; then
        echo "▶️  Session '$session_name' is not paused (Status: $current_status)"
        echo "💡 Current session is already active"
        return 0
    fi
    
    echo "▶️  Resuming Mutagen session: $session_name"
    
    mutagen sync resume "$session_name"
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Session resumed successfully"
        echo "📊 Monitor with: mlogs $session_name"
        echo "📊 Check status: mstatus"
    else
        echo "❌ Failed to resume session"
        echo "💡 Check session status: mutagen sync list $session_name"
    fi
}

# Mutagen 동기화 로그 모니터링
function mlogs() {
    local session_name=$1
    
    # 세션 이름이 지정되지 않은 경우 자동 감지
    if [[ -z "$session_name" ]]; then
        if [[ -f "mutagen.yml" ]]; then
            # mutagen.yml에서 첫 번째 세션 이름 추출
            session_name=$(grep -E "^  [^#].*-sync:" mutagen.yml | head -1 | sed 's/:$//' | sed 's/^  //')
            if [[ -z "$session_name" ]]; then
                echo "❌ No session found in mutagen.yml"
                return 1
            fi
            echo "📊 Auto-detected session: $session_name"
        else
            # 활성 세션 중 첫 번째 사용
            session_name=$(mutagen sync list 2>/dev/null | grep "Name:" | head -1 | awk '{print $2}')
            if [[ -z "$session_name" ]]; then
                echo "❌ No active sessions found"
                echo "💡 Usage: mlogs <session_name>"
                return 1
            fi
            echo "📊 Using active session: $session_name"
        fi
    fi
    
    # 세션 정보 먼저 표시
    echo "🔍 Session Information:"
    local session_info=$(mutagen sync list "$session_name" 2>/dev/null)
    if [[ -n "$session_info" ]]; then
        # 임시 파일을 사용하여 while 루프 문제 해결
        echo "$session_info" > /tmp/mutagen_info_$
        
        while IFS= read -r line; do
            if [[ "$line" =~ ^Alpha:$ ]]; then
                echo "     📍 Local (Source):"
            elif [[ "$line" =~ ^Beta:$ ]]; then
                echo "     🌐 Remote (Target):"
            elif [[ "$line" =~ ^[[:space:]]*URL:\ (.+)$ ]]; then
                local url="${match[1]}"
                if [[ "$url" =~ ^/ ]]; then
                    echo "       📁 $(basename "$url") ($(dirname "$url"))"
                else
                    echo "       🖥️  $url"
                fi
            elif [[ "$line" =~ ^[[:space:]]*Connected:\ (.+)$ ]]; then
                local conn_state="${match[1]}"
                if [[ "$conn_state" == "Yes" ]]; then
                    echo "       ✅ Connected"
                else
                    echo "       ❌ Disconnected"
                fi
            elif [[ "$line" =~ ^Status:\ (.+)$ ]]; then
                local sync_state="${match[1]}"
                echo "     📊 Status: $sync_state"
            fi
        done < /tmp/mutagen_info_$
        
        rm -f /tmp/mutagen_info_$
    fi
    
    echo ""
    echo "📊 Monitoring sync activity for: $session_name"
    echo "🔍 Watch for file changes and transfers..."
    echo "📝 Sync direction: Local ⇄ Remote (bidirectional)"
    echo "Press Ctrl+C to stop monitoring"
    echo ""
    echo "----------------------------------------"
    
    # 실시간 모니터링 시작
    mutagen sync monitor "$session_name" | while IFS= read -r line; do
        # 타임스탬프 추가 및 메시지 포맷팅
        local timestamp=$(date "+%H:%M:%S")
        
        if [[ "$line" =~ "Staging" ]]; then
            echo "[$timestamp] 📦 $line"
        elif [[ "$line" =~ "Reconciling" ]]; then
            echo "[$timestamp] 🔄 $line"
        elif [[ "$line" =~ "Transitioning" ]]; then
            echo "[$timestamp] ⚡ $line"
        elif [[ "$line" =~ "Scanning" ]]; then
            echo "[$timestamp] 🔍 $line"
        elif [[ "$line" =~ "Watching" ]]; then
            echo "[$timestamp] 👁️  $line"
        elif [[ "$line" =~ "conflict" ]] || [[ "$line" =~ "error" ]] || [[ "$line" =~ "Error" ]]; then
            echo "[$timestamp] ⚠️  $line"
        elif [[ "$line" =~ "Synchronized" ]] || [[ "$line" =~ "completed" ]]; then
            echo "[$timestamp] ✅ $line"
        else
            echo "[$timestamp] 📋 $line"
        fi
    done
}

# Mutagen 연결 상태 확인 (개선된 출력)
function mcheck() {
    echo "🔍 Checking Mutagen connectivity..."
    
    if [[ -f "mutagen.yml" ]]; then
        echo "📄 Found mutagen.yml in current directory"
        echo ""
        
        # 프로젝트 세션들을 더 읽기 좋게 출력
        local sessions=$(mutagen sync list 2>/dev/null)
        if [[ -n "$sessions" ]]; then
            echo "🔄 Active Sync Sessions:"
            
            # 임시 파일을 사용하여 while 루프 문제 해결
            echo "$sessions" > /tmp/mutagen_sessions_$
            
            while IFS= read -r line; do
                if [[ "$line" =~ ^Name:\ (.+)$ ]]; then
                    echo "  📂 Session: ${match[1]}"
                elif [[ "$line" =~ ^Alpha:$ ]]; then
                    echo "     📍 Local (Source):"
                elif [[ "$line" =~ ^Beta:$ ]]; then
                    echo "     🌐 Remote (Target):"
                elif [[ "$line" =~ ^[[:space:]]*URL:\ (.+)$ ]]; then
                    local url="${match[1]}"
                    if [[ "$url" =~ ^/ ]]; then
                        echo "       📁 $(basename "$url")"
                    else
                        echo "       🖥️  $url"
                    fi
                elif [[ "$line" =~ ^[[:space:]]*Connected:\ (.+)$ ]]; then
                    local conn_state="${match[1]}"
                    if [[ "$conn_state" == "Yes" ]]; then
                        echo "       ✅ Connected"
                    else
                        echo "       ❌ Disconnected"
                    fi
                elif [[ "$line" =~ ^Status:\ (.+)$ ]]; then
                    local sync_state="${match[1]}"
                    echo "     📊 Status: $sync_state"
                    echo ""
                fi
            done < /tmp/mutagen_sessions_$
            
            rm -f /tmp/mutagen_sessions_$
        else
            echo "❌ No active sessions found"
        fi
    else
        echo "📋 No mutagen.yml found. Listing all sessions:"
        mlist
    fi
    
    # 연결 문제가 있는 세션 찾기
    local problematic_sessions=$(mutagen sync list 2>/dev/null | grep -B2 -A2 "Connected: No\|Status.*Error\|Status.*Problem")
    
    if [[ -n "$problematic_sessions" ]]; then
        echo "⚠️  Found sessions with connection issues:"
        echo "$problematic_sessions"
    else
        echo "🎉 All sessions are healthy and connected!"
    fi
}

# Mutagen 세션 재시작 (연결 문제 해결)
function mrestart() {
    local session_name=${1:-"main"}
    
    echo "🔄 Restarting Mutagen session: $session_name"
    
    # 프로젝트가 있으면 프로젝트 단위로 재시작
    if [[ -f "mutagen.yml" ]]; then
        mstop
        sleep 2
        mstart
    else
        # 개별 세션 재시작
        mutagen sync pause $session_name
        sleep 1
        mutagen sync resume $session_name
        
        if [[ $? -eq 0 ]]; then
            echo "✅ Session restarted successfully"
        else
            echo "❌ Failed to restart session"
        fi
    fi
}

# Mutagen 설정 템플릿 보기
function mtemplate() {
    echo "📋 Available Mutagen configuration templates:"
    echo ""
    echo "1. 🔐 SSH-based sync (recommended):"
    echo "   msync"
    echo "   - Uses ~/.ssh/config for server info"
    echo "   - Includes ML/Python optimized ignore patterns"
    echo "   - Interactive server selection"
    echo ""
    echo "2. 📦 Basic sync template:"
    echo "   mgen myproject user@server:/remote/path"
    echo ""
    echo "3. 🐳 Docker container sync:"
    echo "   mgen myproject docker://container-name/app"
    echo ""
    echo "4. 🏠 Local directory sync:"
    echo "   mgen myproject /path/to/local/directory"
    echo ""
    echo "📚 SSH Config Setup Example:"
    echo "   ~/.ssh/config:"
    echo "   Host myserver"
    echo "       HostName 192.168.1.100"
    echo "       User username"
    echo "       Port 22"
    echo "       IdentityFile ~/.ssh/id_rsa"
    echo ""
    echo "📖 For more options, visit: https://mutagen.io/documentation"
}

# Mutagen 빠른 도움말
function mhelp() {
    echo "🚀 Mutagen zsh Functions Help"
    echo "=========================="
    echo ""
    echo "📋 Session Management:"
    echo "  mlist     - List all Mutagen sessions"
    echo "  mstatus   - Show session status summary"
    echo "  mcheck    - Check connectivity and health"
    echo "  mrestart  - Restart session/project"
    echo "  mpause    - Pause session/project"
    echo "  mresume   - Resume paused session/project"
    echo ""
    echo "📝 Project Management:"
    echo "  mgen      - Generate basic mutagen.yml template"
    echo "  msync     - Generate SSH-based mutagen.yml (recommended)"
    echo "  mstart    - Start Mutagen project"
    echo "  mstop     - Stop Mutagen project"
    echo ""
    echo "📊 Monitoring:"
    echo "  mlogs     - Monitor session logs"
    echo ""
    echo "📚 Help:"
    echo "  mtemplate - Show configuration templates"
    echo "  mhelp     - Show this help"
    echo ""
    echo "💡 SSH Setup (recommended):"
    echo "  1. Configure ~/.ssh/config with your servers"
    echo "  2. Run 'msync' to create SSH-based sync"
    echo "  3. Run 'mstart' to begin synchronization"
    echo ""
    echo "📝 Basic Setup:"
    echo "  1. Run 'mgen <project> <endpoint>' for simple setup"
    echo "  2. Edit mutagen.yml as needed"
    echo "  3. Run 'mstart' to begin synchronization"
    echo ""
    echo "⏸️  Session Control:"
    echo "  - mpause: Temporarily pause sync (files won't sync)"
    echo "  - mresume: Resume paused sync"
    echo "  - mstop: Completely stop sync (removes session)"
    echo "  - mstart: Start new sync session"
}

# 자동완성 설정 (간단한 버전)
if [[ -n ${ZSH_VERSION-} ]]; then
    # Mutagen 세션 이름 자동완성을 위한 함수
    _mutagen_sessions() {
        local sessions
        sessions=($(mutagen sync list 2>/dev/null | grep "Name:" | awk '{print $2}'))
        _describe 'sessions' sessions
    }
    
    # 자동완성 등록
    compdef _mutagen_sessions mlogs mrestart mpause mresume
fi

# 별칭 설정 (선택사항)
alias ms='mstatus'
alias ml='mlist'
alias mc='mcheck'
alias mg='mgen'
