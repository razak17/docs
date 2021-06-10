-- Plugins
local fn, uv, api = vim.fn, vim.loop, vim.api
local data_dir = string.format('%s/site/', vim.fn.stdpath('data'))
local packer_compiled = data_dir .. '/packer_compiled_test.vim'
local compile_to_lua = data_dir .. '/lua/_compiled_test.lua'
local packer = nil

local Plug = {}
Plug.__index = Plug

function Plug:load_packer()
  if not packer then
    api.nvim_command('packadd packer.nvim')
    packer = require('packer')
  end
  packer.init({
    compile_path = packer_compiled,
    git = {clone_timeout = 120},
    disable_commands = true
  })
  packer.reset()
  local use = packer.use
  use {'wbthomason/packer.nvim', opt = true}

  -- use {'franbach/miramare', config = vim.cmd [[colo miramare]]}
  use {'razak17/zephyr-nvim', config = vim.cmd [[colo zephyr]]}
  use {
    'tpope/vim-fugitive',
    event = {'VimEnter'}
  }
  use {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup({
        disable_filetype = {"TelescopePrompt", "vim"}
      })
    end
  }
  use {
    'tweekmonster/startuptime.vim',
    cmd = "StartupTime"
  }
  use {
    'tpope/vim-surround',
    event = {'BufReadPre', 'BufNewFile'}
  }
  use {
    'b3nj5m1n/kommentary',
    event = {'BufReadPre', 'BufNewFile'},
    config = function()
      require('kommentary.config').configure_language("default", {
        prefer_single_line_comments = true
    })
    end
  }
  use {
    "nvim-treesitter/nvim-treesitter",
    event = 'BufRead',
    run = ":TSUpdate",
    config = function()
      local fts = {"lua"}
      vim.api.nvim_command('set foldmethod=expr')
      vim.api.nvim_command('set foldexpr=nvim_treesitter#foldexpr()')
      require'nvim-treesitter.configs'.setup {
        ensure_installed = fts,
        highlight = {enable = true},
      }
      vim.api.nvim_set_keymap('n', 'R', ':write | edit | TSBufEnable highlight<CR>',
                        {});
    end
  }
  use {
    "p00f/nvim-ts-rainbow",
    requires = "nvim-treesitter/nvim-treesitter",
    after = "nvim-treesitter"
  }
  use {
    'romainl/vim-cool',
    event = {'BufRead', 'BufNewFile'},
    config = function()
      vim.g.CoolTotalMatches = 1
    end
  }
  use {'rhysd/accelerated-jk', opt = true, event = "VimEnter"}
  use {
    'norcalli/nvim-colorizer.lua',
    event = {'BufReadPre', 'BufNewFile'},
    config = function()
    end
  }
  use {'mbbill/undotree', cmd = "UndotreeToggle"}
  use {
    'hrsh7th/nvim-compe',
    event = 'InsertEnter',
    config = function()
      require('compe').setup {
        enabled = true,
        min_length = 1,
        preselect = "always"
      }
    end
  }
  use {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    config = function()
      local actions = require('telescope.actions')
      vim.cmd [[packadd plenary.nvim]]
      vim.cmd [[packadd popup.nvim]]
      vim.cmd [[packadd telescope-fzy-native.nvim]]

      require('telescope').setup({
        defaults = {
          prompt_prefix = "> ",
          selection_caret = " ",
          sorting_strategy = "ascending",
          borderchars = {'─', '│', '─', '│', '┌', '┐', '┘', '└'},
          file_sorter = require'telescope.sorters'.get_fzy_sorter,
          file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
          grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
          qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
          mappings = {i = {["<C-e>"] = actions.send_to_qflist}},
          file_browser = {hidden = true},
          extensions = {
            fzy_native = {
              override_generic_sorter = false,
              override_file_sorter = true
            }
          }
        }
      })
      require'telescope'.load_extension('fzy_native')
    end,
    requires = {
      {'nvim-lua/popup.nvim', opt = true},
      {'nvim-lua/plenary.nvim', opt = true},
      {'nvim-telescope/telescope-fzy-native.nvim', opt = true}
    }
  }
end

function Plug:init_ensure_plugins()
  local packer_dir = data_dir .. 'pack/packer/opt/packer.nvim'
  local state = uv.fs_stat(packer_dir)
  if not state then
    local cmd = "!git clone https://github.com/wbthomason/packer.nvim " ..
                    packer_dir
    api.nvim_command(cmd)
    uv.fs_mkdir(data_dir .. 'lua', 511, function()
      assert("make compile path dir faield")
    end)
    self:load_packer()
    packer.install()
  end
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    if not packer then
      Plug:load_packer()
    end
    return packer[key]
  end
})

function plugins.ensure_plugins()
  Plug:init_ensure_plugins()
end

function plugins.convert_compile_file()
  local lines = {}
  local lnum = 1
  lines[#lines + 1] = 'vim.cmd [[packadd packer.nvim]]\n'

  for line in io.lines(packer_compiled) do
    lnum = lnum + 1
    if lnum > 15 then
      lines[#lines + 1] = line .. '\n'
      if line == 'END' then
        break
      end
    end
  end
  table.remove(lines, #lines)

  if vim.fn.isdirectory(data_dir .. 'lua') ~= 1 then
    os.execute('mkdir -p ' .. data_dir .. 'lua')
  end

  if vim.fn.filereadable(compile_to_lua) == 1 then
    os.remove(compile_to_lua)
  end

  local file = io.open(compile_to_lua, "w")
  for _, line in ipairs(lines) do
    file:write(line)
  end
  file:close()

  os.remove(packer_compiled)
end

function plugins.magic_compile()
  plugins.compile()
  plugins.convert_compile_file()
end

function plugins.load_compile()
  plugins.magic_compile()
  vim.cmd [[command! PlugCompile lua require('core.plug').magic_compile()]]
  vim.cmd [[command! PlugInstall lua require('core.plug').install()]]
  vim.cmd [[command! PlugUpdate lua require('core.plug').update()]]
  vim.cmd [[command! PlugSync lua require('core.plug').sync()]]
  vim.cmd [[command! PlugClean lua require('core.plug').clean()]]
  vim.cmd [[autocmd User PlugComplete lua require('core.plug').magic_compile()]]
end

return plugins

