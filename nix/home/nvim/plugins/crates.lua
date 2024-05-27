local crates_status_ok, crates = pcall(require, "crates")
if not crates_status_ok then
	return
end

crates.setup()
