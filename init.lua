-- tmux copy mode for Rex panes. See README.md.
local M = {}

-- Read the script once and run it with bash -c, so copy mode also works in
-- panes on remote hosts that don't have this repo
local f = assert(io.open(debug.getinfo(1, "S").source:gsub("^@", ""):match("^(.*/)") .. "rex-tmux-copy"))
local script = f:read("*a")
f:close()

-- Find a block's rect in a layer's layout tree
local function rect(node, id)
  if node == nil then
    return nil
  end
  if node.block_id == id then
    return node.rect
  end
  return node.split and (rect(node.split.before, id) or rect(node.split.after, id))
end

function M.setup(opts)
  opts = opts or {}

  rex.action({
    name = "tmux_copy_mode",
    title = "Copy Mode (tmux)",
    run = function(ctx)
      local view, err = rex.session.view({})
      if view == nil then
        error(err, 0)
      end
      for _, w in ipairs(view.windows or {}) do
        for _, layer in ipairs(w.layers or {}) do
          -- Do nothing inside a copy mode pane
          for _, b in ipairs(layer.blocks or {}) do
            if b.block_id == ctx.block_id and b.label == "copy mode" then
              return
            end
          end
          local bounds = rect(layer.layout, ctx.block_id)
          if bounds then
            -- Cover the source pane, or the whole window if it is zoomed.
            -- Opening the float unzooms the pane, so the script zooms it again.
            local zoomed = w.zoomed_block_id == ctx.block_id
            if zoomed then
              bounds = { 0, 0, 1, 1 }
            end
            -- Start at the source's size so copy mode doesn't open at 80x24
            local size = rex.block.call("com.superlogical.terminal", "size", { block_id = ctx.block_id })
            local _, err = rex.session.new_layer({
              window_id = w.window_id,
              bounds = bounds,
              focus = true,
              layout = rex.layout.block({
                flavor = "com.superlogical.terminal.shell",
                label = "copy mode",
                options = {
                  shell = "none",
                  size = size and { columns = size.columns, rows = size.rows } or nil,
                  command = { "bash", "-c", script, "rex-tmux-copy", ctx.block_id, zoomed and "zoomed" or "-" },
                },
              }),
            })
            if err ~= nil then
              error(err, 0)
            end
            return
          end
        end
      end
      error("tmux copy mode: no pane " .. tostring(ctx.block_id), 0)
    end,
  })

  if opts.key ~= false then
    rex.bind(opts.key or "ctrl+a>[", "tmux_copy_mode")
  end
end

return M
