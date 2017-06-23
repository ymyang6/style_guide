# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  column             :integer
#  row                :integer
#  height_in_lines    :integer
#  image_path         :string
#  caption_title      :string
#  caption            :string
#  position           :integer
#  page_number        :integer
#  story_number       :integer
#  landscape          :boolean
#  used_in_layout     :boolean
#  working_article_id :integer
#  issue_id           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end