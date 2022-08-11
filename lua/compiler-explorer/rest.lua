local curl = require("plenary.curl")
local config = require("compiler-explorer.config")

local json = vim.json

local M = {}

function M.languages_get()
  local conf = config.get_config()
  local url = table.concat({conf.url, "api", "languages"}, "/")

  local resp = curl.get(url, {
    accept = "application/json",
  })
  local langs = json.decode(resp.body)
  return langs
end

function M.compilers_get(lang)
  local conf = config.get_config()
  local url = table.concat({conf.url, "api", "compilers", lang}, "/")

  local resp = curl.get(url, {
    accept = "application/json",
  })
  if resp.status ~= 200 then
    error("bad request")
  end

  local compilers = json.decode(resp.body)
  return compilers
end

function M.libraries_get(lang)
  local conf = config.get_config()
  local url = table.concat({conf.url, "api", "libraries", lang}, "/")

  local resp = curl.get(url, {
    accept = "application/json",
  })
  if resp.status ~= 200 then
    error("bad request")
  end

  local libs = json.decode(resp.body)
  return libs
end

function M.create_compile_body(source, compiler_opts, compiler_id)
  vim.validate({
    source = { source, "string" },
    compiler_id = { compiler_id, "string" },
  })

  local body = {
    source = source,
    compiler = compiler_id,
    allowStoreCodeDebug = true,
    options = {
      filters = {},
      libraries = {},
      tools = {},
      compilerOptions = {},
      userArguments = compiler_opts,
    },
  }

  return body
end

function M.compile_post(compiler_id, body)
  local conf = config.get_config()
  local url = table.concat({conf.url, "api", "compiler", compiler_id, "compile"}, "/")

  local resp = curl.post(url, {
    body = json.encode(body),
    headers = {
      content_type = "application/json",
      accept = "application/json",
    },
  })
  if resp.status ~= 200 then
    error("bad request")
  end

  local out = json.decode(resp.body)
  return out
end

return M
