-- ===============================================
-- ~/.config/nvim/lua/config/dashboard.lua (수정된 버전)
-- Dashboard 자동 실행 개선
-- ===============================================

local status_ok, dashboard = pcall(require, "dashboard")
if not status_ok then
  vim.notify("dashboard-nvim plugin not found!", vim.log.levels.WARN)
  return
end

-- 외부 파일에서 헤더 읽기 함수
local function read_header_from_file(file_path)
  local header_lines = {}

  local expanded_path = vim.fn.expand(file_path)

  -- 파일이 없으면 조용히 기본 헤더 반환 (경고 없음)
  if vim.fn.filereadable(expanded_path) == 0 then
    return {
      "",
      "    ██████╗ ██╗   ██╗████████╗██╗  ██╗ ██████╗ ███╗   ██╗",
      "    ██╔══██╗╚██╗ ██╔╝╚══██╔══╝██║  ██║██╔═══██╗████╗  ██║",
      "    ██████╔╝ ╚████╔╝    ██║   ███████║██║   ██║██╔██╗ ██║",
      "    ██╔═══╝   ╚██╔╝     ██║   ██╔══██║██║   ██║██║╚██╗██║",
      "    ██║        ██║      ██║   ██║  ██║╚██████╔╝██║ ╚████║",
      "    ╚═╝        ╚═╝      ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝",
      "",
      "            🐍 Python Development Environment 🐍",
      "",
    }
  end
  
  local file = io.open(expanded_path, "r")
  if not file then
    vim.notify("Cannot open header file: " .. expanded_path, vim.log.levels.ERROR)
    return {"", "Header file read error", ""}
  end
  
  for line in file:lines() do
    table.insert(header_lines, line)
  end
  file:close()
  
  if #header_lines == 0 then
    return {"", "Empty header file", ""}
  end
  
  table.insert(header_lines, 1, "")
  table.insert(header_lines, "")
  table.insert(header_lines, "            🐍 Python Development Environment 🐍")
  table.insert(header_lines, "")
  
  return header_lines
end

-- Python 개발 전용 함수들 (동일)
local function create_python_project()
  local project_name = vim.fn.input("Enter project name: ")
  if project_name ~= "" then
    vim.cmd("terminal poetry new " .. project_name)
  end
end

local function activate_poetry_shell()
  if vim.fn.filereadable("pyproject.toml") == 1 then
    vim.cmd("terminal poetry shell")
  else
    vim.notify("No pyproject.toml found in current directory", vim.log.levels.WARN)
  end
end

local function run_pytest()
  if vim.fn.filereadable("pyproject.toml") == 1 then
    vim.cmd("terminal poetry run pytest")
  else
    vim.cmd("terminal pytest")
  end
end

-- NERDTree 토글 함수 추가
local function toggle_nerdtree()
  vim.cmd("NERDTreeToggle")
end

-- 헤더 파일 경로 설정
local header_file_paths = {
  "~/.config/nvim/headers/python_header.txt",
  "~/.config/nvim/python_ascii.txt",
  "~/python_header.txt",
}

local function get_header_file_path()
  for _, path in ipairs(header_file_paths) do
    if vim.fn.filereadable(vim.fn.expand(path)) == 1 then
      return path
    end
  end
  return header_file_paths[1]
end

-- 외부 파일에서 헤더 로드
local python_header = read_header_from_file(get_header_file_path())

-- Dashboard 헤더 색상을 흰색으로 설정 (즉시 적용)
vim.api.nvim_set_hl(0, 'DashboardHeader', { fg = '#ffffff' })
vim.api.nvim_set_hl(0, 'DashboardShortCut', { fg = '#ffffff' })
vim.api.nvim_set_hl(0, 'DashboardFooter', { fg = '#ffffff' })

-- Dashboard 설정 (hyper 테마로 변경하여 recent files 표시)
dashboard.setup({
  theme = 'hyper',
  config = {
    header = python_header,
    
    shortcut = {
      {
        icon = '🐍 ',
        desc = 'New Python Project',
        group = 'String',
        action = create_python_project,
        key = 'p',
      },
      {
        icon = '📦 ',
        desc = 'Poetry Shell',
        group = 'Constant',
        action = activate_poetry_shell,
        key = 's',
      },
      {
        icon = '🔍 ',
        desc = 'Find Files',
        group = 'Function',
        action = 'Telescope find_files',
        key = 'f',
      },
      {
        icon = '🔎 ',
        desc = 'Live Grep',
        group = 'Function',
        action = 'Telescope live_grep',
        key = 'g',
      },
      {
        icon = '📝 ',
        desc = 'New File',
        group = 'Function',
        action = 'enew',
        key = 'n',
      },
      {
        icon = '🐳 ',
        desc = 'Docker',
        group = 'Special',
        action = 'terminal docker ps',
        key = 'd',
      },
      {
        icon = '☸️  ',
        desc = 'Kubernetes',
        group = 'Special',
        key = 'k',
        action = 'terminal kubectl get pods',
      },
      {
        icon = '⚙️  ',
        desc = 'Config',
        group = 'Identifier',
        action = 'edit ~/.config/nvim/init.vim',
        key = 'c',
      },
      {
        icon = '⏻ ',
        desc = 'Quit',
        group = 'Error',
        action = 'qa',
        key = 'q',
      },
    },
    
    project = {
      enable = true,
      limit = 6,
      icon = ' ',
      label = '📁 Recent Projects:',
      action = 'Telescope find_files cwd='
    },
    
    mru = {
      limit = 8,
      icon = ' ',
      label = '📋 Recent Files:',
      cwd_only = false,
    },
    
    footer = {
      "",
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
      "",
      "🚀 Ready to code? Choose an option above or press 'p' for a new Python project!",
      "",
      "💡 Tips:",
      "   • Use 'po' command for Poetry operations",
      "   • Use 'postatus' to check your Poetry environment", 
      "   • Press 'e' to open file tree (NERDTree)",
      "",
      "⚡ Powered by Neovim, Python, Poetry & Love",
      "",
    }
  },
})

