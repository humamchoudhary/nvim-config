-- lua/docviewer/html_parser.lua
-- Simple HTML to readable text converter

local M = {}

-- Remove HTML tags and decode entities
M.strip_html = function(html)
    if not html then return "" end
    
    -- Remove script and style tags and their contents
    html = html:gsub("<script[^>]*>.-</script>", "")
    html = html:gsub("<style[^>]*>.-</style>", "")
    
    -- Remove comments
    html = html:gsub("<!%-%-.-%%-%->", "")
    
    -- Convert common block elements to newlines
    html = html:gsub("<br[^>]*>", "\n")
    html = html:gsub("<br/>", "\n")
    html = html:gsub("</p>", "\n\n")
    html = html:gsub("</div>", "\n")
    html = html:gsub("</h[1-6]>", "\n\n")
    html = html:gsub("</li>", "\n")
    html = html:gsub("</tr>", "\n")
    
    -- Convert headings to markdown-style
    html = html:gsub("<h1[^>]*>(.-)</h1>", "\n# %1\n")
    html = html:gsub("<h2[^>]*>(.-)</h2>", "\n## %1\n")
    html = html:gsub("<h3[^>]*>(.-)</h3>", "\n### %1\n")
    html = html:gsub("<h4[^>]*>(.-)</h4>", "\n#### %1\n")
    html = html:gsub("<h5[^>]*>(.-)</h5>", "\n##### %1\n")
    html = html:gsub("<h6[^>]*>(.-)</h6>", "\n###### %1\n")
    
    -- Convert lists
    html = html:gsub("<li[^>]*>", "• ")
    
    -- Convert code blocks
    html = html:gsub("<code[^>]*>(.-)</code>", "`%1`")
    html = html:gsub("<pre[^>]*>(.-)</pre>", "\n```\n%1\n```\n")
    
    -- Convert emphasis
    html = html:gsub("<strong[^>]*>(.-)</strong>", "**%1**")
    html = html:gsub("<b[^>]*>(.-)</b>", "**%1**")
    html = html:gsub("<em[^>]*>(.-)</em>", "*%1*")
    html = html:gsub("<i[^>]*>(.-)</i>", "*%1*")
    
    -- Remove all remaining HTML tags
    html = html:gsub("<[^>]+>", "")
    
    -- Decode HTML entities
    local entities = {
        ["&nbsp;"] = " ",
        ["&lt;"] = "<",
        ["&gt;"] = ">",
        ["&amp;"] = "&",
        ["&quot;"] = '"',
        ["&#39;"] = "'",
        ["&apos;"] = "'",
        ["&mdash;"] = "—",
        ["&ndash;"] = "–",
        ["&hellip;"] = "…",
        ["&copy;"] = "©",
        ["&reg;"] = "®",
        ["&trade;"] = "™",
    }
    
    for entity, char in pairs(entities) do
        html = html:gsub(entity, char)
    end
    
    -- Decode numeric entities
    html = html:gsub("&#(%d+);", function(n)
        return string.char(tonumber(n))
    end)
    
    html = html:gsub("&#x(%x+);", function(n)
        return string.char(tonumber(n, 16))
    end)
    
    -- Clean up multiple newlines
    html = html:gsub("\n\n\n+", "\n\n")
    
    -- Trim whitespace
    html = html:gsub("^%s+", "")
    html = html:gsub("%s+$", "")
    
    return html
end

-- Extract main content from HTML (try to find article/main/content divs)
M.extract_main_content = function(html)
    if not html then return "" end
    
    -- Try to find main content areas
    local patterns = {
        '<article[^>]*>(.-)</article>',
        '<main[^>]*>(.-)</main>',
        '<div[^>]*class="[^"]*content[^"]*"[^>]*>(.-)</div>',
        '<div[^>]*class="[^"]*article[^"]*"[^>]*>(.-)</div>',
        '<div[^>]*class="[^"]*documentation[^"]*"[^>]*>(.-)</div>',
        '<div[^>]*id="content"[^>]*>(.-)</div>',
        '<div[^>]*id="main"[^>]*>(.-)</div>',
    }
    
    for _, pattern in ipairs(patterns) do
        local content = html:match(pattern)
        if content and #content > 100 then
            return content
        end
    end
    
    -- If no specific content area found, return the whole HTML
    return html
end

-- Convert HTML to readable text with markdown formatting
M.html_to_text = function(html)
    if not html then return "" end
    
    -- Extract main content first
    local content = M.extract_main_content(html)
    
    -- Strip HTML tags and convert to text
    local text = M.strip_html(content)
    
    return text
end

-- Process HTML lines (for when we get HTML as an array of lines)
M.process_html_lines = function(lines)
    if not lines or #lines == 0 then
        return {}
    end
    
    -- Join all lines
    local html = table.concat(lines, "\n")
    
    -- Convert to text
    local text = M.html_to_text(html)
    
    -- Split back into lines
    local result = {}
    for line in text:gmatch("[^\r\n]+") do
        -- Skip empty lines at the start
        if #result > 0 or line:match("%S") then
            table.insert(result, line)
        end
    end
    
    return result
end

-- Extract text content from specific HTML elements
M.extract_element_text = function(html, element)
    if not html or not element then return "" end
    
    local pattern = string.format("<%s[^>]*>(.-)</%s>", element, element)
    local matches = {}
    
    for match in html:gmatch(pattern) do
        local text = M.strip_html(match)
        if text and text:match("%S") then
            table.insert(matches, text)
        end
    end
    
    return table.concat(matches, "\n\n")
end

-- Get title from HTML
M.get_title = function(html)
    if not html then return nil end
    
    -- Try <title> tag
    local title = html:match("<title[^>]*>(.-)</title>")
    if title then
        return M.strip_html(title)
    end
    
    -- Try first <h1>
    title = html:match("<h1[^>]*>(.-)</h1>")
    if title then
        return M.strip_html(title)
    end
    
    return nil
end

-- Extract code examples from HTML
M.extract_code_examples = function(html)
    if not html then return {} end
    
    local examples = {}
    
    -- Find <pre><code> blocks
    for code in html:gmatch("<pre[^>]*><code[^>]*>(.-)</code></pre>") do
        local cleaned = M.strip_html(code)
        if cleaned and cleaned:match("%S") then
            table.insert(examples, cleaned)
        end
    end
    
    -- Find standalone <code> blocks
    if #examples == 0 then
        for code in html:gmatch("<code[^>]*>(.-)</code>") do
            local cleaned = M.strip_html(code)
            if cleaned and cleaned:match("%S") and #cleaned > 10 then
                table.insert(examples, cleaned)
            end
        end
    end
    
    return examples
end

return M
