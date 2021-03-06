# == Schema Information
#
# Table name: page_headings
#
#  id             :integer          not null, primary key
#  page_number    :integer
#  section_name   :string
#  date           :string
#  layout         :text
#  publication_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class PageHeading < ApplicationRecord
  belongs_to :publication

  after_create :setup

  def path
    "#{Rails.root}/public/#{publication.id}/page_heading/#{id}"
  end

  def relative_path
    "#/#{publication.id}/page_heading/#{id}"
  end

  def setup
    system("mkidr -p #{path}") unless File.directory?(path)
  end

  def images_path
    path + "/images"
  end

  def layout_path
    path + "/layout.rb"
  end

  def story_path
    path + "/story.md"
  end

  def pdf_path
    path + "/output.pdf"
  end

  def jpg_path
    path + "/output.jpg"
  end

  def pdf_image_path
    "/#{publication.id}/page_heading/#{page_number}/output.pdf"
  end

  def jpg_image_path
    "/#{publication.id}/page_heading/#{page_number}/output.jpg"
  end

  def setup
    system("mkdir -p #{path}") unless File.directory?(path)
  end

  def page_heading_width
    publication.page_heading_width
  end

  def front_page_real_value
    real_data =<<~EOF
    RLayout::Container.new(width: 1028.976498, height: 137.708, layout_direction: 'horinoztal') do
      image(local_image: '1.pdf', width: 1028.976498, height: 137.708,)
      text('2017년 5월 11일 목요일 (4200호)', x: 886.00, y: 108, width: 200, height: 12, font: 'YDVYGOStd12', font_size: 9.5, text_alignment: 'left')
    end
    EOF
  end

  def front_page_content
    page_heading_width  = publication.page_heading_width

    first_page=<<~EOF
    RLayout::Container.new(width: #{page_heading_width}, height: #{publication.front_page_heading_height_in_pt}, layout_direction: 'horinoztal') do
      image(local_image: '1.pdf', width: #{page_heading_width}, height: 110,)
      text('2017년 5월 11일 목요일 (4200호)', x: 886.00, y: #{114.7549 - 20.0}, width: 200, height: 12, font: 'YDVYGOStd12', font_size: 9.5, text_alignment: 'left')
    end
    EOF
  end

  def self.front_page_content(page)
    page_number   = page.page_number
    section_name  = page.section_name
    page_heading_width = page.page_heading_width
    page_heading_height = page.publication.front_page_heading_height_in_pt
    date                = page.korean_date_string
    first_page=<<~EOF
    RLayout::Container.new(width: #{page_heading_width}, height: #{page_heading_height}, layout_direction: 'horinoztal') do
      image(local_image: '1.pdf', width: #{page_heading_width}, height: 110,)
      text('#{date}', x: 884.00, y: #{114.7549 - 20.0}, width: 200, height: 12, font: 'YDVYGOStd12', font_size: 9.5, text_alignment: 'left')
    end
    EOF
  end

  def even_content
    page_heading_width  = publication.page_heading_width
    page_heading_height = publication.inner_page_heading_height_in_pt
    date                = '2017년 5월 11일 목요일'
    even=<<~EOF
    RLayout::Container.new(width: #{page_heading_width}, height: #{page_heading_height}, layout_direction: 'horinoztal') do
      text('#{section_name}', x: 464.0 , y: 1, width: 100, font: 'YDVYMjOStd14',  font_size: 20, text_color: "#221E1F", text_alignment: 'center')
      text('#{page_number}', x: 1.9795, y: 1, font: 'YDVYGOStd14', font_size: 24, text_color: "#221E1F", width: 50, height: 44)
      text(#{date}, x: 33.5356, y: 10,  width: 200, font: 'YDVYGOStd12', font_size: 9.5, text_color: "#221E1F", text_alignment: 'left')
      image(image_path: '/Users/Shared/SoftwareLab/news_heading/logo/내일신문.pdf', x: #{page_heading_width - 48}, y: 10, width: 43, height: 12,)
      line(x: -3, width: 1037.81, y: 23.803, stroke_width: 0.3, stroke_color: "#221E1F")
      line(x: -3, width: 1037.81, y: 25.903, stroke_width: 0.3, stroke_color: "#221E1F")
    end
    EOF
  end

  def real_even
    real_data=<<~EOF
    RLayout::Container.new(width: 1028.976498, height: 41.70979114285714, layout_direction: 'horinoztal') do
      image(image_path: '/Users/Shared/SoftwareLab/newsman/내일신문/even_bgimage.pdf', x: 0, y: 0, width: 1028.976498, height: 38.70979114285714,)
      text('정치', fill_color: 'clear', x: 464.0 , y: 1, width: 100, font: 'YDVYMjOStd14',  font_size: 14, text_color: "#221E1F", text_alignment: 'center')
      text('2', x: 1.9795, y: 1, font: 'YDVYGOStd12', font_size: 24, text_color: "#221E1F", width: 50, height: 44)
      text('2017년 5월 11일 목요일', fill_color: 'clear', x: 38.875, y: 10,  width: 200, font: 'YDVYGOStd12', font_size: 9.5, text_color: "#221E1F", text_alignment: 'left')
    end

    EOF
  end

  def self.even_content(page)
    page_number         = page.page_number
    section_name        = page.section_name
    page_heading_width  = page.page_heading_width
    page_heading_height = page.heading_height_in_pt
    date                = page.korean_date_string

    even=<<~EOF
    RLayout::Container.new(width: #{page_heading_width}, height: #{page_heading_height}, layout_direction: 'horinoztal') do
      image(image_path: '/Users/Shared/SoftwareLab/newsman/내일신문/even_bgimage.pdf', x: 0, y: 0, width: 1028.976498, height: 38.70979114285714,)
      text('#{section_name}', fill_color: 'clear', y: 1, width: 100, font: 'YDVYMjOStd14',  font_size: 14, text_color: "#221E1F", text_alignment: 'center')
      text('#{page_number}', x: 1.9795, y: 1, font: 'YDVYGOStd14', font_size: 24, text_color: "#221E1F", width: 50, height: 44)
      text('#{date}', fill_color: 'clear', x: 38.875, y: 10,  width: 200, font: 'YDVYGOStd12', font_size: 9.5, text_color: "#221E1F", text_alignment: 'left')
    end
    EOF
  end

  def odd_content
    page_heading_width  = publication.page_heading_width
    page_heading_height = publication.inner_page_heading_height_in_pt
    date                = '2017년 5월 11일 목요일'
    odd=<<~EOF
    RLayout::Container.new(width: #{page_heading_width}, height: #{page_heading_height}, layout_direction: 'horinoztal') do
      text('#{section_name}', x: 464.0, y: 1, width: 100, font: 'YDVYMjOStd14',  font_size: 20, text_color: "#221E1F", text_alignment: 'center')
      text('#{date}', x: 885.5693, y: 10,  width: 200, font: 'YDVYGOStd12', font_size: 9.5, text_color: "#221E1F", text_alignment: 'left')
      text('#{page_number}', x: 988, y: 1, font: 'YDVYGOStd14', font_size: 24, text_color: "#221E1F", width: 40, height: 44, text_alignment: 'right')
      image(image_path: '/Users/Shared/SoftwareLab/news_heading/logo/내일신문.pdf', x: 3, y: 10, width: 43, height: 12, fit_type: 0)
      line(x: -3, width: 1037.81, y: 23.803, stroke_width: 0.3, stroke_color: "#221E1F")
      line(x: -3, width: 1037.81, y: 25.903, stroke_width: 0.3, stroke_color: "#221E1F")
    end
    EOF
  end


  def self.odd_content(page)
    page_number   = page.page_number
    section_name  = page.section_name
    page_heading_width  = page.publication.page_heading_width
    page_heading_height = page.heading_height_in_pt
    date                = page.korean_date_string
    odd=<<~EOF
    RLayout::Container.new(width: #{page_heading_width}, height: #{page_heading_height}, layout_direction: 'horinoztal') do
      text('#{section_name}', x: 464.0, y: 1, width: 100, font: 'YDVYMjOStd14',  font_size: 20, text_color: "#221E1F", text_alignment: 'center')
      text('#{date}', x: 885.5693, y: 10,  width: 200, font: 'YDVYGOStd12', font_size: 9.5, text_color: "#221E1F", text_alignment: 'left')
      text('#{page_number}', x: 988, y: 1, font: 'YDVYGOStd14', font_size: 24, text_color: "#221E1F", width: 40, height: 44, text_alignment: 'right')
      image(image_path: '/Users/Shared/SoftwareLab/news_heading/logo/내일신문.pdf', x: 3, y: 10, width: 43, height: 12, fit_type: 0)
      line(x: -3, width: 1037.81, y: 23.803, stroke_width: 0.3, stroke_color: "#221E1F")
      line(x: -3, width: 1037.81, y: 25.903, stroke_width: 0.3, stroke_color: "#221E1F")
    end
    EOF
  end


  def layout_content
    if page_number == 1
      return front_page_content
    elsif page_number.even?
      return even_content
    else
      return odd_content
    end
  end

  def self.layout_content(page)
    page_number = page.page_number
    section_name = page.section_name
    if page_number == 1
      return PageHeading.front_page_content(page)
    elsif page_number.even?
      return PageHeading.even_content(page)
    else
      return PageHeading.odd_content(page)
    end
  end

  def save_layout
    File.open(layout_path, 'w'){|f| f.write layout_content}
  end

  def generate_pdf
    save_layout
    system "cd #{path} && /Applications/newsman.app/Contents/MacOS/newsman article ."
  end

  def self.save_layout(page)
    page_headig_layout_path = page.page_headig_layout_path
    system("mkdir -p #{page.page_heading_path}") unless File.exist?(page.page_heading_path)
    File.open(page_headig_layout_path, 'w'){|f| f.write PageHeading.layout_content(page)}
  end

  def self.generate_pdf(page)
    PageHeading.save_layout(page)
    path = page.page_heading_path
    system "cd #{path} && /Applications/newsman.app/Contents/MacOS/newsman article ."
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      # get rif of id, created_at, updated_at
      filtered = column_names.dup
      filtered.shift
      filtered.pop
      filtered.pop
      csv << filtered
      all.each do |item|
        csv << item.attributes.values_at(*filtered)
      end
    end
  end

end
