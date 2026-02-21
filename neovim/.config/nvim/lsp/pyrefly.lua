---@type vim.lsp.Config
return {
  cmd = { "uv", "run", "pyrefly", "lsp" },
  filetypes = { "python" },
  root_markers = {
    "pyrefly.toml",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  },
  settings = {
    init_options = {
      displayTypeErrors = "force-on",
    },
  },
  -- on_attach = function(client, bufnr)
  --   if client.server_capabilities.inlayHintProvider then
  --     vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  --   end
  -- end,
  on_exit = function(code, _, _)
    vim.notify("Closing Pyrefly LSP exited with code: " .. code, vim.log.levels.INFO)
  end,
}
