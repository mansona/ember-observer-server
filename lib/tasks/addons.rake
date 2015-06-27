require 'net/http'

namespace :addons do
	namespace :update do
		desc "Update download count for addons"
		task download_count: :environment do
			Addon.all.each do |addon|
				addon.last_month_downloads = addon.downloads.where('date > ?', 1.month.ago).sum(:downloads)
				addon.save
			end
		end

		desc "Update 'top 10%' flag for addon downloads"
		task downloads_flag: [ :environment, 'addons:update:download_count' ] do
			total_addons = Addon.count
			Addon.order('last_month_downloads desc').each_with_index do |addon, index|
				if (index + 1).to_f / total_addons <= 0.1
					addon.is_top_downloaded = true
				else
					addon.is_top_downloaded = false
				end
				addon.save
			end
		end

		desc "Update 'top 10%' flag for Github stars"
		task stars_flag: :environment do
			addons_with_stars = Addon.includes(:github_stats).references(:github_stats).where('github_stats.addon_id is not null and stars is not null')
			total_addons_with_stars = addons_with_stars.count
			Addon.includes(:github_stats).references(:github_stats).where('github_stats.addon_id is null or stars is null').each do |addon|
				addon.is_top_starred = false
				addon.save
			end
			addons_with_stars.order('stars desc').each_with_index do |addon, index|
				if (index + 1).to_f / total_addons_with_stars <= 0.1
					addon.is_top_starred = true
				else
					addon.is_top_starred = false
				end
				addon.save
			end
		end

		desc "Update scores for addons"
		task scores: :environment do
			addon_badge_dir = ENV['ADDON_BADGE_DIR'] || File.join(Rails.root, "public/badges")
			Addon.all.each do |addon|
				score = addon.score = AddonScoreCalculator.calculate_score(addon)
				addon.save

				if addon.is_wip
					score = 'wip'
				else
					score = addon.score || 'na'
				end
				badge_image_path = File.join(Rails.root, "app/assets/images/badges/#{score}.svg")
				cp badge_image_path, File.join(addon_badge_dir, "#{safe_name addon.name}.svg")
			end
		end

		desc "Update all data for addons"
		task all: [ :environment, 'npm:fetch_addon_info', 'github:update:all', 'addons:update:downloads_flag', 'addons:update:stars_flag', 'addons:update:scores', 'cache:regenerate:all' ]

		desc "Update latest version number for ember-cli"
		task ember_cli_version: :environment do
			result = JSON.load(get_url('http://registry.npmjs.org/ember-cli'))
			version = result['dist-tags']['latest']
			if version
				ember_cli = LatestVersion.find_or_create_by(package: 'ember-cli')
				ember_cli.version = version
				ember_cli.save!
			end
		end

	end
end

def get_url(url)
	Net::HTTP.get(URI.parse(url))
end

def safe_name(name)
	name.gsub(/[^A-Za-z0-9]/, '-')
end
