local soundplayer = require("noisemachine.audiomanager")

vim.api.nvim_create_user_command("Noisemachinestart", soundplayer.play, {})
vim.api.nvim_create_user_command("Noisemachinestop", soundplayer.stop, {})
vim.api.nvim_create_user_command("Noisemachinenext", soundplayer.nextgenerator, {})
