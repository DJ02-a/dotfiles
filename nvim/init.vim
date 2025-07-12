" =================================
" 기본 설정
" =================================
set number
set relativenumber  
set numberwidth=4
set cursorline
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,euc-kr,cp949
set langmenu=ko_KR.UTF-8
set background=dark " or light if you want light mode

call plug#begin('~/.config/nvim/plugged')
" THEMES
" Plug 'rebelot/kanagawa.nvim'
Plug 'ellisonleao/gruvbox.nvim'
" Any valid git URL is allowed
Plug 'https://github.com/junegunn/vim-easy-align.git'
" Use 'dir' option to install plugin in a non-default directory
Plug 'junegunn/fzf', { 'dir': '~/.fzf' }
" Neo-tree (NERDTree 대체)
Plug 'nvim-neo-tree/neo-tree.nvim', { 'branch': 'v3.x' }
Plug 'MunifTanjim/nui.nvim'
Plug 's1n7ax/nvim-window-picker'
" Tagbar : a classoutline viewer for Vim
Plug 'https://github.com/preservim/tagbar.git'
" Nvim-web-devicons(Need Nerd Font) for file icons
Plug 'nvim-tree/nvim-web-devicons'
" barbar.nvim
Plug 'lewis6991/gitsigns.nvim' " OPTIONAL: for git status
Plug 'romgrk/barbar.nvim'
" telescope(search files)
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
" git Interface
Plug 'sindrets/diffview.nvim'
Plug 'NeogitOrg/neogit'
" syntax highlighting, indentation plugin
Plug 'https://github.com/nvim-treesitter/nvim-treesitter.git'
Plug 'ryanoasis/vim-devicons'
" makedown viewer
Plug 'ellisonleao/glow.nvim'
" ================= FOR Python ================
Plug 'stevearc/conform.nvim'                          " Formatter (black, isort 등)
Plug 'mfussenegger/nvim-lint'                         " Diagnostics (flake8, mypy 등)
Plug 'AckslD/swenv.nvim'                              " 가상환경 선택 (pyenv, conda, venv 등)
Plug 'psf/black'                                      " Formatter (CLI도 병행 사용)
Plug 'https://github.com/skanehira/denops-docker.vim.git'                    " Docker 연동
Plug 'Ramilito/kubectl.nvim'             " K8s 연동
Plug 'mbbill/undotree'
" for Python LSP
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
" Python
" Type Hints
Plug 'nvimtools/none-ls.nvim'

" github
Plug 'kdheepak/lazygit.nvim'
Plug 'tpope/vim-fugitive'
Plug 'lewis6991/gitsigns.nvim'

" copilot
Plug 'github/copilot.vim'
Plug 'CopilotC-Nvim/CopilotChat.nvim'

" tmux
Plug 'christoomey/vim-tmux-navigator'

" vim-coach
Plug 'folke/snacks.nvim'
Plug 'shahshlok/vim-coach.nvim'

" Dashboard
Plug 'nvimdev/dashboard-nvim'

" footer
Plug 'nvim-lualine/lualine.nvim'

call plug#end()

" Color schemes should be loaded after plug#end().
" We prepend it with 'silent!' to ignore errors when it's not yet installed.
" silent! colorscheme kanagawa
silent! colorscheme gruvbox
" 여기서 플러그인 설정 시작 (Lua 코드)
lua << EOF
-- =================================
-- THEME 설정
-- =================================
require("gruvbox").setup({
  terminal_colors = true, -- add neovim terminal colors
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    emphasis = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
})
vim.cmd("colorscheme gruvbox")

-- =================================
-- nvim-window-picker 설정
-- =================================
local window_picker_ok, window_picker = pcall(require, "window-picker")
if window_picker_ok then
  window_picker.setup({
    filter_rules = {
      include_current_win = false,
      autoselect_one = true,
      bo = {
        filetype = { "neo-tree", "neo-tree-popup", "notify" },
        buftype = { "terminal", "quickfix" },
      },
    },
  })
