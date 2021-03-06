# == Schema Information
#
# Table name: ad_images
#
#  id                 :integer          not null, primary key
#  ad_type            :string
#  column             :integer
#  row                :integer
#  image_path         :string
#  advertiser         :string
#  page_number        :integer
#  article_number     :integer
#  working_article_id :integer
#  issue_id           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#



class AdImage < ApplicationRecord
  belongs_to :issue
  belongs_to :ad_box, optional: true

  before_create :parse_ad
  mount_uploader :ad_image, AdImageUploader

  def image_path
    "#{Rails.root}/public" + ad_image.url if ad_image
  end

  def path
    "#{page.path}/ad"
  end

  def ad_info
    h               = {}
    h[:page_number] = page.page_number
    h[:ad_type]     = ad_type
    h[:advertiser]  = advertiser
    h
  end

  def ad_image_string
    "#{page_number}"
  end

  def self.current_ad_images
    AdImage.where(issue_id: Issue.last.id).all
  end

  def self.place_all_ad_images
    AdImage.current_ad_images.each do |curremt_ad_image|
      curremt_ad_image.place_ad_image
    end
  end

  def place_ad_image
    if ad_box
      ad_box.generate_pdf
      ad_box.update_page_pdf
    end
  end

  private

  def parse_ad
    basename         = File.basename(ad_image.url)
    if basename      =~/^(\d+)/
      page_number             = $1
      self.page_number        = $1.to_i
      page                    = Page.where(issue_id: issue_id, page_number: page_number.to_i).first
      if page
        ad_box                  = page.ad_boxes.first
        if ad_box
          self.ad_box_id          = ad_box.id
          self.ad_type            = ad_box.ad_type
        end
      end
      # self.advertiser     = profile_array[2]
    else
      puts "we have ad without page_number!!!"
    end
    true
  end

end