-- Dashboard 자동 실행 설정 (개선된 버전)
local dashboard_group = vim.api.nvim_create_augroup("Dashboard", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = dashboard_group,
  callback = function()
    -- 인수가 없고, 버퍼가 비어있을 때만 Dashboard 실행
    local should_skip = false
    
    -- 파일이나 디렉토리 인수가 있는지 확인
    if vim.fn.argc() > 0 then
      should_skip = true
    end
    
    -- 버퍼에 내용이 있는지 확인
    if vim.fn.line2byte("$") ~= -1 then
      should_skip = true
    end
    
    -- 특별한 시작 옵션이 있는지 확인
    for _, arg in pairs(vim.v.argv) do
      if arg == "-b" or arg == "-c" or vim.startswith(arg, "+") or arg == "-S" then
        should_skip = true
        break
      end
    end
    
    if not should_skip then
      -- 약간의 지연 후 Dashboard 실행 (다른 플러그인들이 로드된 후)
      vim.defer_fn(function()
        vim.cmd("Dashboard")
      end, 50)
    end
  end,
  desc = "Start Dashboard when vim is opened with no arguments"
})

-- Dashboard 버퍼 설정 (숫자키 매핑 제거)
vim.api.nvim_create_autocmd("FileType", {
  group = dashboard_group,
  pattern = "dashboard",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.spell = false
    vim.opt_local.list = false
    vim.opt_local.cursorline = false
    vim.opt_local.colorcolumn = ""
    vim.opt_local.foldcolumn = "0"
    
    -- Dashboard 헤더 색상을 흰색으로 설정
    vim.api.nvim_set_hl(0, 'DashboardHeader', { fg = '#ffffff' })
    
    -- Dashboard에서 기본 키맵만 유지
    vim.keymap.set('n', 'q', ':qa<CR>', { buffer = true, silent = true })
  end,
  desc = "Dashboard buffer settings"
})

-- 헤더 다시 로드 명령어
vim.api.nvim_create_user_command('DashboardReloadHeader', function()
  local new_header = read_header_from_file(get_header_file_path())
  dashboard.setup({
    theme = 'hyper',
    config = {
      header = new_header,
      shortcut = {
        { icon = '🐍 ', desc = 'New Python Project', action = create_python_project, key = 'p' },
        { icon = '📦 ', desc = 'Poetry Shell', action = activate_poetry_shell, key = 's' },
        { icon = '🔍 ', desc = 'Find Files', action = 'Telescope find_files', key = 'f' },
        { icon = '🔎 ', desc = 'Live Grep', action = 'Telescope live_grep', key = 'g' },
        { icon = '📝 ', desc = 'New File', action = 'enew', key = 'n' },
        { icon = '🐳 ', desc = 'Docker', action = 'terminal docker ps', key = 'd' },
        { icon = '☸️ ', desc = 'Kubernetes', action = 'terminal kubectl get pods', key = 'k' },
        { icon = '⚙️ ', desc = 'Config', action = 'edit ~/.config/nvim/init.vim', key = 'c' },
        { icon = '⏻ ', desc = 'Quit', action = 'qa', key = 'q' },
      },
      footer = { "", "🔄 Header reloaded successfully!", "" }
    }
  })
  vim.notify("Dashboard header reloaded!", vim.log.levels.INFO)
  vim.cmd("Dashboard")
end, { desc = 'Reload dashboard header from file' })

-- 키매핑
vim.keymap.set('n', '<leader>dp', create_python_project, { desc = 'Create new Python project' })
vim.keymap.set('n', '<leader>ds', activate_poetry_shell, { desc = 'Activate Poetry shell' })
vim.keymap.set('n', '<leader>dt', run_pytest, { desc = 'Run pytest' })
vim.keymap.set('n', '<leader>dr', ':DashboardReloadHeader<CR>', { desc = 'Reload dashboard header' })
vim.keymap.set('n', '<leader>dd', ':Dashboard<CR>', { desc = 'Open Dashboard' })

-- Python 개발 전용 자동 명령어들
local python_dashboard_group = vim.api.nvim_create_augroup("PythonDashboard", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = python_dashboard_group,
  callback = function()
    if vim.fn.filereadable("pyproject.toml") == 1 then
      vim.notify("📦 Poetry project detected", vim.log.levels.INFO)
    end
    
    local venv_path = os.getenv("VIRTUAL_ENV")
    if venv_path then
      local venv_name = vim.fn.fnamemodify(venv_path, ":t")
      vim.notify("🐍 Virtual environment: " .. venv_name, vim.log.levels.INFO)
    end
  end,
  desc = "Python project information on startup"
})

-- Dashboard 설정 완료 (조용히)
