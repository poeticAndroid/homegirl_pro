function _init(args)
  anim = image.load(args[1])
  if anim == nil then
    print("Couldn't load file " .. args[1])
    return sys.exit(1)
  end
  image.save(args[#args], anim)
end
