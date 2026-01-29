" =================================
" 기본 설정
" =================================
set number
set relativenumber  
set numberwidth=4
set cursorline
set encoding=utf-8
set modifiable
set fileencoding=utf-8
set fileencodings=utf-8,euc-kr,cp949
set langmenu=ko_KR.UTF-8
set background=dark " or light if you want light mode

" split/vsplit 창마다 cursorline 활성화
augroup CursorLineOnlyInActiveWindow
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
augroup END

" 기본 탭 설정 (4 spaces)
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" =================================
" 파일 타입별 자동 설정
" =================================
" YAML 파일 설정
autocmd FileType yaml setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd BufNewFile,BufRead *.yml,*.yaml setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab

" JSON 파일 설정
autocmd FileType json setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd FileType json nnoremap <buffer> <leader>jf :%!python -m json.tool<CR>

" Docker 파일 설정
autocmd BufNewFile,BufRead Dockerfile* setlocal filetype=dockerfile
autocmd BufNewFile,BufRead docker-compose*.yml,docker-compose*.yaml setlocal filetype=yaml
autocmd FileType dockerfile setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab

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
Plug 'andythigpen/nvim-coverage'

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
Plug 'lambdalisue/battery.vim'

" =================================
" 편의성 및 시각화 플러그인
" =================================
" 자동 괄호 완성
Plug 'windwp/nvim-autopairs'
" 빠른 주석 토글
Plug 'tpope/vim-commentary'
" 코드 스니펫
Plug 'L3MON4D3/LuaSnip'
Plug 'rafamadriz/friendly-snippets'
" 들여쓰기 가이드라인
Plug 'lukas-reineke/indent-blankline.nvim'
" 동일 변수 하이라이트
Plug 'RRethy/vim-illuminate'
" Plug 'xiyaowong/nvim-cursorword'
" 무지개 괄호
Plug 'HiPhish/rainbow-delimiters.nvim'
" 색상 코드 미리보기
Plug 'norcalli/nvim-colorizer.lua'
" 코드 폴딩
Plug 'kevinhwang91/nvim-ufo'
Plug 'kevinhwang91/promise-async'
" 현재 위치 breadcrumb
Plug 'SmiteshP/nvim-navic'
" 함수 시그니처 힌트
Plug 'ray-x/lsp_signature.nvim'
" 심볼 아웃라인 사이드바
Plug 'simrat39/symbols-outline.nvim'

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
    lualine_c = {
      {
        'filename',
        path = 1,  -- 0: 파일명만, 1: 상대 경로, 2: 절대 경로, 3: 절대 경로와 줄임표
        shorting_target = 40,  -- 너무 긴 경로 줄이기
        symbols = {
          modified = ' [+]',
          readonly = ' [RO]',
          unnamed = '[No Name]',
          newfile = '[New]',
        }
      }
    },
    lualine_x = {
      'encoding',
      {
        function()
          -- macOS에서는 항상 Mac 아이콘 표시
          if vim.fn.has('mac') == 1 or vim.fn.has('macunix') == 1 or vim.loop.os_uname().sysname == 'Darwin' then
            return ''  -- Mac 아이콘 (e711)
          elseif vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
            return '󰖳'  -- Windows 아이콘 (f17a)
          else
            return ''  -- Linux 아이콘 (f17c)
          end
        end,
        color = { fg = '#FE8019' },  -- 주황색으로 강조
      },
      'filetype'
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      {
        'filename',
        path = 1,  -- 상대 경로로 표시
        symbols = {
          modified = ' [+]',
          readonly = ' [RO]',
          unnamed = '[No Name]',
          newfile = '[New]',
        }
      }
    },
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {
    lualine_c = {
      {
        function()
          local navic = require('nvim-navic')
          if navic.is_available() then
            return navic.get_location()
          end
          return ""
        end,
        color = { fg = '#FE8019' },  -- 주황색으로 강조
      }
    }
  },
  inactive_winbar = {},
  extensions = {}
}

-- LSP 설정이 이미 존재하는지 확인 (nvim 0.11 새로운 방식)
local pyright_running = false
local clients = vim.lsp.get_clients({ name = 'pyright' })
if #clients > 0 then
    pyright_running = true
end

-- 가상환경 감지 함수
local function get_python_venv_paths()
    local paths = {}
    local python_path = vim.fn.exepath('python')
    
    -- VIRTUAL_ENV 환경변수 확인
    local venv_path = vim.fn.getenv('VIRTUAL_ENV')
    if venv_path ~= vim.NIL and venv_path ~= '' then
        table.insert(paths, venv_path .. '/lib/python*/site-packages')
        return paths, venv_path
    end
    
    -- CONDA_PREFIX 환경변수 확인 (conda 환경)
    local conda_path = vim.fn.getenv('CONDA_PREFIX')
    if conda_path ~= vim.NIL and conda_path ~= '' then
        table.insert(paths, conda_path .. '/lib/python*/site-packages')
        return paths, conda_path
    end
    
    -- pyenv 환경 확인
    if python_path:match('/.pyenv/') then
        local pyenv_version = vim.fn.system('pyenv version-name 2>/dev/null'):gsub('\n', '')
        if pyenv_version and pyenv_version ~= '' then
            local pyenv_root = vim.fn.getenv('PYENV_ROOT') or (vim.fn.getenv('HOME') .. '/.pyenv')
            local site_packages = pyenv_root .. '/versions/' .. pyenv_version .. '/lib/python*/site-packages'
            table.insert(paths, site_packages)
            return paths, pyenv_root .. '/versions/' .. pyenv_version
        end
    end
    
    return paths, nil
end

