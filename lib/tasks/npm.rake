namespace :npm do
  task fetch: :environment do
    sh 'node ./npm-fetch/fetch.js'
  end

  task fetch_addon_info: [ 'npm:update' ] do
    if Rails.env.production?
      snitch_url = ENV['FETCH_SNITCH_URL']
      sh "curl #{snitch_url}"
    end
  end

  task update: [ :environment, 'npm:fetch' ] do
    begin
      addons = ActiveSupport::JSON.decode(File.read('/tmp/addons.json'))
    rescue ActiveSupport::JSON.parse_error
      raise "Invalid JSON in addons.json file"
    end

    addons.each do |metadata|
      name = metadata['name']

      addon = Addon.find_or_initialize_by(name: name)
      latest_version = metadata['latest']['version']
      addon.update(
        latest_version: latest_version,
        latest_version_date: metadata['time'] ? metadata['time'][ latest_version ] : nil,
        description: metadata['description'],
        license: metadata['license'],
        repository_url: metadata['repository']['url']
      )

      if metadata['downloads']['start']
        addon_downloads = addon.downloads.find_or_create_by(date: metadata['downloads']['start'])
        addon_downloads.downloads = metadata['downloads']['downloads']
        addon_downloads.save
      end

      npm_author = metadata['author']
      if npm_author
        author = NpmUser.find_or_create_by(name: npm_author['name'], email: npm_author['email'])
        if author != addon.author
          addon.author = author
        end
      else
        addon.author = nil
      end

      addon.npm_keywords.clear
      metadata['keywords'].each do |keyword|
        npm_keyword = NpmKeyword.find_or_create_by(keyword: keyword)
        addon.npm_keywords << npm_keyword
      end

      addon.maintainers.clear
      metadata['maintainers'].each do |maintainer|
        npm_user = NpmUser.find_or_create_by(name: maintainer['name'], email: maintainer['email'])
        if maintainer['gravatar_id']
          npm_user.gravatar = maintainer['gravatar_id']
          npm_user.save
        end
        addon.maintainers << npm_user
      end

      current_versions = metadata['versions'].keys
      addon.addon_versions = AddonVersion.where(addon_id: addon.id, version: current_versions)

      metadata['versions'].each do |version, data|
        addon_version = addon.addon_versions.where(version: version).first
        unless addon_version
          new_addon_version = AddonVersion.find_or_create_by(
            addon: addon,
            version: version,
            released: metadata['time'][version]
          )
          addon.addon_versions << new_addon_version
        end
      end

      addon.save!

      Rails.cache.delete 'api:addons:index'
    end
  end
end
