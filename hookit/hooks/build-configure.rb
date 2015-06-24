# import some logic/helpers from lib/engine.rb
include NanoBox::Engine

# 'payload' is a helper function within the hookit framework that will parse
# input provided as JSON into a hash with symbol keys.
# https://github.com/pagodabox/hookit/blob/master/lib/hookit/hook.rb#L7-L17
# 
# Now we extract the 'boxfile' section of the payload, which is only the
# 'build' section of the Boxfile provided by the app
boxfile = payload[:boxfile] || {}

# 1)
# If an engine is mounted from the workstation, let's put those in place first.
# This process will replace any default engine if the names collide.
if boxfile[:engine] and is_filepath?(boxfile[:engine])

  basename = ::File.basename(boxfile[:engine])
  path     = "#{SHARE_DIR}/engines/#{basename}"

  # if the engine has been shared with us, then let's copy it over
  if ::File.exist?(path)

    # remove any official engine that may be in the way
    directory "#{ENGINE_DIR}/#{basename}" do
      action :delete
    end

    # copy the mounted engine into place
    execute 'move engine into place' do
      command "cp -r #{ENGINE_LIVE_DIR}/#{basename} #{ENGINE_DIR}/"
    end
  end

  # now let's set the engine in the registry for later consumption
  registry('engine', basename)
end

# 2)
# If a custom engine is specified, and is not mounted from
# the workstation, let's fetch it from warehouse.nanobox.io. 
# This process will replace any default engine if the names collide.
if boxfile[:engine] and not is_filepath?(boxfile[:engine])
  # todo: wait until nanobox-cli can fetch engine
end