-- Pyright 설정 (Neovim 0.11+ 호환)
if not pyright_running then
    local extra_paths, venv_path = get_python_venv_paths()

    -- on_attach 함수 정의
    local function pyright_on_attach(client, bufnr)
        -- 중복 클라이언트 정리
        vim.defer_fn(function()
            local clients = vim.lsp.get_clients({ name = "pyright" })
            if #clients > 1 then
                for i = 2, #clients do
                    clients[i].stop()
                end
            end
        end, 100)

        -- Insert mode에서 실시간 진단 업데이트
        vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
            buffer = bufnr,
            callback = function()
                vim.defer_fn(function()
                    vim.diagnostic.show(nil, bufnr)
                end, 100)
            end,
        })

        -- 인레이 힌트 설정
        if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end

        -- nvim-navic 연동
        local navic = safe_require('nvim-navic')
        if navic and client.server_capabilities.documentSymbolProvider then
            navic.attach(client, bufnr)
        end

        -- lsp_signature 연동
        local lsp_signature = safe_require('lsp_signature')
        if lsp_signature then
            lsp_signature.on_attach({
                bind = true,
                handler_opts = { border = "rounded" }
            }, bufnr)
        end
    end

    -- Neovim 0.11+ 새로운 방식: vim.lsp.config 사용
    if vim.lsp.config then
        -- pyright LSP 설정 등록
        vim.lsp.config.pyright = {
            cmd = { "pyright-langserver", "--stdio" },
            filetypes = { "python" },
            root_markers = {
                "pyproject.toml",
                "setup.py",
                "setup.cfg",
                "requirements.txt",
                "Pipfile",
                ".git"
            },
            settings = {
                python = {
                    pythonPath = vim.fn.exepath('python'),
                    venvPath = venv_path,
                    analysis = {
                        typeCheckingMode = "basic",
                        autoImportCompletions = true,
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        diagnosticMode = "openFilesOnly",
                        reportMissingImports = true,
                        reportUnusedImport = false,
                        reportUnusedVariable = true,
                        reportUndefinedVariable = true,
                        extraPaths = extra_paths,
                    }
                }
            },
        }

        -- Python 파일 자동 시작
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "python",
            callback = function()
                vim.lsp.enable("pyright")
            end,
        })

        -- on_attach 핸들러 추가
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client and client.name == "pyright" then
                    pyright_on_attach(client, args.buf)
                end
            end,
        })
    else
        -- Fallback: 이전 방식 사용 (Neovim 0.10 이하)
        local lspconfig = safe_require('lspconfig')
        if lspconfig then
            lspconfig.pyright.setup({
                cmd = { "pyright-langserver", "--stdio" },
                filetypes = { "python" },
                single_file_support = true,
                settings = {
                    python = {
                        pythonPath = vim.fn.exepath('python'),
                        venvPath = venv_path,
                        analysis = {
                            typeCheckingMode = "basic",
                            autoImportCompletions = true,
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                            diagnosticMode = "openFilesOnly",
                            reportMissingImports = true,
                            reportUnusedImport = false,
                            reportUnusedVariable = true,
                            reportUndefinedVariable = true,
                            extraPaths = extra_paths,
                        }
                    }
                },
                on_attach = pyright_on_attach,
            })
        end
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
    
    -- 실시간 린팅 설정 (Insert mode 포함)
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave", "TextChanged" }, {
        pattern = "*.py",
        callback = function()
            vim.defer_fn(function()
                lint.try_lint()
            end, 500) -- 500ms 지연으로 너무 빈번한 실행 방지
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
            -- Python import picker 통합
            ['<C-i>'] = cmp.mapping(function(fallback)
                if vim.bo.filetype == 'python' and _G.python_import_picker then
                    local word = vim.fn.expand('<cword>')
                    if word and word ~= '' then
                        _G.python_import_picker(word)
                    else
                        fallback()
                    end
                else
                    fallback()
                end
            end, { 'i' }),
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

-- nvim-treesitter 설정
local treesitter = safe_require('nvim-treesitter.configs')
if treesitter then
    treesitter.setup({
        ensure_installed = {
            "python", "lua", "vim", "javascript", "html", "css", 
            "json", "yaml", "toml", "markdown", "bash", "dockerfile"
        },
        sync_install = false,
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
            disable = function(lang, buf)
                local max_filesize = 100 * 1024 -- 100 KB
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end,
        },
        indent = {
            enable = true
        },
        fold = {
            enable = true
        },
        rainbow = {
            enable = true,
            extended_mode = true,
            max_file_lines = nil,
        }
    })
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

-- =================================
-- 편의성 및 시각화 플러그인 설정
-- =================================

-- nvim-autopairs 설정
local autopairs = safe_require('nvim-autopairs')
if autopairs then
    autopairs.setup({
        check_ts = true, -- treesitter 사용
        disable_filetype = { "TelescopePrompt" },
    })
    
    -- cmp와 autopairs 연동
    local cmp_autopairs = safe_require('nvim-autopairs.completion.cmp')
    local cmp = safe_require('cmp')
    if cmp and cmp_autopairs then
        cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end
end

-- LuaSnip 설정
local luasnip = safe_require('luasnip')
if luasnip then
    -- friendly-snippets 로드
    require("luasnip.loaders.from_vscode").lazy_load()
    
    -- 스니펫 키맵
    vim.keymap.set({"i", "s"}, "<C-k>", function()
        if luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        end
    end)
    
    vim.keymap.set({"i", "s"}, "<C-j>", function()
        if luasnip.jumpable(-1) then
            luasnip.jump(-1)
        end
    end)
end