end

-- =================================
-- Neo-tree 설정 (별도 파일에서 로드)
-- =================================
local neotree_config_ok, neotree_config = pcall(require, "config.neotree")
if neotree_config_ok then
  neotree_config.setup()
else
  vim.notify("Neo-tree config not found at lua/config/neotree.lua", vim.log.levels.WARN)
end

-- 안전한 require 함수
local function safe_require(module)
    local ok, result = pcall(require, module)
    if not ok then
        vim.notify("Failed to load " .. module .. ": " .. result, vim.log.levels.ERROR)
        return nil
    end
    return result
end

-- =================================
-- Footer - lualine 설정
-- =================================
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'gruvbox',
    
    -- component_separators = { left = '', right = ''},
    -- component_separators = { left = '|', right = '|'},
    -- section_separators = { left = '', right = ''},
    section_separators = { left = '|', right = '|'},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
      refresh_time = 16, -- ~60fps
      events = {
        'WinEnter',
        'BufEnter',
        'BufWritePost',
        'SessionLoadPost',
        'FileChangedShellPost',
        'VimResized',
        'Filetype',
        'CursorMoved',
        'CursorMovedI',
        'ModeChanged',
      },
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

-- LSP 설정이 이미 존재하는지 확인
local lsp_servers = vim.tbl_keys(require('lspconfig').util.available_servers())
local pyright_running = false

for _, server in ipairs(lsp_servers) do
    if server == 'pyright' then
        local clients = vim.lsp.get_clients({ name = 'pyright' })
        if #clients > 0 then
            pyright_running = true
            break
        end
    end
end

-- Pyright 설정 (중복 실행 방지)
if not pyright_running then
    local lspconfig = safe_require('lspconfig')
    if lspconfig then
        lspconfig.pyright.setup({
            cmd = { "pyright-langserver", "--stdio" },
            filetypes = { "python" },
            single_file_support = true,
            settings = {
                python = {
                    pythonPath = vim.fn.exepath('python'),
                    analysis = {
                        typeCheckingMode = "basic",  -- strict에서 basic으로 변경
                        autoImportCompletions = true,
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        diagnosticMode = "openFilesOnly",
                        reportMissingImports = true,
                        reportUnusedImport = false,
                        reportUnusedVariable = false,  -- 너무 많은 경고 방지
                        reportUndefinedVariable = true,
                    }
                }
            },
            on_attach = function(client, bufnr)
                -- 중복 클라이언트 정리
                vim.defer_fn(function()
                    local clients = vim.lsp.get_clients({ name = "pyright" })
                    if #clients > 1 then
                        for i = 2, #clients do
                            clients[i].stop()
                        end
                    end
                end, 100)
            
                -- 인레이 힌트 설정
                if client.server_capabilities.inlayHintProvider then
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end
            end,
        })
    end
end

-- none-ls 설정 (안전하게 로드)
local null_ls = safe_require("null-ls")
if null_ls then
    null_ls.setup({
        sources = {
            null_ls.builtins.formatting.black.with({
                extra_args = { "--line-length=88" }
            }),
            null_ls.builtins.formatting.isort.with({
                extra_args = { "--profile=black" }
            }),
        },
        on_attach = function(client, bufnr)
            if client:supports_method("textDocument/formatting") then
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = bufnr,
                    callback = function()
                        if vim.bo[bufnr].filetype == "python" then
                            vim.lsp.buf.format({ 
                                bufnr = bufnr,
                                timeout_ms = 5000,  -- 타임아웃 추가
                                filter = function(client)
                                    return client.name == "null-ls"
                                end
                            })
                        end
                    end,
                })
            end
        end,   
    })
end

