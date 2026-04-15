-- lua/docviewer/offline_docs.lua
-- Offline documentation snippets and quick reference

local M = {}

-- Built-in documentation snippets (offline)
M.docs = {
    javascript = {
        array = {
            title = "JavaScript Arrays",
            content = [[
# Array Methods

## Common Methods
- `push()` - Add element to end
- `pop()` - Remove last element
- `shift()` - Remove first element
- `unshift()` - Add element to beginning
- `slice(start, end)` - Extract section
- `splice(start, deleteCount, items)` - Change contents
- `concat()` - Merge arrays
- `join(separator)` - Join elements into string

## Iteration Methods
- `forEach(callback)` - Execute function for each element
- `map(callback)` - Create new array with results
- `filter(callback)` - Create array with filtered elements
- `reduce(callback, initial)` - Reduce to single value
- `find(callback)` - Find first element
- `findIndex(callback)` - Find first element index
- `some(callback)` - Test if any element passes
- `every(callback)` - Test if all elements pass

## Example
```javascript
const arr = [1, 2, 3, 4, 5];
const doubled = arr.map(x => x * 2);  // [2, 4, 6, 8, 10]
const evens = arr.filter(x => x % 2 === 0);  // [2, 4]
const sum = arr.reduce((acc, x) => acc + x, 0);  // 15
```
]],
        },
        promise = {
            title = "JavaScript Promises",
            content = [[
# Promises

## Creating a Promise
```javascript
const promise = new Promise((resolve, reject) => {
    // Async operation
    if (success) {
        resolve(value);
    } else {
        reject(error);
    }
});
```

## Using Promises
```javascript
promise
    .then(result => console.log(result))
    .catch(error => console.error(error))
    .finally(() => console.log('Done'));
```

## Async/Await
```javascript
async function fetchData() {
    try {
        const response = await fetch(url);
        const data = await response.json();
        return data;
    } catch (error) {
        console.error(error);
    }
}
```

## Promise Methods
- `Promise.all([...])` - Wait for all promises
- `Promise.race([...])` - Wait for first promise
- `Promise.allSettled([...])` - Wait for all (success or fail)
- `Promise.any([...])` - Wait for first successful
]],
        },
        fetch = {
            title = "Fetch API",
            content = [[
# Fetch API

## Basic GET Request
```javascript
fetch('https://api.example.com/data')
    .then(response => response.json())
    .then(data => console.log(data))
    .catch(error => console.error('Error:', error));
```

## POST Request
```javascript
fetch('https://api.example.com/data', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
    },
    body: JSON.stringify({ key: 'value' })
})
    .then(response => response.json())
    .then(data => console.log(data));
```

## With Async/Await
```javascript
async function getData() {
    const response = await fetch(url);
    if (!response.ok) {
        throw new Error('HTTP error ' + response.status);
    }
    return await response.json();
}
```

## Response Methods
- `response.json()` - Parse JSON
- `response.text()` - Get text
- `response.blob()` - Get binary data
- `response.arrayBuffer()` - Get array buffer
]],
        },
    },
    
    python = {
        list = {
            title = "Python Lists",
            content = [[
# Python Lists

## Common Methods
- `append(x)` - Add item to end
- `extend(iterable)` - Add all items from iterable
- `insert(i, x)` - Insert item at position
- `remove(x)` - Remove first occurrence
- `pop([i])` - Remove and return item at position
- `clear()` - Remove all items
- `index(x)` - Return index of first occurrence
- `count(x)` - Return number of occurrences
- `sort()` - Sort list in place
- `reverse()` - Reverse list in place
- `copy()` - Return shallow copy

## List Comprehension
```python
# Basic
squares = [x**2 for x in range(10)]

# With condition
evens = [x for x in range(10) if x % 2 == 0]

# Nested
matrix = [[i*j for j in range(3)] for i in range(3)]
```

## Slicing
```python
lst = [0, 1, 2, 3, 4, 5]
lst[1:4]     # [1, 2, 3]
lst[:3]      # [0, 1, 2]
lst[3:]      # [3, 4, 5]
lst[::2]     # [0, 2, 4]
lst[::-1]    # [5, 4, 3, 2, 1, 0]
```
]],
        },
        dict = {
            title = "Python Dictionaries",
            content = [[
# Python Dictionaries

## Common Methods
- `keys()` - Return dict keys
- `values()` - Return dict values
- `items()` - Return (key, value) pairs
- `get(key, default)` - Get value with default
- `pop(key)` - Remove and return value
- `popitem()` - Remove and return (key, value)
- `update(dict)` - Update with another dict
- `clear()` - Remove all items
- `setdefault(key, default)` - Get or set default

## Dict Comprehension
```python
# Basic
squares = {x: x**2 for x in range(5)}

# With condition
evens = {x: x**2 for x in range(10) if x % 2 == 0}

# From lists
keys = ['a', 'b', 'c']
values = [1, 2, 3]
d = {k: v for k, v in zip(keys, values)}
```

## Examples
```python
# Iterate
for key, value in dict.items():
    print(f"{key}: {value}")

# Get with default
value = d.get('key', 'default')

# Update
d.update({'new_key': 'new_value'})
```
]],
        },
    },
    
    lua = {
        table = {
            title = "Lua Tables",
            content = [[
# Lua Tables

## Creating Tables
```lua
-- Array-like
local arr = {1, 2, 3, 4, 5}

-- Dictionary-like
local dict = {
    name = "John",
    age = 30,
    city = "NYC"
}

-- Mixed
local mixed = {
    10, 20, 30,
    key = "value",
    nested = {a = 1, b = 2}
}
```

## Common Operations
```lua
-- Insert
table.insert(arr, value)
table.insert(arr, pos, value)

-- Remove
table.remove(arr)          -- remove last
table.remove(arr, pos)     -- remove at position

-- Concat
local str = table.concat(arr, separator)

-- Sort
table.sort(arr)
table.sort(arr, function(a, b) return a > b end)
```

## Iteration
```lua
-- Numeric indices
for i, v in ipairs(arr) do
    print(i, v)
end

-- All keys (including non-numeric)
for k, v in pairs(dict) do
    print(k, v)
end

-- Numeric for loop
for i = 1, #arr do
    print(arr[i])
end
```

## Length
```lua
local len = #arr  -- length operator
```
]],
        },
    },

    go = {
        slice = {
            title = "Go Slices",
            content = [[
# Go Slices

## Creating Slices
```go
// Literal
s := []int{1, 2, 3, 4, 5}

// Make
s := make([]int, 5)        // len=5, cap=5
s := make([]int, 5, 10)    // len=5, cap=10

// From array
arr := [5]int{1, 2, 3, 4, 5}
s := arr[1:4]              // [2, 3, 4]
```

## Common Operations
```go
// Append
s = append(s, 6)
s = append(s, 7, 8, 9)
s = append(s, anotherSlice...)

// Copy
dest := make([]int, len(src))
copy(dest, src)

// Length and capacity
len(s)
cap(s)
```

## Slicing
```go
s := []int{0, 1, 2, 3, 4, 5}
s[1:4]      // [1, 2, 3]
s[:3]       // [0, 1, 2]
s[3:]       // [3, 4, 5]
s[:]        // full slice
```

## Iteration
```go
// Index and value
for i, v := range s {
    fmt.Println(i, v)
}

// Value only
for _, v := range s {
    fmt.Println(v)
}

// Index only
for i := range s {
    fmt.Println(i)
}
```
]],
        },
        map = {
            title = "Go Maps",
            content = [[
# Go Maps

## Creating Maps
```go
// Literal
m := map[string]int{
    "apple": 5,
    "banana": 3,
}

// Make
m := make(map[string]int)

// Empty
var m map[string]int  // nil map, don't use before make
```

## Operations
```go
// Set
m["key"] = value

// Get
value := m["key"]

// Get with existence check
value, ok := m["key"]
if ok {
    // key exists
}

// Delete
delete(m, "key")

// Length
len(m)
```

## Iteration
```go
// Key and value
for key, value := range m {
    fmt.Println(key, value)
}

// Key only
for key := range m {
    fmt.Println(key)
}
```

## Notes
- Maps are not safe for concurrent use
- Iteration order is not guaranteed
- Cannot get address of map element
]],
        },
    },
}