-- indent-blankline 설정 (들여쓰기 가이드라인)
local ibl = safe_require('ibl')
if ibl then
    ibl.setup({
        indent = {
            char = "│",
            tab_char = "│",
        },
        scope = {
            enabled = true,
            char = "┃",  -- 현재 스코프용 굵은 문자
            show_start = true,
            show_end = true,
            injected_languages = false,
            highlight = { "IblScope" },
            priority = 500,
            include = {
                node_type = {
                    ["*"] = {
                        "function_definition",
                        "class_definition", 
                        "if_statement",
                        "for_statement",
                        "while_statement",
                        "with_statement",
                        "try_statement",
                        "except_clause",
                        "finally_clause",
                        "elif_clause",
                        "else_clause",
                        "match_statement",
                        "case_clause",
                        "block",
                        "compound_statement",
                    },
                    python = {
                        "function_definition",
                        "class_definition",
                        "if_statement", 
                        "for_statement",
                        "while_statement",
                        "with_statement",
                        "try_statement",
                        "except_clause",
                        "finally_clause",
                        "elif_clause",
                        "else_clause",
                        "match_statement",
                        "case_clause",
                        "block",
                        "suite",
                    },
                    yaml = {
                        "block_mapping",
                        "block_sequence",
                        "block_scalar",
                        "flow_mapping",
                        "flow_sequence",
                        "block_node",
                        "document",
                        "stream",
                        "block_mapping_pair",
                        "block_sequence_item",
                    },
                    dockerfile = {
                        "instruction",
                        "run_instruction",
                        "copy_instruction",
                        "add_instruction",
                        "workdir_instruction",
                        "env_instruction",
                        "expose_instruction",
                        "volume_instruction",
                        "user_instruction",
                        "label_instruction",
                        "arg_instruction",
                        "onbuild_instruction",
                        "stopsignal_instruction",
                        "healthcheck_instruction",
                        "shell_instruction",
                        "maintainer_instruction",
                        "cross_build_instruction",
                    }
                }
            }
        },
        exclude = {
            filetypes = {
                "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy"
            }
        }
    })
    
    -- 스코프 하이라이트 색상 설정
    vim.api.nvim_set_hl(0, "IblScope", { fg = "#E5C07B", bold = true })
    
    -- 파일 타입별 추가 설정
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
            -- Python에서 더 세밀한 scope 감지를 위한 설정
            vim.opt_local.shiftwidth = 4
            vim.opt_local.tabstop = 4
            vim.opt_local.softtabstop = 4
        end
    })
    
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "yaml", "yml" },
        callback = function()
            -- YAML 파일 설정
            vim.opt_local.shiftwidth = 2
            vim.opt_local.tabstop = 2
            vim.opt_local.softtabstop = 2
            vim.opt_local.expandtab = true
        end
    })
    
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "dockerfile", "docker" },
        callback = function()
            -- Dockerfile 설정
            vim.opt_local.shiftwidth = 4
            vim.opt_local.tabstop = 4
            vim.opt_local.softtabstop = 4
            vim.opt_local.expandtab = true
        end
    })
end

-- vim-illuminate 설정 (동일 변수 하이라이트)
local illuminate = safe_require('illuminate')
if illuminate then
    illuminate.configure({
        providers = {
            'lsp',
            'treesitter',
            'regex',
        },
        delay = 200,
        filetype_overrides = {},
        filetypes_denylist = {
            'dirbuf',
            'dirvish',
            'fugitive',
        },
        under_cursor = true,
        large_file_cutoff = 2000,
        large_file_overrides = nil,
        min_count_to_highlight = 1,
        should_enable = function(bufnr)
            return true
        end,
        case_insensitive_regex = false,
        modes_denylist = {},  -- 모든 모드에서 활성화
        modes_allowlist = {},
        providers_regex_syntax_denylist = {},
        providers_regex_syntax_allowlist = {},
    })
    
    -- 키맵 설정
    vim.keymap.set('n', '<leader>]', function() illuminate.goto_next_reference() end)
    vim.keymap.set('n', '<leader>[', function() illuminate.goto_prev_reference() end)
end

-- nvim-colorizer 설정 (색상 코드 미리보기)
local colorizer = safe_require('colorizer')
if colorizer then
    colorizer.setup({
        filetypes = {
            'css',
            'javascript',
            'html',
            'lua',
            'vim',
        },
        user_default_options = {
            RGB = true,         -- #RGB hex codes
            RRGGBB = true,      -- #RRGGBB hex codes
            names = true,       -- "Name" codes like Blue or blue
            RRGGBBAA = true,    -- #RRGGBBAA hex codes
            rgb_fn = true,      -- CSS rgb() and rgba() functions
            hsl_fn = true,      -- CSS hsl() and hsla() functions
            css = true,         -- Enable all CSS features
            css_fn = true,      -- Enable all CSS *functions*
        },
    })
end

-- rainbow-delimiters 설정 (무지개 괄호)
local rainbow_delimiters = safe_require('rainbow-delimiters')
if rainbow_delimiters then
    -- 먼저 하이라이트 그룹을 정의
    local colors = {
        "#E06C75", -- Red
        "#E5C07B", -- Yellow
        "#61AFEF", -- Blue
        "#D19A66", -- Orange
        "#98C379", -- Green
        "#C678DD", -- Violet/Purple
        "#56B6C2", -- Cyan
    }
    
    -- 하이라이트 그룹 설정
    for i, color in ipairs(colors) do
        local group_names = {
            "RainbowDelimiterRed",
            "RainbowDelimiterYellow",
            "RainbowDelimiterBlue", 
            "RainbowDelimiterOrange",
            "RainbowDelimiterGreen",
            "RainbowDelimiterViolet",
            "RainbowDelimiterCyan"
        }
        
        if group_names[i] then
            vim.api.nvim_set_hl(0, group_names[i], { fg = color, bold = true })
        end
    end
    
    -- rainbow-delimiters 설정
    vim.g.rainbow_delimiters = {
        strategy = {
            [''] = rainbow_delimiters.strategy['global'],
            python = rainbow_delimiters.strategy['global'],
            lua = rainbow_delimiters.strategy['local'],
        },
        query = {
            [''] = 'rainbow-delimiters',
            lua = 'rainbow-blocks',
        },
        priority = {
            [''] = 110,
            lua = 210,
        },
        highlight = {
            'RainbowDelimiterRed',
            'RainbowDelimiterYellow', 
            'RainbowDelimiterBlue',
            'RainbowDelimiterOrange',
            'RainbowDelimiterGreen',
            'RainbowDelimiterViolet',
            'RainbowDelimiterCyan',
        },
    }
end

-- nvim-navic 설정 (breadcrumb)
local navic = safe_require('nvim-navic')
if navic then
    navic.setup({
        icons = {
            File          = " ",
            Module        = " ",
            Namespace     = " ",
            Package       = " ",
            Class         = " ",
            Method        = " ",
            Property      = " ",
            Field         = " ",
            Constructor   = " ",
            Enum          = "練",
            Interface     = "練",
            Function      = " ",
            Variable      = " ",
            Constant      = " ",
            String        = " ",
            Number        = " ",
            Boolean       = "◩ ",
            Array         = " ",
            Object        = " ",
            Key           = " ",
            Null          = "ﳠ ",
            EnumMember    = " ",
            Struct        = " ",
            Event         = " ",
            Operator      = " ",
            TypeParameter = " ",
        },
        lsp = {
            auto_attach = true,
            preference = nil,
        },
        highlight = true,
        separator = " > ",
        depth_limit = 0,
        depth_limit_indicator = "..",
    })
