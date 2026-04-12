-- Tests for Phase 1: TOC file validation
-- Validates all _Mainline.toc files exist and have correct metadata

describe("Mainline TOC Files (Phase 1)", function()
  local function readFile(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
  end

  local function getField(content, field)
    return content:match("## " .. field .. ": ([^\n]+)")
  end

  local tocFiles = {
    { path = "WeakAuras/WeakAuras_Mainline.toc",                      expectedFlavor = "Mainline", expectedGameType = nil },
    { path = "WeakAurasOptions/WeakAurasOptions_Mainline.toc",        expectedFlavor = nil,        expectedGameType = "mainline" },
    { path = "WeakAurasTemplates/WeakAurasTemplates_Mainline.toc",    expectedFlavor = nil,        expectedGameType = "mainline" },
    { path = "WeakAurasArchive/WeakAurasArchive_Mainline.toc",        expectedFlavor = nil,        expectedGameType = "mainline" },
    { path = "WeakAurasModelPaths/WeakAurasModelPaths_Mainline.toc",  expectedFlavor = nil,        expectedGameType = "mainline" },
  }

  for _, tocDef in ipairs(tocFiles) do
    describe(tocDef.path, function()
      local content

      setup(function()
        content = readFile(tocDef.path)
      end)

      it("exists", function()
        assert.is_not_nil(content, "TOC file not found: " .. tocDef.path)
      end)

      it("has Interface version 120001 (Midnight)", function()
        if not content then return end
        local interface = getField(content, "Interface")
        assert.equals("120001", interface)
      end)

      if tocDef.expectedFlavor then
        it("has X-Flavor: " .. tocDef.expectedFlavor, function()
          if not content then return end
          local flavor = getField(content, "X%-Flavor")
          assert.equals(tocDef.expectedFlavor, flavor)
        end)
      end

      if tocDef.expectedGameType then
        it("has AllowLoadGameType: " .. tocDef.expectedGameType, function()
          if not content then return end
          local gameType = getField(content, "AllowLoadGameType")
          assert.equals(tocDef.expectedGameType, gameType)
        end)
      end

      it("does not reference Mists-specific files", function()
        if not content then return end
        assert.is_nil(content:match("Types_Mists%.lua"), "Should not include Types_Mists.lua")
        assert.is_nil(content:match("ModelPathsMists%.lua"), "Should not include ModelPathsMists.lua")
        assert.is_nil(content:match("TriggerTemplatesDataMists%.lua"), "Should not include TriggerTemplatesDataMists.lua")
        assert.is_nil(content:match("MiniTalent_Mists%.lua"), "Should not include MiniTalent_Mists.lua")
      end)
    end)
  end

  describe("WeakAuras_Mainline.toc", function()
    it("includes Types_Retail.lua", function()
      local content = readFile("WeakAuras/WeakAuras_Mainline.toc")
      assert.is_not_nil(content)
      assert.is_not_nil(content:match("Types_Retail%.lua"))
    end)
  end)

  describe("WeakAurasOptions_Mainline.toc", function()
    it("includes AceGUIWidget-WeakAurasMiniTalent_TWW.lua", function()
      local content = readFile("WeakAurasOptions/WeakAurasOptions_Mainline.toc")
      assert.is_not_nil(content)
      assert.is_not_nil(content:match("MiniTalent_TWW%.lua"))
    end)
  end)

  describe("WeakAurasTemplates_Mainline.toc", function()
    it("includes TriggerTemplatesData.lua (no suffix, retail version)", function()
      local content = readFile("WeakAurasTemplates/WeakAurasTemplates_Mainline.toc")
      assert.is_not_nil(content)
      assert.is_not_nil(content:match("TriggerTemplatesData%.lua"))
      assert.is_nil(content:match("TriggerTemplatesData%a+%.lua"), "Should use no-suffix retail file")
    end)
  end)

  describe("WeakAurasModelPaths_Mainline.toc", function()
    it("includes ModelPaths.lua (no suffix, retail version)", function()
      local content = readFile("WeakAurasModelPaths/WeakAurasModelPaths_Mainline.toc")
      assert.is_not_nil(content)
      assert.is_not_nil(content:match("ModelPaths%.lua"))
      assert.is_nil(content:match("ModelPaths%a+%.lua"), "Should use no-suffix retail file")
    end)
  end)
end)