-- nvim-lint 설정 (안전하게 로드)
local lint = safe_require('lint')
if lint then
    lint.linters_by_ft = {
        python = {'flake8'}
    }
    
    -- flake8 경로 설정
    local flake8_path = vim.fn.exepath('flake8')
    if flake8_path ~= '' then
        lint.linters.flake8.cmd = flake8_path
    end
    
    -- 실시간 린팅 설정 (빈도 줄임)
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        pattern = "*.py",
        callback = function()
            lint.try_lint()
        end,
    })
end

-- 자동완성 설정
local cmp = safe_require('cmp')
if cmp then
    cmp.setup({
        sources = {
            { name = 'nvim_lsp' },
            { name = 'buffer' },
            { name = 'path' },
        },
        mapping = cmp.mapping.preset.insert({
            ['<Down>'] = cmp.mapping.select_next_item(),
            ['<Up>'] = cmp.mapping.select_prev_item(),
            ['<Tab>'] = cmp.mapping.select_next_item(),
            ['<S-Tab>'] = cmp.mapping.select_prev_item(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.close(),
        })
    })
end

-- Telescope 설정
local telescope = safe_require('telescope')
if telescope then
    telescope.setup({
        defaults = {
            cwd = vim.fn.getcwd(),
            file_ignore_patterns = {
                "node_modules/",
                ".git/",
                "__pycache__/",
                "*.pyc",
                ".DS_Store",
                "*.log"
            },
            mappings = {
                i = {
                    ["<C-h>"] = "which_key",
                    ["<C-u>"] = false,
                    ["<C-d>"] = false,
                },
            },
        },
        pickers = {
            find_files = {
                find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
                follow = true,
            },
        },
    })
end

-- Glow 설정
local glow = safe_require('glow')
if glow then
    glow.setup({
        style = "dark",
        width = 120,
        height = 100,
        width_ratio = 0.8,
        height_ratio = 0.8,
    })
end

-- CopilotChat 설정
local copilot_chat = safe_require("CopilotChat")
if copilot_chat then
    copilot_chat.setup({
        debug = false,  -- 디버그 모드 비활성화
    })
end

-- vim-coach 설정
local vim_coach = safe_require('vim-coach')
if vim_coach then
    vim_coach.setup()
end

-- Dashboard 설정 (수정된 부분 - 에러 처리 개선)
local dashboard_ok = safe_require('config.dashboard')
if not dashboard_ok then
    vim.notify("Dashboard config not loaded, using fallback", vim.log.levels.WARN)
    -- 기본 Dashboard 설정
    local dashboard = safe_require('dashboard')
    if dashboard then
        dashboard.setup({
            theme = 'hyper',
            config = {
                header = {
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
                },
                shortcut = {
                    { desc = 'Find Files', group = 'Function', action = 'Telescope find_files', key = 'f' },
                    { desc = 'Recent Files', group = 'Function', action = 'Telescope oldfiles', key = 'r' },
                    { desc = 'File Tree', group = 'Type', action = 'Neotree toggle', key = 'e' },
                    { desc = 'Config', group = 'Identifier', action = 'edit ~/.config/nvim/init.vim', key = 'c' },
                    { desc = 'Quit', group = 'Error', action = 'qa', key = 'q' },
                },
                footer = { "", "🚀 Happy Coding!", "" }
            }
        })
    end
end

EOF

" =================================
" 키맵 설정
" =================================

" LSP 키맵
nnoremap gh <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>t <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>s <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap gD <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap gr <cmd>lua vim.lsp.buf.references()<CR>

" 포맷팅
nnoremap <leader>f <cmd>lua vim.lsp.buf.format()<CR>

" Undo/Redo 키맵
nnoremap <C-z> u
nnoremap <C-S-z> <C-r>
inoremap <C-z> <C-o>u
inoremap <C-S-z> <C-o><C-r>
vnoremap <C-z> u
vnoremap <C-S-z> <C-r>

" Undo Tree
nnoremap <leader>u :UndotreeToggle<CR>
nnoremap <F5> :UndotreeToggle<CR>

" 진단 정보 키맵
nnoremap <leader>e :lua vim.diagnostic.open_float()<CR>
nnoremap <leader>q :lua vim.diagnostic.setloclist()<CR>
nnoremap ]d :lua vim.diagnostic.goto_next()<CR>
nnoremap [d :lua vim.diagnostic.goto_prev()<CR>

" 또는 더 간단하게
nnoremap <F2> :lua vim.diagnostic.open_float()<CR>

" Ctrl+방향키로 윈도우 이동
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j  
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" 터미널 빠르게 열기
nnoremap <leader>t :split \| terminal<CR>
nnoremap <leader>T :vsplit \| terminal<CR>

" 타입 힌트 토글
nnoremap <leader>h <cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>

" 타입 정보 확인
nnoremap K :lua vim.lsp.buf.hover()<CR>

" =================================
" Neo-tree 키맵 설정
" =================================

" Neo-tree 토글 키맵
nnoremap <leader>n :Neotree toggle<CR>
nnoremap <F3> :Neotree toggle<CR>
nnoremap <C-n> :Neotree toggle<CR>

" Neo-tree에서 현재 파일 찾기
nnoremap <leader>nf :Neotree reveal<CR>

" Neo-tree 포커스
nnoremap <leader>e :Neotree focus<CR>

" =================================
" Undo 설정
" =================================
set undofile
set undodir=~/.config/nvim/undo
set undolevels=1000
set undoreload=10000

" undo 디렉토리 생성
if !isdirectory(&undodir)
    call mkdir(&undodir, 'p')
endif

" =================================
" 파일/버퍼 이동 키맵
" =================================

" Option+Tab으로 버퍼 간 이동 (macOS)
nnoremap <A-Tab> :bnext<CR>
nnoremap <A-S-Tab> :bprev<CR>

" Insert 모드에서도 사용 가능
inoremap <A-Tab> <Esc>:bnext<CR>
inoremap <A-S-Tab> <Esc>:bprev<CR>

" Option+숫자로 버퍼 직접 이동 (1~9)
nnoremap <A-1> :b1<CR>
nnoremap <A-2> :b2<CR>
nnoremap <A-3> :b3<CR>
nnoremap <A-4> :b4<CR>
nnoremap <A-5> :b5<CR>
nnoremap <A-6> :b6<CR>
nnoremap <A-7> :b7<CR>
nnoremap <A-8> :b8<CR>
nnoremap <A-9> :b9<CR>

" 이전 파일로 빠른 전환
nnoremap <leader><leader> <C-^>

" Shift+Shift로 Telescope 파일 검색
nnoremap <S-S> :Telescope find_files cwd=.<CR>

" 추가 Telescope 기능들
nnoremap <leader>ff :Telescope find_files cwd=.<CR>
nnoremap <leader>fb :Telescope buffers<CR>
nnoremap <leader>fg :Telescope live_grep cwd=.<CR>
nnoremap <leader>fh :Telescope help_tags<CR>

" 버퍼 관리
nnoremap <leader>b :ls<CR>
nnoremap <leader>bd :bdelete<CR>

" 빠른 파일 관리
nnoremap <C-w> :bdelete<CR>
nnoremap <C-t> :enew<CR>

" 마크다운 뷰어 키맵
nnoremap <leader>md :Glow<CR>
nnoremap <F8> :Glow<CR>

" Git 키맵 설정
nnoremap <silent> <leader>lg :LazyGit<CR>
nnoremap <silent> <leader>gs :Git<CR>
nnoremap <silent> <leader>gc :Git commit<CR>
nnoremap <silent> <leader>gp :Git push<CR>

" CopilotChat 키맵 설정
let g:copilot_no_tab_map = v:true

" 제안 수락
imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")

" 제안 탐색
imap <C-,> <Plug>(copilot-previous)
imap <C-.> <Plug>(copilot-next)  

" 색상 설정
highlight LineNr ctermfg=244
highlight CursorLineNr ctermfg=220
highlight CursorLine ctermbg=236