end

-- symbols-outline 설정
local symbols_outline = safe_require('symbols-outline')
if symbols_outline then
    symbols_outline.setup({
        highlight_hovered_item = true,
        show_guides = true,
        auto_preview = false,
        position = 'right',
        relative_width = true,
        width = 25,
        auto_close = false,
        show_numbers = false,
        show_relative_numbers = false,
        show_symbol_details = true,
        preview_bg_highlight = 'Pmenu',
        autofold_depth = nil,
        auto_unfold_hover = true,
        fold_markers = { '', '' },
        wrap = false,
        keymaps = {
            close = {"<Esc>", "q"},
            goto_location = "<Cr>",
            focus_location = "o",
            hover_symbol = "<C-space>",
            toggle_preview = "K",
            rename_symbol = "r",
            code_actions = "a",
            fold = "h",
            unfold = "l",
            fold_all = "W",
            unfold_all = "E",
            fold_reset = "R",
        },
        lsp_blacklist = {},
        symbol_blacklist = {},
    })
end

-- lsp_signature 설정
local lsp_signature = safe_require('lsp_signature')
if lsp_signature then
    lsp_signature.setup({
        bind = true,
        handler_opts = {
            border = "rounded"
        },
        floating_window = true,
        floating_window_above_cur_line = true,
        fix_pos = false,
        hint_enable = true,
        hint_prefix = "🐍 ",
        hint_scheme = "String",
        hi_parameter = "LspSignatureActiveParameter",
        max_height = 12,
        max_width = 80,
        always_trigger = false,
        auto_close_after = nil,
        extra_trigger_chars = {},
        zindex = 200,
        padding = '',
        transparency = nil,
        shadow_blend = 36,
        shadow_guibg = 'Black',
        timer_interval = 200,
        toggle_key = nil,
    })
end

-- barbar.nvim 설정 (실제 버퍼 번호 표시)
vim.g.barbar_auto_setup = false
local barbar = safe_require('barbar')
if barbar then
    barbar.setup({
        animation = false,
        auto_hide = false,
        tabpages = true,
        clickable = true,
        icons = {
            buffer_index = true,     -- 순차적 인덱스 사용 (1, 2, 3...)
            buffer_number = false,   -- 실제 버퍼 번호 비활성화
            button = '×',            -- 닫기 버튼 활성화
            diagnostics = {
                [vim.diagnostic.severity.ERROR] = {enabled = false},  -- 에러 아이콘 끄기
                [vim.diagnostic.severity.WARN] = {enabled = false},   -- 경고 아이콘 끄기
                [vim.diagnostic.severity.INFO] = {enabled = false},
                [vim.diagnostic.severity.HINT] = {enabled = false},
            },
            gitsigns = {
                added = {enabled = true, icon = '+'},
                changed = {enabled = true, icon = '~'},
                deleted = {enabled = true, icon = '-'},
            },
            filetype = {
                enabled = true,
            },
            separator = {left = '', right = ''},
            modified = {button = '●'},
            inactive = {button = '×'},  -- 비활성 탭에도 닫기 버튼
        },
        maximum_padding = 1,
        minimum_padding = 1,
        maximum_length = 30,
    })
    
    -- 버퍼 번호와 파일명 색상 통일 설정
    vim.api.nvim_set_hl(0, 'BufferCurrentNumber', { fg = '#FE8019', bold = true })  -- 활성 버퍼 번호 (주황색, 볼드)
    vim.api.nvim_set_hl(0, 'BufferCurrent', { fg = '#FE8019', bold = true })        -- 활성 파일명 (주황색, 볼드)
    vim.api.nvim_set_hl(0, 'BufferInactiveNumber', { fg = '#EBDBB2', bold = true })  -- 비활성 버퍼 번호 (파일명과 동일한 밝은 회색)
    vim.api.nvim_set_hl(0, 'BufferInactive', { fg = '#EBDBB2', bold = true })        -- 비활성 파일명 (밝은 회색)
    vim.api.nvim_set_hl(0, 'BufferVisibleNumber', { fg = '#D5C4A1', bold = true })   -- 보이는 버퍼 번호 (밝은 회색, 굵게)
    vim.api.nvim_set_hl(0, 'BufferVisible', { fg = '#D5C4A1', bold = true })         -- 보이는 파일명 (회백색)
end

-- =================================
-- 코드 폴딩 설정 (nvim-ufo + pretty-fold)
-- =================================

-- vim 옵션 설정  
vim.o.foldcolumn = '1' -- 폴드 컬럼 표시
vim.o.foldlevel = 99 -- 높은 폴드 레벨로 시작 (모든 폴드가 열린 상태)
vim.o.foldlevelstart = 99
vim.o.foldenable = true


