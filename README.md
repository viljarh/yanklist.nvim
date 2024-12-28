# yanklist.nvim

Neovim plugin to manage and reuse yank history.

## Features

- View yank history
- Yank any item from history with `<CR>`
- Close the history window with `q` or a toggle keybinding
- Handles multiline yanks with truncation in the display

## Installation

### Using `lazy.nvim`:

```lua
{
    "viljarh/yanklist.nvim",
    config = function()
        require("yanklist").setup()
    end,
}
```

### Using `packer.nvim`:

```lua
use {
    "viljarh/yanklist.nvim",
    config = function()
        require("yanklist").setup()
    end,
}
```

## Usage

- Open Yank List: Press `<leader>yl`
- Select an Item: Navigate to an item and press `<CR>` to yank it
- Close the Window: Press `q` or `<leader>yl` again

## Example keybinding

```lua
vim.api.nvim_set_keymap(
    "n",
    "<leader>yl",
    "<cmd>lua require('yanklist.ui').toggle_history()<CR>",
    { noremap = true, silent = true }
)

```

## Contributing

Contributions are welcome! Feel free to submit a pull request or file an issue.

## Related Projects

- [mbbill/undotree](https://github.com/mbbill/undotree): Inspiration for this project
