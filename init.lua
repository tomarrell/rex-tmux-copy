-- tmux copy mode for Rex panes. See README.md.
local M = {}

local dir = debug.getinfo(1, "S").source:gsub("^@", ""):match("^(.*)/[^/]*$")
local script = dir .. "/rex-tmux-copy"

function M.setup(opts)
  opts = opts or {}

  rex.action({
    name = "tmux_copy_mode",
    title = "Copy Mode (tmux)",
    run = function(ctx, _)
      local r, err = rex.exec({ script, "open", ctx.session_id, ctx.block_id }, { timeout = 10 })
      if r == nil then
        error(err, 0)
      end
      if not r.ok then
        error(r.stderr, 0)
      end
    end,
  })

  if opts.key ~= false then
    rex.bind(opts.key or "ctrl+a>[", "tmux_copy_mode")
  end
end

return M
