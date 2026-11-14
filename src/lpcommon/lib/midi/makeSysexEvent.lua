-- makes what makes a SysEx message of a Launchpad, whose messages all begin
-- with the header given, from the bytes between the header and the end
return function(sysexHeader)
  return function(payload, options)
    return remote.make_midi(sysexHeader .. " " .. payload .. " f7", options or {})
  end
end