-- Search through offline docs
M.search = function(query, filetype)
    query = query:lower()
    filetype = filetype or "javascript"
    
    local results = {}
    local lang_docs = M.docs[filetype]
    
    if not lang_docs then
        return nil
    end
    
    -- Search through topics
    for topic, doc in pairs(lang_docs) do
        if topic:lower():find(query) or doc.title:lower():find(query) then
            table.insert(results, {
                topic = topic,
                title = doc.title,
                content = doc.content,
                relevance = topic:lower() == query and 100 or 50
            })
        end
    end
    
    -- Sort by relevance
    table.sort(results, function(a, b) return a.relevance > b.relevance end)
    
    return results
end

-- Get documentation for a specific topic
M.get = function(topic, filetype)
    filetype = filetype or "javascript"
    local lang_docs = M.docs[filetype]
    
    if not lang_docs then
        return nil
    end
    
    return lang_docs[topic]
end

-- List all available topics for a language
M.list_topics = function(filetype)
    filetype = filetype or "javascript"
    local lang_docs = M.docs[filetype]
    
    if not lang_docs then
        return {}
    end
    
    local topics = {}
    for topic, doc in pairs(lang_docs) do
        table.insert(topics, {
            topic = topic,
            title = doc.title
        })
    end
    
    table.sort(topics, function(a, b) return a.topic < b.topic end)
    
    return topics
end

return M
