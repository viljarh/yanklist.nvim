# yanklist.nvim

Neovim plugin to manage and reuse yank history in a side panel.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
  - [Using `lazy.nvim`](#using-lazynvim)
  - [Using `packer.nvim`](#using-packernvim)
- [Usage](#usage)
- [Keybinding](#keybinding)
  - [Default Keybinding](#default-keybinding)
  - [Custom Keybinding](#custom-keybinding)
- [Contributing](#contributing)
- [Related Projects](#related-projects)

## Features

- View yank history in a side panel
- **Default keybinding**: `<leader>yl` to toggle the yank list
- Yank any item from history with `<CR>`
- Preview the full content of a yank in a floating window with `P`
- Close the yank list with `q` or a toggle keybinding
- Handles multiline yanks with truncation in the display
- Automatically restores focus to the side panel after previewing a yank

## Installation

<details>

<summary>Using `lazy.nvim`</summary>

```lua
{
    "viljarh/yanklist.nvim",
    config = function()
        require("yanklist").setup()
    end,
}
```

</details>

<details>
<summary>Using `packer.nvim`</summary>

```lua
use {
    "viljarh/yanklist.nvim",
    config = function()
        require("yanklist").setup()
    end,
}
```

</details>

## Usage

- Open Yank List: Press `<leader>yl` (default keybinding)
- Select an Item: Navigate to an item and press `<CR>` to yank it
- Preview a Yank: Press `P` to open a floating window showing the full content
  - Close the floating window with `q` or `<ESC>`
  - Focus automatically returns to the side panel after closing the floating window
- Close the Window: Press `q` (inside the panel) or toggle with `<leader>yl`

## Keybinding

### Default keybinding

- By default, the plugin sets `<leader>yl` to toggle the yank list.

### Custom Keybinding

If you'd like to set a custom keybinding, you can pass it to the `setup` function:

```lua
require("yanklist").setup({
    keymap = "<leader>yy" -- Replace with your keybinding
})
```

```

## Contributing

Contributions are welcome! Feel free to submit a pull request or file an issue.

## Related Projects

- [mbbill/undotree](https://github.com/mbbill/undotree): Inspiration for this project
```
