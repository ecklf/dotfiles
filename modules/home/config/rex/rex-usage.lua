-- OpenAI plan limits in a floating terminal. Codex owns authentication.
local M = {}

function M.setup(opts)
  opts = opts or {}
  local command = opts.command or { "rex-usage" }

  rex.action({
    name = "openai_usage_popup",
    title = "Show OpenAI Plan Limits",
    category = "AI",
    run = function(ctx)
      local layer, err = rex.session.new_layer({
        window_id = ctx.window_id,
        bounds = { 0.28, 0.34, 0.44, 0.32 },
        focus = true,
        layout = rex.layout.block({
          flavor = "com.superlogical.terminal.shell",
          label = "OpenAI plan limits",
          options = {
            command = command,
            -- Do not load Codex project configuration from the focused pane.
            cwd = assert(os.getenv("HOME"), "HOME is required for the usage popup"),
            exit = { on_completion = true },
          },
        }),
      })
      if not layer then
        error(err, 0)
      end
      return layer
    end,
  })

  rex.bind(opts.key or "ctrl+b>u", "openai_usage_popup")
end

return M
