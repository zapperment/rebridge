return function (str, chunkLength, numChunks)
    -- Check if the provided parameters are valid
    if not str or not chunkLength or not numChunks then
        return nil, "Invalid parameters"
    end

    local result = {}
    local index = 1
    for _ = 1, numChunks do
        local chunk = str:sub(index, index + chunkLength - 1)

        -- Pad the chunk with spaces if it's too short
        while #chunk < chunkLength do
            chunk = chunk .. " "
        end

        table.insert(result, chunk)
        index = index + chunkLength
    end

    return result
end