local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "Remotes"
    remotesFolder.Parent = ReplicatedStorage
end

local focusToggle = remotesFolder:FindFirstChild("FocusToggle")
if not focusToggle or not focusToggle:IsA("RemoteEvent") then
    if focusToggle and not focusToggle:IsA("RemoteEvent") then
        focusToggle:Destroy()
    end

    focusToggle = Instance.new("RemoteEvent")
    focusToggle.Name = "FocusToggle"
    focusToggle.Parent = remotesFolder
end

return {
    FocusToggle = focusToggle,
}
