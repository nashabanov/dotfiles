vim.lsp.config('ruff', {
  settings = {
    ruff = {
      lint = {
        select = { "ALL" },  
        ignore = { "ANN" },  
      },
      format = {
        lineLength = 88,    
        quoteStyle = "double",
      }
    }
  }
})