-- nvim-ufo 설정
local ufo = safe_require('ufo')
if ufo then
    ufo.setup({
        provider_selector = function(bufnr, filetype, buftype)
            if filetype == 'python' then
                return {'indent'}  -- Python은 indent 기반으로 폴딩
            else
                return {'treesitter', 'indent'}
            end
        end,
        preview = {
            win_config = {
                border = {'', '─', '', '', '', '─', '', ''},
                winhighlight = 'Normal:Folded',
                winblend = 0
            },
            mappings = {
                scrollU = '<C-u>',
                scrollD = '<C-d>',
                jumpTop = '[',
                jumpBot = ']'
            }
        }
    })
    
    -- 폴딩 키맵
    vim.keymap.set('n', 'zR', ufo.openAllFolds)
    vim.keymap.set('n', 'zM', ufo.closeAllFolds)
    vim.keymap.set('n', 'zr', ufo.openFoldsExceptKinds)
    vim.keymap.set('n', 'zm', ufo.closeFoldsWith)
    -- Global variables for enhanced hover
    _G.hover_enhanced = {
        info_winid = nil,
        code_winid = nil,
        current_params = nil,
        show_info = false,
        show_code = false,
    }
    
    vim.keymap.set('n', 'K', function()
        local winid = ufo.peekFoldedLinesUnderCursor()
        if not winid then
            -- Store current position for enhanced hover features
            local client = vim.lsp.get_clients({ bufnr = 0 })[1]
            _G.hover_enhanced.current_params = vim.lsp.util.make_position_params(0, client and client.offset_encoding or 'utf-16')
            -- Also store the current buffer and cursor position
            _G.hover_enhanced.source_buf = vim.api.nvim_get_current_buf()
            _G.hover_enhanced.cursor_pos = vim.api.nvim_win_get_cursor(0)
            vim.lsp.buf.hover()
        end
    end)
    
    -- <leader>r: Show additional info (Definition, Type, References)
    vim.keymap.set('n', '<leader>r', function()
        -- Always update to current position
        local client = vim.lsp.get_clients({ bufnr = 0 })[1]
        _G.hover_enhanced.current_params = vim.lsp.util.make_position_params(0, client and client.offset_encoding or 'utf-16')
        _G.hover_enhanced.source_buf = vim.api.nvim_get_current_buf()
        _G.hover_enhanced.cursor_pos = vim.api.nvim_win_get_cursor(0)
        
        if _G.hover_enhanced.show_info then
            -- Hide info window
            if _G.hover_enhanced.info_winid and vim.api.nvim_win_is_valid(_G.hover_enhanced.info_winid) then
                vim.api.nvim_win_close(_G.hover_enhanced.info_winid, true)
            end
            _G.hover_enhanced.info_winid = nil
            _G.hover_enhanced.show_info = false
        else
            -- Show info window
            _G.show_enhanced_info()
        end
    end)
    
    -- <leader>i: Show/hide function/class code
    vim.keymap.set('n', '<leader>i', function()
        -- Always update to current position
        local client = vim.lsp.get_clients({ bufnr = 0 })[1]
        _G.hover_enhanced.current_params = vim.lsp.util.make_position_params(0, client and client.offset_encoding or 'utf-16')
        _G.hover_enhanced.source_buf = vim.api.nvim_get_current_buf()
        _G.hover_enhanced.cursor_pos = vim.api.nvim_win_get_cursor(0)
        
        if _G.hover_enhanced.show_code then
            -- Hide code window
            if _G.hover_enhanced.code_winid and vim.api.nvim_win_is_valid(_G.hover_enhanced.code_winid) then
                vim.api.nvim_win_close(_G.hover_enhanced.code_winid, true)
            end
            _G.hover_enhanced.code_winid = nil
            _G.hover_enhanced.show_code = false
        else
            -- Show code window
            _G.show_definition_code()
        end
    end)
    
    -- Function to show enhanced information
    _G.show_enhanced_info = function()
        local params = _G.hover_enhanced.current_params
        if not params then return end
        
        local info_lines = {}
        local completed_requests = 0
        local total_requests = 3
        
        -- Get definition info
        vim.lsp.buf_request(0, 'textDocument/definition', params, function(def_err, def_result)
            if def_result and def_result[1] then
                local uri = def_result[1].uri
                local range = def_result[1].range
                local file_path = vim.uri_to_fname(uri)
                local line_num = range.start.line + 1
                table.insert(info_lines, "📍 Definition: " .. vim.fn.fnamemodify(file_path, ":t") .. ":" .. line_num)
            else
                table.insert(info_lines, "📍 Definition: Not found")
            end
            
            completed_requests = completed_requests + 1
            if completed_requests == total_requests then
                _G.display_info_window(info_lines)
            end
        end)
        
        -- Get type definition info
        vim.lsp.buf_request(0, 'textDocument/typeDefinition', params, function(type_err, type_result)
            if type_result and type_result[1] then
                local type_uri = type_result[1].uri
                local type_range = type_result[1].range
                local type_file = vim.uri_to_fname(type_uri)
                local type_line = type_range.start.line + 1
                table.insert(info_lines, "🏷️  Type: " .. vim.fn.fnamemodify(type_file, ":t") .. ":" .. type_line)
            else
                table.insert(info_lines, "🏷️  Type: Not found")
            end
            
            completed_requests = completed_requests + 1
            if completed_requests == total_requests then
                _G.display_info_window(info_lines)
            end
        end)
        
        -- Get references count and locations
        vim.lsp.buf_request(0, 'textDocument/references', vim.tbl_extend('force', params, {
            context = { includeDeclaration = false }
        }), function(ref_err, ref_result)
            if ref_result and #ref_result > 0 then
                table.insert(info_lines, "🔗 References: " .. #ref_result .. " found")
                table.insert(info_lines, "")
                
                -- Group references by file
                local refs_by_file = {}
                for _, ref in ipairs(ref_result) do
                    local file_path = vim.uri_to_fname(ref.uri)
                    local file_name = vim.fn.fnamemodify(file_path, ":t")
                    local line_num = ref.range.start.line + 1
                    
                    if not refs_by_file[file_name] then
                        refs_by_file[file_name] = {}
                    end
                    table.insert(refs_by_file[file_name], {
                        line = line_num,
                        path = file_path
                    })
                end
                
                -- Sort and display references
                for file_name, refs in pairs(refs_by_file) do
                    table.insert(info_lines, "📄 " .. file_name .. ":")
                    
                    -- Sort by line number
                    table.sort(refs, function(a, b) return a.line < b.line end)
                    
                    for _, ref in ipairs(refs) do
                        -- Try to get the actual line content for context
                        local line_content = ""
                        local file = io.open(ref.path, 'r')
                        if file then
                            local current_line = 1
                            for line in file:lines() do
                                if current_line == ref.line then
                                    line_content = line:gsub("^%s+", ""):gsub("%s+$", "") -- trim whitespace
                                    break
                                end
                                current_line = current_line + 1
                            end
                            file:close()
                        end
                        
                        if line_content ~= "" and #line_content < 60 then
                            table.insert(info_lines, string.format("   L%d: %s", ref.line, line_content))
                        else
                            table.insert(info_lines, string.format("   L%d", ref.line))
                        end
                    end
                    table.insert(info_lines, "")
                end
            else
                table.insert(info_lines, "🔗 References: 0 found")
            end
            
            completed_requests = completed_requests + 1
            if completed_requests == total_requests then
                _G.display_info_window(info_lines)
            end
        end)
    end
    
    -- Function to display info window
    _G.display_info_window = function(lines)
        if #lines == 0 then
            lines = {"No additional information available"}
        end
        
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
        vim.api.nvim_buf_set_option(bufnr, 'filetype', 'markdown')
        
        -- Calculate width and height based on content
        local max_line_length = 0
        for _, line in ipairs(lines) do
            max_line_length = math.max(max_line_length, #line)
        end
        
        local width = math.max(60, math.min(100, max_line_length + 4))
        local height = math.min(25, math.max(5, #lines + 2))
        
        _G.hover_enhanced.info_winid = vim.api.nvim_open_win(bufnr, true, {
            relative = 'cursor',
            width = width,
            height = height,
            row = 2,
            col = 0,
            border = 'rounded',
            title = ' Additional Info ',
            title_pos = 'center',
            style = 'minimal',
        })
        
        -- Set window highlight and enable scrolling
        vim.api.nvim_win_set_option(_G.hover_enhanced.info_winid, 'winhl', 'Normal:PmenuSel,FloatBorder:PmenuSel')
        vim.api.nvim_win_set_option(_G.hover_enhanced.info_winid, 'wrap', true)
        
        -- Set up keymaps for the info window
        vim.keymap.set('n', 'q', function()
            if _G.hover_enhanced.info_winid and vim.api.nvim_win_is_valid(_G.hover_enhanced.info_winid) then
                vim.api.nvim_win_close(_G.hover_enhanced.info_winid, true)
            end
            _G.hover_enhanced.info_winid = nil
            _G.hover_enhanced.show_info = false
        end, { buffer = bufnr, silent = true })
        
        vim.keymap.set('n', '<Esc>', function()
            if _G.hover_enhanced.info_winid and vim.api.nvim_win_is_valid(_G.hover_enhanced.info_winid) then
                vim.api.nvim_win_close(_G.hover_enhanced.info_winid, true)
            end
            _G.hover_enhanced.info_winid = nil
            _G.hover_enhanced.show_info = false
        end, { buffer = bufnr, silent = true })
        
        _G.hover_enhanced.show_info = true
    end
    
    -- Function to show definition code
    _G.show_definition_code = function()
        local params = _G.hover_enhanced.current_params
        if not params then return end
        
        vim.lsp.buf_request(0, 'textDocument/definition', params, function(def_err, def_result)
            if not def_result or not def_result[1] then
                vim.notify("Definition not found", vim.log.levels.WARN)
                return
            end
            
            local uri = def_result[1].uri
            local range = def_result[1].range
            local file_path = vim.uri_to_fname(uri)
            
            -- Read the entire file
            local file_lines = {}
            local file = io.open(file_path, 'r')
            if file then
                for line in file:lines() do
                    table.insert(file_lines, line)
                end
                file:close()
            else
                vim.notify("Cannot read file: " .. file_path, vim.log.levels.ERROR)
                return
            end
            
            -- Get the definition line (1-based)
            local def_line = range.start.line + 1
            local filetype = vim.fn.fnamemodify(file_path, ":e")
            
            -- Prepare all lines with line numbers
            local display_lines = {}
            for i, line in ipairs(file_lines) do
                table.insert(display_lines, string.format("%4d: %s", i, line))
            end
            
            if #display_lines == 0 then
                display_lines = {"No code available"}
            end
            
            -- Create buffer and show code window
            local bufnr = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, display_lines)
            vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
            vim.api.nvim_buf_set_option(bufnr, 'filetype', filetype)
            
            local width = math.min(120, vim.o.columns - 10)
            local height = math.min(30, math.max(15, math.min(#display_lines + 2, vim.o.lines - 10)))
            
            _G.hover_enhanced.code_winid = vim.api.nvim_open_win(bufnr, true, {
                relative = 'cursor',
                width = width,
                height = height,
                row = 4,
                col = 0,
                border = 'rounded',
                title = ' Full File: ' .. vim.fn.fnamemodify(file_path, ":t"),
                title_pos = 'center',
                style = 'minimal',
            })
            
            -- Set window highlight and enable syntax
            vim.api.nvim_win_set_option(_G.hover_enhanced.code_winid, 'winhl', 'Normal:Normal,FloatBorder:FloatBorder')
            
            -- Move cursor to the definition line and center it
            vim.api.nvim_win_set_cursor(_G.hover_enhanced.code_winid, {def_line, 0})
            vim.api.nvim_feedkeys('zz', 'n', false) -- Center the line in the window
            
            -- Set up keymaps for the code window
            vim.keymap.set('n', 'q', function()
                if _G.hover_enhanced.code_winid and vim.api.nvim_win_is_valid(_G.hover_enhanced.code_winid) then
                    vim.api.nvim_win_close(_G.hover_enhanced.code_winid, true)
                end
                _G.hover_enhanced.code_winid = nil
                _G.hover_enhanced.show_code = false
            end, { buffer = bufnr, silent = true })
            
            vim.keymap.set('n', '<Esc>', function()
                if _G.hover_enhanced.code_winid and vim.api.nvim_win_is_valid(_G.hover_enhanced.code_winid) then
                    vim.api.nvim_win_close(_G.hover_enhanced.code_winid, true)
                end
                _G.hover_enhanced.code_winid = nil
                _G.hover_enhanced.show_code = false
            end, { buffer = bufnr, silent = true })
            
            -- Enter: Go to line in the actual file
            vim.keymap.set('n', '<CR>', function()
                -- Get current cursor position in the code window
                local cursor_pos = vim.api.nvim_win_get_cursor(_G.hover_enhanced.code_winid)
                local line_in_window = cursor_pos[1]
                
                -- Get the line content to extract the line number
                local line_content = vim.api.nvim_buf_get_lines(bufnr, line_in_window - 1, line_in_window, false)[1]
                if not line_content then return end
                
                -- Extract line number from format "   123: code content"
                local line_num = line_content:match("^%s*(%d+):")
                if not line_num then return end
                
                line_num = tonumber(line_num)
                
                -- Close the code window
                if _G.hover_enhanced.code_winid and vim.api.nvim_win_is_valid(_G.hover_enhanced.code_winid) then
                    vim.api.nvim_win_close(_G.hover_enhanced.code_winid, true)
                end
                _G.hover_enhanced.code_winid = nil
                _G.hover_enhanced.show_code = false
                
                -- Check if there are multiple windows (vsplit already exists)
                local windows = vim.api.nvim_list_wins()
                local current_file = vim.fn.expand('%:p')
                
                if #windows > 1 then
                    -- Multiple windows exist, move to the opposite window
                    vim.cmd('wincmd w')  -- Switch to the other window
                    
                    -- Open the file in the opposite window
                    vim.cmd('edit ' .. vim.fn.fnameescape(file_path))
                else
                    -- Only one window, create vsplit
                    if current_file ~= file_path then
                        vim.cmd('vsplit ' .. vim.fn.fnameescape(file_path))
                    else
                        -- Same file, create vsplit and stay in new window
                        vim.cmd('vsplit')
                    end
                end
                
                -- Go to the specific line
                vim.api.nvim_win_set_cursor(0, {line_num, 0})
                vim.cmd('normal! zz') -- Center the line in the window
                
                -- Optional: highlight the line briefly without entering visual mode
                local ns_id = vim.api.nvim_create_namespace('hover_highlight')
                vim.api.nvim_buf_add_highlight(0, ns_id, 'Visual', line_num - 1, 0, -1)
                
                -- Clear highlight after 300ms
                vim.defer_fn(function()
                    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
                end, 300)
                
            end, { buffer = bufnr, silent = true })
            
            _G.hover_enhanced.show_code = true
        end)
    end
end

-- 폴딩 표시 커스터마이징 (화살표만 표시)
vim.o.fillchars = [[eob: ,fold: ,foldopen:▼,foldsep: ,foldclose:▶]]

-- 단순하게 foldcolumn만 사용 (숫자는 테마에서 숨김 처리)
vim.o.foldcolumn = '1'

-- 커스텀 폴드 텍스트 (화살표 + 라인 수)
local function custom_fold_text()
    local line = vim.fn.getline(vim.v.foldstart)
    local line_count = vim.v.foldend - vim.v.foldstart + 1
    return "▶ " .. line:gsub("^%s*", "") .. " (" .. line_count .. " lines)"
end

_G.custom_fold_text = custom_fold_text
vim.o.foldtext = 'v:lua.custom_fold_text()'

-- Python 전용 폴딩 설정 (indent 기반으로 단순화)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python", 
    callback = function()
        -- 간단한 indent 기반 폴딩 사용
        vim.wo.foldmethod = 'indent'
        vim.wo.foldlevel = 99
    end
})


-- 폴드 하이라이트 설정
vim.api.nvim_set_hl(0, 'Folded', { 
    fg = '#98c379', 
    bg = '#3e4452', 
    bold = true 
})
vim.api.nvim_set_hl(0, 'FoldColumn', { 
    fg = '#98c379', 
    bg = 'none' 
})

-- 기본 폴드 컬럼 색상 설정
vim.api.nvim_set_hl(0, 'FoldColumn', { 
    fg = '#5c6370',  -- 회색으로 숫자 표시
    bg = 'none'
})



-- LSP 진단 설정 개선
vim.diagnostic.config({
    update_in_insert = true,  -- Insert mode에서도 진단 업데이트
    severity_sort = true,
    float = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = 'rounded',
        source = 'always',
        prefix = ' ',
    },
    virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
    },
    signs = true,
    underline = true,
})

-- 진단 하이라이트 색상 설정
vim.api.nvim_set_hl(0, 'DiagnosticUnnecessary', { fg = '#665c54', italic = true })  -- 사용되지 않는 변수용 회색

-- =================================
-- Coverage 설정
-- =================================
-- nvim-coverage 설정 (플러그인이 설치되어 있을 때만)
local coverage_ok, coverage = pcall(require, 'coverage')
if coverage_ok and coverage then
    coverage.setup({
        commands = true, -- create commands
        highlights = {
            -- customize highlight groups created by the plugin
            covered = { fg = "#98C379" },      -- covered lines (green)
            uncovered = { fg = "#E06C75" },    -- uncovered lines (red)  
            partial = { fg = "#E5C07B" },      -- partially covered lines (yellow)
        },
        signs = {
            -- use your own highlight groups or text markers
            covered = { hl = "CoverageCovered", text = "▎" },
            uncovered = { hl = "CoverageUncovered", text = "▎" },
            partial = { hl = "CoveragePartial", text = "▎" },
        },
        summary = {
            -- customize the summary pop-up
            min_coverage = 80.0, -- minimum coverage threshold (used for highlighting)
        },
        lang = {
            -- configure language specific settings
            python = {
                -- Can specify a different coverage command or 'lcov' for a lcov file
                coverage_command = "coverage json --fail-under=0 -q -o -",
                coverage_file = ".coverage", -- coverage data file path
            },
        },
    })
    
    -- Coverage 하이라이트 그룹 설정
    vim.api.nvim_set_hl(0, 'CoverageCovered', { fg = '#98C379', bold = true })    -- 커버된 라인 (초록색)
    vim.api.nvim_set_hl(0, 'CoverageUncovered', { fg = '#E06C75', bold = true })  -- 커버되지 않은 라인 (빨간색)
    vim.api.nvim_set_hl(0, 'CoveragePartial', { fg = '#E5C07B', bold = true })    -- 부분 커버 (노란색)
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

" Undo/Redo 키맵 (크로스 플랫폼: Ctrl+Z)
nnoremap <C-z> u
nnoremap <C-S-z> <C-r>
nnoremap U <C-r>
inoremap <C-z> <C-o>u
inoremap <C-y> <C-o><C-r>
vnoremap <C-z> u
vnoremap <C-S-z> <C-r>

" macOS 추가 매핑: Command 키 (터미널이 지원하는 경우)
if has('mac')
    nnoremap <D-z> u
    nnoremap <D-S-z> <C-r>
    inoremap <D-z> <C-o>u
    inoremap <D-S-z> <C-o><C-r>
    vnoremap <D-z> u
    vnoremap <D-S-z> <C-r>
endif

" Alternative undo mappings for terminals that don't support Cmd key
" Meta key alternatives (Alt/Option + z)
nnoremap <M-z> u
inoremap <M-z> <C-o>u
vnoremap <M-z> u

" Additional failsafe mappings
inoremap <A-z> <C-o>u
nnoremap <A-z> u

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
nnoremap <C-n> :lua require('config.neotree').toggle_with_resize()<CR>

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

" Terminal key sequence timeout settings for better key recognition
set timeout
set timeoutlen=1000
set ttimeout
set ttimeoutlen=10

" undo 디렉토리 생성
if !isdirectory(&undodir)
    call mkdir(&undodir, 'p')
endif

" =================================
" 파일/버퍼 이동 키맵
" =================================

" Alt+Tab으로 버퍼 간 이동 (크로스 플랫폼: macOS Option, Linux Alt)
nnoremap <A-Tab> :bnext<CR>
nnoremap <A-S-Tab> :bprev<CR>

" Insert 모드에서도 사용 가능
inoremap <A-Tab> <Esc>:bnext<CR>
inoremap <A-S-Tab> <Esc>:bprev<CR>

" Insert 모드에서 Shift+Tab으로 들여쓰기 감소
inoremap <S-Tab> <C-D>

" Option+숫자로 탭 인덱스 이동 (순차적 1~9)
nnoremap <A-1> <Cmd>BufferGoto 1<CR>
nnoremap <A-2> <Cmd>BufferGoto 2<CR>
nnoremap <A-3> <Cmd>BufferGoto 3<CR>
nnoremap <A-4> <Cmd>BufferGoto 4<CR>
nnoremap <A-5> <Cmd>BufferGoto 5<CR>
nnoremap <A-6> <Cmd>BufferGoto 6<CR>
nnoremap <A-7> <Cmd>BufferGoto 7<CR>
nnoremap <A-8> <Cmd>BufferGoto 8<CR>
nnoremap <A-9> <Cmd>BufferGoto 9<CR>

" 이전 파일로 빠른 전환
nnoremap <leader><leader> <C-^>

" Shift+Shift로 Telescope 파일 검색
nnoremap <S-S> :Telescope find_files cwd=.<CR>

" 추가 Telescope 기능들
nnoremap <leader>ff :Telescope find_files cwd=.<CR>
nnoremap <leader>fb :Telescope buffers<CR>
nnoremap <leader>fg :Telescope live_grep cwd=.<CR>
nnoremap <leader>fh :Telescope help_tags<CR>

" 코드 접기(Folding) 키 매핑
nnoremap <space> za          " 스페이스로 접기/펼치기 토글
nnoremap zR zR               " 모든 접기 펼치기 (기본 유지)  
nnoremap zM zM               " 모든 접기 접기 (기본 유지)
nnoremap zo zo               " 접기 펼치기 (기본 유지)
nnoremap zc zc               " 접기 닫기 (기본 유지)
nnoremap zj zj               " 다음 접기로 이동 (기본 유지)
nnoremap zk zk               " 이전 접기로 이동 (기본 유지)

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

" Git 상태 미리보기 키맵 (Gitsigns)
nnoremap <leader>gh :Gitsigns preview_hunk<CR>
nnoremap <leader>gb :Gitsigns blame_line<CR>
nnoremap <leader>gr :Gitsigns reset_hunk<CR>
nnoremap <leader>gu :Gitsigns undo_stage_hunk<CR>

" Python 가상환경 키맵
nnoremap <leader>ve :lua require('swenv.api').pick_venv()<CR>
nnoremap <leader>vc :lua print(require('swenv.api').get_current_venv())<CR>

" Coverage 키맵
nnoremap <leader>cc :Coverage<CR>
nnoremap <leader>cs :CoverageShow<CR>
nnoremap <leader>ch :CoverageHide<CR>
nnoremap <leader>ct :CoverageToggle<CR>
nnoremap <leader>cr :CoverageLoad<CR>
nnoremap <leader>cu :CoverageSummary<CR>
nnoremap <F6> :CoverageToggle<CR>

" 심볼 아웃라인 키맵
nnoremap <leader>so :SymbolsOutline<CR>
nnoremap <F4> :SymbolsOutline<CR>

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

" Treesitter 에러 방지용 대체 키맵
nnoremap dG :.,$d<CR>
nnoremap yG :.,$y<CR>

" 리더키+숫자로 탭 인덱스 이동 (순차적)
nnoremap <leader>1 <Cmd>BufferGoto 1<CR>
nnoremap <leader>2 <Cmd>BufferGoto 2<CR>
nnoremap <leader>3 <Cmd>BufferGoto 3<CR>
nnoremap <leader>4 <Cmd>BufferGoto 4<CR>
nnoremap <leader>5 <Cmd>BufferGoto 5<CR>
nnoremap <leader>6 <Cmd>BufferGoto 6<CR>
nnoremap <leader>7 <Cmd>BufferGoto 7<CR>
nnoremap <leader>8 <Cmd>BufferGoto 8<CR>
nnoremap <leader>9 <Cmd>BufferGoto 9<CR>
nnoremap <leader>0 <Cmd>BufferGoto 10<CR>

" Alt+Shift+방향키로 줄 이동 (크로스 플랫폼: macOS Option, Linux Alt)
nnoremap <A-S-k> :m .-2<CR>==
nnoremap <A-S-j> :m .+1<CR>==
vnoremap <A-S-k> :m '<-2<CR>gv=gv
vnoremap <A-S-j> :m '>+1<CR>gv=gv
inoremap <A-S-k> <Esc>:m .-2<CR>==gi
inoremap <A-S-j> <Esc>:m .+1<CR>==gi
