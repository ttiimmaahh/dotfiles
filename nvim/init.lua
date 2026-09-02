-- skip nvim-ts-context-commentstring's auto-setup; we configure it manually
-- in plugins/comment.lua (avoids the legacy CursorHold autocmd)
vim.g.skip_ts_context_commentstring_module = true

require("config.core")
require("config.lazy")
