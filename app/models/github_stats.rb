# == Schema Information
#
# Table name: github_stats
#
#  id                      :integer          not null, primary key
#  addon_id                :integer
#  open_issues             :integer
#  contributors            :integer
#  commits                 :integer
#  forks                   :integer
#  first_commit_date       :datetime
#  first_commit_sha        :string
#  latest_commit_date      :datetime
#  latest_commit_sha       :string
#  stars                   :integer
#  penultimate_commit_date :datetime
#  penultimate_commit_sha  :string
#

class GithubStats < ActiveRecord::Base
	belongs_to :addon
end
