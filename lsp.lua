local r17 = _G.r17

r17.lsp = {}
M = {}

local api = vim.api
local buf_cmd_map, buf_map = r17.buf_cmd_map, r17.buf_map

local get_cursor_pos = function()
  return {vim.fn.line('.'), vim.fn.col('.')}
end

local debounce = function(func, timeout)
  local timer_id = nil
  return function(...)
    if timer_id ~= nil then
      vim.fn.timer_stop(timer_id)
    end
    local args = {...}

    timer_id = vim.fn.timer_start(timeout, function()
      func(args)
      timer_id = nil
    end)
  end
end

r17.lsp.show_diagnostics = (function()
  vim.cmd [[packadd lspsaga.nvim]]
  local debounced = debounce(
                        require'lspsaga.diagnostic'.show_cursor_diagnostics, 30)
  local cursorpos = get_cursor_pos()
  return function()
    local new_cursor = get_cursor_pos()
    if (new_cursor[1] ~= 1 and new_cursor[2] ~= 1) and
        (new_cursor[1] ~= cursorpos[1] or new_cursor[2] ~= cursorpos[2]) then
      cursorpos = new_cursor
      debounced()
    end
  end
end)()

r17.lsp.line_diagnostics = function()
  api.nvim_exec([[
    augroup hover_diagnostics
      autocmd! * <buffer>
      au CursorHold * lua require("modules.lang.lsp.lspconfig.utils").lsp_show_diagnostics()
    augroup END
  ]], false)
end

r17.lsp.autocmds = function(client, _)
  r17.augroup("LspLocationList", {
    {
      events = {"InsertLeave", "BufWrite", "BufEnter"},
      targets = {"<buffer>"},
      command = [[lua vim.lsp.diagnostic.set_loclist({open_loclist = false})]]
    }
  })
  if client and client.resolved_capabilities.document_highlight then
    r17.augroup("LspCursorCommands", {
      {
        events = {"CursorHold"},
        targets = {"<buffer>"},
        command = "lua vim.lsp.buf.document_highlight()"
      },
      {
        events = {"CursorHoldI"},
        targets = {"<buffer>"},
        command = "lua vim.lsp.buf.document_highlight()"
      },
      {
        events = {"CursorMoved"},
        targets = {"<buffer>"},
        command = "lua vim.lsp.buf.clear_references()"
      }
    })
  end
  if client and client.resolved_capabilities.document_formatting then
    -- format on save
    r17.augroup("LspFormat", {
      {
        events = {"BufWritePre"},
        targets = {"<buffer>"},
        command = "lua vim.lsp.buf.formatting_sync(nil, 5000)"
      }
    })
  end
end

M.lsp.diagnostics = {
  ["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true,
        update_in_insert = false,
        virtual_text = {spacing = 4, prefix = ''},
        signs = {enable = true, priority = 20}
      })
}

r17.lsp.diagnostics_off = {
  ["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = false,
        update_in_insert = false,
        virtual_text = false,
        signs = false
      })
}

r17.lsp.saga = function(bufnr)
  vim.cmd [[packadd lspsaga.nvim]]
  local saga = require 'lspsaga'
  saga.init_lsp_saga(require'modules.lang.config'.lsp_saga())
  buf_map(bufnr, "gd", "Lspsaga lsp_finder")
  buf_map(bufnr, "gsh", "Lspsaga signature_help")
  buf_map(bufnr, "gh", "Lspsaga preview_definition")
  buf_map(bufnr, "grr", "Lspsaga rename")
  buf_map(bufnr, "K", "Lspsaga hover_doc")
  buf_map(bufnr, "<Leader>va", "Lspsaga code_action")
  buf_map(bufnr, "<Leader>vA", "Lspsaga range_code_action")
  buf_map(bufnr, "<Leader>vdb", "Lspsaga diagnostic_jump_prev")
  buf_map(bufnr, "<Leader>vdn", "Lspsaga diagnostic_jump_next")
  buf_map(bufnr, "<Leader>vdl", "Lspsaga show_line_diagnostics")
  buf_cmd_map(bufnr, "<C-f>",
              "require('lspsaga.action').smart_scroll_with_saga(1)")
  buf_cmd_map(bufnr, "<c-b>",
              "require('lspsaga.action').smart_scroll_with_saga(-1)")
end

r17.lsp.mappings = function(bufnr, client)
  buf_cmd_map(bufnr, "gsd", "vim.lsp.buf.document_symbol()")
  buf_cmd_map(bufnr, "gsw", "vim.lsp.buf.workspace_symbol()")
  buf_cmd_map(bufnr, "gi", "vim.lsp.buf.implementation()")
  buf_cmd_map(bufnr, "gR", "vim.lsp.buf.references()")
  buf_cmd_map(bufnr, "gD", "vim.lsp.buf.definition()")
  buf_cmd_map(bufnr, "grn", "vim.lsp.buf.rename()")
  buf_map(bufnr, '<Leader>vf', 'LspFormatting')
  buf_cmd_map(bufnr, "<Leader>vl", 'vim.lsp.diagnostic.set_loclist()')
  if client.resolved_capabilities.type_definition then
    buf_cmd_map(bufnr, "ge", "vim.lsp.buf.type_definition()")
  end
end

return M

command {
  "LspLog",
  function()
    local path = vim.lsp.get_log_path()
    vim.cmd("edit " .. path)
  end
}

command {
  "LspRestart",
  function()
    vim.lsp.stop_client(vim.lsp.get_active_clients())
    vim.cmd [[edit]]
  end
}

command {
  "LspFormat",
  function()
    vim.lsp.buf.formatting(vim.g[string.format("format_options_%s",
                                               vim.bo.filetype)] or {})
  end
}

command {
  "LspToggleVirtualText",
  function()
    local virtual_text = {}
    virtual_text.show = true
    virtual_text.show = not virtual_text.show
    vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(0, 1), 0, 1,
                               {virtual_text = virtual_text.show})
  end
}
