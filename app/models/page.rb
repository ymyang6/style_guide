# == Schema Information
#
# Table name: pages
#
#  id           :integer          not null, primary key
#  page_number  :integer
#  section_name :string
#  column       :integer
#  row          :integer
#  ad_type      :string
#  story_count  :integer
#  color_page   :boolean
#  profile      :string
#  issue_id     :integer
#  template_id  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Page < ApplicationRecord
  belongs_to :issue
  has_many :working_articles
  has_many :placed_ads

  before_create :make_profile
  after_create :setup

  def path
    "#{Rails.root}/public/#{issue.publication.id}/issue/#{issue.id}/#{page_number}"
  end

  def pdf_image_path
    "/#{issue.publication.id}/issue/#{issue.id}/#{page_number}/section.pdf"
  end

  def pdf_path
    "#{Rails.root}/public/#{issue.publication.id}/issue/#{issue.id}/#{page_number}/section.pdf"
  end

  def jpg_image_path
    "/#{issue.publication.id}/issue/#{issue.id}/#{page_number}/section.jpg"
  end

  def jpg_path
    "#{Rails.root}/public/#{issue.publication.id}/issue/#{issue.id}/#{page_number}/section.jpg"
  end

  def setup
    system "mkdir -p #{path}" unless File.directory?(path)
    copy_section_template
  end

  def ad_folder
    path + "/ad"
  end

  def ad_place_holder_string
    ad = placed_ads.first
    if ad
      placed_ads.first.ad_place_holder_string
    end
    ""
  end

  def save_ad_place_holder
    puts __method__
    s = ad_place_holder_string
    unless s == ""
      ad_info_path = ad_folder + "/#{save_ad_place_holder}"
      system "cd #{ad_folder} && touch #{ad_info_path}"
    end
  end

  def section_template_folder
    "#{Rails.root}/public/#{issue.publication.id}/section/#{page_number}/#{profile}"
  end

  def story_folders
    #code
  end

  def  fix_working_articles
    template_section = Section.find(template_id)
    layout = eval(template_section.layout)
    layout.each_with_index do |box, i|
      atts = {}
      atts[:page_id]  = self
      atts[:order]    = i + 1
      if box.length == 4
        target = WorkingArticle.where(atts).first_or_create
        target.column     = box[2]
        target.row        = box[3]
        target.is_front_page = (page_number == 1 ? true : false)
        target.top_story     = (i == 0 ? true : false)
        target.top_position  = false
        if box[1] == 0 && page_number != 1
          target.top_position  = true
        elsif box[1] == 1 && page_number == 1
          target.top_position  = true
        end
        target.save
      else
        #TODO we have non-article box, ad or something
        # since this is copyied form section template
        # we might not have to anything?
      end

    end
  end

  def update_working_articles
    puts __method__
    puts "template_id:#{template_id}"
    template_section = Section.find(template_id)

    # evaled_layout = eval(template_section.layout)
    # evaled_layout.each do |box_rect|
    layout = eval(template_section.layout)
    layout.each_with_index do |box, i|
      atts = {}
      atts[:page_id]  = self
      atts[:order]    = i + 1
      atts[:column]   = box[2]
      atts[:row]      = box[3]

      if box.length == 4
        atts[:is_front_page] = (page_number == 1 ? true : false)
        atts[:top_story]     = (i == 0 ? true : false)
        atts[:top_position]  = false
        if box[1] == 0 && page_number != 1
          atts[:top_position]  = true
        elsif box[1] == 1 && page_number == 1
          atts[:top_position]  = true
        end
        WorkingArticle.where(atts).first_or_create
      elsif box.length == 5
        value = box[4].values.first
        ad_hash = {ad_type: value} #conver "광고 to ad_type"
        atts.merge!(ad_hash)
        #TODO we have non-article box, ad or something
        # since this is copyied form section template
        # we might not have to anything?
        PlacedAd.where(atts).first_or_create
      end
    end

  end

  def copy_section_template
    puts __method__
    source = Dir.glob("#{section_template_folder}/*").first
    if source
      system("cp -r #{source}/ #{path}")
    else
      puts "No template in #{section_template_folder}"
    end

    update_working_articles
  end

  def update_page_layout
    puts __method__
    copy_section_template
    generate_pdf
  end

  def generate_pdf
    system "cd #{path} && /Applications/newsman.app/Contents/MacOS/newsman section_pdf ."
  end

  def eval_layout
    eval(layout)
  end

  # other SectionTemplate choices for current page
  def other_choices
    Section.where(page_number: page_number).all
  end

  private

  def make_profile
    profile = "#{column}x#{row}_"
    profile += "H_" if page_number == 1
    profile += "#{ad_type}_" if ad_type
    profile += story_count.to_s
    puts "page_profile:#{profile}"
    self.profile = profile
  end

end