local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },

    window = {
        completion = cmp.config.window.bordered({
            border = 'rounded',
            winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:Visual,Search:None',
            col_offset = -3,
            side_padding = 0,
        }),
        documentation = cmp.config.window.bordered({
            border = 'rounded',
            winhighlight = 'Normal:CmpDoc,FloatBorder:CmpBorder',
            max_width = 60,
            max_height = 20,
        }),
    },

    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),

        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),

        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),

    sources = cmp.config.sources({
        { name = 'nvim_lsp', priority = 1000 },
        { name = 'luasnip',  priority = 750 },
        { name = 'buffer',   priority = 500 },
    }),

    formatting = {
        format = function(entry, vim_item)
            local icons = {
                nvim_lsp = '󰒋 ',
                luasnip  = ' ',
                buffer   = '󰈙 ',
            }

            local source = entry.source.name
            vim_item.kind = (icons[source] or '● ') .. vim_item.kind
            vim_item.menu = source == 'nvim_lsp' and '' or source:upper()

            return vim_item
        end,
    },
})

-- Cmdline completion
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = 'buffer' } },
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' },
        { name = 'cmdline' },
    }),
})
